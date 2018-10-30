#lang racket/base
;;
;; parquet - format.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require thrift
         thrift/idl/enumeration
         thrift/idl/struct
         thrift/protocol/decoding)

;; ---------- Implementation

(define module-name 'parquet)

(define magic-number #"PAR1")

(define-enumeration
  parquet-type 0
  (boolean
   int32
   type-int64
   int96 ; deprecated
   float
   double
   byte-array
   fixed-len-byte-arrary))

(define-enumeration
  converted-type 0
  (utf8
   map
   map-key
   list
   enum
   decimal
   date
   time-millis
   time-micros
   timestamp-millis
   timestamp-micros
   uint8
   uint16
   uint32
   uint64
   int8
   int16
   int32
   int64
   json
   bson
   interval))

(define-enumeration
 field-repetition-type 0
 (required
  optional
  repeated))

(define-enumeration
  encoding 0
  (plain
   group-var-int ; deprecated
   plain-dictionary
   rle
   bit-packed
   delta-bit-packed
   delta-length-byte-array
   delta-byte-array
   rle-dictionary
   ))

(define-enumeration
  compression-codec 0
  (uncompressed
   snappy
   gzip
   lzo
   brotli
   lz4
   zstd))

(define-enumeration
  page-type 0
  (data
   index
   dictionary
   data-v2
   bloom-filter))

(define-enumeration
  boundary-order 0
  (unordered
   ascending
   descending))


(define-thrift-struct decimal-type
  ([1 scale required type-int32]
   [2 precision required type-int32]))


(define-thrift-struct sorting-column
  ([1 column-index required type-int32]
   [2 descending? required type-bool]
   [3 nulls-first? required type-bool]))

(define-thrift-struct page-encoding-stats
 ([1 page-type required page-type]
  [2 encoding required encoding]
  [3 count required type-int32]))

(define-thrift-struct statistics
  ([1 max optional type-binary]
   [2 min optional type-binary]
   [3 null-count optional type-int64]
   [4 distinct-count optional type-int64]
   [5 max-value optional type-binary]
   [6 min-value optional type-binary]))

(define-thrift-struct file-metadata
  ([1 version required type-int32]
   [2 schema required list-of schema-element]
   [3 num-rows required type-int64]
   [4 row-groups required list-of row-group]
   [5 key-value-metadata optional list-of key-value]
   [6 created-by optional type-string]
   [7 column-orders optional list-of column-order]))

(define-thrift-struct logical-type ())

(define-thrift-struct schema-element
  ([1 type optional parquet-type]
   [2 type-length optional type-int32]
   [3 repetition-type optional field-repetition-type]
   [4 name required type-string]
   [5 num-children optional type-int32]
   [6 converted-type optional converted-type]
   [7 scale optional type-int32]
   [8 precision optional type-int32]
   [9 field-id optional type-int32]
   [10 logical-type optional logical-type]))

(define-thrift-struct row-group
  ([1 columns required list-of column-chunk]
   [2 total-byte-size required type-int64]
   [3 num-rows required type-int64]
   [4 sorting-columns optional list-of sorting-column]))

(define-thrift-struct column-chunk
  ([1 file-path optional type-string]
   [2 file-offset required type-int64]
   [3 metadata optional column-metadata]
   [4 offset-index-offset optional type-int64]
   [5 offset-index-length optional type-int32]
   [6 column-index-offset optional type-int64]
   [7 column-index-length optional type-int32]))

(define-thrift-struct page-location
  ([1 offset required type-int64]
   [2 compressed-page-size required type-int32]
   [3 first-row-index required type-int64]))

(define-thrift-struct offset-index
  ([1 page-locations required list-of page-location]))

(define-thrift-struct column-order ())

(define-thrift-struct column-index
  ([1 null-pages? required list-of type-bool]
   [2 min-values required list-of type-binary]
   [3 max-values required list-of type-binary]
   [4 boundary-order required boundary-order]
   [5 null-counts optional list-of type-int64]))

(define-thrift-struct key-value
  ([1 key required type-string]
   [2 value optional type-string]))

(define-thrift-struct column-metadata
  ([1 type required parquet-type]
   [2 encodings required list-of encoding]
   [3 path-in-schema required list-of type-string]
   [4 codec required compression-codec]
   [5 num-values required type-int64]
   [6 total-uncompressed-size required type-int64]
   [7 total-compressed-size required type-int64]
   [8 key-value-metadata optional list-of key-value]
   [8 data-page-offset required type-int64]
   [9 index-page-offset optional type-int64]
   [10 dictionary-page-offset optional type-int64]
   [11 statistics optional statistics]
   [12 encoding-stats optional list-of page-encoding-stats]
   [13 bloom-filter-offset optional type-int64]))

(define-thrift-struct data-page-header
  ([1 num-values required type-int32]
   [2 encoding required encoding]
   [3 definition-level-encoding required encoding]
   [4 repetition-level-encoding required encoding]
   [5 statistics optional statistics]))

(define-thrift-struct index-page-header ())

(define-thrift-struct dictionary-page-header
  ([1 num-values required type-int32]
   [2 encoding required encoding]
   [3 sorted? optional type-bool]))

(define-thrift-struct data-page-header-v2
  ([1 num-value required type-int32]
   [2 num-nulls required type-int32]
   [3 num-rows required type-int32]
   [4 encoding required encoding]
   [5 definition_levels_byte_length required type-int32]
   [6 repetition_levels_byte_length required type-int32]
   [7 compressed? optional type-bool]
   [8 statistics optional statistics]))

(define-thrift-struct split-block-algorithm ())

(define-thrift-struct bloom-filter-algorithm
  ([1 BLOCK split-block-algorithm]))

(define-thrift-struct murmur-3 ())

(define-thrift-struct bloom-filter-hash
  ([1 MURMUR3 murmur-3]))

(define-thrift-struct bloom-filter-page-header
  ([1 num-bytes required type-int32]
   [2 algorithm required bloom-filter-algorithm]
   [3 hash required bloom-filter-hash]))

(define-thrift-struct page-header
 ([1 type required page-type]
  [2 uncompressed-page-size required type-int32]
  [3 compressed-page-size required type-int32]
  [4 crc optional type-int32]
  [5 data-page-header optional data-page-header]
  [6 index-page-header optional index-page-header]
  [7 dictionary-page-header optional dictionary-page-header]
  [8 data-page-header-v2 optional data-page-header-v2]
  [9 bloom-filter-page-header optional bloom-filter-page-header]))
  