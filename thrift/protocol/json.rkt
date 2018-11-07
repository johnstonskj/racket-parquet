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
   (λ (v) (write-number transport state (if (false? v) 0 1)))
   (λ (v) (write-number transport state v))
   (λ (v) (write-bytes transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-number transport state v))
   (λ (v) (write-string transport state v))))

(define (make-json-decoder transport)
  (decoder
   "simple-json"
   (λ () (no-op-decoder "message-begin"))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ () (no-op-decoder "field-begin"))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "map-begin"))
   (λ () (no-op-decoder "map-end"))
   (λ () (no-op-decoder "list-begin"))
   (λ () (no-op-decoder "list-end"))
   (λ () (no-op-decoder "set-begin"))
   (λ () (no-op-decoder "set-end"))
   (λ () (no-op-decoder "boolean"))
   (λ () (no-op-decoder "byte"))
   (λ () (no-op-decoder "bytes"))
   (λ () (no-op-decoder "integer"))
   (λ () (no-op-decoder "integer"))
   (λ () (no-op-decoder "integer"))
   (λ () (no-op-decoder "double"))
   (λ () (no-op-decoder "string"))))

;; ---------- Internal procedures

(define json-protocol-version 1)

(define json-array-begin #"[")
(define json-array-end #"]")

(define json-object-begin #"{")
(define json-object-end #"}")

(define json-space #" ")
(define json-elem-sep #",")
(define json-key-sep #":")

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

(struct json-state
  ([prefix #:mutable]
   [in-map #:mutable]))

(define (write-prefix transport state)
  (cond
    [(false? (json-state-prefix state))
       (set-json-state-prefix! state #t)]
    [else
     (transport-write-bytes transport json-elem-sep)]))

(define (write-ifmap-element-prefix transport state)
  (cond
    [(equal? (car (json-state-in-map state)) 1)
     (transport-write-bytes transport json-object-begin)
     (set-json-state-prefix! state #f)
     #t]
    [else
     #f]))

(define (write-ifmap-element-sep transport state)
  (when (equal? (car (json-state-in-map state)) 1)
    (transport-write-bytes transport json-key-sep)
    (set-json-state-in-map! state
                            (cons 2 (cdr (json-state-in-map state))))
    (set-json-state-prefix! state #f)))

(define (write-ifmap-element-suffix transport state)
  (define in-map-state (json-state-in-map state))
  (cond
    [(equal? (car in-map-state) 3)
     (set-json-state-in-map! state
                             (cons 1 (cdr (json-state-in-map state))))
     (transport-write-bytes transport json-object-end)]
    [(number? (car in-map-state))
     (set-json-state-in-map! state
                             (cons (add1 (car in-map-state))
                                   (cdr in-map-state)))]))

(define (write-message-begin transport state header)
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (transport-write-bytes transport json-array-begin)
  (set-json-state-prefix! state #f)
  (write-number transport state json-protocol-version)
  (write-string transport state (message-header-name header))
  (write-number transport state (message-header-type header))
  (write-number transport state (message-header-sequence-id header)))

(define (write-message-end transport state)
  (transport-write-bytes transport json-array-end))

(define (write-struct-begin transport state)
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (write-prefix transport state)
  (transport-write-bytes transport json-object-begin)
  (set-json-state-prefix! state #f))

(define (write-struct-end transport state)
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-bytes transport json-object-end)
  (write-ifmap-element-suffix transport state))

(define (write-map-begin transport state header)
  (write-prefix transport state)
  (set-json-state-prefix! state #f)
  (transport-write-bytes transport json-array-begin)
  (write-bytes transport state (hash-ref type-ident (map-header-key-type header)))
  (write-bytes transport state (hash-ref type-ident (map-header-element-type header)))
  (write-number transport state (map-header-length header))
  (set-json-state-in-map! state (cons 1 (json-state-in-map state))))

(define (write-map-end transport state)
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-bytes transport json-array-end)
  (write-ifmap-element-suffix transport state))

(define (write-list-begin transport state header)
  (set-json-state-in-map! state (cons #f (json-state-in-map state)))
  (write-prefix transport state)
  (transport-write-bytes transport json-array-begin)
  (transport-write-bytes transport (hash-ref type-ident (list-or-set-element-type header)))
  (write-number transport state (list-or-set-length header)))

(define (write-list-end transport state)
  (set-json-state-in-map! state (cdr (json-state-in-map state)))
  (transport-write-bytes transport json-array-end)
  (write-ifmap-element-suffix transport state))

(define (write-field-begin transport state header)
  (write-prefix transport state)
  (set-json-state-prefix! state #f)
  (write-number transport state (field-header-id header))
  (transport-write-bytes transport json-key-sep)
  (transport-write-bytes transport json-object-begin)
  (transport-write-bytes transport (hash-ref type-ident (field-header-type header)))
  (transport-write-bytes transport json-key-sep)
  (set-json-state-prefix! state #f))

(define (write-field-end transport state)
  (transport-write-bytes transport json-object-end))

(define (write-number transport state num)
  (write-prefix transport state)
  (define write-as-key (write-ifmap-element-prefix transport state))
  (if write-as-key
      (transport-write-bytes transport
                             (string->bytes/utf-8 (format "\"~a\"" num)))
      (transport-write-bytes transport
                             (string->bytes/utf-8 (~a num))))
  (write-ifmap-element-sep transport state)
  (write-ifmap-element-suffix transport state))

(define (write-bytes transport state bs)
  (write-prefix transport state)
  (write-ifmap-element-prefix transport state)
  (transport-write-bytes transport bs)
  (write-ifmap-element-sep transport state)
  (write-ifmap-element-suffix transport state))

(define (write-string transport state str)
  (write-prefix transport state)
  (write-ifmap-element-prefix transport state)
  (transport-write-bytes transport
                         (string->bytes/utf-8 (~s str)))
  (write-ifmap-element-sep transport state)
  (write-ifmap-element-suffix transport state))

(define (write-binary transport state bytes)
  (write-prefix transport state)
  (write-ifmap-element-prefix transport state)
  (write-string state bytes)
  (write-ifmap-element-sep transport state)
  (write-ifmap-element-suffix transport state))
