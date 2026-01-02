// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/attendanceOut_model.dart';
// import '../Repositories/attendance_out_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
// import 'location_view_model.dart';
// // Import the Clock-In ViewModel to access the clear state method
// import 'attendance_view_model.dart';
//
// class AttendanceOutViewModel extends GetxController {
//   var allAttendanceOut = <AttendanceOutModel>[].obs;
//   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   // Get the AttendanceViewModel instance to clear clock-in state
//   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
//
//   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
//   Timer? _deviceTimeCheckTimer;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//     attendanceOutRepository.postDataFromDatabaseToAPI();
//
//     // ✅ SIMPLE: Start checking device time for 11:58 PM
//     _startSimpleDeviceTimeCheck(); // This now calls the updated method
//   }
//
//   @override
//   void onClose() {
//     // ✅ Clean up timer
//     _deviceTimeCheckTimer?.cancel();
//     super.onClose();
//   }
//
//   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
//   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     // Use provided clock-out time or current device time
//     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
//
//     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
//     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
//     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
//
//     // Retrieve shift duration and distance
//     String? clockInTimeString = prefs.getString('clockInTime');
//     DateTime shiftStartTime = clockInTimeString != null
//         ? DateTime.parse(clockInTimeString)
//         : actualClockOutTime;
//
//     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
//     String totalTime = _formatDuration(shiftDuration);
//
//     double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
//
//     // Get attendance ID
//     final attendanceId = prefs.getString('attendanceId') ?? '';
//
//     if (attendanceId.isEmpty) {
//       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
//       await attendanceOutRepository.serialNumberGeneratorApi();
//       final newAttendanceId = prefs.getString('attendanceId') ?? '';
//
//       if (newAttendanceId.isEmpty) {
//         debugPrint("❌ Failed to generate attendance ID");
//         return;
//       }
//     }
//
//     // ✅ Add auto clock-out note if it's an auto clock-out
//     String address = locationViewModel.shopAddress.value;
//     if (clockOutTime != null) {
//       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
//     }
//
//     // ✅ Save to local database
//     addAttendanceOut(
//       AttendanceOutModel(
//         attendance_out_id: attendanceId,
//         user_id: user_id,
//         total_distance: totalDistance,
//         total_time: totalTime,
//         lat_out: locationViewModel.globalLatitude1.value,
//         lng_out: locationViewModel.globalLongitude1.value,
//         address: address,
//       ),
//     );
//
//     // ✅ Post to API
//     await attendanceOutRepository.postDataFromDatabaseToAPI();
//
//     // ✅ Clear clock-in state
//     await attendanceViewModel.clearClockInState();
//
//     debugPrint("✅ Clock-out saved successfully");
//   }
//
//   /// ✅ FORMAT DURATION TO H:mm:ss
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String hours = twoDigits(duration.inHours);
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$hours:$minutes:$seconds';
//   }
//
//   /// ✅ SIMPLE: Start checking device time for 11:58 PM
//   void _startSimpleDeviceTimeCheck() {
//     debugPrint("⏰ Starting device time check for 11:58 PM auto clock-out");
//
//     // Check every minute for 11:58 PM
//     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkFor1158PM();
//     });
//   }
//
//   /// ✅ SIMPLE: Check if it's 11:58 PM device time
//   Future<void> _checkFor1158PM() async {
//     try {
//       // Get current device time
//       DateTime now = DateTime.now();
//
//       // Check if it's exactly 11:58 PM
//       if (now.hour == 23 && now.minute == 58) {
//         debugPrint("⏰ 11:58 PM device time detected!");
//
//         // Get SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         // Check if user is clocked in
//         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//
//         if (isClockedIn) {
//           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
//
//           // Create 11:58 PM timestamp
//           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
//
//           // Save auto clock-out
//           await saveFormAttendanceOut(clockOutTime: clockOutTime);
//         } else {
//           debugPrint("⏰ User already clocked out at 11:58 PM");
//         }
//       }
//
//     } catch (e) {
//       debugPrint("❌ Error in 11:58 PM check: $e");
//     }
//   }
//
//   Future<void> fetchAllAttendanceOut() async {
//     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
//     allAttendanceOut.value = attendanceOut;
//   }
//
//   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
//     attendanceOutRepository.add(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
//     attendanceOutRepository.update(attendanceOutModel);
//     fetchAllAttendanceOut();
//   }
//
//   void deleteAttendanceOut(String id) {
//     attendanceOutRepository.delete(id);
//     fetchAllAttendanceOut();
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceOutRepository.serialNumberGeneratorApi();
//   }
// }

///gpx posted
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Repositories/attendance_out_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'location_view_model.dart';
// Import the Clock-In ViewModel to access the clear state method
import 'attendance_view_model.dart';

class AttendanceOutViewModel extends GetxController {
  var allAttendanceOut = <AttendanceOutModel>[].obs;
  final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());
  // Get the AttendanceViewModel instance to clear clock-in state
  final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();

  // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
  Timer? _deviceTimeCheckTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendanceOut();
    attendanceOutRepository.postDataFromDatabaseToAPI();

    // ✅ SIMPLE: Start checking device time for 11:58 PM
    _startSimpleDeviceTimeCheck(); // This now calls the updated method
  }

  @override
  void onClose() {
    // ✅ Clean up timer
    _deviceTimeCheckTimer?.cancel();
    super.onClose();
  }

  /// ✅ NEW: Save attendance out LOCALLY ONLY (2-second clock-out)
  Future<void> saveFormAttendanceOutLocalOnly({DateTime? clockOutTime, double? distance}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Use provided clock-out time or current device time
    DateTime actualClockOutTime = clockOutTime ?? DateTime.now();

    debugPrint("💾 [LOCAL SAVE] Saving attendance out LOCALLY (posted=0)");
    debugPrint("   🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
    debugPrint("   📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");

    // Retrieve shift duration and distance
    String? clockInTimeString = prefs.getString('clockInTime');
    DateTime shiftStartTime = clockInTimeString != null
        ? DateTime.parse(clockInTimeString)
        : actualClockOutTime;

    Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
    String totalTime = _formatDuration(shiftDuration);

    // Use provided distance or calculate
    double totalDistance = distance ?? await locationViewModel.calculateShiftDistance(shiftStartTime);

    // Get attendance ID
    final attendanceId = prefs.getString('attendanceId') ?? '';

    if (attendanceId.isEmpty) {
      debugPrint("⚠️ No matching attendanceId found for Clock Out!");
      await attendanceOutRepository.serialNumberGeneratorApi();
      final newAttendanceId = prefs.getString('attendanceId') ?? '';

      if (newAttendanceId.isEmpty) {
        debugPrint("❌ Failed to generate attendance ID");
        return;
      }
    }

    // ✅ Add auto clock-out note if it's an auto clock-out
    String address = locationViewModel.shopAddress.value;
    if (clockOutTime != null) {
      address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
    }

    // ✅ Save to local database with posted = 0 (not posted yet)
    addAttendanceOut(
      AttendanceOutModel(
        attendance_out_id: attendanceId,
        user_id: user_id,
        total_distance: totalDistance,
        total_time: totalTime,
        lat_out: locationViewModel.globalLatitude1.value,
        lng_out: locationViewModel.globalLongitude1.value,
        address: address,
        posted: 0, // ✅ IMPORTANT: Mark as not posted
      ),
    );

    // ✅ Clear clock-in state
    await attendanceViewModel.clearClockInState();

    debugPrint("✅ [LOCAL SAVE] Attendance out saved LOCALLY with posted=0");
    debugPrint("   📏 Distance: $totalDistance km");
    debugPrint("   ⏰ Time: $totalTime");
  }

  /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
  Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Use provided clock-out time or current device time
    DateTime actualClockOutTime = clockOutTime ?? DateTime.now();

    debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
    debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
    debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");

    // Retrieve shift duration and distance
    String? clockInTimeString = prefs.getString('clockInTime');
    DateTime shiftStartTime = clockInTimeString != null
        ? DateTime.parse(clockInTimeString)
        : actualClockOutTime;

    Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
    String totalTime = _formatDuration(shiftDuration);

    double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);

    // Get attendance ID
    final attendanceId = prefs.getString('attendanceId') ?? '';

    if (attendanceId.isEmpty) {
      debugPrint("⚠️ No matching attendanceId found for Clock Out!");
      await attendanceOutRepository.serialNumberGeneratorApi();
      final newAttendanceId = prefs.getString('attendanceId') ?? '';

      if (newAttendanceId.isEmpty) {
        debugPrint("❌ Failed to generate attendance ID");
        return;
      }
    }

    // ✅ Add auto clock-out note if it's an auto clock-out
    String address = locationViewModel.shopAddress.value;
    if (clockOutTime != null) {
      address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
    }

    // ✅ Save to local database
    addAttendanceOut(
      AttendanceOutModel(
        attendance_out_id: attendanceId,
        user_id: user_id,
        total_distance: totalDistance,
        total_time: totalTime,
        lat_out: locationViewModel.globalLatitude1.value,
        lng_out: locationViewModel.globalLongitude1.value,
        address: address,
      ),
    );

    // ✅ Post to API
    await attendanceOutRepository.postDataFromDatabaseToAPI();

    // ✅ Clear clock-in state
    await attendanceViewModel.clearClockInState();

    debugPrint("✅ Clock-out saved successfully");
  }

  /// ✅ FORMAT DURATION TO H:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// ✅ SIMPLE: Start checking device time for 11:58 PM
  void _startSimpleDeviceTimeCheck() {
    debugPrint("⏰ Starting device time check for 11:58 PM auto clock-out");

    // Check every minute for 11:58 PM
    _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkFor1158PM();
    });
  }

  /// ✅ SIMPLE: Check if it's 11:58 PM device time
  Future<void> _checkFor1158PM() async {
    try {
      // Get current device time
      DateTime now = DateTime.now();

      // Check if it's exactly 11:58 PM
      if (now.hour == 23 && now.minute == 58) {
        debugPrint("⏰ 11:58 PM device time detected!");

        // Get SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Check if user is clocked in
        bool isClockedIn = prefs.getBool('isClockedIn') ?? false;

        if (isClockedIn) {
          debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");

          // Create 11:58 PM timestamp
          DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);

          // Save auto clock-out LOCALLY
          await saveFormAttendanceOutLocalOnly(clockOutTime: clockOutTime);
        } else {
          debugPrint("⏰ User already clocked out at 11:58 PM");
        }
      }

    } catch (e) {
      debugPrint("❌ Error in 11:58 PM check: $e");
    }
  }

  Future<void> fetchAllAttendanceOut() async {
    var attendanceOut = await attendanceOutRepository.getAttendanceOut();
    allAttendanceOut.value = attendanceOut;
  }

  void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
    attendanceOutRepository.add(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
    attendanceOutRepository.update(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  void deleteAttendanceOut(String id) {
    attendanceOutRepository.delete(id);
    fetchAllAttendanceOut();
  }

  Future<void> serialCounterGet() async {
    await attendanceOutRepository.serialNumberGeneratorApi();
  }
}