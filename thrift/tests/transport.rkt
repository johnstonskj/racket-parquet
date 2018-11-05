#lang racket/base
;;
;; thrift - transport.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; ---------- Requirements

(require rackunit
         ; ---------
         thrift
         thrift/transport/memory)

;; ---------- Test Fixtures

;; ---------- Internal procedures

;; ---------- Test Cases

(test-case
 "simple test for memory transport"

 (define tout (open-output-memory-transport))
 
 (define tin (open-input-memory-transport (transport-output-bytes tout)))

 (check-true #t))
