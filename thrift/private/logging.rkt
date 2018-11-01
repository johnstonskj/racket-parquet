#lang racket/base
;;
;; thrift - logging.
;;   Support for Thrift encoding
;;
;; ~ Simon Johnston 2018.
;;

(provide
 
 (all-defined-out))

(require racket/logging)

(define-logger thrift)

(current-logger thrift-logger)

(define (~b v) (format "~b" v))

(define (~bs bs) (map ~b (bytes->list bs)))

