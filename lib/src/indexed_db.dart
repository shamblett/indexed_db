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

// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

///
/// Type defines
///
typedef DomException = DOMException;

/// Version Change Event
///
extension type VersionChangeEvent._(IDBVersionChangeEvent event) {
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

  @Deprecated('dataLoss no longer supported on IDBVersionChangeEvent')
  String? get dataLoss => 'Not Implemented';

  @Deprecated('dataLossMessage no longer supported on IDBVersionChangeEvent')
  String? get dataLossMessage => 'Not Implemented';

  int? get newVersion => event.newVersion;

  int? get oldVersion => event.oldVersion;

  OpenDBRequest get target => OpenDBRequest((event.target as IDBOpenDBRequest));
}

///
/// Request
///
extension type Request._(IDBRequest request) {
  Request._fromObjectStore(this.request) {
    _initialiseHandlers();
  }

  Request._fromCursor(this.request) {
    _initialiseHandlers();
  }

  Request._fromIndex(this.request) {
    _initialiseHandlers();
  }

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> successEvent =
      EventStreamProvider<ProgressEvent>('success');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');

  DomException? get error => request.error;

  static final _errorValues = Expando<Event>();

  EventHandler onErrorHandler() {
    final event = Event('error');
    _errorValues[(this as Object)] = event;
    return null;
  }

  /// Stream of error events handled by this Request.
  Stream<Event> get onError async* {
    yield (_errorValues[(this as Object)]!);
  }

  static final _successValues = Expando<Event>();

  EventHandler onSuccessHandler() {
    final event = Event('success');
    _successValues[(this as Object)] = event;
    return null;
  }

  /// Stream of success events handled by this Request.
  Stream<Event> get onSuccess async* {
    yield (_successValues[(this as Object)]!);
  }

  String? get readyState => request.readyState;

  dynamic get result => request.result;

  Object? get source => request.source;

  Transaction? get transaction =>
      Transaction._fromRequest(request.transaction!);

  void _initialiseHandlers() {
    request.onerror = onErrorHandler();
    request.onsuccess = onSuccessHandler();
  }
}

///
/// Cursor With Value
///
extension type CursorWithValue._(IDBCursorWithValue cursor) {
  dynamic get value => cursor.value;
}

///
/// Cursor
///
extension type Cursor._(IDBCursor cursor) {
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
}

///
/// Factory - named idbFactory as per the dart:indexed_db API.
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
  Transaction._fromDatabase(this.transaction) {
    _initialiseHandlers();
  }
  Transaction._fromObjectStore(this.transaction) {
    _initialiseHandlers();
  }
  Transaction._fromRequest(this.transaction) {
    _initialiseHandlers();
  }

  /// Static factory designed to expose events to event handlers
  /// that are not necessarily instances of Database.
  /// See EventStreamProvider for usage information.
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<ProgressEvent>('error');
  static const EventStreamProvider<Event> completeEvent =
      EventStreamProvider<ProgressEvent>('complete');

  static final _errorValues = Expando<Event>();

  EventHandler onErrorHandler() {
    final event = Event('error');
    _errorValues[(this as Object)] = event;
    return null;
  }

  /// Stream of error events handled by this Request.
  Stream<Event> get onError async* {
    yield (_errorValues[(this as Object)]!);
  }

  static final _abortValues = Expando<Event>();

  EventHandler onAbortHandler() {
    final event = Event('abort');
    _abortValues[(this as Object)] = event;
    return null;
  }

  /// Stream of abort events handled by this Request.
  Stream<Event> get onAbort async* {
    yield (_abortValues[(this as Object)]!);
  }

  static final _completeValues = Expando<Event>();

  EventHandler onCompleteHandler() {
    final event = Event('complete');
    _completeValues[(this as Object)] = event;
    return null;
  }

  /// Stream of complete events handled by this Request.
  Stream<Event> get onComplete async* {
    yield (_completeValues[(this as Object)]!);
  }

  /// Provides a Future which will be completed once the transaction has completed.
  /// The future will error if an error occurs on the transaction or if the transaction is aborted.
  Future<Database> get completed {
    final completer = Completer<Database>();

    onComplete.first.then((_) {
      completer.complete(Database._fromTransaction(transaction.db));
    });

    onError.first.then((e) {
      completer.completeError(e);
    });

    onAbort.first.then((e) {
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

  void _initialiseHandlers() {
    transaction.onerror = onErrorHandler();
    transaction.onabort = onAbortHandler();
    transaction.oncomplete = onCompleteHandler();
  }
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
    return _cursorStreamFromResult(request, autoAdvance);
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
      request =
          Request._fromIndex(index.openKeyCursor(key_OR_range, direction));
    }
    return _cursorStreamFromResult(request, autoAdvance);
  }
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
  ]) =>
      KeyRange.bound(lower, upper, lowerOpen ?? false, upperOpen ?? false);

  static KeyRange lowerBound_(Object bound, [bool? open]) =>
      KeyRange.lowerBound(bound, open ?? false);

  static KeyRange only_(Object value) => KeyRange.only(value);

  static KeyRange upperBound_(Object bound, [bool? open]) =>
      KeyRange.upperBound(bound, open ?? false);
}

///
/// Database
///
/// An indexed database object for storing client-side data in web apps.
///
extension type Database._(IDBDatabase database) {
  Database._fromOpenRequest(JSAny result) : database = (result as IDBDatabase) {
    _initialiseHandlers();
  }

  Database._fromTransaction(this.database) {
    _initialiseHandlers();
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

  List<String>? get objectStoreNames =>
      _domStringsToList(database.objectStoreNames);

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
    final transaction = database.transaction(storeNames.toJSBox, mode);
    return Transaction._fromDatabase(transaction);
  }

  Transaction transactionStore(String storeName, String mode) =>
      transaction(storeName, mode);

  Transaction transactionStores(List<String> storeName, String mode) =>
      transactionList(storeName, mode);

  void deleteObjectStore(String name) => database.deleteObjectStore(name);

  void _initialiseHandlers() {
    database.onerror = onErrorHandler();
    database.onabort = onAbortHandler();
    database.onclose = onCloseHandler();
  }
}

///
/// Open DB Request
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
          Request._fromObjectStore(store.delete(key_OR_keyRange)));
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
      request =
          Request._fromObjectStore(store.openCursor(key_OR_range, direction));
    }
    return _cursorStreamFromResult(request, autoAdvance);
  }

  Request openKeyCursor(Object? range, [String? direction]) =>
      Request._fromObjectStore(
          store.openKeyCursor(range.jsify(), direction ?? 'next'));

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
// Helper for iterating over cursors in a request.
//
Stream<T> _cursorStreamFromResult<T extends Cursor>(
    Request request, bool? autoAdvance) {
  final controller = StreamController<T>(sync: true);

  request.onError.listen(controller.addError);

  request.onSuccess.listen((e) {
    T? cursor = request.result;
    if (cursor == null) {
      controller.close();
    } else {
      controller.add(cursor);
      if (autoAdvance == true && controller.hasListener) {
        (cursor as dynamic).next();
      }
    }
  });
  return controller.stream;
}

//
// Helper function for DOM String Lists
//
List<String>? _domStringsToList(DOMStringList strings) {
  final length = strings.length;
  if (length == 0) {
    return null;
  }
  final res = <String>[];
  for (int i = 0; i <= length; i++) {
    res.add(strings.item(i)!);
  }
  return res;
}
