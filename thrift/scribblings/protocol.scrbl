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

@title[]{Thrift Protocol Support}

Support for Thrift protocol encodings

@examples[ #:eval example-eval
(require thrift)
; add more here.
]

@;{============================================================================}
@section[]{Protocol Common}
@defmodule[thrift/protocol/common]

@defstruct*[message-header
            ([name string?]
             [type type?]
             [sequence-id integer?])]{
TBD
}

@defstruct*[field-header
            ([name string?]
             [type type?]
             [id exact-nonnegative-integer?])]{
 TBD
}

@defstruct*[map-header
            ([key-type type?]
             [element-type type?]
             [length exact-nonnegative-integer?])]{
TBD
}

@defstruct*[list-or-set
            ([element-type type?]
             [length exact-nonnegative-integer?])]{
TBD
}

@defstruct*[encoder
           ([message-begin (-> message-header? any/c)]
            [message-end (-> any/c)]
            [struct-begin (-> any/c)]
            [struct-end (-> any/c)]
            [field-begin (-> field-header any/c)]
            [field-end (-> any/c)]
            [field-stop (-> any/c)]
            [map-begin (-> map-header? any/c)]
            [map-end (-> any/c)]
            [list-begin (-> list-or-set? any/c)]
            [list-end (-> any/c)]
            [set-begin (-> list-or-set? any/c)]
            [set-end (-> any/c)]
            [boolean (-> boolean? any/c)]
            [byte (-> byte? any/c)]
            [bytes (-> bytes? any/c)]
            [int16 (-> integer? any/c)]
            [int32 (-> integer? any/c)]
            [int64 (-> integer? any/c)]
            [double (-> flonum? any/c)]
            [string (-> string? any/c)])]{
TBD
}

@defstruct*[decoder
           ([message-begin (-> message-header?)]
            [message-end (-> void?)]
            [struct-begin (-> void?)]
            [struct-end (-> void?)]
            [field-begin (-> field-header?)]
            [field-end (-> void?)]
            [map-begin(-> map-header?)]
            [map-end (-> void?)]
            [list-begin (-> list-or-set?)]
            [list-end (-> void?)]
            [set-begin (-> list-or-set?)]
            [set-end (-> void?)]
            [boolean(-> boolean?)]
            [byte (-> byte?)]
            [bytes (-> bytes?)]
            [int16 (-> integer?)]
            [int32 (-> integer?)]
            [int64 (-> integer?)]
            [double (-> flonum?)]
            [string (-> string?)])]{
TBD
}

@;{============================================================================}
@section[]{Plain Protocol}
@defmodule[thrift/protocol/plain]

@defproc[(get-protocol-encoder
          [t  transport?])
         (or/c encoder? #f)]{
 TBD
}

@defproc[(get-protocol-decoder
          [t  transport?])
         (or/c decoder? #f)]{
 TBD
}

@defproc[(read-plain-integer
          [t (or/c transport? port?)]
          [width-in-bytes exact-nonnegative-integer?])
         integer?]{
 TBD
}

@;{============================================================================}
@section[]{Compact Protocol}
@defmodule[thrift/protocol/compact]

@defproc[(get-protocol-encoder
          [t  transport?])
         (or/c encoder? #f)]{
 TBD
}

@defproc[(get-protocol-decoder
          [t  transport?])
         (or/c decoder? #f)]{
 TBD
}

@;{============================================================================}
@section[]{Decoding Support}
@defmodule[thrift/protocol/decoding]

@deftogether[(@defproc[(type-bool/decode [d decoder?]) boolean?]
               @defproc[(type-byte/decode [d decoder?]) byte?]
               @defproc[(type-int16/decode [d decoder?]) integer?]
               @defproc[(type-int32/decode [d decoder?]) integer?]
               @defproc[(type-int64/decode [d decoder?]) integer?]
               @defproc[(type-double/decode [d decoder?]) flonum?]
               @defproc[(type-string/decode [d decoder?]) string?]
               @defproc[(type-binary/decode [d decoder?]) bytes?])]{
TBD
}

@deftogether[(@defproc[(type-bool/decode-list [d decoder?]) (listof boolean?)]
               @defproc[(type-byte/decode-list [d decoder?]) (listof byte?)]
               @defproc[(type-int16/decode-list [d decoder?]) (listof integer?)]
               @defproc[(type-int32/decode-list [d decoder?]) (listof integer?)]
               @defproc[(type-int64/decode-list [d decoder?]) (listof integer?)]
               @defproc[(type-double/decode-list [d decoder?]) (listof flonum?)]
               @defproc[(type-string/decode-list [d decoder?]) (listof string?)]
               @defproc[(type-binary/decode-list [d decoder?]) (listof bytes?)])]{
TBD
}


@defproc[(decode-a-list
          [d decoder?]
          [element-decoder procedure?])
         list?]{
TBD
}

@defproc[(decode-a-union
          [d decoder?]
          [constructor procedure?]
          [struct-schema (hash/c exact-nonnegative-integer? thrift-field?)])
         struct?]{
TBD
}

@defproc[(decode-a-struct
          [d decoder?]
          [struct-schema (hash/c exact-nonnegative-integer? thrift-field?)])
         struct?]{
TBD
}