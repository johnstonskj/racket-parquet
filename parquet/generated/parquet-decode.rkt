#lang racket/base
;;
;; Generated namespace parquet
;;                from ../format.rkt
;;                  on Saturday, November 3rd, 2018
;;                  by thrift/idl/generator v0.1
;;

(provide (all-defined-out))

(require racket/list racket/set thrift thrift/protocol/decoding "parquet.rkt")

(define (parquet-type/decode decoder) (integer->parquet-type (type-int32/decode decoder)))
(define (parquet-type/decode-list decoder)
  (decode-a-list decoder parquet-type/decode))

(define (converted-type/decode decoder) (integer->converted-type (type-int32/decode decoder)))
(define (converted-type/decode-list decoder)
  (decode-a-list decoder converted-type/decode))

(define (field-repetition-type/decode decoder) (integer->field-repetition-type (type-int32/decode decoder)))
(define (field-repetition-type/decode-list decoder)
  (decode-a-list decoder field-repetition-type/decode))

(define (encoding/decode decoder) (integer->encoding (type-int32/decode decoder)))
(define (encoding/decode-list decoder)
  (decode-a-list decoder encoding/decode))

(define (compression-codec/decode decoder) (integer->compression-codec (type-int32/decode decoder)))
(define (compression-codec/decode-list decoder)
  (decode-a-list decoder compression-codec/decode))

(define (page-type/decode decoder) (integer->page-type (type-int32/decode decoder)))
(define (page-type/decode-list decoder)
  (decode-a-list decoder page-type/decode))

(define (boundary-order/decode decoder) (integer->boundary-order (type-int32/decode decoder)))
(define (boundary-order/decode-list decoder)
  (decode-a-list decoder boundary-order/decode))

(define (decimal-type/decode decoder)
  (log-parquet-info "decoding decimal-type from thrift")
  (decode-a-struct decoder decimal-type decimal-type/reverse-schema))
(define (decimal-type/decode-list decoder)
  (log-parquet-info "decoding list of decimal-type from thrift")
  (decode-a-list decoder decimal-type/decode))
(define (decimal-type/decode-set decoder)
  (log-parquet-info "decoding set of decimal-type from thrift")
  (list->set (decode-a-list decoder decimal-type/decode)))

(define (sorting-column/decode decoder)
  (log-parquet-info "decoding sorting-column from thrift")
  (decode-a-struct decoder sorting-column sorting-column/reverse-schema))
(define (sorting-column/decode-list decoder)
  (log-parquet-info "decoding list of sorting-column from thrift")
  (decode-a-list decoder sorting-column/decode))
(define (sorting-column/decode-set decoder)
  (log-parquet-info "decoding set of sorting-column from thrift")
  (list->set (decode-a-list decoder sorting-column/decode)))

(define (page-encoding-stats/decode decoder)
  (log-parquet-info "decoding page-encoding-stats from thrift")
  (decode-a-struct decoder page-encoding-stats page-encoding-stats/reverse-schema))
(define (page-encoding-stats/decode-list decoder)
  (log-parquet-info "decoding list of page-encoding-stats from thrift")
  (decode-a-list decoder page-encoding-stats/decode))
(define (page-encoding-stats/decode-set decoder)
  (log-parquet-info "decoding set of page-encoding-stats from thrift")
  (list->set (decode-a-list decoder page-encoding-stats/decode)))

(define (statistics/decode decoder)
  (log-parquet-info "decoding statistics from thrift")
  (decode-a-struct decoder statistics statistics/reverse-schema))
(define (statistics/decode-list decoder)
  (log-parquet-info "decoding list of statistics from thrift")
  (decode-a-list decoder statistics/decode))
(define (statistics/decode-set decoder)
  (log-parquet-info "decoding set of statistics from thrift")
  (list->set (decode-a-list decoder statistics/decode)))

(define (file-metadata/decode decoder)
  (log-parquet-info "decoding file-metadata from thrift")
  (decode-a-struct decoder file-metadata file-metadata/reverse-schema))
(define (file-metadata/decode-list decoder)
  (log-parquet-info "decoding list of file-metadata from thrift")
  (decode-a-list decoder file-metadata/decode))
(define (file-metadata/decode-set decoder)
  (log-parquet-info "decoding set of file-metadata from thrift")
  (list->set (decode-a-list decoder file-metadata/decode)))

(define (logical-type/decode decoder)
  (log-parquet-info "decoding logical-type from thrift")
  (decode-a-struct decoder logical-type logical-type/reverse-schema))
(define (logical-type/decode-list decoder)
  (log-parquet-info "decoding list of logical-type from thrift")
  (decode-a-list decoder logical-type/decode))
(define (logical-type/decode-set decoder)
  (log-parquet-info "decoding set of logical-type from thrift")
  (list->set (decode-a-list decoder logical-type/decode)))

(define (schema-element/decode decoder)
  (log-parquet-info "decoding schema-element from thrift")
  (decode-a-struct decoder schema-element schema-element/reverse-schema))
(define (schema-element/decode-list decoder)
  (log-parquet-info "decoding list of schema-element from thrift")
  (decode-a-list decoder schema-element/decode))
(define (schema-element/decode-set decoder)
  (log-parquet-info "decoding set of schema-element from thrift")
  (list->set (decode-a-list decoder schema-element/decode)))

(define (row-group/decode decoder)
  (log-parquet-info "decoding row-group from thrift")
  (decode-a-struct decoder row-group row-group/reverse-schema))
(define (row-group/decode-list decoder)
  (log-parquet-info "decoding list of row-group from thrift")
  (decode-a-list decoder row-group/decode))
(define (row-group/decode-set decoder)
  (log-parquet-info "decoding set of row-group from thrift")
  (list->set (decode-a-list decoder row-group/decode)))

(define (column-chunk/decode decoder)
  (log-parquet-info "decoding column-chunk from thrift")
  (decode-a-struct decoder column-chunk column-chunk/reverse-schema))
(define (column-chunk/decode-list decoder)
  (log-parquet-info "decoding list of column-chunk from thrift")
  (decode-a-list decoder column-chunk/decode))
(define (column-chunk/decode-set decoder)
  (log-parquet-info "decoding set of column-chunk from thrift")
  (list->set (decode-a-list decoder column-chunk/decode)))

(define (page-location/decode decoder)
  (log-parquet-info "decoding page-location from thrift")
  (decode-a-struct decoder page-location page-location/reverse-schema))
(define (page-location/decode-list decoder)
  (log-parquet-info "decoding list of page-location from thrift")
  (decode-a-list decoder page-location/decode))
(define (page-location/decode-set decoder)
  (log-parquet-info "decoding set of page-location from thrift")
  (list->set (decode-a-list decoder page-location/decode)))

(define (offset-index/decode decoder)
  (log-parquet-info "decoding offset-index from thrift")
  (decode-a-struct decoder offset-index offset-index/reverse-schema))
(define (offset-index/decode-list decoder)
  (log-parquet-info "decoding list of offset-index from thrift")
  (decode-a-list decoder offset-index/decode))
(define (offset-index/decode-set decoder)
  (log-parquet-info "decoding set of offset-index from thrift")
  (list->set (decode-a-list decoder offset-index/decode)))

(define (column-order/decode decoder)
  (log-parquet-info "decoding column-order from thrift")
  (decode-a-struct decoder column-order column-order/reverse-schema))
(define (column-order/decode-list decoder)
  (log-parquet-info "decoding list of column-order from thrift")
  (decode-a-list decoder column-order/decode))
(define (column-order/decode-set decoder)
  (log-parquet-info "decoding set of column-order from thrift")
  (list->set (decode-a-list decoder column-order/decode)))

(define (column-index/decode decoder)
  (log-parquet-info "decoding column-index from thrift")
  (decode-a-struct decoder column-index column-index/reverse-schema))
(define (column-index/decode-list decoder)
  (log-parquet-info "decoding list of column-index from thrift")
  (decode-a-list decoder column-index/decode))
(define (column-index/decode-set decoder)
  (log-parquet-info "decoding set of column-index from thrift")
  (list->set (decode-a-list decoder column-index/decode)))

(define (key-value/decode decoder)
  (log-parquet-info "decoding key-value from thrift")
  (decode-a-struct decoder key-value key-value/reverse-schema))
(define (key-value/decode-list decoder)
  (log-parquet-info "decoding list of key-value from thrift")
  (decode-a-list decoder key-value/decode))
(define (key-value/decode-set decoder)
  (log-parquet-info "decoding set of key-value from thrift")
  (list->set (decode-a-list decoder key-value/decode)))

(define (column-metadata/decode decoder)
  (log-parquet-info "decoding column-metadata from thrift")
  (decode-a-struct decoder column-metadata column-metadata/reverse-schema))
(define (column-metadata/decode-list decoder)
  (log-parquet-info "decoding list of column-metadata from thrift")
  (decode-a-list decoder column-metadata/decode))
(define (column-metadata/decode-set decoder)
  (log-parquet-info "decoding set of column-metadata from thrift")
  (list->set (decode-a-list decoder column-metadata/decode)))

(define (data-page-header/decode decoder)
  (log-parquet-info "decoding data-page-header from thrift")
  (decode-a-struct decoder data-page-header data-page-header/reverse-schema))
(define (data-page-header/decode-list decoder)
  (log-parquet-info "decoding list of data-page-header from thrift")
  (decode-a-list decoder data-page-header/decode))
(define (data-page-header/decode-set decoder)
  (log-parquet-info "decoding set of data-page-header from thrift")
  (list->set (decode-a-list decoder data-page-header/decode)))

(define (index-page-header/decode decoder)
  (log-parquet-info "decoding index-page-header from thrift")
  (decode-a-struct decoder index-page-header index-page-header/reverse-schema))
(define (index-page-header/decode-list decoder)
  (log-parquet-info "decoding list of index-page-header from thrift")
  (decode-a-list decoder index-page-header/decode))
(define (index-page-header/decode-set decoder)
  (log-parquet-info "decoding set of index-page-header from thrift")
  (list->set (decode-a-list decoder index-page-header/decode)))

(define (dictionary-page-header/decode decoder)
  (log-parquet-info "decoding dictionary-page-header from thrift")
  (decode-a-struct decoder dictionary-page-header dictionary-page-header/reverse-schema))
(define (dictionary-page-header/decode-list decoder)
  (log-parquet-info "decoding list of dictionary-page-header from thrift")
  (decode-a-list decoder dictionary-page-header/decode))
(define (dictionary-page-header/decode-set decoder)
  (log-parquet-info "decoding set of dictionary-page-header from thrift")
  (list->set (decode-a-list decoder dictionary-page-header/decode)))

(define (data-page-header-v2/decode decoder)
  (log-parquet-info "decoding data-page-header-v2 from thrift")
  (decode-a-struct decoder data-page-header-v2 data-page-header-v2/reverse-schema))
(define (data-page-header-v2/decode-list decoder)
  (log-parquet-info "decoding list of data-page-header-v2 from thrift")
  (decode-a-list decoder data-page-header-v2/decode))
(define (data-page-header-v2/decode-set decoder)
  (log-parquet-info "decoding set of data-page-header-v2 from thrift")
  (list->set (decode-a-list decoder data-page-header-v2/decode)))

(define (split-block-algorithm/decode decoder)
  (log-parquet-info "decoding split-block-algorithm from thrift")
  (decode-a-struct decoder split-block-algorithm split-block-algorithm/reverse-schema))
(define (split-block-algorithm/decode-list decoder)
  (log-parquet-info "decoding list of split-block-algorithm from thrift")
  (decode-a-list decoder split-block-algorithm/decode))
(define (split-block-algorithm/decode-set decoder)
  (log-parquet-info "decoding set of split-block-algorithm from thrift")
  (list->set (decode-a-list decoder split-block-algorithm/decode)))

(define (bloom-filter-algorithm/decode decoder)
  (log-parquet-info "decoding bloom-filter-algorithm from thrift")
  (decode-a-struct decoder bloom-filter-algorithm bloom-filter-algorithm/reverse-schema))
(define (bloom-filter-algorithm/decode-list decoder)
  (log-parquet-info "decoding list of bloom-filter-algorithm from thrift")
  (decode-a-list decoder bloom-filter-algorithm/decode))
(define (bloom-filter-algorithm/decode-set decoder)
  (log-parquet-info "decoding set of bloom-filter-algorithm from thrift")
  (list->set (decode-a-list decoder bloom-filter-algorithm/decode)))

(define (murmur-3/decode decoder)
  (log-parquet-info "decoding murmur-3 from thrift")
  (decode-a-struct decoder murmur-3 murmur-3/reverse-schema))
(define (murmur-3/decode-list decoder)
  (log-parquet-info "decoding list of murmur-3 from thrift")
  (decode-a-list decoder murmur-3/decode))
(define (murmur-3/decode-set decoder)
  (log-parquet-info "decoding set of murmur-3 from thrift")
  (list->set (decode-a-list decoder murmur-3/decode)))

(define (bloom-filter-hash/decode decoder)
  (log-parquet-info "decoding bloom-filter-hash from thrift")
  (decode-a-struct decoder bloom-filter-hash bloom-filter-hash/reverse-schema))
(define (bloom-filter-hash/decode-list decoder)
  (log-parquet-info "decoding list of bloom-filter-hash from thrift")
  (decode-a-list decoder bloom-filter-hash/decode))
(define (bloom-filter-hash/decode-set decoder)
  (log-parquet-info "decoding set of bloom-filter-hash from thrift")
  (list->set (decode-a-list decoder bloom-filter-hash/decode)))

(define (bloom-filter-page-header/decode decoder)
  (log-parquet-info "decoding bloom-filter-page-header from thrift")
  (decode-a-struct decoder bloom-filter-page-header bloom-filter-page-header/reverse-schema))
(define (bloom-filter-page-header/decode-list decoder)
  (log-parquet-info "decoding list of bloom-filter-page-header from thrift")
  (decode-a-list decoder bloom-filter-page-header/decode))
(define (bloom-filter-page-header/decode-set decoder)
  (log-parquet-info "decoding set of bloom-filter-page-header from thrift")
  (list->set (decode-a-list decoder bloom-filter-page-header/decode)))

(define (page-header/decode decoder)
  (log-parquet-info "decoding page-header from thrift")
  (decode-a-struct decoder page-header page-header/reverse-schema))
(define (page-header/decode-list decoder)
  (log-parquet-info "decoding list of page-header from thrift")
  (decode-a-list decoder page-header/decode))
(define (page-header/decode-set decoder)
  (log-parquet-info "decoding set of page-header from thrift")
  (list->set (decode-a-list decoder page-header/decode)))

(define-namespace-anchor anchor)
(define this-namespace (namespace-anchor->namespace anchor))

(define (fixup-schema schema)
(for ([index (range (vector-length schema))])
  (define field (vector-ref schema index))
  (when (symbol? (thrift-field-major-type field))
    (define new-field
      (struct-copy thrift-field
                   field
                   [major-type (eval (thrift-field-major-type field) this-namespace)]))
    (vector-set! schema index new-field))))

(define (make-reverse-schema schema)
  (for/hash ([field schema] [position (range (vector-length schema))])
    (set-thrift-field-position! field position)
    (values (thrift-field-id field) field)))

(fixup-schema page-header/schema)
(define page-header/reverse-schema (make-reverse-schema page-header/schema))

(fixup-schema bloom-filter-page-header/schema)
(define bloom-filter-page-header/reverse-schema (make-reverse-schema bloom-filter-page-header/schema))

(fixup-schema bloom-filter-hash/schema)
(define bloom-filter-hash/reverse-schema (make-reverse-schema bloom-filter-hash/schema))

(fixup-schema murmur-3/schema)
(define murmur-3/reverse-schema (make-reverse-schema murmur-3/schema))

(fixup-schema bloom-filter-algorithm/schema)
(define bloom-filter-algorithm/reverse-schema (make-reverse-schema bloom-filter-algorithm/schema))

(fixup-schema split-block-algorithm/schema)
(define split-block-algorithm/reverse-schema (make-reverse-schema split-block-algorithm/schema))

(fixup-schema data-page-header-v2/schema)
(define data-page-header-v2/reverse-schema (make-reverse-schema data-page-header-v2/schema))

(fixup-schema dictionary-page-header/schema)
(define dictionary-page-header/reverse-schema (make-reverse-schema dictionary-page-header/schema))

(fixup-schema index-page-header/schema)
(define index-page-header/reverse-schema (make-reverse-schema index-page-header/schema))

(fixup-schema data-page-header/schema)
(define data-page-header/reverse-schema (make-reverse-schema data-page-header/schema))

(fixup-schema column-metadata/schema)
(define column-metadata/reverse-schema (make-reverse-schema column-metadata/schema))

(fixup-schema key-value/schema)
(define key-value/reverse-schema (make-reverse-schema key-value/schema))

(fixup-schema column-index/schema)
(define column-index/reverse-schema (make-reverse-schema column-index/schema))

(fixup-schema column-order/schema)
(define column-order/reverse-schema (make-reverse-schema column-order/schema))

(fixup-schema offset-index/schema)
(define offset-index/reverse-schema (make-reverse-schema offset-index/schema))

(fixup-schema page-location/schema)
(define page-location/reverse-schema (make-reverse-schema page-location/schema))

(fixup-schema column-chunk/schema)
(define column-chunk/reverse-schema (make-reverse-schema column-chunk/schema))

(fixup-schema row-group/schema)
(define row-group/reverse-schema (make-reverse-schema row-group/schema))

(fixup-schema schema-element/schema)
(define schema-element/reverse-schema (make-reverse-schema schema-element/schema))

(fixup-schema logical-type/schema)
(define logical-type/reverse-schema (make-reverse-schema logical-type/schema))

(fixup-schema file-metadata/schema)
(define file-metadata/reverse-schema (make-reverse-schema file-metadata/schema))

(fixup-schema statistics/schema)
(define statistics/reverse-schema (make-reverse-schema statistics/schema))

(fixup-schema page-encoding-stats/schema)
(define page-encoding-stats/reverse-schema (make-reverse-schema page-encoding-stats/schema))

(fixup-schema sorting-column/schema)
(define sorting-column/reverse-schema (make-reverse-schema sorting-column/schema))

(fixup-schema decimal-type/schema)
(define decimal-type/reverse-schema (make-reverse-schema decimal-type/schema))
