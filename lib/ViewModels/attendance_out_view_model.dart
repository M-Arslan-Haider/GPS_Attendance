import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../repositories/attendance_out_repository.dart';
import '../../constants.dart';

class AttendanceOutViewModel extends GetxController {
  final AttendanceOutRepository _attendanceOutRepo = AttendanceOutRepository();

  var allAttendanceOut = <AttendanceOutModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    fetchAllAttendanceOut();
    _startPeriodicSync();
  }

  // Load all attendance out records
  Future<void> fetchAllAttendanceOut() async {
    final records = await _attendanceOutRepo.getAttendanceOut();
    allAttendanceOut.value = records;
  }

  // Add attendance out record
  Future<void> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    await _attendanceOutRepo.addAttendanceOut(attendanceOut);
    fetchAllAttendanceOut();
  }

  // ✅ ADD THIS METHOD - Sync unposted records
  Future<void> syncUnposted() async {
    await _attendanceOutRepo.syncUnposted();
    fetchAllAttendanceOut();
  }

  // Get today's clock outs count
  Future<int> getTodayClockOutsCount() async {
    final records = await _attendanceOutRepo.getAttendanceOut();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return records.where((r) {
      if (r.attendance_out_date is String) {
        return r.attendance_out_date.toString().contains(today.substring(5, 7));
      }
      return false;
    }).length;
  }

  // Periodic sync
  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await isNetworkAvailable()) {
        await _attendanceOutRepo.syncUnposted();
      }
    });
  }
}