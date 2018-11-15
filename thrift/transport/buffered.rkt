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

(define (open-input-buffered-transport tport)
  (transport
   "buffered"
   'read-buffer
   (open-input-bytes #"")
   (hash 'wrapped tport
         'read-byte buffered-read-byte
         'read-bytes buffered-read-bytes
         'read buffered-read)))

(define (open-output-buffered-transport tport)
  (transport
   "buffered"
   'write-buffer
   (open-output-bytes)
   (hash 'wrapped tport
         'flush flush-buffered)))

;; ---------- Internal procedures

(define (buffered-read-byte tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read-byte wrapped))
  
(define (buffered-read-bytes tport amt)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read-bytes wrapped))
  
(define (buffered-read tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-buffer tport))
  (transport-read wrapped))
  
(define (read-buffer tport)
  (close-input-port (transport-port tport))
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (define buffer (transport-read-bytes wrapped (buffered-read-length)))
  (private:set-transport-port! tport (open-input-bytes buffer)))

(define (flush-buffered tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (transport-write-bytes wrapped (get-output-bytes (transport-port tport)))
  (file-truncate (transport-port tport) 0))

