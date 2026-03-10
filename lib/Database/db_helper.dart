import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    debugPrint('📁 Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔨 Creating database tables...');

    // Attendance In Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance(
        attendance_in_id TEXT PRIMARY KEY,
        attendance_in_date TEXT,
        attendance_in_time TEXT,
        emp_id TEXT,
        lat_in TEXT,
        lng_in TEXT,
        booker_name TEXT,
        designation TEXT,
        city TEXT,
        posted INTEGER DEFAULT 0,
        address TEXT
      )
    ''');
    debugPrint('✅ attendance table created');

    // Attendance Out Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance_out(
        attendance_out_id TEXT PRIMARY KEY,
        attendance_out_date TEXT,
        attendance_out_time TEXT,
        total_time TEXT,
        emp_id TEXT,
        lat_out TEXT,
        lng_out TEXT,
        total_distance TEXT,
        posted INTEGER DEFAULT 0,
        address TEXT,
        reason TEXT DEFAULT 'manual'
      )
    ''');
    debugPrint('✅ attendance_out table created');

    // Location Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS location(
        location_id TEXT PRIMARY KEY,
        location_date TEXT,
        location_time TEXT,
        file_name TEXT,
        emp_id TEXT,
        total_distance TEXT,
        booker_name TEXT,
        posted INTEGER DEFAULT 0,
        body BLOB
      )
    ''');
    debugPrint('✅ location table created');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('📁 Database closed');
    }
  }
}