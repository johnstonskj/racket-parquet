#lang scribble/manual
@;
@; Generated namespace parquet
@;                from ../format.rkt
@;                  on Saturday, November 3rd, 2018
@;                  by thrift/idl/generator v0.1
@;


@(require racket/sandbox scribble/core scribble/eval
          (for-label "parquet.rkt"))

@title[]{Thrift Namespace parquet}

@defproc[(parquet-type? [v any/c]) boolean?]

@deftogether[(
  @defthing[parquet-type:boolean parquet-type?]
  @defthing[parquet-type:int32 parquet-type?]
  @defthing[parquet-type:type-int64 parquet-type?]
  @defthing[parquet-type:int96 parquet-type?]
  @defthing[parquet-type:float parquet-type?]
  @defthing[parquet-type:double parquet-type?]
  @defthing[parquet-type:byte-array parquet-type?]
  @defthing[parquet-type:fixed-len-byte-arrary parquet-type?]
)]

@defproc[(converted-type? [v any/c]) boolean?]

@deftogether[(
  @defthing[converted-type:utf8 converted-type?]
  @defthing[converted-type:map converted-type?]
  @defthing[converted-type:map-key converted-type?]
  @defthing[converted-type:list converted-type?]
  @defthing[converted-type:enum converted-type?]
  @defthing[converted-type:decimal converted-type?]
  @defthing[converted-type:date converted-type?]
  @defthing[converted-type:time-millis converted-type?]
  @defthing[converted-type:time-micros converted-type?]
  @defthing[converted-type:timestamp-millis converted-type?]
  @defthing[converted-type:timestamp-micros converted-type?]
  @defthing[converted-type:uint8 converted-type?]
  @defthing[converted-type:uint16 converted-type?]
  @defthing[converted-type:uint32 converted-type?]
  @defthing[converted-type:uint64 converted-type?]
  @defthing[converted-type:int8 converted-type?]
  @defthing[converted-type:int16 converted-type?]
  @defthing[converted-type:int32 converted-type?]
  @defthing[converted-type:int64 converted-type?]
  @defthing[converted-type:json converted-type?]
  @defthing[converted-type:bson converted-type?]
  @defthing[converted-type:interval converted-type?]
)]

@defproc[(field-repetition-type? [v any/c]) boolean?]

@deftogether[(
  @defthing[field-repetition-type:required field-repetition-type?]
  @defthing[field-repetition-type:optional field-repetition-type?]
  @defthing[field-repetition-type:repeated field-repetition-type?]
)]

@defproc[(encoding? [v any/c]) boolean?]

@deftogether[(
  @defthing[encoding:plain encoding?]
  @defthing[encoding:group-var-int encoding?]
  @defthing[encoding:plain-dictionary encoding?]
  @defthing[encoding:rle encoding?]
  @defthing[encoding:bit-packed encoding?]
  @defthing[encoding:delta-bit-packed encoding?]
  @defthing[encoding:delta-length-byte-array encoding?]
  @defthing[encoding:delta-byte-array encoding?]
  @defthing[encoding:rle-dictionary encoding?]
)]

@defproc[(compression-codec? [v any/c]) boolean?]

@deftogether[(
  @defthing[compression-codec:uncompressed compression-codec?]
  @defthing[compression-codec:snappy compression-codec?]
  @defthing[compression-codec:gzip compression-codec?]
  @defthing[compression-codec:lzo compression-codec?]
  @defthing[compression-codec:brotli compression-codec?]
  @defthing[compression-codec:lz4 compression-codec?]
  @defthing[compression-codec:zstd compression-codec?]
)]

@defproc[(page-type? [v any/c]) boolean?]

@deftogether[(
  @defthing[page-type:data page-type?]
  @defthing[page-type:index page-type?]
  @defthing[page-type:dictionary page-type?]
  @defthing[page-type:data-v2 page-type?]
  @defthing[page-type:bloom-filter page-type?]
)]

@defproc[(boundary-order? [v any/c]) boolean?]

@deftogether[(
  @defthing[boundary-order:unordered boundary-order?]
  @defthing[boundary-order:ascending boundary-order?]
  @defthing[boundary-order:descending boundary-order?]
)]

@defstruct*[decimal-type (
             [scale type-int32]
             [precision type-int32]
)]

@defstruct*[sorting-column (
             [column-index type-int32]
             [descending? type-bool]
             [nulls-first? type-bool]
)]

@defstruct*[page-encoding-stats (
             [page-type page-type]
             [encoding encoding]
             [count type-int32]
)]

@defstruct*[statistics (
             [max type-binary]
             [min type-binary]
             [null-count type-int64]
             [distinct-count type-int64]
             [max-value type-binary]
             [min-value type-binary]
)]

@defstruct*[file-metadata (
             [version type-int32]
             [schema schema-element]
             [num-rows type-int64]
             [row-groups row-group]
             [key-value-metadata key-value]
             [created-by type-string]
             [column-orders column-order]
)]

@defstruct*[logical-type (
)]

@defstruct*[schema-element (
             [type parquet-type]
             [type-length type-int32]
             [repetition-type field-repetition-type]
             [name type-string]
             [num-children type-int32]
             [converted-type converted-type]
             [scale type-int32]
             [precision type-int32]
             [field-id type-int32]
             [logical-type logical-type]
)]

@defstruct*[row-group (
             [columns column-chunk]
             [total-byte-size type-int64]
             [num-rows type-int64]
             [sorting-columns sorting-column]
)]

@defstruct*[column-chunk (
             [file-path type-string]
             [file-offset type-int64]
             [metadata column-metadata]
             [offset-index-offset type-int64]
             [offset-index-length type-int32]
             [column-index-offset type-int64]
             [column-index-length type-int32]
)]

@defstruct*[page-location (
             [offset type-int64]
             [compressed-page-size type-int32]
             [first-row-index type-int64]
)]

@defstruct*[offset-index (
             [page-locations page-location]
)]

@defstruct*[column-order (
)]

@defstruct*[column-index (
             [null-pages? type-bool]
             [min-values type-binary]
             [max-values type-binary]
             [boundary-order boundary-order]
             [null-counts type-int64]
)]

@defstruct*[key-value (
             [key type-string]
             [value type-string]
)]

@defstruct*[column-metadata (
             [type parquet-type]
             [encodings encoding]
             [path-in-schema type-string]
             [codec compression-codec]
             [num-values type-int64]
             [total-uncompressed-size type-int64]
             [total-compressed-size type-int64]
             [key-value-metadata key-value]
             [data-page-offset type-int64]
             [index-page-offset type-int64]
             [dictionary-page-offset type-int64]
             [statistics statistics]
             [encoding-stats page-encoding-stats]
             [bloom-filter-offset type-int64]
)]

@defstruct*[data-page-header (
             [num-values type-int32]
             [encoding encoding]
             [definition-level-encoding encoding]
             [repetition-level-encoding encoding]
             [statistics statistics]
)]

@defstruct*[index-page-header (
)]

@defstruct*[dictionary-page-header (
             [num-values type-int32]
             [encoding encoding]
             [sorted? type-bool]
)]

@defstruct*[data-page-header-v2 (
             [num-value type-int32]
             [num-nulls type-int32]
             [num-rows type-int32]
             [encoding encoding]
             [definition_levels_byte_length type-int32]
             [repetition_levels_byte_length type-int32]
             [compressed? type-bool]
             [statistics statistics]
)]

@defstruct*[split-block-algorithm (
)]

@defstruct*[bloom-filter-algorithm (
             [BLOCK split-block-algorithm]
)]

@defstruct*[murmur-3 (
)]

@defstruct*[bloom-filter-hash (
             [MURMUR3 murmur-3]
)]

@defstruct*[bloom-filter-page-header (
             [num-bytes type-int32]
             [algorithm bloom-filter-algorithm]
             [hash bloom-filter-hash]
)]

@defstruct*[page-header (
             [type page-type]
             [uncompressed-page-size type-int32]
             [compressed-page-size type-int32]
             [crc type-int32]
             [data-page-header data-page-header]
             [index-page-header index-page-header]
             [dictionary-page-header dictionary-page-header]
             [data-page-header-v2 data-page-header-v2]
             [bloom-filter-page-header bloom-filter-page-header]
)]

