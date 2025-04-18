/*
* Package : indexed_db
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 18/12/2024
* Copyright :  S.Hamblett - updates only
*/

import 'dart:js_interop';

import 'package:indexed_db/indexed_db.dart' as idb;

const storeName = 'IDBTestStore';
const int version = 1;

void printValues(String message, dynamic key, dynamic value) =>
    print('EXAMPLE - $message - Key $key, Value $value');

///
/// An example of how to create a database and object store for simple key/value storage and retrieval.
/// Use for simple index_db use cases where more advanced functionality such as indexes etc. is not
/// needed.
void main() async {
  var dbName = 'IDBTestDatabase';
  final factory = idb.IdbFactory();

  print('');
  print('EXAMPLE - Start');
  print('');

  // Delete any existing database.
  factory.deleteDatabase(dbName);
  print('EXAMPLE - Deleted database');

  // Open the database and create the object store in one go.
  // Compare with the factory.open method where an on version change callback
  // must be supplied.
  final result = await factory.openCreate(dbName, storeName);
  final database = result.database;
  print(
    'EXAMPLE - Created new database and object store, database is $dbName, store is $storeName',
  );

  // All database updates and retrievals must be performed in the context of a transaction.

  // Write some values using the transaction obtained from the database.
  // We are updating the database here so the transaction mode is 'readwrite'.
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

  // Wait for the transaction to complete before moving on.
  await transaction.completed;

  // Check the values, again using a transaction from the database.
  // We are reading the database here so the transaction mode is 'readonly'.
  transaction = database.transactionList([storeName], 'readonly');
  print('');
  print('EXAMPLE - Reading values');
  print('');
  var value = await transaction.objectStore(storeName).getObject('Key');
  printValues('Reading', 'String', value);
  value = await transaction.objectStore(storeName).getObject('Int');
  printValues('Reading', 'Int', value);
  value = await transaction.objectStore(storeName).getObject('List');
  printValues('Reading', 'List', value);
  // Dartify maps when retrieved
  JSObject valueMap = await transaction.objectStore(storeName).getObject('Map');
  final readMap = valueMap.dartify() as Map;
  printValues('Reading', 'Map', readMap);
  value = await transaction.objectStore(storeName).getObject('Bool');
  printValues('Reading', 'Bool', value);

  // Close the database
  print('EXAMPLE -  Closing Database');
  database.close();

  print('');
  print('EXAMPLE - Complete');
}
