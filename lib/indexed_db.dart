/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett
 */

/// A client-side key-value store with support for indexes.
///
/// > [!Note]
/// > THis package is a drop in replacement for the now deprecated dart:indexed_db Dart library.
///
/// IndexedDB is a web standard API for client-side storage of
/// structured data. By storing data on the client in an IndexedDB,
/// apps can get advantages such as faster performance and
/// persistence.
///
/// In IndexedDB, each record is identified by a unique index or key, making data retrieval speedy.
/// You can store structured data,such as images, arrays, and maps using IndexedDB.
/// The standard does not specify size limits for individual data items
/// or for the database itself, but browsers may impose storage limits.
///
/// ## Using indexed_db
///
/// The classes in this library provide an interface
/// to the browser's IndexedDB, if it has one.
/// To use this library in your code:
///
///     import 'package:indexed_db/indexed_db.dart';
///
/// IndexedDB is almost universally supported in modern web browsers, but
/// a web app can determine if the browser supports IndexedDB
/// with [IdbFactory.supported]:
///
///     if (IdbFactory.supported)
///       // Use indexeddb.
///     else
///       // Find an alternative.
///
/// See this [example](https://github.com/shamblett/indexed_db/blob/master/example/indexed_db_upgrade_needed.dart) for how to open an indexed_db database as per the original
/// Dart library, i.e. using the upgrade needed callback.
///
/// This [example](https://github.com/shamblett/indexed_db/blob/master/example/indexed_db.dart) shows how to
/// open a database by supplying an object store name. This is a convenience function not available
/// in the original Dart library.
///
/// All data in an IndexedDB is stored within an [ObjectStore].
/// To manipulate the database use [Transaction]s.
///
/// ## Other resources
///
/// This package extends the indexed_db interface as exposed by package [web](https://pub.dev/documentation/web/latest/)
///
/// MDN provides [API
/// documentation](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API).
///
/// {@category Web (Legacy)}
///
library;

export 'src/indexed_db.dart';
