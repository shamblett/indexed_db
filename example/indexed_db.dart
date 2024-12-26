/*
* Package : indexed_db
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 18/12/2024
* Copyright :  S.Hamblett - updates only
*/

// Copyright (c) 2020, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license.

// ignore: deprecated_member_use
import 'dart:async';

import 'package:indexed_db/indexed_db.dart' as idb;

const storeName = 'TEST';
const int version = 1;

int databaseNameIndex = 0;
String nextDatabaseName() {
  return 'Test1_${databaseNameIndex++}';
}

void main() async {
  var dbName = nextDatabaseName();
  final factory = idb.IdbFactory();
  late idb.Database db;

  Future<T> _runInTxn<T>(Future<T>? Function(idb.ObjectStore) requestCommand,
      [String txnMode = 'readwrite']) async {
    final trans = db.transaction(storeName, txnMode);
    final store = trans.objectStore(storeName);
    final result = await requestCommand(store)!;
    await trans.completed;
    return result;
  }

  Future<String> save(String obj, String key) =>
      _runInTxn<String>((dynamic store) async => await store.put(obj, key));

  Future<dynamic> getByKey(String key) => _runInTxn<dynamic>(
      (dynamic store) async => await store.getObject(key), 'readonly');

  // Delete any existing DBs.
  factory.deleteDatabase(dbName);
  print('Deleted database');

  // Open the database at version 1
  var database = await factory.open(dbName);
  db = database;

  print('Created new database');

  // Create the object store
  final objectStore = database.createObjectStore(storeName);
  print('Object store created');

  // Await the completion of the version change transaction
  await Future.delayed(Duration(seconds: 1));
  print('Awaited VC transaction');

  // Write some values using the transaction from the database
  print('Saving');
  await save('Value', 'Key');
  print('Getting');
  var value = await getByKey('Key');
  print('Value is $value');
  // transaction.objectStore(storeName).put(10, 'Int');
  // print('Value2');
  // transaction.objectStore(storeName).put([1, 2, 3], 'List');
  // print('Value3');
  // // transaction.objectStore(storeName).put({'first': 1, 'second': 2}, 'Map');
  // // print('Value4');
  // transaction.objectStore(storeName).put(true, 'Bool');
  // print('Value5');

  // Check the values
  // print('Checking values');
  // transaction = database.transactionList([storeName], 'readonly');
  // //var value = await transaction.objectStore(storeName).getObject('Key');
  // var value = await objectStore.getObject('Key');
  // expect(value, 'Value');
  // value = await transaction.objectStore(storeName).getObject('Int');
  // expect(value, 10);
  // value = await transaction.objectStore(storeName).getObject('List');
  // expect(value, [1, 2, 3]);
  // value = await transaction.objectStore(storeName).getObject('Map');
  // expect(value, {'first': 1, 'second': 2});
  // value = await transaction.objectStore(storeName).getObject('Bool');
  // expect(value, isTrue);

  // Close the database
  database.close();
}
