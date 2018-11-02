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

@title[]{Thrift IDL Support.}

Support for Thrift format definitions

@examples[ #:eval example-eval
(require thrift
         thrift/idl/language)

(define-thrift-namespace parquet)

(define-thrift-enum
  parquet-type 0
  (boolean
   int32
   int64
   int96 ; deprecated
   float
   double
   byte-array
   fixed-len-byte-arrary))

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
@section[]{Type System}
@defmodule[thrift/idl/common]

@subsection[]{Core Types}

@defproc[(type? [v any/c]) boolean?]

@deftogether[(@defthing[type-bool type?]
               @defthing[type-byte type?]
               @defthing[type-int16 type?]
               @defthing[type-int32 type?]
               @defthing[type-int64 type?]
               @defthing[type-double type?]
               @defthing[type-string type?]
               @defthing[type-binary type?]
               @defthing[type-struct type?]
               @defthing[type-list type?]
               @defthing[type-set type?]
               @defthing[type-map type?])]{
TBD
}

@subsection[]{Field Type Information}

@defproc[(required-type? [v any/c]) boolean?]

@deftogether[(@defthing[required required-type?]
               @defthing[optional required-type?]
               @defthing[default required-type?])]{
TBD
}

@defproc[(container-type? [v any/c]) boolean?]

@deftogether[(@defthing[list-of container-type?]
               @defthing[set-of container-type?]
               @defthing[map-of container-type?]
               @defthing[none container-type?])]{
TBD
}

@defstruct*[thrift-field
            ([id identifier?]
             [name string?]
             [required symbol?]
             [container symbol?]
             [major-type symbol?]
             [minor-type symbol?]
             [position exact-nonnegative-integer?])]{
TBD
}

@;{============================================================================}
@section[]{IDL Language}
@defmodule[thrift/idl/language]

@defform[(define-thrift-namespace namespace)
         #:contracts ([namespace string?])]{
TBD
}

@defform[(define-thrift-enum id maybe-start value ...)
         #:grammar
         [(id string?)
          (maybe-start (code:line)
                       exact-nonnegative-integer?)
          (value-expr identifier?
                      [identifier? exact-nonnegative-integer?])
 ]]{
TBD
}

@defform[#:literals (map-of)
         (define-thrift-struct [id string?] field ...)
         #:grammar
         [(field (index name maybe-req maybe-con elem-type)
                 (index name maybe-req map-of elem-type key-type))
          (maybe-required (code:line)
                          required-type?)
          (maybe-container (code:line)
                           container-type?)]
         #:contracts ([index exact-nonnegative-integer?]
                      [name identifier?]
                      [elem-type identifier?]
                      [key-type identifier?])]{
TBD
}

@;{============================================================================}
@section[]{Code Generator}
@defmodule[thrift/idl/generator]

@defproc[(process-file
          [file-path string?]
          [over-write? boolean? #f])
         void?]{
TBD
}

@subsection[]{Command-Line Launcher}

@verbatim|{
$ rthrift 
}|