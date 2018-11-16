#lang racket/base
;;
;; thrift - transport.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; ---------- Requirements

(require racket/bool
         rackunit
         ; ---------
         thrift
         thrift/protocol/binary
         thrift/protocol/sexpression
         thrift/transport/buffered
         thrift/transport/memory)

;; ---------- Test Fixtures

;; ---------- Internal procedures

(define (test-write-then-read [wrapper-out #f] [wrapper-in #f])
  (define traw-out (open-output-memory-transport))
  (define tout (if (false? wrapper-out) traw-out (wrapper-out traw-out)))
  (define pout (make-sexpression-encoder tout))

  ((encoder-message-begin pout) (message-header "test" message-type-call 101))
  (flush-transport tout)
  
  ((encoder-list-begin pout) (list-or-set type-string 2))
  ((encoder-string pout) "hello")
  ((encoder-string pout) "world")
  ((encoder-list-end pout))

  ((encoder-struct-begin pout))

  ((encoder-field-begin pout) (field-header "name" type-string 1))
  ((encoder-string pout) "simon")
  ((encoder-field-end pout))

  ((encoder-field-begin pout) (field-header "age" type-byte 2))
  ((encoder-byte pout) 48)
  ((encoder-field-end pout))
  
  ((encoder-field-begin pout) (field-header "brilliant?" type-bool 3))
  ((encoder-boolean pout) #f)
  ((encoder-field-end pout))
  
  ((encoder-struct-end pout))
  
  ((encoder-map-begin pout) (map-header type-string type-int32 0))
  ((encoder-string pout) "key")
  ((encoder-string pout) "value")
  ((encoder-string pout) "key2")
  ((encoder-int32 pout) 101)
  ((encoder-int32 pout) 202)
  ((encoder-string pout) "value?")
  ((encoder-map-end pout))
  
  ((encoder-message-end pout))
  (flush-transport tout)
  
  (close-transport tout)
  (define content (transport-output-bytes traw-out))
  (displayln content)
  
  (define traw-in (open-input-memory-transport content))
  (define tin (if (false? wrapper-in) traw-in (wrapper-in traw-in)))
  (define pin (make-sexpression-decoder tin))
  (define msg ((decoder-message-begin pin)))
  (check-equal? (message-header-name msg) "test")
  (check-equal? (message-header-type msg) message-type-call)
  (check-equal? (message-header-sequence-id msg) 101)
  ((decoder-message-end pin))
  
  (close-transport tin))

;; ---------- Test Cases

(test-case
 "simple test for memory transport"

 (test-write-then-read))

(test-case
 "simple test for buffered transport"

 (test-write-then-read open-output-buffered-transport open-input-buffered-transport))

(test-case
 "simple test for framed transport"

 (test-write-then-read open-output-framed-transport open-input-framed-transport))

