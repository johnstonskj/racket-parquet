#lang racket/base
;;
;; thrift - transport/memory.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [open-input-memory-transport
   (-> bytes? transport?)]

  [open-output-memory-transport
   (-> transport?)]

  [transport-output-bytes 
   (->  transport? bytes?)]))

;; ---------- Requirements

(require racket/bool
         thrift/transport/common
         thrift/private/logging)

;; ---------- Implementation

(define (open-input-memory-transport bytes)
  (transport "in-memory" 'memory (open-input-bytes bytes)))

(define (open-output-memory-transport)
  (transport "in-memory" 'memory (open-output-bytes)))

(define (transport-output-bytes tport)
  (get-output-bytes (transport-port tport)))
