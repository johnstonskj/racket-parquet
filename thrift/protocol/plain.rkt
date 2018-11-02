#lang racket/base
;;
;; thrift - protocol/plain.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [get-protocol-encoder
   (-> transport? (or/c encoder? #f))]
  
  [get-protocol-decoder
   (-> transport? (or/c decoder? #f))]
  
  [read-plain-integer
   (-> (or/c transport? port?) exact-nonnegative-integer? integer?)]))

;; ---------- Requirements

(require thrift)

;; ---------- Implementation

(define (get-protocol-encoder transport)
  #f)

(define (get-protocol-decoder transport)
  (decoder
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   #f
   (λ () (if (= (read-byte (transport-port transport)) 0) #f #t))
   (λ () (read-byte (transport-port transport)))
   (λ (count) (read-bytes count (transport-port transport)))
   (λ () (read-plain-integer transport 2))
   (λ () (read-plain-integer transport 4))
   (λ () (read-plain-integer transport 8))
   #f
   #f))

;; ---------- Internal procedures

(define (read-plain-integer in width-in-bytes)
  (unless (input-transport? in) (error "transport must be open for input"))
  (define p (if (port? in) in (transport-port in)))
  (define bs (read-bytes width-in-bytes p))
  (integer-bytes->integer bs #t #f 0 width-in-bytes))

