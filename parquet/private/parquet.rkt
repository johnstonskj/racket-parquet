#lang racket/base
;;
;; parquet - parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (contract-out))

;; ---------- Requirements

(require racket/bool
         racket/list
         racket/match
         racket/string
         thrift
         thrift/transport/file
         thrift/protocol/compact
         (prefix-in plain: thrift/protocol/plain)
         parquet/private/format)

;; ---------- Internal types

;; ---------- Implementation

(define-logger parquet)

(define int32-length 4)

(define magic-length (bytes-length magic-number))

(define minimum-file-length (+ magic-length int32-length magic-length))


(define (open-file file-path)
  (log-parquet-info "opening Parquet file: ~a" file-path)
  (define transport (open-file-transport file-path))
  (define size ((transport-size transport)))
  (cond
    [(not (> size minimum-file-length))
     (error "file too small, size:" size)]
    [else
     (log-parquet-debug "transport: ~a" transport)

     (define plain (plain:get-protocol-decoder transport))
     
     (define header-magic ((decoder-bytes plain) magic-length))
     (unless (equal? header-magic magic-number)
       (error "invalid file format, no initial magic number. Bytes: " header-magic))
     
     (file-position (transport-in-port transport) (- size magic-length))
     (define footer-magic ((decoder-bytes plain) magic-length))
     (unless (equal? header-magic magic-number)
       (error "invalid file format, no trailing magic number. Bytes: " footer-magic))

     transport]))


(define (read-metadata transport)
  (log-parquet-info "attempting to read metadata with compact decoder")

  (define size ((transport-size transport)))
  (define plain (plain:get-protocol-decoder transport))

  (file-position (transport-in-port transport)
                 (- size magic-length int32-length))
  (define footer-length ((decoder-int32 plain)))
  (log-parquet-debug "Footer length: ~a" footer-length)
  (unless (< footer-length size)
    (error "invalid file format, footer length not in file: " footer-length))
  
  ((transport-position transport) (- size footer-length magic-length int32-length))
  (log-parquet-debug "Reading FileMetadata at: ~a" (file-position (transport-in-port transport)))
  
  (define compact (get-protocol-decoder transport))
  (decode-file-metadata compact))

;; ********* ********* ********* ********* ********* *********

(define (decode-a-list decoder element-decoder)
  (log-parquet-debug "decoding a list of ~a" (object-name element-decoder))
  (define header ((decoder-list-begin decoder)))
  (define the-list
    (for/list ([element (range (list-or-set-length header))])
      (cond
        [(= (procedure-arity element-decoder) 0)
         (element-decoder)]
        [(= (procedure-arity element-decoder) 1)
         (element-decoder decoder)]
        [else
         (error "invalid decoder function: " (object-name element-decoder))])))
  ((decoder-list-end decoder))
  the-list)

(struct field-schema
  (vid decoder required))

(define (decode-a-struct decoder constructor struct-schema)
  (log-parquet-debug "decoding a structure of ~a" (object-name constructor))
  ((decoder-struct-begin decoder))
  (define result (make-vector (hash-count struct-schema) 'no-value))
  
  (let next-field ([field ((decoder-field-begin decoder))])
    (cond
      [(= (field-header-type field) field-type-stop)
       ((decoder-field-end decoder))]
      [else
       ;; TODO: handle booleans separately
       (define schema (hash-ref struct-schema (field-header-id field)))
       (define decode-func (field-schema-decoder schema))
       (define value
         (cond
           [(= (procedure-arity decode-func) 0)
            (decode-func)]
           [(= (procedure-arity decode-func) 1)
            (decode-func decoder)]
           [else
            (error "invalid decoder function: " (object-name decode-func))]))
       (log-parquet-debug "field value for ~a: ~a" (field-header-id field) value)
       (vector-set! result (field-schema-vid schema) value)
       ((decoder-field-end decoder))
       (next-field ((decoder-field-begin decoder)))]))

  (for ([(id schema) struct-schema])
    (when (and
           (field-schema-required schema)
           (equal? (vector-ref result (field-schema-vid schema)) 'no-value))
      (error (format "field id ~a required for structure ~a "
                     id (object-name constructor)))))
  
  ((decoder-struct-end decoder))
  (apply constructor (vector->list result)))

;; ********* ********* ********* ********* ********* *********

(define (decode-file-metadata decoder)
  (log-parquet-info "decode-file-metadata from thrift")
  (decode-a-struct
   decoder
   file-metadata
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t)
    2 (field-schema 1 decode-schema-element-list #t)
    3 (field-schema 2 (decoder-int64 decoder) #t)
    4 (field-schema 3 decode-row-group-list #t)
    5 (field-schema 5 debug-file-metadata #f) ;decode-key-value-list #f)
    6 (field-schema 5 (decoder-string decoder) #f)
    7 (field-schema 6 decode-column-order-list #f))))

(define (debug-file-metadata decoder)
  (newline)
  (for ([byte ((decoder-bytes decoder) 32)])
    (display (format "~b " byte)))
  (newline))

(define (decode-schema-element-list decoder)
  (log-parquet-info "decode-schema-element-list from thrift")
  ;; TODO: reconstruct nested form
  (decode-a-list decoder decode-schema-element))

(define (decode-schema-element decoder)
  (log-parquet-info "decode-schema-element from thrift")
  (decode-a-struct
   decoder
   schema-element
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #f) ; type?
    2 (field-schema 1 (decoder-int32 decoder) #f)
    3 (field-schema 2 (decoder-int32 decoder) #f) ; field-repetition-type?
    4 (field-schema 3 (decoder-string decoder) #f)
    5 (field-schema 4 (decoder-int32 decoder) #f)
    6 (field-schema 5 (decoder-int32 decoder) #f) ; converted-type?
    7 (field-schema 6 (decoder-int32 decoder) #f)
    8 (field-schema 7 (decoder-int32 decoder) #f)
    9 (field-schema 8 (decoder-int32 decoder) #f)
    10 (field-schema 9 (decoder-int32 decoder) #f)))) ; logical-type?

(define (decode-row-group-list decoder)
  (log-parquet-info "decode-row-group-list from thrift")
  (decode-a-list decoder decode-row-group))

(define (decode-row-group decoder)
  (log-parquet-info "decode-row-group from thrift")
  (decode-a-struct
   decoder
   row-group
   (hash
    1 (field-schema 0 decode-column-chunk-list #t)
    2 (field-schema 1 (decoder-int64 decoder) #t)
    3 (field-schema 2 (decoder-int64 decoder) #t)
    4 (field-schema 3 decode-sorting-column-list #f))))

(define (decode-column-chunk-list decoder)
  (log-parquet-info "decode-column-chunk-list from thrift")
  (decode-a-list decoder decode-column-chunk))

(define (decode-column-chunk decoder)
  (log-parquet-info "decode-column-chunk from thrift")
  (decode-a-struct
   decoder
   column-chunk
   (hash
    1 (field-schema 0 (decoder-string decoder) #f)
    2 (field-schema 1 (decoder-int64 decoder) #t)
    3 (field-schema 2 decode-column-metadata #f)
    4 (field-schema 3 (decoder-int64 decoder) #f)
    5 (field-schema 4 (decoder-int32 decoder) #f)
    6 (field-schema 5 (decoder-int64 decoder) #f)
    7 (field-schema 6 (decoder-int32 decoder) #f))))

(define (decode-sorting-column-list decoder)
  (log-parquet-info "decode-sorting-column-list from thrift")
  (decode-a-list decoder decode-sorting-column))

(define (decode-sorting-column decoder)
  (log-parquet-info "decode-sorting-column from thrift")
  (decode-a-struct
   decoder
   sorting-column
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t)
    2 (field-schema 1 (decoder-boolean decoder) #t)
    3 (field-schema 2 (decoder-boolean decoder) #t))))

(define (decode-column-metadata decoder)
  (log-parquet-info "decode-column-metadata from thrift")
  (decode-a-struct
   decoder
   column-metadata
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #t) ; type?
    2 (field-schema 1 decode-encodings-list #t) ; listof int32
    3 (field-schema 2 decode-path-in-schema-list #t) ; listof string
    4 (field-schema 3 (decoder-int32 decoder) #t) ; compression-code?
    5 (field-schema 4 (decoder-int64 decoder) #t)
    6 (field-schema 5 (decoder-int64 decoder) #t)
    7 (field-schema 6 (decoder-int64 decoder) #t)
    8 (field-schema 7 decode-key-value-list #f)
    9 (field-schema 8 (decoder-int64 decoder) #t)
    10 (field-schema 9 (decoder-int64 decoder) #f)
    11 (field-schema 10 (decoder-int64 decoder) #f)
    12 (field-schema 11 decode-statistics #f)
    13 (field-schema 12 decode-page-encoding-stats-list #f)
    14 (field-schema 13 (decoder-int64 decoder) #f))))

(define (decode-encodings-list decoder)
  (log-parquet-info "decode-encodings-list from thrift")
  (decode-a-list decoder (decoder-int32 decoder)))

(define (decode-path-in-schema-list decoder)
  (log-parquet-info "decode-path-in-schema-list from thrift")
  (decode-a-list decoder (decoder-string decoder)))

(define (decode-key-value-list decoder)
  (log-parquet-info "decode-key-value-list from thrift")
  (decode-a-list decoder decode-key-value))

(define (decode-key-value decoder)
  (log-parquet-info "decode-key-value from thrift")
  (decode-a-struct
   decoder
   key-value
   (hash
    1 (field-schema 0 (decoder-string decoder) #t)
    2 (field-schema 1 (decoder-string decoder) #t))))

(define (decode-statistics decoder)
  (log-parquet-info "decode-statistics from thrift")
  (decode-a-struct
   decoder
   key-value
   (hash
    1 (field-schema 0 (decoder-string decoder) #f)
    2 (field-schema 1 (decoder-string decoder) #f)
    3 (field-schema 2 (decoder-int64 decoder) #f)
    4 (field-schema 3 (decoder-int64 decoder) #f)
    5 (field-schema 4 (decoder-string decoder) #f)
    6 (field-schema 5 (decoder-string decoder) #f))))

(define (decode-page-encoding-stats-list decoder)
  (log-parquet-info "decode-page-encoding-stats-list from thrift")
  (decode-a-list decoder decode-page-encoding-stats))

(define (decode-page-encoding-stats decoder)
  (log-parquet-info "decode-page-encoding-stats from thrift")
  (decode-a-struct
   decoder
   page-encoding-stats
   (hash
    1 (field-schema 0 (decoder-int32 decoder) #f) ; page-type?
    2 (field-schema 1 (decoder-int32 decoder) #f) ; encoding?
    3 (field-schema 2 (decoder-int32 decoder) #f))))

(define (decode-column-order-list decoder)
  (log-parquet-info "decode-column-order-list from thrift")
  (decode-a-list decoder decode-column-order))

(define (decode-column-order decoder)
  (log-parquet-info "decode-column-order from thrift")
  (decoder-struct-begin decoder)
  (decoder-struct-end decoder)
  'no-value)
  

;; ---------- Internal procedures

;; ---------- Internal tests

(module+ test
  (require racket/logging rackunit thrift/private/logging)
  (with-logging-to-port
      (current-output-port)
    (λ ()
      (define transport (open-file "../../test-data/nation.impala.parquet"))
      (define metadata (read-metadata transport))
      (displayln (format "File Metadata: ~a" (transport-source transport)))
      (displayln (format "  Version: ~a" (file-metadata-version metadata)))
      (displayln (format "  Num Rows: ~a" (file-metadata-num-rows metadata)))
      (displayln "  k/v metadata:")
      (cond
        [(or (equal? (file-metadata-key-value-metadata metadata) 'no-value)
                     (= (length (file-metadata-key-value-metadata metadata)) 0))
         (displayln "    (none)")]
        [else
         (for ([kv (file-metadata-key-value-metadata metadata)])
           (displayln (format "    ~a: ~a"
                              (key-value-key kv)
                              (key-value-value kv))))])
      (displayln "  schema:")
      (cond
        [(= (length (file-metadata-schema metadata)) 0)
         (displayln "    (none)")]
        [else
         (for ([element (file-metadata-schema metadata)])
           (displayln
            (format "    ~a (~a): length=~a. repetition=~a, children=~a, converted-type=~a"
                    (schema-element-name element)
                    (if (equal? (schema-element-type element) 'no-value)
                        'no-value
                        (integer->type (schema-element-type element)))
                    (schema-element-type-length element)
                    (if (equal? (schema-element-repetition-type element) 'no-value)
                        'no-value
                        (integer->field-repetition-type (schema-element-repetition-type element)))
                    (schema-element-num-children element)
                    (schema-element-converted-type element)
                    ))
           )])
      (displayln "  row groups:")
      (cond
        [(= (length (file-metadata-row-groups metadata)) 0)
         (displayln "    (none)")]
        [else
         (for ([group (file-metadata-row-groups metadata)]
               [idx (range (length (file-metadata-row-groups metadata)))])
           (displayln (format "    group ~a:" idx))
           (for ([column (row-group-columns group)])
             (displayln (format "      path=~a, offset=~a, "
                                (column-chunk-file-path column)
                                (column-chunk-file-offset column)))
             (displayln "        metadata:")
             (displayln (format "          paths=~a, "
                                (string-join
                                 (column-metadata-path-in-schema (column-chunk-metadata column))
                                 "; ")))
             (displayln (format "          type=~a,"
                                (integer->type (column-metadata-type
                                                (column-chunk-metadata column)))))
             (displayln (format "          encodings=~a, "
                                (string-join
                                 (for/list ([encoding (column-metadata-encodings
                                                       (column-chunk-metadata column))])
                                   (symbol->string (integer->encoding encoding)))
                                 "; ")))
             (displayln (format "          compression=~a"
                                (integer->compression-codec (column-metadata-codec
                                                             (column-chunk-metadata column)))))
             (displayln (format "          values=~a, "
                                (column-metadata-num-values (column-chunk-metadata column))))
             (displayln (format "          uncompressed-size=~a, "
                                (column-metadata-total-uncompressed-size
                                 (column-chunk-metadata column))))
             (displayln (format "          data-page-offset=~a,"
                                (column-metadata-data-page-offset
                                 (column-chunk-metadata column))))
             (displayln (format "          index-page-offset=~a,"
                                (column-metadata-index-page-offset
                                 (column-chunk-metadata column))))
             ))])
      (newline)
      (displayln "Data:")
      (newline)
      )
    #:logger thrift-logger
    'warning))