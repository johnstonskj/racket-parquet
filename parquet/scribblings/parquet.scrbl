#lang scribble/manual

@(require racket/file scribble/core)

@;{============================================================================}

@title[#:version "1.0"]{Package parquet.}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

Read/Write Apache Parquet format files

@table-of-contents[]

@include-section["_parquet.scrbl"]

@section{License}

@verbatim|{|@file->string["../LICENSE"]}|