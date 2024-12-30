[![Build Status](https://github.com/shamblett/indexed_db/actions/workflows/ci.yml/badge.svg)](https://github.com/shamblett/indexed_db/actions/workflows/ci.yml)

# indexed_db
A drop in replacement package for dart:indexed_db built on package web rather than dart:html.

This package is intended to be a straight replacement of the existing dart:indexed_db library which
doesn't support compilation to WASM.

As such it implements the same API as dart:indexed_db, with only a few additions for added convenience
of use. 

The full dart:indexed_db API is supported with the omission of the Observation, Observer and ObserverChanges 
classes. These interfaces are no longer supported in package web. This doesn't impact on any essential indexed_db 
functionality.



