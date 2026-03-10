// // // import 'package:sqflite/sqflite.dart';
// // // import 'package:path/path.dart';
// // // import 'package:flutter/foundation.dart';
// // //
// // // class DBHelper {
// // //   static final DBHelper _instance = DBHelper._internal();
// // //   factory DBHelper() => _instance;
// // //   DBHelper._internal();
// // //
// // //   static Database? _database;
// // //
// // //   Future<Database> get db async {
// // //     if (_database != null) return _database!;
// // //     _database = await initDatabase();
// // //     return _database!;
// // //   }
// // //
// // //   Future<Database> initDatabase() async {
// // //     String path = join(await getDatabasesPath(), 'attendance.db');
// // //     debugPrint('📁 Database path: $path');
// // //
// // //     return await openDatabase(
// // //       path,
// // //       version: 1,
// // //       onCreate: _onCreate,
// // //     );
// // //   }
// // //
// // //   Future<void> _onCreate(Database db, int version) async {
// // //     debugPrint('🔨 Creating database tables...');
// // //
// // //     // Attendance In Table
// // //     await db.execute('''
// // //       CREATE TABLE IF NOT EXISTS attendance(
// // //         attendance_in_id TEXT PRIMARY KEY,
// // //         attendance_in_date TEXT,
// // //         attendance_in_time TEXT,
// // //         emp_id TEXT,
// // //         lat_in TEXT,
// // //         lng_in TEXT,
// // //         booker_name TEXT,
// // //         designation TEXT,
// // //         city TEXT,
// // //         posted INTEGER DEFAULT 0,
// // //         address TEXT
// // //       )
// // //     ''');
// // //     debugPrint('✅ attendance table created');
// // //
// // //     // Attendance Out Table
// // //     await db.execute('''
// // //       CREATE TABLE IF NOT EXISTS attendance_out(
// // //         attendance_out_id TEXT PRIMARY KEY,
// // //         attendance_out_date TEXT,
// // //         attendance_out_time TEXT,
// // //         total_time TEXT,
// // //         emp_id TEXT,
// // //         lat_out TEXT,
// // //         lng_out TEXT,
// // //         total_distance TEXT,
// // //         posted INTEGER DEFAULT 0,
// // //         address TEXT,
// // //         reason TEXT DEFAULT 'manual'
// // //       )
// // //     ''');
// // //     debugPrint('✅ attendance_out table created');
// // //
// // //     // Location Table
// // //     await db.execute('''
// // //       CREATE TABLE IF NOT EXISTS location(
// // //         location_id TEXT PRIMARY KEY,
// // //         location_date TEXT,
// // //         location_time TEXT,
// // //         file_name TEXT,
// // //         emp_id TEXT,
// // //         total_distance TEXT,
// // //         booker_name TEXT,
// // //         posted INTEGER DEFAULT 0,
// // //         body BLOB
// // //       )
// // //     ''');
// // //     debugPrint('✅ location table created');
// // //   }
// // //
// // //   Future<void> close() async {
// // //     if (_database != null) {
// // //       await _database!.close();
// // //       _database = null;
// // //       debugPrint('📁 Database closed');
// // //     }
// // //   }
// // // }
// //
// //
// // import 'package:sqflite/sqflite.dart';
// // import 'package:path/path.dart';
// // import 'package:flutter/foundation.dart';
// //
// // class DBHelper {
// //   static final DBHelper _instance = DBHelper._internal();
// //   factory DBHelper() => _instance;
// //   DBHelper._internal();
// //
// //   static Database? _database;
// //
// //   // Table names
// //   static const String attendanceTableName = 'attendance';
// //   static const String attendanceOutTableName = 'attendance_out';
// //   static const String locationTableName = 'location';
// //
// //   Future<Database> get db async {
// //     if (_database != null) return _database!;
// //     _database = await initDatabase();
// //     return _database!;
// //   }
// //
// //   Future<Database> initDatabase() async {
// //     String path = join(await getDatabasesPath(), 'attendance.db');
// //     debugPrint('📁 Database path: $path');
// //
// //     return await openDatabase(
// //       path,
// //       version: 1,
// //       onCreate: _onCreate,
// //     );
// //   }
// //
// //   Future<void> _onCreate(Database db, int version) async {
// //     debugPrint('🔨 Creating database tables...');
// //
// //     // Attendance In Table
// //     await db.execute('''
// //       CREATE TABLE IF NOT EXISTS $attendanceTableName(
// //         attendance_in_id TEXT PRIMARY KEY,
// //         attendance_in_date TEXT,
// //         attendance_in_time TEXT,
// //         user_id TEXT,
// //         lat_in TEXT,
// //         lng_in TEXT,
// //         booker_name TEXT,
// //         city TEXT,
// //         posted INTEGER DEFAULT 0,
// //         address TEXT
// //       )
// //     ''');
// //     debugPrint('✅ $attendanceTableName table created');
// //
// //     // Attendance Out Table
// //     await db.execute('''
// //       CREATE TABLE IF NOT EXISTS $attendanceOutTableName(
// //         attendance_out_id TEXT PRIMARY KEY,
// //         attendance_out_date TEXT,
// //         attendance_out_time TEXT,
// //         total_time TEXT,
// //         user_id TEXT,
// //         lat_out TEXT,
// //         lng_out TEXT,
// //         total_distance TEXT,
// //         posted INTEGER DEFAULT 0,
// //         address TEXT,
// //         reason TEXT DEFAULT 'manual'
// //       )
// //     ''');
// //     debugPrint('✅ $attendanceOutTableName table created');
// //
// //     // Location Table
// //     await db.execute('''
// //       CREATE TABLE IF NOT EXISTS $locationTableName(
// //         location_id TEXT PRIMARY KEY,
// //         location_date TEXT,
// //         location_time TEXT,
// //         file_name TEXT,
// //         user_id TEXT,
// //         total_distance TEXT,
// //         booker_name TEXT,
// //         posted INTEGER DEFAULT 0,
// //         body BLOB
// //       )
// //     ''');
// //     debugPrint('✅ $locationTableName table created');
// //   }
// //
// //   Future<void> close() async {
// //     if (_database != null) {
// //       await _database!.close();
// //       _database = null;
// //       debugPrint('📁 Database closed');
// //     }
// //   }
// // }
//
// import 'dart:io';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:flutter/foundation.dart';
//
// class DBHelper {
//   static final DBHelper _instance = DBHelper._internal();
//   factory DBHelper() => _instance;
//   DBHelper._internal();
//
//   static Database? _database;
//
//   // Table names
//   static const String attendanceTableName    = 'attendance';
//   static const String attendanceOutTableName = 'attendance_out';
//   static const String locationTableName      = 'location';
//
//   Future<Database> get db async {
//     if (_database != null) return _database!;
//     _database = await initDatabase();
//     return _database!;
//   }
//
//   Future<Database> initDatabase() async {
//     final dbPath = join(await getDatabasesPath(), 'attendance.db');
//     debugPrint('📁 Database path: $dbPath');
//
//     // ──────────────────────────────────────────────────────────────────────
//     // ✅ FORCE-DELETE the old broken database so it is recreated cleanly.
//     //    The old DB had mixed-up column names (emp_id vs user_id) that caused
//     //    "table has no column named user_id" crashes on existing installs.
//     //    Safe to delete: all unposted records will be re-synced from the server
//     //    on next launch, and any pending data is already lost due to the crash.
//     //
//     //    REMOVE these 6 lines once all devices have been updated.
//     // ──────────────────────────────────────────────────────────────────────
//     final oldFile = File(dbPath);
//     if (await oldFile.exists()) {
//       await oldFile.delete();
//       debugPrint('🗑️ Old broken database deleted — will recreate cleanly');
//     }
//
//     return await openDatabase(
//       dbPath,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     debugPrint('🔨 Creating database tables...');
//
//     // user_id  → stores emp_id value
//     // booker_name → stores emp_name value
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS $attendanceTableName (
//         attendance_in_id   TEXT PRIMARY KEY,
//         attendance_in_date TEXT,
//         attendance_in_time TEXT,
//         user_id            TEXT,
//         lat_in             TEXT,
//         lng_in             TEXT,
//         booker_name        TEXT,
//         designation        TEXT,
//         city               TEXT,
//         address            TEXT,
//         posted             INTEGER DEFAULT 0
//       )
//     ''');
//     debugPrint('✅ $attendanceTableName table created');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS $attendanceOutTableName (
//         attendance_out_id   TEXT PRIMARY KEY,
//         attendance_out_date TEXT,
//         attendance_out_time TEXT,
//         total_time          TEXT,
//         user_id             TEXT,
//         lat_out             TEXT,
//         lng_out             TEXT,
//         total_distance      TEXT,
//         address             TEXT,
//         posted              INTEGER DEFAULT 0,
//         reason              TEXT DEFAULT 'manual'
//       )
//     ''');
//     debugPrint('✅ $attendanceOutTableName table created');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS $locationTableName (
//         location_id     TEXT PRIMARY KEY,
//         location_date   TEXT,
//         location_time   TEXT,
//         file_name       TEXT,
//         user_id         TEXT,
//         total_distance  TEXT,
//         booker_name     TEXT,
//         posted          INTEGER DEFAULT 0,
//         body            BLOB
//       )
//     ''');
//     debugPrint('✅ $locationTableName table created');
//   }
//
//   Future<void> close() async {
//     if (_database != null) {
//       await _database!.close();
//       _database = null;
//       debugPrint('📁 Database closed');
//     }
//   }
// }

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // Table names
  static const String attendanceTableName    = 'attendance';
  static const String attendanceOutTableName = 'attendance_out';
  static const String locationTableName      = 'location';

  Future<Database> get db async {
    // If database exists and is open, return it
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    // Otherwise initialize new database
    _database = await initDatabase();
    return _database!;
  }

  /// ✅ Check if file is writable by attempting to open it for write
  Future<bool> _isFileWritable(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return true; // New file will be created

      // Try to open file for append to test write permission
      final raf = await file.open(mode: FileMode.append);
      await raf.close();
      return true;
    } catch (e) {
      debugPrint('⚠️ File write test failed: $e');
      return false;
    }
  }

  /// ✅ Check if directory is writable
  Future<bool> _isDirectoryWritable(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Try to create a test file
      final testFile = File(join(dirPath, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      debugPrint('⚠️ Directory write test failed: $e');
      return false;
    }
  }

  Future<Database> initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'attendance.db');
    debugPrint('📁 Database path: $dbPath');

    final dbFile = File(dbPath);
    final dbDir = dirname(dbPath);

    // ✅ Check directory writability first
    final dirWritable = await _isDirectoryWritable(dbDir);
    debugPrint('📁 Directory writable: $dirWritable');

    // ✅ Check file writability using custom method instead of canWrite()
    if (await dbFile.exists()) {
      final fileWritable = await _isFileWritable(dbPath);
      debugPrint('📁 Database file exists, writable: $fileWritable');

      if (!fileWritable && Platform.isAndroid) {
        debugPrint('⚠️ Database appears readonly, attempting permission fix...');
        try {
          await Process.run('chmod', ['666', dbPath]);
          // Re-test after chmod
          final nowWritable = await _isFileWritable(dbPath);
          debugPrint('📁 After permission fix, writable: $nowWritable');
        } catch (e) {
          debugPrint('⚠️ Permission fix failed: $e');
        }
      }
    }

    // If corrupted, delete it
    if (await dbFile.exists()) {
      try {
        final testDb = await openDatabase(dbPath, readOnly: true);
        await testDb.close();
      } catch (e) {
        debugPrint('⚠️ Database corrupted, deleting: $e');
        await dbFile.delete();
      }
    }

    // ✅ Removed onConfigure with PRAGMA statements
    try {
      final database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          debugPrint('✅ Database opened successfully');
          // Verify database is working
          try {
            await db.rawQuery('SELECT 1');
            debugPrint('✅ Database query test passed');
          } catch (e) {
            debugPrint('❌ Database query test failed: $e');
          }
        },
      );

      return database;
    } catch (e) {
      debugPrint('❌ Failed to open database: $e');

      // Last resort: delete and recreate
      if (await dbFile.exists()) {
        await dbFile.delete();
        debugPrint('🗑️ Deleted corrupted database, retrying...');
      }

      // Retry opening without any complex configuration
      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔨 Creating database tables...');

    // user_id  → stores emp_id value
    // booker_name → stores emp_name value
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceTableName (
        attendance_in_id   TEXT PRIMARY KEY,
        attendance_in_date TEXT,
        attendance_in_time TEXT,
        user_id            TEXT,
        lat_in             TEXT,
        lng_in             TEXT,
        booker_name        TEXT,
        designation        TEXT,
        city               TEXT,
        address            TEXT,
        posted             INTEGER DEFAULT 0
      )
    ''');
    debugPrint('✅ $attendanceTableName table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceOutTableName (
        attendance_out_id   TEXT PRIMARY KEY,
        attendance_out_date TEXT,
        attendance_out_time TEXT,
        total_time          TEXT,
        user_id             TEXT,
        lat_out             TEXT,
        lng_out             TEXT,
        total_distance      TEXT,
        address             TEXT,
        posted              INTEGER DEFAULT 0,
        reason              TEXT DEFAULT 'manual'
      )
    ''');
    debugPrint('✅ $attendanceOutTableName table created');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $locationTableName (
        location_id     TEXT PRIMARY KEY,
        location_date   TEXT,
        location_time   TEXT,
        file_name       TEXT,
        user_id         TEXT,
        total_distance  TEXT,
        booker_name     TEXT,
        posted          INTEGER DEFAULT 0,
        body            BLOB
      )
    ''');
    debugPrint('✅ $locationTableName table created');
  }

  // ✅ Simplified database health check (removed WAL-dependent checks)
  Future<bool> isDatabaseHealthy() async {
    try {
      final db = await this.db;
      if (!db.isOpen) return false;

      // Simple read test only
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      debugPrint('❌ Database health check failed: $e');
      return false;
    }
  }

  // ✅ Simplified database repair
  Future<bool> repairDatabase() async {
    try {
      debugPrint('🔧 Attempting database repair...');

      // Close current connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Get database path
      final dbPath = join(await getDatabasesPath(), 'attendance.db');
      final dbFile = File(dbPath);

      // Backup existing database
      if (await dbFile.exists()) {
        final backupPath = join(await getDatabasesPath(), 'attendance.db.backup');
        try {
          await dbFile.copy(backupPath);
          debugPrint('💾 Database backed up to: $backupPath');
        } catch (e) {
          debugPrint('⚠️ Backup failed: $e');
        }
      }

      // Delete and recreate
      if (await dbFile.exists()) {
        await dbFile.delete();
        debugPrint('🗑️ Database deleted for repair');
      }

      // Reinitialize
      await db;
      debugPrint('✅ Database repair completed');

      return true;
    } catch (e) {
      debugPrint('❌ Database repair failed: $e');
      return false;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('📁 Database closed');
    }
  }
}