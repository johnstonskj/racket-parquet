#lang racket/base
;;
;; thrift - protocol/sexpression.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [make-sexpression-encoder
   (-> transport? (or/c encoder? #f))]
  
  [make-sexpression-decoder
   (-> transport? (or/c decoder? #f))]))

;; ---------- Requirements

(require thrift
         thrift/protocol/exn-common
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Implementation

(struct s-value
  (index
   type
   value) #:prefab)

(struct protocol-header
  (id
   version
   message-header) #:prefab)

(define (make-sexpression-encoder transport)
  (encoder
   "s-expression"
   (λ (header) (write-message-begin transport header))
   (λ () (no-op-encoder "message-end"))
   (λ () (no-op-encoder "struct-begin"))
   (λ () (no-op-encoder "struct-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-encoder "field-end"))
   (λ () (no-op-encoder "field-stop"))
   (λ (header) (write-value transport header))
   (λ () (no-op-encoder "map-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-encoder "list-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-decoder "set-end"))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))
   (λ (v) (write-value transport v))))

(define (make-sexpression-decoder transport)
  (decoder
   "s-expression"
   (λ () (read-message-begin transport))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ () (read-value transport field-header?))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-stop"))
   (λ () (read-value transport map-header?))
   (λ () (no-op-decoder "map-end"))
   (λ () (read-value transport list-or-set?))
   (λ () (no-op-decoder "list-end"))
   (λ () (read-value transport list-or-set?))
   (λ () (no-op-decoder "set-end"))
   (λ () (read-value transport boolean?))
   (λ () (read-value transport byte?))
   (λ () (read-value transport bytes?))
   (λ () (read-value transport integer?))
   (λ () (read-value transport integer?))
   (λ () (read-value transport integer?))
   (λ () (read-value transport flonum?))
   (λ () (read-value transport string?))))

;; ---------- Internal procedures

(define (write-message-begin tport msg)
  (write-value tport (protocol-header 's-expression 1 msg)))

(define (read-message-begin tport)
  (define header (read-value tport protocol-header?))
  (when (not (equal? (protocol-header-id header) 's-expression))
     (log-thrift-error "value ~s, invalid, expecting ~a"
                       (protocol-header-id header) 's-expression)
    (raise (invalid-protocol-id (current-continuation-marks) (protocol-header-id header))))
  (when (not (equal? (protocol-header-version header) 1))
     (log-thrift-error "value ~s, invalid, expecting ~a"
                       (protocol-header-version header) 1)
    (raise (invalid-protocol-version (current-continuation-marks) (protocol-header-version header))))
  (when (not (message-header? (protocol-header-message-header header)))
     (log-thrift-error "~s, invalid, expecting a message header"
                       (protocol-header-message-header header))
    (raise (decoding-error (current-continuation-marks) (protocol-header-message-header header))))
  (protocol-header-message-header header))
  
(define (write-value tport v)
  (transport-write tport v)
  (display " " (transport-port tport)))

(define (read-value tport type-predicate?)
  (define v (transport-read tport))
  (cond
    [(type-predicate? v)
     v]
    [else
     (log-thrift-error "~a not-a ~a" v type-predicate?)
     (raise (invalid-value-type (current-continuation-marks) v))]))
