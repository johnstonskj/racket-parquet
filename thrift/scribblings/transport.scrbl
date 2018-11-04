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

@defproc[(transport-read-byte
          [t transport?])
         byte?]{
TBD
}
  
@defproc[(transport-read-bytes
          [t transport?]
          [amt exact-positive-integer?])
         bytes?]{
TBD
}
  
@defproc[(transport-write-byte
          [t transport?]
          [b byte?])
         void?]{
TBD
}
  
@defproc[(transport-write-bytes
          [t transport?]
          [bs bytes?]
          [start-pos exact-nonnegative-integer? 0]
          [end-pos exact-nonnegative-integer?])
         void?]{
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

@defproc[(flush-transport
          [t output-transport?])
         void?]{
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