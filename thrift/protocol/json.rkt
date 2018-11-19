#lang racket/base
;;
;; thrift - protocol/json.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [make-json-encoder
   (-> transport? (or/c encoder? #f))]
  
  [make-json-decoder
   (-> transport? (or/c decoder? #f))]))

;; ---------- Requirements

(require racket/bool
         racket/format
         racket/string
         thrift
         thrift/protocol/exn-common
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Implementation

; From <https://github.com/apache/thrift/blob/master/lib/cpp/src/thrift/protocol/TJSONProtocol.h>
;
; * Implements a protocol which uses JSON as the wire-format.
; *
; * Thrift types are represented as described below:
; *
; * 1. Every Thrift integer type is represented as a JSON number.
; *
; * 2. Thrift doubles are represented as JSON numbers. Some special values are
; *    represented as strings:
; *    a. "NaN" for not-a-number values
; *    b. "Infinity" for positive infinity
; *    c. "-Infinity" for negative infinity
; *
; * 3. Thrift string values are emitted as JSON strings, with appropriate
; *    escaping.
; *
; * 4. Thrift binary values are encoded into Base64 and emitted as JSON strings.
; *    The readBinary() method is written such that it will properly skip if
; *    called on a Thrift string (although it will decode garbage data).
; *
; *    NOTE: Base64 padding is optional for Thrift binary value encoding. So
; *    the readBinary() method needs to decode both input strings with padding
; *    and those without one.
; *
; * 5. Thrift structs are represented as JSON objects, with the field ID as the
; *    key, and the field value represented as a JSON object with a single
; *    key-value pair. The key is a short string identifier for that type,
; *    followed by the value. The valid type identifiers are: "tf" for bool,
; *    "i8" for byte, "i16" for 16-bit integer, "i32" for 32-bit integer, "i64"
; *    for 64-bit integer, "dbl" for double-precision loating point, "str" for
; *    string (including binary), "rec" for struct ("records"), "map" for map,
; *    "lst" for list, "set" for set.
; *
; * 6. Thrift lists and sets are represented as JSON arrays, with the first
; *    element of the JSON array being the string identifier for the Thrift
; *    element type and the second element of the JSON array being the count of
; *    the Thrift elements. The Thrift elements then follow.
; *
; * 7. Thrift maps are represented as JSON arrays, with the first two elements
; *    of the JSON array being the string identifiers for the Thrift key type
; *    and value type, followed by the count of the Thrift pairs, followed by a
; *    JSON object containing the key-value pairs. Note that JSON keys can only
; *    be strings, which means that the key type of the Thrift map should be
; *    restricted to numeric or string types -- in the case of numerics, they
; *    are serialized as strings.
; *
; * 8. Thrift messages are represented as JSON arrays, with the protocol
; *    version #, the message name, the message type, and the sequence ID as
; *    the first 4 elements.
; *
; * More discussion of the double handling is probably warranted. The aim of
; * the current implementation is to match as closely as possible the behavior
; * of Java's Double.toString(), which has no precision loss.  Implementors in
; * other languages should strive to achieve that where possible. I have not
; * yet verified whether std::istringstream::operator>>, which is doing that
; * work for me in C++, loses any precision, but I am leaving this as a future
; * improvement. I may try to provide a C component for this, so that other
; * languages could bind to the same underlying implementation for maximum
; * consistency.
; *


(define (make-json-encoder transport)
  (define state (json-state #f '()))
  (encoder
   "simple-json"
   (λ (header) (write-message-begin transport state header))
   (λ () (write-message-end transport state))
   (λ () (write-struct-begin transport state))
   (λ () (write-struct-end transport state))
   (λ (header) (write-field-begin transport state header))
   (λ () (write-field-end transport state))
   (λ () (no-op-encoder "field-stop"))
   (λ (header) (write-map-begin transport state header))
   (λ () (write-map-end transport state))
   (λ (header) (write-list-begin transport state header))
   (λ () (write-list-end transport state))
   (λ (header) (write-list-begin transport state header))
   (λ () (write-list-end transport state))
   (λ (v) (write-boolean transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-bytes transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-string transport state v))))

(define (make-json-decoder transport)
  (define state (json-state #f '()))
  (decoder
   "simple-json"
   (λ () (read-message-begin transport state))
   (λ () (read-message-end transport state))
   (λ () (read-struct-begin transport state))
   (λ () (read-struct-end transport state))
   (λ () (read-field-begin transport state))
   (λ () (read-field-end transport state))
   (λ () (no-op-decoder "field-stop"))
   (λ () (read-map-begin transport state))
   (λ () (read-map-end transport state))
   (λ () (read-list-begin transport state))
   (λ () (read-list-end transport state))
   (λ () (read-list-begin transport state))
   (λ () (read-list-end transport state))
   (λ () (read-boolean transport state))
   (λ () (read-number transport state))
   (λ () (no-op-decoder "bytes"))
   (λ () (read-number transport state))
   (λ () (read-number transport state))
   (λ () (read-number transport state))
   (λ () (no-op-decoder "double"))
   (λ () (read-string transport state))))

;; ---------- Internal values/types

(define json-protocol-version 1)

(define json-array-begin (char->integer #\[))
(define json-array-end (char->integer #\]))

(define json-object-begin (char->integer #\{))
(define json-object-end (char->integer #\}))

(define json-space (char->integer #\space))
(define json-elem-sep (char->integer #\,))
(define json-key-sep (char->integer #\:))

(define type-ident
  (hash type-bool #"\"tf\""
        type-byte #"\"i8\""
        type-int16 #"\"i16\""
        type-int32 #"\"i32\""
        type-int64 #"\"i64\""
        type-double #"\"dbl\""
        type-string #"\"str\""
        type-binary #"\"str\""
        type-struct #"\"rec\""
        type-map #"\"map\""
        type-list #"\"lst\""
        type-set #"\"set\""))

(define type-ident/reverse
  (for/hash ([(id str) type-ident])
    (values (string-trim (bytes->string/utf-8 str) "\"") id)))

(struct json-state
  ([prefix #:mutable]
   [in-map #:mutable]))

;; ---------- Internal procedures read/write

;; [<version>,"<name>",<type>,<sequence>, ...
(define (write-message-begin tport state header)
  (log-thrift-debug "json:write-message-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (transport-write-byte tport json-array-begin)
  (set-json-state-prefix! state #f)
  (write-number tport state json-protocol-version)
  (write-string tport state (message-header-name header))
  (write-number tport state (message-header-type header))
  (write-number tport state (message-header-sequence-id header)))

(define (read-message-begin tport state)
  (log-thrift-debug "json:read-message-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (set-json-state-prefix! state #f)
  (define array-begin (transport-read-byte tport))
  (unless (equal? array-begin json-array-begin)
    (raise (decoding-error (current-continuation-marks) 'array-begin array-begin)))
  (define protocol-version (read-number tport state))
  (unless (equal? protocol-version json-protocol-version)
    (raise (invalid-protocol-version (current-continuation-marks) protocol-version)))
  (define msg-name (read-string tport state))
  (define msg-type (read-number tport state))
  (define msg-sequence (read-number tport state))
  (message-header msg-name msg-type msg-sequence))


(define (write-message-end tport state)
  (log-thrift-debug "json:write-message-end")
  (transport-write-byte tport json-array-end))

(define (read-message-end tport state)
  (log-thrift-debug "json:read-message-end"))

;; { ...
(define (write-struct-begin tport state)
  (log-thrift-debug "json:write-struct-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (write-prefix tport state)
  (transport-write-byte tport json-object-begin)
  (set-json-state-prefix! state #f))

(define (read-struct-begin tport state)
  (log-thrift-debug "json:read-struct-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (read-prefix tport state)
  (read-byte/expecting tport json-object-begin)
  (set-json-state-prefix! state #f))


;; ... }
(define (write-struct-end tport state)
  (log-thrift-debug "json:write-struct-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-byte tport json-object-end)
  (write-ifmap-element-suffix tport state))

(define (read-struct-end tport state)
  (log-thrift-debug "json:read-struct-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (read-byte/expecting tport json-object-end))


;; ["<key-type>","<element-type>",len, ...
(define (write-map-begin tport state header)
  (log-thrift-debug "json:write-map-begin")
  (write-prefix tport state)
  (set-json-state-prefix! state #f)
  (transport-write-byte tport json-array-begin)
  (write-bytes tport state (hash-ref type-ident (map-header-key-type header)))
  (write-bytes tport state (hash-ref type-ident (map-header-element-type header)))
  (write-number tport state (map-header-length header))
  (set-json-state-in-map! state (cons 1 (json-state-in-map state))))

(define (read-map-begin tport state)
  (log-thrift-debug "json:read-map-begin")
  (read-prefix tport state)
  (read-byte/expecting tport json-array-begin)
  (set-json-state-prefix! state #f)
  (define key-type (read-string tport state))
  (define element-type (read-string tport state))
  (define map-length (read-number tport state))
  (set-json-state-in-map! state (cons 1 (json-state-in-map state)))
  (map-header (hash-ref type-ident/reverse key-type)
              (hash-ref type-ident/reverse element-type)
              map-length))

;; ... ]
(define (write-map-end tport state)
  (log-thrift-debug "json:write-map-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-byte tport json-array-end)
  (write-ifmap-element-suffix tport state))

(define (read-map-end tport state)
  (log-thrift-debug "json:read-map-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (read-byte/expecting tport json-array-end))


;; ["<element-type>",len, ...
(define (write-list-begin tport state header)
  (log-thrift-debug "json:write-list-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (write-prefix tport state)
  (transport-write-byte tport json-array-begin)
  (transport-write-bytes tport (hash-ref type-ident (list-or-set-element-type header)))
  (write-number tport state (list-or-set-length header)))

(define (read-list-begin tport state)
  (log-thrift-debug "json:read-list-begin")
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (read-prefix tport state)
  (read-byte/expecting tport json-array-begin)
  (set-json-state-prefix! state #f)
  (define element-type (read-string tport state))
  (define list-length (read-number tport state))
  (list-or-set (hash-ref type-ident/reverse element-type) list-length))


;; ... ]
(define (write-list-end tport state)
  (log-thrift-debug "json:write-list-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-byte tport json-array-end)
  (write-ifmap-element-suffix tport state))

(define (read-list-end tport state)
  (log-thrift-debug "json:read-list-end")
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (read-byte/expecting tport json-array-end)
  (read-ifmap-element-suffix tport state))


;; "<field-id>":{"<type>": ...
(define (write-field-begin tport state header)
  (log-thrift-debug "json:write-field-begin")
  (write-prefix tport state)
  (set-json-state-prefix! state #f)
  (transport-write-bytes tport
                         (string->bytes/utf-8 (format "\"~a\"" (field-header-id header))))
  (transport-write-byte tport json-key-sep)
  (transport-write-byte tport json-object-begin)
  (transport-write-bytes tport (hash-ref type-ident (field-header-type header)))
  (transport-write-byte tport json-key-sep)
  (set-json-state-prefix! state #f))

(define (read-field-begin tport state)
  (log-thrift-debug "json:read-field-begin")
  (define key (read-string tport state))
  (skip-over tport json-key-sep)
  (skip-over tport json-object-begin)
  (set-json-state-prefix! state #f)
  (define type (read-string tport state))
  (skip-over tport json-key-sep)
  (set-json-state-prefix! state #f)
  (field-header "" (hash-ref type-ident/reverse type) (string->number key)))

;; ... }
(define (write-field-end tport state)
  (log-thrift-debug "json:write-field-end")
  (transport-write-byte tport json-object-end))

(define (read-field-end tport state)
  (log-thrift-debug "json:read-field-end")
  (read-byte/expecting tport json-object-end))

;; plain JSON boolean
(define (write-boolean tport state bool)
  (log-thrift-debug "json:write-boolean")
  (write-prefix tport state)
  (write-ifmap-element-prefix tport state)
  (if (false? bool)
      (transport-write-bytes tport #"false")
      (transport-write-bytes tport #"true"))
  (write-ifmap-element-sep tport state)
  (write-ifmap-element-suffix tport state))

(define (read-boolean tport state)
  (log-thrift-debug "json:read-boolean")
  (read-prefix tport state)
  (read-ifmap-element-prefix transport state)
  (define bool (read-atom tport))
  (define result (cond
                   [(bytes=? bool #"false") #f]
                   [(bytes=? bool #"true") #t]
                   [else
                    (raise (decoding-error
                            (current-continuation-marks)
                            "boolean"
                            bool))]))
  (read-ifmap-element-sep transport state)
  (read-ifmap-element-suffix transport state)
  result)


;; plain JSON number
(define (write-number tport state num)
  (log-thrift-debug "json:write-number")
  (write-prefix tport state)
  (define write-as-key (write-ifmap-element-prefix tport state))
  (if write-as-key
      (transport-write-bytes tport
                             (string->bytes/utf-8 (format "\"~a\"" num)))
      (transport-write-bytes tport
                             (string->bytes/utf-8 (~a num))))
  (write-ifmap-element-sep tport state)
  (write-ifmap-element-suffix tport state))

(define (read-number tport state)
  (log-thrift-debug "json:read-number")
  (read-prefix tport state)
  (read-ifmap-element-prefix tport state)
  (define atom (read-atom tport))
  (define result (string->number (bytes->string/utf-8 atom)))
  (read-ifmap-element-sep tport state)
  (read-ifmap-element-suffix tport state)
  result)


;; ??
(define (write-bytes tport state bs)
  (log-thrift-debug "json:write-bytes")
  (write-prefix tport state)
  (write-ifmap-element-prefix tport state)
  (transport-write-bytes tport bs)
  (write-ifmap-element-sep tport state)
  (write-ifmap-element-suffix tport state))

;; plain JSON string
(define (write-string tport state str)
  (log-thrift-debug "json:write-string")
  (write-prefix tport state)
  (write-ifmap-element-prefix tport state)
  (transport-write-bytes tport
                         (string->bytes/utf-8 (~s str)))
  (write-ifmap-element-sep tport state)
  (write-ifmap-element-suffix tport state))

(define (read-string tport state)
  (log-thrift-debug "json:read-string")
  (read-prefix tport state)
  (read-ifmap-element-prefix tport state)
  (define result (string-trim (bytes->string/utf-8 (read-atom tport)) "\""))
  (read-ifmap-element-sep tport state)
  (read-ifmap-element-suffix tport state)
  result)

;; base-64 encoded JSON string
(define (write-binary tport state bytes)
  (log-thrift-debug "json:write-binary")
  (write-prefix tport state)
  (write-ifmap-element-prefix tport state)
  (write-string state bytes)
  (write-ifmap-element-sep tport state)
  (write-ifmap-element-suffix tport state))

(define (read-atom tport)
  (let next-byte ([bytestr #""]
                   [a-byte (transport-peek tport)])
    (cond
      [(or (= a-byte json-elem-sep)
           (= a-byte json-key-sep)
           (= a-byte json-array-end)
           (= a-byte json-object-end)
           (eof-object? a-byte))
       bytestr]
      [else
       (define another-byte (transport-read-byte tport))
       (next-byte (bytes-append bytestr (bytes another-byte)) (transport-peek tport))])))

;; ---------- Internal procedures read/write state

(define (read-byte/expecting tport expecting)
  (define value (transport-read-byte tport))
  (unless (= value expecting)
    (raise (decoding-error (current-continuation-marks)
                           (integer->char expecting)
                           (integer->char value)))))

(define (write-prefix tport state)
  ; write a "," as a prefix to an output value
  ; depends on the current prefix state
  (cond
    [(false? (json-state-prefix state))
       (set-json-state-prefix! state #t)]
    [else
     (transport-write-byte tport json-elem-sep)]))

(define (read-prefix tport state)
  (cond
    [(false? (json-state-prefix state))
       (set-json-state-prefix! state #t)]
    [else
     (skip-over tport json-elem-sep)]))


(define (write-ifmap-element-prefix tport state)
  (cond
    [(equal? (car (json-state-in-map state)) 1)
     (transport-write-byte tport json-object-begin)
     (set-json-state-prefix! state #f)
     #t]
    [else
     #f]))

(define (read-ifmap-element-prefix tport state)
  (cond
    [(equal? (car (json-state-in-map state)) 1)
     (read-byte/expecting tport json-object-begin)
     (set-json-state-prefix! state #f)
     #t]
    [else
     #f]))


(define (write-ifmap-element-sep tport state)
  (when (equal? (car (json-state-in-map state)) 1)
    (transport-write-byte tport json-key-sep)
    (set-json-state-in-map! state
                            (cons 2 (cdr (json-state-in-map state))))
    (set-json-state-prefix! state #f)))

(define (read-ifmap-element-sep tport state)
  (when (equal? (car (json-state-in-map state)) 1)
    (read-byte/expecting tport json-key-sep)
    (set-json-state-in-map! state
                            (cons 2 (cdr (json-state-in-map state))))
    (set-json-state-prefix! state #f)))


(define (write-ifmap-element-suffix tport state)
  (define in-map-state (json-state-in-map state))
  (cond
    [(equal? (car in-map-state) 3)
     (set-json-state-in-map! state
                             (cons 1 (cdr (json-state-in-map state))))
     (transport-write-byte tport json-object-end)]
    [(number? (car in-map-state))
     (set-json-state-in-map! state
                             (cons (add1 (car in-map-state))
                                   (cdr in-map-state)))]))

(define (read-ifmap-element-suffix tport state)
  (define in-map-state (json-state-in-map state))
  (cond
    [(equal? (car in-map-state) 3)
     (set-json-state-in-map! state
                             (cons 1 (cdr (json-state-in-map state))))
     (read-byte/expecting tport json-object-end)]
    [(number? (car in-map-state))
     (set-json-state-in-map! state
                             (cons (add1 (car in-map-state))
                                   (cdr in-map-state)))]))

;; ---------- Internal procedures skip characters

(define (skip-over tport skip-char [and-spaces #t])
  (define result (skip-to tport skip-char))
  (cond
    [(equal? result #t)
     (transport-read-byte tport)
     (when (equal? and-spaces #t)
       (skip-spaces tport))]
    [else result]))

(define (skip-spaces tport)
  (let next-char ([peeked (transport-peek tport)])
    (cond
      [(equal? peeked json-space)
       (transport-read-byte tport)
       (next-char (transport-peek tport))]
      [(eof-object? peeked)
       eof]
      [else
       #t])))
  
(define (skip-to tport skip-char)
  (let next-char ([peeked (transport-peek tport)])
    (cond
      [(equal? peeked skip-char)
       #t]
      [(eof-object? peeked)
       eof]
      [else
       (transport-read-byte tport)
       (next-char (transport-peek tport))])))
