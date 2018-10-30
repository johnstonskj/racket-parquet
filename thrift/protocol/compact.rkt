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
 
 get-protocol-encoder
 
 get-protocol-decoder)

;; ---------- Requirements

(require racket/flonum
         racket/list
         racket/set
         thrift
         thrift/idl/enumeration
         thrift/protocol/plain
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
  ([last-field-id #:mutable]))

;; ---------- Implementation

(define/contract
  (get-protocol-encoder transport)
  (-> transport? (or/c encoder? #f))
  #f)

(define/contract (get-protocol-decoder transport)
  (-> transport? (or/c decoder? #f))
  (define state (compact-state '()))
  (decoder
   (λ () (message-begin state transport))
   (λ () (message-end state transport))
   (λ () (struct-begin state transport))
   (λ () (struct-end state transport))
   (λ () (field-begin state transport))
   (λ () (field-end state transport))
   (λ () (map-begin state transport))
   (λ () (map-end state transport))
   (λ () (list-begin state transport))
   (λ () (list-end state transport))
   (λ () (set-begin state transport))
   (λ () (set-end state transport))
   (λ () (read-boolean transport))
   (λ () (read-byte (transport-in-port transport)))
   (λ (num) (read-bytes num (transport-in-port transport)))
   (λ () (read-integer transport 16))
   (λ () (read-integer transport 32))
   (λ () (read-integer transport 64))
   (λ () (read-double transport))
   (λ () (read-string transport))))

(define (read-boolean transport)
  (read-byte (transport-in-port transport)))

(define (read-integer transport width)
  (define integer (zigzag->integer (read-varint (transport-in-port transport))))
  (cond
    [(<= (integer-length integer) width)
     integer]
    [else (error 'read-integer "integer read is too wide for bits: " width)]))

(define (read-double in)
  (->fl (read-plain-integer (transport-in-port transport) 8)))

(define (read-binary transport)
  (define byte-length (read-varint (transport-in-port transport)))
  (read-bytes byte-length (transport-in-port transport)))

(define (read-string transport)
  (bytes->string/utf-8 (read-binary transport)))

(define (message-begin state transport)
  (define msg-protocol-id (read-byte (transport-in-port transport)))
  (unless (= protocol-id msg-protocol-id)
    (error 'read-message-header "invalid message protocol id: " msg-protocol-id))
  (define msg-type-version (read-byte (transport-in-port transport)))
  (define msg-type (bitwise-and (arithmetic-shift msg-type-version -5) #b111))
  (unless (message-type? msg-type)
    (error 'read-message-header "invalid message type: " msg-type))
  (define msg-version (bitwise-and msg-type-version #b11111))
  (unless (= version msg-version)
    (error 'read-message-header "invalid message version: " msg-version))
  (define msg-sequence-id (read-varint (transport-in-port transport)))
  (define msg-method-name (read-string (transport-in-port transport)))
  (unless (= (string-length msg-method-name) 0)
    (error 'read-message-header "method name not specified."))
  (log-thrift-debug "message name ~a, type ~s, sequence" msg-method-name msg-type msg-sequence-id)
  (message-header msg-method-name msg-type msg-sequence-id))

(define (message-end state transport)
  (void))

(define (struct-begin state transport)
  (log-thrift-debug "struct-begin")
  ; push new tracking ID
  (set-compact-state-last-field-id! state (cons 0 (compact-state-last-field-id state)))
  unnamed)

(define (struct-end state transport)
  (log-thrift-debug "struct-end")
  ; pop the tracking ID
  (set-compact-state-last-field-id! state (rest (compact-state-last-field-id state)))
  (void))

(define (field-begin state transport)
  (log-thrift-debug "field-begin")
  (define head (read-byte (transport-in-port transport)))
  (cond
    [(= head field-type-stop)
     (log-thrift-debug "(field-stop)")
     (field-header unnamed field-type-stop 0)]
    [else
     (define field-id-delta (bitwise-bit-field head 4 8))
     (define field-type (bitwise-bit-field head 0 4))
;     (log-thrift-debug "field delta:type ~b -> ~b ~b" head field-id-delta field-type)
     (define field-id (cond
                        [(= field-id-delta 0)
                         (zigzag->integer (read-plain-integer (transport-in-port transport) 2))]
                        [else
                         (+ (first (compact-state-last-field-id state)) field-id-delta)]))
     (when (= field-id 0)
       (error 'cp:read-structure "field id may not be zero"))
     (set-compact-state-last-field-id!
      state
      (cons field-id (rest (compact-state-last-field-id state))))
     (log-thrift-debug "structure field id ~a type ~s" field-id (integer->field-type field-type))
     (field-header unnamed field-type field-id)]))
       
(define (field-end state transport)
  (log-thrift-debug "field-end")
  (void))

(define (field-stop state transport)
  (log-thrift-debug "field-stop")
  (void))

(define (map-begin state transport)
  (log-thrift-debug "map-begin")
  (define size (read-varint  (transport-in-port transport)))
  (define head-byte (read-byte (transport-in-port transport)))
  (define key-type (bitwise-bit-field head-byte 4 8))
  (define element-type (bitwise-bit-field head-byte 0 4))
  (map key-type element-type size))


(define (map-end state transport)
  (log-thrift-debug "map-end")
  (void))

(define (list-begin state transport)
  (log-thrift-debug "list-begin")
  (define first-byte (read-byte (transport-in-port transport)))
  (define short-size (bitwise-bit-field first-byte 4 8))
  (define element-type (bitwise-bit-field first-byte 0 4))
  (define size (cond
                 [(= short-size 15)
                  (read-varint (transport-in-port transport))]
                 [else short-size]))
  (log-thrift-debug "reading list, ~a elements, of type ~s" size (integer->field-type element-type))
  (list-or-set element-type size))

(define (list-end state transport)
  (log-thrift-debug "list-end")
  (void))

(define (set-begin state transport)
  (log-thrift-debug "set-begin")
  (list-begin state transport))

(define (set-end state transport)
  (log-thrift-debug "set-end")
  (void))

;; ---------- Internal procedures

(define (integer->zigzag n)
  (cond
    [(< (integer-length n) 32)
     (bitwise-xor (arithmetic-shift n 1) (arithmetic-shift n -31))]
    [(< (integer-length n) 64)
     (bitwise-xor (arithmetic-shift n 1) (arithmetic-shift n -63))]
    [else (error "cannot zig-zag number (too large): " n)]))

(define (zigzag->integer z)
  (bitwise-xor (arithmetic-shift z -1) (- (bitwise-and z 1))))

(define 7bit-mask #b1111111)

(define 7bit-more #b10000000)

(define (write-varint n)
  (unless (> n 0)
    (error "cannot 7bit encode negative numbers: " n))
  (define width (+ (quotient (integer-length n) 8) 2))
  (define bs (make-bytes width))
  (let next-byte ([num n] [at 0])
    (define value (bitwise-and num 7bit-mask))
    (define next-num (arithmetic-shift num -7))
    (cond 
      [(not (= next-num 0))
       (bytes-set! bs at (bitwise-ior value 7bit-more))
       (next-byte next-num (add1 at))]
      [(= next-num 0)
       (bytes-set! bs at value)
       (subbytes bs 0 (add1 at))]
      [else (error "should not get here")])))

(define (read-varint in)
  (let next-byte ([num 0] [b (read-byte in)] [shift 0])
    (define more (bitwise-and b 7bit-more))
    (define next-num (bitwise-ior num (arithmetic-shift (bitwise-and b 7bit-mask) shift)))
    (if (= more 0)
        next-num
        (next-byte next-num (read-byte in) (+ shift 7)))))

;; ---------- Internal tests

(module+ test
  (require racket/list
           rackunit)

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

;  (check-equal? (integer->varint 1) #"\1")
;  (check-equal? (bytes->list (integer->varint #b1111111111))
;                '(#b11111111 #b111 ))
;
;  (check-equal? (varint->integer (list->bytes '(#b11111111 #b111))) 1023)
;  
;  (check-equal? (zigzag->integer
;                 (varint->integer
;                  (integer->varint
;                   (integer->zigzag 2147483647))))
;                2147483647)
;
;  (check-equal? (varint->integer
;                 (list->bytes '(#b11111111 #b11111111 #b11111111 #b11111111 #b11111)))
;                8589934591)
  )
