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

@title[]{Thrift Processor Support}

Support for Thrift protocol encodings

@examples[ #:eval example-eval
(require thrift)

(define (my-processor in out)
  transport-processor/c
  #f)
]

@;{============================================================================}
@section[]{Processor Types}
@defmodule[thrift/processor/common]

@racketblock[
(define transport-processor/c
  (-> input-transport? output-transport? boolean?))

(define protocol-processor/c
  (-> decoder? encoder? boolean?))
]