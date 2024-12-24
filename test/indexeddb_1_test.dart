/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett - updates only
 */

// Copyright (c) 2020, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license.

@TestOn('browser')
library;

// ignore: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';
import 'package:web/web.dart';

const storeName = 'TEST';
const int version = 1;

int databaseNameIndex = 0;
String nextDatabaseName() {
  return 'Test1_${databaseNameIndex++}';
}

// Future testUpgrade() {
//   var dbName = nextDatabaseName();
//   var upgraded = false;
//
//   // Delete any existing DBs.
//   window.indexedDB.deleteDatabase(dbName);
//   idb.Database db;
//
//   // Open the database at version 1
//   final request = window.indexedDB.open(dbName, 1);
//   // ignore: unnecessary_lambdas, avoid_types_on_closure_parameters
//   request.onsuccess = (((Event _) => (request.result as IDBDatabase).close());
//   request.onsuccess = ((Event _) => completer.complete()).toJS;
//   // ignore: avoid_types_on_closure_parameters
//   request.onupgradeneeded = ((Event _) {
//     (request.result! as IDBDatabase).createObjectStore(storeName);
//   }).toJS;
//   _databases[dbName] = (request.result as idb.Database);
//   dbOpenRequest.result.
//   final dbOpenRequest = window.indexedDB.open(dbName, 1);
//   dbOpenRequest.onsuccess = ((Event _) {(dbOpenRequest.result! as IDBDatabase).close(); return null;});
//     db.close();
//     return window.indexedDB!.open(dbName, version: 2,
//         onUpgradeNeeded: (e) {
//       expect(e.oldVersion, 1);
//       expect(e.newVersion, 2);
//       upgraded = true;
//     });
//   }).then((_) {
//     expect(upgraded, isTrue);
//   });
// }

// testReadWrite(key, value, matcher,
//         [dbName,
//         storeName = storeName,
//         version = version,
//         stringifyResult = false]) =>
//     () {
//       if (dbName == null) {
//         dbName = nextDatabaseName();
//       }
//       createObjectStore(e) {
//         idb.ObjectStore store = e.target.result.createObjectStore(storeName);
//         expect(store, isNotNull);
//       }
//
//       late idb.Database db;
//       return window.indexedDB!.deleteDatabase(dbName).then((_) {
//         return window.indexedDB!
//             .open(dbName, version: version, onUpgradeNeeded: createObjectStore);
//       }).then((idb.Database result) {
//         db = result;
//         var transaction = db.transactionList([storeName], 'readwrite');
//         transaction.objectStore(storeName).put(value, key);
//         return transaction.completed;
//       }).then((_) {
//         var transaction = db.transaction(storeName, 'readonly');
//         return transaction.objectStore(storeName).getObject(key);
//       }).then((object) {
//         db.close();
//         if (stringifyResult) {
//           // Stringify the numbers to verify that we're correctly returning ints
//           // as ints vs doubles.
//           expect(object.toString(), matcher);
//         } else {
//           expect(object, matcher);
//         }
//       }).whenComplete(() {
//         return window.indexedDB!.deleteDatabase(dbName);
//       });
//     };

// testReadWriteTyped(key, value, matcher,
//         [dbName,
//         String storeName = storeName,
//         version = version,
//         stringifyResult = false]) =>
//     () {
//       if (dbName == null) {
//         dbName = nextDatabaseName();
//       }
//       void createObjectStore(e) {
//         var store = e.target.result.createObjectStore(storeName);
//         expect(store, isNotNull);
//       }
//
//       late idb.Database db;
//       // Delete any existing DBs.
//       return window.indexedDB!.deleteDatabase(dbName).then((_) {
//         return window.indexedDB!
//             .open(dbName, version: version, onUpgradeNeeded: createObjectStore);
//       }).then((idb.Database result) {
//         db = result;
//         idb.Transaction transaction =
//             db.transactionList([storeName], 'readwrite');
//         transaction.objectStore(storeName).put(value, key);
//
//         return transaction.completed;
//       }).then((idb.Database result) {
//         idb.Transaction transaction = db.transaction(storeName, 'readonly');
//         return transaction.objectStore(storeName).getObject(key);
//       }).then((object) {
//         db.close();
//         if (stringifyResult) {
//           // Stringify the numbers to verify that we're correctly returning ints
//           // as ints vs doubles.
//           expect(object.toString(), matcher);
//         } else {
//           expect(object, matcher);
//         }
//       }).whenComplete(() {
//         return window.indexedDB!.deleteDatabase(dbName);
//       });
//     };

main() {
  test('Supported', () {
    expect(idb.IdbFactory.supported, true);
  });

  test('Open - No Version', () async {
    var dbName = nextDatabaseName();
    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open the database at version 1
    final database = await factory.open(dbName);
    expect(database.name, dbName);
    expect(database.version, 1);
    expect(database.objectStoreNames, isNull);
  });
}
