// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';

// Test for Indexes.

var dbName = 'test_db_5';
var storeName = 'test_store';
var indexName = 'name_index';
late idb.Database db;
var value = {'name_index': 'one', 'value': 'add_value'};

Future testInit() async {
  final factory = idb.IdbFactory();
  // Delete any existing DBs.
  factory.deleteDatabase(dbName);

  // Open the database at version 1
  db = await factory.open(dbName);
  var objectStore = db.createObjectStore(storeName, autoIncrement: true);
  objectStore.createIndex(indexName, 'name_index', unique: false);

  // Allow the version change transaction to complete, should be needed only in unit testing.
  await Future.delayed(Duration(seconds: 1));

  return db;
}

Future testAddDelete() async {
  var transaction = db.transaction(storeName, 'readwrite');
  var key = await transaction.objectStore(storeName).add(value.jsify());
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  JSObject readValue = await transaction.objectStore(storeName).getObject(key);
  var dartObject = readValue.dartify() as Map;
  expect((dartObject)['value'], value['value']);
  await transaction.completed;
  transaction = db.transactionList([storeName], 'readwrite');
  await transaction.objectStore(storeName).delete(key);
  await transaction.completed;
  transaction = db.transactionList([storeName], 'readonly');
  var count = await transaction.objectStore(storeName).count();
  expect(count, 0);
}

Future testClearCount() async {
  var transaction = db.transaction(storeName, 'readwrite');
  transaction.objectStore(storeName).add(value.jsify());

  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  var count = await transaction.objectStore(storeName).count();
  expect(count, 1);
  await transaction.completed;
  transaction = db.transactionList([storeName], 'readwrite');
  transaction.objectStore(storeName).clear();
  await transaction.completed;
  transaction = db.transactionList([storeName], 'readonly');
  count = await transaction.objectStore(storeName).count();
  expect(count, 0);
}

Future testIndex() async {
  var transaction = db.transaction(storeName, 'readwrite');
  transaction.objectStore(storeName).add(value.jsify());
  transaction.objectStore(storeName).add(value.jsify());
  transaction.objectStore(storeName).add(value.jsify());
  transaction.objectStore(storeName).add(value.jsify());

  await transaction.completed;
  transaction = db.transactionList([storeName], 'readonly');
  var index = transaction.objectStore(storeName).index(indexName);
  var count = await index.count();
  expect(count, 4);
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  index = transaction.objectStore(storeName).index(indexName);
  var cursorsLength = await index.openCursor(autoAdvance: true).length;
  expect(cursorsLength, 4);
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  index = transaction.objectStore(storeName).index(indexName);
  cursorsLength = await index.openKeyCursor(autoAdvance: true).length;
  expect(cursorsLength, 4);
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  index = transaction.objectStore(storeName).index(indexName);
  JSObject readValue = await index.get('one');
  var dartObject = readValue.dartify() as Map;
  expect((dartObject)['value'], value['value']);
  await transaction.completed;
  transaction = db.transaction(storeName, 'readwrite');
  transaction.objectStore(storeName).clear();
  return transaction.completed;
}

Future testCursor() async {
  var deleteValue = {'name_index': 'two', 'value': 'delete_value'};
  var updateValue = {'name_index': 'three', 'value': 'update_value'};
  var updatedValue = {'name_index': 'three', 'value': 'updated_value'};
  var transaction = db.transaction(storeName, 'readwrite');
  transaction.objectStore(storeName).add(value.jsify());
  transaction.objectStore(storeName).add(deleteValue.jsify());
  transaction.objectStore(storeName).add(updateValue.jsify());

  await transaction.completed;
  transaction = db.transactionList([storeName], 'readwrite');
  var index = transaction.objectStore(storeName).index(indexName);
  var cursors = index.openCursor().asBroadcastStream();

  cursors.listen((cursor) {
    JSObject value = cursor.value;
    var dartObject = value.dartify() as Map;
    if ((dartObject)['value'] == 'delete_value') {
      cursor.delete().then((_) {
        cursor.next();
      });
    } else if (dartObject['value'] == 'update_value') {
      cursor.update(updatedValue.jsify()).then((_) {
        cursor.next();
      });
    } else {
      cursor.next();
    }
  });
  await cursors.last;
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  index = transaction.objectStore(storeName).index(indexName);
  JSObject readValue = await index.get('three');
  var dartObject = readValue.dartify() as Map;
  expect((dartObject)['value'], 'updated_value');
  await transaction.completed;
  transaction = db.transaction(storeName, 'readonly');
  index = transaction.objectStore(storeName).index(indexName);
  var readValue1 = await index.get('two');
  expect(readValue1, isNull);
  return transaction.completed;
}

main() {
  test('Indexes', () async {
    await testInit();
    await testAddDelete();
    await testClearCount();
    await testIndex();
    await testCursor();
  });
}
