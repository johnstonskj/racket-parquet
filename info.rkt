#lang info
;;
;; Collection parquet / parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(define collection 'multi)

(define pkg-desc "Read/Write Apache Parquet format files")
(define version "1.0")
(define pkg-authors '(johnstonskj))

(define deps '(
  "base"
  "rackunit-lib"
  "racket-index"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "sandbox-lib"
  "cover-coveralls"))
