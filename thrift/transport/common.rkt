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

  [transport-overrides
   (-> transport? hash?)]

  [transport-read-byte
   (-> transport? byte?)]
  
  [transport-read-bytes
   (-> transport? exact-positive-integer? bytes?)]
  
  [transport-read
   (-> transport? any/c)]
  
  [transport-write-byte
   (-> transport? byte? void?)]
  
  [transport-write-bytes
   (->* (transport? bytes?) (exact-nonnegative-integer? exact-nonnegative-integer?) void?)]
  
  [transport-write
   (-> transport? any/c void?)]
  
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

;; ---------- Requirements

(require racket/bool
         thrift/common
         thrift/private/transport)

;; ---------- Implementation (Types)

(define (transport-read-byte tport)
  (define actual (if (hash-has-key? (transport-overrides tport) 'read-byte)
                     (hash-ref (transport-overrides tport) 'read-byte)
                     read-byte))
  (actual (transport-port tport)))
  
(define (transport-read-bytes tport amt)
  (define actual (if (hash-has-key? (transport-overrides tport) 'read-bytes)
                     (hash-ref (transport-overrides tport) 'read-bytes)
                     read-bytes))
  (actual amt (transport-port tport)))
  
(define (transport-read tport)
  (define actual (if (hash-has-key? (transport-overrides tport) 'read)
                     (hash-ref (transport-overrides tport) 'read)
                     read))
  (actual (transport-port tport)))
  
(define (transport-write-byte tport b)
  (define actual (if (hash-has-key? (transport-overrides tport) 'write-byte)
                     (hash-ref (transport-overrides tport) 'write-byte)
                     write-byte))
  (actual b (transport-port tport)))
  
(define (transport-write-bytes tport bs [start 0] [end #f])
  (define actual (if (hash-has-key? (transport-overrides tport) 'write-bytes)
                     (hash-ref (transport-overrides tport) 'write-bytes)
                     write-bytes))
  (cond
    [(false? end)
     (actual bs (transport-port tport) start)]
    [else
     (actual bs (transport-port tport) start end)])
  (void))
  
(define (transport-write tport v)
  (define actual (if (hash-has-key? (transport-overrides tport) 'write)
                     (hash-ref (transport-overrides tport) 'write)
                     write))
  (actual v (transport-port tport)))
  
(define (transport-size tport)
  (define actual (if (hash-has-key? (transport-overrides tport) 'size)
                     (hash-ref (transport-overrides tport) 'size)
                     file-size))
  (cond
    [(input-transport? tport)
     (actual (transport-source tport))]
    [else eof]))

(define (transport-read-position tport [new-pos #f])
  (define actual (if (hash-has-key? (transport-overrides tport) 'position)
                     (hash-ref (transport-overrides tport) 'position)
                     file-position))
  (cond
    [(input-transport? tport)
     (cond
       [(false? new-pos)
        (actual (transport-port tport))]
       [else
        (actual (transport-port tport) new-pos)
        new-pos])]
    [else eof]))


(define (input-transport? tport)
  (input-port? (transport-port tport)))

(define (output-transport? tport)
  (output-port? (transport-port tport)))

(define (close-transport tport)
  (define p (transport-port tport))
  (cond
    [(input-port? p)
     (close-input-port p)]
    [(output-port? p)
     (flush-transport tport)
     (close-output-port p)]
    [else (error "what kind of port is this? " p)]))

(define (flush-transport tport)
  (define actual (if (hash-has-key? (transport-overrides tport) 'flush)
                     (hash-ref (transport-overrides tport) 'flush)
                     flush-output))
  (actual (transport-port tport)))