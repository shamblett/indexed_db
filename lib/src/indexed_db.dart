/// A client-side key-value store with support for indexes.
///
/// > [!Note]
/// > New projects should prefer to use
/// > [package:web](https://pub.dev/packages/web). For existing projects, see
/// > our [migration guide](https://dart.dev/go/package-web).
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
///     import 'dart:indexed_db';
///
/// IndexedDB is almost universally supported in modern web browsers, but
/// a web app can determine if the browser supports IndexedDB
/// with [IdbFactory.supported]:
///
///     if (IdbFactory.supported)
///       // Use indexeddb.
///     else
///       // Find an alter.
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
/// {@category Web (Legacy)}
///
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// DO NOT EDIT - unless you are editing documentation as per:
// https://code.google.com/p/dart/wiki/ContributingHTMLDocumentation
// Auto-generated dart:indexed_db library.

class _KeyRangeFactoryProvider {

  static var _cachedClass;

  static _class() {
    return _cachedClass;
  }

  static _translateKey(idbKey) => idbKey; // TODO: fixme.

}

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An indexed database object for storing client-side data
/// in web apps.
class Database {
  ObjectStore createObjectStore(String name, {keyPath, bool? autoIncrement}) {
    var options = {};
    if (keyPath != null) {
      options['keyPath'] = keyPath;
    }
    if (autoIncrement != null) {
      options['autoIncrement'] = autoIncrement;
    }

    return _createObjectStore(name, options);
  }

  Transaction transaction(storeName_OR_storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }

    // TODO(sra): Ensure storeName_OR_storeNames is a string or List<String>,
    // and copy to JavaScript array if necessary.

    // Try and create a transaction with a string mode.  Browsers that expect a
    // numeric mode tend to convert the string into a number.  This fails
    // silently, resulting in zero ('readonly').
    return _transaction(storeName_OR_storeNames, mode);
  }

  Transaction transactionStore(String storeName, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }
    // Try and create a transaction with a string mode.  Browsers that expect a
    // numeric mode tend to convert the string into a number.  This fails
    // silently, resulting in zero ('readonly').
    return _transaction(storeName, mode);
  }

  Transaction transactionList(List<String> storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }
    List storeNames_1 = storeNames;
    return _transaction(storeNames_1, mode);
  }

  Transaction transactionStores(List storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }
    return _transaction(storeNames, mode);
  }

  @JS('transaction')
  Transaction _transaction(stores, mode) ;

  // To suppress missing implicit constructor warnings.
  factory Database._() {
    throw new UnsupportedError("Not supported");
  }

  /// Static factory designed to expose `abort` events to event
  /// handlers that are not necessarily instances of [Database].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<Event>('abort');

  /// Static factory designed to expose `close` events to event
  /// handlers that are not necessarily instances of [Database].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> closeEvent =
      EventStreamProvider<Event>('close');

  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [Database].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  /// Static factory designed to expose `versionchange` events to event
  /// handlers that are not necessarily instances of [Database].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<VersionChangeEvent> versionChangeEvent =
      EventStreamProvider<VersionChangeEvent>('versionchange');

  String? get name;
  
  List<String>? get objectStoreNames;
  
  int? get version ;

  void close() ;

  ObjectStore _createObjectStore(String name, [Map? options]) {
    if (options != null) {
      var options_1 = options;
      return _createObjectStore_1(name, options_1);
    }
    return _createObjectStore_2(name);
  }


  /// Stream of `abort` events handled by this [Database].
  Stream<Event> get onAbort => abortEvent.forTarget(this);

  /// Stream of `close` events handled by this [Database].
  Stream<Event> get onClose => closeEvent.forTarget(this);

  /// Stream of `error` events handled by this [Database].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of `versionchange` events handled by this [Database].
  Stream<VersionChangeEvent> get onVersionChange =>
      versionChangeEvent.forTarget(this);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

typedef void ObserverCallback(ObserverChanges changes);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


  /// Deprecated. Always returns `false`.
  @Deprecated('No longer supported on modern browsers. Always returns false.')
  bool get supportsDatabaseNames => false;


/// Ties a request to a completer, so the completer is completed when it succeeds
/// and errors out when the request errors.
Future<T> _completeRequest<T>(Request request) {
  var completer = new Completer<T>.sync();
  // TODO: make sure that completer.complete is synchronous as transactions
  // may be committed if the result is not processed immediately.
  request.onSuccess.listen((e) {
    T result = request.result;
    completer.complete(result);
  });
  request.onError.listen(completer.completeError);
  return completer.future;
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


  /// Creates a stream of cursors over the records in this object store.
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
  Stream<CursorWithValue> openCursor(
      {key, KeyRange? range, String? direction, bool? autoAdvance}) {
    var key_OR_range = null;
    if (key != null) {
      if (range != null) {
        throw new ArgumentError('Cannot specify both key and range.');
      }
      key_OR_range = key;
    } else {
      key_OR_range = range;
    }

    // TODO: try/catch this and return a stream with an immediate error.
    var request;
    if (direction == null) {
      request = _openCursor(key_OR_range);
    } else {
      request = _openCursor(key_OR_range, direction);
    }
    return _cursorStreamFromResult(request, autoAdvance);
  }

  Index createIndex(String name, keyPath, {bool? unique, bool? multiEntry}) {
    var options = {};
    if (unique != null) {
      options['unique'] = unique;
    }
    if (multiEntry != null) {
      options['multiEntry'] = multiEntry;
    }

    return _createIndex(name, keyPath, options);
  }

  bool? get autoIncrement ;

  List<String>? get indexNames ;

  Object? get keyPath ;

  String? get name ;

  set name(String? value) ;

  Transaction? get transaction ;

  Request _add(/*any*/ value, [/*any*/ key]) {
    if (key != null) {
      var value_1 = value;
      var key_2 = key;
      return _add_1(value_1, key_2);
    }
    var value_1 = value;
    return _add_2(value_1);
  }


  Request _add_1(value, key) ;

  Request _add_2(value) ;

  Request _clear() ;

  Request _count(Object? key) ;

  Index _createIndex(String name, Object keyPath, [Map? options]) {
    if (options != null) {
      var options_1 = convertDartTo_Dictionary(options);
      return _createIndex_1(name, keyPath, options_1);
    }
    return _createIndex_2(name, keyPath);
  }

  Index _createIndex_1(name, keyPath, options) ;
  Index _createIndex_2(name, keyPath) ;

  Request _delete(Object key) ;

  void deleteIndex(String name) ;

  Request _get(Object key) ;

  Request getAll(Object? query, [int? count]) ;

  Request getAllKeys(Object? query, [int? count]) ;

  Request getKey(Object key) ;

  Index index(String name) ;

  Request _openCursor(Object? range, [String? direction]) ;

  Request openKeyCursor(Object? range, [String? direction]) ;

  Request _put(/*any*/ value, [/*any*/ key]) {
    if (key != null) {
      var value_1 = value;
      var key_2 = key;
      return _put_1(value_1, key_2);
    }
    var value_1 = value;
    return _put_2(value_1);
  }

  Request _put_1(value, key) ;

  Request _put_2(value) ;

  /// Helper for iterating over cursors in a request.
  static Stream<T> _cursorStreamFromResult<T extends Cursor>(
      Request request, bool? autoAdvance) {
    // TODO: need to guarantee that the controller provides the values
    // immediately as waiting until the next tick will cause the transaction to
    // close.
    var controller = new StreamController<T>(sync: true);

    //TODO: Report stacktrace once issue 4061 is resolved.
    request.onError.listen(controller.addError);

    request.onSuccess.listen((e) {
      T? cursor = request.result as dynamic;
      if (cursor == null) {
        controller.close();
      } else {
        controller.add(cursor);
        if (autoAdvance == true && controller.hasListener) {
          cursor.next();
        }
      }
    });
    return controller.stream;
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class Observation extends JavaScriptObject {
  // To suppress missing implicit constructor warnings.
  factory Observation._() {
    throw new UnsupportedError("Not supported");
  }

  Object? get key ;

  String? get type ;

  Object? get value ;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Observer extends JavaScriptObject {
  // To suppress missing implicit constructor warnings.
  factory Observer._() {
    throw new UnsupportedError("Not supported");
  }

  factory Observer(ObserverCallback callback) {
    var callback_1 = convertDartClosureToJS(callback, 1);
    return Observer._create_1(callback_1);
  }
  static Observer _create_1(callback) =>
      JS('Observer', 'new IDBObserver(#)', callback);

  void observe(Database db, Transaction tx, Map options) {
    var options_1 = convertDartTo_Dictionary(options);
    _observe_1(db, tx, options_1);
    return;
  }

  void _observe_1(Database db, Transaction tx, options) ;

  void unobserve(Database db) ;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class ObserverChanges extends JavaScriptObject {
  // To suppress missing implicit constructor warnings.
  factory ObserverChanges._() {
    throw new UnsupportedError("Not supported");
  }

  Database? get database ;

  Object? get records ;

  Transaction? get transaction ;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class OpenDBRequest extends Request {
  // To suppress missing implicit constructor warnings.
  factory OpenDBRequest._() {
    throw new UnsupportedError("Not supported");
  }

  /// Static factory designed to expose `blocked` events to event
  /// handlers that are not necessarily instances of [OpenDBRequest].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> blockedEvent =
      const EventStreamProvider<Event>('blocked');

  /// Static factory designed to expose `upgradeneeded` events to event
  /// handlers that are not necessarily instances of [OpenDBRequest].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<VersionChangeEvent> upgradeNeededEvent =
      const EventStreamProvider<VersionChangeEvent>('upgradeneeded');

  /// Stream of `blocked` events handled by this [OpenDBRequest].
  Stream<Event> get onBlocked => blockedEvent.forTarget(this);

  /// Stream of `upgradeneeded` events handled by this [OpenDBRequest].
  Stream<VersionChangeEvent> get onUpgradeNeeded =>
      upgradeNeededEvent.forTarget(this);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Request extends EventTarget {
  // To suppress missing implicit constructor warnings.
  factory Request._() {
    throw new UnsupportedError("Not supported");
  }

  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [Request].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      const EventStreamProvider<Event>('error');

  /// Static factory designed to expose `success` events to event
  /// handlers that are not necessarily instances of [Request].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> successEvent =
      const EventStreamProvider<Event>('success');

  DomException? get error ;

  String? get readyState ;

  dynamic get result => _convertToDart_IDBAny(this._get_result);

  dynamic get _get_result ;


  Object? get source ;

  Transaction? get transaction ;

  /// Stream of `error` events handled by this [Request].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of `success` events handled by this [Request].
  Stream<Event> get onSuccess => successEvent.forTarget(this);
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Transaction extends EventTarget {
  /// Provides a Future which will be completed once the transaction has
  /// completed.
  ///
  /// The future will error if an error occurs on the transaction or if the
  /// transaction is aborted.
  Future<Database> get completed {
    var completer = new Completer<Database>();

    this.onComplete.first.then((_) {
      completer.complete(db);
    });

    this.onError.first.then((e) {
      completer.completeError(e);
    });

    this.onAbort.first.then((e) {
      // Avoid completing twice if an error occurs.
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  // To suppress missing implicit constructor warnings.
  factory Transaction._() {
    throw new UnsupportedError("Not supported");
  }

  /// Static factory designed to expose `abort` events to event
  /// handlers that are not necessarily instances of [Transaction].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> abortEvent =
      const EventStreamProvider<Event>('abort');

  /// Static factory designed to expose `complete` events to event
  /// handlers that are not necessarily instances of [Transaction].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> completeEvent =
      const EventStreamProvider<Event>('complete');

  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [Transaction].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      const EventStreamProvider<Event>('error');

  Database? get db ;

  DomException? get error ;

  String? get mode ;

  List<String>? get objectStoreNames ;

  void abort() ;

  ObjectStore objectStore(String name) ;

  /// Stream of `abort` events handled by this [Transaction].
  Stream<Event> get onAbort => abortEvent.forTarget(this);

  /// Stream of `complete` events handled by this [Transaction].
  Stream<Event> get onComplete => completeEvent.forTarget(this);

  /// Stream of `error` events handled by this [Transaction].
  Stream<Event> get onError => errorEvent.forTarget(this);
}
// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class VersionChangeEvent extends Event {
  // To suppress missing implicit constructor warnings.
  factory VersionChangeEvent._() {
    throw new UnsupportedError("Not supported");
  }

  factory VersionChangeEvent(String type, [Map? eventInitDict]) {
    if (eventInitDict != null) {
      var eventInitDict_1 = convertDartTo_Dictionary(eventInitDict);
      return VersionChangeEvent._create_1(type, eventInitDict_1);
    }
    return VersionChangeEvent._create_2(type);
  }
  static VersionChangeEvent _create_1(type, eventInitDict) => JS(
      'VersionChangeEvent',
      'new IDBVersionChangeEvent(#,#)',
      type,
      eventInitDict);
  static VersionChangeEvent _create_2(type) =>
      JS('VersionChangeEvent', 'new IDBVersionChangeEvent(#)', type);

  String? get dataLoss ;

  String? get dataLossMessage ;

  int? get newVersion ;

  int? get oldVersion ;

  OpenDBRequest get target ;
}
