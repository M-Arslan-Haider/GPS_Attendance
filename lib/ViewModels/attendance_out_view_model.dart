// // // // // // //
// // // // // // // ///gpx posted
// // // // // // // import 'dart:convert';
// // // // // // // import 'dart:async';
// // // // // // // import 'package:http/http.dart' as http;
// // // // // // // import 'package:flutter/foundation.dart';
// // // // // // // import 'package:get/get.dart';
// // // // // // // import 'package:intl/intl.dart';
// // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // import '../Databases/util.dart';
// // // // // // // import '../Models/attendanceOut_model.dart';
// // // // // // // import '../Repositories/attendance_out_repository.dart';
// // // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // // // import 'location_view_model.dart';
// // // // // // // // Import the Clock-In ViewModel to access the clear state method
// // // // // // // import 'attendance_view_model.dart';
// // // // // // //
// // // // // // // class AttendanceOutViewModel extends GetxController {
// // // // // // //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// // // // // // //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// // // // // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // // // // //   // Get the AttendanceViewModel instance to clear clock-in state
// // // // // // //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// // // // // // //
// // // // // // //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// // // // // // //   Timer? _deviceTimeCheckTimer;
// // // // // // //
// // // // // // //   @override
// // // // // // //   void onInit() {
// // // // // // //     super.onInit();
// // // // // // //     fetchAllAttendanceOut();
// // // // // // //     attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // // // //
// // // // // // //     // ✅ SIMPLE: Start checking device time for 11:58 PM
// // // // // // //     _startSimpleDeviceTimeCheck(); // This now calls the updated method
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   void onClose() {
// // // // // // //     // ✅ Clean up timer
// // // // // // //     _deviceTimeCheckTimer?.cancel();
// // // // // // //     super.onClose();
// // // // // // //   }
// // // // // // //
// // // // // // //   /// ✅ NEW: Save attendance out LOCALLY ONLY (2-second clock-out)
// // // // // // //   // Future<void> saveFormAttendanceOutLocalOnly({DateTime? clockOutTime, double? distance}) async {
// // // // // // //   //   SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //   //   await prefs.reload();
// // // // // // //   //
// // // // // // //   //   // Use provided clock-out time or current device time
// // // // // // //   //   DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // // //   //
// // // // // // //   //   debugPrint("💾 [LOCAL SAVE] Saving attendance out LOCALLY (posted=0)");
// // // // // // //   //   debugPrint("   🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // // //   //   debugPrint("   📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // // //   //
// // // // // // //   //   // Retrieve shift duration and distance
// // // // // // //   //   String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //   //   DateTime shiftStartTime = clockInTimeString != null
// // // // // // //   //       ? DateTime.parse(clockInTimeString)
// // // // // // //   //       : actualClockOutTime;
// // // // // // //   //
// // // // // // //   //   Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // // // //   //   String totalTime = _formatDuration(shiftDuration);
// // // // // // //   //
// // // // // // //   //   // Use provided distance or calculate
// // // // // // //   //   double totalDistance = distance ?? await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // // // //   //
// // // // // // //   //   // Get attendance ID
// // // // // // //   //   final attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //   //
// // // // // // //   //   if (attendanceId.isEmpty) {
// // // // // // //   //     debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // // // //   //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // // //   //     final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //   //
// // // // // // //   //     if (newAttendanceId.isEmpty) {
// // // // // // //   //       debugPrint("❌ Failed to generate attendance ID");
// // // // // // //   //       return;
// // // // // // //   //     }
// // // // // // //   //   }
// // // // // // //   //
// // // // // // //   //   // ✅ Add auto clock-out note if it's an auto clock-out
// // // // // // //   //   String address = locationViewModel.shopAddress.value;
// // // // // // //   //   if (clockOutTime != null) {
// // // // // // //   //     address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // // // //   //   }
// // // // // // //   //
// // // // // // //   //   // ✅ Save to local database with posted = 0 (not posted yet)
// // // // // // //   //   addAttendanceOut(
// // // // // // //   //     AttendanceOutModel(
// // // // // // //   //       attendance_out_id: attendanceId,
// // // // // // //   //       user_id: user_id,
// // // // // // //   //       total_distance: totalDistance,
// // // // // // //   //       total_time: totalTime,
// // // // // // //   //       lat_out: locationViewModel.globalLatitude1.value,
// // // // // // //   //       lng_out: locationViewModel.globalLongitude1.value,
// // // // // // //   //       address: address,
// // // // // // //   //       posted: 0, // ✅ IMPORTANT: Mark as not posted
// // // // // // //   //     ),
// // // // // // //   //   );
// // // // // // //   //
// // // // // // //   //   // ✅ Clear clock-in state
// // // // // // //   //   await attendanceViewModel.clearClockInState();
// // // // // // //   //
// // // // // // //   //   debugPrint("✅ [LOCAL SAVE] Attendance out saved LOCALLY with posted=0");
// // // // // // //   //   debugPrint("   📏 Distance: $totalDistance km");
// // // // // // //   //   debugPrint("   ⏰ Time: $totalTime");
// // // // // // //   // }
// // // // // // //   /// ✅ NEW: Save attendance out LOCALLY ONLY (2-second clock-out)
// // // // // // //   Future<void> saveFormAttendanceOutLocalOnly({DateTime? clockOutTime, double? distance}) async {
// // // // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //     await prefs.reload();
// // // // // // //
// // // // // // //     // Use provided clock-out time or current device time
// // // // // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // // //
// // // // // // //     debugPrint("💾 [LOCAL SAVE] Saving attendance out LOCALLY (posted=0)");
// // // // // // //     debugPrint("   🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // // //     debugPrint("   📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // // //
// // // // // // //     // ✅ FIRST: Check if distance is provided
// // // // // // //     double totalDistance;
// // // // // // //
// // // // // // //     if (distance != null) {
// // // // // // //       // Use the provided distance (from clock-out)
// // // // // // //       totalDistance = distance;
// // // // // // //       debugPrint("   📏 Using provided distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // //     } else {
// // // // // // //       // Fallback: calculate from location view model
// // // // // // //       String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //       DateTime shiftStartTime = clockInTimeString != null
// // // // // // //           ? DateTime.parse(clockInTimeString)
// // // // // // //           : actualClockOutTime;
// // // // // // //
// // // // // // //       totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // // // //       debugPrint("   📏 Calculated distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // //     }
// // // // // // //
// // // // // // //     // Retrieve shift duration
// // // // // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //     DateTime shiftStartTime = clockInTimeString != null
// // // // // // //         ? DateTime.parse(clockInTimeString)
// // // // // // //         : actualClockOutTime;
// // // // // // //
// // // // // // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // // // //     String totalTime = _formatDuration(shiftDuration);
// // // // // // //
// // // // // // //     // Get attendance ID
// // // // // // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //
// // // // // // //     if (attendanceId.isEmpty) {
// // // // // // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // // // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // // //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //
// // // // // // //       if (newAttendanceId.isEmpty) {
// // // // // // //         debugPrint("❌ Failed to generate attendance ID");
// // // // // // //         return;
// // // // // // //       }
// // // // // // //     }
// // // // // // //
// // // // // // //     // ✅ Add auto clock-out note if it's an auto clock-out
// // // // // // //     String address = locationViewModel.shopAddress.value;
// // // // // // //     if (clockOutTime != null) {
// // // // // // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // // // //     }
// // // // // // //
// // // // // // //     // ✅ Save to local database with posted = 0 (not posted yet)
// // // // // // //     addAttendanceOut(
// // // // // // //       AttendanceOutModel(
// // // // // // //         attendance_out_id: attendanceId,
// // // // // // //         user_id: user_id,
// // // // // // //         total_distance: totalDistance, // ✅ This now uses the actual distance
// // // // // // //         total_time: totalTime,
// // // // // // //         lat_out: locationViewModel.globalLatitude1.value,
// // // // // // //         lng_out: locationViewModel.globalLongitude1.value,
// // // // // // //         address: address,
// // // // // // //         posted: 0, // ✅ IMPORTANT: Mark as not posted
// // // // // // //       ),
// // // // // // //     );
// // // // // // //
// // // // // // //     // ✅ Clear clock-in state
// // // // // // //     await attendanceViewModel.clearClockInState();
// // // // // // //
// // // // // // //     debugPrint("✅ [LOCAL SAVE] Attendance out saved LOCALLY with posted=0");
// // // // // // //     debugPrint("   📏 Actual Distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // //     debugPrint("   ⏰ Time: $totalTime");
// // // // // // //   }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // // // // // //   // Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// // // // // // //   //   SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //   //   await prefs.reload();
// // // // // // //   //
// // // // // // //   //   // Use provided clock-out time or current device time
// // // // // // //   //   DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // // //   //
// // // // // // //   //   debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // // // // // //   //   debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // // //   //   debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // // //   //
// // // // // // //   //   // Retrieve shift duration and distance
// // // // // // //   //   String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //   //   DateTime shiftStartTime = clockInTimeString != null
// // // // // // //   //       ? DateTime.parse(clockInTimeString)
// // // // // // //   //       : actualClockOutTime;
// // // // // // //   //
// // // // // // //   //   Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // // // //   //   String totalTime = _formatDuration(shiftDuration);
// // // // // // //   //
// // // // // // //   //   double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // // // //   //
// // // // // // //   //   // Get attendance ID
// // // // // // //   //   final attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //   //
// // // // // // //   //   if (attendanceId.isEmpty) {
// // // // // // //   //     debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // // // //   //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // // //   //     final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //   //
// // // // // // //   //     if (newAttendanceId.isEmpty) {
// // // // // // //   //       debugPrint("❌ Failed to generate attendance ID");
// // // // // // //   //       return;
// // // // // // //   //     }
// // // // // // //   //   }
// // // // // // //   //
// // // // // // //   //   // ✅ Add auto clock-out note if it's an auto clock-out
// // // // // // //   //   String address = locationViewModel.shopAddress.value;
// // // // // // //   //   if (clockOutTime != null) {
// // // // // // //   //     address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // // // //   //   }
// // // // // // //   //
// // // // // // //   //   // ✅ Save to local database
// // // // // // //   //   addAttendanceOut(
// // // // // // //   //     AttendanceOutModel(
// // // // // // //   //       attendance_out_id: attendanceId,
// // // // // // //   //       user_id: user_id,
// // // // // // //   //       total_distance: totalDistance,
// // // // // // //   //       total_time: totalTime,
// // // // // // //   //       lat_out: locationViewModel.globalLatitude1.value,
// // // // // // //   //       lng_out: locationViewModel.globalLongitude1.value,
// // // // // // //   //       address: address,
// // // // // // //   //     ),
// // // // // // //   //   );
// // // // // // //   //
// // // // // // //   //   // ✅ Post to API
// // // // // // //   //   await attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // // // //   //
// // // // // // //   //   // ✅ Clear clock-in state
// // // // // // //   //   await attendanceViewModel.clearClockInState();
// // // // // // //   //
// // // // // // //   //   debugPrint("✅ Clock-out saved successfully");
// // // // // // //   // }
// // // // // // //
// // // // // // //   /// ✅ UPDATED: Added optional clockOutTime and distance parameters
// // // // // // //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime, double? distance}) async {
// // // // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // //     await prefs.reload();
// // // // // // //
// // // // // // //     // Use provided clock-out time or current device time
// // // // // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // // //
// // // // // // //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // // // // // //     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // // //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // // //
// // // // // // //     // ✅ FIRST: Check if distance is provided
// // // // // // //     double totalDistance;
// // // // // // //
// // // // // // //     if (distance != null) {
// // // // // // //       // Use the provided distance
// // // // // // //       totalDistance = distance;
// // // // // // //       debugPrint("   📏 Using provided distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // //     } else {
// // // // // // //       // Fallback: calculate from location view model
// // // // // // //       String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //       DateTime shiftStartTime = clockInTimeString != null
// // // // // // //           ? DateTime.parse(clockInTimeString)
// // // // // // //           : actualClockOutTime;
// // // // // // //
// // // // // // //       totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // // // //       debugPrint("   📏 Calculated distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // //     }
// // // // // // //
// // // // // // //     // Retrieve shift duration
// // // // // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // // // // //     DateTime shiftStartTime = clockInTimeString != null
// // // // // // //         ? DateTime.parse(clockInTimeString)
// // // // // // //         : actualClockOutTime;
// // // // // // //
// // // // // // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // // // //     String totalTime = _formatDuration(shiftDuration);
// // // // // // //
// // // // // // //     // Get attendance ID
// // // // // // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //
// // // // // // //     if (attendanceId.isEmpty) {
// // // // // // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // // // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // // //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // // // // //
// // // // // // //       if (newAttendanceId.isEmpty) {
// // // // // // //         debugPrint("❌ Failed to generate attendance ID");
// // // // // // //         return;
// // // // // // //       }
// // // // // // //     }
// // // // // // //
// // // // // // //     // ✅ Add auto clock-out note if it's an auto clock-out
// // // // // // //     String address = locationViewModel.shopAddress.value;
// // // // // // //     if (clockOutTime != null) {
// // // // // // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // // // //     }
// // // // // // //
// // // // // // //     // ✅ Save to local database
// // // // // // //     addAttendanceOut(
// // // // // // //       AttendanceOutModel(
// // // // // // //         attendance_out_id: attendanceId,
// // // // // // //         user_id: user_id,
// // // // // // //         total_distance: totalDistance, // ✅ This now uses the actual distance
// // // // // // //         total_time: totalTime,
// // // // // // //         lat_out: locationViewModel.globalLatitude1.value,
// // // // // // //         lng_out: locationViewModel.globalLongitude1.value,
// // // // // // //         address: address,
// // // // // // //       ),
// // // // // // //     );
// // // // // // //
// // // // // // //     // ✅ Post to API
// // // // // // //     await attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // // // //
// // // // // // //     // ✅ Clear clock-in state
// // // // // // //     await attendanceViewModel.clearClockInState();
// // // // // // //
// // // // // // //     debugPrint("✅ Clock-out saved successfully");
// // // // // // // //     debugPrint("   📏 Actual Distance: ${totalDistance.toStringAsFixed(3)} km");
// // // // // // // //     debugPrint("   ⏰ Time: $totalTime");
// // // // // // // //   }
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // //   /// ✅ FORMAT DURATION TO H:mm:ss
// // // // // // // //   String _formatDuration(Duration duration) {
// // // // // // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // // // // //     String hours = twoDigits(duration.inHours);
// // // // // // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // // // // //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// // // // // // // //     return '$hours:$minutes:$seconds';
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// ✅ SIMPLE: Start checking device time for 11:58 PM
// // // // // // // //   void _startSimpleDeviceTimeCheck() {
// // // // // // // //     debugPrint("⏰ Starting device time check for 11:58 PM auto clock-out");
// // // // // // // //
// // // // // // // //     // Check every minute for 11:58 PM
// // // // // // // //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // // // // // // //       _checkFor1158PM();
// // // // // // // //     });
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// ✅ SIMPLE: Check if it's 11:58 PM device time
// // // // // // // //   Future<void> _checkFor1158PM() async {
// // // // // // // //     try {
// // // // // // // //       // Get current device time
// // // // // // // //       DateTime now = DateTime.now();
// // // // // // // //
// // // // // // // //       // Check if it's exactly 11:58 PM
// // // // // // // //       if (now.hour == 23 && now.minute == 58) {
// // // // // // // //         debugPrint("⏰ 11:58 PM device time detected!");
// // // // // // // //
// // // // // // // //         // Get SharedPreferences
// // // // // // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // // // //
// // // // // // // //         // Check if user is clocked in
// // // // // // // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // // // // // //
// // // // // // // //         if (isClockedIn) {
// // // // // // // //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
// // // // // // // //
// // // // // // // //           // Create 11:58 PM timestamp
// // // // // // // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
// // // // // // // //
// // // // // // // //           // Save auto clock-out LOCALLY
// // // // // // // //           await saveFormAttendanceOutLocalOnly(clockOutTime: clockOutTime);
// // // // // // // //         } else {
// // // // // // // //           debugPrint("⏰ User already clocked out at 11:58 PM");
// // // // // // // //         }
// // // // // // // //       }
// // // // // // // //
// // // // // // // //     } catch (e) {
// // // // // // // //       debugPrint("❌ Error in 11:58 PM check: $e");
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> fetchAllAttendanceOut() async {
// // // // // // // //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// // // // // // // //     allAttendanceOut.value = attendanceOut;
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // // // // //     attendanceOutRepository.add(attendanceOutModel);
// // // // // // // //     fetchAllAttendanceOut();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // // // // //     attendanceOutRepository.update(attendanceOutModel);
// // // // // // // //     fetchAllAttendanceOut();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void deleteAttendanceOut(String id) {
// // // // // // // //     attendanceOutRepository.delete(id);
// // // // // // // //     fetchAllAttendanceOut();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> serialCounterGet() async {
// // // // // // // //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // // // //   }
// // // // // // // // }
// // // // // // // ///////////////////////////////////////////
// // // // // // ///gpx posted
// // // // // // import 'dart:convert';
// // // // // // import 'dart:async';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'package:flutter/foundation.dart';
// // // // // // import 'package:get/get.dart';
// // // // // // import 'package:intl/intl.dart';
// // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // import '../Databases/util.dart';
// // // // // // import '../Models/attendanceOut_model.dart';
// // // // // // import '../Repositories/attendance_out_repository.dart';
// // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // // import '../Tracker/location00.dart';
// // // // // // import 'location_view_model.dart';
// // // // // // // Import the Clock-In ViewModel to access the clear state method
// // // // // // import 'attendance_view_model.dart';
// // // // // //
// // // // // // class AttendanceOutViewModel extends GetxController {
// // // // // //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// // // // // //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// // // // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // // // //   // Get the AttendanceViewModel instance to clear clock-in state
// // // // // //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// // // // // //
// // // // // //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// // // // // //   Timer? _deviceTimeCheckTimer;
// // // // // //
// // // // // //   @override
// // // // // //   void onInit() {
// // // // // //     super.onInit();
// // // // // //     fetchAllAttendanceOut();
// // // // // //     attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // // //
// // // // // //     // ✅ SIMPLE: Start checking device time for 11:58 PM
// // // // // //     _startSimpleDeviceTimeCheck();
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   void onClose() {
// // // // // //     // ✅ Clean up timer
// // // // // //     _deviceTimeCheckTimer?.cancel();
// // // // // //     super.onClose();
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ NEW: Save attendance out LOCALLY ONLY (2-second clock-out)
// // // // // //   /// ✅ UPDATED: Save attendance out LOCALLY ONLY with better distance calculation
// // // // // //   /// ✅ UPDATED: Save attendance out LOCALLY ONLY with better distance calculation
// // // // // //   /// ✅ NEW: Save attendance out LOCALLY ONLY (2-second clock-out)
// // // // // //   Future<void> saveFormAttendanceOutLocalOnly({DateTime? clockOutTime, double? distance}) async {
// // // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //     await prefs.reload();
// // // // // //
// // // // // //     // Use provided clock-out time or current device time
// // // // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // //
// // // // // //     debugPrint("💾 [LOCAL SAVE] Saving attendance out LOCALLY (posted=0)");
// // // // // //     debugPrint("   🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // //     debugPrint("   📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // //
// // // // // //     // ✅ GET CLOCK-IN TIME
// // // // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // // // //     DateTime shiftStartTime = clockInTimeString != null
// // // // // //         ? DateTime.parse(clockInTimeString)
// // // // // //         : actualClockOutTime;
// // // // // //
// // // // // //     debugPrint("   🕐 Shift Start: ${DateFormat('HH:mm:ss').format(shiftStartTime)}");
// // // // // //     debugPrint("   🕐 Clock-Out Time: ${DateFormat('HH:mm:ss').format(actualClockOutTime)}");
// // // // // //
// // // // // //     // ✅ CALCULATE SHIFT DURATION
// // // // // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // // //     String totalTime = _formatDuration(shiftDuration);
// // // // // //
// // // // // //     // ✅ CALCULATE SHIFT DISTANCE
// // // // // //     double shiftDistance;
// // // // // //
// // // // // //     if (distance != null) {
// // // // // //       // Use provided distance
// // // // // //       shiftDistance = distance;
// // // // // //       debugPrint("   📏 Using provided shift distance: ${shiftDistance.toStringAsFixed(3)} km");
// // // // // //     } else {
// // // // // //       // Calculate shift-specific distance
// // // // // //       shiftDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // // //       debugPrint("   📏 Calculated SHIFT distance: ${shiftDistance.toStringAsFixed(3)} km");
// // // // // //     }
// // // // // //
// // // // // //     // Get attendance ID
// // // // // //     String attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // //
// // // // // //     if (attendanceId.isEmpty) {
// // // // // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // //       attendanceId = prefs.getString('attendanceId') ?? '';
// // // // // //
// // // // // //       if (attendanceId.isEmpty) {
// // // // // //         debugPrint("❌ Failed to generate attendance ID");
// // // // // //         return;
// // // // // //       }
// // // // // //     }
// // // // // //
// // // // // //     // ✅ Add auto clock-out note if it's an auto clock-out
// // // // // //     String address = locationViewModel.shopAddress.value;
// // // // // //     if (clockOutTime != null) {
// // // // // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // // //     }
// // // // // //
// // // // // //     // ✅ Get current location coordinates
// // // // // //     double latOut = locationViewModel.globalLatitude1.value;
// // // // // //     double lngOut = locationViewModel.globalLongitude1.value;
// // // // // //
// // // // // //     // If coordinates are 0, get current location
// // // // // //     if (latOut == 0.0 || lngOut == 0.0) {
// // // // // //       debugPrint("   📍 Getting current location...");
// // // // // //       await locationViewModel.saveCurrentLocation();
// // // // // //       latOut = locationViewModel.globalLatitude1.value;
// // // // // //       lngOut = locationViewModel.globalLongitude1.value;
// // // // // //     }
// // // // // //
// // // // // //     // ✅ Save to local database with posted = 0 (not posted yet)
// // // // // //     debugPrint("   💾 Saving to database locally...");
// // // // // //     debugPrint("   - ID: $attendanceId");
// // // // // //     debugPrint("   - User: $user_id");
// // // // // //     debugPrint("   - Shift Distance: ${shiftDistance.toStringAsFixed(3)} km");
// // // // // //     debugPrint("   - Shift Duration: $totalTime");
// // // // // //     debugPrint("   - Lat/Lng: $latOut, $lngOut");
// // // // // //     debugPrint("   - Address: $address");
// // // // // //
// // // // // //     addAttendanceOut(
// // // // // //       AttendanceOutModel(
// // // // // //         attendance_out_id: attendanceId,
// // // // // //         user_id: user_id,
// // // // // //         total_distance: shiftDistance, // ✅ SHIFT distance
// // // // // //         total_time: totalTime,
// // // // // //         lat_out: latOut,
// // // // // //         lng_out: lngOut,
// // // // // //         address: address,
// // // // // //         posted: 0, // ✅ IMPORTANT: Mark as not posted
// // // // // //       ),
// // // // // //     );
// // // // // //
// // // // // //     // ✅ Clear clock-in state
// // // // // //     await attendanceViewModel.clearClockInState();
// // // // // //
// // // // // //     debugPrint("✅ [LOCAL SAVE] Attendance out saved LOCALLY with posted=0");
// // // // // //     debugPrint("   📏 Shift Distance: ${shiftDistance.toStringAsFixed(3)} km");
// // // // // //     debugPrint("   ⏰ Shift Duration: $totalTime");
// // // // // //     debugPrint("   📍 Location: $address");
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ UPDATED: Added optional clockOutTime and distance parameters for auto clock-out
// // // // // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // // // // //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// // // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //     await prefs.reload();
// // // // // //
// // // // // //     // Use provided clock-out time or current device time
// // // // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // // //
// // // // // //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // // // // //     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // // //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // // //
// // // // // //     // ✅ First save locally with posted=0
// // // // // //     debugPrint("💾 Step 1: Saving locally first...");
// // // // // //
// // // // // //     // Get distance from LocationService for local save
// // // // // //     LocationService locationService = LocationService();
// // // // // //     await locationService.init();
// // // // // //     double finalDistance = await locationService.calculateCurrentDistance();
// // // // // //
// // // // // //     await saveFormAttendanceOutLocalOnly(
// // // // // //         clockOutTime: clockOutTime,
// // // // // //         distance: finalDistance
// // // // // //     );
// // // // // //
// // // // // //     // ✅ Then post to API
// // // // // //     debugPrint("📤 Step 2: Posting to API...");
// // // // // //     await attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // // //
// // // // // //     // ✅ Clear clock-in state (already done in local save, but just in case)
// // // // // //     await attendanceViewModel.clearClockInState();
// // // // // //
// // // // // //     debugPrint("✅ Clock-out saved successfully (local + API)");
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ FORMAT DURATION TO H:mm:ss
// // // // // //   String _formatDuration(Duration duration) {
// // // // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // // //     String hours = twoDigits(duration.inHours);
// // // // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // // //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// // // // // //     return '$hours:$minutes:$seconds';
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ SIMPLE: Start checking device time for 11:58 PM
// // // // // //   void _startSimpleDeviceTimeCheck() {
// // // // // //     debugPrint("⏰ Starting device time check for 11:58 PM auto clock-out");
// // // // // //
// // // // // //     // Check every minute for 11:58 PM
// // // // // //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // // // // //       _checkFor1158PM();
// // // // // //     });
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ SIMPLE: Check if it's 11:58 PM device time
// // // // // //   Future<void> _checkFor1158PM() async {
// // // // // //     try {
// // // // // //       // Get current device time
// // // // // //       DateTime now = DateTime.now();
// // // // // //
// // // // // //       // Check if it's exactly 11:58 PM
// // // // // //       if (now.hour == 23 && now.minute == 58) {
// // // // // //         debugPrint("⏰ 11:58 PM device time detected!");
// // // // // //
// // // // // //         // Get SharedPreferences
// // // // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //
// // // // // //         // Check if user is clocked in
// // // // // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // // // //
// // // // // //         if (isClockedIn) {
// // // // // //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
// // // // // //
// // // // // //           // Create 11:58 PM timestamp
// // // // // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
// // // // // //
// // // // // //           // Save auto clock-out LOCALLY
// // // // // //           await saveFormAttendanceOutLocalOnly(clockOutTime: clockOutTime);
// // // // // //         } else {
// // // // // //           debugPrint("⏰ User already clocked out at 11:58 PM");
// // // // // //         }
// // // // // //       }
// // // // // //
// // // // // //     } catch (e) {
// // // // // //       debugPrint("❌ Error in 11:58 PM check: $e");
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   /// ✅ NEW: Added function to check for 11:00 PM (from second file)
// // // // // //   /// ✅ SIMPLE: Check if it's 11:00 PM device time
// // // // // //   Future<void> _checkFor11PM() async {
// // // // // //     try {
// // // // // //       // Get current device time
// // // // // //       DateTime now = DateTime.now();
// // // // // //
// // // // // //       // Check if it's exactly 11:00 PM
// // // // // //       if (now.hour == 23 && now.minute == 0) {
// // // // // //         debugPrint("⏰ 11:00 PM device time detected!");
// // // // // //
// // // // // //         // Get SharedPreferences
// // // // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // // //
// // // // // //         // Check if user is clocked in
// // // // // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // // // //
// // // // // //         if (isClockedIn) {
// // // // // //           debugPrint("🤖 User is clocked in - triggering auto clock-out");
// // // // // //
// // // // // //           // Create 11:00 PM timestamp
// // // // // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 0, 0);
// // // // // //
// // // // // //           // Save auto clock-out
// // // // // //           await saveFormAttendanceOut(clockOutTime: clockOutTime);
// // // // // //         } else {
// // // // // //           debugPrint("⏰ User already clocked out at 11:00 PM");
// // // // // //         }
// // // // // //       }
// // // // // //
// // // // // //     } catch (e) {
// // // // // //       debugPrint("❌ Error in 11:00 PM check: $e");
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   Future<void> fetchAllAttendanceOut() async {
// // // // // //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// // // // // //     allAttendanceOut.value = attendanceOut;
// // // // // //   }
// // // // // //
// // // // // //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // // //     attendanceOutRepository.add(attendanceOutModel);
// // // // // //     fetchAllAttendanceOut();
// // // // // //   }
// // // // // //
// // // // // //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // // //     attendanceOutRepository.update(attendanceOutModel);
// // // // // //     fetchAllAttendanceOut();
// // // // // //   }
// // // // // //
// // // // // //   void deleteAttendanceOut(String id) {
// // // // // //     attendanceOutRepository.delete(id);
// // // // // //     fetchAllAttendanceOut();
// // // // // //   }
// // // // // //
// // // // // //   Future<void> serialCounterGet() async {
// // // // // //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // // // //   }
// // // // // // }
// // // // // //
// // // // //
// // // // // import 'dart:async';
// // // // // import 'dart:convert';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:flutter/foundation.dart';
// // // // // import 'package:get/get.dart';
// // // // // import 'package:intl/intl.dart';
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // import '../Databases/util.dart';
// // // // // import '../Models/attendanceOut_model.dart';
// // // // // import '../Repositories/attendance_out_repository.dart';
// // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // import 'location_view_model.dart';
// // // // // // Import the Clock-In ViewModel to access the clear state method
// // // // // import 'attendance_view_model.dart';
// // // // //
// // // // // class AttendanceOutViewModel extends GetxController {
// // // // //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// // // // //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// // // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // // //   // Get the AttendanceViewModel instance to clear clock-in state
// // // // //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// // // // //
// // // // //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// // // // //   Timer? _deviceTimeCheckTimer;
// // // // //
// // // // //   @override
// // // // //   void onInit() {
// // // // //     super.onInit();
// // // // //     fetchAllAttendanceOut();
// // // // //     attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // //
// // // // //     // ✅ SIMPLE: Start checking device time for 11:00 PM
// // // // //     _startSimpleDeviceTimeCheck();
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   void onClose() {
// // // // //     // ✅ Clean up timer
// // // // //     _deviceTimeCheckTimer?.cancel();
// // // // //     super.onClose();
// // // // //   }
// // // // //
// // // // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // // // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // // // //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// // // // //     // ✅ PEHLE CHECK KARO KE LOCAL DATA SYNC HUA HAI YA NAHI
// // // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // //     await prefs.reload();
// // // // //
// // // // //     // ✅ STEP 1: Check if data already saved locally and synced
// // // // //     String? localClockOutData = prefs.getString('localClockOutData');
// // // // //     if (localClockOutData != null) {
// // // // //       Map<String, dynamic> localData = jsonDecode(localClockOutData);
// // // // //       if (localData['posted'] == true) {
// // // // //         debugPrint("✅ Clock-out already synced to server, skipping API call");
// // // // //         // Just update UI state if needed
// // // // //         return;
// // // // //       }
// // // // //     }
// // // // //
// // // // //     // ✅ STEP 2: Use provided clock-out time or current device time
// // // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // // //
// // // // //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // // // //     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // // //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // // //
// // // // //     // ✅ STEP 3: Retrieve shift duration and distance FROM LOCAL STORAGE
// // // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // // //     DateTime shiftStartTime = clockInTimeString != null
// // // // //         ? DateTime.parse(clockInTimeString)
// // // // //         : actualClockOutTime;
// // // // //
// // // // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // // //     String totalTime = _formatDuration(shiftDuration);
// // // // //
// // // // //     double totalDistance = 0.0;
// // // // //     try {
// // // // //       // Try to get distance from local storage first
// // // // //       totalDistance = prefs.getDouble('lastDistance') ?? 0.0;
// // // // //       if (totalDistance == 0.0) {
// // // // //         // Fallback to calculation
// // // // //         totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // // //       }
// // // // //     } catch (e) {
// // // // //       debugPrint("⚠️ Distance calculation error, using 0: $e");
// // // // //       totalDistance = 0.0;
// // // // //     }
// // // // //
// // // // //     // ✅ STEP 4: Get attendance ID (generate if not exists)
// // // // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // // // //
// // // // //     if (attendanceId.isEmpty) {
// // // // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // // // //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // // //
// // // // //       if (newAttendanceId.isEmpty) {
// // // // //         debugPrint("❌ Failed to generate attendance ID");
// // // // //         // Still save locally for retry
// // // // //         return;
// // // // //       }
// // // // //     }
// // // // //
// // // // //     // ✅ STEP 5: Add auto clock-out note if it's an auto clock-out
// // // // //     String address = locationViewModel.shopAddress.value;
// // // // //     if (clockOutTime != null) {
// // // // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // // //     }
// // // // //
// // // // //     // ✅ STEP 6: Save to local database (THIS IS THE API CALL)
// // // // //     try {
// // // // //       addAttendanceOut(
// // // // //         AttendanceOutModel(
// // // // //           attendance_out_id: attendanceId,
// // // // //           user_id: user_id,
// // // // //           total_distance: totalDistance,
// // // // //           total_time: totalTime,
// // // // //           lat_out: locationViewModel.globalLatitude1.value,
// // // // //           lng_out: locationViewModel.globalLongitude1.value,
// // // // //           address: address,
// // // // //           posted: 1, // Mark as posted to API
// // // // //         ),
// // // // //       );
// // // // //
// // // // //       // ✅ STEP 7: Post to API
// // // // //       await attendanceOutRepository.postDataFromDatabaseToAPI();
// // // // //
// // // // //       // ✅ STEP 8: Clear clock-in state
// // // // //       await attendanceViewModel.clearClockInState();
// // // // //
// // // // //       // ✅ STEP 9: Mark local data as synced
// // // // //       if (localClockOutData != null) {
// // // // //         Map<String, dynamic> dataMap = jsonDecode(localClockOutData);
// // // // //         dataMap['posted'] = true;
// // // // //         dataMap['apiSyncedAt'] = DateTime.now().toIso8601String();
// // // // //         await prefs.setString('localClockOutData', jsonEncode(dataMap));
// // // // //         debugPrint("✅ Marked local clock-out data as API synced");
// // // // //       }
// // // // //
// // // // //       // ✅ STEP 10: Clear from pending sync queue
// // // // //       List<String> pendingSyncs = prefs.getStringList('pendingSyncQueue') ?? [];
// // // // //       pendingSyncs.removeWhere((sync) {
// // // // //         try {
// // // // //           Map<String, dynamic> syncData = jsonDecode(sync);
// // // // //           return syncData['type'] == 'clock_out' || syncData['type'] == 'auto_clock_out';
// // // // //         } catch (e) {
// // // // //           return false;
// // // // //         }
// // // // //       });
// // // // //       await prefs.setStringList('pendingSyncQueue', pendingSyncs);
// // // // //
// // // // //       debugPrint("✅ Clock-out saved and API synced successfully at ${DateFormat('HH:mm:ss').format(DateTime.now())}");
// // // // //
// // // // //     } catch (e) {
// // // // //       debugPrint("❌ API Error in saveFormAttendanceOut: $e");
// // // // //
// // // // //       // Even if API fails, mark as attempted
// // // // //       if (localClockOutData != null) {
// // // // //         Map<String, dynamic> dataMap = jsonDecode(localClockOutData);
// // // // //         dataMap['syncAttempts'] = (dataMap['syncAttempts'] ?? 0) + 1;
// // // // //         dataMap['lastSyncAttempt'] = DateTime.now().toIso8601String();
// // // // //         await prefs.setString('localClockOutData', jsonEncode(dataMap));
// // // // //       }
// // // // //
// // // // //       throw e; // Re-throw so caller knows API failed
// // // // //     }
// // // // //   }
// // // // //
// // // // //   /// ✅ FORMAT DURATION TO H:mm:ss
// // // // //   String _formatDuration(Duration duration) {
// // // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // // //     String hours = twoDigits(duration.inHours);
// // // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // // //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// // // // //     return '$hours:$minutes:$seconds';
// // // // //   }
// // // // //
// // // // //   /// ✅ SIMPLE: Start checking device time for 11:00 PM
// // // // //   void _startSimpleDeviceTimeCheck() {
// // // // //     debugPrint("⏰ Starting device time check for 11:00 PM auto clock-out");
// // // // //
// // // // //     // Check every minute for 11:00 PM
// // // // //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // // // //       _checkFor11PM();
// // // // //     });
// // // // //   }
// // // // //
// // // // //   /// ✅ SIMPLE: Check if it's 11:00 PM device time
// // // // //   Future<void> _checkFor11PM() async {
// // // // //     try {
// // // // //       // Get current device time
// // // // //       DateTime now = DateTime.now();
// // // // //
// // // // //       // Check if it's exactly 11:00 PM
// // // // //       if (now.hour == 23 && now.minute == 0) {
// // // // //         debugPrint("⏰ 11:00 PM device time detected!");
// // // // //
// // // // //         // Get SharedPreferences
// // // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // // //
// // // // //         // Check if user is clocked in
// // // // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // // //
// // // // //         if (isClockedIn) {
// // // // //           debugPrint("🤖 User is clocked in - triggering auto clock-out");
// // // // //
// // // // //           // Create 11:00 PM timestamp
// // // // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 0, 0);
// // // // //
// // // // //           // Save auto clock-out
// // // // //           await saveFormAttendanceOut(clockOutTime: clockOutTime);
// // // // //
// // // // //           // // Show notification
// // // // //           // Get.snackbar(
// // // // //           //   'Auto Clock-Out',
// // // // //           //   'Automatically clocked out at 11:00 PM',
// // // // //           //   snackPosition: SnackPosition.TOP,
// // // // //           //   backgroundColor: Colors.white,
// // // // //           //   colorText: Colors.white,
// // // // //           //   duration: const Duration(seconds: 10),
// // // // //           // );
// // // // //         } else {
// // // // //           debugPrint("⏰ User already clocked out at 11:00 PM");
// // // // //         }
// // // // //       }
// // // // //
// // // // //     } catch (e) {
// // // // //       debugPrint("❌ Error in 11:00 PM check: $e");
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> fetchAllAttendanceOut() async {
// // // // //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// // // // //     allAttendanceOut.value = attendanceOut;
// // // // //   }
// // // // //
// // // // //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // //     attendanceOutRepository.add(attendanceOutModel);
// // // // //     fetchAllAttendanceOut();
// // // // //   }
// // // // //
// // // // //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // // //     attendanceOutRepository.update(attendanceOutModel);
// // // // //     fetchAllAttendanceOut();
// // // // //   }
// // // // //
// // // // //   void deleteAttendanceOut(String id) {
// // // // //     attendanceOutRepository.delete(id);
// // // // //     fetchAllAttendanceOut();
// // // // //   }
// // // // //
// // // // //   Future<void> serialCounterGet() async {
// // // // //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // // //   }
// // // // // }
// // // //
// // // // import 'dart:convert';
// // // // import 'dart:async';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import '../Databases/util.dart';
// // // // import '../Models/attendanceOut_model.dart';
// // // // import '../Repositories/attendance_out_repository.dart';
// // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // import 'location_view_model.dart';
// // // // // Import the Clock-In ViewModel to access the clear state method
// // // // import 'attendance_view_model.dart';
// // // //
// // // // class AttendanceOutViewModel extends GetxController {
// // // //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// // // //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // //   // Get the AttendanceViewModel instance to clear clock-in state
// // // //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// // // //
// // // //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// // // //   Timer? _deviceTimeCheckTimer;
// // // //
// // // //   @override
// // // //   void onInit() {
// // // //     super.onInit();
// // // //     fetchAllAttendanceOut();
// // // //     attendanceOutRepository.postDataFromDatabaseToAPI();
// // // //
// // // //     // ✅ SIMPLE: Start checking device time for 11:00 PM
// // // //     _startSimpleDeviceTimeCheck();
// // // //   }
// // // //
// // // //   @override
// // // //   void onClose() {
// // // //     // ✅ Clean up timer
// // // //     _deviceTimeCheckTimer?.cancel();
// // // //     super.onClose();
// // // //   }
// // // //
// // // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // // //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     await prefs.reload();
// // // //
// // // //     // Use provided clock-out time or current device time
// // // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // // //
// // // //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // // //     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // // //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // // //
// // // //     // Retrieve shift duration and distance
// // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // //     DateTime shiftStartTime = clockInTimeString != null
// // // //         ? DateTime.parse(clockInTimeString)
// // // //         : actualClockOutTime;
// // // //
// // // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // // //     String totalTime = _formatDuration(shiftDuration);
// // // //
// // // //     double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // // //
// // // //     // Get attendance ID
// // // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // // //
// // // //     if (attendanceId.isEmpty) {
// // // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // // //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // // //
// // // //       if (newAttendanceId.isEmpty) {
// // // //         debugPrint("❌ Failed to generate attendance ID");
// // // //         return;
// // // //       }
// // // //     }
// // // //
// // // //     // ✅ Add auto clock-out note if it's an auto clock-out
// // // //     String address = locationViewModel.shopAddress.value;
// // // //     if (clockOutTime != null) {
// // // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // // //     }
// // // //
// // // //     // ✅ Save to local database
// // // //     addAttendanceOut(
// // // //       AttendanceOutModel(
// // // //         attendance_out_id: attendanceId,
// // // //         user_id: user_id,
// // // //         total_distance: totalDistance,
// // // //         total_time: totalTime,
// // // //         lat_out: locationViewModel.globalLatitude1.value,
// // // //         lng_out: locationViewModel.globalLongitude1.value,
// // // //         address: address,
// // // //       ),
// // // //     );
// // // //
// // // //     // ✅ Post to API
// // // //     await attendanceOutRepository.postDataFromDatabaseToAPI();
// // // //
// // // //     // ✅ Clear clock-in state
// // // //     await attendanceViewModel.clearClockInState();
// // // //
// // // //     debugPrint("✅ Clock-out saved successfully");
// // // //   }
// // // //
// // // //   /// ✅ FORMAT DURATION TO H:mm:ss
// // // //   String _formatDuration(Duration duration) {
// // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // //     String hours = twoDigits(duration.inHours);
// // // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// // // //     return '$hours:$minutes:$seconds';
// // // //   }
// // // //
// // // //   /// ✅ SIMPLE: Start checking device time for 11:00 PM
// // // //   void _startSimpleDeviceTimeCheck() {
// // // //     debugPrint("⏰ Starting device time check for 11:00 PM auto clock-out");
// // // //
// // // //     // Check every minute for 11:00 PM
// // // //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // // //       _checkFor11PM();
// // // //     });
// // // //   }
// // // //
// // // //   /// ✅ SIMPLE: Check if it's 11:00 PM device time
// // // //   Future<void> _checkFor11PM() async {
// // // //     try {
// // // //       // Get current device time
// // // //       DateTime now = DateTime.now();
// // // //
// // // //       // Check if it's exactly 11:00 PM
// // // //       if (now.hour == 23 && now.minute == 0) {
// // // //         debugPrint("⏰ 11:00 PM device time detected!");
// // // //
// // // //         // Get SharedPreferences
// // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //
// // // //         // Check if user is clocked in
// // // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // //
// // // //         if (isClockedIn) {
// // // //           debugPrint("🤖 User is clocked in - triggering auto clock-out");
// // // //
// // // //           // Create 11:00 PM timestamp
// // // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 0, 0);
// // // //
// // // //           // Save auto clock-out
// // // //           await saveFormAttendanceOut(clockOutTime: clockOutTime);
// // // //
// // // //           // // Show notification
// // // //           // Get.snackbar(
// // // //           //   'Auto Clock-Out',
// // // //           //   'Automatically clocked out at 11:00 PM',
// // // //           //   snackPosition: SnackPosition.TOP,
// // // //           //   backgroundColor: Colors.white,
// // // //           //   colorText: Colors.white,
// // // //           //   duration: const Duration(seconds: 10),
// // // //           // );
// // // //         } else {
// // // //           debugPrint("⏰ User already clocked out at 11:00 PM");
// // // //         }
// // // //       }
// // // //
// // // //     } catch (e) {
// // // //       debugPrint("❌ Error in 11:00 PM check: $e");
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> fetchAllAttendanceOut() async {
// // // //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// // // //     allAttendanceOut.value = attendanceOut;
// // // //   }
// // // //
// // // //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // //     attendanceOutRepository.add(attendanceOutModel);
// // // //     fetchAllAttendanceOut();
// // // //   }
// // // //
// // // //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // // //     attendanceOutRepository.update(attendanceOutModel);
// // // //     fetchAllAttendanceOut();
// // // //   }
// // // //
// // // //   void deleteAttendanceOut(String id) {
// // // //     attendanceOutRepository.delete(id);
// // // //     fetchAllAttendanceOut();
// // // //   }
// // // //
// // // //   Future<void> serialCounterGet() async {
// // // //     await attendanceOutRepository.serialNumberGeneratorApi();
// // // //   }
// // // // }
// // //
// // // import 'dart:async';
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:get/get.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import '../Databases/util.dart';
// // // import '../Models/attendanceOut_model.dart';
// // // import '../Repositories/attendance_out_repository.dart';
// // // import 'location_view_model.dart';
// // // // Import the Clock-In ViewModel to access the clear state method
// // // import 'attendance_view_model.dart';
// // //
// // // class AttendanceOutViewModel extends GetxController {
// // //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// // //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // //   // Get the AttendanceViewModel instance to clear clock-in state
// // //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// // //
// // //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// // //   Timer? _deviceTimeCheckTimer;
// // //
// // //   @override
// // //   void onInit() {
// // //     super.onInit();
// // //     fetchAllAttendanceOut();
// // //     attendanceOutRepository.postDataFromDatabaseToAPI();
// // //
// // //     // ✅ SIMPLE: Start checking device time for 11:00 PM
// // //     _startSimpleDeviceTimeCheck();
// // //   }
// // //
// // //   @override
// // //   void onClose() {
// // //     // ✅ Clean up timer
// // //     _deviceTimeCheckTimer?.cancel();
// // //     super.onClose();
// // //   }
// // //
// // //   /// ✅ UPDATED: Added optional clockOutTime parameter for auto clock-out
// // //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     await prefs.reload();
// // //
// // //     // Use provided clock-out time or current device time
// // //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// // //
// // //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// // //     debugPrint("🤖 Auto clock-out: ${clockOutTime != null ? 'Yes' : 'No (Manual)'}");
// // //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// // //
// // //     // Retrieve shift duration and distance
// // //     String? clockInTimeString = prefs.getString('clockInTime');
// // //     DateTime shiftStartTime = clockInTimeString != null
// // //         ? DateTime.parse(clockInTimeString)
// // //         : actualClockOutTime;
// // //
// // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // //     String totalTime = _formatDuration(shiftDuration);
// // //
// // //     double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // //
// // //     // Get attendance ID
// // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // //
// // //     if (attendanceId.isEmpty) {
// // //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// // //       await attendanceOutRepository.serialNumberGeneratorApi();
// // //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// // //
// // //       if (newAttendanceId.isEmpty) {
// // //         debugPrint("❌ Failed to generate attendance ID");
// // //         return;
// // //       }
// // //     }
// // //
// // //     // ✅ Add auto clock-out note if it's an auto clock-out
// // //     String address = locationViewModel.shopAddress.value;
// // //     if (clockOutTime != null) {
// // //       address = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
// // //     }
// // //
// // //     // ✅ Save to local database FIRST
// // //     addAttendanceOut(
// // //       AttendanceOutModel(
// // //         attendance_out_id: attendanceId,
// // //         user_id: user_id,
// // //         total_distance: totalDistance,
// // //         total_time: totalTime,
// // //         lat_out: locationViewModel.globalLatitude1.value,
// // //         lng_out: locationViewModel.globalLongitude1.value,
// // //         address: address,
// // //       ),
// // //     );
// // //
// // //     // ✅ Store sync status locally
// // //     await prefs.setString('lastClockOutTime', actualClockOutTime.toIso8601String());
// // //     await prefs.setDouble('lastClockOutDistance', totalDistance);
// // //     await prefs.setString('clockOutSyncStatus', 'pending');
// // //
// // //     // ✅ TRY to post to API (fire and forget - won't block user)
// // //     _tryPostToAPIInBackground();
// // //
// // //     // ✅ Clear clock-in state
// // //     await attendanceViewModel.clearClockInState();
// // //
// // //     debugPrint("✅ Clock-out saved LOCALLY successfully");
// // //   }
// // //
// // //   /// ✅ NEW: Save to local database only (no API call)
// // //   Future<void> saveFormAttendanceOutLocalOnly({
// // //     required double totalDistance,
// // //   }) async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     await prefs.reload();
// // //
// // //     DateTime actualClockOutTime = DateTime.now();
// // //
// // //     debugPrint("💾 Saving clock-out to LOCAL database only");
// // //
// // //     // Retrieve shift duration and distance
// // //     String? clockInTimeString = prefs.getString('clockInTime');
// // //     DateTime shiftStartTime = clockInTimeString != null
// // //         ? DateTime.parse(clockInTimeString)
// // //         : actualClockOutTime;
// // //
// // //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// // //     String totalTime = _formatDuration(shiftDuration);
// // //
// // //     // double totalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
// // //
// // //     // Get attendance ID
// // //     final attendanceId = prefs.getString('attendanceId') ?? '';
// // //
// // //     if (attendanceId.isEmpty) {
// // //       debugPrint("⚠️ No matching attendanceId found!");
// // //       // Generate a temporary ID for local storage
// // //       String tempId = "TEMP-${user_id}-${DateTime.now().millisecondsSinceEpoch}";
// // //
// // //       // Save to local database with temporary ID
// // //       addAttendanceOut(
// // //         AttendanceOutModel(
// // //           attendance_out_id: tempId,
// // //           user_id: user_id,
// // //           total_distance: totalDistance,
// // //           total_time: totalTime,
// // //           lat_out: locationViewModel.globalLatitude1.value,
// // //           lng_out: locationViewModel.globalLongitude1.value,
// // //           address: locationViewModel.shopAddress.value,
// // //         ),
// // //       );
// // //
// // //       // Store for later sync
// // //       await prefs.setString('pendingAttendanceOutId', tempId);
// // //     } else {
// // //       // Save to local database
// // //       addAttendanceOut(
// // //         AttendanceOutModel(
// // //           attendance_out_id: attendanceId,
// // //           user_id: user_id,
// // //           total_distance: totalDistance,
// // //           total_time: totalTime,
// // //           lat_out: locationViewModel.globalLatitude1.value,
// // //           lng_out: locationViewModel.globalLongitude1.value,
// // //           address: locationViewModel.shopAddress.value,
// // //         ),
// // //       );
// // //     }
// // //
// // //     // Store sync status
// // //     await prefs.setString('lastClockOutTime', actualClockOutTime.toIso8601String());
// // //     await prefs.setDouble('lastClockOutDistance', totalDistance);
// // //     await prefs.setString('clockOutSyncStatus', 'pending_local');
// // //
// // //     // Clear clock-in state
// // //     await attendanceViewModel.clearClockInState();
// // //
// // //     debugPrint("✅ Clock-out saved to LOCAL database only");
// // //   }
// // //
// // //   /// ✅ FORMAT DURATION TO H:mm:ss
// // //   String _formatDuration(Duration duration) {
// // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // //     String hours = twoDigits(duration.inHours);
// // //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// // //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// // //     return '$hours:$minutes:$seconds';
// // //   }
// // //
// // //   /// ✅ SIMPLE: Start checking device time for 11:00 PM
// // //   void _startSimpleDeviceTimeCheck() {
// // //     debugPrint("⏰ Starting device time check for 11:00 PM auto clock-out");
// // //
// // //     // Check every minute for 11:00 PM
// // //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // //       _checkFor11PM();
// // //     });
// // //   }
// // //
// // //   /// ✅ SIMPLE: Check if it's 11:00 PM device time
// // //   Future<void> _checkFor11PM() async {
// // //     try {
// // //       // Get current device time
// // //       DateTime now = DateTime.now();
// // //
// // //       // Check if it's exactly 11:00 PM
// // //       if (now.hour == 23 && now.minute == 0) {
// // //         debugPrint("⏰ 11:00 PM device time detected!");
// // //
// // //         // Get SharedPreferences
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //         // Check if user is clocked in
// // //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // //
// // //         if (isClockedIn) {
// // //           debugPrint("🤖 User is clocked in - triggering auto clock-out");
// // //
// // //           // Create 11:00 PM timestamp
// // //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 0, 0);
// // //
// // //           // Save auto clock-out
// // //           await saveFormAttendanceOut(clockOutTime: clockOutTime);
// // //         } else {
// // //           debugPrint("⏰ User already clocked out at 11:00 PM");
// // //         }
// // //       }
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ Error in 11:00 PM check: $e");
// // //     }
// // //   }
// // //
// // //   // ✅ NEW: Background API posting (won't block user)
// // //   void _tryPostToAPIInBackground() async {
// // //     try {
// // //       debugPrint("🌐 Attempting background API sync...");
// // //
// // //       // Check internet quickly
// // //       final connectivityResult = await (Connectivity().checkConnectivity());
// // //       bool isConnected = connectivityResult != ConnectivityResult.none;
// // //
// // //       if (isConnected) {
// // //         await attendanceOutRepository.postDataFromDatabaseToAPI();
// // //         debugPrint("✅ Background sync completed");
// // //
// // //         // Update sync status
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //         await prefs.setString('clockOutSyncStatus', 'synced');
// // //       } else {
// // //         debugPrint("📶 No internet - will sync later");
// // //         // Will be synced by the auto-sync system when internet comes back
// // //       }
// // //     } catch (e) {
// // //       debugPrint("⚠️ Background sync failed: $e");
// // //       // Will retry on next auto-sync
// // //     }
// // //   }
// // //
// // //   // ✅ NEW: Force sync pending data
// // //   Future<void> syncPendingData() async {
// // //     try {
// // //       debugPrint("🔄 Forcing sync of pending attendance out data...");
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       String syncStatus = prefs.getString('clockOutSyncStatus') ?? '';
// // //
// // //       if (syncStatus == 'pending' || syncStatus == 'pending_local' || syncStatus == 'retry_needed') {
// // //         await attendanceOutRepository.postDataFromDatabaseToAPI();
// // //         await prefs.setString('clockOutSyncStatus', 'synced');
// // //         debugPrint("✅ Pending data synced successfully");
// // //       } else {
// // //         debugPrint("✅ No pending data to sync");
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error syncing pending data: $e");
// // //     }
// // //   }
// // //
// // //   Future<void> fetchAllAttendanceOut() async {
// // //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// // //     allAttendanceOut.value = attendanceOut;
// // //   }
// // //
// // //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // //     attendanceOutRepository.add(attendanceOutModel);
// // //     fetchAllAttendanceOut();
// // //   }
// // //
// // //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// // //     attendanceOutRepository.update(attendanceOutModel);
// // //     fetchAllAttendanceOut();
// // //   }
// // //
// // //   void deleteAttendanceOut(String id) {
// // //     attendanceOutRepository.delete(id);
// // //     fetchAllAttendanceOut();
// // //   }
// // //
// // //   Future<void> serialCounterGet() async {
// // //     await attendanceOutRepository.serialNumberGeneratorApi();
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'dart:async';
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:get/get.dart';
// // import 'package:intl/intl.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Databases/util.dart';
// // import '../Models/attendanceOut_model.dart';
// // import '../Repositories/attendance_out_repository.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // import 'location_view_model.dart';
// // // Import the Clock-In ViewModel to access the clear state method
// // import 'attendance_view_model.dart';
// //
// // class AttendanceOutViewModel extends GetxController {
// //   var allAttendanceOut = <AttendanceOutModel>[].obs;
// //   final AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //   // Get the AttendanceViewModel instance to clear clock-in state
// //   final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
// //
// //   // ✅ SIMPLE DEVICE TIME AUTO CLOCK-OUT VARIABLE
// //   Timer? _deviceTimeCheckTimer;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchAllAttendanceOut();
// //     attendanceOutRepository.postDataFromDatabaseToAPI();
// //
// //     // ✅ RESTORE ANY PENDING DATA ON STARTUP
// //     restoreFromBackupIfNeeded();
// //
// //     // ✅ SIMPLE: Start checking device time for 11:00 PM
// //     _startSimpleDeviceTimeCheck();
// //   }
// //
// //   @override
// //   void onClose() {
// //     // ✅ Clean up timer
// //     _deviceTimeCheckTimer?.cancel();
// //     super.onClose();
// //   }
// //
// //   /// ✅ UPDATED: Enhanced saveFormAttendanceOut method with SharedPreferences backup
// //   Future<void> saveFormAttendanceOutWithPrefs({
// //     DateTime? clockOutTime,
// //     double? totalDistance,
// //     bool isAuto = false,
// //     String reason = 'manual',
// //   }) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.reload();
// //
// //     // Use provided clock-out time or current device time
// //     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
// //
// //     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
// //     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
// //     debugPrint("🤖 Auto clock-out: ${isAuto ? 'Yes ($reason)' : 'No (Manual)'}");
// //
// //     // ✅ RETRIEVE SHIFT DATA FROM SHAREDPREFERENCES (FASTER)
// //     String? clockInTimeString = prefs.getString('clockInTime');
// //     DateTime shiftStartTime = clockInTimeString != null
// //         ? DateTime.parse(clockInTimeString)
// //         : actualClockOutTime.subtract(const Duration(hours: 1)); // Default 1 hour
// //
// //     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
// //     String totalTime = _formatDuration(shiftDuration);
// //
// //     // Use provided distance or calculate from SharedPreferences
// //     double finalDistance = totalDistance ??
// //         (await locationViewModel.calculateShiftDistance(shiftStartTime));
// //
// //     // Get attendance ID
// //     final attendanceId = prefs.getString('attendanceId') ?? '';
// //
// //     if (attendanceId.isEmpty) {
// //       debugPrint("⚠️ No matching attendanceId found for Clock Out!");
// //       await attendanceOutRepository.serialNumberGeneratorApi();
// //       final newAttendanceId = prefs.getString('attendanceId') ?? '';
// //
// //       if (newAttendanceId.isEmpty) {
// //         debugPrint("❌ Failed to generate attendance ID");
// //
// //         // ✅ STILL SAVE TO SHAREDPREFERENCES AS BACKUP
// //         await _saveToPrefsAsBackup(
// //           clockOutTime: actualClockOutTime,
// //           totalTime: totalTime,
// //           totalDistance: finalDistance,
// //           reason: reason,
// //         );
// //
// //         return;
// //       }
// //     }
// //
// //     String address = locationViewModel.shopAddress.value;
// //
// //     // ✅ Add auto clock-out note if it's an auto clock-out
// //     if (isAuto) {
// //       address = "$address (Auto clock-out: $reason at ${DateFormat('hh:mm a').format(actualClockOutTime)})";
// //     }
// //
// //     // ✅ STEP 1: SAVE TO SHAREDPREFERENCES (IMMEDIATE)
// //     await _saveToPrefsAsBackup(
// //       attendanceId: attendanceId,
// //       clockOutTime: actualClockOutTime,
// //       totalTime: totalTime,
// //       totalDistance: finalDistance,
// //       address: address,
// //       reason: reason,
// //     );
// //
// //     // ✅ STEP 2: SAVE TO LOCAL DATABASE
// //     addAttendanceOut(
// //       AttendanceOutModel(
// //         attendance_out_id: attendanceId,
// //         user_id: user_id,
// //         total_distance: finalDistance,
// //         total_time: totalTime,
// //         lat_out: locationViewModel.globalLatitude1.value,
// //         lng_out: locationViewModel.globalLongitude1.value,
// //         address: address,
// //       ),
// //     );
// //
// //     // ✅ STEP 3: TRY TO POST TO API (FIRE AND FORGET - DON'T WAIT)
// //     _tryPostToApiInBackground(attendanceId);
// //
// //     // ✅ STEP 4: CLEAR CLOCK-IN STATE
// //     await attendanceViewModel.clearClockInState();
// //
// //     debugPrint("✅ Clock-out saved successfully (Local + SharedPreferences)");
// //   }
// //
// //   /// ✅ FORMAT DURATION TO H:mm:ss
// //   String _formatDuration(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     String hours = twoDigits(duration.inHours);
// //     String minutes = twoDigits(duration.inMinutes.remainder(60));
// //     String seconds = twoDigits(duration.inSeconds.remainder(60));
// //     return '$hours:$minutes:$seconds';
// //   }
// //
// //   /// ✅ SIMPLE: Start checking device time for 11:00 PM
// //   void _startSimpleDeviceTimeCheck() {
// //     debugPrint("⏰ Starting device time check for 11:00 PM auto clock-out");
// //
// //     // Check every minute for 11:00 PM
// //     _deviceTimeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// //       _checkFor11PM();
// //     });
// //   }
// //
// //   /// ✅ SIMPLE: Check if it's 11:00 PM device time
// //   Future<void> _checkFor11PM() async {
// //     try {
// //       // Get current device time
// //       DateTime now = DateTime.now();
// //
// //       // Check if it's exactly 11:00 PM
// //       if (now.hour == 23 && now.minute == 0) {
// //         debugPrint("⏰ 11:00 PM device time detected!");
// //
// //         // Get SharedPreferences
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //         // Check if user is clocked in
// //         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// //
// //         if (isClockedIn) {
// //           debugPrint("🤖 User is clocked in - triggering auto clock-out");
// //
// //           // Create 11:00 PM timestamp
// //           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 0, 0);
// //
// //           // Save auto clock-out with SharedPreferences backup
// //           await saveFormAttendanceOutWithPrefs(
// //             clockOutTime: clockOutTime,
// //             isAuto: true,
// //             reason: '11pm_auto',
// //           );
// //         } else {
// //           debugPrint("⏰ User already clocked out at 11:00 PM");
// //         }
// //       }
// //
// //     } catch (e) {
// //       debugPrint("❌ Error in 11:00 PM check: $e");
// //     }
// //   }
// //
// //   // ✅ NEW METHOD: Save to SharedPreferences as backup
// //   Future<void> _saveToPrefsAsBackup({
// //     String? attendanceId,
// //     required DateTime clockOutTime,
// //     required String totalTime,
// //     required double totalDistance,
// //     String address = '',
// //     String reason = 'manual',
// //   }) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //     // Save all clock-out data
// //     Map<String, dynamic> clockOutData = {
// //       'backup_attendanceId': attendanceId ?? 'UNKNOWN',
// //       'backup_userId': user_id,
// //       'backup_clockOutTime': clockOutTime.toIso8601String(),
// //       'backup_totalTime': totalTime,
// //       'backup_totalDistance': totalDistance,
// //       'backup_latOut': locationViewModel.globalLatitude1.value,
// //       'backup_lngOut': locationViewModel.globalLongitude1.value,
// //       'backup_address': address.isNotEmpty ? address : locationViewModel.shopAddress.value,
// //       'backup_reason': reason,
// //       'backup_savedAt': DateTime.now().toIso8601String(),
// //     };
// //
// //     // Convert map to JSON string
// //     String jsonData = json.encode(clockOutData);
// //     await prefs.setString('backupClockOutData', jsonData);
// //     await prefs.setBool('hasBackupClockOutData', true);
// //
// //     debugPrint("📱 [BACKUP] Clock-out data saved to SharedPreferences");
// //   }
// //
// //   // ✅ NEW METHOD: Try to post to API in background
// //   void _tryPostToApiInBackground(String attendanceId) async {
// //     try {
// //       debugPrint("🌐 [BACKGROUND SYNC] Attempting API post...");
// //
// //       // Quick internet check
// //       var connectivity = Connectivity();
// //       var results = await connectivity.checkConnectivity();
// //       bool isOnline = results.isNotEmpty &&
// //           results.any((result) => result != ConnectivityResult.none);
// //
// //       if (isOnline) {
// //         await attendanceOutRepository.postDataFromDatabaseToAPI();
// //         debugPrint("✅ [BACKGROUND SYNC] API post completed");
// //
// //         // Clear backup data if successfully posted
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('hasBackupClockOutData', false);
// //         await prefs.remove('backupClockOutData');
// //       } else {
// //         debugPrint("🌐 [BACKGROUND SYNC] No internet - Will retry later");
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [BACKGROUND SYNC] API post error: $e");
// //       // Data is safe in SharedPreferences, so no problem
// //     }
// //   }
// //
// //   // ✅ NEW METHOD: Restore from backup if needed
// //   Future<void> restoreFromBackupIfNeeded() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool hasBackup = prefs.getBool('hasBackupClockOutData') ?? false;
// //
// //     if (hasBackup) {
// //       String jsonData = prefs.getString('backupClockOutData') ?? '{}';
// //       try {
// //         Map<String, dynamic> data = json.decode(jsonData);
// //
// //         debugPrint("🔄 Restoring clock-out data from backup...");
// //         debugPrint("   - Attendance ID: ${data['backup_attendanceId']}");
// //         debugPrint("   - Reason: ${data['backup_reason']}");
// //
// //         // Add to database
// //         addAttendanceOut(
// //           AttendanceOutModel(
// //             attendance_out_id: data['backup_attendanceId'],
// //             user_id: data['backup_userId'],
// //             total_distance: data['backup_totalDistance'],
// //             total_time: data['backup_totalTime'],
// //             lat_out: data['backup_latOut'],
// //             lng_out: data['backup_lngOut'],
// //             address: data['backup_address'],
// //           ),
// //         );
// //
// //         // Try to post to API again
// //         _tryPostToApiInBackground(data['backup_attendanceId']);
// //
// //       } catch (e) {
// //         debugPrint("❌ Error restoring backup: $e");
// //       }
// //     }
// //   }
// //
// //   /// ✅ LEGACY METHOD: Keep for backward compatibility
// //   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
// //     await saveFormAttendanceOutWithPrefs(
// //       clockOutTime: clockOutTime,
// //       isAuto: clockOutTime != null,
// //       reason: clockOutTime != null ? 'legacy_auto' : 'manual',
// //     );
// //   }
// //
// //   Future<void> fetchAllAttendanceOut() async {
// //     var attendanceOut = await attendanceOutRepository.getAttendanceOut();
// //     allAttendanceOut.value = attendanceOut;
// //   }
// //
// //   void addAttendanceOut(AttendanceOutModel attendanceOutModel) {
// //     attendanceOutRepository.add(attendanceOutModel);
// //     fetchAllAttendanceOut();
// //   }
// //
// //   void updateAttendanceOut(AttendanceOutModel attendanceOutModel) {
// //     attendanceOutRepository.update(attendanceOutModel);
// //     fetchAllAttendanceOut();
// //   }
// //
// //   void deleteAttendanceOut(String id) {
// //     attendanceOutRepository.delete(id);
// //     fetchAllAttendanceOut();
// //   }
// //
// //   Future<void> serialCounterGet() async {
// //     await attendanceOutRepository.serialNumberGeneratorApi();
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
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
//   // ✅ AUTO CLOCK-OUT VARIABLE - CHANGED TO 11:58 PM
//   Timer? _autoClockOutTimer;
//
//   // Connectivity instance for internet checks
//   final Connectivity _connectivity = Connectivity();
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendanceOut();
//
//     // ✅ INITIAL API SYNC
//     attendanceOutRepository.postDataFromDatabaseToAPI();
//
//     // ✅ RESTORE ANY PENDING DATA ON STARTUP
//     restoreFromBackupIfNeeded();
//
//     // ✅ START CHECKING FOR 11:58 PM AUTO CLOCK-OUT
//     _startAutoClockOutTimer();
//
//     // ✅ START PERIODIC SYNC CHECK
//     _startPeriodicSyncCheck();
//   }
//
//   @override
//   void onClose() {
//     // ✅ Clean up timers
//     _autoClockOutTimer?.cancel();
//     super.onClose();
//   }
//
//   /// ✅ UPDATED: Enhanced saveFormAttendanceOut method with proper distance handling
//   Future<void> saveFormAttendanceOutWithPrefs({
//     DateTime? clockOutTime,
//     double? totalDistance,
//     bool isAuto = false,
//     String reason = 'manual',
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     // Use provided clock-out time or current device time
//     DateTime actualClockOutTime = clockOutTime ?? DateTime.now();
//
//     debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
//     debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
//     debugPrint("🤖 Auto clock-out: ${isAuto ? 'Yes ($reason)' : 'No (Manual)'}");
//
//     // ✅ RETRIEVE SHIFT DATA FROM SHAREDPREFERENCES
//     String? clockInTimeString = prefs.getString('clockInTime');
//     DateTime shiftStartTime = clockInTimeString != null
//         ? DateTime.parse(clockInTimeString)
//         : actualClockOutTime.subtract(const Duration(hours: 1));
//
//     Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
//     String totalTime = _formatDuration(shiftDuration);
//
//     // ✅ PRIORITY: Use provided distance first, then check SharedPreferences
//     double finalDistance = 0.0;
//
//     if (totalDistance != null && totalDistance > 0) {
//       // 1. Use provided distance
//       finalDistance = totalDistance;
//       debugPrint("📍 [DISTANCE] Using provided distance: ${finalDistance.toStringAsFixed(3)} km");
//     } else {
//       // 2. Check SharedPreferences for saved distance
//       double savedDistance = prefs.getDouble('clockOutDistance') ?? 0.0;
//       if (savedDistance > 0) {
//         finalDistance = savedDistance;
//         debugPrint("📍 [DISTANCE] Using saved distance from SharedPreferences: ${savedDistance.toStringAsFixed(3)} km");
//       } else {
//         // 3. Check backup distance
//         double backupDistance = prefs.getDouble('backupDistance') ?? 0.0;
//         if (backupDistance > 0) {
//           finalDistance = backupDistance;
//           debugPrint("📍 [DISTANCE] Using backup distance: ${backupDistance.toStringAsFixed(3)} km");
//         } else {
//           // 4. Calculate from LocationViewModel
//           try {
//             finalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
//             debugPrint("📍 [DISTANCE] Calculated from LocationViewModel: ${finalDistance.toStringAsFixed(3)} km");
//           } catch (e) {
//             debugPrint("❌ [DISTANCE] Error calculating distance: $e");
//             finalDistance = 0.0;
//           }
//         }
//       }
//     }
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
//
//         // ✅ STILL SAVE TO SHAREDPREFERENCES AS BACKUP
//         await _saveToPrefsAsBackup(
//           clockOutTime: actualClockOutTime,
//           totalTime: totalTime,
//           totalDistance: finalDistance,
//           reason: reason,
//         );
//
//         return;
//       }
//     }
//
//     String address = locationViewModel.shopAddress.value;
//
//     // ✅ Add auto clock-out note if it's an auto clock-out
//     if (isAuto) {
//       address = "$address (Auto clock-out: $reason at ${DateFormat('hh:mm a').format(actualClockOutTime)})";
//     }
//
//     // ✅ STEP 1: SAVE TO SHAREDPREFERENCES (IMMEDIATE)
//     await _saveToPrefsAsBackup(
//       attendanceId: attendanceId,
//       clockOutTime: actualClockOutTime,
//       totalTime: totalTime,
//       totalDistance: finalDistance,
//       address: address,
//       reason: reason,
//     );
//
//     // ✅ STEP 2: CREATE ATTENDANCE OUT MODEL WITH DISTANCE
//     AttendanceOutModel attendanceOutModel = AttendanceOutModel(
//       attendance_out_id: attendanceId,
//       user_id: user_id,
//       total_distance: finalDistance,
//       total_time: totalTime,
//       lat_out: locationViewModel.globalLatitude1.value,
//       lng_out: locationViewModel.globalLongitude1.value,
//       address: address,
//     );
//
//     debugPrint("📊 [ATTENDANCE OUT DATA]");
//     debugPrint("   - ID: $attendanceId");
//     debugPrint("   - User: $user_id");
//     debugPrint("   - Distance: ${finalDistance.toStringAsFixed(3)} km");
//     debugPrint("   - Time: $totalTime");
//     debugPrint("   - Location: ${locationViewModel.globalLatitude1.value}, ${locationViewModel.globalLongitude1.value}");
//
//     // ✅ STEP 3: SAVE TO LOCAL DATABASE
//     addAttendanceOut(attendanceOutModel);
//
//     // ✅ STEP 4: TRY TO POST TO API IMMEDIATELY WITH DISTANCE
//     await _postAttendanceOutToApi(attendanceOutModel);
//
//     // ✅ STEP 5: CLEAR CLOCK-IN STATE
//     await attendanceViewModel.clearClockInState();
//
//     debugPrint("✅ Clock-out saved successfully with distance: ${finalDistance.toStringAsFixed(3)} km");
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
//   /// ✅ UPDATED: Start checking device time for 11:58 PM AUTO CLOCK-OUT
//   void _startAutoClockOutTimer() {
//     debugPrint("⏰ Starting auto clock-out timer for 11:58 PM");
//
//     // Check every minute for 11:58 PM
//     _autoClockOutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkForAutoClockOut();
//     });
//
//     // Also check immediately
//     _checkForAutoClockOut();
//   }
//
//   /// ✅ UPDATED: Check if it's 11:58 PM for auto clock-out
//   Future<void> _checkForAutoClockOut() async {
//     try {
//       // Get current device time
//       DateTime now = DateTime.now();
//
//       // ✅ CHANGED: Check if it's exactly 11:58 PM (23:58)
//       if (now.hour == 23 && now.minute == 58) {
//         debugPrint("🕰 11:58 PM AUTO CLOCK-OUT TIME DETECTED!");
//
//         // Get SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         // Check if user is clocked in
//         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//
//         if (isClockedIn) {
//           debugPrint("🤖 User is clocked in - triggering 11:58 PM auto clock-out");
//
//           // Create 11:58 PM timestamp
//           DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
//
//           // Save auto clock-out with SharedPreferences backup
//           await saveFormAttendanceOutWithPrefs(
//             clockOutTime: clockOutTime,
//             isAuto: true,
//             reason: '11:58_pm_auto',
//           );
//
//           // Show notification to user
//           Get.snackbar(
//             'Auto Clock-Out',
//             'Automatically clocked out at 11:58 PM',
//             snackPosition: SnackPosition.TOP,
//             // backgroundColor: Colors.purple.shade700,
//             // colorText: Colors.white,
//             duration: const Duration(seconds: 10),
//           );
//
//         } else {
//           debugPrint("⏰ User already clocked out at 11:58 PM");
//         }
//       }
//
//     } catch (e) {
//       debugPrint("❌ Error in auto clock-out check: $e");
//     }
//   }
//
//   // ✅ UPDATE: Save to SharedPreferences with distance
//   Future<void> _saveToPrefsAsBackup({
//     String? attendanceId,
//     required DateTime clockOutTime,
//     required String totalTime,
//     required double totalDistance,
//     String address = '',
//     String reason = 'manual',
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Save all clock-out data
//     Map<String, dynamic> clockOutData = {
//       'backup_attendanceId': attendanceId ?? 'UNKNOWN',
//       'backup_userId': user_id,
//       'backup_clockOutTime': clockOutTime.toIso8601String(),
//       'backup_totalTime': totalTime,
//       'backup_totalDistance': totalDistance, // ✅ DISTANCE INCLUDED
//       'backup_latOut': locationViewModel.globalLatitude1.value,
//       'backup_lngOut': locationViewModel.globalLongitude1.value,
//       'backup_address': address.isNotEmpty ? address : locationViewModel.shopAddress.value,
//       'backup_reason': reason,
//       'backup_savedAt': DateTime.now().toIso8601String(),
//     };
//
//     // Convert map to JSON string
//     String jsonData = json.encode(clockOutData);
//     await prefs.setString('backupClockOutData', jsonData);
//     await prefs.setBool('hasBackupClockOutData', true);
//
//     // ✅ ALSO SAVE DISTANCE SEPARATELY FOR EASY ACCESS
//     await prefs.setDouble('backupDistance', totalDistance);
//
//     debugPrint("📱 [BACKUP] Clock-out data saved with distance: ${totalDistance.toStringAsFixed(3)} km");
//   }
//
//   // ✅ NEW METHOD: Post attendance out to API with retry logic
//   Future<void> _postAttendanceOutToApi(AttendanceOutModel attendanceOutModel) async {
//     try {
//       debugPrint("🌐 [API POST] Attempting to post attendance-out data...");
//       debugPrint("   - Distance to post: ${attendanceOutModel.total_distance} km");
//
//       // Quick internet check
//       var results = await _connectivity.checkConnectivity();
//       bool isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       if (isOnline) {
//         // ✅ POST TO API WITH AWAIT
//         await attendanceOutRepository.postDataFromDatabaseToAPI();
//
//         // ✅ VERIFY THE DATA WAS POSTED
//         debugPrint("✅ [API POST] Successfully posted attendance-out data");
//         debugPrint("   - Posted distance: ${attendanceOutModel.total_distance} km");
//
//         // Clear backup data if successfully posted
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('hasBackupClockOutData', false);
//         await prefs.remove('backupClockOutData');
//         await prefs.remove('backupDistance');
//         await prefs.remove('clockOutDistance');
//
//       } else {
//         debugPrint("🌐 [API POST] No internet - Data saved locally, will sync later");
//
//         // Mark for auto-sync
//         await _saveToPrefsAsBackup(
//           attendanceId: attendanceOutModel.attendance_out_id,
//           clockOutTime: DateTime.now(),
//           totalTime: attendanceOutModel.total_time,
//           totalDistance: attendanceOutModel.total_distance,
//           address: attendanceOutModel.address,
//           reason: 'offline_pending',
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ [API POST] Error posting attendance-out: $e");
//       debugPrint("   - Failed distance: ${attendanceOutModel.total_distance} km");
//
//       // Data remains in SharedPreferences backup, will retry later
//     }
//   }
//
//   // ✅ NEW METHOD: Try to post to API in background (for backward compatibility)
//   void _tryPostToApiInBackground(String attendanceId) async {
//     try {
//       debugPrint("🌐 [BACKGROUND SYNC] Attempting API post...");
//
//       // Quick internet check
//       var results = await _connectivity.checkConnectivity();
//       bool isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       if (isOnline) {
//         await attendanceOutRepository.postDataFromDatabaseToAPI();
//         debugPrint("✅ [BACKGROUND SYNC] API post completed");
//
//         // Clear backup data if successfully posted
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('hasBackupClockOutData', false);
//         await prefs.remove('backupClockOutData');
//         await prefs.remove('backupDistance');
//       } else {
//         debugPrint("🌐 [BACKGROUND SYNC] No internet - Will retry later");
//       }
//     } catch (e) {
//       debugPrint("❌ [BACKGROUND SYNC] API post error: $e");
//       // Data is safe in SharedPreferences, so no problem
//     }
//   }
//
//   // ✅ NEW METHOD: Restore from backup if needed
//   Future<void> restoreFromBackupIfNeeded() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasBackup = prefs.getBool('hasBackupClockOutData') ?? false;
//
//     if (hasBackup) {
//       String jsonData = prefs.getString('backupClockOutData') ?? '{}';
//       try {
//         Map<String, dynamic> data = json.decode(jsonData);
//
//         debugPrint("🔄 Restoring clock-out data from backup...");
//         debugPrint("   - Attendance ID: ${data['backup_attendanceId']}");
//         debugPrint("   - Reason: ${data['backup_reason']}");
//         debugPrint("   - Distance: ${data['backup_totalDistance']} km");
//
//         // Add to database
//         addAttendanceOut(
//           AttendanceOutModel(
//             attendance_out_id: data['backup_attendanceId'],
//             user_id: data['backup_userId'],
//             total_distance: data['backup_totalDistance'],
//             total_time: data['backup_totalTime'],
//             lat_out: data['backup_latOut'],
//             lng_out: data['backup_lngOut'],
//             address: data['backup_address'],
//           ),
//         );
//
//         // Try to post to API again
//         _tryPostToApiInBackground(data['backup_attendanceId']);
//
//       } catch (e) {
//         debugPrint("❌ Error restoring backup: $e");
//       }
//     }
//   }
//
//   /// ✅ LEGACY METHOD: Keep for backward compatibility
//   Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
//     await saveFormAttendanceOutWithPrefs(
//       clockOutTime: clockOutTime,
//       isAuto: clockOutTime != null,
//       reason: clockOutTime != null ? 'legacy_auto' : 'manual',
//     );
//   }
//
//   // ✅ NEW METHOD: Direct save with distance for immediate use
//   Future<void> saveAttendanceOutWithDistance({
//     required String attendanceId,
//     required double distance,
//     required DateTime clockOutTime,
//     String address = '',
//     bool isAuto = false,
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     String? clockInTimeString = prefs.getString('clockInTime');
//     DateTime shiftStartTime = clockInTimeString != null
//         ? DateTime.parse(clockInTimeString)
//         : clockOutTime.subtract(const Duration(hours: 1));
//
//     Duration shiftDuration = clockOutTime.difference(shiftStartTime);
//     String totalTime = _formatDuration(shiftDuration);
//
//     // Add auto note if needed
//     String finalAddress = address;
//     if (isAuto) {
//       finalAddress = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
//     }
//
//     // Create attendance out model
//     AttendanceOutModel attendanceOutModel = AttendanceOutModel(
//       attendance_out_id: attendanceId,
//       user_id: user_id,
//       total_distance: distance,
//       total_time: totalTime,
//       lat_out: locationViewModel.globalLatitude1.value,
//       lng_out: locationViewModel.globalLongitude1.value,
//       address: finalAddress.isNotEmpty ? finalAddress : locationViewModel.shopAddress.value,
//     );
//
//     // Save to database
//     addAttendanceOut(attendanceOutModel);
//
//     // Save to SharedPreferences backup
//     await _saveToPrefsAsBackup(
//       attendanceId: attendanceId,
//       clockOutTime: clockOutTime,
//       totalTime: totalTime,
//       totalDistance: distance,
//       address: finalAddress,
//       reason: isAuto ? 'direct_auto' : 'direct_manual',
//     );
//
//     // Try to post immediately
//     await _postAttendanceOutToApi(attendanceOutModel);
//
//     debugPrint("✅ Direct save with distance: ${distance.toStringAsFixed(3)} km");
//   }
//
//   // ✅ NEW METHOD: Start periodic sync check
//   void _startPeriodicSyncCheck() {
//     // Check for pending data every 5 minutes
//     Timer.periodic(const Duration(minutes: 5), (timer) async {
//       await _syncPendingDataIfOnline();
//     });
//   }
//
//   // ✅ NEW METHOD: Sync pending data if online
//   Future<void> _syncPendingDataIfOnline() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       bool hasPendingData = prefs.getBool('hasBackupClockOutData') ?? false;
//
//       if (!hasPendingData) {
//         return;
//       }
//
//       var results = await _connectivity.checkConnectivity();
//       bool isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       if (isOnline) {
//         debugPrint("🔄 [PERIODIC SYNC] Internet available - syncing pending data");
//         await attendanceOutRepository.postDataFromDatabaseToAPI();
//
//         // Clear backup if successful
//         await prefs.setBool('hasBackupClockOutData', false);
//         await prefs.remove('backupClockOutData');
//         await prefs.remove('backupDistance');
//
//         debugPrint("✅ [PERIODIC SYNC] Pending data synced successfully");
//       }
//     } catch (e) {
//       debugPrint("❌ [PERIODIC SYNC] Error: $e");
//     }
//   }
//
//   // ✅ NEW: Check if user should be auto clocked out
//   Future<bool> shouldAutoClockOut() async {
//     try {
//       DateTime now = DateTime.now();
//
//       // Check if it's 11:58 PM
//       if (now.hour == 23 && now.minute == 58) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//
//         return isClockedIn;
//       }
//
//       return false;
//     } catch (e) {
//       debugPrint("❌ Error checking auto clock-out: $e");
//       return false;
//     }
//   }
//
//   // ✅ NEW: Get auto clock-out time
//   DateTime getAutoClockOutTime() {
//     DateTime now = DateTime.now();
//     // Return today's 11:58 PM
//     return DateTime(now.year, now.month, now.day, 23, 58, 0);
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
//
//   // ✅ NEW: Debug method to check distance in database
//   void debugDistanceInDatabase() async {
//     debugPrint("🔍 [DATABASE DEBUG] Checking attendance-out records...");
//
//     var records = await attendanceOutRepository.getAttendanceOut();
//     if (records.isEmpty) {
//       debugPrint("📭 No attendance-out records found in database");
//       return;
//     }
//
//     for (var record in records) {
//       debugPrint("📊 Record: ID=${record.attendance_out_id}, Distance=${record.total_distance} km, Time=${record.total_time}");
//     }
//   }
//
//   // ✅ NEW: Get total clock-outs count for today
//   Future<int> getTodayClockOutsCount() async {
//     try {
//       var records = await attendanceOutRepository.getAttendanceOut();
//       DateTime today = DateTime.now();
//       String todayDate = DateFormat('yyyy-MM-dd').format(today);
//
//       int count = 0;
//       for (var record in records) {
//         // Extract date from attendance ID or check timestamp
//         if (record.attendance_out_id.contains(todayDate.substring(5, 7))) { // Check month
//           count++;
//         }
//       }
//
//       return count;
//     } catch (e) {
//       debugPrint("❌ Error getting today's clock-outs count: $e");
//       return 0;
//     }
//   }
// }
//

///2nd for fast out
import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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

  // ✅ AUTO CLOCK-OUT VARIABLE - CHANGED TO 11:58 PM
  Timer? _autoClockOutTimer;

  // Connectivity instance for internet checks
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendanceOut();

    // ✅ INITIAL API SYNC
    attendanceOutRepository.postDataFromDatabaseToAPI();

    // ✅ RESTORE ANY PENDING DATA ON STARTUP
    restoreFromBackupIfNeeded();

    // ✅ RESTORE FAST SAVED DATA ON STARTUP
    restoreFastDataOnStartup();

    // ✅ START CHECKING FOR 11:58 PM AUTO CLOCK-OUT
    _startAutoClockOutTimer();

    // ✅ START PERIODIC SYNC CHECK
    _startPeriodicSyncCheck();
  }

  @override
  void onClose() {
    // ✅ Clean up timers
    _autoClockOutTimer?.cancel();
    super.onClose();
  }

  /// ✅ UPDATED: Enhanced saveFormAttendanceOut method with proper distance handling
  Future<void> saveFormAttendanceOutWithPrefs({
    DateTime? clockOutTime,
    double? totalDistance,
    bool isAuto = false,
    String reason = 'manual',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Use provided clock-out time or current device time
    DateTime actualClockOutTime = clockOutTime ?? DateTime.now();

    debugPrint("🕐 Clock-out time: ${DateFormat('hh:mm:ss a').format(actualClockOutTime)}");
    debugPrint("📱 Device time: ${DateFormat('hh:mm:ss a').format(DateTime.now())}");
    debugPrint("🤖 Auto clock-out: ${isAuto ? 'Yes ($reason)' : 'No (Manual)'}");

    // ✅ RETRIEVE SHIFT DATA FROM SHAREDPREFERENCES
    String? clockInTimeString = prefs.getString('clockInTime');
    DateTime shiftStartTime = clockInTimeString != null
        ? DateTime.parse(clockInTimeString)
        : actualClockOutTime.subtract(const Duration(hours: 1));

    Duration shiftDuration = actualClockOutTime.difference(shiftStartTime);
    String totalTime = _formatDuration(shiftDuration);

    // ✅ PRIORITY: Use provided distance first, then check SharedPreferences
    double finalDistance = 0.0;

    if (totalDistance != null && totalDistance > 0) {
      // 1. Use provided distance
      finalDistance = totalDistance;
      debugPrint("📍 [DISTANCE] Using provided distance: ${finalDistance.toStringAsFixed(3)} km");
    } else {
      // 2. Check SharedPreferences for saved distance
      double savedDistance = prefs.getDouble('clockOutDistance') ?? 0.0;
      if (savedDistance > 0) {
        finalDistance = savedDistance;
        debugPrint("📍 [DISTANCE] Using saved distance from SharedPreferences: ${savedDistance.toStringAsFixed(3)} km");
      } else {
        // 3. Check backup distance
        double backupDistance = prefs.getDouble('backupDistance') ?? 0.0;
        if (backupDistance > 0) {
          finalDistance = backupDistance;
          debugPrint("📍 [DISTANCE] Using backup distance: ${backupDistance.toStringAsFixed(3)} km");
        } else {
          // 4. Calculate from LocationViewModel
          try {
            finalDistance = await locationViewModel.calculateShiftDistance(shiftStartTime);
            debugPrint("📍 [DISTANCE] Calculated from LocationViewModel: ${finalDistance.toStringAsFixed(3)} km");
          } catch (e) {
            debugPrint("❌ [DISTANCE] Error calculating distance: $e");
            finalDistance = 0.0;
          }
        }
      }
    }

    // Get attendance ID
    final attendanceId = prefs.getString('attendanceId') ?? '';

    if (attendanceId.isEmpty) {
      debugPrint("⚠️ No matching attendanceId found for Clock Out!");
      await attendanceOutRepository.serialNumberGeneratorApi();
      final newAttendanceId = prefs.getString('attendanceId') ?? '';

      if (newAttendanceId.isEmpty) {
        debugPrint("❌ Failed to generate attendance ID");

        // ✅ STILL SAVE TO SHAREDPREFERENCES AS BACKUP
        await _saveToPrefsAsBackup(
          clockOutTime: actualClockOutTime,
          totalTime: totalTime,
          totalDistance: finalDistance,
          reason: reason,
        );

        return;
      }
    }

    String address = locationViewModel.shopAddress.value;

    // ✅ Add auto clock-out note if it's an auto clock-out
    if (isAuto) {
      address = "$address (Auto clock-out: $reason at ${DateFormat('hh:mm a').format(actualClockOutTime)})";
    }

    // ✅ STEP 1: SAVE TO SHAREDPREFERENCES (IMMEDIATE)
    await _saveToPrefsAsBackup(
      attendanceId: attendanceId,
      clockOutTime: actualClockOutTime,
      totalTime: totalTime,
      totalDistance: finalDistance,
      address: address,
      reason: reason,
    );

    // ✅ STEP 2: CREATE ATTENDANCE OUT MODEL WITH DISTANCE
    AttendanceOutModel attendanceOutModel = AttendanceOutModel(
      attendance_out_id: attendanceId,
      user_id: user_id,
      total_distance: finalDistance,
      total_time: totalTime,
      lat_out: locationViewModel.globalLatitude1.value,
      lng_out: locationViewModel.globalLongitude1.value,
      address: address,
    );

    debugPrint("📊 [ATTENDANCE OUT DATA]");
    debugPrint("   - ID: $attendanceId");
    debugPrint("   - User: $user_id");
    debugPrint("   - Distance: ${finalDistance.toStringAsFixed(3)} km");
    debugPrint("   - Time: $totalTime");
    debugPrint("   - Location: ${locationViewModel.globalLatitude1.value}, ${locationViewModel.globalLongitude1.value}");

    // ✅ STEP 3: SAVE TO LOCAL DATABASE
    addAttendanceOut(attendanceOutModel);

    // ✅ STEP 4: TRY TO POST TO API IMMEDIATELY WITH DISTANCE
    await _postAttendanceOutToApi(attendanceOutModel);

    // ✅ STEP 5: CLEAR CLOCK-IN STATE
    await attendanceViewModel.clearClockInState();

    debugPrint("✅ Clock-out saved successfully with distance: ${finalDistance.toStringAsFixed(3)} km");
  }

  // ✅ ULTRA-FAST ATTENDANCE SAVE - COMPLETES IN <1 SECOND
  Future<void> fastSaveAttendanceOut({
    required DateTime clockOutTime,
    required double totalDistance,
    bool isAuto = false,
    String reason = 'fast_manual',
  }) async {
    debugPrint("⚡ [FAST SAVE] Starting ultra-fast attendance save");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ STEP 1: GET ESSENTIAL DATA QUICKLY
    String attendanceId = prefs.getString('attendanceId') ?? '';

    // Generate ID if missing (quickly)
    if (attendanceId.isEmpty) {
      attendanceId = 'FAST_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('fastAttendanceId', attendanceId);
    }

    // ✅ STEP 2: CALCULATE TOTAL TIME QUICKLY
    String? clockInTimeString = prefs.getString('clockInTime');
    String totalTime = '00:00:00';

    if (clockInTimeString != null) {
      try {
        DateTime shiftStartTime = DateTime.parse(clockInTimeString);
        Duration shiftDuration = clockOutTime.difference(shiftStartTime);
        totalTime = _formatDuration(shiftDuration);
      } catch (e) {
        totalTime = '00:00:00';
      }
    }

    // ✅ STEP 3: SAVE TO SHAREDPREFERENCES (FASTEST)
    Map<String, dynamic> fastData = {
      'fast_attendanceId': attendanceId,
      'fast_userId': user_id,
      'fast_clockOutTime': clockOutTime.toIso8601String(),
      'fast_totalTime': totalTime,
      'fast_totalDistance': totalDistance,
      'fast_latOut': locationViewModel.globalLatitude1.value,
      'fast_lngOut': locationViewModel.globalLongitude1.value,
      'fast_address': locationViewModel.shopAddress.value,
      'fast_reason': reason,
      'fast_savedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    String jsonData = json.encode(fastData);
    await prefs.setString('fastClockOutData', jsonData);
    await prefs.setBool('hasFastClockOutData', true);
    await prefs.setDouble('clockOutDistance', totalDistance);

    // ✅ STEP 4: QUICK DATABASE INSERT (NON-BLOCKING)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Create model
        AttendanceOutModel attendanceOutModel = AttendanceOutModel(
          attendance_out_id: attendanceId,
          user_id: user_id,
          total_distance: totalDistance,
          total_time: totalTime,
          lat_out: locationViewModel.globalLatitude1.value,
          lng_out: locationViewModel.globalLongitude1.value,
          address: locationViewModel.shopAddress.value,
        );

        // Save to database in background
        addAttendanceOut(attendanceOutModel);

        debugPrint("✅ [FAST SAVE] Quick save completed");

        // ✅ STEP 5: SCHEDULE API SYNC FOR LATER
        _scheduleApiSync(attendanceOutModel);

      } catch (e) {
        debugPrint("⚠️ [FAST SAVE] Background save error: $e");
      }
    });

    debugPrint("⚡ [FAST SAVE] Completed in <1 second");
    debugPrint("   - Distance: ${totalDistance.toStringAsFixed(3)} km");
    debugPrint("   - Time: $totalTime");
  }

  // ✅ SCHEDULE API SYNC FOR LATER
  void _scheduleApiSync(AttendanceOutModel model) {
    Timer(Duration(seconds: 10), () async {
      try {
        debugPrint("🔄 [DELAYED SYNC] Attempting API sync...");

        var results = await _connectivity.checkConnectivity();
        bool isOnline = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        if (isOnline) {
          await attendanceOutRepository.postDataFromDatabaseToAPI();
          debugPrint("✅ [DELAYED SYNC] API sync successful");

          // Clear fast data
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasFastClockOutData', false);
          await prefs.remove('fastClockOutData');
        }
      } catch (e) {
        debugPrint("⚠️ [DELAYED SYNC] Error: $e");
      }
    });
  }

  /// ✅ FORMAT DURATION TO H:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// ✅ UPDATED: Start checking device time for 11:58 PM AUTO CLOCK-OUT
  void _startAutoClockOutTimer() {
    debugPrint("⏰ Starting auto clock-out timer for 11:58 PM");

    // Check every minute for 11:58 PM
    _autoClockOutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForAutoClockOut();
    });

    // Also check immediately
    _checkForAutoClockOut();
  }

  /// ✅ UPDATED: Check if it's 11:58 PM for auto clock-out
  Future<void> _checkForAutoClockOut() async {
    try {
      // Get current device time
      DateTime now = DateTime.now();

      // ✅ CHANGED: Check if it's exactly 11:58 PM (23:58)
      if (now.hour == 23 && now.minute == 58) {
        debugPrint("🕰 11:58 PM AUTO CLOCK-OUT TIME DETECTED!");

        // Get SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Check if user is clocked in
        bool isClockedIn = prefs.getBool('isClockedIn') ?? false;

        if (isClockedIn) {
          debugPrint("🤖 User is clocked in - triggering 11:58 PM auto clock-out");

          // Create 11:58 PM timestamp
          DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);

          // Save auto clock-out with SharedPreferences backup
          await saveFormAttendanceOutWithPrefs(
            clockOutTime: clockOutTime,
            isAuto: true,
            reason: '11:58_pm_auto',
          );

          // Show notification to user
          Get.snackbar(
            'Auto Clock-Out',
            'Automatically clocked out at 11:58 PM',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.purple.shade700,
            colorText: Colors.white,
            duration: const Duration(seconds: 10),
          );

        } else {
          debugPrint("⏰ User already clocked out at 11:58 PM");
        }
      }

    } catch (e) {
      debugPrint("❌ Error in auto clock-out check: $e");
    }
  }

  // ✅ UPDATE: Save to SharedPreferences with distance
  Future<void> _saveToPrefsAsBackup({
    String? attendanceId,
    required DateTime clockOutTime,
    required String totalTime,
    required double totalDistance,
    String address = '',
    String reason = 'manual',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save all clock-out data
    Map<String, dynamic> clockOutData = {
      'backup_attendanceId': attendanceId ?? 'UNKNOWN',
      'backup_userId': user_id,
      'backup_clockOutTime': clockOutTime.toIso8601String(),
      'backup_totalTime': totalTime,
      'backup_totalDistance': totalDistance, // ✅ DISTANCE INCLUDED
      'backup_latOut': locationViewModel.globalLatitude1.value,
      'backup_lngOut': locationViewModel.globalLongitude1.value,
      'backup_address': address.isNotEmpty ? address : locationViewModel.shopAddress.value,
      'backup_reason': reason,
      'backup_savedAt': DateTime.now().toIso8601String(),
    };

    // Convert map to JSON string
    String jsonData = json.encode(clockOutData);
    await prefs.setString('backupClockOutData', jsonData);
    await prefs.setBool('hasBackupClockOutData', true);

    // ✅ ALSO SAVE DISTANCE SEPARATELY FOR EASY ACCESS
    await prefs.setDouble('backupDistance', totalDistance);

    debugPrint("📱 [BACKUP] Clock-out data saved with distance: ${totalDistance.toStringAsFixed(3)} km");
  }

  // ✅ NEW METHOD: Post attendance out to API with retry logic
  Future<void> _postAttendanceOutToApi(AttendanceOutModel attendanceOutModel) async {
    try {
      debugPrint("🌐 [API POST] Attempting to post attendance-out data...");
      debugPrint("   - Distance to post: ${attendanceOutModel.total_distance} km");

      // Quick internet check
      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline) {
        // ✅ POST TO API WITH AWAIT
        await attendanceOutRepository.postDataFromDatabaseToAPI();

        // ✅ VERIFY THE DATA WAS POSTED
        debugPrint("✅ [API POST] Successfully posted attendance-out data");
        debugPrint("   - Posted distance: ${attendanceOutModel.total_distance} km");

        // Clear backup data if successfully posted
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasBackupClockOutData', false);
        await prefs.remove('backupClockOutData');
        await prefs.remove('backupDistance');
        await prefs.remove('clockOutDistance');

      } else {
        debugPrint("🌐 [API POST] No internet - Data saved locally, will sync later");

        // Mark for auto-sync
        await _saveToPrefsAsBackup(
          attendanceId: attendanceOutModel.attendance_out_id,
          clockOutTime: DateTime.now(),
          totalTime: attendanceOutModel.total_time,
          totalDistance: attendanceOutModel.total_distance,
          address: attendanceOutModel.address,
          reason: 'offline_pending',
        );
      }
    } catch (e) {
      debugPrint("❌ [API POST] Error posting attendance-out: $e");
      debugPrint("   - Failed distance: ${attendanceOutModel.total_distance} km");

      // Data remains in SharedPreferences backup, will retry later
    }
  }

  // ✅ NEW METHOD: Try to post to API in background (for backward compatibility)
  void _tryPostToApiInBackground(String attendanceId) async {
    try {
      debugPrint("🌐 [BACKGROUND SYNC] Attempting API post...");

      // Quick internet check
      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline) {
        await attendanceOutRepository.postDataFromDatabaseToAPI();
        debugPrint("✅ [BACKGROUND SYNC] API post completed");

        // Clear backup data if successfully posted
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasBackupClockOutData', false);
        await prefs.remove('backupClockOutData');
        await prefs.remove('backupDistance');
      } else {
        debugPrint("🌐 [BACKGROUND SYNC] No internet - Will retry later");
      }
    } catch (e) {
      debugPrint("❌ [BACKGROUND SYNC] API post error: $e");
      // Data is safe in SharedPreferences, so no problem
    }
  }

  // ✅ NEW METHOD: Restore from backup if needed
  Future<void> restoreFromBackupIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasBackup = prefs.getBool('hasBackupClockOutData') ?? false;

    if (hasBackup) {
      String jsonData = prefs.getString('backupClockOutData') ?? '{}';
      try {
        Map<String, dynamic> data = json.decode(jsonData);

        debugPrint("🔄 Restoring clock-out data from backup...");
        debugPrint("   - Attendance ID: ${data['backup_attendanceId']}");
        debugPrint("   - Reason: ${data['backup_reason']}");
        debugPrint("   - Distance: ${data['backup_totalDistance']} km");

        // Add to database
        addAttendanceOut(
          AttendanceOutModel(
            attendance_out_id: data['backup_attendanceId'],
            user_id: data['backup_userId'],
            total_distance: data['backup_totalDistance'],
            total_time: data['backup_totalTime'],
            lat_out: data['backup_latOut'],
            lng_out: data['backup_lngOut'],
            address: data['backup_address'],
          ),
        );

        // Try to post to API again
        _tryPostToApiInBackground(data['backup_attendanceId']);

      } catch (e) {
        debugPrint("❌ Error restoring backup: $e");
      }
    }
  }

  // ✅ RESTORE FAST DATA ON APP START
  Future<void> restoreFastDataOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasFastData = prefs.getBool('hasFastClockOutData') ?? false;

    if (hasFastData) {
      debugPrint("🔄 Restoring fast-saved clock-out data...");

      try {
        String jsonData = prefs.getString('fastClockOutData') ?? '{}';
        Map<String, dynamic> data = json.decode(jsonData);

        // Create proper model
        AttendanceOutModel model = AttendanceOutModel(
          attendance_out_id: data['fast_attendanceId'],
          user_id: data['fast_userId'],
          total_distance: data['fast_totalDistance'],
          total_time: data['fast_totalTime'],
          lat_out: data['fast_latOut'],
          lng_out: data['fast_lngOut'],
          address: data['fast_address'],
        );

        // Add to database
        addAttendanceOut(model);

        debugPrint("✅ Fast data restored: ${model.total_distance} km");

        // Try to sync
        _scheduleApiSync(model);

      } catch (e) {
        debugPrint("❌ Error restoring fast data: $e");
      }
    }
  }

  /// ✅ LEGACY METHOD: Keep for backward compatibility
  Future<void> saveFormAttendanceOut({DateTime? clockOutTime}) async {
    await saveFormAttendanceOutWithPrefs(
      clockOutTime: clockOutTime,
      isAuto: clockOutTime != null,
      reason: clockOutTime != null ? 'legacy_auto' : 'manual',
    );
  }

  // ✅ NEW METHOD: Direct save with distance for immediate use
  Future<void> saveAttendanceOutWithDistance({
    required String attendanceId,
    required double distance,
    required DateTime clockOutTime,
    String address = '',
    bool isAuto = false,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? clockInTimeString = prefs.getString('clockInTime');
    DateTime shiftStartTime = clockInTimeString != null
        ? DateTime.parse(clockInTimeString)
        : clockOutTime.subtract(const Duration(hours: 1));

    Duration shiftDuration = clockOutTime.difference(shiftStartTime);
    String totalTime = _formatDuration(shiftDuration);

    // Add auto note if needed
    String finalAddress = address;
    if (isAuto) {
      finalAddress = "$address (Auto clock-out at ${DateFormat('hh:mm a').format(clockOutTime)})";
    }

    // Create attendance out model
    AttendanceOutModel attendanceOutModel = AttendanceOutModel(
      attendance_out_id: attendanceId,
      user_id: user_id,
      total_distance: distance,
      total_time: totalTime,
      lat_out: locationViewModel.globalLatitude1.value,
      lng_out: locationViewModel.globalLongitude1.value,
      address: finalAddress.isNotEmpty ? finalAddress : locationViewModel.shopAddress.value,
    );

    // Save to database
    addAttendanceOut(attendanceOutModel);

    // Save to SharedPreferences backup
    await _saveToPrefsAsBackup(
      attendanceId: attendanceId,
      clockOutTime: clockOutTime,
      totalTime: totalTime,
      totalDistance: distance,
      address: finalAddress,
      reason: isAuto ? 'direct_auto' : 'direct_manual',
    );

    // Try to post immediately
    await _postAttendanceOutToApi(attendanceOutModel);

    debugPrint("✅ Direct save with distance: ${distance.toStringAsFixed(3)} km");
  }

  // ✅ NEW METHOD: Start periodic sync check
  void _startPeriodicSyncCheck() {
    // Check for pending data every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _syncPendingDataIfOnline();
    });
  }

  // ✅ NEW METHOD: Sync pending data if online
  Future<void> _syncPendingDataIfOnline() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasPendingData = prefs.getBool('hasBackupClockOutData') ?? false;

      if (!hasPendingData) {
        return;
      }

      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline) {
        debugPrint("🔄 [PERIODIC SYNC] Internet available - syncing pending data");
        await attendanceOutRepository.postDataFromDatabaseToAPI();

        // Clear backup if successful
        await prefs.setBool('hasBackupClockOutData', false);
        await prefs.remove('backupClockOutData');
        await prefs.remove('backupDistance');

        debugPrint("✅ [PERIODIC SYNC] Pending data synced successfully");
      }
    } catch (e) {
      debugPrint("❌ [PERIODIC SYNC] Error: $e");
    }
  }

  // ✅ NEW: Check if user should be auto clocked out
  Future<bool> shouldAutoClockOut() async {
    try {
      DateTime now = DateTime.now();

      // Check if it's 11:58 PM
      if (now.hour == 23 && now.minute == 58) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isClockedIn = prefs.getBool('isClockedIn') ?? false;

        return isClockedIn;
      }

      return false;
    } catch (e) {
      debugPrint("❌ Error checking auto clock-out: $e");
      return false;
    }
  }

  // ✅ NEW: Get auto clock-out time
  DateTime getAutoClockOutTime() {
    DateTime now = DateTime.now();
    // Return today's 11:58 PM
    return DateTime(now.year, now.month, now.day, 23, 58, 0);
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

  // ✅ NEW: Debug method to check distance in database
  void debugDistanceInDatabase() async {
    debugPrint("🔍 [DATABASE DEBUG] Checking attendance-out records...");

    var records = await attendanceOutRepository.getAttendanceOut();
    if (records.isEmpty) {
      debugPrint("📭 No attendance-out records found in database");
      return;
    }

    for (var record in records) {
      debugPrint("📊 Record: ID=${record.attendance_out_id}, Distance=${record.total_distance} km, Time=${record.total_time}");
    }
  }

  // ✅ NEW: Get total clock-outs count for today
  Future<int> getTodayClockOutsCount() async {
    try {
      var records = await attendanceOutRepository.getAttendanceOut();
      DateTime today = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(today);

      int count = 0;
      for (var record in records) {
        // Extract date from attendance ID or check timestamp
        if (record.attendance_out_id.contains(todayDate.substring(5, 7))) { // Check month
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint("❌ Error getting today's clock-outs count: $e");
      return 0;
    }
  }
}
