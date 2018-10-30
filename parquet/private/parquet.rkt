#lang racket/base
;;
;; parquet - parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (all-defined-out))

;; ---------- Requirements

(require racket/bool
         racket/list
         racket/match
         racket/string
         thrift
         (prefix-in compact: thrift/protocol/compact)
         
         thrift/protocol/decoding
         parquet/private/format
         parquet/private/logging)

;; ---------- Internal types

;; ---------- Implementation

(struct field-schema (index decoder required))

(define (decode-file-metadata decoder)
  (log-parquet-info "decode-file-metadata from thrift")
  (decode-a-struct
   decoder
   file-metadata
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t)
    2 (field-schema 1 decode-schema-element-list #t)
    3 (field-schema 2 (decoder-int64 decoder) #t)
    4 (field-schema 3 decode-row-group-list #t)
    5 (field-schema 5 debug-file-metadata #f) ;decode-key-value-list #f)
    6 (field-schema 5 (decoder-string decoder) #f)
    7 (field-schema 6 decode-column-order-list #f))))

(define (debug-file-metadata decoder)
  (newline)
  (for ([byte ((decoder-bytes decoder) 32)])
    (display (format "~b " byte)))
  (newline))

(define (decode-schema-element-list decoder)
  (log-parquet-info "decode-schema-element-list from thrift")
  ;; TODO: reconstruct nested form
  (decode-a-list decoder decode-schema-element))

(define (decode-schema-element decoder)
  (log-parquet-info "decode-schema-element from thrift")
  (decode-a-struct
   decoder
   schema-element
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #f) ; type?
    2 (field-schema 1 (decoder-int32 decoder) #f)
    3 (field-schema 2 (decoder-int32 decoder) #f) ; field-repetition-type?
    4 (field-schema 3 (decoder-string decoder) #f)
    5 (field-schema 4 (decoder-int32 decoder) #f)
    6 (field-schema 5 (decoder-int32 decoder) #f) ; converted-type?
    7 (field-schema 6 (decoder-int32 decoder) #f)
    8 (field-schema 7 (decoder-int32 decoder) #f)
    9 (field-schema 8 (decoder-int32 decoder) #f)
    10 (field-schema 9 (decoder-int32 decoder) #f)))) ; logical-type?

(define (decode-row-group-list decoder)
  (log-parquet-info "decode-row-group-list from thrift")
  (decode-a-list decoder decode-row-group))

(define (decode-row-group decoder)
  (log-parquet-info "decode-row-group from thrift")
  (decode-a-struct
   decoder
   row-group
   (hash
    1 (field-schema 0 decode-column-chunk-list #t)
    2 (field-schema 1 (decoder-int64 decoder) #t)
    3 (field-schema 2 (decoder-int64 decoder) #t)
    4 (field-schema 3 decode-sorting-column-list #f))))

(define (decode-column-chunk-list decoder)
  (log-parquet-info "decode-column-chunk-list from thrift")
  (decode-a-list decoder decode-column-chunk))

(define (decode-column-chunk decoder)
  (log-parquet-info "decode-column-chunk from thrift")
  (decode-a-struct
   decoder
   column-chunk
   (hash
    1 (field-schema 0 (decoder-string decoder) #f)
    2 (field-schema 1 (decoder-int64 decoder) #t)
    3 (field-schema 2 decode-column-metadata #f)
    4 (field-schema 3 (decoder-int64 decoder) #f)
    5 (field-schema 4 (decoder-int32 decoder) #f)
    6 (field-schema 5 (decoder-int64 decoder) #f)
    7 (field-schema 6 (decoder-int32 decoder) #f))))

(define (decode-sorting-column-list decoder)
  (log-parquet-info "decode-sorting-column-list from thrift")
  (decode-a-list decoder decode-sorting-column))

(define (decode-sorting-column decoder)
  (log-parquet-info "decode-sorting-column from thrift")
  (decode-a-struct
   decoder
   sorting-column
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t)
    2 (field-schema 1 (decoder-boolean decoder) #t)
    3 (field-schema 2 (decoder-boolean decoder) #t))))

(define (decode-column-metadata decoder)
  (log-parquet-info "decode-column-metadata from thrift")
  (decode-a-struct
   decoder
   column-metadata
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t) ; type?
    2 (field-schema 1 decode-encodings-list #t) ; listof int32
    3 (field-schema 2 decode-path-in-schema-list #t) ; listof string
    4 (field-schema 3 (decoder-int32 decoder) #t) ; compression-code?
    5 (field-schema 4 (decoder-int64 decoder) #t)
    6 (field-schema 5 (decoder-int64 decoder) #t)
    7 (field-schema 6 (decoder-int64 decoder) #t)
    8 (field-schema 7 decode-key-value-list #f)
    9 (field-schema 8 (decoder-int64 decoder) #t)
    10 (field-schema 9 (decoder-int64 decoder) #f)
    11 (field-schema 10 (decoder-int64 decoder) #f)
    12 (field-schema 11 decode-statistics #f)
    13 (field-schema 12 decode-page-encoding-stats-list #f)
    14 (field-schema 13 (decoder-int64 decoder) #f))))

(define (decode-encodings-list decoder)
  (log-parquet-info "decode-encodings-list from thrift")
  (decode-a-list decoder (decoder-int32 decoder)))

(define (decode-path-in-schema-list decoder)
  (log-parquet-info "decode-path-in-schema-list from thrift")
  (decode-a-list decoder (decoder-string decoder)))

(define (decode-key-value-list decoder)
  (log-parquet-info "decode-key-value-list from thrift")
  (decode-a-list decoder decode-key-value))

(define (decode-key-value decoder)
  (log-parquet-info "decode-key-value from thrift")
  (decode-a-struct
   decoder
   key-value
   (hash
    1 (field-schema 0 (decoder-string decoder) #t)
    2 (field-schema 1 (decoder-string decoder) #t))))

(define (decode-statistics decoder)
  (log-parquet-info "decode-statistics from thrift")
  (decode-a-struct
   decoder
   key-value
   (hash
    1 (field-schema 0 (decoder-string decoder) #f)
    2 (field-schema 1 (decoder-string decoder) #f)
    3 (field-schema 2 (decoder-int64 decoder) #f)
    4 (field-schema 3 (decoder-int64 decoder) #f)
    5 (field-schema 4 (decoder-string decoder) #f)
    6 (field-schema 5 (decoder-string decoder) #f))))

(define (decode-page-encoding-stats-list decoder)
  (log-parquet-info "decode-page-encoding-stats-list from thrift")
  (decode-a-list decoder decode-page-encoding-stats))

(define (decode-page-encoding-stats decoder)
  (log-parquet-info "decode-page-encoding-stats from thrift")
  (decode-a-struct
   decoder
   page-encoding-stats
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #f) ; page-type?
    2 (field-schema 1 (decoder-int32 decoder) #f) ; encoding?
    3 (field-schema 2 (decoder-int32 decoder) #f))))

(define (decode-column-order-list decoder)
  (log-parquet-info "decode-column-order-list from thrift")
  (decode-a-list decoder decode-column-order))

(define (decode-column-order decoder)
  (log-parquet-info "decode-column-order from thrift")
  (decoder-struct-begin decoder)
  (decoder-struct-end decoder)
  'no-value)
  

;; ---------- Internal procedures

;; ---------- Internal tests
