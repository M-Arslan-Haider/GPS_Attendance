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

  // Get all attendance records
  Future<List<AttendanceModel>> getAttendance() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceTableName,
      orderBy: 'attendance_in_date DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  // Get unposted attendance records
  Future<List<AttendanceModel>> getUnPostedAttendance() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceTableName,
      where: 'posted = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  // Add attendance record
  Future<int> addAttendance(AttendanceModel attendance) async {
    final db = await dbHelper.db;
    attendance.posted = 0;

    // Check if already exists
    final existing = await db.query(
      attendanceTableName,
      where: 'attendance_in_id = ?',
      whereArgs: [attendance.attendance_in_id],
    );

    if (existing.isNotEmpty) {
      debugPrint('⚠️ Attendance already exists: ${attendance.attendance_in_id}');
      return 0;
    }

    return await db.insert(attendanceTableName, attendance.toMap());
  }

  // Update attendance record
  Future<int> updateAttendance(AttendanceModel attendance) async {
    final db = await dbHelper.db;
    return await db.update(
      attendanceTableName,
      attendance.toMap(),
      where: 'attendance_in_id = ?',
      whereArgs: [attendance.attendance_in_id],
    );
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    final db = await dbHelper.db;
    await db.update(
      attendanceTableName,
      {'posted': 1},
      where: 'attendance_in_id = ?',
      whereArgs: [id],
    );
  }

  // Post to API
  Future<bool> postToAPI(AttendanceModel attendance) async {
    try {
      final response = await http.post(
        Uri.parse(attendanceInApi),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(attendance.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Attendance posted: ${attendance.attendance_in_id}');
        await markAsPosted(attendance.attendance_in_id!);
        return true;
      } else {
        debugPrint('❌ API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network error: $e');
      return false;
    }
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    if (!await isNetworkAvailable()) {
      debugPrint('📴 No internet connection');
      return;
    }

    final unposted = await getUnPostedAttendance();
    if (unposted.isEmpty) {
      debugPrint('📭 No unposted attendance records');
      return;
    }

    debugPrint('🔄 Syncing ${unposted.length} attendance records');
    for (var attendance in unposted) {
      await postToAPI(attendance);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Generate attendance ID
  Future<String> generateAttendanceId() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('attendanceCounter') ?? 1;

    final now = DateTime.now();
    final month = DateFormat('MMM').format(now);
    final day = DateFormat('dd').format(now);

    String id = "ATD-$emp_id-$day-$month-${counter.toString().padLeft(3, '0')}";

    await prefs.setInt('attendanceCounter', counter + 1);
    return id;
  }
}