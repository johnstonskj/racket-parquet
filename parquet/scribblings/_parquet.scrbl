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

@title[]{Module parquet.}
@defmodule[parquet]

Read/Write Apache Parquet format files

@examples[ #:eval example-eval
(require parquet)
; add more here.
]

@;{============================================================================}

@;Add your API documentation here...


Document  - TBD
