// ///16-10-25
// import 'dart:async';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/attendance_Model.dart';
// import '../Repositories/attendance_repository.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class AttendanceViewModel extends GetxController {
//   var allAttendance = <AttendanceModel>[].obs;
//   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   // --- TIMER AND STATE VARIABLES ---
//   var isClockedIn = false.obs; // Tracks if the user is currently clocked in
//   DateTime? _clockInTime; // Stores the actual clock-in DateTime
//   Timer? _timer; // The timer object
//   var elapsedTime = '00:00:00'.obs; // Display string for elapsed time
//   var isLoading = false.obs;
//   // ---------------------------------
//
//   int attendanceInSerialCounter = 1;
//   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuserId = '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllAttendance();
//     _loadInitialClockState(); // Load clock state on init
//   }
//
//   // Handle disposal of the timer
//   @override
//   void onClose() {
//     _stopTimer();
//     super.onClose();
//   }
//
//   // LOCATION CHECK METHOD
//
//   Future<bool> isLocationAvailable() async {
//     try {
//       debugPrint("⚡ ULTRA-FAST location check - NO GPS WAITING");
//
//       // 1. INSTANT check if location service is enabled
//       bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
//
//       if (!isLocationEnabled) {
//         debugPrint("❌ Location is OFF - BLOCKING clock-in");
//         Get.snackbar(
//           'Location Required',
//           'Please turn on Location in device settings to clock in',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return false;
//       }
//
//       debugPrint("✅ Location is ON - PROCEEDING IMMEDIATELY");
//
//       // 2. SET COORDINATES TO ZERO IMMEDIATELY (no waiting)
//       LocationViewModel locationVM = Get.find<LocationViewModel>();
//       locationVM.globalLatitude1.value = 0.0;
//       locationVM.globalLongitude1.value = 0.0;
//
//       // 3. TRY TO GET COORDINATES IN BACKGROUND (fire and forget)
//       _tryGetCoordinatesInBackground();
//
//       return true; // ✅ ALWAYS ALLOW CLOCK-IN IF LOCATION IS ON
//
//     } catch (e) {
//       debugPrint("⚠ Location check error: $e - but ALLOWING clock-in");
//       // Even on error, allow clock-in
//       return true;
//     }
//   }
//
// // Fire and forget - never waits
//   void _tryGetCoordinatesInBackground() async {
//     try {
//       debugPrint("🛰 Background GPS attempt started...");
//
//       LocationViewModel locationVM = Get.find<LocationViewModel>();
//
//       // Try last known position first (with timeout)
//       Position? lastPosition = await Geolocator.getLastKnownPosition()
//           .timeout(Duration(seconds: 3), onTimeout: () {
//         debugPrint("⏰ Last known position timeout");
//         return null;
//       });
//
//       if (lastPosition != null && lastPosition.latitude != 0.0) {
//         debugPrint("📍 Background: Got last known coordinates");
//         locationVM.globalLatitude1.value = lastPosition.latitude;
//         locationVM.globalLongitude1.value = lastPosition.longitude;
//         return;
//       }
//
//       // Try current position (with timeout)
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.low,
//       ).timeout(Duration(seconds: 10), onTimeout: () {
//         debugPrint("⏰ Current position timeout");
//         throw TimeoutException("GPS timeout");
//       });
//
//       debugPrint("📍 Background: Got current coordinates");
//       locationVM.globalLatitude1.value = position.latitude;
//       locationVM.globalLongitude1.value = position.longitude;
//
//     } catch (e) {
//       debugPrint("⚠ Background GPS failed: $e");
//       // No problem - we already clocked in with zeros
//     }
//   }
//
//
//
//   // Future<bool> isLocationAvailable() async {
//   //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   //   if (!serviceEnabled) {
//   //     _showLocationRequiredDialog();
//   //     return false; // Block clock-in
//   //   }
//   //
//   //   LocationPermission permission = await Geolocator.checkPermission();
//   //   if (permission == LocationPermission.denied) {
//   //     permission = await Geolocator.requestPermission();
//   //   }
//   //
//   //   if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//   //     _showLocationRequiredDialog();
//   //     return false; // Block clock-in
//   //   }
//   //
//   //   try {
//   //     await Geolocator.getCurrentPosition(
//   //       desiredAccuracy: LocationAccuracy.high,
//   //     ).timeout(Duration(seconds: 5));
//   //   } catch (e) {
//   //     Get.snackbar(
//   //       "Location Error",
//   //       "Cannot determine your location. Please try again.",
//   //       snackPosition: SnackPosition.TOP,
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //     );
//   //     return false; // Block clock-in if position can't be obtained
//   //   }
//   //
//   //   return true; // ✅ Location available
//   // }
//
//   // Future<bool> isLocationAvailable() async {
//   //   try {
//   //     // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   //     // if (!serviceEnabled) {
//   //     //   debugPrint("❌ Location services disabled");
//   //     //   _showLocationRequiredDialog();
//   //     //   return false;
//   //     // }
//   //
//   //     LocationPermission permission = await Geolocator.checkPermission();
//   //     if (permission == LocationPermission.denied) {
//   //       debugPrint("❌ Location permission denied");
//   //       permission = await Geolocator.requestPermission();
//   //       if (permission != LocationPermission.whileInUse &&
//   //           permission != LocationPermission.always) {
//   //         _showLocationRequiredDialog();
//   //         return false;
//   //       }
//   //     } else if (permission == LocationPermission.deniedForever) {
//   //       debugPrint("❌ Location permission permanently denied");
//   //       _showLocationRequiredDialog();
//   //       return false;
//   //     }
//   //
//   //     try {
//   //       Position position = await Geolocator.getCurrentPosition(
//   //         desiredAccuracy: LocationAccuracy.high,
//   //       ).timeout(Duration(seconds: 5));
//   //
//   //       if (position.latitude == 0.0 && position.longitude == 0.0) {
//   //         debugPrint("❌ Invalid location coordinates");
//   //         return false;
//   //       }
//   //
//   //       debugPrint("✅ Location available: ${position.latitude}, ${position.longitude}");
//   //       return true;
//   //     } catch (e) {
//   //       debugPrint("❌ Cannot get current position: $e");
//   //       _showLocationRequiredDialog();
//   //       return false;
//   //     }
//   //   } catch (e) {
//   //     debugPrint("❌ Location check failed: $e");
//   //     _showLocationRequiredDialog();
//   //     return false;
//   //   }
//   // }
//
//
//   // LOCATION REQUIRED DIALOG
//   void _showLocationRequiredDialog() {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: AlertDialog(
//           title: Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
//                 SizedBox(height: 16),
//                 Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
//                 SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Device location'),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Location Accuracy'),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//               ],
//             ),
//           ),
//           actions: [
//             Container(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await Geolocator.openLocationSettings();
//                   Get.back();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('TURN ON'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   // --- TIMER METHODS ---
//
//   Future<void> _loadInitialClockState() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Check if there is a saved clock-in time
//     String? clockInTimeString = prefs.getString('clockInTime'); //
//
//     if (clockInTimeString != null) {
//       _clockInTime = DateTime.parse(clockInTimeString); //
//       isClockedIn.value = true; //
//       _startTimer(); // Resume the timer if clocked in
//     }
//   }
//
//   void _startTimer() {
//     if (_clockInTime == null) return;
//
//     // Cancel any existing timer to prevent duplicates
//     _timer?.cancel(); //
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       final now = DateTime.now();
//       final duration = now.difference(_clockInTime!); // Calculate duration
//
//       // Format the duration into H:mm:ss
//       String twoDigits(int n) => n.toString().padLeft(2, '0');
//       String hours = twoDigits(duration.inHours);
//       String minutes = twoDigits(duration.inMinutes.remainder(60));
//       String seconds = twoDigits(duration.inSeconds.remainder(60));
//
//       elapsedTime.value = '$hours:$minutes:$seconds'; // Update observable elapsed time
//
//       // Log every minute to verify timer is working
//       if (duration.inSeconds % 60 == 0) {
//         debugPrint("⏰ Attendance Timer: ${elapsedTime.value}");
//       }
//
//       // Saving total time to preferences for use in clock-out
//       _saveTotalTime(elapsedTime.value); //
//     });
//     debugPrint('✅ Attendance Timer started at: $_clockInTime');
//   }
//
//   void _stopTimer() {
//     _timer?.cancel(); //
//     _timer = null;
//     debugPrint('🛑 Attendance Timer stopped');
//   }
//
//   // Save total elapsed time for the AttendanceOutModel
//   Future<void> _saveTotalTime(String time) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('totalTime', time); //
//     debugPrint("✅ Saved total time to preferences: $time");
//   }
//
//   // Clear clock-in state when clocking out (to be called by the Clock-Out button/logic)
//   Future<void> clearClockInState() async {
//     _stopTimer(); //
//     isClockedIn.value = false; //
//     _clockInTime = null; //
//     elapsedTime.value = '00:00:00'; //
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('clockInTime'); //
//     await prefs.remove('attendanceId'); // Clear ID for next session
//     await prefs.remove('totalTime'); // Clear saved total time
//     await prefs.remove('totalDistance'); // Clear distance
//     await prefs.setInt('secondsPassed', 0); //
//     debugPrint("🔄 Clock-in state cleared");
//   }
//
//   // ---------------------------------
//
//   Future<void> _loadCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     attendanceInSerialCounter =
//         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
//     attendanceInCurrentMonth =
//         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
//     currentuserId = prefs.getString('currentuserId') ?? '';
//
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
//     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
//     await prefs.setString('currentuserId', currentuserId);
//   }
//
//   String generateNewAttendanceId(String userId) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     // If user changes, start from last known highest serial
//     if (currentuserId != userId) {
//       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
//       currentuserId = userId;
//     }
//
//     // Month change — reset counter
//     if (attendanceInCurrentMonth != currentMonth) {
//       attendanceInSerialCounter = 1;
//       attendanceInCurrentMonth = currentMonth;
//     }
//
//     // Example: ATD-VT0043-Oct-001
//     String attendanceId =
//         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
//
//     // Increment for next time
//     attendanceInSerialCounter++;
//     _saveCounter();
//
//     return attendanceId;
//   }
//
//   // ***************************************************************
//   // Internet Speed Check
//   // ***************************************************************
//   Future<String> _checkInternetSpeed() async {
//     try {
//       final response = await http.head(Uri.parse('https://www.google.com'))
//           .timeout(const Duration(seconds: 3));
//
//       if (response.statusCode == 200) {
//         return 'fast';
//       } else {
//         return 'slow';
//       }
//     } on TimeoutException {
//       return 'slow';
//     } on SocketException {
//       return 'none';
//     } catch (e) {
//       debugPrint('Internet check failed: $e');
//       return 'none';
//     }
//   }
//
//
//   Future<void> saveFormAttendanceIn() async {
//     if (isClockedIn.value) {
//       Get.snackbar(
//         'Already Clocked In',
//         'You are already clocked in. Current duration: ${elapsedTime.value}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     // ✅ Check location before anything else
//     bool locationAvailable = await isLocationAvailable();
//     if (!locationAvailable) {
//       debugPrint("❌ Clock-in blocked: Location not available");
//       return; // Stop here, don't start timer
//     }
//
//     // --- IMMEDIATELY SET CLOCK-IN STATE ---
//     _clockInTime = DateTime.now();
//     isClockedIn.value = true;
//     elapsedTime.value = '00:00:00';
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('clockInTime', _clockInTime!.toIso8601String());
//     _startTimer();
//
//     Get.snackbar(
//       'Clock-In Started',
//       'Clock-in in progress...',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//
//     // --- Continue with background tasks ---
//     isLoading.value = true;
//     try {
//       final internetStatus = await _checkInternetSpeed();
//       await _loadCounter();
//       final attendanceId = generateNewAttendanceId(user_id);
//       await prefs.setString('attendanceId', attendanceId);
//       await prefs.remove('totalDistance');
//       await prefs.setInt('secondsPassed', 0);
//
//       addAttendance(
//         AttendanceModel(
//           attendance_in_id: attendanceId,
//           user_id: user_id,
//           city: userCity,
//           booker_name: userName,
//           lat_in: locationViewModel.globalLatitude1.value,
//           lng_in: locationViewModel.globalLongitude1.value,
//           designation: userDesignation,
//           address: locationViewModel.shopAddress.value,
//         ),
//       );
//
//       if (internetStatus == 'fast') {
//         await attendanceRepository.postDataFromDatabaseToAPI();
//       }
//
//       Get.snackbar(
//         'Clock-In Successful',
//         'You are now clocked in.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Future<void> saveFormAttendanceIn() async {
//   //   isLoading.value = true;
//   //
//   //   try {
//   //     // 1. Location Check
//   //     bool locationAvailable = await isLocationAvailable();
//   //     if (!locationAvailable) {
//   //       debugPrint("❌ Clock-in blocked: Location not available");
//   //       return;
//   //     }
//   //     debugPrint("✅ Location available, proceeding with clock-in");
//   //
//   //     // 2. Prevent double clock-in
//   //     if (isClockedIn.value) {
//   //       Get.snackbar('Already Clocked In', 'You are already clocked in. Current duration: ${elapsedTime.value}',
//   //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
//   //       return;
//   //     }
//   //
//   //     // 3. Internet Check
//   //     final internetStatus = await _checkInternetSpeed();
//   //
//   //     if (internetStatus == 'none') {
//   //       Get.snackbar(
//   //         'Offline Mode',
//   //         'No internet connection detected. Clocking in offline.',
//   //         snackPosition: SnackPosition.TOP,
//   //         backgroundColor: Colors.blue.shade500,
//   //         colorText: Colors.white,
//   //         duration: const Duration(seconds: 8),
//   //       );
//   //     }
//   //
//   //     // 4. Generate ID and Save State
//   //     SharedPreferences prefs = await SharedPreferences.getInstance();
//   //     await _loadCounter();
//   //
//   //     // **FIX: Explicitly clear distance here to ensure the new shift starts at 0**
//   //     await prefs.remove('totalDistance');
//   //     await prefs.setInt('secondsPassed', 0);
//   //
//   //     final attendanceId = generateNewAttendanceId(user_id);
//   //     await prefs.setString('attendanceId', attendanceId);
//   //
//   //     // Set clock-in state and start timer
//   //     _clockInTime = DateTime.now(); //
//   //     isClockedIn.value = true; //
//   //     await prefs.setString('clockInTime', _clockInTime!.toIso8601String()); //
//   //     _startTimer(); //
//   //
//   //     // 5. Save to Local Database
//   //     addAttendance(
//   //       AttendanceModel(
//   //         attendance_in_id: attendanceId,
//   //         user_id: user_id,
//   //         city: userCity,
//   //         booker_name: userName,
//   //         // Assuming globalLatitude1 and globalLongitude1 are updated by LocationViewModel after a successful check
//   //         lat_in: locationViewModel.globalLatitude1.value,
//   //         lng_in: locationViewModel.globalLongitude1.value,
//   //         designation: userDesignation,
//   //         address: locationViewModel.shopAddress.value,
//   //       ),
//   //     );
//   //
//   //     // 6. Post to API if internet is fast
//   //     if (internetStatus == 'fast') {
//   //       await attendanceRepository.postDataFromDatabaseToAPI();
//   //     } else {
//   //       debugPrint('Skipping API post. Internet status: $internetStatus');
//   //     }
//   //
//   //     // 7. Success Notification
//   //     Get.snackbar(
//   //       'Clock-In Successful',
//   //       'You are now clocked in.',
//   //       snackPosition: SnackPosition.TOP,
//   //       backgroundColor: Colors.green,
//   //       colorText: Colors.white,
//   //     );
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
//
//   Future<void> fetchAllAttendance() async {
//     var attendance = await attendanceRepository.getAttendance();
//     allAttendance.value = attendance;
//   }
//
//   void addAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.add(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void updateAttendance(AttendanceModel attendanceModel) {
//     attendanceRepository.update(attendanceModel);
//     fetchAllAttendance();
//   }
//
//   void deleteAttendance(String id) {
//     attendanceRepository.delete(id);
//     fetchAllAttendance();
//   }
//
//   Future<void> serialCounterGet() async {
//     await attendanceRepository.serialNumberGeneratorApi();
//   }
// }
//
//
//
//
//
// // ///16-10-25  yh code bhi thik hai
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:intl/intl.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Models/attendance_Model.dart';
// // import '../Repositories/attendance_repository.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class AttendanceViewModel extends GetxController {
// //   var allAttendance = <AttendanceModel>[].obs;
// //   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //
// //   // --- TIMER AND STATE VARIABLES ---
// //   var isClockedIn = false.obs; // Tracks if the user is currently clocked in
// //   DateTime? _clockInTime; // Stores the actual clock-in DateTime
// //   Timer? _timer; // The timer object
// //   var elapsedTime = '00:00:00'.obs; // Display string for elapsed time
// //   var isLoading = false.obs;
// //   // ---------------------------------
// //
// //   int attendanceInSerialCounter = 1;
// //   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
// //   String currentuserId = '';
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchAllAttendance();
// //     _loadInitialClockState(); // Load clock state on init
// //   }
// //
// //   // Handle disposal of the timer
// //   @override
// //   void onClose() {
// //     _stopTimer();
// //     super.onClose();
// //   }
// //   Future<bool> isLocationAvailable() async {
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       _showLocationRequiredDialog();
// //       return false; // Block clock-in
// //     }
// //
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //     }
// //
// //     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
// //       _showLocationRequiredDialog();
// //       return false; // Block clock-in
// //     }
// //
// //     try {
// //       await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       ).timeout(Duration(seconds: 5));
// //     } catch (e) {
// //       Get.snackbar(
// //         "Location Error",
// //         "Cannot determine your location. Please try again.",
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //       );
// //       return false; // Block clock-in if position can't be obtained
// //     }
// //
// //     return true; // ✅ Location available
// //   }
// //
// //   // LOCATION CHECK METHOD
// //   // Future<bool> isLocationAvailable() async {
// //   //   try {
// //   //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //   //     if (!serviceEnabled) {
// //   //       // ✅ Just warn the user, don’t block clock-in
// //   //       Get.snackbar(
// //   //         "Location Warning",
// //   //         "Device location is off. Clocking in offline.",
// //   //         snackPosition: SnackPosition.TOP,
// //   //         backgroundColor: Colors.red,
// //   //         colorText: Colors.white,
// //   //         duration: const Duration(seconds: 5),
// //   //       );
// //   //       // ❌ Don't return false
// //   //       serviceEnabled = false;
// //   //     }
// //   //
// //   //     LocationPermission permission = await Geolocator.checkPermission();
// //   //     if (permission == LocationPermission.denied) {
// //   //       permission = await Geolocator.requestPermission();
// //   //       if (permission != LocationPermission.whileInUse &&
// //   //           permission != LocationPermission.always) {
// //   //         // ✅ Just warn, don’t block
// //   //         Get.snackbar(
// //   //           "Location Warning",
// //   //           "Location permission denied. Clocking in offline.",
// //   //           snackPosition: SnackPosition.TOP,
// //   //           backgroundColor: Colors.orange,
// //   //           colorText: Colors.white,
// //   //           duration: const Duration(seconds: 5),
// //   //         );
// //   //       }
// //   //     } else if (permission == LocationPermission.deniedForever) {
// //   //       Get.snackbar(
// //   //         "Location Warning",
// //   //         "Location permission permanently denied. Clocking in offline.",
// //   //         snackPosition: SnackPosition.TOP,
// //   //         backgroundColor: Colors.red,
// //   //         colorText: Colors.white,
// //   //         duration: const Duration(seconds: 5),
// //   //       );
// //   //     }
// //   //
// //   //     // Try to get position but ignore failure in offline mode
// //   //     try {
// //   //       Position position = await Geolocator.getCurrentPosition(
// //   //         desiredAccuracy: LocationAccuracy.high,
// //   //       ).timeout(Duration(seconds: 5));
// //   //       debugPrint("✅ Location available: ${position.latitude}, ${position.longitude}");
// //   //     } catch (e) {
// //   //       debugPrint("⚠️ Cannot get precise location: $e");
// //   //     }
// //   //
// //   //     return true; // ✅ Always return true for offline clock-in
// //   //   } catch (e) {
// //   //     debugPrint("⚠️ Location check failed: $e");
// //   //     return true; // ✅ Always allow
// //   //   }
// //   // }
// //
// //
// //
// //   // LOCATION REQUIRED DIALOG
// //   void _showLocationRequiredDialog() {
// //     Get.dialog(
// //       WillPopScope(
// //         onWillPop: () async => false,
// //         child: AlertDialog(
// //           title: Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
// //                 SizedBox(height: 16),
// //                 Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
// //                 SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
// //                     SizedBox(width: 8),
// //                     Text('Device location'),
// //                   ],
// //                 ),
// //                 Row(
// //                   children: [
// //                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
// //                     SizedBox(width: 8),
// //                     Text('Location Accuracy'),
// //                   ],
// //                 ),
// //                 SizedBox(height: 12),
// //                 Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             Container(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: () async {
// //                   await Geolocator.openLocationSettings();
// //                   Get.back();
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue,
// //                   foregroundColor: Colors.white,
// //                 ),
// //                 child: Text('TURN ON'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       barrierDismissible: false,
// //     );
// //   }
// //
// //   // --- TIMER METHODS ---
// //
// //   Future<void> _loadInitialClockState() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     // Check if there is a saved clock-in time
// //     String? clockInTimeString = prefs.getString('clockInTime'); //
// //
// //     if (clockInTimeString != null) {
// //       _clockInTime = DateTime.parse(clockInTimeString); //
// //       isClockedIn.value = true; //
// //       _startTimer(); // Resume the timer if clocked in
// //     }
// //   }
// //
// //   void _startTimer() {
// //     if (_clockInTime == null) return;
// //
// //     // Cancel any existing timer to prevent duplicates
// //     _timer?.cancel(); //
// //
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       final now = DateTime.now();
// //       final duration = now.difference(_clockInTime!); // Calculate duration
// //
// //       // Format the duration into H:mm:ss
// //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// //       String hours = twoDigits(duration.inHours);
// //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// //
// //       elapsedTime.value = '$hours:$minutes:$seconds'; // Update observable elapsed time
// //
// //       // Log every minute to verify timer is working
// //       if (duration.inSeconds % 60 == 0) {
// //         debugPrint("⏰ Attendance Timer: ${elapsedTime.value}");
// //       }
// //
// //       // Saving total time to preferences for use in clock-out
// //       _saveTotalTime(elapsedTime.value); //
// //     });
// //     debugPrint('✅ Attendance Timer started at: $_clockInTime');
// //   }
// //
// //   void _stopTimer() {
// //     _timer?.cancel(); //
// //     _timer = null;
// //     debugPrint('🛑 Attendance Timer stopped');
// //   }
// //
// //   // Save total elapsed time for the AttendanceOutModel
// //   Future<void> _saveTotalTime(String time) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('totalTime', time); //
// //     debugPrint("✅ Saved total time to preferences: $time");
// //   }
// //
// //   // Clear clock-in state when clocking out (to be called by the Clock-Out button/logic)
// //   Future<void> clearClockInState() async {
// //     _stopTimer(); //
// //     isClockedIn.value = false; //
// //     _clockInTime = null; //
// //     elapsedTime.value = '00:00:00'; //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('clockInTime'); //
// //     await prefs.remove('attendanceId'); // Clear ID for next session
// //     await prefs.remove('totalTime'); // Clear saved total time
// //     await prefs.remove('totalDistance'); // Clear distance
// //     await prefs.setInt('secondsPassed', 0); //
// //     debugPrint("🔄 Clock-in state cleared");
// //   }
// //
// //   // ---------------------------------
// //
// //   Future<void> _loadCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     attendanceInSerialCounter =
// //         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
// //     attendanceInCurrentMonth =
// //         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
// //     currentuserId = prefs.getString('currentuserId') ?? '';
// //
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
// //   }
// //
// //   Future<void> _saveCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
// //     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
// //     await prefs.setString('currentuserId', currentuserId);
// //   }
// //
// //   String generateNewAttendanceId(String userId) {
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     // If user changes, start from last known highest serial
// //     if (currentuserId != userId) {
// //       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
// //       currentuserId = userId;
// //     }
// //
// //     // Month change — reset counter
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     // Example: ATD-VT0043-Oct-001
// //     String attendanceId =
// //         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
// //
// //     // Increment for next time
// //     attendanceInSerialCounter++;
// //     _saveCounter();
// //
// //     return attendanceId;
// //   }
// //
// //   // ***************************************************************
// //   // Internet Speed Check
// //   // ***************************************************************
// //   Future<String> _checkInternetSpeed() async {
// //     try {
// //       final response = await http.head(Uri.parse('https://www.google.com'))
// //           .timeout(const Duration(seconds: 3));
// //
// //       if (response.statusCode == 200) {
// //         return 'fast';
// //       } else {
// //         return 'slow';
// //       }
// //     } on TimeoutException {
// //       return 'slow';
// //     } on SocketException {
// //       return 'none';
// //     } catch (e) {
// //       debugPrint('Internet check failed: $e');
// //       return 'none';
// //     }
// //   }
// //   Future<void> saveFormAttendanceIn() async {
// //     if (isClockedIn.value) {
// //       Get.snackbar(
// //         'Already Clocked In',
// //         'You are already clocked in. Current duration: ${elapsedTime.value}',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //       );
// //       return;
// //     }
// //
// //     // ✅ Check location before anything else
// //     bool locationAvailable = await isLocationAvailable();
// //     if (!locationAvailable) {
// //       debugPrint("❌ Clock-in blocked: Location not available");
// //       return; // Stop here, don't start timer
// //     }
// //
// //     // --- IMMEDIATELY SET CLOCK-IN STATE ---
// //     _clockInTime = DateTime.now();
// //     isClockedIn.value = true;
// //     elapsedTime.value = '00:00:00';
// //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('clockInTime', _clockInTime!.toIso8601String());
// //     _startTimer();
// //
// //     Get.snackbar(
// //       'Clock-In Started',
// //       'Clock-in in progress...',
// //       snackPosition: SnackPosition.TOP,
// //       backgroundColor: Colors.green,
// //       colorText: Colors.white,
// //     );
// //
// //     // --- Continue with background tasks ---
// //     isLoading.value = true;
// //     try {
// //       final internetStatus = await _checkInternetSpeed();
// //       await _loadCounter();
// //       final attendanceId = generateNewAttendanceId(user_id);
// //       await prefs.setString('attendanceId', attendanceId);
// //       await prefs.remove('totalDistance');
// //       await prefs.setInt('secondsPassed', 0);
// //
// //       addAttendance(
// //         AttendanceModel(
// //           attendance_in_id: attendanceId,
// //           user_id: user_id,
// //           city: userCity,
// //           booker_name: userName,
// //           lat_in: locationViewModel.globalLatitude1.value,
// //           lng_in: locationViewModel.globalLongitude1.value,
// //           designation: userDesignation,
// //           address: locationViewModel.shopAddress.value,
// //         ),
// //       );
// //
// //       if (internetStatus == 'fast') {
// //         await attendanceRepository.postDataFromDatabaseToAPI();
// //       }
// //
// //       Get.snackbar(
// //         'Clock-In Successful',
// //         'You are now clocked in.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //       );
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }
// //
// //   // Future<void> saveFormAttendanceIn() async {
// //   //   if (isClockedIn.value) {
// //   //     Get.snackbar(
// //   //       'Already Clocked In',
// //   //       'You are already clocked in. Current duration: ${elapsedTime.value}',
// //   //       snackPosition: SnackPosition.TOP,
// //   //       backgroundColor: Colors.green,
// //   //       colorText: Colors.white,
// //   //     );
// //   //     return;
// //   //   }
// //   //
// //   //   // --- IMMEDIATELY SET CLOCK-IN STATE ---
// //   //   _clockInTime = DateTime.now();
// //   //   isClockedIn.value = true;
// //   //   elapsedTime.value = '00:00:00';
// //   //
// //   //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //   //   await prefs.setString('clockInTime', _clockInTime!.toIso8601String());
// //   //   _startTimer();
// //   //
// //   //   Get.snackbar(
// //   //     'Clock-In Started',
// //   //     'Clock-in in progress...',
// //   //     snackPosition: SnackPosition.TOP,
// //   //     backgroundColor: Colors.green,
// //   //     colorText: Colors.white,
// //   //   );
// //   //
// //   //   // --- DO BACKGROUND OPERATIONS WITHOUT BLOCKING UI ---
// //   //   isLoading.value = true;
// //   //   try {
// //   //     // 1. Location (best effort)
// //   //     await isLocationAvailable();
// //   //
// //   //     // 2. Internet check
// //   //     final internetStatus = await _checkInternetSpeed();
// //   //
// //   //     // 3. Counter & attendance ID
// //   //     await _loadCounter();
// //   //     final attendanceId = generateNewAttendanceId(user_id);
// //   //     await prefs.setString('attendanceId', attendanceId);
// //   //     await prefs.remove('totalDistance');
// //   //     await prefs.setInt('secondsPassed', 0);
// //   //
// //   //     // 4. Save to local DB
// //   //     addAttendance(
// //   //       AttendanceModel(
// //   //         attendance_in_id: attendanceId,
// //   //         user_id: user_id,
// //   //         city: userCity,
// //   //         booker_name: userName,
// //   //         lat_in: locationViewModel.globalLatitude1.value,
// //   //         lng_in: locationViewModel.globalLongitude1.value,
// //   //         designation: userDesignation,
// //   //         address: locationViewModel.shopAddress.value,
// //   //       ),
// //   //     );
// //   //
// //   //     // 5. Post to API if online
// //   //     if (internetStatus == 'fast') {
// //   //       await attendanceRepository.postDataFromDatabaseToAPI();
// //   //     }
// //   //
// //   //     Get.snackbar(
// //   //       'Clock-In Successful',
// //   //       'You are now clocked in.',
// //   //       snackPosition: SnackPosition.TOP,
// //   //       backgroundColor: Colors.green,
// //   //       colorText: Colors.white,
// //   //     );
// //   //   } finally {
// //   //     isLoading.value = false;
// //   //   }
// //   // }
// //
// //
// //   // Future<void> saveFormAttendanceIn() async {
// //   //   isLoading.value = true;
// //   //
// //   //   try {
// //   //     // 1. Location Check
// //   //     bool locationAvailable = await isLocationAvailable();
// //   //     if (!locationAvailable) {
// //   //       debugPrint("❌ Clock-in blocked: Location not available");
// //   //       return;
// //   //     }
// //   //     debugPrint("✅ Location available, proceeding with clock-in");
// //   //
// //   //     // 2. Prevent double clock-in
// //   //     if (isClockedIn.value) {
// //   //       Get.snackbar('Already Clocked In', 'You are already clocked in. Current duration: ${elapsedTime.value}',
// //   //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
// //   //       return;
// //   //     }
// //   //
// //   //     // 3. Internet Check
// //   //     final internetStatus = await _checkInternetSpeed();
// //   //
// //   //     if (internetStatus == 'none') {
// //   //       Get.snackbar(
// //   //         'Offline Mode',
// //   //         'No internet connection detected. Clocking in offline.',
// //   //         snackPosition: SnackPosition.TOP,
// //   //         backgroundColor: Colors.blue.shade500,
// //   //         colorText: Colors.white,
// //   //         duration: const Duration(seconds: 8),
// //   //       );
// //   //     }
// //   //
// //   //     // 4. Generate ID and Save State
// //   //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //   //     await _loadCounter();
// //   //
// //   //     // **FIX: Explicitly clear distance here to ensure the new shift starts at 0**
// //   //     await prefs.remove('totalDistance');
// //   //     await prefs.setInt('secondsPassed', 0);
// //   //
// //   //     final attendanceId = generateNewAttendanceId(user_id);
// //   //     await prefs.setString('attendanceId', attendanceId);
// //   //
// //   //     // Set clock-in state and start timer
// //   //     _clockInTime = DateTime.now(); //
// //   //     isClockedIn.value = true; //
// //   //     await prefs.setString('clockInTime', _clockInTime!.toIso8601String()); //
// //   //     _startTimer(); //
// //   //
// //   //     // 5. Save to Local Database
// //   //     addAttendance(
// //   //       AttendanceModel(
// //   //         attendance_in_id: attendanceId,
// //   //         user_id: user_id,
// //   //         city: userCity,
// //   //         booker_name: userName,
// //   //         // Assuming globalLatitude1 and globalLongitude1 are updated by LocationViewModel after a successful check
// //   //         lat_in: locationViewModel.globalLatitude1.value,
// //   //         lng_in: locationViewModel.globalLongitude1.value,
// //   //         designation: userDesignation,
// //   //         address: locationViewModel.shopAddress.value,
// //   //       ),
// //   //     );
// //   //
// //   //     // 6. Post to API if internet is fast
// //   //     if (internetStatus == 'fast') {
// //   //       await attendanceRepository.postDataFromDatabaseToAPI();
// //   //     } else {
// //   //       debugPrint('Skipping API post. Internet status: $internetStatus');
// //   //     }
// //   //
// //   //     // 7. Success Notification
// //   //     Get.snackbar(
// //   //       'Clock-In Successful',
// //   //       'You are now clocked in.',
// //   //       snackPosition: SnackPosition.TOP,
// //   //       backgroundColor: Colors.green,
// //   //       colorText: Colors.white,
// //   //     );
// //   //   } finally {
// //   //     isLoading.value = false;
// //   //   }
// //   // }
// //
// //   Future<void> fetchAllAttendance() async {
// //     var attendance = await attendanceRepository.getAttendance();
// //     allAttendance.value = attendance;
// //   }
// //
// //   void addAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.add(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void updateAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.update(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void deleteAttendance(String id) {
// //     attendanceRepository.delete(id);
// //     fetchAllAttendance();
// //   }
// //
// //   Future<void> serialCounterGet() async {
// //     await attendanceRepository.serialNumberGeneratorApi();
// //   }
// // }
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:intl/intl.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Models/attendance_Model.dart';
// // import '../Repositories/attendance_repository.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class AttendanceViewModel extends GetxController {
// //   var allAttendance = <AttendanceModel>[].obs;
// //   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //
// //   // --- TIMER AND STATE VARIABLES ---
// //   var isClockedIn = false.obs; // Tracks if the user is currently clocked in
// //   DateTime? _clockInTime; // Stores the actual clock-in DateTime
// //   Timer? _timer; // The timer object
// //   var elapsedTime = '00:00:00'.obs; // Display string for elapsed time
// //   // ---------------------------------
// //
// //   int attendanceInSerialCounter = 1;
// //   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
// //   String currentuserId = '';
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchAllAttendance();
// //     _loadInitialClockState(); // Load clock state on init
// //   }
// //
// //   // Handle disposal of the timer
// //   @override
// //   void onClose() {
// //     _stopTimer();
// //     super.onClose();
// //   }
// //
// //   // --- TIMER METHODS ---
// //
// //   Future<void> _loadInitialClockState() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     // Check if there is a saved clock-in time
// //     String? clockInTimeString = prefs.getString('clockInTime'); //
// //
// //     if (clockInTimeString != null) {
// //       _clockInTime = DateTime.parse(clockInTimeString); //
// //       isClockedIn.value = true; //
// //       _startTimer(); // Resume the timer if clocked in
// //     }
// //   }
// //
// //   void _startTimer() {
// //     if (_clockInTime == null) return;
// //
// //     // Cancel any existing timer to prevent duplicates
// //     _timer?.cancel(); //
// //
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       final now = DateTime.now();
// //       final duration = now.difference(_clockInTime!); // Calculate duration
// //
// //       // Format the duration into H:mm:ss
// //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// //       String hours = twoDigits(duration.inHours);
// //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// //
// //       elapsedTime.value = '$hours:$minutes:$seconds'; // Update observable elapsed time
// //
// //       // Saving total time to preferences for use in clock-out
// //       _saveTotalTime(elapsedTime.value); //
// //     });
// //     debugPrint('Timer started.');
// //   }
// //
// //   void _stopTimer() {
// //     _timer?.cancel(); //
// //     _timer = null;
// //     debugPrint('Timer stopped.');
// //   }
// //
// //   // Save total elapsed time for the AttendanceOutModel
// //   Future<void> _saveTotalTime(String time) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('totalTime', time); //
// //   }
// //
// //   // Clear clock-in state when clocking out (to be called by the Clock-Out button/logic)
// //   Future<void> clearClockInState() async {
// //     _stopTimer(); //
// //     isClockedIn.value = false; //
// //     _clockInTime = null; //
// //     elapsedTime.value = '00:00:00'; //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('clockInTime'); //
// //     await prefs.remove('attendanceId'); // Clear ID for next session
// //     await prefs.remove('totalTime'); // Clear saved total time
// //     await prefs.remove('totalDistance'); // Clear distance
// //   }
// //
// //   // ---------------------------------
// //
// //   Future<void> _loadCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     attendanceInSerialCounter =
// //         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
// //     attendanceInCurrentMonth =
// //         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
// //     currentuserId = prefs.getString('currentuserId') ?? '';
// //
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
// //   }
// //
// //   Future<void> _saveCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
// //     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
// //     await prefs.setString('currentuserId', currentuserId);
// //   }
// //
// //   String generateNewAttendanceId(String userId) {
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     // If user changes, start from last known highest serial
// //     if (currentuserId != userId) {
// //       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
// //       currentuserId = userId;
// //     }
// //
// //     // Month change — reset counter
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     // Example: ATD-VT0043-Oct-001
// //     String attendanceId =
// //         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
// //
// //     // Increment for next time
// //     attendanceInSerialCounter++;
// //     _saveCounter();
// //
// //     return attendanceId;
// //   }
// //
// //   // ***************************************************************
// //   // Internet Speed Check
// //   // ***************************************************************
// //   Future<String> _checkInternetSpeed() async {
// //     try {
// //       final response = await http.head(Uri.parse('https://www.google.com'))
// //           .timeout(const Duration(seconds: 3));
// //
// //       if (response.statusCode == 200) {
// //         return 'fast';
// //       } else {
// //         return 'slow';
// //       }
// //     } on TimeoutException {
// //       return 'slow';
// //     } on SocketException {
// //       return 'none';
// //     } catch (e) {
// //       debugPrint('Internet check failed: $e');
// //       return 'none';
// //     }
// //   }
// //
// //   Future<void> saveFormAttendanceIn() async {
// //     // Prevent double clock-in
// //     if (isClockedIn.value) {
// //       Get.snackbar('Already Clocked In', 'You are already clocked in. Current duration: ${elapsedTime.value}',
// //           snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
// //       return;
// //     }
// //
// //     final internetStatus = await _checkInternetSpeed();
// //
// //     if (internetStatus == 'none') {
// //       Get.snackbar(
// //         'Offline Mode',
// //         'No internet connection detected. Clocking in offline.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.blue.shade500,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 8),
// //       );
// //     } else if (internetStatus == 'slow') {
// //       Get.snackbar(
// //         'Internet Slow ⚠️',
// //         'Your internet is slow. Please find a faster network or turn off internet to clock-in offline.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 10),
// //       );
// //       return;
// //     }
// //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await _loadCounter();
// //
// //     final attendanceId = generateNewAttendanceId(user_id);
// //     await prefs.setString('attendanceId', attendanceId);
// //
// //     // Set clock-in state and start timer
// //     _clockInTime = DateTime.now(); //
// //     isClockedIn.value = true; //
// //     await prefs.setString('clockInTime', _clockInTime!.toIso8601String()); //
// //     _startTimer(); //
// //
// //     addAttendance(
// //       AttendanceModel(
// //         attendance_in_id: attendanceId,
// //         user_id: user_id,
// //         city: userCity,
// //         booker_name: userName,
// //         lat_in: locationViewModel.globalLatitude1.value,
// //         lng_in: locationViewModel.globalLongitude1.value,
// //         designation: userDesignation,
// //         address: locationViewModel.shopAddress.value,
// //       ),
// //     );
// //
// //     if (internetStatus == 'fast') {
// //       await attendanceRepository.postDataFromDatabaseToAPI();
// //     } else {
// //       debugPrint('Skipping API post. Internet status: $internetStatus');
// //     }
// //
// //     Get.snackbar(
// //       'Clock-In Successful',
// //       'You are now clocked in.',
// //       snackPosition: SnackPosition.TOP,
// //       backgroundColor: Colors.green,
// //       colorText: Colors.white,
// //     );
// //   }
// //
// //   Future<void> fetchAllAttendance() async {
// //     var attendance = await attendanceRepository.getAttendance();
// //     allAttendance.value = attendance;
// //   }
// //
// //   void addAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.add(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void updateAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.update(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void deleteAttendance(String id) {
// //     attendanceRepository.delete(id);
// //     fetchAllAttendance();
// //   }
// //
// //   Future<void> serialCounterGet() async {
// //     await attendanceRepository.serialNumberGeneratorApi();
// //   }
// // }
// // attendance_view_model.dart
//
//
//
//
// ///16-10-25
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:geolocator/geolocator.dart'; // <--- Added from first block
// // import 'package:intl/intl.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Models/attendance_Model.dart';
// // import '../Repositories/attendance_repository.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class AttendanceViewModel extends GetxController {
// //   var allAttendance = <AttendanceModel>[].obs;
// //   final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //
// //   // --- TIMER AND STATE VARIABLES ---
// //   var isClockedIn = false.obs; // Tracks if the user is currently clocked in
// //   DateTime? _clockInTime; // Stores the actual clock-in DateTime
// //   Timer? _timer; // The timer object
// //   var elapsedTime = '00:00:00'.obs; // Display string for elapsed time
// //   var isLoading = false.obs; // <--- Added from first block
// //   // ---------------------------------
// //
// //   int attendanceInSerialCounter = 1;
// //   String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
// //   String currentuserId = '';
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchAllAttendance();
// //     _loadInitialClockState(); // Load clock state on init
// //   }
// //
// //   // Handle disposal of the timer
// //   @override
// //   void onClose() {
// //     _stopTimer();
// //     super.onClose();
// //   }
// //
// //   // LOCATION CHECK METHOD <--- Added from first block
// //   Future<bool> isLocationAvailable() async {
// //     try {
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         debugPrint("❌ Location services disabled");
// //         _showLocationRequiredDialog();
// //         return false;
// //       }
// //
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         debugPrint("❌ Location permission denied");
// //         permission = await Geolocator.requestPermission();
// //         if (permission != LocationPermission.whileInUse &&
// //             permission != LocationPermission.always) {
// //           _showLocationRequiredDialog();
// //           return false;
// //         }
// //       } else if (permission == LocationPermission.deniedForever) {
// //         debugPrint("❌ Location permission permanently denied");
// //         _showLocationRequiredDialog();
// //         return false;
// //       }
// //
// //       try {
// //         Position position = await Geolocator.getCurrentPosition(
// //           desiredAccuracy: LocationAccuracy.high,
// //         ).timeout(Duration(seconds: 5));
// //
// //         if (position.latitude == 0.0 && position.longitude == 0.0) {
// //           debugPrint("❌ Invalid location coordinates");
// //           return false;
// //         }
// //
// //         debugPrint("✅ Location available: ${position.latitude}, ${position.longitude}");
// //         return true;
// //       } catch (e) {
// //         debugPrint("❌ Cannot get current position: $e");
// //         _showLocationRequiredDialog();
// //         return false;
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Location check failed: $e");
// //       _showLocationRequiredDialog();
// //       return false;
// //     }
// //   }
// //
// //   // LOCATION REQUIRED DIALOG <--- Added from first block
// //   void _showLocationRequiredDialog() {
// //     Get.dialog(
// //       WillPopScope(
// //         onWillPop: () async => false,
// //         child: AlertDialog(
// //           title: Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
// //                 SizedBox(height: 16),
// //                 Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
// //                 SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
// //                     SizedBox(width: 8),
// //                     Text('Device location'),
// //                   ],
// //                 ),
// //                 Row(
// //                   children: [
// //                     Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
// //                     SizedBox(width: 8),
// //                     Text('Location Accuracy'),
// //                   ],
// //                 ),
// //                 SizedBox(height: 12),
// //                 Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             Container(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: () async {
// //                   await Geolocator.openLocationSettings();
// //                   Get.back();
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue,
// //                   foregroundColor: Colors.white,
// //                 ),
// //                 child: Text('TURN ON'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       barrierDismissible: false,
// //     );
// //   }
// //
// //   // --- TIMER METHODS ---
// //
// //   Future<void> _loadInitialClockState() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     // Check if there is a saved clock-in time
// //     String? clockInTimeString = prefs.getString('clockInTime'); //
// //
// //     if (clockInTimeString != null) {
// //       _clockInTime = DateTime.parse(clockInTimeString); //
// //       isClockedIn.value = true; //
// //       _startTimer(); // Resume the timer if clocked in
// //     }
// //   }
// //
// //   void _startTimer() {
// //     if (_clockInTime == null) return;
// //
// //     // Cancel any existing timer to prevent duplicates
// //     _timer?.cancel(); //
// //
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       final now = DateTime.now();
// //       final duration = now.difference(_clockInTime!); // Calculate duration
// //
// //       // Format the duration into H:mm:ss
// //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// //       String hours = twoDigits(duration.inHours);
// //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// //
// //       elapsedTime.value = '$hours:$minutes:$seconds'; // Update observable elapsed time
// //
// //       // Log every minute to verify timer is working
// //       if (duration.inSeconds % 60 == 0) { // <--- Added log from first block
// //         debugPrint("⏰ Attendance Timer: ${elapsedTime.value}");
// //       }
// //
// //       // Saving total time to preferences for use in clock-out
// //       _saveTotalTime(elapsedTime.value); //
// //     });
// //     debugPrint('✅ Attendance Timer started at: $_clockInTime'); // <--- Updated log
// //   }
// //
// //   void _stopTimer() {
// //     _timer?.cancel(); //
// //     _timer = null;
// //     debugPrint('🛑 Attendance Timer stopped'); // <--- Updated log
// //   }
// //
// //   // Save total elapsed time for the AttendanceOutModel
// //   Future<void> _saveTotalTime(String time) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('totalTime', time); //
// //     debugPrint("✅ Saved total time to preferences: $time"); // <--- Added log
// //   }
// //
// //   // Clear clock-in state when clocking out (to be called by the Clock-Out button/logic)
// //   Future<void> clearClockInState() async {
// //     _stopTimer(); //
// //     isClockedIn.value = false; //
// //     _clockInTime = null; //
// //     elapsedTime.value = '00:00:00'; //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('clockInTime'); //
// //     await prefs.remove('attendanceId'); // Clear ID for next session
// //     await prefs.remove('totalTime'); // Clear saved total time
// //     await prefs.remove('totalDistance'); // Clear distance
// //     await prefs.setInt('secondsPassed', 0); // <--- Added from first block
// //     debugPrint("🔄 Clock-in state cleared"); // <--- Added log
// //   }
// //
// //   // ---------------------------------
// //
// //   Future<void> _loadCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     attendanceInSerialCounter =
// //         prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
// //     attendanceInCurrentMonth =
// //         prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
// //     currentuserId = prefs.getString('currentuserId') ?? '';
// //
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
// //   }
// //
// //   Future<void> _saveCounter() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
// //     await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
// //     await prefs.setString('currentuserId', currentuserId);
// //   }
// //
// //   String generateNewAttendanceId(String userId) {
// //     String currentMonth = DateFormat('MMM').format(DateTime.now());
// //
// //     // If user changes, start from last known highest serial
// //     if (currentuserId != userId) {
// //       attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
// //       currentuserId = userId;
// //     }
// //
// //     // Month change — reset counter
// //     if (attendanceInCurrentMonth != currentMonth) {
// //       attendanceInSerialCounter = 1;
// //       attendanceInCurrentMonth = currentMonth;
// //     }
// //
// //     // Example: ATD-VT0043-Oct-001
// //     String attendanceId =
// //         "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
// //
// //     // Increment for next time
// //     attendanceInSerialCounter++;
// //     _saveCounter();
// //
// //     return attendanceId;
// //   }
// //
// //   // ***************************************************************
// //   // Internet Speed Check
// //   // ***************************************************************
// //   Future<String> _checkInternetSpeed() async {
// //     try {
// //       final response = await http.head(Uri.parse('https://www.google.com'))
// //           .timeout(const Duration(seconds: 3));
// //
// //       if (response.statusCode == 200) {
// //         return 'fast';
// //       } else {
// //         return 'slow';
// //       }
// //     } on TimeoutException {
// //       return 'slow';
// //     } on SocketException {
// //       return 'none';
// //     } catch (e) {
// //       debugPrint('Internet check failed: $e');
// //       return 'none';
// //     }
// //   }
// //
// //   Future<void> saveFormAttendanceIn() async {
// //     isLoading.value = true; // <--- Added from first block
// //
// //     try {
// //       // 1. Location Check
// //       bool locationAvailable = await isLocationAvailable(); // <--- Added from first block
// //       if (!locationAvailable) {
// //         debugPrint("❌ Clock-in blocked: Location not available"); // <--- Added from first block
// //         return;
// //       }
// //       debugPrint("✅ Location available, proceeding with clock-in"); // <--- Added from first block
// //
// //       // 2. Prevent double clock-in
// //       if (isClockedIn.value) {
// //         Get.snackbar('Already Clocked In', 'You are already clocked in. Current duration: ${elapsedTime.value}',
// //             snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
// //         return;
// //       }
// //
// //       // 3. Internet Check
// //       final internetStatus = await _checkInternetSpeed();
// //
// //       if (internetStatus == 'none') {
// //         Get.snackbar(
// //           'Offline Mode',
// //           'No internet connection detected. Clocking in offline.',
// //           snackPosition: SnackPosition.TOP,
// //           backgroundColor: Colors.blue.shade500,
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 8),
// //         );
// //       } else if (internetStatus == 'slow') {
// //         Get.snackbar(
// //           'Internet Slow ⚠️',
// //           'Your internet is slow. Please find a faster network or turn off internet to clock-in offline.',
// //           snackPosition: SnackPosition.TOP,
// //           backgroundColor: Colors.red,
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 10),
// //         );
// //         return;
// //       }
// //
// //       // 4. Generate ID and Save State
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await _loadCounter();
// //
// //       final attendanceId = generateNewAttendanceId(user_id);
// //       await prefs.setString('attendanceId', attendanceId);
// //
// //       // Set clock-in state and start timer
// //       _clockInTime = DateTime.now(); //
// //       isClockedIn.value = true; //
// //       await prefs.setString('clockInTime', _clockInTime!.toIso8601String()); //
// //       _startTimer(); //
// //
// //       // 5. Save to Local Database
// //       addAttendance(
// //         AttendanceModel(
// //           attendance_in_id: attendanceId,
// //           user_id: user_id,
// //           city: userCity,
// //           booker_name: userName,
// //           // Assuming globalLatitude1 and globalLongitude1 are updated by LocationViewModel after a successful check
// //           lat_in: locationViewModel.globalLatitude1.value,
// //           lng_in: locationViewModel.globalLongitude1.value,
// //           designation: userDesignation,
// //           address: locationViewModel.shopAddress.value,
// //         ),
// //       );
// //
// //       // 6. Post to API if internet is fast
// //       if (internetStatus == 'fast') {
// //         await attendanceRepository.postDataFromDatabaseToAPI();
// //       } else {
// //         debugPrint('Skipping API post. Internet status: $internetStatus');
// //       }
// //
// //       // 7. Success Notification
// //       Get.snackbar(
// //         'Clock-In Successful',
// //         'You are now clocked in.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //       );
// //     } finally {
// //       isLoading.value = false; // <--- Added from first block
// //     }
// //   }
// //
// //   Future<void> fetchAllAttendance() async {
// //     var attendance = await attendanceRepository.getAttendance();
// //     allAttendance.value = attendance;
// //   }
// //
// //   void addAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.add(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void updateAttendance(AttendanceModel attendanceModel) {
// //     attendanceRepository.update(attendanceModel);
// //     fetchAllAttendance();
// //   }
// //
// //   void deleteAttendance(String id) {
// //     attendanceRepository.delete(id);
// //     fetchAllAttendance();
// //   }
// //
// //   Future<void> serialCounterGet() async {
// //     await attendanceRepository.serialNumberGeneratorApi();
// //   }
// // }


import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/attendance_Model.dart';
import '../Repositories/attendance_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceViewModel extends GetxController {
  var allAttendance = <AttendanceModel>[].obs;
  final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  // --- TIMER AND STATE VARIABLES ---
  var isClockedIn = false.obs;
  DateTime? _clockInTime;
  Timer? _timer;
  var elapsedTime = '00:00:00'.obs;
  var isLoading = false.obs;
  // ---------------------------------

  int attendanceInSerialCounter = 1;
  String attendanceInCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuserId = '';

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
    _loadInitialClockState();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  // 🎯 SIMPLE LOCATION CHECK - ONLY CHECKS IF SERVICE IS ENABLED
  Future<bool> isLocationAvailable() async {
    try {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      return isLocationEnabled; // Simple true/false
    } catch (e) {
      return true; // Even on error, allow clock-in
    }
  }

  // 🎯 MAIN CLOCK-IN METHOD - INSTANT SUCCESS
  Future<void> saveFormAttendanceIn() async {
    debugPrint("🎯 CLOCK-IN STARTED");

    // 1. Check if already clocked in
    if (isClockedIn.value) {
      Get.snackbar(
        'Already Clocked In',
        'You are already clocked in',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
      );
      return;
    }

    // 2. QUICK location service check ONLY
    bool locationAvailable = await isLocationAvailable();
    if (!locationAvailable) {
      Get.snackbar(
        'Location Required',
        'Please turn on device location',
        backgroundColor: Colors.red,
      );
      return;
    }

    debugPrint("✅ Location ON - CLOCKING IN NOW");

    // 3. INSTANTLY SET CLOCK-IN STATE (NO AWAIT)
    _clockInTime = DateTime.now();
    isClockedIn.value = true;
    elapsedTime.value = '00:00:00';
    _startTimer();

    // 4. SHOW SUCCESS IMMEDIATELY
    Get.snackbar(
      'Clock-In Successful',
      'You are now clocked in',
      backgroundColor: Colors.green,
    );

    debugPrint("✅ CLOCK-IN COMPLETED - USER SEES SUCCESS");

    // 5. BACKGROUND TASKS - FIRE AND FORGET (NO AWAIT)
    // _handleAllBackgroundTasks();
    await _handleAllBackgroundTasks(); // ✅ ADD AWAIT
  }

  // 🛰 ALL BACKGROUND TASKS - COMPLETELY NON-BLOCKING
  ///old code
  // void _handleAllBackgroundTasks() async {
  //   debugPrint("🛰 Starting background tasks...");
  //
  //   try {
  //     // A. Save to SharedPreferences
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('clockInTime', _clockInTime!.toIso8601String());
  //     debugPrint("✅ Background: Saved to SharedPreferences");
  //
  //     // B. Generate attendance data
  //     await _loadCounter();
  //     final attendanceId = generateNewAttendanceId(user_id);
  //     await prefs.setString('attendanceId', attendanceId);
  //     await prefs.remove('totalDistance');
  //     await prefs.setInt('secondsPassed', 0);
  //     debugPrint("✅ Background: Generated attendance ID: $attendanceId");
  //
  //     // C. Save to local database
  //     addAttendance(
  //       AttendanceModel(
  //         attendance_in_id: attendanceId,
  //         user_id: user_id,
  //         city: userCity,
  //         booker_name: userName,
  //         lat_in: locationViewModel.globalLatitude1.value, // Could be 0.0
  //         lng_in: locationViewModel.globalLongitude1.value, // Could be 0.0
  //         designation: userDesignation,
  //         address: locationViewModel.shopAddress.value,
  //       ),
  //     );
  //     debugPrint("✅ Background: Saved to local database");
  //
  //     // D. Try server sync if internet available
  //     _tryServerSync();
  //
  //   } catch (e) {
  //     debugPrint("⚠ Background tasks error: $e");
  //   }
  // }

  // 🌐 SERVER SYNC - FIRE AND FORGET

  /// added code
  // 🛰 ALL BACKGROUND TASKS - WITH BLOCKING SYNC
  Future<void> _handleAllBackgroundTasks() async { // ✅ CHANGE: void → Future<void>
    debugPrint("🛰 Starting background tasks with BLOCKING sync...");

    try {
      // A. Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('clockInTime', _clockInTime!.toIso8601String());
      debugPrint("✅ Background: Saved to SharedPreferences");

      // B. Generate attendance data
      await _loadCounter();
      final attendanceId = generateNewAttendanceId(user_id);
      await prefs.setString('attendanceId', attendanceId);
      await prefs.remove('totalDistance');
      await prefs.setInt('secondsPassed', 0);
      debugPrint("✅ Background: Generated attendance ID: $attendanceId");

      // C. Save to local database
      addAttendance(
        AttendanceModel(
          attendance_in_id: attendanceId,
          user_id: user_id,
          city: userCity,
          booker_name: userName,
          lat_in: locationViewModel.globalLatitude1.value,
          lng_in: locationViewModel.globalLongitude1.value,
          designation: userDesignation,
          address: locationViewModel.shopAddress.value,
        ),
      );
      debugPrint("✅ Background: Saved to local database");

      // D. ✅ BLOCKING SERVER SYNC (Like clock-out)
      debugPrint("🌐 [ATTENDANCE-IN] Starting BLOCKING server sync...");

      final internetStatus = await _checkInternetSpeed().timeout(
        Duration(seconds: 3),
        onTimeout: () => 'none',
      );

      if (internetStatus == 'fast') {
        debugPrint("🌐 [ATTENDANCE-IN] Calling postDataFromDatabaseToAPI with AWAIT");
        await attendanceRepository.postDataFromDatabaseToAPI(); // ✅ AWAIT COMPLETION
        debugPrint("✅ [ATTENDANCE-IN] BLOCKING server sync completed");
      } else {
        debugPrint("🌐 [ATTENDANCE-IN] No internet - will sync later");
      }

    } catch (e) {
      debugPrint("⚠ Background tasks error: $e");
    }
  }
  ///coredted
  // void _tryServerSync() async {
  //   try {
  //     debugPrint("🌐 Trying server sync...");
  //
  //     // Quick internet check
  //     final internetStatus = await _checkInternetSpeed().timeout(
  //       Duration(seconds: 2),
  //       onTimeout: () => 'none',
  //     );
  //
  //     if (internetStatus == 'fast') {
  //       await attendanceRepository.postDataFromDatabaseToAPI();
  //       debugPrint("✅ Background: Server sync completed");
  //     } else {
  //       debugPrint("🌐 No internet - skipping server sync");
  //     }
  //   } catch (e) {
  //     debugPrint("⚠ Server sync failed: $e");
  //   }
  // }

  // 🌐 SERVER SYNC - IMMEDIATE (LIKE CLOCK-OUT)
  void _tryServerSync() async {
    try {
      debugPrint("🌐 [ATTENDANCE-IN] Immediate server sync started");

      // Quick internet check
      final internetStatus = await _checkInternetSpeed().timeout(
        Duration(seconds: 2),
        onTimeout: () => 'none',
      );

      debugPrint("🌐 [ATTENDANCE-IN] Internet status: $internetStatus");

      if (internetStatus == 'fast') {
        debugPrint("🌐 [ATTENDANCE-IN] Calling postDataFromDatabaseToAPI immediately");
        await attendanceRepository.postDataFromDatabaseToAPI(); // ✅ AWAIT COMPLETION
        debugPrint("✅ [ATTENDANCE-IN] Immediate server sync completed");
      } else {
        debugPrint("🌐 [ATTENDANCE-IN] No internet - skipping sync");
      }
    } catch (e) {
      debugPrint("⚠ [ATTENDANCE-IN] Immediate sync failed: $e");
      // Don't throw - data is saved locally
    }
  }



  // --- TIMER METHODS ---
  Future<void> _loadInitialClockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clockInTimeString = prefs.getString('clockInTime');

    if (clockInTimeString != null) {
      _clockInTime = DateTime.parse(clockInTimeString);
      isClockedIn.value = true;
      _startTimer();
    }
  }

  void _startTimer() {
    if (_clockInTime == null) return;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final duration = now.difference(_clockInTime!);

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));

      elapsedTime.value = '$hours:$minutes:$seconds';

      if (duration.inSeconds % 60 == 0) {
        debugPrint("⏰ Attendance Timer: ${elapsedTime.value}");
      }

      _saveTotalTime(elapsedTime.value);
    });
    debugPrint('✅ Attendance Timer started at: $_clockInTime');
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    debugPrint('🛑 Attendance Timer stopped');
  }

  Future<void> _saveTotalTime(String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('totalTime', time);
    debugPrint("✅ Saved total time to preferences: $time");
  }

  Future<void> clearClockInState() async {
    _stopTimer();
    isClockedIn.value = false;
    _clockInTime = null;
    elapsedTime.value = '00:00:00';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockInTime');
    await prefs.remove('attendanceId');
    await prefs.remove('totalTime');
    await prefs.remove('totalDistance');
    await prefs.setInt('secondsPassed', 0);
    debugPrint("🔄 Clock-in state cleared");
  }

  // --- SERIAL NUMBER METHODS ---
  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    attendanceInSerialCounter =
        prefs.getInt('attendanceInSerialCounter') ?? (attendanceInHighestSerial ?? 1);
    attendanceInCurrentMonth =
        prefs.getString('attendanceInCurrentMonth') ?? currentMonth;
    currentuserId = prefs.getString('currentuserId') ?? '';

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }

    debugPrint('Loaded Serial Counter: $attendanceInSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceInSerialCounter', attendanceInSerialCounter);
    await prefs.setString('attendanceInCurrentMonth', attendanceInCurrentMonth);
    await prefs.setString('currentuserId', currentuserId);
  }

  String generateNewAttendanceId(String userId) {
    // 👇 yahan define kar rahe hain current DateTime
    final DateTime now = DateTime.now(); ///

    String currentMonth = DateFormat('MMM').format(DateTime.now());
    ///
    String currentDayNumber = DateFormat('dd').format(now); // 28 ///
    // String currentDayName = DateFormat('E').format(now); // Thu ///



    if (currentuserId != userId) {
      attendanceInSerialCounter = attendanceInHighestSerial ?? 1;
      currentuserId = userId;
    }

    if (attendanceInCurrentMonth != currentMonth) {
      attendanceInSerialCounter = 1;
      attendanceInCurrentMonth = currentMonth;
    }
    // String attendanceId =
    //     "ATD-$userId-$currentMonth-$currentDayNumber-$currentDayName-${attendanceInSerialCounter.toString().padLeft(3, '0')}";
    String attendanceId =
        "ATD-$userId-$currentDayNumber-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";

    debugPrint("🆔 Generated Attendance ID: $attendanceId");

    // String attendanceId =
    //     "ATD-$userId-$currentMonth-${attendanceInSerialCounter.toString().padLeft(3, '0')}";

    attendanceInSerialCounter++;
    _saveCounter();

    return attendanceId;
  }

  // --- INTERNET CHECK ---
  Future<String> _checkInternetSpeed() async {
    try {
      final response = await http.head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return 'fast';
      } else {
        return 'slow';
      }
    } on TimeoutException {
      return 'slow';
    } on SocketException {
      return 'none';
    } catch (e) {
      debugPrint('Internet check failed: $e');
      return 'none';
    }
  }

  // --- DATABASE METHODS ---
  Future<void> fetchAllAttendance() async {
    var attendance = await attendanceRepository.getAttendance();
    allAttendance.value = attendance;
  }

  void addAttendance(AttendanceModel attendanceModel) {
    attendanceRepository.add(attendanceModel);
    fetchAllAttendance();
  }

  void updateAttendance(AttendanceModel attendanceModel) {
    attendanceRepository.update(attendanceModel);
    fetchAllAttendance();
  }

  void deleteAttendance(String id) {
    attendanceRepository.delete(id);
    fetchAllAttendance();
  }

  Future<void> serialCounterGet() async {
    await attendanceRepository.serialNumberGeneratorApi();
  }
}