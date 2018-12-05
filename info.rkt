#lang info
;;
;; Collection parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(define collection "parquet")

(define pkg-desc "Read/Write Apache Parquet format files")
(define version "1.0")
(define pkg-authors '(johnstonskj))

(define deps '(
  "base"
  "thrift"
  "rackunit-lib"
  "racket-index"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "sandbox-lib"
  "cover-coveralls"))

(define scribblings '(("scribblings/parquet.scrbl" (multi-page))))

(define test-omit-paths '("scribblings" "private"))

(define racket-launcher-names (list "rparquet"))
(define racket-launcher-libraries (list "file.rkt"))
