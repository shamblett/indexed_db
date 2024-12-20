// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library IndexedDB1Test;
/
import 'dart:async';
import 'dart:math' as math;

import 'package:indexed_db/indexed_db.dart' as idb;
import 'package:test/test.dart';
import 'package:web/web.dart';

main() {

    test('Database', () {
      //idb.Database().transactionList(
      idb.Factory().deleteDatabase('me');
    });
}
