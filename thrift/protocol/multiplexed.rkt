#lang racket/base
;;
;; thrift - protocol/multiplexed.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; https://github.com/apache/thrift/blob/master/doc/specs/thrift-binary-protocol.md

(require racket/contract)

(provide

 (contract-out
  
  [get-protocol-encoder
   (-> encoder? string? (or/c encoder? #f))]
  
  [get-protocol-decoder
   (-> decoder? string? (or/c decoder? #f))]))

;; ---------- Requirements

(require racket/flonum
         thrift/protocol/common
         thrift/transport/common
         thrift/private/enumeration
         thrift/private/protocol
         thrift/private/logging)

;; ---------- Implementation

(define (get-protocol-encoder wrapped service-name)
  #f)

(define (get-protocol-decoder wrapped service-name)
  (decoder
   (λ () (message-begin transport))
   (λ () ((decoder-message-end wrapped)))
   (λ () ((decoder-struct-begin wrapped)))
   (λ () ((decoder-struct-end wrapped)))
   (λ () ((decoder-field-begin wrapped)))
   (λ () ((decoder-field-end wrapped)))
   (λ () ((decoder-map-begin wrapped)))
   (λ () ((decoder-map-end wrapped)))
   (λ () ((decoder-list-begin wrapped)))
   (λ () ((decoder-list-end wrapped)))
   (λ () ((decoder-set-begin wrapped)))
   (λ () ((decoder-set-end wrapped)))
   (λ () (if (= (transport-read-byte transport) 0) #f #t))
   (λ () (transport-read-byte transport))
   (λ () (read-binary transport))
   (λ () (read-plain-integer transport 2))
   (λ () (read-plain-integer transport 4))
   (λ () (read-plain-integer transport 8))
   #f
   (λ () (bytes->string/utf-8 (read-binary transport)))))

;; ---------- Internal procedures

