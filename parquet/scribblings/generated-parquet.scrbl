#lang scribble/manual
@;
@; Generated namespace parquet
@;                from ../parquet/format.rkt
@;                  on Sunday, November 4th, 2018
@;                  by thrift/idl/generator v0.1
@;


@(require racket/sandbox scribble/core scribble/eval
          (for-label parquet))

@title[]{Generated Thrift Namespace parquet}
@defmodule[parquet/generated/parquet]

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
             [page-type page-type?]
             [encoding encoding?]
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
             [schema schema-element?]
             [num-rows type-int64]
             [row-groups row-group?]
             [key-value-metadata key-value?]
             [created-by type-string]
             [column-orders column-order?]
)]

@defstruct*[logical-type (
)]

@defstruct*[schema-element (
             [type parquet-type?]
             [type-length type-int32]
             [repetition-type field-repetition-type?]
             [name type-string]
             [num-children type-int32]
             [converted-type converted-type?]
             [scale type-int32]
             [precision type-int32]
             [field-id type-int32]
             [logical-type logical-type?]
)]

@defstruct*[row-group (
             [columns column-chunk?]
             [total-byte-size type-int64]
             [num-rows type-int64]
             [sorting-columns sorting-column?]
)]

@defstruct*[column-chunk (
             [file-path type-string]
             [file-offset type-int64]
             [metadata column-metadata?]
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
             [page-locations page-location?]
)]

@defstruct*[column-order (
)]

@defstruct*[column-index (
             [null-pages? type-bool]
             [min-values type-binary]
             [max-values type-binary]
             [boundary-order boundary-order?]
             [null-counts type-int64]
)]

@defstruct*[key-value (
             [key type-string]
             [value type-string]
)]

@defstruct*[column-metadata (
             [type parquet-type?]
             [encodings encoding?]
             [path-in-schema type-string]
             [codec compression-codec?]
             [num-values type-int64]
             [total-uncompressed-size type-int64]
             [total-compressed-size type-int64]
             [key-value-metadata key-value?]
             [data-page-offset type-int64]
             [index-page-offset type-int64]
             [dictionary-page-offset type-int64]
             [statistics statistics?]
             [encoding-stats page-encoding-stats?]
             [bloom-filter-offset type-int64]
)]

@defstruct*[data-page-header (
             [num-values type-int32]
             [encoding encoding?]
             [definition-level-encoding encoding?]
             [repetition-level-encoding encoding?]
             [statistics statistics?]
)]

@defstruct*[index-page-header (
)]

@defstruct*[dictionary-page-header (
             [num-values type-int32]
             [encoding encoding?]
             [sorted? type-bool]
)]

@defstruct*[data-page-header-v2 (
             [num-value type-int32]
             [num-nulls type-int32]
             [num-rows type-int32]
             [encoding encoding?]
             [definition_levels_byte_length type-int32]
             [repetition_levels_byte_length type-int32]
             [compressed? type-bool]
             [statistics statistics?]
)]

@defstruct*[split-block-algorithm (
)]

@defstruct*[bloom-filter-algorithm (
             [BLOCK split-block-algorithm?]
)]

@defstruct*[murmur-3 (
)]

@defstruct*[bloom-filter-hash (
             [MURMUR3 murmur-3?]
)]

@defstruct*[bloom-filter-page-header (
             [num-bytes type-int32]
             [algorithm bloom-filter-algorithm?]
             [hash bloom-filter-hash?]
)]

@defstruct*[page-header (
             [type page-type?]
             [uncompressed-page-size type-int32]
             [compressed-page-size type-int32]
             [crc type-int32]
             [data-page-header data-page-header?]
             [index-page-header index-page-header?]
             [dictionary-page-header dictionary-page-header?]
             [data-page-header-v2 data-page-header-v2?]
             [bloom-filter-page-header bloom-filter-page-header?]
)]

@section[]{Enumeration Conversion}

@deftogether[(
  @defproc[(boundary-order->symbol [e boundary-order?]) symbol?]
  @defproc[(boundary-order->integer [e boundary-order?]) exact-nonnegative-integer?]
  @defproc[(integer->boundary-order [n exact-nonnegative-integer?]) boundary-order?]
)]

@deftogether[(
  @defproc[(page-type->symbol [e page-type?]) symbol?]
  @defproc[(page-type->integer [e page-type?]) exact-nonnegative-integer?]
  @defproc[(integer->page-type [n exact-nonnegative-integer?]) page-type?]
)]

@deftogether[(
  @defproc[(compression-codec->symbol [e compression-codec?]) symbol?]
  @defproc[(compression-codec->integer [e compression-codec?]) exact-nonnegative-integer?]
  @defproc[(integer->compression-codec [n exact-nonnegative-integer?]) compression-codec?]
)]

@deftogether[(
  @defproc[(encoding->symbol [e encoding?]) symbol?]
  @defproc[(encoding->integer [e encoding?]) exact-nonnegative-integer?]
  @defproc[(integer->encoding [n exact-nonnegative-integer?]) encoding?]
)]

@deftogether[(
  @defproc[(field-repetition-type->symbol [e field-repetition-type?]) symbol?]
  @defproc[(field-repetition-type->integer [e field-repetition-type?]) exact-nonnegative-integer?]
  @defproc[(integer->field-repetition-type [n exact-nonnegative-integer?]) field-repetition-type?]
)]

@deftogether[(
  @defproc[(converted-type->symbol [e converted-type?]) symbol?]
  @defproc[(converted-type->integer [e converted-type?]) exact-nonnegative-integer?]
  @defproc[(integer->converted-type [n exact-nonnegative-integer?]) converted-type?]
)]

@deftogether[(
  @defproc[(parquet-type->symbol [e parquet-type?]) symbol?]
  @defproc[(parquet-type->integer [e parquet-type?]) exact-nonnegative-integer?]
  @defproc[(integer->parquet-type [n exact-nonnegative-integer?]) parquet-type?]
)]

@section[]{Type Decoders}
@defmodule[parquet/generated/parquet-decode]

@deftogether[(
  @defproc[(boundary-order/decode [d decoder?]) boundary-order?]
  @defproc[(boundary-order/decode-list [d decoder?]) (listof boundary-order?)]
)]

@deftogether[(
  @defproc[(page-type/decode [d decoder?]) page-type?]
  @defproc[(page-type/decode-list [d decoder?]) (listof page-type?)]
)]

@deftogether[(
  @defproc[(compression-codec/decode [d decoder?]) compression-codec?]
  @defproc[(compression-codec/decode-list [d decoder?]) (listof compression-codec?)]
)]

@deftogether[(
  @defproc[(encoding/decode [d decoder?]) encoding?]
  @defproc[(encoding/decode-list [d decoder?]) (listof encoding?)]
)]

@deftogether[(
  @defproc[(field-repetition-type/decode [d decoder?]) field-repetition-type?]
  @defproc[(field-repetition-type/decode-list [d decoder?]) (listof field-repetition-type?)]
)]

@deftogether[(
  @defproc[(converted-type/decode [d decoder?]) converted-type?]
  @defproc[(converted-type/decode-list [d decoder?]) (listof converted-type?)]
)]

@deftogether[(
  @defproc[(parquet-type/decode [d decoder?]) parquet-type?]
  @defproc[(parquet-type/decode-list [d decoder?]) (listof parquet-type?)]
)]

@deftogether[(
  @defproc[(page-header/decode [d decoder?]) page-header?]
  @defproc[(page-header/decode-list [d decoder?]) (listof page-header?)]
  @defproc[(page-header/decode-set [d decoder?]) (setof page-header?)]
)]

@deftogether[(
  @defproc[(bloom-filter-page-header/decode [d decoder?]) bloom-filter-page-header?]
  @defproc[(bloom-filter-page-header/decode-list [d decoder?]) (listof bloom-filter-page-header?)]
  @defproc[(bloom-filter-page-header/decode-set [d decoder?]) (setof bloom-filter-page-header?)]
)]

@deftogether[(
  @defproc[(bloom-filter-hash/decode [d decoder?]) bloom-filter-hash?]
  @defproc[(bloom-filter-hash/decode-list [d decoder?]) (listof bloom-filter-hash?)]
  @defproc[(bloom-filter-hash/decode-set [d decoder?]) (setof bloom-filter-hash?)]
)]

@deftogether[(
  @defproc[(murmur-3/decode [d decoder?]) murmur-3?]
  @defproc[(murmur-3/decode-list [d decoder?]) (listof murmur-3?)]
  @defproc[(murmur-3/decode-set [d decoder?]) (setof murmur-3?)]
)]

@deftogether[(
  @defproc[(bloom-filter-algorithm/decode [d decoder?]) bloom-filter-algorithm?]
  @defproc[(bloom-filter-algorithm/decode-list [d decoder?]) (listof bloom-filter-algorithm?)]
  @defproc[(bloom-filter-algorithm/decode-set [d decoder?]) (setof bloom-filter-algorithm?)]
)]

@deftogether[(
  @defproc[(split-block-algorithm/decode [d decoder?]) split-block-algorithm?]
  @defproc[(split-block-algorithm/decode-list [d decoder?]) (listof split-block-algorithm?)]
  @defproc[(split-block-algorithm/decode-set [d decoder?]) (setof split-block-algorithm?)]
)]

@deftogether[(
  @defproc[(data-page-header-v2/decode [d decoder?]) data-page-header-v2?]
  @defproc[(data-page-header-v2/decode-list [d decoder?]) (listof data-page-header-v2?)]
  @defproc[(data-page-header-v2/decode-set [d decoder?]) (setof data-page-header-v2?)]
)]

@deftogether[(
  @defproc[(dictionary-page-header/decode [d decoder?]) dictionary-page-header?]
  @defproc[(dictionary-page-header/decode-list [d decoder?]) (listof dictionary-page-header?)]
  @defproc[(dictionary-page-header/decode-set [d decoder?]) (setof dictionary-page-header?)]
)]

@deftogether[(
  @defproc[(index-page-header/decode [d decoder?]) index-page-header?]
  @defproc[(index-page-header/decode-list [d decoder?]) (listof index-page-header?)]
  @defproc[(index-page-header/decode-set [d decoder?]) (setof index-page-header?)]
)]

@deftogether[(
  @defproc[(data-page-header/decode [d decoder?]) data-page-header?]
  @defproc[(data-page-header/decode-list [d decoder?]) (listof data-page-header?)]
  @defproc[(data-page-header/decode-set [d decoder?]) (setof data-page-header?)]
)]

@deftogether[(
  @defproc[(column-metadata/decode [d decoder?]) column-metadata?]
  @defproc[(column-metadata/decode-list [d decoder?]) (listof column-metadata?)]
  @defproc[(column-metadata/decode-set [d decoder?]) (setof column-metadata?)]
)]

@deftogether[(
  @defproc[(key-value/decode [d decoder?]) key-value?]
  @defproc[(key-value/decode-list [d decoder?]) (listof key-value?)]
  @defproc[(key-value/decode-set [d decoder?]) (setof key-value?)]
)]

@deftogether[(
  @defproc[(column-index/decode [d decoder?]) column-index?]
  @defproc[(column-index/decode-list [d decoder?]) (listof column-index?)]
  @defproc[(column-index/decode-set [d decoder?]) (setof column-index?)]
)]

@deftogether[(
  @defproc[(column-order/decode [d decoder?]) column-order?]
  @defproc[(column-order/decode-list [d decoder?]) (listof column-order?)]
  @defproc[(column-order/decode-set [d decoder?]) (setof column-order?)]
)]

@deftogether[(
  @defproc[(offset-index/decode [d decoder?]) offset-index?]
  @defproc[(offset-index/decode-list [d decoder?]) (listof offset-index?)]
  @defproc[(offset-index/decode-set [d decoder?]) (setof offset-index?)]
)]

@deftogether[(
  @defproc[(page-location/decode [d decoder?]) page-location?]
  @defproc[(page-location/decode-list [d decoder?]) (listof page-location?)]
  @defproc[(page-location/decode-set [d decoder?]) (setof page-location?)]
)]

@deftogether[(
  @defproc[(column-chunk/decode [d decoder?]) column-chunk?]
  @defproc[(column-chunk/decode-list [d decoder?]) (listof column-chunk?)]
  @defproc[(column-chunk/decode-set [d decoder?]) (setof column-chunk?)]
)]

@deftogether[(
  @defproc[(row-group/decode [d decoder?]) row-group?]
  @defproc[(row-group/decode-list [d decoder?]) (listof row-group?)]
  @defproc[(row-group/decode-set [d decoder?]) (setof row-group?)]
)]

@deftogether[(
  @defproc[(schema-element/decode [d decoder?]) schema-element?]
  @defproc[(schema-element/decode-list [d decoder?]) (listof schema-element?)]
  @defproc[(schema-element/decode-set [d decoder?]) (setof schema-element?)]
)]

@deftogether[(
  @defproc[(logical-type/decode [d decoder?]) logical-type?]
  @defproc[(logical-type/decode-list [d decoder?]) (listof logical-type?)]
  @defproc[(logical-type/decode-set [d decoder?]) (setof logical-type?)]
)]

@deftogether[(
  @defproc[(file-metadata/decode [d decoder?]) file-metadata?]
  @defproc[(file-metadata/decode-list [d decoder?]) (listof file-metadata?)]
  @defproc[(file-metadata/decode-set [d decoder?]) (setof file-metadata?)]
)]

@deftogether[(
  @defproc[(statistics/decode [d decoder?]) statistics?]
  @defproc[(statistics/decode-list [d decoder?]) (listof statistics?)]
  @defproc[(statistics/decode-set [d decoder?]) (setof statistics?)]
)]

@deftogether[(
  @defproc[(page-encoding-stats/decode [d decoder?]) page-encoding-stats?]
  @defproc[(page-encoding-stats/decode-list [d decoder?]) (listof page-encoding-stats?)]
  @defproc[(page-encoding-stats/decode-set [d decoder?]) (setof page-encoding-stats?)]
)]

@deftogether[(
  @defproc[(sorting-column/decode [d decoder?]) sorting-column?]
  @defproc[(sorting-column/decode-list [d decoder?]) (listof sorting-column?)]
  @defproc[(sorting-column/decode-set [d decoder?]) (setof sorting-column?)]
)]

@deftogether[(
  @defproc[(decimal-type/decode [d decoder?]) decimal-type?]
  @defproc[(decimal-type/decode-list [d decoder?]) (listof decimal-type?)]
  @defproc[(decimal-type/decode-set [d decoder?]) (setof decimal-type?)]
)]

