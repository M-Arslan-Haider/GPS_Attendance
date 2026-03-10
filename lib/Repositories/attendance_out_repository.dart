import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../../constants.dart';

class AttendanceOutRepository {
  final DBHelper dbHelper = DBHelper();

  // Get all attendance out records
  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceOutTableName,
      orderBy: 'attendance_out_date DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceOutModel.fromMap(maps[i]);
    });
  }

  // Get unposted attendance out records
  Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      attendanceOutTableName,
      where: 'posted = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return AttendanceOutModel.fromMap(maps[i]);
    });
  }

  // Add attendance out record
  Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    final db = await dbHelper.db;
    attendanceOut.posted = 0;

    // Check if already exists
    final existing = await db.query(
      attendanceOutTableName,
      where: 'attendance_out_id = ?',
      whereArgs: [attendanceOut.attendance_out_id],
    );

    if (existing.isNotEmpty) {
      debugPrint('⚠️ Attendance out already exists: ${attendanceOut.attendance_out_id}');
      return 0;
    }

    return await db.insert(attendanceOutTableName, attendanceOut.toMap());
  }

  // Update attendance out record
  Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
    final db = await dbHelper.db;
    return await db.update(
      attendanceOutTableName,
      attendanceOut.toMap(),
      where: 'attendance_out_id = ?',
      whereArgs: [attendanceOut.attendance_out_id],
    );
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    final db = await dbHelper.db;
    await db.update(
      attendanceOutTableName,
      {'posted': 1},
      where: 'attendance_out_id = ?',
      whereArgs: [id],
    );
  }

  // Post to API
  Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
    try {
      final response = await http.post(
        Uri.parse(attendanceOutApi),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(attendanceOut.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Attendance Out posted: ${attendanceOut.attendance_out_id}');
        await markAsPosted(attendanceOut.attendance_out_id!);
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

    final unposted = await getUnPostedAttendanceOut();
    if (unposted.isEmpty) {
      debugPrint('📭 No unposted attendance out records');
      return;
    }

    debugPrint('🔄 Syncing ${unposted.length} attendance out records');
    for (var attendanceOut in unposted) {
      await postToAPI(attendanceOut);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}