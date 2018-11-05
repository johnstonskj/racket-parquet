#lang racket/base
;;
;; thrift - private/transport.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide

 no-op-encoder

 no-op-decoder

 read-plain-integer)

;; ---------- Requirements

(require thrift/transport/common
         thrift/private/logging)

;; ---------- Implementation

(define (no-op-encoder name)
  (λ (transport)
    (unless (output-transport? transport)
      (error "transport must be open for output"))
    (log-thrift-debug (symbol->string name))
    (void)))

(define (no-op-decoder name)
  (λ (transport)
    (unless (input-transport? transport)
      (error "transport must be open for input"))
    (log-thrift-debug (symbol->string name))
    (void)))

(define (read-plain-integer in width-in-bytes)
  (unless (input-transport? in) (error "transport must be open for input"))
  (define bs (transport-read-bytes in width-in-bytes))
  (integer-bytes->integer bs #t #f 0 width-in-bytes))

