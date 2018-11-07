#lang racket/base
;;
;; thrift - prototol.
;;   Support for Thrift encoding
;;
;; Copyright (c) 2018 Simon Johnston (johnstonskj@gmail.com).

;; ---------- Requirements

(require rackunit
         ; ---------
         thrift
         thrift/protocol/json
         thrift/protocol/sexpression
         thrift/transport/memory)

;; ---------- Test Fixtures

;; ---------- Internal procedures

;; ---------- Test Cases

(define encoding-tests
  (hash make-json-encoder #"[1,\"mthod\",7,9,[\"str\",2,\"hello\",\"world\"],{1:{\"str\":\"simon\"},2:{\"i8\":48},3:{\"tf\":0}},[\"str\",\"i32\",0,{\"key\":\"value\"},{\"key2\":101},{\"202\":\"value?\"}]]"
        make-sexpression-encoder #"#s(message-header \"mthod\" 7 9) #s(list-or-set 6 2) \"hello\" \"world\" #s(field-header \"name\" 6 1) \"simon\" #s(field-header \"age\" 1 2) 48 #s(field-header \"brilliant?\" 0 3) #f #s(map-header 6 3 0) \"key\" \"value\" \"key2\" 101 202 \"value?\" "))
   
  
(for ([(encoder results) encoding-tests])
  (test-case
   (format "testing simple encoding using ~a" encoder)
   (define t (open-output-memory-transport))
   (define p (encoder t))

   ((encoder-message-begin p) (message-header "mthod" 7 9))

   ((encoder-list-begin p) (list-or-set type-string 2))
   ((encoder-string p) "hello")
   ((encoder-string p) "world")
   ((encoder-list-end p))

   ((encoder-struct-begin p))

   ((encoder-field-begin p) (field-header "name" type-string 1))
   ((encoder-string p) "simon")
   ((encoder-field-end p))

   ((encoder-field-begin p) (field-header "age" type-byte 2))
   ((encoder-byte p) 48)
   ((encoder-field-end p))

   ((encoder-field-begin p) (field-header "brilliant?" type-bool 3))
   ((encoder-boolean p) #f)
   ((encoder-field-end p))

   ((encoder-struct-end p))

   ((encoder-map-begin p) (map-header type-string type-int32 0))
   ((encoder-string p) "key")
   ((encoder-string p) "value")
   ((encoder-string p) "key2")
   ((encoder-int32 p) 101)
   ((encoder-int32 p) 202)
   ((encoder-string p) "value?")
   ((encoder-map-end p))


   ((encoder-message-end p))

   (define actual (transport-output-bytes t))

   (check-equal? actual results)))