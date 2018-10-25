#lang racket/base
;;
;; thrift - transport/file.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 
 open-file-transport)

;; ---------- Requirements

(require thrift/transport/common
         thrift/private/logging)

;; ---------- Internal types

;; ---------- Implementation

(define (open-file-transport file-path)
  (log-thrift-info "opening thrift file: ~a" file-path)
  (cond
    [(not (file-exists? file-path))
     (error 'open-file-transport "file does not exist, path:" file-path)]
    [(not (member 'read (file-or-directory-permissions file-path)))
     (error 'open-file-transport "file not readable")]
    [(not (member 'write (file-or-directory-permissions file-path)))
     (error 'open-file-transport "file not writeable")]
    [else
     (define size (file-size file-path))
     (log-thrift-debug "~a size: ~a" file-path size)
     
     (define-values (in-port out-port)
       (open-input-output-file file-path
                               #:mode 'binary
                               #:exists 'can-update))
     (file-stream-buffer-mode in-port 'block)
     (file-stream-buffer-mode out-port 'block)
     
     (transport file-path
                in-port
                out-port
                (λ () (file-size file-path))
                (λ ([pos #f]) (if pos
                                  (file-position in-port pos)
                                  (file-position in-port)))
                #f)]))

(define (close-transport transport)
  (log-thrift-info "closing thrift file: ~a" (transport-source transport))
  (close-input-port (transport-in-port transport))
  (close-output-port (transport-out-port transport)))

;; ---------- Internal procedures

;; ---------- Internal tests
