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

@title[]{Thrift Transport Support.}

Support for Thrift transports

@examples[ #:eval example-eval
(require thrift)
; add more here.
]

@;{============================================================================}
@section[]{Transport Common}
@defmodule[thrift/transport/common]

@defstruct*[transport
            ([source string?]
             [port port?])]{
TBD
}

@defproc[(input-transport?
          [t transport?])
         boolean?]{
TBD
}
  
@defproc[(output-transport?
          [t transport?])
         boolean?]{
TBD
}

@defproc[(close-transport
          [t transport?])
         any/c]{
TBD
}


@;{============================================================================}
@section[]{File Transport}
@defmodule[thrift/transport/file]

@defproc[(open-input-file-transport
          [file-path string?])
         transport?]{
TBD
}

@defproc[(open-output-file-transport
          [file-path string?])
         transport?]{
TBD
}

@defproc[(transport-file-size
          [t transport?])
         exact-nonnegative-integer?]{
TBD
}

@defproc*[([(transport-file-position
             [t transport?])
            any/c]
           [(transport-file-position
             [t transport?]
             [pos exact-nonnegative-integer?])
            any/c])]{
TBD
}