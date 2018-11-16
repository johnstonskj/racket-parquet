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
   (-> output-transport? output-transport?)]

  [open-input-framed-transport
   (-> input-transport? input-transport?)]

  [open-output-framed-transport
   (-> output-transport? output-transport?)])

 buffered-read-length)

;; ---------- Requirements

(require racket/bool
         thrift/transport/common
         thrift/private/protocol
         (prefix-in private: thrift/private/transport))

;; ---------- Implementation

(define buffered-read-length (make-parameter 512))

(struct buffered-transport private:wrapped-transport
  (buffer-size
   [buffer-read #:mutable]))

(define (open-input-buffered-transport tport)
  (buffered-transport
   "buffered"
   'read-buffered
   (open-input-bytes #"")
   tport
   (private:read-interceptor
    buffered-read-byte
    buffered-read-bytes
    buffered-read
    #f
    #f)
   (buffered-read-length)
   0))

(define (open-output-buffered-transport tport)
  (buffered-transport
   "buffered"
   'write-buffered
   (open-output-bytes)
   tport
   (private:write-interceptor
    #f #f #f
    buffered-flush)
   (buffered-read-length)
   0))

(define (open-input-framed-transport tport)
  (buffered-transport
   "framed"
   'read-framed
   (open-input-bytes #"")
   tport
   (private:read-interceptor
    buffered-read-byte
    buffered-read-bytes
    buffered-read
    buffered-size
    #f)
   0 0))

(define (open-output-framed-transport tport)
  (buffered-transport
   "framed"
   'write-framed
   (open-output-bytes)
   tport
   (private:write-interceptor
    #f #f #f
    buffered-flush)
   0 0))

;; ---------- Internal procedures

(define (buffered-read-byte tport)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (read-byte (transport-port tport)))
  
(define (buffered-read-bytes tport amt)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (read-bytes amt (transport-port tport)))
  
(define (buffered-read tport)
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (read (transport-port tport)))

(define (buffered-size tport)
  (transport-size (private:wrapped-transport-wrapped tport)))

(define (transport-read-position tport [new-pos #f])
  ;; TODO: need to override transport-read-position?
  (cond
    [(false? new-pos)
     (- (transport-read-position (private:wrapped-transport-wrapped tport))
        (- (buffered-transport-buffer-read tport) (file-position (transport-port tport))))]
    [else
     (define buffer-end (transport-read-position (private:wrapped-transport-wrapped tport)))
     (define buffer-start (- buffer-end (buffered-transport-buffer-read tport)))
     (cond
       [(and (>= new-pos buffer-start) (<= new-pos buffer-end))
        (file-position (transport-port tport) (- new-pos buffer-start))]
       [(< new-pos buffer-start)
        (error "not implemented")]
       [(> new-pos buffer-end)
        (error "not implemented")])])
  (eof))

(define (read-buffer tport)
  (close-input-port (transport-port tport))
  (define read-length
    (cond
      [(equal? (transport-source tport) 'read-buffered)
       (buffered-transport-buffer-size tport)]
      [(equal? (transport-source tport) 'read-framed)
       (read-plain-integer (private:wrapped-transport-wrapped tport) 4)]
      [else (error "read-buffer: unexpected transport: " (transport-source tport))]))
  (define buffer (transport-read-bytes (private:wrapped-transport-wrapped tport) read-length))
  (set-buffered-transport-buffer-read! tport read-length)
  (private:set-transport-port! tport (open-input-bytes buffer)))

(define (buffered-flush tport)
  (close-output-port (transport-port tport))
  (define bytes (get-output-bytes (transport-port tport)))
  (cond
    [(equal? (transport-source tport) 'write-buffered)
     (transport-write-bytes (private:wrapped-transport-wrapped tport) bytes)]
    [(equal? (transport-source tport) 'write-framed)
     (write-plain-integer (private:wrapped-transport-wrapped tport) (bytes-length bytes) 4)
     (transport-write-bytes (private:wrapped-transport-wrapped tport) bytes)]
    [else (error "buffered-flush: unexpected transport: " (transport-source tport))])
  (flush-output (transport-port (private:wrapped-transport-wrapped tport)))
  (private:set-transport-port! tport (open-output-bytes)))
