#lang racket/base
;;
;; thrift - transport.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 
 (struct-out transport))

;; ---------- Requirements

;; ---------- Internal types

;; ---------- Implementation

(struct transport
  (source
   in-port
   out-port
   size
   position
   options) #:transparent)
  
;; ---------- Internal procedures

;; ---------- Internal tests
