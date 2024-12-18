/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett
 */

///
/// A client-side key-value store with support for indexes.
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
/// The classes in this library provide an interface
/// to the web package IndexedDB implementation.
///
/// All data in an IndexedDB is stored within an [ObjectStore].
/// To manipulate the database use [Transaction]s.
///
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

///
/// Factory
///
extension type Factory(IDBFactory factory {
  IDBOpenDBRequest deleteDatabase(String name) => factory.deleteDatabase(name);

  int cmp(Object first, Object second) =>
      factory.cmp(first.jsify(), second.jsify());

  Future<Database> open(String name, {int? version}) {
    final completer = Completer<Database>();
    try {
      IDBOpenDBRequest request;
      if (version != null) {
        request = factory.open(name, version);
      } else {
        request = factory.open(name);
      }
      request.onsuccess = ((Event _) {
        completer.complete((request.result! as Database));
      }).toJS;
      return completer.future;
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }
}

/// Transaction
///
extension type Transaction(IDBTransaction transaction) {}

/// in web apps.
extension type Database(IDBDatabase database) {
  Transaction transactionList(List<String> storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }
    List storeNames_1 = storeNames;
    return (database.transaction(storeNames_1.toJSBox, mode) as Transaction);
  }
}
