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
   (->  transport? bytes?)]
  
  [transport-file-size
   (-> transport? exact-nonnegative-integer?)]

  [transport-file-position
   (->* (transport?) (exact-nonnegative-integer?) any/c)]))

;; ---------- Requirements

(require racket/bool
         thrift/transport/common
         thrift/private/logging)

;; ---------- Implementation

(define (open-input-memory-transport bytes)
  (transport 'memory (open-input-bytes bytes)))

(define (open-output-memory-transport)
  (transport 'memory (open-output-bytes)))

(define (transport-output-bytes tport)
  (get-output-bytes (transport-port tport)))

(define (transport-file-size tport)
  (cond
    [(input-transport? tport)
     (file-size (transport-source tport))]
    [else (error "transport must be opened for input")]))

(define (transport-file-position tport [new-pos #f])
  (cond
    [(input-transport? tport)
     (cond
       [(false? new-pos)
        (file-position (transport-port tport))]
       [else (file-position (transport-port tport) new-pos)])]
    [else (error "transport must be opened for input")]))

;; ---------- Internal procedures

(define (open-file-transport file-path direction)
  (log-thrift-info "opening thrift file: ~a for ~a" file-path direction)
  (cond
    [(not (file-exists? file-path))
     (error 'open-file-transport "file does not exist, path:" file-path)]
    [(not (member 'read (file-or-directory-permissions file-path)))
     (error 'open-file-transport "file not readable")]
    [(not (member 'write (file-or-directory-permissions file-path)))
     (error 'open-file-transport "file not writeable")]
    [else
     (define port
       (cond
         [(equal? direction 'input)
          (open-input-file file-path #:mode 'binary)]
         [(equal? direction 'output)
          (open-output-file file-path #:mode 'binary #:exists 'can-update)]))
     (file-stream-buffer-mode port 'block)
     
     (transport file-path port)]))

