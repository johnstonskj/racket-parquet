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
   (-> transport? (or/c encoder? #f))]
  
  [make-binary-decoder
   (-> transport? (or/c decoder? #f))]))

;; ---------- Requirements

(require racket/flonum
         thrift/protocol/common
         thrift/protocol/exn-common
         thrift/transport/common
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Internal types/values

(define protocol-version #b1000000000000001)

(define unnamed "")

(define-enumeration field-type 0
  (stop
   unused-1
   boolean
   byte
   double
   unused-5
   int16
   unused-7
   int32
   unused-9
   int64
   string
   structure
   map
   set
   list))
;; ---------- Implementation

(define (make-binary-encoder transport)
  #f)

(define (make-binary-decoder transport)
  (decoder
   "binary"
   (λ () (message-begin transport))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ () (field-begin transport))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-end"))
   (λ () (map-begin transport))
   (λ () (no-op-decoder "map-end"))
   (λ () (list-begin transport))
   (λ () (no-op-decoder "list-end"))
   (λ () (set-begin transport))
   (λ () (no-op-decoder "set-end"))
   (λ () (if (= (transport-read-byte transport) 0) #f #t))
   (λ () (transport-read-byte transport))
   (λ () (read-binary transport))
   (λ () (read-plain-integer transport 2))
   (λ () (read-plain-integer transport 4))
   (λ () (read-plain-integer transport 8))
   (λ () (read-double transport))
   (λ () (bytes->string/utf-8 (read-binary transport)))))

;; ---------- Internal procedures

(define (read-double in)
  (unless (input-transport? transport)
    (raise (transport-not-open-input (current-continuation-marks))))
  (->fl (read-plain-integer  transport 8)))

(define (read-binary transport)
  (unless (input-transport? transport)
    (raise (transport-not-open-input (current-continuation-marks))))
  (define byte-length (read-plain-integer transport 4))
  (transport-read-bytes transport byte-length))

(define (read-string transport)
  (unless (input-transport? transport)
    (raise (transport-not-open-input (current-continuation-marks))))
  (bytes->string/utf-8 (read-binary transport)))

(define (message-begin transport)
  (unless (input-transport? transport)
    (raise (transport-not-open-input (current-continuation-marks))))
  (log-thrift-debug "message-begin")

  (define msg-version (read-plain-integer transport 2))
  (unless (= protocol-version msg-version)
    (raise (invalid-protocol-version (current-continuation-marks) msg-version)))

  (transport-read-byte transport) ;; ignored
  
  (define msg-type-byte (transport-read-byte transport))
  ;; TODO: check top 5 bytes are 0
  (define msg-type (bitwise-and #b111))

  (define msg-method-name (read-string transport))
  (unless (= (string-length msg-method-name) 0)
    (raise (wrong-method-name (current-continuation-marks) msg-method-name)))
  
  (define msg-sequence-id (read-plain-integer transport 4))
  (log-thrift-debug "message name ~a, type ~s, sequence"
                    msg-method-name msg-type msg-sequence-id)
  (message-header msg-method-name msg-type msg-sequence-id))

(define (field-begin transport)
  (unless (input-transport? transport) (raise transport-not-open-input))
  (log-thrift-debug "field-begin")
  (define head (transport-read-byte transport))
  (cond
    [(= head field-type-stop)
     (log-thrift-debug "<< (field-stop)")
     (field-header unnamed field-type-stop 0)]
    [else
     (define field-type (transport-read-byte transport))
     (define field-id (read-plain-integer transport 2))
     (log-thrift-debug "<< structure field id ~a type ~a (~s)"
                       field-id field-type (integer->field-type field-type))
     (field-header unnamed field-type field-id)]))
       
(define (map-begin transport)
  (unless (input-transport? transport) (raise transport-not-open-input))
  (log-thrift-debug "map-begin")
  (define key-type (transport-read-byte transport))
  (define element-type (transport-read-byte transport))
  (define size (read-plain-integer transport 4))
  (map key-type element-type size))

(define (list-begin transport)
  (unless (input-transport? transport) (raise transport-not-open-input))
  (log-thrift-debug "list-begin")
  (define element-type (transport-read-byte transport))
  (define size (read-plain-integer transport 4))
  (log-thrift-debug "<< reading list, ~a elements, of type ~s"
                    size (integer->field-type element-type))
  (list-or-set element-type size))

(define (set-begin transport)
  (unless (input-transport? transport) (raise transport-not-open-input))
  (log-thrift-debug "set-begin")
  (list-begin transport))
