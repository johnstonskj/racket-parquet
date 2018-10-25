#lang racket/base
;;
;; parquet - format.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require thrift/idl/enumeration
         thrift/idl/structure)

;; ---------- Implementation

(define magic-number #"PAR1")

(define-enumeration
  type 0
  (boolean
   int32
   int64
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


(define-structure decimal
  ([1 scale int32]
   [2 precision int32]))


(define-structure sorting-column
  ([1 column-index int32]
   [2 descending? bool]
   [3 nulls-first? bool]))

(define-structure page-encoding-stats
 ([1 page-type page-type?]
  [2 encoding encoding?]
  [3 count int32]))

(define-structure statistics
  ([1 max binary]
   [2 min binary]
   [3 null-count int64]
   [4 distinct-count int64]
   [5 max-value binary]
   [6 min-value binary]))

(define-structure file-metadata
  ([1 version int32]
   [2 schema list]
   [3 num-rows int64]
   [4 row-groups list]
   [5 key-value-metadata list]
   [6 created-by string]
   [7 column-orders list]))

(define-structure schema-element
  ([1 type type?]
   [2 type-length int32]
   [3 repetition-type field-repetition-type?]
   [4 name string?]
   [5 num-children int32]
   [6 converted-type converted-type?]
   [7 scale int32]
   [8 precision int32]
   [9 field-id int32]
   [10 logical-type logical-type]))

(define-structure row-group
  ([1 columns list]
   [2 total-byte-size int64]
   [3 num-rows int64]
   [4 sorting-columns list]))

(define-structure column-chunk
  ([1 file-path string]
   [2 file-offset int64]
   [3 metadata column-metadata?]
   [4 offset-index-offset int64]
   [5 offset-index-length int32]
   [6 column-index-offset int64]
   [7 column-index-length int32]))

(define-structure page-location
  ([1 offset int64]
   [2 compressed-page-size int32]
   [3 first-row-index int64]))

(define-structure offset-index
  ([1 page-locations list]))

(define-structure column-order ())

(define-structure column-index
  ([1 null-pages? list]
   [2 min-values list]
   [3 max-values list]
   [4 boundary-order boundary-order?]
   [5 null-counts list]))

(define-structure key-value
  ([1 key string]
   [2 value string]))

(define-structure column-metadata
  ([1 type type?]
   [2 encodings listof]
   [3 path-in-schema listof]
   [4 codec compression-codec?]
   [5 num-values int64]
   [6 total-uncompressed-size int64]
   [7 total-compressed-size int64]
   [8 key-value-metadata list]
   [8 data-page-offset int64]
   [9 index-page-offset int64]
   [10 dictionary-page-offset int64]
   [11 statistics statistics?]
   [12 encoding-stats list]
   [13 bloom-filter-offset int64]))

(struct data-page-header
  (num-values ; i32
   definition-level-encoding ; encoding
   repetition-level-encoding ; encoding
   statistics ; optional statistics
   ))

(struct index-page-header ())

(struct dictionary-page-header
  (num-values ; required i32
   encoding ; required encoding?
   sorted? ; optional boolean
   ))

(struct data-page-header-v2
  (num-value ; i32
   num-nulls ; i32
   num-rows ; i32
   encoding
   definition_levels_byte_length ; i32
   repetition_levels_byte_length ; i32
   compressed?
   statistics))

(struct bloom-filter-page-header
  (num-bytes
   algorithm
   hash))

(struct page-header
 (type ; page-type?
  uncompressed-page-size
  compressed-page-size
  crc
  data-page-header
  index-page-header
  dictionary-page-header
  data-page-header-v2
  bloom-filter-page-header))
  
;; ---------- Internal procedures

;; ---------- Internal tests
