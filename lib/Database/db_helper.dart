import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static Database? _database;

  static const String dbName = "employee_portal.db";

  static const String attendanceTable = "attendance_in";
  static const String attendanceOutTable = "attendance_out";
  static const String locationTable = "location";
  static const String leaveTable = "leave_application";

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {

    String path = join(await getDatabasesPath(), dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    /// Attendance IN
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $attendanceTable(
      attendance_in_id TEXT PRIMARY KEY,
      attendance_in_date TEXT,
      attendance_in_time TEXT,
      emp_id TEXT,
      emp_name TEXT,
      job TEXT,
      lat_in TEXT,
      lng_in TEXT,
      city TEXT,
      address TEXT,
      posted INTEGER DEFAULT 0
    )
    ''');

    /// Attendance OUT
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $attendanceOutTable(
      attendance_out_id TEXT PRIMARY KEY,
      attendance_out_date TEXT,
      attendance_out_time TEXT,
      total_time TEXT,
      emp_id TEXT,
      lat_out TEXT,
      lng_out TEXT,
      total_distance TEXT,
      address TEXT,
      reason TEXT DEFAULT 'manual',
      posted INTEGER DEFAULT 0
    )
    ''');

    /// Location
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $locationTable(
      location_id TEXT PRIMARY KEY,
      location_date TEXT,
      location_time TEXT,
      file_name TEXT,
      emp_id TEXT,
      emp_name TEXT,
      total_distance TEXT,
      posted INTEGER DEFAULT 0,
      body BLOB
    )
    ''');

    /// Leave Application
    await db.execute('''
CREATE TABLE IF NOT EXISTS $leaveTable(
  id TEXT PRIMARY KEY,
  leave_id TEXT UNIQUE,
  emp_id TEXT,
  emp_name TEXT,
  job_role TEXT,
  leave_type TEXT,
  start_date TEXT,
  end_date TEXT,
  total_days INTEGER,
  is_half_day INTEGER DEFAULT 0,
  reason TEXT,
  attachment_data BLOB,
  attachment_image TEXT,
  application_date TEXT,
  application_time TEXT,
  status TEXT DEFAULT 'pending',
  posted INTEGER DEFAULT 0,
  has_attachment INTEGER DEFAULT 0
)
''');
  }

  /// INSERT
  Future<int> insert(String table, Map<String, dynamic> data) async {

    final db = await database;

    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// GET ALL
  Future<List<Map<String, dynamic>>> getAll(String table) async {

    final db = await database;

    return await db.query(table);
  }

  /// GET UNPOSTED DATA (Sync ke liye)
  Future<List<Map<String, dynamic>>> getUnposted(String table) async {

    final db = await database;

    return await db.query(
      table,
      where: "posted = ?",
      whereArgs: [0],
    );
  }

  /// UPDATE POSTED STATUS
  Future<int> markAsPosted(String table, String idColumn, String id) async {

    final db = await database;

    return await db.update(
      table,
      {"posted": 1},
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  /// DELETE
  Future<int> delete(String table, String idColumn, String id) async {

    final db = await database;

    return await db.delete(
      table,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

}