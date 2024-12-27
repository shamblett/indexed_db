// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library;

import 'dart:async';
import 'dart:js_interop';

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';

// Test for KeyRange and Cursor.

const String dbName = 'Test4';
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
  Future<Object?> write(index) {
    var transaction = db.transaction(storeName, 'readwrite');
    return transaction
        .objectStore(storeName)
        .put({'content': 'Item $index'}.jsify(), index) as Future<Object?>;
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

testRange(idb.Database db, idb.KeyRange range, int expectedFirst, int expectedLast) {
  idb.Transaction txn = db.transaction(storeName, 'readonly');
  idb.ObjectStore objectStore = txn.objectStore(storeName);
  var cursors = objectStore
      .openCursor(range: range, autoAdvance: true)
      .asBroadcastStream();

  int lastKey = 0;
  cursors.listen((idb.CursorWithValue cursor) {
    lastKey = cursor.key as int;
    JSObject value = cursor.value;
    var dartObject = value.dartify();
    expect((dartObject as Map)['content'], 'Item ${cursor.key}');
  });

  cursors.first.then((cursor) {
    expect(cursor.key, expectedFirst);
    cursor.next();
  });
  cursors.last.then((cursor) {
    expect(lastKey, expectedLast);
    cursor.next();
  });

  return cursors.length.then((length) {
    expect(length, expectedLast - expectedFirst + 1);
    });
}

main() async {
  idb.Database db = await setupDb();
  test('only1', () => testRange(db, idb.KeyRange.only(55), 55, 55));
  // test('only2', () => testRange(db, idb.KeyRange.only(100), null, null));
  // test('only3', () => testRange(db, idb.KeyRange.only(-1), null, null));
  //
  // test('lower1', () => testRange(db, idb.KeyRange.lowerBound(40), 40, 99));
  // // OPTIONALS lower2() => testRange(db,  idb.KeyRange.lowerBound(40, open: true), 41, 99);
  // test(
  //     'lower2', () => testRange(db, idb.KeyRange.lowerBound(40, true), 41, 99));
  // // OPTIONALS lower3() => testRange(db,  idb.KeyRange.lowerBound(40, open: false), 40, 99);
  // test('lower3',
  //     () => testRange(db, idb.KeyRange.lowerBound(40, false), 40, 99));
  //
  // test('upper1', () => testRange(db, idb.KeyRange.upperBound(40), 0, 40));
  // // OPTIONALS upper2() => testRange(db,  idb.KeyRange.upperBound(40, open: true), 0, 39);
  // test('upper2', () => testRange(db, idb.KeyRange.upperBound(40, true), 0, 39));
  // // upper3() => testRange(db,  idb.KeyRange.upperBound(40, open: false), 0, 40);
  // test(
  //     'upper3', () => testRange(db, idb.KeyRange.upperBound(40, false), 0, 40));
  //
  // test('bound1', () => testRange(db, idb.KeyRange.bound(20, 30), 20, 30));
  //
  // test('bound2', () => testRange(db, idb.KeyRange.bound(-100, 200), 0, 99));

  // bound3() =>
  //     // OPTIONALS testRange(db,  idb.KeyRange.bound(20, 30, upperOpen: true),
  //     testRange(db,  idb.KeyRange.bound(20, 30, false, true), 20, 29);
  //
  // bound4() =>
  //     // OPTIONALS testRange(db,  idb.KeyRange.bound(20, 30, lowerOpen: true),
  //     testRange(db,  idb.KeyRange.bound(20, 30, true), 21, 30);
  //
  // bound5() =>
  //     // OPTIONALS testRange(db,  idb.KeyRange.bound(20, 30, lowerOpen: true, upperOpen: true),
  //     testRange(db,  idb.KeyRange.bound(20, 30, true, true), 21, 29);
}
