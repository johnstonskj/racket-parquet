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
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Implementation

(struct s-value
  (index
   type
   value) #:prefab)

(define (make-sexpression-encoder transport)
  (encoder
   "s-expression"
   (λ (header) (write-value transport header))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-decoder "field-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-decoder "map-end"))
   (λ (header) (write-value transport header))
   (λ () (no-op-decoder "list-end"))
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
   (λ () (read-value transport message-header?))
   (λ () (no-op-decoder "message-end"))
   (λ () (no-op-decoder "struct-begin"))
   (λ () (no-op-decoder "struct-end"))
   (λ () (read-value transport field-header?))
   (λ () (no-op-decoder "field-end"))
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

(define (write-value transport v)
  (transport-write transport v))

(define (read-value transport type-predicate?)
  (define v (transport-read transport))
  (cond
    [(type-predicate? v)
     v]
    [else
     (error "value not expected type: " v)]))
