/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett - updates only
 */

@TestOn('browser')
@Timeout(Duration(seconds: 60))
library;

import 'dart:js_interop';

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';

// Basic database create, open and read write value tests

const storeName = 'TEST';
const int version = 1;
const dbName = 'TESTDB';

main() {
  test('Supported', () {
    expect(idb.IdbFactory.supported, true);
  });

  test('Open - No Version', () async {
    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open the database at version 1
    final database = await factory.open(dbName);
    expect(database.name, dbName);
    expect(database.version, 1);
    expect(database.objectStoreNames, isNull);
  });

  test('Open - Version - with upgrade needed callback', () async {
    var upgradeCalled = false;
    idb.VersionChangeEvent changeEvent = idb.VersionChangeEvent('test');
    void onUpgradeNeeded(idb.VersionChangeEvent event) {
      upgradeCalled = true;
      changeEvent = event;
    }

    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open the database at version 1
    final database = await factory.open(dbName,
        version: version, onUpgradeNeeded: onUpgradeNeeded);
    expect(database, isNotNull);
    expect(database.name, dbName);
    expect(database.version, 1);
    expect(database.objectStoreNames, isNull);
    expect(upgradeCalled, isTrue);
    expect(changeEvent.oldVersion, 0);
    expect(changeEvent.newVersion, 1);
  });

  test('Open - Version - with upgrade needed for new version', () async {
    var upgradeCalled1 = false;
    var upgradeCalled2 = false;
    idb.VersionChangeEvent changeEvent1 = idb.VersionChangeEvent('V1');
    idb.VersionChangeEvent changeEvent2 = idb.VersionChangeEvent('V2');
    void onUpgradeNeeded1(idb.VersionChangeEvent event) {
      upgradeCalled1 = true;
      changeEvent1 = event;
    }

    void onUpgradeNeeded2(idb.VersionChangeEvent event) {
      upgradeCalled2 = true;
      changeEvent2 = event;
    }

    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open the database at version 1
    var database = await factory.open(dbName,
        version: version, onUpgradeNeeded: onUpgradeNeeded1);
    expect(database, isNotNull);
    expect(database.name, dbName);
    expect(database.version, 1);
    expect(database.objectStoreNames, isNull);
    expect(upgradeCalled1, isTrue);
    expect(changeEvent1.oldVersion, 0);
    expect(changeEvent1.newVersion, 1);

    // Close this database
    database.close();

    // Open the database at version 2
    database = await factory.open(dbName,
        version: version + 1, onUpgradeNeeded: onUpgradeNeeded2);
    expect(database, isNotNull);
    expect(database.name, dbName);
    expect(database.version, 2);
    expect(database.objectStoreNames, isNull);
    expect(upgradeCalled2, isTrue);
    expect(changeEvent2.oldVersion, 1);
    expect(changeEvent2.newVersion, 2);
  });

  test('Read Write - with upgrade needed callback', () async {
    late idb.ObjectStore objectStore;
    late idb.Database database;
    late idb.IdbFactory factory;

    void upgradeNeeded(idb.VersionChangeEvent event) async {
      // Save the database and create the object store
      database = event.target.database;
      objectStore = database.createObjectStore(storeName);
    }

    factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open and check the database at version 1
    await factory.open(dbName, version: 1, onUpgradeNeeded: upgradeNeeded);
    expect(database.name, dbName);
    expect(database.version, 1);

    // Check the object store
    expect(objectStore.name, storeName);
    expect(database.objectStoreNames, [storeName]);

    // Write some values using the transaction from the database;
    var transaction = database.transactionList([storeName], 'readwrite');
    transaction.objectStore(storeName).put('Value', 'Key');
    transaction.objectStore(storeName).put(10, 'Int');
    transaction.objectStore(storeName).put([1, 2, 3], 'List');
    // Jsify maps for storage
    transaction
        .objectStore(storeName)
        .put({'first': 1, 'second': 2}.jsify(), 'Map');
    transaction.objectStore(storeName).put(true, 'Bool');
    await transaction.completed;

    // Check the values
    transaction = database.transactionList([storeName], 'readonly');
    var value = await transaction.objectStore(storeName).getObject('Key');
    expect(value, 'Value');
    value = await transaction.objectStore(storeName).getObject('Int');
    expect(value, 10);
    value = await transaction.objectStore(storeName).getObject('List');
    expect(value, [1, 2, 3]);
    // Dartify maps
    JSObject valueMap =
        await transaction.objectStore(storeName).getObject('Map');
    expect(valueMap.dartify(), {'first': 1, 'second': 2});
    value = await transaction.objectStore(storeName).getObject('Bool');
    expect(value, isTrue);

    // Close the database
    database.close();
  });

  test('Read Write - with open create', () async {
    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open and check the database at version 1
    final result = await factory.openCreate(dbName, storeName);
    final database = result.database;
    expect(database.name, dbName);
    expect(database.version, 1);

    // Check the object store
    expect(database.objectStoreNames, [storeName]);

    // Write some values using the transaction from the database;
    var transaction = database.transactionList([storeName], 'readwrite');
    transaction.objectStore(storeName).put('Value', 'Key');
    transaction.objectStore(storeName).put(10, 'Int');
    transaction.objectStore(storeName).put([1, 2, 3], 'List');
    // Jsify maps for storage
    transaction
        .objectStore(storeName)
        .put({'first': 1, 'second': 2}.jsify(), 'Map');
    transaction.objectStore(storeName).put(true, 'Bool');
    await transaction.completed;

    // Check the values
    transaction = database.transactionList([storeName], 'readonly');
    var value = await transaction.objectStore(storeName).getObject('Key');
    expect(value, 'Value');
    value = await transaction.objectStore(storeName).getObject('Int');
    expect(value, 10);
    value = await transaction.objectStore(storeName).getObject('List');
    expect(value, [1, 2, 3]);
    // Dartify maps
    JSObject valueMap =
        await transaction.objectStore(storeName).getObject('Map');
    expect(valueMap.dartify(), {'first': 1, 'second': 2});
    value = await transaction.objectStore(storeName).getObject('Bool');
    expect(value, isTrue);

    // Close the database
    database.close();
  });
}
