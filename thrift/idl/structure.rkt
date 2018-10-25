#lang racket
;; thrift - structure.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require (for-syntax racket/syntax))

;; ---------- Implementation

(define-syntax (define-structure stx)
  (syntax-case stx ()
    ;; TODO: deal with required and listof
    [(_ struct-id ([field-id field-name type-id] ...))
     (with-syntax ([index-to-id (format-id #'struct-id "index->~a" #'struct-id)]
                   [name-to-id (format-id #'struct-id "name->~a" #'struct-id)])
       (define ids (syntax->list #'(field-id ...)))
       (define names (syntax->list #'(field-name ...)))
       #`(begin
        (struct struct-id (field-name ...) #:transparent)
        (define (index-to-id sv n)
          (cond 
            #,@(for/list ([id ids] [name names])
                 (with-syntax ([a-field-id (format-id #'struct-id "~a" name)])
                   #`[(= n #,id) (name-to-id sv a-field-id)]))
            [else (error "not a valid index for struct: " n)]))
        (define-syntax-rule (name-to-id st a-field-id)
          (match st
            [(struct* struct-id ([a-field-id v])) v]
            [else (error "not a valid field for struct: " )]))))]
    [else
     (error "unsupported syntax format")]))

;; ---------- Internal tests

(define-structure file-metadata
  ([1 version int32]
   [2 schema list]
   [3 num-rows int64]
   [4 row-groups list]
   [5 key-value-metadata list]
   [6 created-by string]
   [7 column-orders list]))

(define (testme)
  (define fmd (file-metadata 101 '() 10 1 '() "me" '()))
  (file-metadata? fmd)
  (file-metadata-version fmd)
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
