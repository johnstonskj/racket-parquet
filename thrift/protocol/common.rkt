#lang racket/base
;;
;; thrift - protocol/common.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;writeMessageBegin(name, type, seq)
;writeMessageEnd()
;writeStructBegin(name)
;writeStructEnd()
;writeFieldBegin(name, type, id)
;writeFieldEnd()
;writeFieldStop()
;writeMapBegin(ktype, vtype, size)
;writeMapEnd()
;writeListBegin(etype, size)
;writeListEnd()
;writeSetBegin(etype, size)
;writeSetEnd()
;writeBool(bool)
;writeByte(byte)
;writeI16(i16)
;writeI32(i32)
;writeI64(i64)
;writeDouble(double)
;writeString(string)
;
;name, type, seq = readMessageBegin()
;                  readMessageEnd()
;name = readStructBegin()
;       readStructEnd()
;name, type, id = readFieldBegin()
;                 readFieldEnd()
;k, v, size = readMapBegin()
;             readMapEnd()
;etype, size = readListBegin()
;              readListEnd()
;etype, size = readSetBegin()
;              readSetEnd()
;bool = readBool()
;byte = readByte()
;i16 = readI16()
;i32 = readI32()
;i64 = readI64()
;double = readDouble()
;string = readString()

(provide
 (struct-out message-header)
 (struct-out field-header)
 (struct-out map)
 (struct-out list-or-set)
 (struct-out encoder)
 (struct-out decoder))

;; ---------- Implementation

(struct message-header
  (name type sequence-id) #:transparent)

(struct field-header
  (name type id) #:transparent)

(struct map
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
