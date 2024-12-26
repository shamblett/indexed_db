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
import 'dart:js_interop';
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

  test('Open - Version - no upgrade needed callback', () async {
    var dbName = nextDatabaseName();
    final factory = idb.IdbFactory();

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);

    // Open the database at version 1 with no upgrade needed callback
    expect(
        factory.open(dbName, version: version), throwsA(isA<ArgumentError>()));
  });

  test('Open - Version - with upgrade needed callback', () async {
    var upgradeCalled = false;
    idb.VersionChangeEvent changeEvent = idb.VersionChangeEvent('test');
    void onUpgradeNeeded(idb.VersionChangeEvent event) {
      upgradeCalled = true;
      changeEvent = event;
    }

    var dbName = nextDatabaseName();
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

    var dbName = nextDatabaseName();
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

  test('Read Write', () async {
    var dbName = nextDatabaseName();
    final factory = idb.IdbFactory();
    late idb.Database database;
    late idb.ObjectStore objectStore;
    dynamic value;

    Future<T> runInTxn<T>(Future<T>? Function(idb.ObjectStore) requestCommand,
        [String txnMode = 'readwrite']) async {
      final trans = database.transaction(storeName, txnMode);
      trans.core.oncomplete = ((Event e) {
        print("TX complete called");
      }).toJS;
      final store = trans.objectStore(storeName);
      final result = await requestCommand(store)!;
      trans.commit();
      await trans.completed;
      return result;
    }

    Future<dynamic> save(String obj, String key) => runInTxn<dynamic>(
        (idb.ObjectStore store) async => store.put(obj, key));

    Future<dynamic> getByKey(String key) => runInTxn<dynamic>(
        (dynamic store) async => await store.getObject(key), 'readonly');

    void onUpgradeNeeded(idb.VersionChangeEvent event) async {
      database = (event.currentTarget as idb.OpenDBRequest).database;
      objectStore = database.createObjectStore(storeName);
      var key = await save('Value', 'Key');
      print('HHHkkk $key');
      value = await getByKey('Key');
      print('HHH $value');
      expect(value, 'Value');
    }

    // Delete any existing DBs.
    factory.deleteDatabase(dbName);
    print('Deleted database');

    // Open the database at version 1
    await factory.open(dbName,
        version: version, onUpgradeNeeded: onUpgradeNeeded);
    expect(database.name, dbName);
    expect(database.version, 1);
    expect(database.objectStoreNames, [storeName]);
    print('Created new database');

    expect(objectStore.name, storeName);

    // Await the completion of the version change transaction
    //await Future.delayed(Duration(seconds: 1));
    //print('Awaited VC transaction');
    // print('Checking value 1');
    // value.then((val) {
    //   print('Checking value');
    //   expect(value, 'Value');
    // });
    // Write some values using the transaction from the database
    //await save('Value', 'Key');
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
    await Future.delayed(Duration(seconds: 10));
    // Close the database
    database.close();
  });
}
