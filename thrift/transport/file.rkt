#lang racket/base
;;
;; thrift - transport/file.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [open-input-file-transport
   (-> string? transport?)]

  [open-output-file-transport
   (-> string? transport?)]))

;; ---------- Requirements

(require racket/bool
         thrift/transport/common
         thrift/private/logging)

;; ---------- Implementation

(define (open-input-file-transport file-path)
  (open-file-transport file-path 'input))

(define (open-output-file-transport file-path)
  (open-file-transport file-path 'output))

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
     
     (transport "file" file-path port)]))

