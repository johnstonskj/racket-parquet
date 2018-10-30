#lang racket/base
;;
;; thrift - protocol/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

(provide
 (struct-out message-header)
 (struct-out field-header)
 (struct-out map-header)
 (struct-out list-or-set)
 (struct-out encoder)
 (struct-out decoder))

;; ---------- Implementation (Types)

(struct message-header
  (name type sequence-id) #:transparent)

(struct field-header
  (name type id) #:transparent)

(struct map-header
  (key-type element-type length) #:transparent)

(struct list-or-set
  (element-type length) #:transparent)

(struct encoder
  (message-begin
   message-end
   struct-begin
   struct-end
   field-begin
   field-end
   field-stop
   map-begin
   map-end
   list-begin
   list-end
   set-begin
   set-end
   boolean
   byte
   bytes
   int16
   int32
   int64
   double
   string))

(struct decoder
  (message-begin
   message-end
   struct-begin
   struct-end
   field-begin
   field-end
   map-begin
   map-end
   list-begin
   list-end
   set-begin
   set-end
   boolean
   byte
   bytes
   int16
   int32
   int64
   double
   string))
