#lang racket/base
;;
;; thrift - transport/framed.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  
  [open-input-framed-transport
   (-> input-transport? input-transport?)]

  [open-output-framed-transport
   (-> output-transport? output-transport?)]))

;; ---------- Requirements

(require thrift/transport/common
         thrift/private/protocol
         (prefix-in private: thrift/private/transport))

;; ---------- Implementation

(define (open-input-framed-transport tport)
  (transport
   "framed"
   'read-buffer
   (open-input-bytes #"")
   (hash 'wrapped tport
         'read-byte framed-read-byte
         'read-bytes framed-read-bytes
         'read framed-read)))

(define (open-output-framed-transport tport)
  (transport
   "framed"
   'write-buffer
   (open-output-bytes)
   (hash 'wrapped tport
         'flush flush-framed)))

;; ---------- Internal procedures

(define (framed-read-byte tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-frame tport))
  (transport-read-byte wrapped))
  
(define (framed-read-bytes tport amt)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-frame tport))
  (transport-read-bytes wrapped))
  
(define (framed-read tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (when (eof-object? (peek-byte (transport-port tport)))
    (read-frame tport))
  (transport-read wrapped))
  
(define (read-frame tport)
  (close-input-port (transport-port tport))
  (define frame-length (read-plain-integer 4))
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (define frame (transport-read-bytes wrapped frame-length))
  (private:set-transport-port! tport (open-input-bytes frame)))

(define (flush-framed tport)
  (define wrapped (hash-ref (transport-overrides tport) 'wrapped))
  (define bytes (get-output-bytes (transport-port tport)))
  (write-plain-integer (bytes-length bytes) 4)
  (transport-write-bytes wrapped bytes)
  (file-truncate (transport-port tport) 0))

