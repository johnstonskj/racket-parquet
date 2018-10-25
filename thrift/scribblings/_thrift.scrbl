#lang scribble/manual

@(require racket/sandbox
          scribble/core
          scribble/eval
          (for-label racket/base
                     racket/contract
                     thrift))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/string
                                thrift)))

@;{============================================================================}

@title[]{Module thrift.}
@defmodule[thrift]

Support for Thrift encoding

@examples[ #:eval example-eval
(require thrift)
; add more here.
]

@;{============================================================================}

@;Add your API documentation here...


Document  - TBD
