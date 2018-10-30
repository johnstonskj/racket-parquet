#lang racket/base
;;
;; thrift - protocol/plain.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 get-protocol-encoder
 get-protocol-decoder
 read-plain-integer)

;; ---------- Requirements

(require thrift/protocol/common
         thrift/transport/common)

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
   (λ () (if (= (read-byte (transport-in-port transport)) 0) #f #t))
   (λ () (read-byte (transport-in-port transport)))
   (λ (count) (read-bytes count (transport-in-port transport)))
   (λ () (read-plain-integer (transport-in-port transport) 2))
   (λ () (read-plain-integer (transport-in-port transport) 4))
   (λ () (read-plain-integer (transport-in-port transport) 8))
   #f
   #f))

;; ---------- Internal procedures

(define (read-plain-integer in width-in-bytes)
  (define bs (read-bytes width-in-bytes in))
  (integer-bytes->integer bs #t #f 0 width-in-bytes))

