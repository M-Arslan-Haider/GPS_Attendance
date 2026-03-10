import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/attendance_out_repository.dart';
import '../ViewModels/location_view_model.dart';
import '../../constants.dart';

class AttendanceViewModel extends GetxController {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final AttendanceOutRepository _attendanceOutRepo = AttendanceOutRepository();

  // Lazy getter — safe even if LocationViewModel is registered after this VM
  LocationViewModel get _locationVM => Get.find<LocationViewModel>();

  // Observables
  var allAttendance = <AttendanceModel>[].obs;
  var isClockedIn = false.obs;
  var isLoading = false.obs;
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

  // ─────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────

  Future<void> fetchAllAttendance() async {
    final attendance = await _attendanceRepo.getAttendance();
    allAttendance.value = attendance;
  }

  // ─────────────────────────────────────────────
  // CLOCK STATE PERSISTENCE
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_clockInTime != null) {
        final duration = DateTime.now().difference(_clockInTime!);
        elapsedTime.value = _formatDuration(duration);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  // ─────────────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────────────

  Future<bool> isLocationAvailable() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// ✅ FAST: Uses low accuracy + 5s timeout so clock-in is near-instant.
  /// Reverse geocoding runs in background and won't block clock-in.
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // ✅ Use low accuracy + 5s timeout for speed
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 5), onTimeout: () async {
        // Fallback: use last known position if timeout
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
        throw TimeoutException('GPS timeout');
      });

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;

      // Keep LocationViewModel globals in sync for GPX tracker
      try {
        _locationVM.globalLatitude1.value = position.latitude;
        _locationVM.globalLongitude1.value = position.longitude;
      } catch (_) {}

      // ✅ Reverse geocoding runs in background — doesn't block clock-in
      _reverseGeocodeInBackground(position.latitude, position.longitude);

    } catch (e) {
      debugPrint('❌ [VM] Location error: $e');
      // Use LocationViewModel coords as fallback if available
      try {
        if (_locationVM.globalLatitude1.value != 0.0) {
          currentLat.value = _locationVM.globalLatitude1.value;
          currentLng.value = _locationVM.globalLongitude1.value;
        }
      } catch (_) {}
    }
  }

  void _reverseGeocodeInBackground(double lat, double lng) {
    Future.microtask(() async {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng)
            .timeout(const Duration(seconds: 8));
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address =
          '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}'.trim();
          currentAddress.value = address;
          try { _locationVM.shopAddress.value = address; } catch (_) {}
        }
      } catch (e) {
        final fallback = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
        currentAddress.value = fallback;
        try { _locationVM.shopAddress.value = fallback; } catch (_) {}
      }
    });
  }

  // ─────────────────────────────────────────────
  // 🎯 CLOCK IN  (target: <2 seconds)
  // ─────────────────────────────────────────────

  Future<void> clockIn() async {
    if (isClockedIn.value) {
      Get.snackbar('Already Clocked In', 'You are already clocked in',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // ✅ FAST: get location with timeout
      await getCurrentLocation();

      // Accept 0.0 coords — don't block clock-in if GPS slow
      final attendanceId = await _attendanceRepo.generateAttendanceId();

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
        posted: 0,
      );

      // ✅ Save locally — instant
      await _attendanceRepo.addAttendance(attendance);

      // Update state immediately
      _clockInTime = DateTime.now();
      isClockedIn.value = true;
      _startTimer();

      // Persist state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsClockedIn, true);
      await prefs.setString(prefClockInTime, _clockInTime!.toIso8601String());
      await prefs.setString(prefAttendanceId, attendanceId);
      await prefs.setInt(prefSecondsPassed, 0);

      // Start LocationViewModel timer for GPX tracking
      try {
        _locationVM.saveClockStatus(true);
        _locationVM.startTimer();
      } catch (_) {}

      // ✅ FIRE-AND-FORGET: post to API in background, don't await
      _postInBackground(attendance);

      Get.snackbar('✅ Clocked In', 'GPS tracking started',
          backgroundColor: Colors.green, colorText: Colors.white,
          duration: const Duration(seconds: 2));

      fetchAllAttendance();
    } catch (e) {
      debugPrint('❌ [VM] Clock in error: $e');
      Get.snackbar('Error', 'Failed to clock in. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _postInBackground(AttendanceModel attendance) {
    Future.microtask(() async {
      try {
        if (await isNetworkAvailable()) {
          await _attendanceRepo.postToAPI(attendance);
        }
      } catch (e) {
        debugPrint('⚠️ [VM] Background post error (will retry on sync): $e');
      }
    });
  }

  void _postOutInBackground(AttendanceOutModel attendanceOut) {
    Future.microtask(() async {
      try {
        if (await isNetworkAvailable()) {
          await _attendanceOutRepo.postToAPI(attendanceOut);
        }
      } catch (e) {
        debugPrint('⚠️ [VM] Background post-out error (will retry on sync): $e');
      }
    });
  }

  // ─────────────────────────────────────────────
  // 🎯 CLOCK OUT  (target: <2 seconds)
  // ─────────────────────────────────────────────

  Future<void> clockOut() async {
    if (!isClockedIn.value) {
      Get.snackbar('Not Clocked In', 'Please clock in first',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clock Out'),
        content: const Text('Are you sure you want to clock out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final attendanceId = prefs.getString(prefAttendanceId) ??
          await _attendanceRepo.generateAttendanceId();
      final clockOutTime = DateTime.now();

      // ✅ Calculate elapsed time locally — instant, no async needed
      String totalTime = '00:00:00';
      try {
        totalTime = await _locationVM.stopTimer();
      } catch (_) {
        if (_clockInTime != null) {
          totalTime = _formatDuration(clockOutTime.difference(_clockInTime!));
        }
      }

      // ✅ Get cached distance — instant (no network)
      double distanceKm = _currentCachedDistance;
      try {
        distanceKm = await _locationVM.getImmediateDistance()
            .timeout(const Duration(seconds: 2), onTimeout: () => _currentCachedDistance);
      } catch (_) {}

      final String totalDistance = distanceKm.toStringAsFixed(3);

      // Persist for background operations
      await prefs.setString(prefTotalDistance, totalDistance);
      await prefs.setDouble('fullClockOutDistance', distanceKm);
      await prefs.setString('fullClockOutTime', clockOutTime.toIso8601String());

      double outLat = currentLat.value;
      double outLng = currentLng.value;
      String outAddress = currentAddress.value;

      // Use LocationViewModel coords if better
      try {
        if (_locationVM.globalLatitude1.value != 0.0) {
          outLat = _locationVM.globalLatitude1.value;
          outLng = _locationVM.globalLongitude1.value;
          await prefs.setDouble('pendingLatOut', outLat);
          await prefs.setDouble('pendingLngOut', outLng);
        }
        if (_locationVM.shopAddress.value.isNotEmpty) {
          outAddress = _locationVM.shopAddress.value;
          await prefs.setString('pendingAddress', outAddress);
        }
      } catch (_) {}

      final attendanceOut = AttendanceOutModel(
        attendance_out_id: attendanceId,
        emp_id: emp_id,
        total_time: totalTime,
        lat_out: outLat,
        lng_out: outLng,
        total_distance: totalDistance,
        address: outAddress,
        attendance_out_date: clockOutTime,
        attendance_out_time: clockOutTime,
        reason: 'manual',
        posted: 0,
      );

      // ✅ Save locally — instant
      await _attendanceOutRepo.addAttendanceOut(attendanceOut);

      // Stop LocationViewModel
      try { _locationVM.saveClockStatus(false); } catch (_) {}

      // Reset state immediately
      isClockedIn.value = false;
      _timer?.cancel();
      elapsedTime.value = '00:00:00';
      _clockInTime = null;

      // Clear persisted state
      await prefs.remove(prefIsClockedIn);
      await prefs.remove(prefClockInTime);
      await prefs.remove(prefAttendanceId);
      await prefs.remove(prefTotalDistance);
      await prefs.setInt(prefSecondsPassed, 0);

      // ✅ FIRE-AND-FORGET: post + GPX consolidation in background
      _postOutInBackground(attendanceOut);
      _schedulePostClockOutOperations(clockOutTime, distanceKm);

      Get.snackbar(
        '✅ Clock Out Complete',
        'Time: $totalTime  |  Distance: ${totalDistance}km',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      fetchAllAttendance();
    } catch (e) {
      debugPrint('❌ [VM] Clock out error: $e');
      Get.snackbar('Error', 'Failed to clock out. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Cached distance — updated by timer_card's _updateCurrentDistance
  double _currentCachedDistance = 0.0;
  void updateCachedDistance(double d) => _currentCachedDistance = d;

  // ─────────────────────────────────────────────
  // POST CLOCK-OUT BACKGROUND OPERATIONS
  // ─────────────────────────────────────────────

  void _schedulePostClockOutOperations(DateTime clockOutTime, double distance) {
    Timer(const Duration(seconds: 5), () async {
      try {
        debugPrint('🔄 [VM] Post-clockout: consolidating GPX...');
        await _locationVM.consolidateDailyGPXDataForDate(clockOutTime);
        await _locationVM.saveLocationFromConsolidatedFileForDate(clockOutTime);
        debugPrint('✅ [VM] Post-clockout complete. Distance: ${distance.toStringAsFixed(3)} km');
      } catch (e) {
        debugPrint('❌ [VM] Post-clockout background error: $e');
      }
    });
  }

  // ─────────────────────────────────────────────
  // SYNC
  // ─────────────────────────────────────────────

  Future<void> syncUnposted() async {
    await _attendanceRepo.syncUnposted();
    await _attendanceOutRepo.syncUnposted();
    fetchAllAttendance();
  }

  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await isNetworkAvailable()) {
        await _attendanceRepo.syncUnposted();
        await _attendanceOutRepo.syncUnposted();
      }
    });
  }
}