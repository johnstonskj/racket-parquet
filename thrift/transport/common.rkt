#lang racket/base
;;
;; thrift - transport/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 
 (struct-out transport))

;; ---------- Implementation (Types)

(struct transport
  (source
   in-port
   out-port
   size
   position
   options) #:transparent)
