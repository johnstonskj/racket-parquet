#lang info
;;
;; Collection parquet / thrift.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(define collection "thrift")
(define scribblings '(("scribblings/thrift.scrbl" (multi-page))))

(define test-omit-paths '("scribblings" "private"))

(define racket-launcher-names (list "rthrift"))
(define racket-launcher-libraries (list "idl/generator.rkt"))