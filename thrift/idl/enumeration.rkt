#lang racket/base
;;
;; thrift - enumeration.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require (for-syntax
          racket/base
          racket/list
          racket/sequence
          racket/syntax))

;; ---------- Implementation

(define-syntax (define-enumeration stx)
  (syntax-case stx ()
    [(_ id (enum-id ...))
     ;; no starting integer specified, use the default of one.
     #`(define-enumeration id 1 (enum-id ...))]
     ;; starting integer specified, just increase by one for each identifier.
    [(_ id start (enum-id ...))
     (and (identifier? #'id)
          (for/and ([an-id (syntax->list #'(enum-id ...))])
            (identifier? an-id)))
     (with-syntax ([pred-id (format-id #'id "~a?" #'id)]
                   [name-id (format-id #'id "integer->~a" #'id)]
                   [names-id (format-id #'id "~a/names" #'id)])
       #`(begin
           #,@(let* ([first-integer (syntax->datum #'start)]
                     [enum-list (syntax->list #'(enum-id ...))]
                     [integers (sequence->list (in-range first-integer (add1 (length enum-list))))]
                     [predicate
                      ;; define the predicate to test for valid values
                      (with-syntax ([enum-count (length enum-list)])
                        #`(define (pred-id v)
                            (and (integer? v)
                                 (>= v 1)
                                 (<= v enum-count))))]
                     [to-name
                      ;; define the integer->enum function to return symbolic names
                      (with-syntax ([id-hash
                                     (datum->syntax stx
                                      (for/hash ([x enum-list]
                                                 [n integers])
                                        (values n (format-id #'id "~a-~a" #'id x))))])
                          #`(define (name-id v) (hash-ref id-hash v)))]
                     [to-names
                      ;; define the enum->names function to return symbolic names
                      (with-syntax ([id-list
                                     (datum->syntax stx
                                      (cons 'list
                                            (for/list ([x enum-list])
                                              (symbol->string (format-symbol "~a-~a" #'id x)))))])
                          #`(define names-id id-list))]
                     [enumerations
                      ;; define each enumeration value
                      (for/list ([x enum-list]
                                 [n integers])
                        (with-syntax ([an-enum-id (format-id #'id "~a-~a" #'id x)]
                                      [ix n])
                          #`(define an-enum-id ix)))])
                (append enumerations (list predicate to-name to-names)))))]
    [(_ id ([enum-id enum-val] ...))
     ;; no starting integer specified, use the default of one.
     #`(define-enumeration id 1 ([enum-id enum-val] ...))]
    [(_ id start ([enum-id enum-val] ...))
     ;; TODO: this should be the workhorse version
     (error "unsupported format")]))

;; ---------- Internal tests

(module+ test 
  (define-enumeration my-enum (A B C))
  (my-enum? -1)
  (my-enum? 0)
  (my-enum? 1)
  (my-enum? 2)
  (my-enum? 3)
  (my-enum? 4)
  my-enum-A
  my-enum-B
  my-enum-C
  (integer->my-enum 2)
  my-enum/names)