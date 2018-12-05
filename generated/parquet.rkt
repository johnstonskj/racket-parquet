#lang racket/base
;;
;; Generated namespace parquet
;;                from ../format.rkt
;;                  on Saturday, November 3rd, 2018
;;                  by thrift/idl/generator v0.1
;;

(provide (all-defined-out))

(require racket/logging racket/match racket/list racket/set thrift thrift/protocol/decoding)

(define-logger parquet)
(current-logger parquet-logger)

(struct parquet-type (n v))
(define parquet-type:boolean (parquet-type 'parquet-type:boolean 0))
(define parquet-type:int32 (parquet-type 'parquet-type:int32 1))
(define parquet-type:type-int64 (parquet-type 'parquet-type:type-int64 2))
(define parquet-type:int96 (parquet-type 'parquet-type:int96 3))
(define parquet-type:float (parquet-type 'parquet-type:float 4))
(define parquet-type:double (parquet-type 'parquet-type:double 5))
(define parquet-type:byte-array (parquet-type 'parquet-type:byte-array 6))
(define parquet-type:fixed-len-byte-arrary (parquet-type 'parquet-type:fixed-len-byte-arrary 7))
(define (parquet-type->symbol e)
  (parquet-type-n e))
(define (parquet-type->integer e)
  (parquet-type-v e))
(define (integer->parquet-type n)
  (match n
    [0 parquet-type:boolean]
    [1 parquet-type:int32]
    [2 parquet-type:type-int64]
    [3 parquet-type:int96]
    [4 parquet-type:float]
    [5 parquet-type:double]
    [6 parquet-type:byte-array]
    [7 parquet-type:fixed-len-byte-arrary]
    [else (error "unknown value for enum parquet-type: " n)]))

(struct converted-type (n v))
(define converted-type:utf8 (converted-type 'converted-type:utf8 0))
(define converted-type:map (converted-type 'converted-type:map 1))
(define converted-type:map-key (converted-type 'converted-type:map-key 2))
(define converted-type:list (converted-type 'converted-type:list 3))
(define converted-type:enum (converted-type 'converted-type:enum 4))
(define converted-type:decimal (converted-type 'converted-type:decimal 5))
(define converted-type:date (converted-type 'converted-type:date 6))
(define converted-type:time-millis (converted-type 'converted-type:time-millis 7))
(define converted-type:time-micros (converted-type 'converted-type:time-micros 8))
(define converted-type:timestamp-millis (converted-type 'converted-type:timestamp-millis 9))
(define converted-type:timestamp-micros (converted-type 'converted-type:timestamp-micros 10))
(define converted-type:uint8 (converted-type 'converted-type:uint8 11))
(define converted-type:uint16 (converted-type 'converted-type:uint16 12))
(define converted-type:uint32 (converted-type 'converted-type:uint32 13))
(define converted-type:uint64 (converted-type 'converted-type:uint64 14))
(define converted-type:int8 (converted-type 'converted-type:int8 15))
(define converted-type:int16 (converted-type 'converted-type:int16 16))
(define converted-type:int32 (converted-type 'converted-type:int32 17))
(define converted-type:int64 (converted-type 'converted-type:int64 18))
(define converted-type:json (converted-type 'converted-type:json 19))
(define converted-type:bson (converted-type 'converted-type:bson 20))
(define converted-type:interval (converted-type 'converted-type:interval 21))
(define (converted-type->symbol e)
  (converted-type-n e))
(define (converted-type->integer e)
  (converted-type-v e))
(define (integer->converted-type n)
  (match n
    [0 converted-type:utf8]
    [1 converted-type:map]
    [2 converted-type:map-key]
    [3 converted-type:list]
    [4 converted-type:enum]
    [5 converted-type:decimal]
    [6 converted-type:date]
    [7 converted-type:time-millis]
    [8 converted-type:time-micros]
    [9 converted-type:timestamp-millis]
    [10 converted-type:timestamp-micros]
    [11 converted-type:uint8]
    [12 converted-type:uint16]
    [13 converted-type:uint32]
    [14 converted-type:uint64]
    [15 converted-type:int8]
    [16 converted-type:int16]
    [17 converted-type:int32]
    [18 converted-type:int64]
    [19 converted-type:json]
    [20 converted-type:bson]
    [21 converted-type:interval]
    [else (error "unknown value for enum converted-type: " n)]))

(struct field-repetition-type (n v))
(define field-repetition-type:required (field-repetition-type 'field-repetition-type:required 0))
(define field-repetition-type:optional (field-repetition-type 'field-repetition-type:optional 1))
(define field-repetition-type:repeated (field-repetition-type 'field-repetition-type:repeated 2))
(define (field-repetition-type->symbol e)
  (field-repetition-type-n e))
(define (field-repetition-type->integer e)
  (field-repetition-type-v e))
(define (integer->field-repetition-type n)
  (match n
    [0 field-repetition-type:required]
    [1 field-repetition-type:optional]
    [2 field-repetition-type:repeated]
    [else (error "unknown value for enum field-repetition-type: " n)]))

(struct encoding (n v))
(define encoding:plain (encoding 'encoding:plain 0))
(define encoding:group-var-int (encoding 'encoding:group-var-int 1))
(define encoding:plain-dictionary (encoding 'encoding:plain-dictionary 2))
(define encoding:rle (encoding 'encoding:rle 3))
(define encoding:bit-packed (encoding 'encoding:bit-packed 4))
(define encoding:delta-bit-packed (encoding 'encoding:delta-bit-packed 5))
(define encoding:delta-length-byte-array (encoding 'encoding:delta-length-byte-array 6))
(define encoding:delta-byte-array (encoding 'encoding:delta-byte-array 7))
(define encoding:rle-dictionary (encoding 'encoding:rle-dictionary 8))
(define (encoding->symbol e)
  (encoding-n e))
(define (encoding->integer e)
  (encoding-v e))
(define (integer->encoding n)
  (match n
    [0 encoding:plain]
    [1 encoding:group-var-int]
    [2 encoding:plain-dictionary]
    [3 encoding:rle]
    [4 encoding:bit-packed]
    [5 encoding:delta-bit-packed]
    [6 encoding:delta-length-byte-array]
    [7 encoding:delta-byte-array]
    [8 encoding:rle-dictionary]
    [else (error "unknown value for enum encoding: " n)]))

(struct compression-codec (n v))
(define compression-codec:uncompressed (compression-codec 'compression-codec:uncompressed 0))
(define compression-codec:snappy (compression-codec 'compression-codec:snappy 1))
(define compression-codec:gzip (compression-codec 'compression-codec:gzip 2))
(define compression-codec:lzo (compression-codec 'compression-codec:lzo 3))
(define compression-codec:brotli (compression-codec 'compression-codec:brotli 4))
(define compression-codec:lz4 (compression-codec 'compression-codec:lz4 5))
(define compression-codec:zstd (compression-codec 'compression-codec:zstd 6))
(define (compression-codec->symbol e)
  (compression-codec-n e))
(define (compression-codec->integer e)
  (compression-codec-v e))
(define (integer->compression-codec n)
  (match n
    [0 compression-codec:uncompressed]
    [1 compression-codec:snappy]
    [2 compression-codec:gzip]
    [3 compression-codec:lzo]
    [4 compression-codec:brotli]
    [5 compression-codec:lz4]
    [6 compression-codec:zstd]
    [else (error "unknown value for enum compression-codec: " n)]))

(struct page-type (n v))
(define page-type:data (page-type 'page-type:data 0))
(define page-type:index (page-type 'page-type:index 1))
(define page-type:dictionary (page-type 'page-type:dictionary 2))
(define page-type:data-v2 (page-type 'page-type:data-v2 3))
(define page-type:bloom-filter (page-type 'page-type:bloom-filter 4))
(define (page-type->symbol e)
  (page-type-n e))
(define (page-type->integer e)
  (page-type-v e))
(define (integer->page-type n)
  (match n
    [0 page-type:data]
    [1 page-type:index]
    [2 page-type:dictionary]
    [3 page-type:data-v2]
    [4 page-type:bloom-filter]
    [else (error "unknown value for enum page-type: " n)]))

(struct boundary-order (n v))
(define boundary-order:unordered (boundary-order 'boundary-order:unordered 0))
(define boundary-order:ascending (boundary-order 'boundary-order:ascending 1))
(define boundary-order:descending (boundary-order 'boundary-order:descending 2))
(define (boundary-order->symbol e)
  (boundary-order-n e))
(define (boundary-order->integer e)
  (boundary-order-v e))
(define (integer->boundary-order n)
  (match n
    [0 boundary-order:unordered]
    [1 boundary-order:ascending]
    [2 boundary-order:descending]
    [else (error "unknown value for enum boundary-order: " n)]))

(struct decimal-type (scale precision) #:transparent)
(define decimal-type/schema
  (vector
    (thrift-field 1 'scale 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'precision 'required 'none type-int32/decode #f #f)))

(struct sorting-column (column-index descending? nulls-first?) #:transparent)
(define sorting-column/schema
  (vector
    (thrift-field 1 'column-index 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'descending? 'required 'none type-bool/decode #f #f)
    (thrift-field 3 'nulls-first? 'required 'none type-bool/decode #f #f)))

(struct page-encoding-stats (page-type encoding count) #:transparent)
(define page-encoding-stats/schema
  (vector
    (thrift-field 1 'page-type 'required 'none 'page-type/decode #f #f)
    (thrift-field 2 'encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 3 'count 'required 'none type-int32/decode #f #f)))

(struct statistics (max min null-count distinct-count max-value min-value) #:transparent)
(define statistics/schema
  (vector
    (thrift-field 1 'max 'optional 'none type-binary/decode #f #f)
    (thrift-field 2 'min 'optional 'none type-binary/decode #f #f)
    (thrift-field 3 'null-count 'optional 'none type-int64/decode #f #f)
    (thrift-field 4 'distinct-count 'optional 'none type-int64/decode #f #f)
    (thrift-field 5 'max-value 'optional 'none type-binary/decode #f #f)
    (thrift-field 6 'min-value 'optional 'none type-binary/decode #f #f)))

(struct file-metadata (version schema num-rows row-groups key-value-metadata created-by column-orders) #:transparent)
(define file-metadata/schema
  (vector
    (thrift-field 1 'version 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'schema 'required 'list-of 'schema-element/decode-list #f #f)
    (thrift-field 3 'num-rows 'required 'none type-int64/decode #f #f)
    (thrift-field 4 'row-groups 'required 'list-of 'row-group/decode-list #f #f)
    (thrift-field 5 'key-value-metadata 'optional 'list-of 'key-value/decode-list #f #f)
    (thrift-field 6 'created-by 'optional 'none type-string/decode #f #f)
    (thrift-field 7 'column-orders 'optional 'list-of 'column-order/decode-list #f #f)))

(struct logical-type () #:transparent)
(define logical-type/schema
  (vector
))

(struct schema-element (type type-length repetition-type name num-children converted-type scale precision field-id logical-type) #:transparent)
(define schema-element/schema
  (vector
    (thrift-field 1 'type 'optional 'none 'parquet-type/decode #f #f)
    (thrift-field 2 'type-length 'optional 'none type-int32/decode #f #f)
    (thrift-field 3 'repetition-type 'optional 'none 'field-repetition-type/decode #f #f)
    (thrift-field 4 'name 'required 'none type-string/decode #f #f)
    (thrift-field 5 'num-children 'optional 'none type-int32/decode #f #f)
    (thrift-field 6 'converted-type 'optional 'none 'converted-type/decode #f #f)
    (thrift-field 7 'scale 'optional 'none type-int32/decode #f #f)
    (thrift-field 8 'precision 'optional 'none type-int32/decode #f #f)
    (thrift-field 9 'field-id 'optional 'none type-int32/decode #f #f)
    (thrift-field 10 'logical-type 'optional 'none 'logical-type/decode #f #f)))

(struct row-group (columns total-byte-size num-rows sorting-columns) #:transparent)
(define row-group/schema
  (vector
    (thrift-field 1 'columns 'required 'list-of 'column-chunk/decode-list #f #f)
    (thrift-field 2 'total-byte-size 'required 'none type-int64/decode #f #f)
    (thrift-field 3 'num-rows 'required 'none type-int64/decode #f #f)
    (thrift-field 4 'sorting-columns 'optional 'list-of 'sorting-column/decode-list #f #f)))

(struct column-chunk (file-path file-offset metadata offset-index-offset offset-index-length column-index-offset column-index-length) #:transparent)
(define column-chunk/schema
  (vector
    (thrift-field 1 'file-path 'optional 'none type-string/decode #f #f)
    (thrift-field 2 'file-offset 'required 'none type-int64/decode #f #f)
    (thrift-field 3 'metadata 'optional 'none 'column-metadata/decode #f #f)
    (thrift-field 4 'offset-index-offset 'optional 'none type-int64/decode #f #f)
    (thrift-field 5 'offset-index-length 'optional 'none type-int32/decode #f #f)
    (thrift-field 6 'column-index-offset 'optional 'none type-int64/decode #f #f)
    (thrift-field 7 'column-index-length 'optional 'none type-int32/decode #f #f)))

(struct page-location (offset compressed-page-size first-row-index) #:transparent)
(define page-location/schema
  (vector
    (thrift-field 1 'offset 'required 'none type-int64/decode #f #f)
    (thrift-field 2 'compressed-page-size 'required 'none type-int32/decode #f #f)
    (thrift-field 3 'first-row-index 'required 'none type-int64/decode #f #f)))

(struct offset-index (page-locations) #:transparent)
(define offset-index/schema
  (vector
    (thrift-field 1 'page-locations 'required 'list-of 'page-location/decode-list #f #f)))

(struct column-order () #:transparent)
(define column-order/schema
  (vector
))

(struct column-index (null-pages? min-values max-values boundary-order null-counts) #:transparent)
(define column-index/schema
  (vector
    (thrift-field 1 'null-pages? 'required 'list-of type-bool/decode-list #f #f)
    (thrift-field 2 'min-values 'required 'list-of type-binary/decode-list #f #f)
    (thrift-field 3 'max-values 'required 'list-of type-binary/decode-list #f #f)
    (thrift-field 4 'boundary-order 'required 'none 'boundary-order/decode #f #f)
    (thrift-field 5 'null-counts 'optional 'list-of type-int64/decode-list #f #f)))

(struct key-value (key value) #:transparent)
(define key-value/schema
  (vector
    (thrift-field 1 'key 'required 'none type-string/decode #f #f)
    (thrift-field 2 'value 'optional 'none type-string/decode #f #f)))

(struct column-metadata (type encodings path-in-schema codec num-values total-uncompressed-size total-compressed-size key-value-metadata data-page-offset index-page-offset dictionary-page-offset statistics encoding-stats bloom-filter-offset) #:transparent)
(define column-metadata/schema
  (vector
    (thrift-field 1 'type 'required 'none 'parquet-type/decode #f #f)
    (thrift-field 2 'encodings 'required 'list-of 'encoding/decode-list #f #f)
    (thrift-field 3 'path-in-schema 'required 'list-of type-string/decode-list #f #f)
    (thrift-field 4 'codec 'required 'none 'compression-codec/decode #f #f)
    (thrift-field 5 'num-values 'required 'none type-int64/decode #f #f)
    (thrift-field 6 'total-uncompressed-size 'required 'none type-int64/decode #f #f)
    (thrift-field 7 'total-compressed-size 'required 'none type-int64/decode #f #f)
    (thrift-field 8 'key-value-metadata 'optional 'list-of 'key-value/decode-list #f #f)
    (thrift-field 9 'data-page-offset 'required 'none type-int64/decode #f #f)
    (thrift-field 10 'index-page-offset 'optional 'none type-int64/decode #f #f)
    (thrift-field 11 'dictionary-page-offset 'optional 'none type-int64/decode #f #f)
    (thrift-field 12 'statistics 'optional 'none 'statistics/decode #f #f)
    (thrift-field 13 'encoding-stats 'optional 'list-of 'page-encoding-stats/decode-list #f #f)
    (thrift-field 14 'bloom-filter-offset 'optional 'none type-int64/decode #f #f)))

(struct data-page-header (num-values encoding definition-level-encoding repetition-level-encoding statistics) #:transparent)
(define data-page-header/schema
  (vector
    (thrift-field 1 'num-values 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 3 'definition-level-encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 4 'repetition-level-encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 5 'statistics 'optional 'none 'statistics/decode #f #f)))

(struct index-page-header () #:transparent)
(define index-page-header/schema
  (vector
))

(struct dictionary-page-header (num-values encoding sorted?) #:transparent)
(define dictionary-page-header/schema
  (vector
    (thrift-field 1 'num-values 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 3 'sorted? 'optional 'none type-bool/decode #f #f)))

(struct data-page-header-v2 (num-value num-nulls num-rows encoding definition_levels_byte_length repetition_levels_byte_length compressed? statistics) #:transparent)
(define data-page-header-v2/schema
  (vector
    (thrift-field 1 'num-value 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'num-nulls 'required 'none type-int32/decode #f #f)
    (thrift-field 3 'num-rows 'required 'none type-int32/decode #f #f)
    (thrift-field 4 'encoding 'required 'none 'encoding/decode #f #f)
    (thrift-field 5 'definition_levels_byte_length 'required 'none type-int32/decode #f #f)
    (thrift-field 6 'repetition_levels_byte_length 'required 'none type-int32/decode #f #f)
    (thrift-field 7 'compressed? 'optional 'none type-bool/decode #f #f)
    (thrift-field 8 'statistics 'optional 'none 'statistics/decode #f #f)))

(struct split-block-algorithm () #:transparent)
(define split-block-algorithm/schema
  (vector
))

(struct bloom-filter-algorithm (BLOCK) #:transparent)
(define bloom-filter-algorithm/schema
  (vector
    (thrift-field 1 'BLOCK 'default 'none 'split-block-algorithm/decode #f #f)))

(struct murmur-3 () #:transparent)
(define murmur-3/schema
  (vector
))

(struct bloom-filter-hash (MURMUR3) #:transparent)
(define bloom-filter-hash/schema
  (vector
    (thrift-field 1 'MURMUR3 'default 'none 'murmur-3/decode #f #f)))

(struct bloom-filter-page-header (num-bytes algorithm hash) #:transparent)
(define bloom-filter-page-header/schema
  (vector
    (thrift-field 1 'num-bytes 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'algorithm 'required 'none 'bloom-filter-algorithm/decode #f #f)
    (thrift-field 3 'hash 'required 'none 'bloom-filter-hash/decode #f #f)))

(struct page-header (type uncompressed-page-size compressed-page-size crc data-page-header index-page-header dictionary-page-header data-page-header-v2 bloom-filter-page-header) #:transparent)
(define page-header/schema
  (vector
    (thrift-field 1 'type 'required 'none 'page-type/decode #f #f)
    (thrift-field 2 'uncompressed-page-size 'required 'none type-int32/decode #f #f)
    (thrift-field 3 'compressed-page-size 'required 'none type-int32/decode #f #f)
    (thrift-field 4 'crc 'optional 'none type-int32/decode #f #f)
    (thrift-field 5 'data-page-header 'optional 'none 'data-page-header/decode #f #f)
    (thrift-field 6 'index-page-header 'optional 'none 'index-page-header/decode #f #f)
    (thrift-field 7 'dictionary-page-header 'optional 'none 'dictionary-page-header/decode #f #f)
    (thrift-field 8 'data-page-header-v2 'optional 'none 'data-page-header-v2/decode #f #f)
    (thrift-field 9 'bloom-filter-page-header 'optional 'none 'bloom-filter-page-header/decode #f #f)))

