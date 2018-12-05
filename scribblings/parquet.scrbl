#lang scribble/manual

@(require racket/file scribble/core)

@;{============================================================================}

@title[#:version "1.0"]{Package parquet.}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

This package provides the ability to
read (and eventually write) @hyperlink["https://parquet.apache.org/"]{Apache Parquet}
formatted files. Such files are becoming the mainstay of cloud-native big data
systems, especially the @hyperlink["https://hadoop.apache.org/"]{Apache Hadoop}
ecosystem.

The Parquet format is based upon the @hyperlink["https://thrift.apache.org/"]{Apache Thrift}
framework; @italic{"for scalable cross-language services development"}. The
support for this is described in @other-doc['(lib "thrift/scribblings/thrift.scrbl")
                                            #:indirect "Thrift collection"].

@image["scribblings/parquet_logo.png"] 

@table-of-contents[]

@include-section["generated-parquet.scrbl"]

@include-section["file.scrbl"]

@section{License}

@verbatim|{|@file->string["LICENSE"]}|
