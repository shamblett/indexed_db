/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett
 */

///
/// A client-side key-value store with support for indexes.
///
/// IndexedDB is a web standard API for client-side storage of
/// structured data. By storing data on the client in an IndexedDB,
/// apps can get advantages such as faster performance and
/// persistence.
///
/// In IndexedDB, each record is identified by a unique index or key,
/// making data retrieval speedy.
/// You can store structured data,
/// such as images, arrays, and maps using IndexedDB.
/// The standard does not specify size limits for individual data items
/// or for the database itself, but browsers may impose storage limits.
///
/// The classes in this library provide an interface
/// to the web package IndexedDB implementation.
///
/// All data in an IndexedDB is stored within an [ObjectStore].
/// To manipulate the database use [Transaction]s.
///
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

///
/// Version Change Event
///
extension type VersionChangeEvent._(IDBVersionChangeEvent event) {}

///
/// Factory - names idbFactory as per the dart:indexed_db API.
///
extension type idbFactory._(IDBFactory factory) {
  IDBOpenDBRequest deleteDatabase(String name) => factory.deleteDatabase(name);

  int cmp(Object first, Object second) =>
      factory.cmp(first.jsify(), second.jsify());

  Future<Database> open(String name,
      {int? version,
      void Function(VersionChangeEvent event)? onUpgradeNeeded,
      void Function(Event event)? onBlocked}) {
    final completer = Completer<Database>();
    if ((version == null) != (onUpgradeNeeded == null)) {
      return new Future.error(new ArgumentError(
          'Version and onUpgradeNeeded must be specified together'));
    }
    try {
      IDBOpenDBRequest request;
      if (version != null) {
        request = factory.open(name, version);
      } else {
        request = factory.open(name);
      }
      request.onsuccess = ((Event _) {
        completer.complete(Database.fromOpenRequest(request.result!));
      }).toJS;
      request.onblocked = ((Event e) {
        if (onBlocked != null) {
          onBlocked(e);
        } else {
          return Future.error(StateError('Request was blocked'));
        }
      }).toJS;
      request.onupgradeneeded = ((VersionChangeEvent e) {
        if (onUpgradeNeeded != null) {
          onUpgradeNeeded(e);
        } else {
          return Future.error(
              StateError('Upgrade needed, no handler supplied'));
        }
      }).toJS;
      return completer.future;
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  /// Checks to see if Indexed DB is supported on the current platform.
  bool get supported => true; // Always supported now.
}

///
/// Transaction
///
extension type Transaction._(IDBTransaction transaction) {}

///
/// Database
///
extension type Database._(IDBDatabase database) {
  Database.fromOpenRequest(JSAny result) : database = (result as IDBDatabase) {
    database.onabort = onAbortHandler();
  }

  List<String>? get objectStoreNames {
    final length = database.objectStoreNames.length;
    if (length == 0) {
      return null;
    }
    final res = <String>[];
    for (int i = 0; i <= length; i++) {
      res.add(database.objectStoreNames.item(i)!);
    }
    return res;
  }

  static final _abortValues = Expando<Event>();

  EventHandler onAbortHandler() {
    final event = Event('abort');
    _abortValues[(this as Object)] = event;
    return null;
  }

  String? get name => database.name;

  /// Stream of abort events handled by this Database.
  Stream<Event> get onAbort async* {
    yield _abortValues[(this as Object)]!;
  }

  Transaction transactionList(List<String> storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }
    List storeNames_1 = storeNames;
    return (database.transaction(storeNames_1.toJSBox, mode) as Transaction);
  }
}
