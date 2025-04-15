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
/// An example of how to create a database and object store for more advanced use cases.
/// Allows for the creation of indexes and any other functionality that may need to be
/// run in the context of an on upgrade needed transaction.
void main() async {
  var dbName = 'IDBTestDatabase';
  final factory = idb.IdbFactory();
  late idb.Database database;

  // The on upgrade needed callback. This function runs in the context
  // of the version change transaction. Any indexed_db functionality that must
  // be run in the context of the version change transaction must be put in here.
  void upgradeNeeded(idb.VersionChangeEvent event) async {
    // Get the database from the OpenDBRequest result
    database = event.target.database;

    // You must create your object store here.
    database.createObjectStore(storeName);

    // Add any functionality needed that needs to be done in this call back,
    // example, create an index -
    // objectStore.createIndex('name_index', 'name_index', unique: false);
  }

  print('');
  print('EXAMPLE - Start');
  print('');

  // Delete any existing database.
  factory.deleteDatabase(dbName);
  print('EXAMPLE - Deleted database');

  // Create and open a database using the on upgrade needed callback.
  // Allows specification of the version you wish to create and fine grained
  // control of the creation process in the upgradeNeeded callback.
  await factory.open(dbName, version: 1, onUpgradeNeeded: upgradeNeeded);
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
