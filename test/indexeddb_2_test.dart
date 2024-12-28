// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library;

// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';

// Read with cursor tests

const String dbName = 'Test3';
const String storeName = 'TEST';
const int version = 1;

Future<idb.Database> createAndOpenDb() async {
  final factory = idb.IdbFactory();

  // Delete any existing DBs.
  factory.deleteDatabase(dbName);

  // Open the database at version 1
  final database = await factory.open(dbName);

  // Create the object store
  database.createObjectStore(storeName);

  // Allow the version change transaction to complete, should be needed only in unit testing.
  await Future.delayed(Duration(seconds: 1));

  return database;
}

Future<idb.Database> writeItems(idb.Database db) {
  Future<Object> write(index) {
    var transaction = db.transaction(storeName, 'readwrite');
    transaction.objectStore(storeName).put('Item $index', index);
    return transaction.completed;
  }

  var future = write(0);
  for (var i = 1; i < 100; ++i) {
    future = future.then((_) => write(i));
  }

  // Chain on the DB so we return it at the end.
  return future.then((_) => db);
}

Future<idb.Database> setupDb() {
  return createAndOpenDb().then(writeItems);
}

Future<idb.Database> readAllViaCursor(idb.Database db) {
  idb.Transaction txn = db.transaction(storeName, 'readonly');
  idb.ObjectStore objectStore = txn.objectStore(storeName);
  int itemCount = 0;
  int sumKeys = 0;
  Object? lastKey;

  var cursors = objectStore.openCursor().asBroadcastStream();
  cursors.listen((cursor) {
    ++itemCount;
    lastKey = cursor.key;
    sumKeys += cursor.key as int;
    expect(cursor.value, 'Item ${cursor.key}');
    cursor.next();
  });
  cursors.last.then((cursor) {
    expect(lastKey, 99);
    expect(sumKeys, (100 * 99) ~/ 2);
    expect(itemCount, 100);
  });

  return cursors.last.then((_) => db);
}

Future<idb.Database> readAllReversedViaCursor(idb.Database db) {
  idb.Transaction txn = db.transaction(storeName, 'readonly');
  idb.ObjectStore objectStore = txn.objectStore(storeName);
  int itemCount = 0;
  int sumKeys = 0;
  Object? lastKey;

  var cursors = objectStore.openCursor(direction: 'prev').asBroadcastStream();
  cursors.listen((cursor) {
    ++itemCount;
    lastKey = cursor.key;
    sumKeys += cursor.key as int;
    expect(cursor.value, 'Item ${cursor.key}');
    cursor.next();
  });
  cursors.last.then((cursor) {
    expect(lastKey, 0);
    expect(sumKeys, (100 * 99) ~/ 2);
    expect(itemCount, 100);
  });
  return cursors.last.then((_) => db);
}

main() {
    test('Cursors', () async {
      idb.Database db = await setupDb();
      await readAllViaCursor(db);
      await readAllReversedViaCursor(db);
      db.close();
    });
}
