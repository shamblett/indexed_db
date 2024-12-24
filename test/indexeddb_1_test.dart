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

Future testUpgrade() {
  var dbName = nextDatabaseName();
  var upgraded = false;

  // Delete any existing DBs.
  return window.indexedDB!.deleteDatabase(dbName).then((_) {
    return window.indexedDB
        .open(dbName, version: 1, onUpgradeNeeded: (e) {});
  }).then((db) {
    db.close();
  }).then((_) {
    return window.indexedDB!.open(dbName, version: 2,
        onUpgradeNeeded: (e) {
      expect(e.oldVersion, 1);
      expect(e.newVersion, 2);
      upgraded = true;
    });
  }).then((_) {
    expect(upgraded, isTrue);
  });
}

testReadWrite(key, value, matcher,
        [dbName,
        storeName = storeName,
        version = version,
        stringifyResult = false]) =>
    () {
      if (dbName == null) {
        dbName = nextDatabaseName();
      }
      createObjectStore(e) {
        idb.ObjectStore store = e.target.result.createObjectStore(storeName);
        expect(store, isNotNull);
      }

      late idb.Database db;
      return window.indexedDB!.deleteDatabase(dbName).then((_) {
        return window.indexedDB!
            .open(dbName, version: version, onUpgradeNeeded: createObjectStore);
      }).then((idb.Database result) {
        db = result;
        var transaction = db.transactionList([storeName], 'readwrite');
        transaction.objectStore(storeName).put(value, key);
        return transaction.completed;
      }).then((_) {
        var transaction = db.transaction(storeName, 'readonly');
        return transaction.objectStore(storeName).getObject(key);
      }).then((object) {
        db.close();
        if (stringifyResult) {
          // Stringify the numbers to verify that we're correctly returning ints
          // as ints vs doubles.
          expect(object.toString(), matcher);
        } else {
          expect(object, matcher);
        }
      }).whenComplete(() {
        return window.indexedDB!.deleteDatabase(dbName);
      });
    };

testReadWriteTyped(key, value, matcher,
        [dbName,
        String storeName = storeName,
        version = version,
        stringifyResult = false]) =>
    () {
      if (dbName == null) {
        dbName = nextDatabaseName();
      }
      void createObjectStore(e) {
        var store = e.target.result.createObjectStore(storeName);
        expect(store, isNotNull);
      }

      late idb.Database db;
      // Delete any existing DBs.
      return window.indexedDB!.deleteDatabase(dbName).then((_) {
        return window.indexedDB!
            .open(dbName, version: version, onUpgradeNeeded: createObjectStore);
      }).then((idb.Database result) {
        db = result;
        idb.Transaction transaction =
            db.transactionList([storeName], 'readwrite');
        transaction.objectStore(storeName).put(value, key);

        return transaction.completed;
      }).then((idb.Database result) {
        idb.Transaction transaction = db.transaction(storeName, 'readonly');
        return transaction.objectStore(storeName).getObject(key);
      }).then((object) {
        db.close();
        if (stringifyResult) {
          // Stringify the numbers to verify that we're correctly returning ints
          // as ints vs doubles.
          expect(object.toString(), matcher);
        } else {
          expect(object, matcher);
        }
      }).whenComplete(() {
        return window.indexedDB!.deleteDatabase(dbName);
      });
    };

void testTypes(testFunction) {
  test('String', testFunction(123, 'Hoot!', equals('Hoot!')));
  test('int', testFunction(123, 12345, equals(12345)));
  test('List', testFunction(123, [1, 2, 3], equals([1, 2, 3])));
  test('List 2', testFunction(123, [2, 3, 4], equals([2, 3, 4])));
  test('bool', testFunction(123, [true, false], equals([true, false])));
  test(
      'largeInt',
      testFunction(123, 1371854424211, equals("1371854424211"), null,
          storeName, version, true));
  test(
      'largeDoubleConvertedToInt',
      testFunction(123, 1371854424211.0, equals("1371854424211"), null,
          storeName, version, true));
  test(
      'largeIntInMap',
      testFunction(123, {'time': 4503599627370492},
          equals("{time: 4503599627370492}"), null, storeName, version, true));
  var now = new DateTime.now();
  test(
      'DateTime',
      testFunction(
          123,
          now,
          predicate((date) =>
              date.millisecondsSinceEpoch == now.millisecondsSinceEpoch)));
}

main() {
  // Test that indexed_db is properly flagged as supported or not.
  // Note that the rest of the indexed_db tests assume that this has been
  // checked.
  group('supported', () {
    test('supported', () {
      expect(idb.IdbFactory.supported, true);
    });
  });

  group('functional', () {
    test('throws when unsupported', () {
      var expectation = idb.IdbFactory.supported ? returnsNormally : throws;

      expect(() {
        var db = window.indexedDB!;
        db.open('random_db');
      }, expectation);
    });

    // Don't bother with these tests if it's unsupported.
    if (idb.IdbFactory.supported) {
      test('upgrade', testUpgrade);
      group('dynamic', () {
        testTypes(testReadWrite);
      });
      group('typed', () {
        testTypes(testReadWriteTyped);
      });
    }
  });
}
