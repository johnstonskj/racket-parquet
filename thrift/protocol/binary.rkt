#lang racket/base
;;
;; thrift - protocol/binary.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; https://github.com/apache/thrift/blob/master/doc/specs/thrift-binary-protocol.md

(require racket/contract)

(provide

 (contract-out
  
  [make-binary-encoder
   (-> output-transport? (or/c encoder? #f))]
  
  [make-binary-decoder
   (-> input-transport? (or/c decoder? #f))]))

;; ---------- Requirements

(require racket/bool
         racket/flonum
         thrift/idl/common
         thrift/protocol/common
         thrift/protocol/exn-common
         thrift/transport/common
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Internal types/values

(define protocol-version #b1000000000000001)

(define unnamed "")

;; ---------- Implementation

(define (make-binary-encoder transport)
  (encoder
   "binary"
   (λ (msg) (write-message-begin transport msg))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ (fld) (write-field-begin transport fld))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-stop"))
   (λ (map) (write-map-begin transport map))
   (λ () (no-op-decoder "map-end"))
   (λ (lst) (write-list-begin transport lst))
   (λ () (no-op-decoder "list-end"))
   (λ (set) (write-set-begin transport set))
   (λ () (no-op-decoder "set-end"))
   (λ (v) (write-boolean transport v))
   (λ (v) (transport-write-byte transport v))
   (λ (v) (write-binary transport v))
   (λ (v) (write-plain-integer transport v 2))
   (λ (v) (write-plain-integer transport v 4))
   (λ (v) (write-plain-integer transport v 8))
   (λ (v) (write-double transport v))
   (λ (v) (write-string transport v))))

(define (make-binary-decoder transport)
  (decoder
   "binary"
   (λ () (read-message-begin transport))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ () (read-field-begin transport))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-stop"))
   (λ () (read-map-begin transport))
   (λ () (no-op-decoder "map-end"))
   (λ () (read-list-begin transport))
   (λ () (no-op-decoder "list-end"))
   (λ () (read-set-begin transport))
   (λ () (no-op-decoder "set-end"))
   (λ () (if (= (transport-read-byte transport) 0) #f #t))
   (λ () (transport-read-byte transport))
   (λ () (read-binary transport))
   (λ () (read-plain-integer transport 2))
   (λ () (read-plain-integer transport 4))
   (λ () (read-plain-integer transport 8))
   (λ () (read-double transport))
   (λ () (read-string transport))))

;; ---------- Internal procedures

(define (write-boolean tport v)
  (if (false? v)
      (transport-write-byte tport 0)
      (transport-write-byte tport 1)))

(define (read-boolean tport)
  (if (= (transport-read-byte tport) 0) #f #t))

(define (write-double tport v)
  (write-plain-integer tport (fl->exact-integer v) 8))

(define (read-double tport)
  (->fl (read-plain-integer tport 8)))

(define (write-binary tport bytes)
  (write-plain-integer tport (bytes-length bytes) 4)
  (transport-write-bytes tport bytes))

(define (read-binary tport)
  (define byte-length (read-plain-integer tport 4))
  (transport-read-bytes tport byte-length))

(define (write-string tport str)
  (write-binary tport (string->bytes/utf-8 str)))
  
(define (read-string tport)
  (bytes->string/utf-8 (read-binary tport)))

(define (write-message-begin tport msg)
  (log-thrift-debug "write-message-begin")
  (write-plain-integer tport protocol-version 2 #f)
  (transport-write-byte tport 0)
  (transport-write-byte tport (bitwise-and (message-header-type msg) #b111))
  (write-string tport (message-header-name msg))
  (write-plain-integer tport (message-header-sequence-id msg) 4))

(define (read-message-begin tport)
  (log-thrift-debug "read-message-begin")

  (define msg-version (read-plain-integer tport 2 #f))
  (unless (= protocol-version msg-version)
    (raise (invalid-protocol-version (current-continuation-marks) msg-version)))

  (transport-read-byte tport) ;; ignored
  
  (define msg-type-byte (transport-read-byte tport))
  ;; TODO: check top 5 bytes are 0
  (define msg-type (bitwise-and msg-type-byte #b111))

  (define msg-method-name (read-string tport))
  (when (= (string-length msg-method-name) 0)
    (raise (wrong-method-name (current-continuation-marks) msg-method-name)))
  
  (define msg-sequence-id (read-plain-integer tport 4))
  (log-thrift-debug "message name ~a, type ~s, sequence ~a"
                    msg-method-name msg-type msg-sequence-id)
  (message-header msg-method-name msg-type msg-sequence-id))

(define (write-field-begin tport field)
  (log-thrift-debug "write-field-begin")
  (cond
    [(equal? (field-header-type field) type-stop)
     (transport-write-byte tport type-stop)]
    [else
     (transport-write-byte tport (field-header-type field))
     (write-plain-integer tport (field-header-id field) 2)]))

(define (read-field-begin tport)
  (log-thrift-debug "field-begin")
  (define field-type (transport-read-byte tport))
  (cond
    [(= field-type type-stop)
     (log-thrift-debug "<< (field-stop)")
     (field-header unnamed type-stop type-stop)]
    [else
     (define field-id (read-plain-integer tport 2))
     (log-thrift-debug "<< structure field id ~a type ~a (~s)"
                       field-id field-type (integer->type field-type))
     (field-header unnamed field-type field-id)]))

(define (write-map-begin tport map)
  (log-thrift-debug "write-map-begin")
  (transport-write-byte tport (map-header-key-type map))
  (transport-write-byte tport (map-header-element-type map))
  (write-plain-integer tport (map-header-length map) 4))
  
(define (read-map-begin tport)
  (log-thrift-debug "read-map-begin")
  (define key-type (transport-read-byte tport))
  (define element-type (transport-read-byte tport))
  (define size (read-plain-integer tport 4))
  (map-header key-type element-type size))

(define (write-list-begin tport lst)
  (log-thrift-debug "write-list-begin")
  (transport-write-byte tport (list-or-set-element-type lst))
  (write-plain-integer tport (list-or-set-length lst) 4))

(define (read-list-begin tport)
  (log-thrift-debug "read-list-begin")
  (define element-type (transport-read-byte tport))
  (define size (read-plain-integer tport 4))
  (log-thrift-debug "<< reading list, ~a elements, of type ~s"
                    size (integer->type element-type))
  (list-or-set element-type size))

(define (write-set-begin tport set)
  (log-thrift-debug "write-set-begin")
  (write-list-begin tport set))
  
(define (read-set-begin tport)
  (log-thrift-debug "read-set-begin")
  (read-list-begin tport))
