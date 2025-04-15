/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett
 */

/// A client-side key-value store with support for indexes.
///
/// > [!Note]
/// > New projects should prefer to use
/// > [package:web](https://pub.dev/packages/web). For existing projects, see
/// > our [migration guide](https://dart.dev/go/package-web).
///
/// IndexedDB is a web standard API for client-side storage of
/// structured data. By storing data on the client in an IndexedDB,
/// apps can get advantages such as faster performance and
/// persistence.
///
/// In IndexedDB, each record is identified by a unique index or key,
/// making data retrieval speedy.
/// You can store structured data,
/// such as images, arrays, and maps using IndexedDB.
/// The standard does not specify size limits for individual data items
/// or for the database itself, but browsers may impose storage limits.
///
/// ## Using indexed_db
///
/// The classes in this library provide an interface
/// to the browser's IndexedDB, if it has one.
/// To use this library in your code:
///
///     import 'dart:indexed_db';
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
/// Access to the browser's IndexedDB is provided by the app's top-level
/// [Window] object, which your code can refer to with `window.indexedDB`.
/// So, for example,
/// here's how to use window.indexedDB to open a database:
///
///     Future open() {
///       return window.indexedDB.open('myIndexedDB',
///           version: 1,
///           onUpgradeNeeded: _initializeDatabase)
///         .then(_loadFromDB);
///     }
///     void _initializeDatabase(VersionChangeEvent e) {
///       ...
///     }
///     Future _loadFromDB(Database db) {
///       ...
///     }
///
/// All data in an IndexedDB is stored within an [ObjectStore].
/// To manipulate the database use [Transaction]s.
///
/// ## Other resources
///
/// Other options for client-side data storage include:
///
/// * [Window.localStorage]&mdash;a
/// basic mechanism that stores data as a [Map],
/// and where both the keys and the values are strings.
///
/// MDN provides [API
/// documentation](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API).
///
/// {@category Web (Legacy)}
///
library;

export 'src/indexed_db.dart';
