import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/attendance_out_repository.dart';
import '../../constants.dart';

class AttendanceViewModel extends GetxController {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final AttendanceOutRepository _attendanceOutRepo = AttendanceOutRepository(); // ✅ DEFINED HERE

  // Observable variables
  var allAttendance = <AttendanceModel>[].obs;
  var isClockedIn = false.obs;
  var elapsedTime = '00:00:00'.obs;
  var currentLat = 0.0.obs;
  var currentLng = 0.0.obs;
  var currentAddress = ''.obs;

  Timer? _timer;
  DateTime? _clockInTime;

  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    fetchAllAttendance();
    _loadClockState();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Load all attendance
  Future<void> fetchAllAttendance() async {
    final attendance = await _attendanceRepo.getAttendance();
    allAttendance.value = attendance;
  }

  // Load clock state from prefs
  Future<void> _loadClockState() async {
    final prefs = await SharedPreferences.getInstance();
    isClockedIn.value = prefs.getBool(prefIsClockedIn) ?? false;

    if (isClockedIn.value) {
      final timeStr = prefs.getString(prefClockInTime);
      if (timeStr != null) {
        _clockInTime = DateTime.parse(timeStr);
        _startTimer();
      }
    }
  }

  // Start timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_clockInTime != null) {
        final duration = DateTime.now().difference(_clockInTime!);
        elapsedTime.value = _formatDuration(duration);
      }
    });
  }

  // Format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;

      // Get address from coordinates
      try {
        final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          currentAddress.value = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}';
        }
      } catch (e) {
        currentAddress.value = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      debugPrint('❌ Location error: $e');
    }
  }

  // 🎯 CLOCK IN
  Future<void> clockIn() async {
    if (isClockedIn.value) {
      Get.snackbar(
        'Already Clocked In',
        'You are already clocked in',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Get location first
    await getCurrentLocation();

    if (currentLat.value == 0.0) {
      Get.snackbar(
        'Location Required',
        'Unable to get your location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Generate attendance ID
    final attendanceId = await _attendanceRepo.generateAttendanceId();

    // Create attendance record
    final attendance = AttendanceModel(
      attendance_in_id: attendanceId,
      emp_id: emp_id,
      lat_in: currentLat.value,
      lng_in: currentLng.value,
      booker_name: emp_name,
      designation: emp_job,
      city: emp_city,
      address: currentAddress.value,
      attendance_in_date: DateTime.now(),
      attendance_in_time: DateTime.now(),
    );

    // Save to local database
    await _attendanceRepo.addAttendance(attendance);

    // Update state
    _clockInTime = DateTime.now();
    isClockedIn.value = true;
    _startTimer();

    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsClockedIn, true);
    await prefs.setString(prefClockInTime, _clockInTime!.toIso8601String());
    await prefs.setString(prefAttendanceId, attendanceId);

    // Try to post immediately
    if (await isNetworkAvailable()) {
      await _attendanceRepo.postToAPI(attendance);
    }

    Get.snackbar(
      'Clock In Successful',
      'Your shift has started',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    fetchAllAttendance();
  }

  // 🎯 CLOCK OUT
  Future<void> clockOut() async {
    if (!isClockedIn.value) {
      Get.snackbar(
        'Not Clocked In',
        'Please clock in first',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Confirm clock out
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clock Out'),
        content: const Text('Are you sure you want to clock out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Get final location
    await getCurrentLocation();

    // Get attendance ID from prefs
    final prefs = await SharedPreferences.getInstance();
    final attendanceId = prefs.getString(prefAttendanceId) ??
        await _attendanceRepo.generateAttendanceId();

    // Calculate total time
    final clockOutTime = DateTime.now();
    final totalTime = _formatDuration(clockOutTime.difference(_clockInTime!));

    // Create attendance out record
    final attendanceOut = AttendanceOutModel(
      attendance_out_id: attendanceId,
      emp_id: emp_id,
      total_time: totalTime,
      lat_out: currentLat.value,
      lng_out: currentLng.value,
      total_distance: '0',
      address: currentAddress.value,
      attendance_out_date: clockOutTime,
      attendance_out_time: clockOutTime,
      reason: 'manual',
    );

    // Save to database
    await _attendanceOutRepo.addAttendanceOut(attendanceOut); // ✅ USING _attendanceOutRepo HERE

    // Update state
    isClockedIn.value = false;
    _timer?.cancel();
    elapsedTime.value = '00:00:00';

    // Clear prefs
    await prefs.remove(prefIsClockedIn);
    await prefs.remove(prefClockInTime);
    await prefs.remove(prefAttendanceId);

    // Try to post immediately
    if (await isNetworkAvailable()) {
      await _attendanceOutRepo.postToAPI(attendanceOut); // ✅ USING _attendanceOutRepo HERE
    }

    Get.snackbar(
      'Clock Out Successful',
      'Total Time: $totalTime',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    fetchAllAttendance();
  }

  // ✅ SYNC UNPOSTED ATTENDANCE - DEFINED HERE
  Future<void> syncUnposted() async {
    await _attendanceRepo.syncUnposted();
    fetchAllAttendance();
  }

  // Periodic sync
  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await isNetworkAvailable()) {
        await _attendanceRepo.syncUnposted();
        await _attendanceOutRepo.syncUnposted(); // ✅ USING _attendanceOutRepo HERE
      }
    });
  }
}