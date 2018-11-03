#lang racket
;;
;; thrift - idl/generator.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(require racket/contract)

(provide

 (contract-out
  [process-file
   (->* (string? string?) (boolean?) void?)]))

;; ---------- Requirements

(require racket/date
         racket/list
         racket/sequence
         racket/struct
         racket/syntax
         syntax/parse
         thrift/idl/common)

;; ---------- Implementation

(define (process-file file-path output-path [over-write? #f])
  (define in (open-input-file file-path))
  (define out (output #f #f #f #f))
  (define namespace #f)
  (define enums '())
  (define structs '())
  
  (let next ([syn (read-next-syntax file-path in)])
    (unless (equal? syn eof)
      (define syntax-form (syntax-head syn))
      (cond
        [(equal? syntax-form 'define-thrift-namespace)
         (unless (equal? namespace #f)
           (error "cannot redefine namespace"))
         (set! namespace (syntax->datum (second (syntax-e syn))))
         (set! out
               (output
                (open-output-file (format "_~a.rkt" namespace))
                (open-output-file (format "_~a-encode.rkt" namespace))
                (open-output-file (format "_~a-decode.rkt" namespace))
                (open-output-file (format "_~a.scrbl" namespace))))
         (write-file-header (output-defines out)
                            file-path
                            namespace
                            (map ~a '(racket/logging
                                      racket/match
                                      racket/list
                                      racket/set
                                      thrift
                                      thrift/protocol/decoding)))
         (write-file-header (output-encoders out)
                            file-path
                            namespace
                            (list (format "\"~a.rkt\"" namespace)))
         (write-file-header (output-decoders out)
                            file-path
                            namespace
                            (list (format "\"~a.rkt\"" namespace)))
         (write-scribble-file-header (output-docs out)
                                     file-path
                                     namespace
                                     (list (format "\"~a.rkt\"" namespace)))
         (write-logging (output-defines out) namespace)]
        
        [(equal? syntax-form 'define-thrift-enum)
         (when (equal? namespace #f)
           (error "no defined namespace"))
         (define enum-id (parse-enum syn namespace out))
         (set! enums (cons enum-id enums))]
        
        [(equal? syntax-form 'define-thrift-struct)
         (when (equal? namespace #f)
           (error "no defined namespace"))
         (define struct-id (parse-struct syn namespace out))
         (set! structs (cons struct-id structs))]
        
        [(or (equal? syntax-form 'provide)
             (equal? syntax-form 'require)
             (equal? syntax-form 'define))
         (void)] ; ignore
        
        [else
         (raise-contract-error syntax-form
                               syn
                               (syntax-position syn)
                               file-path
                               "unsupported top-level form")])
      
      (next (read-next-syntax file-path in))))
  
  (write-struct-fixups (output-defines out) structs)
  
  (close-output-port (output-defines out))
  (close-output-port (output-encoders out))
  (close-output-port (output-decoders out))
  (close-output-port (output-docs out)))

;; ---------- Internal procedures (parsing)

(struct output
  (defines
   encoders
   decoders
   docs))

(define (read-next-syntax src in)
  (with-handlers ([exn:fail:read?
                   (λ (e) (when (string=? (exn-message e) "read-syntax: `#lang` not enabled")
                            (read-next-syntax src in) ; skip the actual language part
                            (read-next-syntax src in)))])
    (read-syntax src in)))

(define (syntax-head syn)
  (syntax->datum (car (syntax-e syn))))

(define-syntax-class name-value
  #:description "name/value pair"
  #:attributes (name value)
  (pattern (name:id value:nat)))

(define (parse-enum syn ns out)
  (define-values (enum-id name-values)
    (syntax-parse syn
      #:context 'enum-specification
      [(_ enum-id:id (~optional start:nat #:defaults ([start #'0])) ((~seq idents:id ...)))
       (define names (syntax->list #'(idents ...)))
       (define start-num (syntax->datum #'start))
       (values (syntax->datum #'enum-id)
               (for/list ([name names] [v (range start-num (+ (length names) start-num))])
                 (cons (syntax->datum name) v)))]
      [(_ enum-id:id (~optional start:nat #:defaults ([start #'0])) ((~seq idents:name-value ...)))
       (values (syntax->datum #'enum-id)
               (for/list ([name (syntax->list #'(idents.name ...))]
                          [v (syntax->list #'(idents.value ...))])
                 (cons (syntax->datum name) (syntax->datum v))))]))
  (write-enum (output-defines out) ns enum-id name-values)
  (write-enum-doc (output-docs out) ns enum-id name-values)
  (syntax->datum #'enum-id))

(define (parse-struct syn ns out)
  (syntax-parse syn
    #:context 'struct-specification
    [(_ struct-id:id ((~seq field-details ...)))
     (define field-list 
       (for/list ([a-field (syntax->list #'(field-details ...))])
         (define details (map syntax->datum (syntax-e a-field)))
         (when (or (< (length details) 3) (> (length details) 6))
           (raise-contract-error (car details)
                                 a-field
                                 (syntax-position a-field)
                                 ns
                                 "expecting [index name required? container? type key-type?]"))
         (define parsed
           (let parse ([input details] [state 0] [result '()])
             (define consider (if (empty? input) #f (first input)))
             (match state
               [0 (cond
                    [(exact-nonnegative-integer? consider)
                     (parse (rest input) (add1 state) (cons consider result))]
                    [else (error "index not natural number: " consider)])]
               [1 (cond
                    [(or (symbol? consider) (identifier? consider))
                     (parse (rest input) (add1 state) (cons consider result))]
                    [else (error "name not identifier: " consider)])]
               [2 (cond
                    [(or (equal? consider 'required) (equal? consider 'optional))
                     (parse (rest input) (add1 state) (cons consider result))]
                    [else (parse input (add1 state) (cons 'default result))])]
               [3 (cond
                    [(or (equal? consider 'list-of) (equal? consider 'set-of)
                         (equal? consider 'map-of))
                     (parse (rest input) (add1 state) (cons consider result))]
                    [else (parse input (add1 state) (cons 'none result))])]
               [4 (cond
                    [(or (symbol? consider) (identifier? consider))
                     (parse (rest input) (add1 state) (cons consider result))]
                    [else (error "type not identifier: " consider)])]
               [5 (cond
                    [(or (false? consider) (symbol? consider) (identifier? consider))
                     (reverse (cons #f (cons consider result)))]
                    [else (error "key-type not identifier: " consider)])]
               [else (error "not a valid state!" input)])))
         ;; TODO: validate.
         (apply thrift-field parsed)))
     (write-struct (output-defines out) ns (syntax->datum #'struct-id) field-list)
     (write-struct-doc (output-docs out) ns (syntax->datum #'struct-id) field-list)
     (syntax->datum #'struct-id)]))

;; ---------- Internal procedures (writing)

(define (write-file-header out in-file-path ns required-modules)
  (displayln "#lang racket/base" out)
  (displayln ";;" out)
  (displayln (format ";; Generated namespace ~a" ns) out)
  (displayln (format ";;                from ~a" in-file-path) out)
  (displayln (format ";;                  on ~a" (date->string (current-date))) out)
  (displayln ";;                  by thrift/idl/generator v0.1" out)
  (displayln ";;" out)
  (newline out)
  (displayln "(provide (all-defined-out))" out)
  (newline out)
  (displayln (format "(require ~a)" (string-join required-modules " ")) out)
  (newline out))

(define (write-scribble-file-header out in-file-path ns required-modules)
  (displayln "#lang scribble/manual" out)
  (displayln "@;" out)
  (displayln (format "@; Generated namespace ~a" ns) out)
  (displayln (format "@;                from ~a" in-file-path) out)
  (displayln (format "@;                  on ~a" (date->string (current-date))) out)
  (displayln "@;                  by thrift/idl/generator v0.1" out)
  (displayln "@;" out)
  (newline out)
  (newline out)
  (displayln  "@(require racket/sandbox scribble/code scribble/eval" out)
  (displayln (format "          (for-label ~a))" (string-join required-modules " ")) out)
  (newline out)
  (displayln (format "@title[]{Thrift Namespace ~a}" ns) out)
  (newline out))

(define (write-logging out ns)
  (displayln (format "(define-logger ~a)" ns) out)
  (displayln (format "(current-logger ~a-logger)" ns) out)
  (newline out))

(define (write-enum-doc out ns id values)
  (displayln (format "@defproc[(~a? [v any/c]) boolean?]" id) out)
  (newline out)
  (displayln "@deftogether[(" out)
  (for ([vs values])
    (displayln (format "  @defthing[~a:~a ~a?]" id (car vs) id) out))
  (displayln ")]" out)
  (newline out))

(define (write-enum out ns id values)
  ;; write the structure itself
  (displayln (format "(struct ~a (n v))" id) out)
  ;; now write each value
  (for ([vs values])
    (displayln (format
                "(define ~a:~a (~a '~a:~a ~a))"
                id (car vs)
                id
                id (car vs)
                (cdr vs)) out))
  ;; define the enum->name function to return symbolic names
  (displayln (format "(define (~a->symbol e)" id) out)
  (displayln (format "  (~a-n e))" id) out)
  ;; define the enum->integer function
  (displayln (format "(define (~a->integer e)" id) out)
  (displayln (format "  (~a-v e))" id) out)
  ;; define the integer->enum function to return symbolic names
  (displayln (format "(define (integer->~a n)" id) out)
  (displayln "  (match n" out)
  (define patterns
    (for/list ([vs values])
      (format "    [~a ~a:~a]" (cdr vs) id (car vs))))
  (displayln (string-join patterns "\n") out)
  (displayln (format "    [else (error \"unknown value for enum ~a: \" n)]))" id) out)
  ;; decoder function
  (displayln (format "(define (~a/decode decoder) (integer->~a (type-int32/decode decoder)))" id id) out)
  (displayln (format "(define (~a/decode-list decoder)" id) out)
  (displayln (format "  (decode-a-list decoder ~a/decode))" id) out)
  (newline out))

(define (decoder-function container type)
  (define suffix
    (cond
      [(equal? container 'none) ""]
      [(equal? container 'list-of) "-list"]
      [(equal? container 'set-of) "-set"]
      [else (error "unsupported container type: " container)]))
  (cond
    [(member type '(type-bool type-byte type-int16 type-int32 type-int64
                              type-double type-string type-binary))
     (format "~a/decode~a" type suffix)]
    [else
     (format "'~a/decode~a" type suffix)]))

(define (write-struct-doc out ns id fields)
  (displayln (format "@defstruct*[~a (" id) out)
  (for ([f fields])
    (cond
      [(equal? (thrift-field-container f) container-type-list-of)
       (displayln (format "             [~a (listof ~a)]"
                          (thrift-field-name f)
                          (thrift-field-major-type f)) out)]
      [(equal? (thrift-field-container f) container-type-set-of)
       (displayln (format "             [~a (setof ~a)]"
                          (thrift-field-name f)
                          (thrift-field-major-type f)) out)]
      [(equal? (thrift-field-container f) container-type-map-of)
       (displayln (format "             [~a (hash/c ~a ~a)]"
                          (thrift-field-name f)
                          (thrift-field-major-type f)
                          (thrift-field-minor-type f)) out)]
      [else
       (displayln (format "             [~a ~a]"
                          (thrift-field-name f)
                          (thrift-field-major-type f)) out)]))
  (displayln ")]" out)
  (newline out))

(define (write-struct out ns id fields)
  (displayln (format "(struct ~a (~a) #:transparent)"
                     id
                     (string-join (map ~a (map thrift-field-name fields)) " ")) out)
  (displayln (format "(define ~a/schema" id) out)
  (displayln "  (vector" out)
  (display (string-join
              (map
               (λ (f) (format "    ~a"
                              (cons
                               'thrift-field
                               (struct->list
                                (struct-copy
                                 thrift-field f
                                 [name (format "'~s" (thrift-field-name f))]
                                 [required (format "'~s" (thrift-field-required f))]
                                 [container (format "'~s" (thrift-field-container f))]
                                 [major-type (decoder-function
                                              (thrift-field-container f)
                                              (thrift-field-major-type f))])))))
               fields)
              "\n") out)
  (displayln "))" out)

  (displayln (format "(define (~a/decode decoder)" id) out)
  (displayln (format "  (log-~a-info \"decoding ~a from thrift\")" ns id) out)
  (displayln (format "  (decode-a-struct decoder ~a ~a/reverse-schema))" id id) out)
  
  (displayln (format "(define (~a/decode-list decoder)" id) out)
  (displayln (format "  (log-~a-info \"decoding list of ~a from thrift\")" ns id) out)
  (displayln (format "  (decode-a-list decoder ~a/decode))" id) out)
  (displayln (format "(define (~a/decode-set decoder)" id) out)
  (displayln (format "  (log-~a-info \"decoding set of ~a from thrift\")" ns id) out)
  (displayln (format "  (list->set (decode-a-list decoder ~a/decode)))" id) out)
  (newline out))

(define (write-struct-fixups out ids)
  (displayln "(define-namespace-anchor anchor)" out)
  (displayln "(define this-namespace (namespace-anchor->namespace anchor))" out)
  (newline out)
  
  (displayln "(define (fixup-schema schema)" out)
  (displayln "(for ([index (range (vector-length schema))])" out)
  (displayln "  (define field (vector-ref schema index))" out)
  (displayln "  (when (symbol? (thrift-field-major-type field))" out)
  (displayln "    (define new-field" out)
  (displayln "      (struct-copy thrift-field" out)
  (displayln "                   field" out)
  (displayln "                   [major-type (eval (thrift-field-major-type field) this-namespace)]))" out)
  (displayln "    (vector-set! schema index new-field))))" out)
  (newline out)

  (displayln "(define (make-reverse-schema schema)" out)
  (displayln "  (for/hash ([field schema] [position (range (vector-length schema))])" out)
  (displayln "    (set-thrift-field-position! field position)" out)
  (displayln "    (values (thrift-field-id field) field)))" out)
  (newline out)

  (for ([id ids])
    (displayln (format "(fixup-schema ~a/schema)" id) out)
    (displayln (format "(define ~a/reverse-schema (make-reverse-schema ~a/schema))" id id) out)
    (newline out)))

(module+ main
  (displayln "!"))

;; ---------- Internal tests

(module+ test
  (process-file "../../parquet/format.rkt" "."))