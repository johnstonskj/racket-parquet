#lang scribble/manual

@(require racket/sandbox
          scribble/core
          scribble/eval
          parquet
          (for-label racket/base
                     racket/contract
                     parquet))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/string
                                parquet)))

@;{============================================================================}

@title[]{Collection parquet.}
@defmodule[parquet]

TBD.

@;{============================================================================}
@section[]{File Format}

@racket[parquet/format]

@racketblock[
(define-thrift-struct file-metadata
  ([1 version required type-int32]
   [2 schema required list-of schema-element]
   [3 num-rows required type-int64]
   [4 row-groups required list-of row-group]
   [5 key-value-metadata optional list-of key-value]
   [6 created-by optional type-string]
   [7 column-orders optional list-of column-order]))
]


@;{============================================================================}
@section[]{Generated Content}

@racketblock[
(struct file-metadata (version schema num-rows row-groups key-value-metadata
                       created-by column-orders) #:transparent)

(define file-metadata/schema
  (vector
    (thrift-field 1 'version 'required 'none type-int32/decode #f #f)
    (thrift-field 2 'schema 'required 'list-of 'schema-element/decode-list #f #f)
    (thrift-field 3 'num-rows 'required 'none type-int64/decode #f #f)
    (thrift-field 4 'row-groups 'required 'list-of 'row-group/decode-list #f #f)
    (thrift-field 5 'key-value-metadata 'optional 'list-of 'key-value/decode-list #f #f)
    (thrift-field 6 'created-by 'optional 'none type-string/decode #f #f)
    (thrift-field 7 'column-orders 'optional 'list-of 'column-order/decode-list #f #f)))

(define (file-metadata/decode decoder)
  (log-parquet-info "decoding file-metadata from thrift")
  (decode-a-struct decoder file-metadata file-metadata/reverse-schema))

(define (file-metadata/decode-list decoder)
  (log-parquet-info "decoding list of file-metadata from thrift")
  (decode-a-list decoder file-metadata/decode))

(define (file-metadata/decode-set decoder)
  (log-parquet-info "decoding set of file-metadata from thrift")
  (list->set (decode-a-list decoder file-metadata/decode)))
]