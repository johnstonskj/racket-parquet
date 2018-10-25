#lang racket/base
;;
;; parquet - parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (contract-out))

;; ---------- Requirements

(require "private/parquet.rkt")

;; ---------- Internal types

;; ---------- Implementation

;; ---------- Internal procedures

;; ---------- Internal tests


(module+ test
  (require rackunit)
  ;; only use for internal tests, use check- functions 
  (check-true "dummy first test" #f))


(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
