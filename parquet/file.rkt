#lang racket/base
;;
;; parquet - parquet.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (contract-out

  [open-file
   (-> string? transport?)]

  [close-file
   (-> transport? void?)]

  [read-metadata
   [-> transport? file-metadata?]]))

;; ---------- Requirements

(require racket/list
         racket/string
         thrift
         thrift/transport/file
         (prefix-in plain: thrift/protocol/plain)
         (prefix-in compact: thrift/protocol/compact)
         thrift/protocol/decoding
         parquet/generated/parquet)

;; ---------- Internal types

;; ---------- Implementation

(define int32-length 4)

(define magic-number #"PAR1")

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

(define (close-file transport)
  (close-file-transport transport)
  (void))

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
  
  (define compact (compact:get-protocol-decoder transport))
  (file-metadata/decode compact))

;; ---------- Executable

(module+ main
  (require racket/logging rackunit thrift/private/logging)
  (with-logging-to-port
      (current-output-port)
    (λ ()
      (define transport (open-file "../test-data/nation.impala.parquet"))
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
                        (schema-element-type element))
                    (schema-element-type-length element)
                    (if (equal? (schema-element-repetition-type element) 'no-value)
                        'no-value
                        (schema-element-repetition-type element))
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
                                (column-metadata-type
                                 (column-chunk-metadata column))))
             (displayln (format "          encodings=~a, "
                                (string-join
                                 (for/list ([encoding (column-metadata-encodings
                                                       (column-chunk-metadata column))])
                                   (symbol->string (encoding->symbol encoding)))
                                 "; ")))
             (displayln (format "          compression=~a"
                                (column-metadata-codec
                                 (column-chunk-metadata column))))
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

      (close-file-transport transport)
      )
    #:logger thrift-logger
    'info))