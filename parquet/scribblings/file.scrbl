#lang scribble/manual

@(require racket/sandbox
          scribble/core
          scribble/eval
          parquet
          (for-label racket/base
                     racket/contract
                     parquet
                     thrift))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/string
                                parquet/file)))

@;{============================================================================}

@title[]{Module file.}
@defmodule[parquet/file]

Read/Write Apache Parquet format files.

@examples[ #:eval example-eval
(require parquet/file
         parquet/generated/parquet
         thrift/transport/common)

(define tport (open-input-parquet-file "../test-data/nation.impala.parquet"))
(define metadata (read-metadata tport))

(displayln (format "File Metadata: ~a, Version: ~a, Num Rows: ~a"
                   (transport-source tport)
                   (file-metadata-version metadata)
                   (file-metadata-num-rows metadata)))

(close-parquet-file tport)
]

@;{============================================================================}
@section[]{File Handling}

@defproc[(open-input-parquet-file
          [file-path string?])
         transport?]{
TBD
}

@defproc[(close-parquet-file
          [transport transport?])
         void?]{
TBD
}

@;{============================================================================}
@section[]{Decoding}

@defproc[(read-metadata
          [transport transport?])
         file-metadata?]{
TBD
}
