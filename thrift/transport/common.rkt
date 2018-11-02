#lang racket/base
;;
;; thrift - transport/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide
 
 (contract-out

  [transport?
   (-> any/c boolean?)]

  [transport-source
   (-> transport? string?)]

  [transport-port
   (-> transport? port?)]

  [input-transport?
   (-> transport? boolean?)]
  
  [output-transport?
   (-> transport? boolean?)]

  [close-transport
   (-> transport? any/c)])
 
 transport)

;; ---------- Implementation (Types)

(struct transport
  (source
   port))

(define (input-transport? tport)
  (input-port? (transport-port tport)))

(define (output-transport? tport)
  (output-port? (transport-port tport)))

(define (close-transport tport)
  (define p (transport-port tport))
  (cond
    [(input-port? p) (close-input-port p)]
    [(output-port? p) (close-output-port p)]
    [else (error "what kind of port is this? " p)]))
