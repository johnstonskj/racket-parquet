#lang racket/base
;;
;; thrift - protocol/json.
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

; The message in the transport are encoded as this: 4 bytes represents
; the length of the json object and immediately followed by the json object.
; 
;     '\x00\x00\x00+' '{"payload": {}, "metadata": {"version": 1}}'
; 
; the 4 bytes are the bytes representation of an integer and is encoded in
; big-endian.

(struct s-value
  (index
   type
   value) #:prefab)

(define (make-sexpression-encoder transport)
  (encoder
   "s-expression"
   (λ (header) (write-value transport header))
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
   (λ () (no-op-encoder "set-end"))
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
     (raise (invalid-value-type (current-continuation-marks) v))]))