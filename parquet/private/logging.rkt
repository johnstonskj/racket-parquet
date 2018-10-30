#lang racket/base
;;
;; parquet - logging.
;;
;; ~ Simon Johnston 2018.
;;

(provide
 
 (all-defined-out))

(require racket/logging)

(define-logger parquet)

(current-logger parquet-logger)
