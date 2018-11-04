# Racket package parquet

[![GitHub release](https://img.shields.io/github/release/johnstonskj/racket-parquet.svg?style=flat-square)](https://github.com/johnstonskj/racket-parquet/releases)
[![Travis Status](https://travis-ci.org/johnstonskj/racket-parquet.svg)](https://www.travis-ci.org/johnstonskj/racket-parquet)
[![Coverage Status](https://coveralls.io/repos/github/johnstonskjracket-/parquet/badge.svg?branch=master)](https://coveralls.io/github/johnstonskj/racket-parquet?branch=master)
[![raco pkg install parquet](https://img.shields.io/badge/raco%20pkg%20install-parquet-blue.svg)](http://pkgs.racket-lang.org/package/parquet)
[![Documentation](https://img.shields.io/badge/raco%20docs-rml--core-blue.svg)](http://docs.racket-lang.org/parquet/index.html)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/racket-parquet.svg)](https://github.com/johnstonskj/racket-parquet/stargazers)
![mit License](https://img.shields.io/badge/license-mit-118811.svg)

This package provides an implementation of basic read (write coming eventually) capabilities for Apache Parquet files. Parquet is a commonly used format in cloud-native systems, the Hadoop ecosystem and machine learning applications.


## Modules

* `parquet` - Common definitions for the Parquet format.
* `parquet/file` - Interface to read a Parquet file.
* `parquet/generated/*` - The set of Thrift generated types and decode functions.
* `thrift` - Common type definitions for the Thrift stack.
* `thrift/idl/generator` - Generate Racket modules based upon an IDL.
* `thrift/idl/language` - Racket syntax for defining IDLs in Racket.
* `thrift/protocol/plain` - The plain binary protocol.
* `thrift/protocol/compact` - The compact binary protocol.
* thrift/transport/file` - A File transport.

## Command Line Launchers

* `rparquet` - 
* `rthrift` - 

[![Apache Parquet](https://raw.githubusercontent.com/johnstonskj/racket-parquet/master/parquet/scribblings/parquet_logo.png)](https://thrift.apache.org)

## Example

```scheme
(require parquet/file
         parquet/generated/parquet
         thrift/transport/common)

(define tport (open-input-parquet-file "../test-data/nation.impala.parquet"))
(define metadata (read-metadata tport))

(displayln (format "File Metadata: ~a, Version: ~a, Num Rows: ~a"
                   (transport-source tport)
                   (file-metadata-version metadata)
                   (file-metadata-num-rows metadata)))

(close-parquet-file tport)
```

## Installation

* To install (from within the package directory): `raco pkg install`
* To install (once uploaded to [pkgs.racket-lang.org](https://pkgs.racket-lang.org/)): `raco pkg install parquet`
* To uninstall: `raco pkg remove parquet`
* To view documentation: `raco docs parquet`

## History

* **1.0** - Initial Stable Version
  * Thrift IDL and generator working for types and decoding functions.
  * Thrift compact protocol working for read.
  * Thrift file transport working for read.
  * Parquet file reader and launcher working for metadata only.
* **0.1** - Initial (Unstable) Version

[![Racket Language](https://raw.githubusercontent.com/johnstonskj/racket-scaffold/master/scaffold/plank-files/racket-lang.png)](https://racket-lang.org/)
