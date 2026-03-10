import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../../constants.dart';

class AttendanceOutRepository {
  final DBHelper dbHelper = DBHelper();

  // ✅ Track posted IDs in session to prevent duplicate posting
  final Set<String> _postedIds = {};

  // Get all attendance out records
  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceOutTableName,
      orderBy: 'attendance_out_date DESC',
    );

    debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');
    for (var map in maps) {
      debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
    }

    return List.generate(maps.length, (i) {
      return AttendanceOutModel.fromMap(maps[i]);
    });
  }

  // Fetch from API and save locally
  Future<void> fetchAndSaveAttendanceOut() async {
    try {
      debugPrint('🔍 [REPO-OUT] Fetching attendance out from API...');
      final response = await http.get(
        Uri.parse('$attendanceOutApi$emp_id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await dbHelper.db;

        int savedCount = 0;
        for (var item in data) {
          try {
            item['posted'] = 1;
            AttendanceOutModel model = AttendanceOutModel.fromMap(item);

            final existing = await db.query(
              attendanceOutTableName,
              where: 'attendance_out_id = ?',
              whereArgs: [model.attendance_out_id],
            );

            if (existing.isEmpty) {
              await db.insert(attendanceOutTableName, model.toMap());
              savedCount++;
              debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
            } else {
              debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
            }
          } catch (e) {
            debugPrint("❌ [REPO-OUT] Error saving item: $e");
          }
        }
        debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
      }
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
    }
  }

  // Get unposted attendance out records
  Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceOutTableName,
        where: 'posted = ?',
        whereArgs: [0],
      );

      debugPrint('📊 [REPO-OUT] Found ${maps.length} unposted records');

      return List.generate(maps.length, (i) {
        return AttendanceOutModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
      return [];
    }
  }

  // Add attendance out record with duplicate check
  Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      final db = await dbHelper.db;
      attendanceOut.posted = 0;

      // Check if already exists
      final existing = await db.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceOut.attendance_out_id],
      );

      if (existing.isNotEmpty) {
        debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceOut.attendance_out_id}');
        return 0;
      }

      debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceOut.attendance_out_id}');
      return await db.insert(attendanceOutTableName, attendanceOut.toMap());
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error adding record: $e');
      return -1;
    }
  }

  // Update attendance out record
  Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      final db = await dbHelper.db;
      debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceOut.attendance_out_id}');
      return await db.update(
        attendanceOutTableName,
        attendanceOut.toMap(),
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceOut.attendance_out_id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error updating record: $e');
      rethrow;
    }
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    try {
      final db = await dbHelper.db;
      await db.update(
        attendanceOutTableName,
        {'posted': 1},
        where: 'attendance_out_id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ [REPO-OUT] Marked as posted: $id');
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
    }
  }

  // Post single record to API with retry logic
  Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
    const int maxRetries = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting ${attendanceOut.attendance_out_id}');

        var recordData = attendanceOut.toJson();
        recordData['reason'] = attendanceOut.reason ?? 'manual';

        final response = await http.post(
          Uri.parse(attendanceOutApi),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(recordData),
        ).timeout(const Duration(seconds: 15));

        debugPrint('📡 [REPO-OUT] Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ [REPO-OUT] Posted successfully: ${attendanceOut.attendance_out_id}');
          await markAsPosted(attendanceOut.attendance_out_id!);
          _postedIds.add(attendanceOut.attendance_out_id.toString());
          return true;
        } else if (response.statusCode == 409) {
          // Already exists on server — treat as success
          debugPrint('⚠️ [REPO-OUT] Record already exists on server: ${attendanceOut.attendance_out_id}');
          await markAsPosted(attendanceOut.attendance_out_id!);
          return true;
        } else {
          debugPrint('❌ [REPO-OUT] Server error ${response.statusCode}: ${response.body}');
          if (attempt < maxRetries) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      } catch (e) {
        debugPrint('❌ [REPO-OUT] Attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    return false;
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    debugPrint('🔄 [REPO-OUT] ===== STARTING SYNC =====');

    if (!await isNetworkAvailable()) {
      debugPrint('📴 [REPO-OUT] No internet connection. Skipping sync.');
      return;
    }

    final unposted = await getUnPostedAttendanceOut();

    if (unposted.isEmpty) {
      debugPrint('📭 [REPO-OUT] No unposted attendance out records');
      return;
    }

    debugPrint('🔄 [REPO-OUT] Syncing ${unposted.length} records');

    // Deduplicate before posting
    final Map<String, AttendanceOutModel> uniqueRecords = {};
    for (var record in unposted) {
      if (record.attendance_out_id != null) {
        uniqueRecords[record.attendance_out_id.toString()] = record;
      }
    }

    int successCount = 0;
    int failCount = 0;

    for (var record in uniqueRecords.values) {
      // Skip if already posted in this session
      if (_postedIds.contains(record.attendance_out_id.toString())) {
        debugPrint('⚠️ [REPO-OUT] Skipping already posted in session: ${record.attendance_out_id}');
        continue;
      }

      final posted = await postToAPI(record);
      if (posted) {
        successCount++;
      } else {
        failCount++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint('📊 [REPO-OUT] Sync results: $successCount success, $failCount failed');

    // Clean duplicate records after sync
    await _cleanDuplicateRecords();

    debugPrint('🔄 [REPO-OUT] ===== SYNC COMPLETED =====');
  }

  // Delete record
  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    debugPrint('🗑️ [REPO-OUT] Deleting record: $id');
    return await db.delete(
      attendanceOutTableName,
      where: 'attendance_out_id = ?',
      whereArgs: [id],
    );
  }

  // Clean duplicate records from local DB
  Future<void> _cleanDuplicateRecords() async {
    try {
      final db = await dbHelper.db;

      final List<Map> allRecords = await db.query(
        attendanceOutTableName,
        columns: ['attendance_out_id'],
      );

      final Set<String> uniqueIds = {};
      final List<String> duplicateIds = [];

      for (var record in allRecords) {
        String id = record['attendance_out_id'].toString();
        if (uniqueIds.contains(id)) {
          duplicateIds.add(id);
        } else {
          uniqueIds.add(id);
        }
      }

      for (String duplicateId in duplicateIds) {
        debugPrint('⚠️ [REPO-OUT] Found duplicates for ID: $duplicateId');

        final List<Map> duplicates = await db.query(
          attendanceOutTableName,
          where: 'attendance_out_id = ?',
          whereArgs: [duplicateId],
        );

        if (duplicates.length > 1) {
          for (int i = 1; i < duplicates.length; i++) {
            await db.delete(
              attendanceOutTableName,
              where: 'rowid = ?',
              whereArgs: [duplicates[i]['rowid']],
            );
          }
          debugPrint('✅ [REPO-OUT] Cleaned ${duplicates.length - 1} duplicates for ID: $duplicateId');
        }
      }
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
    }
  }

  // Get record by ID
  Future<AttendanceOutModel?> getRecordById(String id) async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return AttendanceOutModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting record by ID: $e');
      return null;
    }
  }

  // Clear posted cache
  void clearPostedCache() {
    _postedIds.clear();
    debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
  }
}