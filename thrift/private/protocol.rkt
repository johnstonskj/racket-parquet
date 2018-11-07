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
  (log-thrift-debug (symbol->string name)))

(define (no-op-decoder name)
  (log-thrift-debug (symbol->string name)))

(define (read-plain-integer in width-in-bytes)
  (unless (input-transport? in) (error "transport must be open for input"))
  (define bs (transport-read-bytes in width-in-bytes))
  (integer-bytes->integer bs #t #f 0 width-in-bytes))

