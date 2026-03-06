

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import '../Models/leave_model.dart';

class DBHelper extends GetxService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'bookIt.db');

    var db = openDatabase(
      path,
      version: 15, // Increased to 13 for leave table updates
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  _onCreate(Database db, int version) async {
    List<String> tableQueries = [
      "CREATE TABLE IF NOT EXISTS $tableNameLogin(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT, dispatcher TEXT, dispatcher_id TEXT, images BLOB)",
      // "CREATE TABLE IF NOT EXISTS $tableNameLogin(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT, images BLOB)",
      "CREATE TABLE IF NOT EXISTS $addShopTableName(shop_id TEXT PRIMARY KEY, shop_date TEXT, shop_time TEXT, shop_name TEXT,city TEXT,shop_address TEXT,owner_name TEXT,owner_cnic TEXT,phone_no TEXT,address TEXT, alternative_phone_no TEXT,latitude TEXT, longitude TEXT, user_id TEXT, posted INTEGER DEFAULT 0 )",
      "CREATE TABLE IF NOT EXISTS $shopVisitMasterTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT, shop_visit_time TEXT, brand TEXT, shop_address TEXT,user_id TEXT, shop_name TEXT, address TEXT, latitude TEXT, longitude TEXT, city TEXT,owner_name TEXT,posted INTEGER DEFAULT 0, booker_name TEXT,walk_through TEXT,planogram TEXT,signage TEXT,product_reviewed TEXT,feedback TEXT,body BLOB)",
      "CREATE TABLE IF NOT EXISTS $shopVisitDetailsTableName(shop_visit_details_id TEXT PRIMARY KEY, shop_visit_details_date TEXT, shop_visit_details_time TEXT,user_id TEXT, shop_visit_master_id TEXT, product TEXT, quantity TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(shop_visit_master_id) REFERENCES $shopVisitMasterTableName(shop_visit_master_id))",
      "CREATE TABLE IF NOT EXISTS $orderMasterTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,user_name TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT,city TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderMasterStatusTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderDetailsTableName (order_details_id TEXT PRIMARY KEY, order_details_date TEXT, order_details_time TEXT,user_id TEXT, order_master_id TEXT, product TEXT, quantity TEXT, in_stock TEXT, rate TEXT,posted INTEGER DEFAULT 0, amount TEXT, FOREIGN KEY(order_master_id) REFERENCES $orderMasterTableName(order_master_id))",
      "CREATE TABLE IF NOT EXISTS $returnFormMasterTableName(return_master_id TEXT PRIMARY KEY, return_amount TEXT,return_master_date TEXT,user_id TEXT, return_master_time TEXT, posted INTEGER DEFAULT 0,select_shop TEXT)",
      "CREATE TABLE IF NOT EXISTS $returnFormDetailsTableName(return_details_id TEXT PRIMARY KEY, return_details_date TEXT, return_details_time TEXT,user_id TEXT, return_master_id TEXT, item TEXT, quantity TEXT, reason TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(return_master_id) REFERENCES $returnFormMasterTableName(return_master_id))",
      "CREATE TABLE IF NOT EXISTS $recoveryFormTableName(recovery_id TEXT PRIMARY KEY, recovery_date TEXT, recovery_time TEXT, shop_name TEXT,user_id TEXT,current_balance TEXT,cash_recovery TEXT,net_balance TEXT,posted INTEGER DEFAULT 0)",
      "CREATE TABLE IF NOT EXISTS $attendanceTableName(attendance_in_id TEXT PRIMARY KEY, attendance_in_date TEXT, attendance_in_time TEXT,user_id TEXT, lat_in TEXT, lng_in TEXT, booker_name TEXT,designation, city TEXT,posted INTEGER DEFAULT 0, address TEXT)",
      "CREATE TABLE IF NOT EXISTS $attendanceOutTableName(attendance_out_id TEXT PRIMARY KEY, attendance_out_date TEXT, attendance_out_time TEXT,  total_time TEXT, user_id TEXT, lat_out TEXT, lng_out TEXT, total_distance TEXT,posted INTEGER DEFAULT 0, address TEXT, reason TEXT DEFAULT 'manual')",
      "CREATE TABLE IF NOT EXISTS $locationTableName(location_id TEXT PRIMARY KEY, location_date TEXT, location_time TEXT, file_name TEXT, user_id TEXT, total_distance TEXT, booker_name TEXT, posted INTEGER DEFAULT 0, body BLOB)",
      "CREATE TABLE IF NOT EXISTS $productsTableName(id NUMBER, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT, in_stock TEXT)",
      "CREATE TABLE IF NOT EXISTS $headsShopVisitsTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT,shop_visit_time TEXT,posted INTEGER DEFAULT 0, shop_name TEXT, user_id TEXT, city TEXT, booker_name TEXT, feedback TEXT, shop_address TEXT, booker_id TEXT)",
      'CREATE TABLE IF NOT EXISTS $travelTimeData (id TEXT PRIMARY KEY, user_id TEXT,  travel_date TEXT, start_time TEXT, end_time TEXT, travel_distance REAL, travel_time REAL, average_speed REAL, working_time REAL, idle_time REAL, travel_type TEXT, latitude REAL, longitude REAL, address TEXT, posted INTEGER DEFAULT 0)',
      '''CREATE TABLE $centralPoints(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        central_point_id TEXT UNIQUE,
        user_id TEXT,
        overall_center_lat REAL,
        overall_center_lng REAL,
        total_clusters INTEGER,
        total_coordinates INTEGER,
        processing_date TEXT,
        booker_name TEXT,
        cluster_data TEXT,
        created_at TEXT,
        cluster_area TEXT,
        address_district TEXT,
        stay_time_in_cluster REAL
      )''',
      '''CREATE TABLE IF NOT EXISTS $leaveTable(
          id TEXT PRIMARY KEY,
          leave_id TEXT UNIQUE,
          booker_id TEXT,
          booker_name TEXT,
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
        )''',
    ];

    debugPrint('✅ All tables created successfully - Version 14');

    for (var query in tableQueries) {
      await db.execute(query);
    }
  }

  // _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   debugPrint('🔄 Upgrading database from version $oldVersion to $newVersion');
  //
  //   if (oldVersion < 14) {
  //     try {
  //       // Check current table structure
  //       final columns = await db.rawQuery("PRAGMA table_info($leaveTable)");
  //       final columnNames = columns.map((c) => c['name'] as String).toList();
  //
  //       debugPrint('📋 Current leaveTable columns: $columnNames');
  //
  //       // Add missing columns if they don't exist
  //       if (!columnNames.contains('attachment_image')) {
  //         await db.execute(
  //             "ALTER TABLE $leaveTable ADD COLUMN attachment_image TEXT");
  //         debugPrint('✅ Added attachment_image column to leaveTable');
  //       }
  //
  //       if (!columnNames.contains('has_attachment')) {
  //         await db.execute(
  //             "ALTER TABLE $leaveTable ADD COLUMN has_attachment INTEGER DEFAULT 0");
  //         debugPrint('✅ Added has_attachment column to leaveTable');
  //       }
  //
  //       // If table doesn't exist at all, create it fresh
  //       if (columns.isEmpty) {
  //         await db.execute('''
  //           CREATE TABLE IF NOT EXISTS $leaveTable(
  //             id TEXT PRIMARY KEY,
  //             leave_id TEXT UNIQUE,
  //             booker_id TEXT,
  //             booker_name TEXT,
  //             leave_type TEXT,
  //             start_date TEXT,
  //             end_date TEXT,
  //             total_days INTEGER,
  //             is_half_day INTEGER DEFAULT 0,
  //             reason TEXT,
  //             attachment_data BLOB,
  //             attachment_image TEXT,
  //             application_date TEXT,
  //             application_time TEXT,
  //             status TEXT DEFAULT 'pending',
  //             posted INTEGER DEFAULT 0,
  //             has_attachment INTEGER DEFAULT 0
  //           )
  //         ''');
  //         debugPrint('✅ Created fresh leaveTable');
  //       }
  //
  //       debugPrint('✅ Database upgraded to version 14 successfully');
  //     } catch (e) {
  //       debugPrint('❌ Error during database upgrade: $e');
  //
  //       // Fallback: Drop and recreate table
  //       try {
  //         await db.execute("DROP TABLE IF EXISTS $leaveTable");
  //
  //         await db.execute('''
  //           CREATE TABLE IF NOT EXISTS $leaveTable(
  //             id TEXT PRIMARY KEY,
  //             leave_id TEXT UNIQUE,
  //             booker_id TEXT,
  //             booker_name TEXT,
  //             leave_type TEXT,
  //             start_date TEXT,
  //             end_date TEXT,
  //             total_days INTEGER,
  //             is_half_day INTEGER DEFAULT 0,
  //             reason TEXT,
  //             attachment_data BLOB,
  //             attachment_image TEXT,
  //             application_date TEXT,
  //             application_time TEXT,
  //             status TEXT DEFAULT 'pending',
  //             posted INTEGER DEFAULT 0,
  //             has_attachment INTEGER DEFAULT 0
  //           )
  //         ''');
  //
  //         debugPrint('✅ Recreated leaveTable with all columns');
  //       } catch (e2) {
  //         debugPrint('❌ Failed to recreate table: $e2');
  //       }
  //     }
  //   }
  // }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
        '🔄 Upgrading database from version $oldVersion to $newVersion');

    // ================= LEAVE TABLE MIGRATION =================
    if (oldVersion < 15) {
      try {
        final columns =
        await db.rawQuery("PRAGMA table_info($leaveTable)");
        final columnNames =
        columns.map((c) => c['name'] as String).toList();

        debugPrint('📋 Current leaveTable columns: $columnNames');

        // Add missing columns
        if (!columnNames.contains('attachment_image')) {
          await db.execute(
              "ALTER TABLE $leaveTable ADD COLUMN attachment_image TEXT");
          debugPrint('✅ Added attachment_image column');
        }

        if (!columnNames.contains('has_attachment')) {
          await db.execute(
              "ALTER TABLE $leaveTable ADD COLUMN has_attachment INTEGER DEFAULT 0");
          debugPrint('✅ Added has_attachment column');
        }

        // If table somehow not exist
        if (columns.isEmpty) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS $leaveTable(
            id TEXT PRIMARY KEY,
            leave_id TEXT UNIQUE,
            booker_id TEXT,
            booker_name TEXT,
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
          debugPrint('✅ Created fresh leaveTable');
        }

        debugPrint('✅ Leave table migration completed');
      } catch (e) {
        debugPrint('❌ Leave table migration error: $e');
      }
    }

    // ================= ATTENDANCE TABLE MIGRATION =================
    try {
      final attendanceColumns =
      await db.rawQuery("PRAGMA table_info($attendanceTableName)");

      final attendanceColumnNames =
      attendanceColumns.map((c) => c['name'] as String).toList();

      debugPrint(
          '📋 Current attendanceTable columns: $attendanceColumnNames');

      // ✅ ADD reason COLUMN IF NOT EXISTS
      if (!attendanceColumnNames.contains('reason')) {
        await db.execute(
            "ALTER TABLE $attendanceTableName ADD COLUMN reason TEXT");
        debugPrint('✅ Added reason column to attendance table');
      }
    } catch (e) {
      debugPrint('❌ Attendance table migration error: $e');
    }

    debugPrint('✅ Database upgrade finished');
  }

  Future<void> clearData() async {
    final db = await this.db;
    List<String> tableNames = [productsTableName];

    for (var tableName in tableNames) {
      await db.execute("DELETE FROM $tableName");
    }
  }

  Future<int> insertLeave(LeaveModel leave) async {
    try {
      final db = await this.db;

      DateTime now = DateTime.now();
      String day = now.day.toString().padLeft(2, '0');
      String monthAbbrev = _getMonthAbbreviation(now.month);
      int sequence = await _getLeaveSequenceForDay(now);
      String sequenceStr = sequence.toString().padLeft(3, '0');
      String leaveId = 'LV-${leave.bookerId}-$day-$monthAbbrev-$sequenceStr';

      // Generate filename
      String? attachmentImage;
      if (leave.attachmentData != null) {
        attachmentImage =
            'leave_${leave.bookerId}_${now.millisecondsSinceEpoch}.jpg';
      }

      final data = {
        'id': now.millisecondsSinceEpoch.toString(),
        'leave_id': leaveId,
        'booker_id': leave.bookerId,
        'booker_name': leave.bookerName ?? '',
        'leave_type': leave.leaveType,
        'start_date': leave.startDate,
        'end_date': leave.endDate,
        'total_days': leave.totalDays,
        'is_half_day': leave.isHalfDay ? 1 : 0,
        'reason': leave.reason,
        'attachment_data': leave.attachmentData,
        'attachment_image': attachmentImage,
        'application_date': now.toIso8601String().split('T')[0],
        'application_time':
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
        'status': leave.status ?? 'pending',
        'posted': 0,
        'has_attachment': leave.attachmentData != null ? 1 : 0,
      };

      debugPrint('📝 Inserting leave to database');
      debugPrint('📎 Attachment filename: $attachmentImage');
      debugPrint('📎 BLOB size: ${leave.attachmentData?.length ?? 0} bytes');

      final result = await db.insert(leaveTable, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('✅ Leave inserted with ID: $result, Leave ID: $leaveId');
      return result;
    } catch (e) {
      debugPrint('❌ Error inserting leave: $e');

      // Debug table structure
      try {
        final db = await this.db;
        final columns = await db.rawQuery("PRAGMA table_info($leaveTable)");
        debugPrint('📋 leaveTable structure:');
        for (var col in columns) {
          debugPrint('   ${col['name']} - ${col['type']}');
        }
      } catch (e2) {
        debugPrint('❌ Error checking table structure: $e2');
      }

      return 0;
    }
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '---';
    }
  }

  Future<int> _getLeaveSequenceForDay(DateTime date) async {
    try {
      final db = await this.db;
      String dateStr = date.toIso8601String().split('T')[0];

      final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $leaveTable 
      WHERE application_date = ? 
    ''', [dateStr]);

      int count = result.first['count'] as int? ?? 0;
      return count + 1;
    } catch (e) {
      debugPrint('❌ Error getting leave sequence: $e');
      return 1;
    }
  }

  Future<int> markLeaveAsPosted(String leaveId) async {
    try {
      final db = await this.db;
      debugPrint('🔄 Marking leave as posted: $leaveId');

      final result = await db.update(
        leaveTable,
        {'posted': 1},
        where: 'leave_id = ?',
        whereArgs: [leaveId],
      );

      if (result > 0) {
        debugPrint('✅ Leave marked as posted successfully');
      } else {
        debugPrint('⚠️ No leave found with ID: $leaveId');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error marking leave as posted: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getLeavesByBookerId(
      String bookerId) async {
    try {
      final db = await this.db;
      debugPrint('📋 Fetching leaves for booker: $bookerId');

      final leaves = await db.query(
        leaveTable,
        columns: [
          'id',
          'leave_id',
          'booker_id',
          'booker_name',
          'leave_type',
          'start_date',
          'end_date',
          'total_days',
          'is_half_day',
          'reason',
          'attachment_image',
          'application_date',
          'application_time',
          'status',
          'posted',
          'has_attachment'
        ],
        where: 'booker_id = ?',
        whereArgs: [bookerId],
        orderBy: 'application_date DESC, application_time DESC',
      );

      debugPrint('✅ Found ${leaves.length} leaves for booker $bookerId');

      return leaves;
    } catch (e) {
      debugPrint('❌ Error fetching leaves: $e');
      return [];
    }
  }

  Future<Uint8List?> getLeaveAttachment(String leaveId) async {
    try {
      final db = await this.db;
      debugPrint('📋 Fetching attachment for leave: $leaveId');

      final result = await db.query(
        leaveTable,
        columns: ['attachment_data'],
        where: 'leave_id = ?',
        whereArgs: [leaveId],
        limit: 1,
      );

      if (result.isNotEmpty && result.first['attachment_data'] != null) {
        final blobData = result.first['attachment_data'];
        if (blobData is Uint8List) {
          return blobData;
        } else if (blobData is List<int>) {
          return Uint8List.fromList(blobData);
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching attachment: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingLeaves() async {
    try {
      final db = await this.db;
      debugPrint('🔄 Fetching pending leaves (posted = 0)');

      final leaves = await db.query(
        leaveTable,
        columns: [
          'id',
          'leave_id',
          'booker_id',
          'booker_name',
          'leave_type',
          'start_date',
          'end_date',
          'total_days',
          'is_half_day',
          'reason',
          'attachment_image',
          'application_date',
          'application_time',
          'status',
          'posted',
          'has_attachment'
        ],
        where: 'posted = ?',
        whereArgs: [0],
        orderBy: 'application_date DESC, application_time DESC',
      );

      debugPrint('✅ Found ${leaves.length} pending leaves');

      return leaves;
    } catch (e) {
      debugPrint('❌ Error fetching pending leaves: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPendingLeavesWithAttachments() async {
    try {
      final db = await this.db;
      debugPrint('🔄 Fetching pending leaves with attachments');

      final leaves = await db.query(
        leaveTable,
        where: 'posted = ?',
        whereArgs: [0],
        orderBy: 'application_date DESC, application_time DESC',
      );

      debugPrint('✅ Found ${leaves.length} pending leaves');

      // Convert BLOB to Uint8List
      for (var leave in leaves) {
        if (leave['attachment_data'] != null &&
            leave['attachment_data'] is List<int>) {
          leave['attachment_data'] =
              Uint8List.fromList(leave['attachment_data'] as List<int>);
        }
      }

      return leaves;
    } catch (e) {
      debugPrint('❌ Error fetching pending leaves with attachments: $e');
      return [];
    }
  }
}
