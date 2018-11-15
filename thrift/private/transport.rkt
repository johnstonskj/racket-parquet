#lang racket/base
;;
;; thrift - private/transport.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (struct-out transport))

;; ---------- Implementation (Types)

(struct transport
  (name
   source
   [port #:mutable]
   overrides))
