#lang racket/base
;;
;; thrift - transport/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract racket/bool)

(provide
 
 (contract-out

  [transport?
   (-> any/c boolean?)]

  [transport-source
   (-> transport? string?)]

  [transport-port
   (-> transport? port?)]

  [transport-read-byte
   (-> transport? byte?)]
  
  [transport-read-bytes
   (-> transport? exact-positive-integer? bytes?)]
  
  [transport-write-byte
   (-> transport? byte? void?)]
  
  [transport-write-bytes
   (->* (transport? bytes?) (exact-nonnegative-integer? exact-nonnegative-integer?) void?)]
  
  [transport-size
   (-> transport? (or/c exact-nonnegative-integer? eof-object?))]

  [transport-read-position
   (->* (transport?) (exact-nonnegative-integer?) (or/c exact-nonnegative-integer? eof-object?))]

  [input-transport?
   (-> transport? boolean?)]
  
  [output-transport?
   (-> transport? boolean?)]

  [flush-transport
   (-> output-transport? void?)]
  
  [close-transport
   (-> transport? any/c)])
 
 transport)

;; ---------- Implementation (Types)

(struct transport
  (name
   source
   port))

(define (transport-read-byte tport)
  (read-byte (transport-port tport)))
  
(define (transport-read-bytes tport amt)
  (read-bytes amt (transport-port tport)))
  
(define (transport-write-byte tport b)
  (write-byte b (transport-port tport)))
  
(define (transport-write-bytes tport bs [start 0] [end #f])
  (cond
    [(false? end)
     (write-bytes bs (transport-port tport) start)]
    [else
     (write-bytes bs (transport-port tport) start end)]))
  
(define (transport-size tport)
  (cond
    [(input-transport? tport)
     (file-size (transport-source tport))]
    [else eof]))

(define (transport-read-position tport [new-pos #f])
  (cond
    [(input-transport? tport)
     (cond
       [(false? new-pos)
        (file-position (transport-port tport))]
       [else
        (file-position (transport-port tport) new-pos)
        new-pos])]
    [else eof]))


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

(define (flush-transport tport)
  (flush-output (transport-port tport)))