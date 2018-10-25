#lang racket/base
;;
;; thrift - common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).


(require racket/contract)

(provide
 (all-defined-out))

;; ---------- Requirements

(require thrift/idl/enumeration)

;; ---------- Implementation

(define-enumeration message-type 1
  (call
   reply
   exception
   one-way))

(define-enumeration exception-type 0
  (unknown
   unknown-method
   invalid-message-type
   wrong-method-name
   bad-sequence-id
   missing-result
   internal-error
   protocol-error
   invalid-transform
   invalid-protocol
   unsupported-client-type))

(struct exception
  (message
   type) #:transparent)

(define-enumeration field-type 0
  (stop
   boolean-true
   boolean-false
   byte
   int16
   int32
   int64
   double
   binary
   list
   set
   map
   structure))

(struct field-value
  (id
   type
   value) #:transparent)
