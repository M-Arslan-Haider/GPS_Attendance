import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../models/attendance_model.dart';
import '../../constants.dart';

class AttendanceRepository {
  final DBHelper dbHelper = DBHelper();

  // ✅ Track posted IDs in session to prevent duplicates
  final Set<String> _postedIds = {};

  // Get all attendance records
  Future<List<AttendanceModel>> getAttendance() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceTableName,
      orderBy: 'attendance_in_date DESC',
    );

    debugPrint('📊 [REPO-IN] Raw data from Attendance database: ${maps.length} records');
    for (var map in maps) {
      debugPrint("   - ID: ${map['attendance_in_id']}, Posted: ${map['posted']}");
    }

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  // Fetch from API and save locally
  Future<void> fetchAndSaveAttendance() async {
    try {
      debugPrint('🔍 [REPO-IN] Fetching attendance from API...');
      final response = await http.get(
        Uri.parse('$attendanceInApi$emp_id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await dbHelper.db;

        int savedCount = 0;
        for (var item in data) {
          try {
            item['posted'] = 1;
            AttendanceModel model = AttendanceModel.fromMap(item);

            final existing = await db.query(
              attendanceTableName,
              where: 'attendance_in_id = ?',
              whereArgs: [model.attendance_in_id],
            );

            if (existing.isEmpty) {
              await db.insert(attendanceTableName, model.toMap());
              savedCount++;
              debugPrint("✅ [REPO-IN] Saved from API: ${model.attendance_in_id}");
            } else {
              debugPrint("⚠️ [REPO-IN] Skipping duplicate from API: ${model.attendance_in_id}");
            }
          } catch (e) {
            debugPrint("❌ [REPO-IN] Error saving item: $e");
          }
        }
        debugPrint("✅ [REPO-IN] Fetched and saved $savedCount records from API");
      }
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error fetching from API: $e');
    }
  }

  // Get unposted attendance records
  Future<List<AttendanceModel>> getUnPostedAttendance() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceTableName,
        where: 'posted = ?',
        whereArgs: [0],
      );

      debugPrint('📊 [REPO-IN] Found ${maps.length} unposted records');

      return List.generate(maps.length, (i) {
        return AttendanceModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error getting unposted records: $e');
      return [];
    }
  }

  // Add attendance record
  Future<int> addAttendance(AttendanceModel attendance) async {
    try {
      final db = await dbHelper.db;
      attendance.posted = 0;

      // Check if already exists
      final existing = await db.query(
        attendanceTableName,
        where: 'attendance_in_id = ?',
        whereArgs: [attendance.attendance_in_id],
      );

      if (existing.isNotEmpty) {
        debugPrint('⚠️ [REPO-IN] Duplicate record found, skipping: ${attendance.attendance_in_id}');
        return 0;
      }

      debugPrint('✅ [REPO-IN] Adding new record: ${attendance.attendance_in_id}');
      return await db.insert(attendanceTableName, attendance.toMap());
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error adding record: $e');
      return -1;
    }
  }

  // Update attendance record
  Future<int> updateAttendance(AttendanceModel attendance) async {
    try {
      final db = await dbHelper.db;
      debugPrint('✏️ [REPO-IN] Updating record: ${attendance.attendance_in_id}');
      return await db.update(
        attendanceTableName,
        attendance.toMap(),
        where: 'attendance_in_id = ?',
        whereArgs: [attendance.attendance_in_id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error updating record: $e');
      rethrow;
    }
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    try {
      final db = await dbHelper.db;
      await db.update(
        attendanceTableName,
        {'posted': 1},
        where: 'attendance_in_id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ [REPO-IN] Marked as posted: $id');
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error marking as posted: $e');
    }
  }

  // Post single record to API with retry logic
  Future<bool> postToAPI(AttendanceModel attendance) async {
    const int maxRetries = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🌐 [REPO-IN] Attempt $attempt: Posting ${attendance.attendance_in_id}');

        final response = await http.post(
          Uri.parse(attendanceInApi),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(attendance.toJson()),
        ).timeout(const Duration(seconds: 15));

        debugPrint('📡 [REPO-IN] Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ [REPO-IN] Posted successfully: ${attendance.attendance_in_id}');
          await markAsPosted(attendance.attendance_in_id!);
          _postedIds.add(attendance.attendance_in_id.toString());
          return true;
        } else if (response.statusCode == 409) {
          // Already exists on server — treat as success
          debugPrint('⚠️ [REPO-IN] Record already exists on server: ${attendance.attendance_in_id}');
          await markAsPosted(attendance.attendance_in_id!);
          return true;
        } else {
          debugPrint('❌ [REPO-IN] Server error ${response.statusCode}: ${response.body}');
          if (attempt < maxRetries) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      } catch (e) {
        debugPrint('❌ [REPO-IN] Attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    return false;
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    debugPrint('🔄 [REPO-IN] ===== STARTING SYNC =====');

    if (!await isNetworkAvailable()) {
      debugPrint('📴 [REPO-IN] No internet connection. Skipping sync.');
      return;
    }

    final unposted = await getUnPostedAttendance();

    if (unposted.isEmpty) {
      debugPrint('📭 [REPO-IN] No unposted attendance records');
      return;
    }

    debugPrint('🔄 [REPO-IN] Syncing ${unposted.length} attendance records');

    // Deduplicate before posting
    final Map<String, AttendanceModel> uniqueRecords = {};
    for (var record in unposted) {
      if (record.attendance_in_id != null) {
        uniqueRecords[record.attendance_in_id.toString()] = record;
      }
    }

    int successCount = 0;
    int failCount = 0;

    for (var record in uniqueRecords.values) {
      // Skip if already posted in this session
      if (_postedIds.contains(record.attendance_in_id.toString())) {
        debugPrint('⚠️ [REPO-IN] Skipping already posted in session: ${record.attendance_in_id}');
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

    debugPrint('📊 [REPO-IN] Sync results: $successCount success, $failCount failed');
    debugPrint('🔄 [REPO-IN] ===== SYNC COMPLETED =====');
  }

  // Delete record
  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    debugPrint('🗑️ [REPO-IN] Deleting record: $id');
    return await db.delete(
      attendanceTableName,
      where: 'attendance_in_id = ?',
      whereArgs: [id],
    );
  }

  // Generate unique attendance ID
  Future<String> generateAttendanceId() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('attendanceInCounter') ?? 1;

    final now = DateTime.now();
    final month = DateFormat('MMM').format(now);
    final day = DateFormat('dd').format(now);

    String id = "ATD-$emp_id-$day-$month-${counter.toString().padLeft(3, '0')}";

    await prefs.setInt('attendanceInCounter', counter + 1);
    debugPrint('🔢 [REPO-IN] Generated ID: $id');
    return id;
  }

  // Clear posted cache
  void clearPostedCache() {
    _postedIds.clear();
    debugPrint('🧹 [REPO-IN] Cleared posted IDs cache');
  }
}