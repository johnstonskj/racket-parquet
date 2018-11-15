#lang racket/base
;;
;; thrift - transport/buffered.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [open-input-buffered-transport
   (-> input-transport? input-transport?)]

  [open-output-buffered-transport
   (-> output-transport? output-transport?)])

 buffered-read-length)

;; ---------- Requirements

(require thrift/transport/common
         thrift/private/protocol
         (prefix-in private: thrift/private/transport))

;; ---------- Implementation

(define buffered-read-length (make-parameter 512))

(struct buffered-transport private:wrapped-transport
  (buffer-size))

(define (open-input-buffered-transport tport)
  (buffered-transport
   "buffered"
   'read-buffer
   (open-input-bytes #"")
   tport
   (private:read-interceptor
    buffered-read-byte
    buffered-read-bytes
    buffered-read
    #f
    #f)
   (buffered-read-length)))

(define (open-output-buffered-transport tport)
  (buffered-transport
   "buffered"
   'write-buffer
   (open-output-bytes)
   tport
   (private:write-interceptor
    #f #f #f
    buffered-flush)
   (buffered-read-length)))

(define (open-input-framed-transport tport)
  (buffered-transport
   "framed"
   'read-buffer
   (open-input-bytes #"")
   tport
   (private:read-interceptor
    buffered-read-byte
    buffered-read-bytes
    buffered-read
    #f
    #f)
   0))

(define (open-output-framed-transport tport)
  (buffered-transport
   "framed"
   'write-buffer
   (open-output-bytes)
   tport
   (private:write-interceptor
    #f #f #f
    buffered-flush)
   0))

;; ---------- Internal procedures

;; TODO: need to override transport-read-position?

(define (buffered-read-byte tport)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read-byte (private:wrapped-transport-wrapped tport)))
  
(define (buffered-read-bytes tport amt)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read-bytes (private:wrapped-transport-wrapped tport)))
  
(define (buffered-read tport)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read (private:wrapped-transport-wrapped tport)))

(define (read-buffer tport)
  (close-input-port (transport-port tport))
  (define buffer
    (cond
      [(equal? (transport-source tport) "buffered")
       (transport-read-bytes
        (private:wrapped-transport-wrapped tport)
        (buffered-read-length))]
      [(equal? (transport-source tport) "framed")
       (define frame-length (read-plain-integer 4))
       (transport-read-bytes (private:wrapped-transport-wrapped tport) frame-length)]
      [else (error "unexpected transport: " (transport-source tport))]))
  (private:set-transport-port! tport (open-input-bytes buffer)))

(define (buffered-flush tport)
  (define bytes (get-output-bytes (transport-port tport)))
  (cond
    [(equal? (transport-source tport) "buffered")
     (transport-write-bytes (private:wrapped-transport-wrapped tport) bytes)]
    [(equal? (transport-source tport) "framed")
     (write-plain-integer (bytes-length bytes) 4)
     (transport-write-bytes (private:wrapped-transport-wrapped tport) bytes)]
    [else (error "unexpected transport: " (transport-source tport))])
  (file-truncate (transport-port tport) 0))
