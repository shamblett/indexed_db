/*
 * Package : indexed_db
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 18/12/2024
 * Copyright :  S.Hamblett
 */

// Original API copyright
// Copyright (c) 2020, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license.

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
///
/// You can store structured data,
/// such as images, arrays, and maps using IndexedDB.
/// The standard does not specify size limits for individual data items
/// or for the database itself, but browsers may impose storage limits.
///
/// ## Using indexed_db
///
/// This library provide an interface
/// to the browser's IndexedDB functionality, specifically it wraps the provided IDBxxx
/// interfaces to provide a more coherent means of access.
///
/// To use this library in your code:
///
///     import 'package:indexed_db/indexed_db';
///
/// Here's how to use IdbFactory to open a database and object store:
///
///      final factory = IdbFactory();
///      final result  = await factory.openCreate(dbName, storeName);
///      final database = result.database;
///      final objectStore = result.objectStore;
///
/// You can also use [IdbFactory.open] and pass an upgrade needed callback if you need
/// finer control of the creation process. Note that if you are using certain indexed_db
/// facilities such a creating indexes you must use this method.
///
/// All data in an IndexedDB is stored within an [ObjectStore].
/// To manipulate the database use [Transaction]s.
///
/// ## Other resources
///
/// Other options for client-side data storage include:
///
/// * [Window.localStorage]&mdash;a
/// basic mechanism that stores data as a [Map],
/// and where both the keys and the values are strings.
///
/// MDN provides [API
/// documentation](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API).
///
library;

// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

///
/// Type defines
///
typedef DomException = DOMException;

///
/// Helper class for [openCreate] return value
class OpenCreateResult {
  OpenCreateResult(this.database, this.objectStore);
  Database database;
  ObjectStore objectStore;
}

/// Version Change Event
///
extension type VersionChangeEvent._(IDBVersionChangeEvent event)
    implements Event {
  VersionChangeEvent.fromOpen(this.event);

  factory VersionChangeEvent(String type, [Map? eventInitDict]) {
    if (eventInitDict != null) {
      var eventInitDict_1 = eventInitDict;
      return VersionChangeEvent._create_1(type, eventInitDict_1);
    }
    return VersionChangeEvent._create_2(type);
  }

  static VersionChangeEvent _create_1(type, eventInitDict) =>
      (IDBVersionChangeEvent(type, eventInitDict) as VersionChangeEvent);

  static VersionChangeEvent _create_2(type) =>
      (IDBVersionChangeEvent(type) as VersionChangeEvent);

  int? get newVersion => event.newVersion;

  int? get oldVersion => event.oldVersion;

  OpenDBRequest get target =>
      OpenDBRequest._fromVersionChangeRequest(event.target as IDBOpenDBRequest);

  /// Allows access to the underlying IDB interface.
  IDBVersionChangeEvent get idbObject => event;
}

///
/// Request
///
extension type Request._(IDBRequest request) implements EventTarget {
  Request._fromObjectStore(this.request);

  Request._fromCursor(this.request);

  Request._fromIndex(this.request);

  Request._fromFactory(this.request);

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> successEvent =
      EventStreamProvider<ProgressEvent>('success');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');

  DomException? get error => request.error;

  /// Stream of error events handled by this [Request].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of success events handled by this [Request].
  Stream<Event> get onSuccess => successEvent.forTarget(this);

  String? get readyState => request.readyState;

  dynamic get result => request.result;

  Object? get source => request.source;

  Transaction? get transaction =>
      Transaction._fromRequest(request.transaction!);

  /// Allows access to the underlying IDB interface.
  IDBRequest get idbObject => request;
}

///
/// Cursor With Value
///
extension type CursorWithValue._(IDBCursorWithValue cursor) {
  CursorWithValue._fromObjectStore(this.cursor);

  dynamic get value => cursor.value;

  String? get direction => cursor.direction;

  Object? get key => cursor.key;

  Object? get primaryKey => cursor.primaryKey;

  Object? get source => cursor.source;

  void advance(int count) => cursor.advance(count);

  void continuePrimaryKey(Object key, Object primaryKey) =>
      cursor.continuePrimaryKey(key.jsify(), primaryKey.jsify());

  Future delete() {
    try {
      return _completeRequest(Request._fromCursor(cursor.delete()));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  void next([Object? key]) => cursor.continue_(key.jsify());

  Future update(dynamic value) {
    try {
      return _completeRequest(Request._fromCursor(cursor.update(value)));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  /// Allows access to the underlying IDB interface.
  IDBCursorWithValue get idbObject => cursor;
}

///
/// Cursor
///
extension type Cursor._(IDBCursor cursor) {
  Cursor._fromObjectStore(this.cursor);

  String? get direction => cursor.direction;

  Object? get key => cursor.key;

  Object? get primaryKey => cursor.primaryKey;

  Object? get source => cursor.source;

  void advance(int count) => cursor.advance(count);

  void continuePrimaryKey(Object key, Object primaryKey) =>
      cursor.continuePrimaryKey(key.jsify(), primaryKey.jsify());

  Future delete() {
    try {
      return _completeRequest(Request._fromCursor(cursor.delete()));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  void next([Object? key]) => cursor.continue_(key.jsify());

  Future update(dynamic value) {
    try {
      return _completeRequest(Request._fromCursor(cursor.update(value)));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  /// Allows access to the underlying IDB interface.
  IDBCursor get idbObject => cursor;
}

///
/// Factory - named IdbFactory as per the dart:indexed_db API.
///
extension type IdbFactory._(IDBFactory factory) {
  IdbFactory() : factory = window.indexedDB;

  IDBOpenDBRequest deleteDatabase(String name) => factory.deleteDatabase(name);

  int cmp(Object first, Object second) =>
      factory.cmp(first.jsify(), second.jsify());

  Future<Database> open(
    String name, {
    int? version,
    void Function(VersionChangeEvent event)? onUpgradeNeeded,
    void Function(Event event)? onBlocked,
  }) {
    if ((version == null) != (onUpgradeNeeded == null)) {
      return Future.error(
        ArgumentError('Version and onUpgradeNeeded must be specified together'),
      );
    }
    try {
      OpenDBRequest request;
      if (version != null) {
        request = OpenDBRequest._fromFactory(factory.open(name, version));
      } else {
        request = OpenDBRequest._fromFactory(factory.open(name));
      }

      if (onUpgradeNeeded != null) {
        request.onUpgradeNeeded.listen(onUpgradeNeeded);
      }
      if (onBlocked != null) {
        request.onBlocked.listen(onBlocked);
      }
      return _completeRequest(Request._fromFactory(request.idbObject));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  ///
  /// Opens a database and creates an object store.
  ///
  /// Allows the setting of object store creation parameters if
  /// needed, See [Database.createObjectStore]
  /// Obviates the need for an on upgrade needed callback.
  ///
  /// The [OpenCreateResult] contains both the database and the object store
  ///
  /// Note: not part of the original dart:indexed_db implementation.
  Future<OpenCreateResult> openCreate(
    String dbName,
    String objectStoreName, {
    keyPath,
    bool? autoIncrement,
  }) async {
    late Database database;
    late ObjectStore objectStore;

    void upgradeNeeded(VersionChangeEvent event) async {
      database = event.target.database;
      objectStore = database.createObjectStore(
        objectStoreName,
        keyPath: keyPath,
        autoIncrement: autoIncrement,
      );
    }

    try {
      OpenDBRequest request;
      final completer = Completer<OpenCreateResult>();
      request = OpenDBRequest._fromFactory(factory.open(dbName));
      request.onUpgradeNeeded.listen(upgradeNeeded);
      _completeRequest(Request._fromFactory(request.idbObject)).then(
        (_) => completer.complete(OpenCreateResult(database, objectStore)),
      );
      return completer.future;
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  /// Checks to see if Indexed DB is supported on the current platform.
  static bool get supported => true; // Always supported now.

  /// Allows access to the underlying IDB interface.
  IDBFactory get idbObject => factory;
}

///
/// Transaction
///
extension type Transaction._(IDBTransaction transaction)
    implements EventTarget {
  Transaction._fromDatabase(this.transaction);

  Transaction._fromObjectStore(this.transaction);

  Transaction._fromRequest(this.transaction);

  Transaction._fromOpenRequest(this.transaction);

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');
  static const EventStreamProvider<Event> completeEvent =
      EventStreamProvider<ProgressEvent>('complete');

  /// Stream of error events handled by this [Transaction].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of abort events handled by this [Transaction].
  Stream<Event> get onAbort => abortEvent.forTarget(this);

  /// Stream of complete events handled by this [Transaction].
  Stream<Event> get onComplete => completeEvent.forTarget(this);

  /// Provides a Future which will be completed once the transaction has completed.
  /// The future will error if an error occurs on the transaction or if the transaction is aborted.
  Future<Database> get completed {
    final completer = Completer<Database>();

    onComplete.listen((_) {
      completer.complete(Database._fromTransaction(transaction.db));
    });

    onError.listen((e) {
      completer.completeError(e);
    });

    onAbort.listen((e) {
      // Avoid completing twice if an error occurs.
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Database? get db => Database._fromTransaction(transaction.db);

  DomException? get error => transaction.error;

  String? get mode => transaction.mode;

  List<String>? get objectStoreNames =>
      _domStringsToList(transaction.objectStoreNames);

  void abort() => transaction.abort();

  ObjectStore objectStore(String name) =>
      ObjectStore._fromTransaction(transaction.objectStore(name));

  IDBTransaction get core => transaction;

  void commit() => transaction.commit();

  /// Allows access to the underlying IDB interface.
  IDBTransaction get idbObject => transaction;
}

///
/// Index
///
extension type Index._(IDBIndex index) {
  Index._fromObjectStore(this.index);

  Object? get keyPath => index.keyPath;

  bool? get multiEntry => index.multiEntry;

  String? get name => index.name;

  ObjectStore? get objectStore => ObjectStore._fromIndex(index.objectStore);

  bool? get unique => index.unique;

  Future<int> count([dynamic key_OR_range]) {
    try {
      final Request request = Request._fromIndex(index.count(key_OR_range));
      return _completeRequest(request);
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Future get(dynamic key) {
    try {
      final Request request = Request._fromIndex(index.get(key));
      return _completeRequest(request);
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Request getAll(Object? query, [int? count]) =>
      Request._fromIndex(index.getAll(query.jsify(), count ?? 0));

  Request getAllKeys(Object? query, [int? count]) =>
      Request._fromIndex(index.getAllKeys(query.jsify(), count ?? 0));

  Future getKey(dynamic key) {
    try {
      final Request request = Request._fromIndex(index.getKey(key));
      return _completeRequest(request);
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Stream<CursorWithValue> openCursor({
    dynamic key,
    KeyRange? range,
    String? direction,
    bool? autoAdvance,
  }) {
    dynamic key_OR_range;
    if (key != null) {
      if (range != null) {
        throw ArgumentError('Cannot specify both key and range.');
      }
      key_OR_range = key;
    } else {
      key_OR_range = range;
    }
    Request request;
    if (direction == null) {
      request = Request._fromIndex(index.openCursor(key_OR_range, "next"));
    } else {
      request = Request._fromIndex(index.openCursor(key_OR_range, direction));
    }
    return ObjectStore._cursorWithValueStreamFromResult(request, autoAdvance);
  }

  /// Creates a stream of cursors over the records in this object store.
  /// See also [ObjectStore.openCursor]
  Stream<Cursor> openKeyCursor({
    dynamic key,
    KeyRange? range,
    String? direction,
    bool? autoAdvance,
  }) {
    dynamic key_OR_range;
    if (key != null) {
      if (range != null) {
        throw ArgumentError('Cannot specify both key and range.');
      }
      key_OR_range = key;
    } else {
      key_OR_range = range;
    }
    Request request;
    if (direction == null) {
      request = Request._fromIndex(index.openKeyCursor(key_OR_range, "next"));
    } else {
      request = Request._fromIndex(
        index.openKeyCursor(key_OR_range, direction),
      );
    }
    return ObjectStore._cursorStreamFromResult(request, autoAdvance);
  }

  /// Allows access to the underlying IDB interface.
  IDBIndex get idbObject => index;
}

///
/// Key Range
///
extension type KeyRange._(IDBKeyRange keyrange) {
  KeyRange.bound(
    dynamic lower,
    dynamic upper, [
    bool lowerOpen = false,
    bool upperOpen = false,
  ]) : keyrange = IDBKeyRange.bound(lower, upper, lowerOpen, upperOpen);

  KeyRange.lowerBound(dynamic bound, [bool open = false])
    : keyrange = IDBKeyRange.lowerBound(bound, open);

  KeyRange.only(dynamic value) : keyrange = IDBKeyRange.only(value);

  KeyRange.upperBound(dynamic bound, [bool open = false])
    : keyrange = IDBKeyRange.upperBound(bound, open);

  Object? get lower => keyrange.lower;

  Object? get lowerOpen => keyrange.lowerOpen;

  Object? get upper => keyrange.upper;

  Object? get upperOpen => keyrange.upperOpen;

  bool includes(Object key) => keyrange.includes(key.jsify());

  static KeyRange bound_(
    Object lower,
    Object upper, [
    bool? lowerOpen,
    bool? upperOpen,
  ]) => KeyRange.bound(lower, upper, lowerOpen ?? false, upperOpen ?? false);

  static KeyRange lowerBound_(Object bound, [bool? open]) =>
      KeyRange.lowerBound(bound, open ?? false);

  static KeyRange only_(Object value) => KeyRange.only(value);

  static KeyRange upperBound_(Object bound, [bool? open]) =>
      KeyRange.upperBound(bound, open ?? false);

  /// Allows access to the underlying IDB interface.
  IDBKeyRange get idbObject => keyrange;
}

///
/// Database
///
/// An indexed database object for storing client-side data in web apps.
///
extension type Database._(IDBDatabase database) implements EventTarget {
  Database(this.database);

  Database._fromOpenRequest(JSAny? result) : database = (result as IDBDatabase);

  Database._fromTransaction(this.database);

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');
  static const EventStreamProvider<Event> closeEvent =
      EventStreamProvider<ProgressEvent>('close');
  static const EventStreamProvider<VersionChangeEvent> versionChangeEvent =
      EventStreamProvider<VersionChangeEvent>('versionchange');

  String? get name => database.name;

  /// Stream of abort events handled by this [Database].
  Stream<Event> get onAbort => abortEvent.forTarget(this);

  /// Stream of close events handled by this [Database].
  Stream<Event> get onClose => closeEvent.forTarget(this);

  /// Stream of error events handled by this [Database].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of version change events handled by this [Database].
  Stream<VersionChangeEvent> get onVersionChange =>
      versionChangeEvent.forTarget(this);

  int? get version => database.version;

  void close() => database.close();

  ObjectStore createObjectStore(
    String name, {
    dynamic keyPath,
    bool? autoIncrement,
  }) {
    final options = IDBObjectStoreParameters(
      keyPath: keyPath?.jsify(),
      autoIncrement: autoIncrement ?? false,
    );

    final objectStore = database.createObjectStore(name, options);
    return ObjectStore._fromCreateRequest(objectStore);
  }

  Transaction transaction(dynamic storeName_OR_storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw ArgumentError(mode);
    }
    final transaction = database.transaction(storeName_OR_storeNames, mode);
    return Transaction._fromDatabase(transaction);
  }

  Transaction transactionList(List<String> storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw ArgumentError(mode);
    }
    final transaction = database.transaction(storeNames.jsify()!, mode);
    return Transaction._fromDatabase(transaction);
  }

  Transaction transactionStore(String storeName, String mode) =>
      transaction(storeName, mode);

  Transaction transactionStores(List<String> storeName, String mode) =>
      transactionList(storeName, mode);

  void deleteObjectStore(String name) => database.deleteObjectStore(name);

  List<String>? get objectStoreNames =>
      _domStringsToList(database.objectStoreNames);

  /// Allows access to the underlying IDB interface.
  IDBDatabase get idbObject => database;
}

///
/// Open DB Request
///
extension type OpenDBRequest._(IDBOpenDBRequest openrequest)
    implements EventTarget {
  OpenDBRequest._fromVersionChangeRequest(this.openrequest);

  OpenDBRequest._fromFactory(this.openrequest);

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> blockedEvent =
      EventStreamProvider<ProgressEvent>('blocked');
  static const EventStreamProvider<VersionChangeEvent> upgradeNeededEvent =
      EventStreamProvider<VersionChangeEvent>('upgradeneeded');

  /// Stream of blocked events handled by this [OpenDBRequest].
  Stream<Event> get onBlocked => blockedEvent.forTarget(this);

  /// Stream of upgrade needed events handled by this [OpenDBRequest].
  Stream<VersionChangeEvent> get onUpgradeNeeded =>
      upgradeNeededEvent.forTarget(this);

  DOMException? get error => openrequest.error;

  Transaction get transaction =>
      Transaction._fromOpenRequest(openrequest.transaction!);

  JSAny? get result => openrequest.result;

  ///
  /// Get the database created by the open request
  /// Convenience function, use only you know the context of what you are
  /// doing, i.e a database open request.
  Database get database => Database._fromOpenRequest(result);

  /// Allows access to the underlying IDB interface.
  IDBOpenDBRequest get idbObject => openrequest;
}

///
/// Object Store
///
extension type ObjectStore._(IDBObjectStore store) {
  ObjectStore._fromCreateRequest(objectStore) : store = objectStore;
  ObjectStore._fromIndex(this.store);
  ObjectStore._fromTransaction(this.store);

  bool? get autoIncrement => store.autoIncrement;

  List<String>? get indexNames => _domStringsToList(store.indexNames);

  Object? get keyPath => store.keyPath;

  String? get name => store.name;

  Transaction? get transaction =>
      Transaction._fromObjectStore(store.transaction);

  Future add(dynamic value, [dynamic key]) {
    try {
      final IDBRequest request;
      if (key != null) {
        request = store.add(value, key);
      } else {
        request = store.add(value);
      }
      return _completeRequest(Request._fromObjectStore(request));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Future clear() {
    try {
      return _completeRequest(Request._fromObjectStore(store.clear()));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Future<int> count([dynamic key_OR_range]) {
    try {
      var request = store.count(key_OR_range);
      return _completeRequest(Request._fromObjectStore(request));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Index createIndex(
    String name,
    dynamic keyPath, {
    bool? unique,
    bool? multiEntry,
  }) {
    final options = IDBIndexParameters();
    if (unique != null) {
      options.unique = unique;
    }
    if (multiEntry != null) {
      options.multiEntry = multiEntry;
    }
    return Index._fromObjectStore(store.createIndex(name, keyPath, options));
  }

  Future delete(dynamic key_OR_keyRange) {
    try {
      return _completeRequest(
        Request._fromObjectStore(store.delete(key_OR_keyRange)),
      );
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  void deleteIndex(String name) => store.deleteIndex(name);

  Request getAll(Object? query, [int? count]) =>
      Request._fromObjectStore(store.getAll(query.jsify(), count ?? 0));

  Request getAllKeys(Object? query, [int? count]) =>
      Request._fromObjectStore(store.getAllKeys(query.jsify(), count ?? 0));

  Request getKey(Object key) =>
      Request._fromObjectStore(store.getKey(key.jsify()));

  Future getObject(dynamic key) {
    try {
      final request = store.get(key);
      return _completeRequest(Request._fromObjectStore(request));
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  Index index(String name) => Index._fromObjectStore(store.index(name));

  ///
  ///  Creates a stream of cursors over the records in this object store.
  ///
  /// **The stream must be manually advanced by calling [Cursor.next] after
  /// each item or by specifying autoAdvance to be true.**
  ///
  ///     var cursors = objectStore.openCursor().listen(
  ///       (cursor) {
  ///         // ...some processing with the cursor
  ///         cursor.next(); // advance onto the next cursor.
  ///       },
  ///       onDone: () {
  ///         // called when there are no more cursors.
  ///         print('all done!');
  ///       });
  ///
  /// Asynchronous operations which are not related to the current transaction
  /// will cause the transaction to automatically be committed-- all processing
  /// must be done synchronously unless they are additional async requests to
  /// the current transaction.
  ///
  Stream<CursorWithValue> openCursor({
    dynamic key,
    KeyRange? range,
    String? direction,
    bool? autoAdvance,
  }) {
    dynamic key_OR_range;
    if (key != null) {
      if (range != null) {
        throw ArgumentError('Cannot specify both key and range.');
      }
      key_OR_range = key;
    } else {
      key_OR_range = range;
    }

    final Request request;
    if (direction == null) {
      request = Request._fromObjectStore(store.openCursor(key_OR_range));
    } else {
      request = Request._fromObjectStore(
        store.openCursor(key_OR_range, direction),
      );
    }
    return _cursorWithValueStreamFromResult(request, autoAdvance);
  }

  Request openKeyCursor(Object? range, [String? direction]) =>
      Request._fromObjectStore(
        store.openKeyCursor(range.jsify(), direction ?? 'next'),
      );

  Future put(dynamic value, [dynamic key]) {
    try {
      final Request request;
      if (key != null) {
        request = Request._fromObjectStore(store.put(value, key));
      } else {
        request = Request._fromObjectStore(store.put(value));
      }
      return _completeRequest(request);
    } catch (e, stacktrace) {
      return Future.error(e, stacktrace);
    }
  }

  /// Allows access to the underlying IDB interface.
  IDBObjectStore get idbObject => store;

  //
  //Helper for iterating over cursors in a request.
  //
  static Stream<Cursor> _cursorStreamFromResult(
    Request request,
    bool? autoAdvance,
  ) {
    var controller = StreamController<Cursor>(sync: true);

    request.onError.listen(controller.addError);

    request.onSuccess.listen((e) {
      if (!controller.isClosed) {
        if (request.result != null) {
          Cursor cursor = Cursor._fromObjectStore(request.result);
          if (cursor == null) {
            controller.close();
          } else {
            controller.add(cursor);
            if (autoAdvance == true && controller.hasListener) {
              cursor.next();
            }
          }
        } else {
          controller.close();
        }
      }
    });
    return controller.stream;
  }

  //
  //Helper for iterating over cursors with values in a request.
  //
  static Stream<CursorWithValue> _cursorWithValueStreamFromResult(
    Request request,
    bool? autoAdvance,
  ) {
    var controller = StreamController<CursorWithValue>(sync: true);

    request.onError.listen(controller.addError);

    request.onSuccess.listen((e) {
      if (!controller.isClosed) {
        if (request.result != null) {
          CursorWithValue cursor = CursorWithValue._fromObjectStore(
            request.result,
          );
          if (cursor == null) {
            controller.close();
          } else {
            controller.add(cursor);
            if (autoAdvance == true && controller.hasListener) {
              cursor.next();
            }
          }
        } else {
          controller.close();
        }
      }
    });
    return controller.stream;
  }
}

//
// Ties a request to a completer, so the completer is completed when it succeeds
// and errors out when the request errors.
//
Future<T> _completeRequest<T>(Request request) {
  var completer = Completer<T>.sync();
  request.onSuccess.listen((e) {
    T result = request.result;
    completer.complete(result);
  });
  request.onError.listen(completer.completeError);
  return completer.future;
}

//
// Helper function for DOM String Lists
//
List<String>? _domStringsToList(DOMStringList? strings) {
  if (strings == null) {
    return null;
  }
  final length = strings.length;
  if (length == 0) {
    return null;
  }
  final res = <String>[];
  for (int i = 0; i < length; i++) {
    res.add(strings.item(i)!);
  }
  return res;
}
