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
/// ## Using indexed_db
///
/// The classes in this library provide an interface
/// to the browser's IndexedDB, if it has one.
/// To use this library in your code:
///
///     import 'package:indexed_db/indexed_db';
///
/// IndexedDB is almost universally supported in modern web browsers, but
/// a web app can determine if the browser supports IndexedDB
/// with [IdbFactory.supported]:
///
///     if (IdbFactory.supported)
///       // Use indexeddb.
///     else
///       // Find an alternative.
///
/// Access to the browser's IndexedDB is provided by the app's top-level
/// [Window] object, which your code can refer to with `window.indexedDB`.
/// So, for example,
/// here's how to use window.indexedDB to open a database:
///
///     Future open() {
///       return window.indexedDB.open('myIndexedDB',
///           version: 1,
///           onUpgradeNeeded: _initializeDatabase)
///         .then(_loadFromDB);
///     }
///     void _initializeDatabase(VersionChangeEvent e) {
///       ...
///     }
///     Future _loadFromDB(Database db) {
///       ...
///     }
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

import 'dart:async';
import 'dart:js_interop';

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
      return Future.error(ArgumentError(
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
        completer.complete(Database._fromOpenRequest(request.result!));
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
extension type Transaction._(IDBTransaction transaction) {
  Transaction._fromDatabase(this.transaction);
}

///
/// Object Store
///
extension type ObjectStore._(IDBObjectStore store) {
  ObjectStore.fromCreateRequest(this.store);
}

///
/// Database
///
/// An indexed database object for storing client-side data in web apps.
///
extension type Database._(IDBDatabase database) {
  Database._fromOpenRequest(JSAny result) : database = (result as IDBDatabase) {
    database.onabort = onAbortHandler();
    database.onclose = onCloseHandler();
    database.onerror = onErrorHandler();
  }

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');
  static const EventStreamProvider<Event> closeEvent =
      EventStreamProvider<ProgressEvent>('close');
  static const EventStreamProvider<Event> versionChangeEvent =
      EventStreamProvider<ProgressEvent>('versionchange');

  String? get name => database.name;

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

  /// Stream of abort events handled by this Database.
  Stream<Event> get onAbort async* {
    yield (_abortValues[(this as Object)]!);
  }

  static final _closeValues = Expando<Event>();

  EventHandler onCloseHandler() {
    final event = Event('close');
    _closeValues[(this as Object)] = event;
    return null;
  }

  /// Stream of close events handled by this Database.
  Stream<Event> get onClose async* {
    yield _closeValues[(this as Object)]!;
  }

  static final _errorValues = Expando<Event>();

  EventHandler onErrorHandler() {
    final event = Event('error');
    _errorValues[(this as Object)] = event;
    return null;
  }

  /// Stream of error events handled by this Database.
  Stream<Event> get onError async* {
    yield _errorValues[(this as Object)]!;
  }

  static final _versionChangeValues = Expando<Event>();

  EventHandler onVersionHandler() {
    final event = Event('versionchange');
    _versionChangeValues[(this as Object)] = event;
    return null;
  }

  /// Stream of version change events handled by this [Database].
  Stream<Event> get onVersionChange async* {
    yield _versionChangeValues[(this as Object)]!;
  }

  int? get version => database.version;

  void close() => database.close();

  ObjectStore createObjectStore(
    String name, {
    dynamic keyPath,
    bool? autoIncrement,
  }) {
    final options = IDBObjectStoreParameters(
        keyPath: keyPath.jsify(), autoIncrement: autoIncrement!);

    final objectStore = database.createObjectStore(name, options);
    return ObjectStore.fromCreateRequest(objectStore);
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
    final transaction = database.transaction(storeNames.toJSBox, mode);
    return Transaction._fromDatabase(transaction);
  }

  Transaction transactionStore(String storeName, String mode) =>
      transaction(storeName, mode);

  Transaction transactionStores(List<String> storeName, String mode) =>
      transactionList(storeName, mode);

  void deleteObjectStore(String name) => database.deleteObjectStore(name);
}

///
/// OpenDBRequest
///
extension type OpenDBRequest._(IDBOpenDBRequest openRequest) {
  OpenDBRequest(this.openRequest) {
    openRequest.onblocked = onBlockedHandler();
    openRequest.onupgradeneeded = onUpgradeNeededHandler();
  }

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> blockedEvent =
      EventStreamProvider<ProgressEvent>('blocked');
  static const EventStreamProvider<Event> upgradeNeededEvent =
      EventStreamProvider<ProgressEvent>('upgradeneeded');

  static final _blockedValues = Expando<Event>();

  EventHandler onBlockedHandler() {
    final event = Event('blocked');
    _blockedValues[(this as Object)] = event;
    return null;
  }

  /// Stream of blocked events handled by this Database.
  Stream<Event> get onAbort async* {
    yield (_blockedValues[(this as Object)]!);
  }

  static final _upgradeNeededValues = Expando<Event>();

  EventHandler onUpgradeNeededHandler() {
    final event = Event('upgradeNeeded');
    _upgradeNeededValues[(this as Object)] = event;
    return null;
  }

  /// Stream of upgrade needed events handled by this Database.
  Stream<Event> get onUpgradeNeeded async* {
    yield (_upgradeNeededValues[(this as Object)]!);
  }
}
