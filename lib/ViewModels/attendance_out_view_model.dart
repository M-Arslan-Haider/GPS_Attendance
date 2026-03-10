// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../Database/util.dart';
// import '../Models/attendanceOut_model.dart';
// import '../repositories/attendance_out_repository.dart';
// import '../../constants.dart';
//
// class AttendanceOutViewModel extends GetxController {
//   final AttendanceOutRepository _attendanceOutRepo = AttendanceOutRepository();
//
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   var isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadEmployeeData();
//     fetchAllAttendanceOut();
//     _startPeriodicSync();
//   }
//
//   @override
//   void onClose() {
//     super.onClose();
//   }
//
//   // ─────────────────────────────────────────────
//   // DATA FETCHING
//   // ─────────────────────────────────────────────
//
//   Future<void> fetchAllAttendanceOut() async {
//     isLoading.value = true;
//     try {
//       final records = await _attendanceOutRepo.getAttendanceOut();
//       allAttendanceOut.value = records;
//       debugPrint('📋 [VM-OUT] Loaded ${records.length} attendance out records');
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Error loading records: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // ADD ATTENDANCE OUT
//   // ─────────────────────────────────────────────
//
//   Future<void> addAttendanceOut(AttendanceOutModel attendanceOut) async {
//     try {
//       await _attendanceOutRepo.addAttendanceOut(attendanceOut);
//       fetchAllAttendanceOut();
//       debugPrint('✅ [VM-OUT] Added attendance out: ${attendanceOut.attendance_out_id}');
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Error adding record: $e');
//     }
//   }
//
//   // 🚀 OPTIMIZED FAST SAVE - COMPLETES IN <1 SECOND
//   Future<void> fastSaveAttendanceOut({
//     required DateTime clockOutTime,
//     required double totalDistance,
//     required bool isAuto,
//     required String reason,
//   }) async {
//     try {
//       final String attendanceId =
//           'ATD-OUT-$emp_id-${DateFormat('ddMMMyyyyHHmmss').format(clockOutTime)}';
//
//       debugPrint('⚡ [VM-OUT] Fast saving: $attendanceId | isAuto: $isAuto | reason: $reason');
//
//       final AttendanceOutModel attendanceOut = AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         emp_id: emp_id,
//         total_time: '00:00:00', // Updated later by background heavy ops
//         lat_out: 0.0,           // Updated later by background heavy ops
//         lng_out: 0.0,
//         total_distance: totalDistance.toStringAsFixed(2),
//         address: '',
//         attendance_out_date: clockOutTime,
//         attendance_out_time: clockOutTime,
//         reason: reason,
//         posted: 0,
//       );
//
//       // Save locally only (instant)
//       await _attendanceOutRepo.addAttendanceOut(attendanceOut);
//       debugPrint('💾 [VM-OUT] Saved locally: $attendanceId');
//
//       // Fire-and-forget API post
//       _postInBackground(attendanceOut);
//
//       fetchAllAttendanceOut();
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Fast save error: $e');
//     }
//   }
//
//   void _postInBackground(AttendanceOutModel attendanceOut) {
//     Future.microtask(() async {
//       try {
//         if (await isNetworkAvailable()) {
//           final posted = await _attendanceOutRepo.postToAPI(attendanceOut);
//           if (posted) {
//             debugPrint('✅ [VM-OUT] Posted to API: ${attendanceOut.attendance_out_id}');
//           } else {
//             debugPrint('⚠️ [VM-OUT] API post failed — will retry on next sync');
//           }
//         } else {
//           debugPrint('📴 [VM-OUT] Offline — stored locally, will sync later');
//         }
//       } catch (e) {
//         debugPrint('⚠️ [VM-OUT] Background post error: $e');
//       }
//     });
//   }
//
//   // ─────────────────────────────────────────────
//   // SYNC
//   // ─────────────────────────────────────────────
//
//   Future<void> syncUnposted() async {
//     isLoading.value = true;
//     try {
//       await _attendanceOutRepo.syncUnposted();
//       fetchAllAttendanceOut();
//       debugPrint('✅ [VM-OUT] Sync completed');
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Sync error: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // UTILITY METHODS
//   // ─────────────────────────────────────────────
//
//   Future<int> getTodayClockOutsCount() async {
//     try {
//       final records = await _attendanceOutRepo.getAttendanceOut();
//       final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
//
//       return records.where((r) {
//         if (r.attendance_out_date is String) {
//           return r.attendance_out_date.toString() == today;
//         } else if (r.attendance_out_date is DateTime) {
//           return DateFormat('dd-MMM-yyyy').format(r.attendance_out_date) == today;
//         }
//         return false;
//       }).length;
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Error getting today count: $e');
//       return 0;
//     }
//   }
//
//   Future<int> getUnpostedCount() async {
//     try {
//       final unposted = await _attendanceOutRepo.getUnPostedAttendanceOut();
//       return unposted.length;
//     } catch (e) {
//       debugPrint('❌ [VM-OUT] Error getting unposted count: $e');
//       return 0;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // PERIODIC SYNC
//   // ─────────────────────────────────────────────
//
//   void _startPeriodicSync() {
//     Timer.periodic(const Duration(minutes: 5), (timer) async {
//       if (await isNetworkAvailable()) {
//         debugPrint('⏰ [VM-OUT] Periodic sync triggered');
//         await _attendanceOutRepo.syncUnposted();
//         fetchAllAttendanceOut();
//       }
//     });
//   }
// }


import 'dart:async';
import 'package:flutter/foundation.dart';
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
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    fetchAllAttendanceOut();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // DATA FETCHING
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // ADD ATTENDANCE OUT
  // ─────────────────────────────────────────────

  Future<void> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      await _attendanceOutRepo.addAttendanceOut(attendanceOut);
      fetchAllAttendanceOut();
      debugPrint('✅ [VM-OUT] Added attendance out: ${attendanceOut.attendance_out_id}');
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error adding record: $e');
    }
  }

  // ─────────────────────────────────────────────
  // 🚀 FAST SAVE — all fields populated before save/post
  // ─────────────────────────────────────────────

  Future<void> fastSaveAttendanceOut({
    required DateTime clockOutTime,
    required double totalDistance,
    required bool isAuto,
    required String reason,
  }) async {
    try {
      final String attendanceId =
          'ATD-OUT-$emp_id-${DateFormat('ddMMMyyyyHHmmss').format(clockOutTime)}';

      debugPrint('⚡ [VM-OUT] Fast saving: $attendanceId | isAuto: $isAuto | reason: $reason');

      // ✅ Read real location + clock-in time from SharedPreferences
      //    (written by _handleClockOut in timer_card.dart before this is called)
      final prefs = await SharedPreferences.getInstance();

      final double latOut  = prefs.getDouble('pendingLatOut')  ?? 0.0;
      final double lngOut  = prefs.getDouble('pendingLngOut')  ?? 0.0;
      final String address = prefs.getString('pendingAddress') ?? '';

      // Compute total_time from stored clock-in timestamp
      String totalTime = '00:00:00';
      final String? clockInStr = prefs.getString(prefClockInTime);
      if (clockInStr != null) {
        try {
          final clockIn  = DateTime.parse(clockInStr);
          final duration = clockOutTime.difference(clockIn);
          String two(int n) => n.toString().padLeft(2, '0');
          totalTime =
          '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}';
        } catch (_) {}
      }

      debugPrint('📍 [VM-OUT] lat=$latOut, lng=$lngOut, address=$address, totalTime=$totalTime');

      final AttendanceOutModel attendanceOut = AttendanceOutModel(
        attendance_out_id: attendanceId,
        emp_id: emp_id,                                  // ✅ maps to user_id in DB/API
        total_time: totalTime,                           // ✅ real computed value
        lat_out: latOut,                                 // ✅ real GPS value
        lng_out: lngOut,                                 // ✅ real GPS value
        total_distance: totalDistance.toStringAsFixed(2),
        address: address,                                // ✅ real address
        attendance_out_date: clockOutTime,
        attendance_out_time: clockOutTime,
        reason: reason,
        posted: 0,
      );

      // Save locally (instant)
      await _attendanceOutRepo.addAttendanceOut(attendanceOut);
      debugPrint('💾 [VM-OUT] Saved locally: $attendanceId');

      // Fire-and-forget API post
      _postInBackground(attendanceOut);

      fetchAllAttendanceOut();
    } catch (e) {
      debugPrint('❌ [VM-OUT] Fast save error: $e');
    }
  }

  void _postInBackground(AttendanceOutModel attendanceOut) {
    Future.microtask(() async {
      try {
        if (await isNetworkAvailable()) {
          final posted = await _attendanceOutRepo.postToAPI(attendanceOut);
          if (posted) {
            debugPrint('✅ [VM-OUT] Posted to API: ${attendanceOut.attendance_out_id}');
          } else {
            debugPrint('⚠️ [VM-OUT] API post failed — will retry on next sync');
          }
        } else {
          debugPrint('📴 [VM-OUT] Offline — stored locally, will sync later');
        }
      } catch (e) {
        debugPrint('⚠️ [VM-OUT] Background post error: $e');
      }
    });
  }

  // ─────────────────────────────────────────────
  // SYNC
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // UTILITY
  // ─────────────────────────────────────────────

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

  Future<int> getUnpostedCount() async {
    try {
      final unposted = await _attendanceOutRepo.getUnPostedAttendanceOut();
      return unposted.length;
    } catch (e) {
      debugPrint('❌ [VM-OUT] Error getting unposted count: $e');
      return 0;
    }
  }

  // ─────────────────────────────────────────────
  // PERIODIC SYNC
  // ─────────────────────────────────────────────

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