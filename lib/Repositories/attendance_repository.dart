import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../Database/db_helper.dart';
import '../Models/attendance_Model.dart';

class AttendanceRepository {
  final DBHelper _dbHelper = DBHelper();

  static const String _postApiUrl =
      'http://oracle.metaxperts.net/ords/production/attendanceinpost/post/';

  // ─────────────────────────────────────────────
  // READ – all records
  // ─────────────────────────────────────────────
  Future<List<AttendanceModel>> getAll() async {
    final rows = await _dbHelper.getAll(DBHelper.attendanceTable);
    return rows.map((row) => AttendanceModel.fromMap(row)).toList();
  }

  // ─────────────────────────────────────────────
  // READ – unposted records only
  // ─────────────────────────────────────────────
  Future<List<AttendanceModel>> getUnposted() async {
    final rows = await _dbHelper.getUnposted(DBHelper.attendanceTable);
    return rows.map((row) => AttendanceModel.fromMap(row)).toList();
  }

  // ─────────────────────────────────────────────
  // INSERT
  // ─────────────────────────────────────────────
  Future<int> add(AttendanceModel model) async {
    // Auto-generate a UUID if no ID is provided
    model.attendance_in_id ??= const Uuid().v4();

    return await _dbHelper.insert(
      DBHelper.attendanceTable,
      model.toMap(),
    );
  }

  // ─────────────────────────────────────────────
  // MARK AS POSTED (local DB)
  // ─────────────────────────────────────────────
  Future<int> markAsPosted(String id) async {
    return await _dbHelper.markAsPosted(
      DBHelper.attendanceTable,
      'attendance_in_id',
      id,
    );
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<int> delete(String id) async {
    return await _dbHelper.delete(
      DBHelper.attendanceTable,
      'attendance_in_id',
      id,
    );
  }

  // ─────────────────────────────────────────────
  // POST single record to API
  // ─────────────────────────────────────────────
  Future<bool> _postToApi(AttendanceModel model) async {
    try {
      final response = await http.post(
        Uri.parse(_postApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(model.toMap()),
      );

      debugPrint(
          '📡 [AttendanceRepo] POST ${model.attendance_in_id} → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
            '✅ [AttendanceRepo] Posted successfully: ${model.attendance_in_id}');
        return true;
      } else {
        debugPrint(
            '❌ [AttendanceRepo] Server error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [AttendanceRepo] Network error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // SYNC – push all unposted records to API
  // ─────────────────────────────────────────────
  Future<void> syncUnposted() async {
    final unposted = await getUnposted();

    if (unposted.isEmpty) {
      debugPrint('ℹ️ [AttendanceRepo] No unposted records to sync.');
      return;
    }

    debugPrint(
        '🔄 [AttendanceRepo] Syncing ${unposted.length} unposted record(s)...');

    for (final model in unposted) {
      final success = await _postToApi(model);

      if (success) {
        await markAsPosted(model.attendance_in_id.toString());
        debugPrint(
            '✅ [AttendanceRepo] Marked as posted: ${model.attendance_in_id}');
      } else {
        debugPrint(
            '⚠️ [AttendanceRepo] Skipped (will retry later): ${model.attendance_in_id}');
      }
    }
  }
}