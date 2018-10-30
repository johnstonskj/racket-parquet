#lang racket
;; thrift - idl/struct.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require syntax/parse
         thrift
         thrift/idl/literals
         thrift/protocol/decoding
         thrift/private/logging
         (for-syntax racket/bool
                     racket/match
                     racket/syntax
                     syntax/parse))

;; ---------- Implementation

(define-syntax-literals kw-required (required optional))

(define-syntax-literals kw-container (list-of set-of map-of none))

(define-syntax (define-thrift-struct stx)
;  (define (type-id->decoder type)
  (syntax-parse stx
    [(_ struct-id:id ((~seq field-details ...)))
     (define name-list '())
     (with-syntax ([struct-schema (format-id #'struct-id "~a/schema" #'struct-id)]
                   [struct-rev-schema (format-id #'struct-id "~a/reverse-schema" #'struct-id)]
                   [struct-decode (format-id #'struct-id "~a/decode" #'struct-id)]
                   [struct-decode-list (format-id #'struct-id "~a/decode-list" #'struct-id)]
                   [index-to-id (format-id #'struct-id "index->~a" #'struct-id)]
                   [name-to-id (format-id #'struct-id "name->~a" #'struct-id)])
       #`(begin
           (define struct-schema
             (vector
              #,@(for/list ([a-field (syntax->list #'(field-details ...))])
                   (syntax-parse a-field
                     #:literals (required optional list-of set-of map-of none)
                     [(index:nat name:id type:id)
                      (set! name-list (cons (cons #'index #'name) name-list))
                      (with-syntax ([decoder-name (format-id #'type "~a/decode" #'type)])
                        #'(thrift-field index (quote name) required none decoder-name #f #f))]
                     
                     [(index:nat name:id ?required:kw-required/class type:id)
                      (set! name-list (cons (cons #'index #'name) name-list))
                      (with-syntax ([decoder-name (format-id #'type "~a/decode" #'type)])
                        #'(thrift-field index (quote name) ?required none decoder-name #f #f))]
                     
                     [(index:nat name:id ?container:kw-container/class type:id)
                      #:fail-when (equal? (format "~a" (syntax->datum #'?container)) "map-of")
                      "map-of requires a second type to be specified"
                      (set! name-list (cons (cons #'index #'name) name-list))
                      (with-syntax ([decoder-name (format-id #'type "~a/decode" #'type)])
                        #'(thrift-field index (quote name) required ?container decoder-name #f #f))]
                     
                     [(index:nat name:id ?container:kw-container/class major-type:id minor-type:id)
                      #:fail-when (not (equal? (format "~a" (syntax->datum #'?container)) "map-of"))
                      "specification of a second type requires a container map-of"
                      (set! name-list (cons (cons #'index #'name) name-list))
                      (with-syntax ([decoder-name (format-id #'type "~a/decode" #'type)]
                                    [minor-decoder-name (format-id #'type "~a/decode" #'type)])
                        #'(thrift-field index (quote name) required ?container major-decoder-name minor-decoder-name #f))]
                     
                     [(index:nat
                       name:id
                       ?required:kw-required/class
                       ?container:kw-container/class
                       major-type:id
                       (~optional minor-type:id #:defaults ([minor-type #'#f])))
                      #:fail-when (and (equal? (format "~a" (syntax->datum #'?container)) "map-of")
                                       (false? (syntax->datum #'minor-type)))
                      "map-of requires a second type to be specified"
                      (set! name-list (cons (cons #'index #'name) name-list))
                      (with-syntax ([major-decoder-name (format-id #'type "~a/decode" #'type)]
                                    [minor-decoder-name (format-id #'type "~a/decode" #'type)])
                        #'(thrift-field index (quote name) ?required ?container major-decoder-name minor-decoder-name #f))]))))
           (define struct-rev-schema
             (for/hash ([field struct-schema] [position (range (vector-length struct-schema))])
               (set-thrift-field-position! field position)
               (values (thrift-field-id field) field)))
           #,@(with-syntax ([field-list
                             (for/list ([name (reverse name-list)])
                               (format-id #'struct-id "~a" (cdr name)))])
                #'((struct struct-id field-list)))
           (define (struct-decode decoder)
             (log-thrift-info "decoding ~a from thrift" struct-id)
             (decode-a-struct decoder struct-id struct-rev-schema))
           (define (struct-decode-list decoder)
             (log-thrift-info "decoding list of ~a from thrift" struct-id)
             (decode-a-list decoder struct-decode))
           (define (index-to-id sv n)
             (cond 
               #,@(for/list ([index-name name-list])
                    (with-syntax ([a-field-id (format-id #'struct-id "~a" (cdr index-name))])
                      #`[(= n #,(car index-name)) (name-to-id sv a-field-id)]))
               [else (error "not a valid index for struct: " n)]))
           (define-syntax-rule (name-to-id st a-field-id)
             (match st
               ; match a struct with field named a-field-id
               [(struct* struct-id ([a-field-id v])) v]
               [else (error "not a valid field for struct: " )]))
           ))]))
     
;; ---------- Internal tests

(module+ test

  (require thrift/idl/common)

  (define-thrift-struct key-value
    ([1 key type-string]
     [2 value optional type-string]))
  
  (define-thrift-struct file-metadata
    ([1 version type-int32]
     [2 schema list-of type-string]
     [3 num-rows type-int64]
     [4 row-groups list-of type-int32]
     [5 key-value-metadata type-string]
     [6 created-by type-string]
     [7 column-orders list-of key-value]))

  (define fmd (file-metadata 101 '() 10 1 '() "simon" '()))
  
  (displayln file-metadata/schema)

  (displayln file-metadata/reverse-schema)

  (displayln (file-metadata? fmd))
  (displayln (file-metadata-version fmd))
  (displayln (index->file-metadata fmd 1))
  (displayln (name->file-metadata fmd version))
  (displayln (index->file-metadata fmd 2))
  (displayln (name->file-metadata fmd schema))
  (displayln (index->file-metadata fmd 3))
  (displayln (name->file-metadata fmd num-rows))
  (displayln (index->file-metadata fmd 4))
  (displayln (name->file-metadata fmd row-groups))
  (displayln (index->file-metadata fmd 5))
  (displayln (name->file-metadata fmd key-value-metadata))
  (displayln (index->file-metadata fmd 6))
  (displayln (name->file-metadata fmd created-by))
  (displayln (index->file-metadata fmd 7))
  (displayln (name->file-metadata fmd column-orders)))
