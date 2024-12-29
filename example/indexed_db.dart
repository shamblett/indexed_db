/*
* Package : indexed_db
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 18/12/2024
* Copyright :  S.Hamblett - updates only
*/

// Copyright (c) 2020, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license.

import 'dart:js_interop';

import 'package:indexed_db/indexed_db.dart' as idb;

const storeName = 'IDBTestStore';
const int version = 1;

void printValues(String message, dynamic key, dynamic value) =>
    print('EXAMPLE - $message - Key $key, Value $value');

void main() async {
  var dbName = 'IDBTestDatabase';
  final factory = idb.IdbFactory();

  // Delete any existing DBs.
  factory.deleteDatabase(dbName);
  print('EXAMPLE - Deleted database');

  // Open the database.
  var database = await factory.openCreate(dbName, storeName);
  print(
      'EXAMPLE - Created new database and object store, database is $dbName, store is $storeName');

  // Write some values using the transaction from the database;
  var transaction = database.transactionList([storeName], 'readwrite');
  print('');
  print('EXAMPLE - Writing values');
  print('');
  printValues('Writing', 'String', 'Value');
  transaction.objectStore(storeName).put('Value', 'Key');
  printValues('Writing', 'Int', 10);
  transaction.objectStore(storeName).put(10, 'Int');
  printValues('Writing', 'List', [1, 2, 3]);
  transaction.objectStore(storeName).put([1, 2, 3], 'List');
  printValues('Writing', 'Map', {'first': 1, 'second': 2});
  // Jsify maps for storage
  transaction
      .objectStore(storeName)
      .put({'first': 1, 'second': 2}.jsify(), 'Map');
  printValues('Writing', 'Bool', true);
  transaction.objectStore(storeName).put(true, 'Bool');

  // Wait for the transaction to complete
  await transaction.completed;

  // Check the values
  transaction = database.transactionList([storeName], 'readonly');
  print('');
  print('EXAMPLE - Reading values');
  print('');
  var value = await transaction.objectStore(storeName).getObject('Key');
  printValues('Reading', 'Key', value);
  value = await transaction.objectStore(storeName).getObject('Int');
  printValues('Reading', 'Int', value);
  value = await transaction.objectStore(storeName).getObject('List');
  printValues('Reading', 'List', value);
  // Dartify maps when retrieved
  JSObject valueMap = await transaction.objectStore(storeName).getObject('Map');
  printValues('Reading', 'Map', valueMap);
  value = await transaction.objectStore(storeName).getObject('Bool');
  printValues('Reading', 'Bool', value);

  // Close the database
  print('EXAMPLE -  Closing Database');
  database.close();
}
