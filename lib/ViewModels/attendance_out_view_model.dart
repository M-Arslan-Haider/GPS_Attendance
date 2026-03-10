import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../repositories/attendance_out_repository.dart';
import '../../constants.dart';

class AttendanceOutViewModel extends GetxController {
  final AttendanceOutRepository _attendanceOutRepo = AttendanceOutRepository();

  // Observable list of all attendance out records
  var allAttendanceOut = <AttendanceOutModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    fetchAllAttendanceOut();
    _startPeriodicSync();
  }

  // Load all attendance out records
  Future<void> fetchAllAttendanceOut() async {
    isLoading.value = true;
    try {
      final records = await _attendanceOutRepo.getAttendanceOut();
      allAttendanceOut.value = records;
      debugPrint('📋 [VM-OUT] Loaded ${records.length} attendance out records');
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error loading records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add attendance out record (pass full model)
  Future<void> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      await _attendanceOutRepo.addAttendanceOut(attendanceOut);
      fetchAllAttendanceOut();
      debugPrint('✅ [VM-OUT] Added attendance out: ${attendanceOut.attendance_out_id}');
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error adding record: $e');
    }
  }

  // ✅ Fast save — builds AttendanceOutModel from named params and saves immediately.
  // Called from timer_card.dart for both auto clock-out and manual clock-out.
  // No dialogs, no snackbars — silent and offline-safe.
  Future<void> fastSaveAttendanceOut({
    required DateTime clockOutTime,
    required double totalDistance,
    required bool isAuto,
    required String reason,
  }) async {
    try {
      // Build unique ID: ATD-OUT-{emp_id}-{timestamp}
      final String attendanceId =
          'ATD-OUT-$emp_id-${DateFormat('ddMMMyyyyHHmmss').format(clockOutTime)}';

      debugPrint(
          '⚡ [VM-OUT] Fast saving: $attendanceId | isAuto: $isAuto | reason: $reason');

      final AttendanceOutModel attendanceOut = AttendanceOutModel(
        attendance_out_id: attendanceId,
        emp_id: emp_id,
        total_time: '00:00:00', // Updated later by background heavy ops
        lat_out: 0.0,           // Updated later by background heavy ops
        lng_out: 0.0,
        total_distance: totalDistance.toStringAsFixed(2),
        address: '',
        attendance_out_date: clockOutTime,
        attendance_out_time: clockOutTime,
        reason: reason,
        posted: 0,
      );

      // Always save locally first (offline-safe)
      await _attendanceOutRepo.addAttendanceOut(attendanceOut);
      debugPrint('💾 [VM-OUT] Saved locally: $attendanceId');

      // Try immediate API post if network available
      if (await isNetworkAvailable()) {
        final posted = await _attendanceOutRepo.postToAPI(attendanceOut);
        if (posted) {
          debugPrint('✅ [VM-OUT] Posted to API: $attendanceId');
        } else {
          debugPrint('⚠️ [VM-OUT] API post failed — will retry on next sync: $attendanceId');
        }
      } else {
        debugPrint('📴 [VM-OUT] Offline — stored locally, will sync later: $attendanceId');
      }

      fetchAllAttendanceOut();
    } catch (e) {
      debugPrint('❌ [VM-OUT] Fast save error: $e');
    }
  }

  // Manually sync unposted records
  Future<void> syncUnposted() async {
    isLoading.value = true;
    try {
      await _attendanceOutRepo.syncUnposted();
      fetchAllAttendanceOut();
      debugPrint('✅ [VM-OUT] Sync completed');
    } catch (e) {
      debugPrint('❌ [VM-OUT] Sync error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get today's clock out count
  Future<int> getTodayClockOutsCount() async {
    try {
      final records = await _attendanceOutRepo.getAttendanceOut();
      final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

      return records.where((r) {
        if (r.attendance_out_date is String) {
          return r.attendance_out_date.toString() == today;
        } else if (r.attendance_out_date is DateTime) {
          return DateFormat('dd-MMM-yyyy').format(r.attendance_out_date) == today;
        }
        return false;
      }).length;
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error getting today count: $e');
      return 0;
    }
  }

  // Get unposted count (useful for badge/indicator in UI)
  Future<int> getUnpostedCount() async {
    try {
      final unposted = await _attendanceOutRepo.getUnPostedAttendanceOut();
      return unposted.length;
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error getting unposted count: $e');
      return 0;
    }
  }

  // Periodic background sync every 5 minutes
  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await isNetworkAvailable()) {
        debugPrint('⏰ [VM-OUT] Periodic sync triggered');
        await _attendanceOutRepo.syncUnposted();
        fetchAllAttendanceOut();
      }
    });
  }
}