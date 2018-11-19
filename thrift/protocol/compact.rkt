#lang racket/base
;;
;; thrift - protocol/compact.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).
;;
;; Implementatiopn based upon the following specifcation:
;;   https://github.com/apache/thrift/blob/master/doc/specs/thrift-compact-protocol.md
;;
;; message               => version-and-type seq-id method-name struct-encoding 
;; version-and-type      => (6-bit version identifier) (2-bit type identifier)
;; seq-id                => varint
;; method-name           => varint (N-byte string)
;; struct-encoding       => field_list stop
;; field_list            => field field_list | field
;; field                 => type-and-id value
;; type-and-id           => field-id-delta type-header | 0 type-header zigzag-varint
;; field-id-delta        => (4-bit offset from preceding field id, 1-15)
;; type-header           => boolean-true | boolean-false | byte-type-header | i16-type-header |
;;                          i32-type-header | i64-type-header | double-type-header |
;;                          string-type-header | binary-type-header | list-type-header |
;;                          set-type-header | map-type-header | struct-type-header
;; value                 => boolean-true | boolean-false | byte | i16 | i32 | i64 | double |
;;                          string | binary | list | set | map | struct
;; stop                  => 0x0
;; boolean-true          => 0x1
;; boolean-false         => 0x2
;; byte-type-header      => 0x3
;; i16-type-header       => 0x4
;; i32-type-header       => 0x5
;; i64-type-header       => 0x6
;; double-type-header    => 0x7
;; binary-type-header    => 0x8
;; string-type-header    => binary-type-header
;; list-type-header      => 0x9
;; set-type-header       => 0xA
;; map-type-header       => 0xB
;; struct-type-header    => 0xC
;; byte                  => (1-byte value)
;; i16                   => zigzag-varint
;; i32                   => zigzag-varint
;; i64                   => zigzag-varint
;; double                => (8-byte double)
;; binary                => varint(size) (bytes)
;; string                => (utf-8 encoded)binary
;; list                  => type-header varint list-body
;; set                   => type-header varint list-body
;; list-body             => value list-body | value
;; map                   => (key)type-header (value)type-header varint key-value-pair-list
;; key-value-pair-list   => key-value-pair key-value-pair-list | key-value-pair
;; key-value-pair        => (key)value (value)value
;;
;; Notes:
;;
;; 1. A Union is encoded exactly the same as a struct with the additional restriction that
;;    at most 1 field may be encoded.
;; 2. An Exception is encoded exactly the same as a struct.
;;

(require racket/contract)

(provide
 
 (contract-out
  
  [make-compact-encoder
   (-> output-transport? (or/c encoder? #f))]
  
  [make-compact-decoder
   (-> input-transport? (or/c decoder? #f))]))

;; ---------- Requirements

(require racket/flonum
         racket/list
         racket/set
         thrift
         thrift/protocol/exn-common
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Internal types/values

(define protocol-id #b10000010)

(define protocol-version #b00001)

(define unnamed "")

(define-enumeration field-type 0
  (stop
   boolean-true
   boolean-false
   byte
   int16
   int32
   int64
   double
   binary
   list
   set
   map
   structure))

(struct compact-state
  ([last-field-id #:mutable]
   [last-boolean-value #:mutable]))

;; ---------- Implementation

(define (make-compact-encoder transport)
  (define state (compact-state '() #f))
  (encoder
   "compact"
   (λ (msg) (write-message-begin state transport msg))
   (λ () (no-op-decoder "message-end"))
   (λ () (write-struct-begin state))
   (λ () (write-struct-end state))
   (λ (fld) (write-field-begin state transport fld))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-stop"))
   (λ (map) (write-map-begin state transport map))
   (λ () (no-op-decoder "map-end"))
   (λ (lst) (write-list-begin state transport lst))
   (λ () (no-op-decoder "list-end"))
   (λ (set) (write-set-begin state transport set))
   (λ () (no-op-decoder "set-end"))
   (λ (v) (no-op-decoder "write-boolean"))
   (λ (v) (transport-write-byte transport v))
   (λ (v) (write-binary transport v))
   (λ (v) (write-integer transport v 16))
   (λ (v) (write-integer transport v 32))
   (λ (v) (write-integer transport v 64))
   (λ (v) (write-double transport v))
   (λ (v) (write-string transport v))))

(define (make-compact-decoder transport)
  (define state (compact-state '() #f))
  (decoder
   "compact"
   (λ () (read-message-begin state transport))
   (λ () (no-op-decoder "message-end"))
   (λ () (read-struct-begin state))
   (λ () (read-struct-end state))
   (λ () (read-field-begin state transport))
   (λ () (no-op-decoder "field-end"))
   (λ () (no-op-decoder "field-stop"))
   (λ () (read-map-begin state transport))
   (λ () (no-op-decoder "map-end"))
   (λ () (read-list-begin state transport))
   (λ () (no-op-decoder "list-end"))
   (λ () (read-set-begin state transport))
   (λ () (no-op-decoder "set-end"))
   (λ () (read-boolean state transport))
   (λ () (transport-read-byte transport))
   (λ () (read-binary transport))
   (λ () (read-integer transport 16))
   (λ () (read-integer transport 32))
   (λ () (read-integer transport 64))
   (λ () (read-double transport))
   (λ () (read-string transport))))

(define (read-boolean state tport)
  (compact-state-last-boolean-value state))

(define (write-integer tport integer width)
  (when (<= (integer-length integer) width)
    (raise (number-too-large (current-continuation-marks) integer)))
  (write-varint tport (integer->zigzag integer)))

(define (read-integer tport width)
  (define integer (zigzag->integer (read-varint tport)))
  (cond
    [(<= (integer-length integer) width)
     integer]
    [else (raise (number-too-large (current-continuation-marks) integer))]))

(define (write-double tport double)
  (write-plain-integer tport (fl->exact-integer double) 8))

(define (read-double tport)
  (->fl (read-plain-integer tport 8)))

(define (write-binary tport bytes)
  (write-varint tport (bytes-length bytes))
  (transport-write-bytes tport bytes))
  
(define (read-binary tport)
  (define byte-length (read-varint tport))
  (transport-read-bytes tport byte-length))

(define (write-string tport str)
  (write-binary tport (string->bytes/utf-8 str)))
  
(define (read-string transport)
  (bytes->string/utf-8 (read-binary transport)))

(define (write-message-begin state tport msg)
  (transport-write-byte tport protocol-id)
  (transport-write-byte tport (+ protocol-version
                                 (arithmetic-shift (message-header-type msg) 5)))
  (write-varint tport (message-header-sequence-id msg))
  (write-string tport (message-header-name msg))
  (void))

(define (read-message-begin state tport)
  (log-thrift-debug "message-begin")
  (define msg-protocol-id (transport-read-byte tport))
  (unless (= protocol-id msg-protocol-id)
    (raise (invalid-protocol-id (current-continuation-marks) msg-protocol-id)))
  (define msg-type-version (transport-read-byte tport))
  (define msg-type (bitwise-and (arithmetic-shift msg-type-version -5) #b111))
  (unless (message-type? msg-type)
    (raise (invalid-message-type (current-continuation-marks)msg-type)))
  (define msg-version (bitwise-and msg-type-version #b11111))
  (unless (= protocol-version msg-version)
    (raise invalid-protocol-version))
  (define msg-sequence-id (read-varint tport))
  (define msg-method-name (read-string tport))
  (unless (= (string-length msg-method-name) 0)
    (raise wrong-method-name))
  (log-thrift-debug "message name ~a, type ~s, sequence" msg-method-name msg-type msg-sequence-id)
  (message-header msg-method-name msg-type msg-sequence-id))

(define (write-struct-begin state)
  (void))

(define (read-struct-begin state)
  (log-thrift-debug "struct-begin")
  ; push new tracking ID
  (set-compact-state-last-field-id! state (cons 0 (compact-state-last-field-id state)))
  unnamed)

(define (write-struct-end state)
  (void))

(define (read-struct-end state)
  (log-thrift-debug "struct-end")
  ; pop the tracking ID
  (set-compact-state-last-field-id! state (rest (compact-state-last-field-id state)))
  (void))

(define (write-field-begin state tport field)
  (cond
    [(equal? (field-header-type field) field-type-stop)
     (transport-write-byte tport field-type-stop)]
    [else
     ; id-delta & type
     ; field-id ?
     (void)
     ]))

(define (read-field-begin state tport)
  (log-thrift-debug "field-begin")
  (define head (transport-read-byte tport))
  (cond
    [(= head field-type-stop)
     (log-thrift-debug "<< (field-stop)")
     (field-header unnamed field-type-stop 0)]
    [else
     (define field-id-delta (bitwise-bit-field head 4 8))
     (define field-type (bitwise-bit-field head 0 4))
     (log-thrift-debug (format ">> field header ~b -> ~b ~b"
                               head field-id-delta field-type))
     (cond
       [(= field-type field-type-boolean-true)
        (set-compact-state-last-boolean-value! state #t)]
       [(= field-type field-type-boolean-false)
        (set-compact-state-last-boolean-value! state #f)])
     (define field-id (cond
                        [(= field-id-delta 0)
                         (zigzag->integer (read-plain-integer tport 2))]
                        [else
                         (+ (first (compact-state-last-field-id state)) field-id-delta)]))
     (when (= field-id 0)
       (raise (invalid-field-id-zero (current-continuation-marks))))
     (set-compact-state-last-field-id!
      state
      (cons field-id (rest (compact-state-last-field-id state))))
     (log-thrift-debug "<< structure field id ~a type ~a (~s)"
                       field-id field-type (integer->field-type field-type))
     (field-header unnamed field-type field-id)]))

(define (write-map-begin state tport map)
  (write-varint tport (map-header-length map))
  ; key-type & element-type
  (transport-write-byte tport 0))

(define (read-map-begin state tport)
  (log-thrift-debug "map-begin")
  (define size (read-varint  tport))
  (define head-byte (transport-read-byte tport))
  (define key-type (bitwise-bit-field head-byte 4 8))
  (define element-type (bitwise-bit-field head-byte 0 4))
  (map key-type element-type size))

(define (write-list-begin state tport lst)
  (void))

(define (read-list-begin state tport)
  (log-thrift-debug "list-begin")
  (define first-byte (transport-read-byte tport))
  (define short-size (bitwise-bit-field first-byte 4 8))
  (define element-type (bitwise-bit-field first-byte 0 4))
  (define size (cond
                 [(= short-size 15)
                  (read-varint tport)]
                 [else short-size]))
  (log-thrift-debug "<< reading list, ~a elements, of type ~s"
                    size (integer->field-type element-type))
  (list-or-set element-type size))

(define (write-set-begin state tport set)
  (write-list-begin state tport set))

(define (read-set-begin state tport)
  (log-thrift-debug "set-begin")
  (read-list-begin state tport))

;; ---------- Internal procedures

(define (integer->zigzag n)
  (cond
    [(< (integer-length n) 32)
     (bitwise-xor (arithmetic-shift n 1) (arithmetic-shift n -31))]
    [(< (integer-length n) 64)
     (bitwise-xor (arithmetic-shift n 1) (arithmetic-shift n -63))]
    [else (raise (number-too-large (current-continuation-marks) n))]))

(define (zigzag->integer z)
  (bitwise-xor (arithmetic-shift z -1) (- (bitwise-and z 1))))

(define 7bit-mask #b1111111)

(define 7bit-more #b10000000)

(define (write-varint transport n)
  (unless (> n 0)
    (raise (number-negative (current-continuation-marks) n)))
  (define width (+ (quotient (integer-length n) 8) 2))
  (let next-byte ([num n])
    (define value (bitwise-and num 7bit-mask))
    (define next-num (arithmetic-shift num -7))
    (cond 
      [(not (= next-num 0))
       (transport-write-byte transport (bitwise-ior value 7bit-more))
       (next-byte next-num)]
      [(= next-num 0)
       (transport-write-byte transport value)]
      [else (error "should not get here")])))

(define (read-varint transport)
  (let next-byte ([num 0] [b (transport-read-byte transport)] [shift 0])
    (define more (bitwise-and b 7bit-more))
    (define next-num (bitwise-ior num (arithmetic-shift (bitwise-and b 7bit-mask) shift)))
    (if (= more 0)
        next-num
        (next-byte next-num (transport-read-byte transport) (+ shift 7)))))

;; ---------- Internal tests

(module+ test
  (require racket/list
           rackunit
           thrift/transport/memory)

  (define (write-test t v)
    (define out (open-output-memory-transport))
    (t out)
    (define bytes (transport-output-bytes out))
    (close-transport out)
    (check-equal? bytes v))

  (define (read-test t bytes v)
    (define in (open-input-memory-transport bytes))
    (define result (t in))
    (close-transport in)
    (check-equal? result v))

  (define zigzag-tests '((0 0) (-1 1) (1 2) (-2 3) (2 4)
                               (1023 2046) (-1025 2049)
                               (2147483647 4294967294)
                               (-2147483648 4294967295)
                               (4294967294 8589934588)
                               (8589934591 17179869182)))
  (for ([test zigzag-tests])
    (check-equal? (integer->zigzag (first test)) (second test))
    (check-equal? (zigzag->integer (second test)) (first test))
    (check-equal? (zigzag->integer (integer->zigzag (first test))) (first test))
    (check-equal? (zigzag->integer (integer->zigzag (second test))) (second test)))

  (define varint-tests '((1 #"\1")
                         (#b1111111111 #"\377\a")
                         (8589934591 #"\377\377\377\377\37")))
  (for ([test varint-tests])
    (write-test (λ (t) (write-varint t (first test))) (second test))
    (read-test (λ (t) (read-varint t)) (second test) (first test))))
