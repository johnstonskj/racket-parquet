#lang racket/base
;;
;; thrift - idl/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (all-defined-out))

;; ---------- Requirements

(require thrift/private/enumeration)

;; ---------- Implementation (Types)

;; from https://thrift.apache.org/docs/types
(define-enumeration type 0
  (;; Base Types
   bool
   byte
   int16
   int32
   int64
   double
   string
   ;; Special Types
   binary
   ;; Structs
   struct
   ;; Containers
   list
   set
   map))

(define-enumeration required-type
  (required
   optional
   default))

(define-enumeration container-type
  (list-of
   set-of
   map-of
   none))

(struct thrift-field
  (id
   name
   required
   container
   major-type ; one day will be (decoder . encoder)
   minor-type ; one day will be (decoder . encoder)
   [position #:mutable])
  #:transparent)
