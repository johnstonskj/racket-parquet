#lang racket/base
;;
;; parquet - file.
;;   Read/Write Apache Parquet format files
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; Racket Style Guide: http://docs.racket-lang.org/style/index.html

(require racket/contract)

(provide
 (contract-out

  [open-input-parquet-file
   (-> string? transport?)]

  [close-parquet-file
   (-> transport? void?)]

  [read-metadata
   [-> transport? file-metadata?]]))

;; ---------- Requirements

(require racket/list
         racket/string
         thrift
         thrift/transport/file
         thrift/protocol/binary
         thrift/protocol/compact
         thrift/protocol/decoding
         parquet/generated/parquet
         parquet/generated/parquet-decode)

;; ---------- Internal types

;; ---------- Implementation

(define int32-length 4)

(define magic-number #"PAR1")

(define magic-length (bytes-length magic-number))

(define minimum-file-length (+ magic-length int32-length magic-length))


(define (open-input-parquet-file file-path)
  (log-parquet-info "opening Parquet file: ~a for reading" file-path)
  (define transport (open-input-file-transport file-path))
  (define size (transport-size transport))
  (cond
    [(not (> size minimum-file-length))
     (error "file too small, size:" size)]
    [else
     (log-parquet-debug "transport: ~a" transport)

     (define header-magic (transport-read-bytes transport magic-length))
     (unless (equal? header-magic magic-number)
       (error "invalid file format, no initial magic number. Bytes: " header-magic))
     
     (transport-read-position transport (- size magic-length))
     (define footer-magic (transport-read-bytes transport magic-length))
     (unless (equal? header-magic magic-number)
       (error "invalid file format, no trailing magic number. Bytes: " footer-magic))

     transport]))

(define (close-parquet-file transport)
  (close-transport transport)
  (void))

(define (read-metadata transport)
  (log-parquet-info "attempting to read metadata with compact decoder")

  (define size (transport-size transport))
  (define binary (make-binary-decoder transport))

  (transport-read-position transport (- size magic-length int32-length))
  (define footer-length ((decoder-int32 binary)))
  (log-parquet-debug "Footer length: ~a" footer-length)
  (unless (< footer-length size)
    (error "invalid file format, footer length not in file: " footer-length))
  
  (transport-read-position transport (- size footer-length magic-length int32-length))
  (log-parquet-debug "Reading FileMetadata at: ~a" (transport-read-position transport))
  
  (define compact (make-compact-decoder transport))
  (file-metadata/decode compact))

;; ---------- Executable

(module+ main
  (require racket/cmdline racket/logging rackunit thrift/private/logging)

  (define dump-metadata (make-parameter #f))
  (define dump-row-group-metadata (make-parameter #f))
  (define dump-data (make-parameter #t))
  (define dump-format (make-parameter 'screen))
  (define dump-columns (make-parameter '()))
  (define logging-level (make-parameter 'warning))

  (define file-to-read
    (command-line
     #:program "rparquet"
     #:once-each
     [("-m" "--metadata") "Display File Metadata"
                         (dump-metadata #t)]
     [("-r" "--row-group-metadata") "Display Row Group Metadata"
                         (dump-row-group-metadata #t)]
     [("-f" "--format") format "Select format for output"
                         (dump-format (string->symbol format))]
     #:multi
     [("-c" "--col") column "Select column(s) to display"
                         (dump-columns (cons column (dump-columns)))]
     #:once-each
     [("-v" "--verbose") "Compile with verbose messages"
                         (logging-level 'info)]
     [("-V" "--very-verbose") "Compile with very verbose messages"
                         (logging-level 'debug)]
     #:args (file-path)
     file-path))


  (with-logging-to-port
      (current-output-port)
    (λ ()
      (define transport (open-input-parquet-file file-to-read))
      (define metadata (read-metadata transport))
      
      (when (dump-metadata)
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
                          (parquet-type->symbol (schema-element-type element)))
                      (schema-element-type-length element)
                      (if (equal? (schema-element-repetition-type element) 'no-value)
                          'no-value
                          (field-repetition-type->symbol (schema-element-repetition-type element)))
                      (schema-element-num-children element)
                      (schema-element-converted-type element)
                      ))
             )])
        (newline))
      
      (when (dump-row-group-metadata)
        (displayln "Row Group Metadata:")
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
                                  (parquet-type->symbol
                                   (column-metadata-type
                                    (column-chunk-metadata column)))))
               (displayln (format "          encodings=~a, "
                                  (string-join
                                   (for/list ([encoding (column-metadata-encodings
                                                         (column-chunk-metadata column))])
                                     (symbol->string (encoding->symbol encoding)))
                                   "; ")))
               (displayln (format "          compression=~a"
                                  (compression-codec->symbol
                                   (column-metadata-codec
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
                                   (column-chunk-metadata column))))))])
        (newline))

      (when (dump-data)
        (displayln "Data:")
        (newline))

      (close-parquet-file transport))
    #:logger thrift-logger
    (logging-level)))