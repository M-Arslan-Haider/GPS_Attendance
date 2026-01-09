//
// // // ///26-12-2025 clockout auto
// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // // import 'package:rive/rive.dart';
// // // import 'package:location/location.dart' as loc;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import '../../BatterySaverService.dart';
// // // import '../../Databases/util.dart';
// // // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // // import '../../Tracker/location00.dart';
// // // import '../../Tracker/trac.dart';
// // // import '../../main.dart';
// // // import 'assets.dart';
// // // import 'menu_item.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:gpx/gpx.dart';
// // //
// // // class TimerCard extends StatefulWidget {
// // //   const TimerCard({super.key});
// // //
// // //   @override
// // //   State<TimerCard> createState() => _TimerCardState();
// // // }
// // //
// // // class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
// // //   final locationViewModel = Get.find<LocationViewModel>();
// // //   final attendanceViewModel = Get.find<AttendanceViewModel>();
// // //   final attendanceOutViewModel = Get.find<AttendanceOutViewModel>();
// // //   final updateFunctionViewModel = Get.find<UpdateFunctionViewModel>();
// // //
// // //   // ✅ ABDULLAH: Added Travel Time ViewModel initialization
// // //   final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());
// // //
// // //   final loc.Location location = loc.Location();
// // //   final Connectivity _connectivity = Connectivity();
// // //
// // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // //   Timer? _locationMonitorTimer;
// // //   bool _wasLocationAvailable = true;
// // //   bool _autoClockOutInProgress = false;
// // //
// // //   bool _isRiveAnimationActive = false;
// // //   Timer? _localBackupTimer;
// // //   DateTime? _localClockInTime;
// // //   String _localElapsedTime = '00:00:00';
// // //
// // //   // ✅ AUTO-SYNC VARIABLES
// // //   Timer? _autoSyncTimer;
// // //   bool _isOnline = false;
// // //   bool _isSyncing = false; // ✅ ADD SYNC LOCK
// // //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// // //
// // //   // ✅ ADD: Distance tracking
// // //   double _currentDistance = 0.0;
// // //   Timer? _distanceUpdateTimer;
// // //
// // //   // ✅ SIMPLE 11:00 PM AUTO CLOCK-OUT TIMER
// // //   Timer? _elevenPMTimer;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //     _initializeFromPersistentState();
// // //     _startAutoSyncMonitoring();
// // //     _setupMidnightProcessing();
// // //     _startDistanceUpdater();
// // //
// // //     // ✅ START 11:00 PM DEVICE TIME CHECK
// // //     _startElevenPMTimer();
// // //     _startBatterySaverAutoClockOutMonitoring();
// // //
// // //     // ✅ CHECK FOR PENDING DATA ON STARTUP
// // //     _checkAndSyncPendingData();
// // //   }
// // //
// // //   @override
// // //   void didChangeDependencies() {
// // //     super.didChangeDependencies();
// // //     _restoreEverything();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     _stopLocationMonitoring();
// // //     _localBackupTimer?.cancel();
// // //     _autoSyncTimer?.cancel();
// // //     _connectivitySubscription?.cancel();
// // //     _distanceUpdateTimer?.cancel();
// // //     _elevenPMTimer?.cancel(); // ✅ STOP 11:00 PM TIMER
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     debugPrint("🔄 [LIFECYCLE] App state changed: $state");
// // //
// // //     if (state == AppLifecycleState.resumed) {
// // //       _restoreEverything();
// // //       _checkConnectivityAndSync();
// // //
// // //       // ✅ RESTART 11:00 PM TIMER WHEN APP RESUMES
// // //       _startElevenPMTimer();
// // //
// // //       // ✅ CHECK FOR PENDING DATA WHEN APP RESUMES
// // //       _checkAndSyncPendingData();
// // //     }
// // //   }
// // //
// // //   // ✅ NEW METHOD: Check and sync pending data
// // //   void _checkAndSyncPendingData() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //     // Check for pending clock-out
// // //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// // //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// // //
// // //     if (hasPendingClockOut || clockOutPending) {
// // //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// // //       _triggerAutoSync();
// // //     }
// // //   }
// // //
// // //   // ✅ BATTERY SAVER AUTO CLOCK-OUT MONITORING
// // //   void _startBatterySaverAutoClockOutMonitoring() {
// // //     Timer.periodic(const Duration(seconds: 10), (timer) async {
// // //       if (!attendanceViewModel.isClockedIn.value) {
// // //         return; // User not clocked in, no need to check
// // //       }
// // //
// // //       try {
// // //         bool isBatterySaverOn = await BatterySaverService.isBatterySaverOn();
// // //
// // //         if (isBatterySaverOn) {
// // //           debugPrint("🔋 [BATTERY SAVER] Battery Saver ON detected - triggering auto clock-out");
// // //           await _handleBatterySaverAutoClockOut();
// // //         }
// // //       } catch (e) {
// // //         debugPrint("❌ Error checking battery saver: $e");
// // //       }
// // //     });
// // //   }
// // //
// // //   // ✅ SIMPLE: START 11:00 PM DEVICE TIME TIMER
// // //   void _startElevenPMTimer() {
// // //     // Cancel existing timer
// // //     _elevenPMTimer?.cancel();
// // //
// // //     debugPrint("⏰ Starting 11:00 PM device time check");
// // //
// // //     // Check every minute if it's 11:00 PM
// // //     _elevenPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // //       _checkForElevenPM();
// // //     });
// // //   }
// // //
// // //   // ✅ SIMPLE: CHECK FOR 11:00 PM DEVICE TIME
// // //   void _checkForElevenPM() async {
// // //     try {
// // //       // Get current device time
// // //       DateTime now = DateTime.now();
// // //
// // //       // Check if it's exactly 11:00 PM
// // //       if (now.hour == 23 && now.minute == 0) {
// // //         debugPrint("🕰 11:00 PM DEVICE TIME DETECTED");
// // //
// // //         // Check if user is clocked in
// // //         if (attendanceViewModel.isClockedIn.value) {
// // //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:00 PM");
// // //
// // //           // Call auto clock-out at 11:00 PM
// // //           await _handleElevenPMAutoClockOut();
// // //         } else {
// // //           debugPrint("⏰ User already clocked out at 11:00 PM");
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error in 11:00 PM check: $e");
// // //     }
// // //   }
// // //
// // //   // ✅ BATTERY SAVER AUTO CLOCK-OUT
// // //   Future<void> _handleBatterySaverAutoClockOut() async {
// // //     if (_autoClockOutInProgress) return;
// // //     _autoClockOutInProgress = true;
// // //
// // //     debugPrint("🔄 [BATTERY SAVER AUTO] Auto Clock-Out triggered - Battery Saver ON");
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //
// // //       // ✅ GET CURRENT DISTANCE
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double finalDistance = await locationService.calculateCurrentDistance();
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// // //       await _saveAllClockOutDataToPrefs(
// // //         finalDistance: finalDistance,
// // //         clockOutTime: clockOutTime,
// // //         reason: 'battery_saver_auto',
// // //       );
// // //
// // //       debugPrint("✅ [PREFERENCE] Battery saver auto clock-out data saved to SharedPreferences");
// // //
// // //       // 🔥 DAILY CONSOLIDATION
// // //       await locationViewModel.consolidateDailyGPXData();
// // //       debugPrint("✅ [BATTERY SAVER AUTO] All today's points merged");
// // //
// // //       // ✅ STOP TRAVEL TIME TRACKING
// // //       travelTimeViewModel.stopTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (Battery Saver)");
// // //
// // //       locationViewModel.saveCurrentLocation().catchError((e)
// // //       => debugPrint("Battery saver auto location error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       // UPDATE UI STATE
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// // //       await prefs.setBool('clockOutPending', true);
// // //
// // //       // UPDATE RIVE ANIMATION
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       // RESET LOCAL VARIABLES
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //       _currentDistance = 0.0;
// // //
// // //       // STOP BACKGROUND SERVICE
// // //       service.invoke("stopService");
// // //
// // //       // ✅ SAVE ATTENDANCE OUT WITH BATTERY SAVER REASON
// // //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: true,
// // //         reason: 'battery_saver_auto',
// // //       );
// // //
// // //       // 🔥 24 HOURS DATA PROCESSING
// // //       await locationViewModel.updateTodayCentralPoint();
// // //       debugPrint("✅ [24HOURS] Daily GPX data processed (Battery Saver)");
// // //
// // //       // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
// // //       await locationViewModel.saveLocationFromConsolidatedFile();
// // //       debugPrint("💾 Location saved from consolidated file (Battery Saver)");
// // //
// // //       locationViewModel.saveClockStatus(false).catchError((e)
// // //       => debugPrint("Battery saver clock status error: $e"));
// // //
// // //       await location.enableBackgroundMode(enable: false);
// // //
// // //       // ✅ SYNC after auto clock-out (FIRE AND FORGET)
// // //       _triggerPostClockOutSync();
// // //
// // //       debugPrint("✅ [BATTERY SAVER AUTO] Auto Clock-Out completed");
// // //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// // //
// // //       // Show battery saver auto clock-out notification
// // //       Get.snackbar(
// // //         '⚠️ Battery Saver Detected',
// // //         'Auto clock-out due to Battery Saver mode. Data saved locally.',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.orange,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //         icon: Icon(Icons.battery_alert, color: Colors.white),
// // //         mainButton: TextButton(
// // //           onPressed: () {
// // //             BatterySaverService.openBatterySaverSettings();
// // //           },
// // //           child: Text('SETTINGS', style: TextStyle(color: Colors.white)),
// // //         ),
// // //       );
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [BATTERY SAVER AUTO] Error: $e");
// // //
// // //       // Emergency fallback - at least update the clock status
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       Get.snackbar(
// // //         'Battery Saver Alert',
// // //         'Please turn OFF Battery Saver for GPS tracking',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.red,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //       );
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   // ✅ SIMPLE: HANDLE 11:00 PM AUTO CLOCK-OUT
// // //   Future<void> _handleElevenPMAutoClockOut() async {
// // //     if (_autoClockOutInProgress) return;
// // //     _autoClockOutInProgress = true;
// // //
// // //     debugPrint("🔄 [11:00 PM] Automatic clock-out triggered by device time");
// // //
// // //     try {
// // //       // Stop monitoring timers
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //
// // //       // ✅ GET CURRENT DATA
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double finalDistance = await locationService.calculateCurrentDistance();
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       // Adjust to exactly 11:00 PM
// // //       clockOutTime = DateTime(clockOutTime.year, clockOutTime.month, clockOutTime.day, 23, 0, 0);
// // //
// // //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// // //       await _saveAllClockOutDataToPrefs(
// // //         finalDistance: finalDistance,
// // //         clockOutTime: clockOutTime,
// // //         reason: '11pm_auto',
// // //       );
// // //
// // //       debugPrint("✅ [PREFERENCE] 11:00 PM auto clock-out data saved to SharedPreferences");
// // //
// // //       // Save current location
// // //       locationViewModel.saveCurrentLocation().catchError((e)
// // //       => debugPrint("11PM location error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       // Update UI state
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// // //       await prefs.setBool('clockOutPending', true);
// // //
// // //       // Update Rive animation
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       // Reset local variables
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //       _currentDistance = 0.0;
// // //
// // //       // Stop background service
// // //       service.invoke("stopService");
// // //
// // //       // ✅ Save attendance with 11:00 PM timestamp
// // //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: true,
// // //         reason: '11pm_auto',
// // //       );
// // //
// // //       // Process and save location data
// // //       await locationViewModel.consolidateDailyGPXData();
// // //       await locationViewModel.updateTodayCentralPoint();
// // //       await locationViewModel.saveLocationFromConsolidatedFile();
// // //       await locationViewModel.saveClockStatus(false);
// // //
// // //       // Disable background mode
// // //       await location.enableBackgroundMode(enable: false);
// // //
// // //       // ✅ SYNC (FIRE AND FORGET)
// // //       _triggerPostClockOutSync();
// // //
// // //       // Show notification
// // //       Get.snackbar(
// // //         'Auto Clock-Out',
// // //         'Automatically clocked out at 11:00 PM. Data saved locally.',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.purple.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //         icon: const Icon(Icons.access_time, color: Colors.white),
// // //       );
// // //
// // //       debugPrint("✅ [11:00 PM] Auto clock-out completed successfully");
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [11:00 PM] Error during auto clock-out: $e");
// // //
// // //       // Emergency fallback
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       Get.snackbar(
// // //         'Auto Clock-Out',
// // //         'System automatically ended your shift at 11:00 PM',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.purple.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //       );
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   // ✅ NEW METHOD: Save all clock-out data to SharedPreferences
// // //   Future<void> _saveAllClockOutDataToPrefs({
// // //     required double finalDistance,
// // //     required DateTime clockOutTime,
// // //     String reason = 'manual',
// // //   }) async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //     // Save all critical data
// // //     await prefs.setString('pendingClockOutTime', clockOutTime.toIso8601String());
// // //     await prefs.setDouble('pendingTotalDistance', finalDistance);
// // //     await prefs.setString('pendingClockOutReason', reason);
// // //
// // //     // Save location data
// // //     await prefs.setDouble('pendingLatOut', locationViewModel.globalLatitude1.value);
// // //     await prefs.setDouble('pendingLngOut', locationViewModel.globalLongitude1.value);
// // //     await prefs.setString('pendingAddress', locationViewModel.shopAddress.value);
// // //
// // //     // Mark that we have pending clock-out data
// // //     await prefs.setBool('hasPendingClockOutData', true);
// // //
// // //     debugPrint("📱 [PREFERENCE] All clock-out data saved to SharedPreferences");
// // //   }
// // //
// // //   // ✅ NEW METHOD: Trigger sync after clock-out (FIRE AND FORGET)
// // //   void _triggerPostClockOutSync() async {
// // //     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
// // //
// // //     try {
// // //       // Check if we're online
// // //       var results = await _connectivity.checkConnectivity();
// // //       bool isOnline = results.isNotEmpty &&
// // //           results.any((result) => result != ConnectivityResult.none);
// // //
// // //       if (isOnline && !_isSyncing) {
// // //         _isSyncing = true;
// // //
// // //         // Try to sync all data
// // //         await updateFunctionViewModel.syncAllLocalDataToServer();
// // //
// // //         // Clear pending flag if sync successful
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //         await prefs.setBool('hasPendingClockOutData', false);
// // //         await prefs.setBool('clockOutPending', false);
// // //
// // //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// // //
// // //         // Show success notification
// // //         Get.snackbar(
// // //           'Sync Complete',
// // //           'All data synchronized to server',
// // //           snackPosition: SnackPosition.BOTTOM,
// // //           backgroundColor: Colors.green,
// // //           colorText: Colors.white,
// // //           duration: const Duration(seconds: 2),
// // //         );
// // //       } else {
// // //         debugPrint("🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
// // //
// // //         // Data is already saved in SharedPreferences, so it's safe
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //         await prefs.setBool('clockOutPending', true);
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
// // //
// // //       // Even on error, data is safe in SharedPreferences
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('clockOutPending', true);
// // //     } finally {
// // //       _isSyncing = false;
// // //     }
// // //   }
// // //
// // //   // GET GPX FILE NAME CONSISTENTLY
// // //   String _getGpxFileName() {
// // //     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //     return 'track_${user_id}_$date.gpx';
// // //   }
// // //
// // //   String _getConsolidatedFileName() {
// // //     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //     return 'track$date.gpx';
// // //   }
// // //
// // //   // ✅ START DISTANCE UPDATER
// // //   void _startDistanceUpdater() {
// // //     _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
// // //       if (attendanceViewModel.isClockedIn.value) {
// // //         await _updateCurrentDistance();
// // //       }
// // //     });
// // //   }
// // //
// // //   // ✅ UPDATE CURRENT DISTANCE
// // //   Future<void> _updateCurrentDistance() async {
// // //     try {
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double distance = await locationService.calculateCurrentDistance();
// // //
// // //       if (mounted) {
// // //         setState(() {
// // //           _currentDistance = distance;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Distance update error: $e");
// // //     }
// // //   }
// // //
// // //   // ✅ GET CURRENT DISTANCE
// // //   Future<double> _getCurrentDistance() async {
// // //     if (_currentDistance > 0) {
// // //       return _currentDistance;
// // //     }
// // //
// // //     try {
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       return await locationService.calculateCurrentDistance();
// // //     } catch (e) {
// // //       return 0.0;
// // //     }
// // //   }
// // //
// // //   // ✅ AUTO-SYNC MONITORING SYSTEM WITH SYNC LOCK
// // //   void _startAutoSyncMonitoring() async {
// // //     // Listen to connectivity changes
// // //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
// // //
// // //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'} | Was: ${wasOnline ? 'ONLINE' : 'OFFLINE'} | Syncing: $_isSyncing");
// // //
// // //       // ✅ FIX: Only trigger if we JUST came online AND not already syncing
// // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// // //         _triggerAutoSync();
// // //       }
// // //     });
// // //
// // //     // ✅ FIX: Reduce frequency and add protection
// // //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// // //       if (!_isSyncing) {
// // //         _checkConnectivityAndSync();
// // //       }
// // //     });
// // //
// // //     _checkConnectivityAndSync();
// // //   }
// // //
// // //   // ✅ CHECK CONNECTIVITY AND SYNC WITH PROTECTION
// // //   void _checkConnectivityAndSync() async {
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     try {
// // //       var results = await _connectivity.checkConnectivity();
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
// // //
// // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // //         debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
// // //         _triggerAutoSync();
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
// // //     }
// // //   }
// // //
// // //   // ✅ TRIGGER AUTO-SYNC WITH SYNC LOCKING
// // //   void _triggerAutoSync() async {
// // //     // Prevent multiple simultaneous syncs
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     _isSyncing = true; // Lock sync
// // //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// // //
// // //     try {
// // //       // Show subtle notification
// // //       Get.snackbar(
// // //         'Syncing Data',
// // //         'Auto-syncing offline data...',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.blue.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //
// // //       // Sync all local data to server
// // //       await updateFunctionViewModel.syncAllLocalDataToServer();
// // //
// // //       // ✅ Clear pending flags if sync successful
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('hasPendingClockOutData', false);
// // //       await prefs.setBool('clockOutPending', false);
// // //
// // //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// // //
// // //     } catch (e) {
// // //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// // //     } finally {
// // //       _isSyncing = false; // Release lock
// // //       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
// // //     }
// // //   }
// // //
// // //   void _restoreEverything() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // //
// // //     if (isClockedIn) {
// // //       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
// // //
// // //       locationViewModel.isClockedIn.value = true;
// // //       attendanceViewModel.isClockedIn.value = true;
// // //
// // //       _isRiveAnimationActive = true;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //
// // //       if (mounted) {
// // //         setState(() {});
// // //       }
// // //
// // //       debugPrint("✅ [BULLETPROOF] Everything restored successfully");
// // //     }
// // //   }
// // //
// // //   void _startLocalBackupTimer() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     String? clockInTimeString = prefs.getString('clockInTime');
// // //
// // //     if (clockInTimeString == null) return;
// // //
// // //     _localClockInTime = DateTime.parse(clockInTimeString);
// // //     _localBackupTimer?.cancel();
// // //
// // //     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (_localClockInTime == null) return;
// // //
// // //       final now = DateTime.now();
// // //       final duration = now.difference(_localClockInTime!);
// // //
// // //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// // //       String hours = twoDigits(duration.inHours);
// // //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// // //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// // //
// // //       _localElapsedTime = '$hours:$minutes:$seconds';
// // //       attendanceViewModel.elapsedTime.value = _localElapsedTime;
// // //
// // //       if (mounted) {
// // //         setState(() {});
// // //       }
// // //     });
// // //
// // //     debugPrint("✅ [BACKUP TIMER] Local backup timer started");
// // //   }
// // //
// // //   Future<void> _initializeFromPersistentState() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // //
// // //     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn");
// // //
// // //     locationViewModel.isClockedIn.value = isClockedIn;
// // //     attendanceViewModel.isClockedIn.value = isClockedIn;
// // //     _isRiveAnimationActive = isClockedIn;
// // //
// // //     if (isClockedIn) {
// // //       debugPrint("✅ [INIT] User was clocked in - starting everything...");
// // //
// // //       _startBackgroundServices();
// // //       _startLocationMonitoring();
// // //       _startLocalBackupTimer();
// // //
// // //       debugPrint("✅ [INIT] Full clocked-in state restored");
// // //     }
// // //
// // //     if (mounted) {
// // //       setState(() {});
// // //     }
// // //   }
// // //
// // //   void onThemeRiveIconInit(Artboard artboard) {
// // //     final controller = StateMachineController.fromArtboard(
// // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // //     if (controller != null) {
// // //       artboard.addController(controller);
// // //       _themeMenuIcon[0].riveIcon.status =
// // //       controller.findInput<bool>("active") as SMIBool?;
// // //
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// // //         debugPrint("🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// // //       }
// // //     } else {
// // //       debugPrint("StateMachineController not found!");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               // Time display
// // //               Obx(() {
// // //                 String displayTime = _localElapsedTime;
// // //                 if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
// // //                   displayTime = attendanceViewModel.elapsedTime.value;
// // //                 }
// // //
// // //                 return Text(
// // //                   displayTime,
// // //                   style: const TextStyle(
// // //                     fontSize: 20,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Colors.black87,
// // //                   ),
// // //                 );
// // //               }),
// // //               // ✅ ADD: Distance display
// // //               Obx(() {
// // //                 if (attendanceViewModel.isClockedIn.value) {
// // //                   return FutureBuilder<double>(
// // //                     future: _getCurrentDistance(),
// // //                     builder: (context, snapshot) {
// // //                       if (snapshot.hasData && snapshot.data! > 0) {
// // //                         return Text(
// // //                           '${snapshot.data!.toStringAsFixed(2)} km',
// // //                           style: TextStyle(
// // //                             fontSize: 12,
// // //                             color: Colors.blue.shade700,
// // //                             fontWeight: FontWeight.w500,
// // //                           ),
// // //                         );
// // //                       }
// // //                       return const SizedBox.shrink();
// // //                     },
// // //                   );
// // //                 }
// // //                 return const SizedBox.shrink();
// // //               }),
// // //             ],
// // //           ),
// // //           Obx(() {
// // //             return ElevatedButton(
// // //               onPressed: () async {
// // //                 debugPrint("🎯 [BUTTON] Button pressed");
// // //                 debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");
// // //
// // //                 if (attendanceViewModel.isClockedIn.value) {
// // //                   await _handleClockOut(context);
// // //                 } else {
// // //                   await _handleClockIn(context);
// // //                 }
// // //               },
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: attendanceViewModel.isClockedIn.value
// // //                     ? Colors.redAccent
// // //                     : Colors.green,
// // //                 minimumSize: const Size(30, 30),
// // //                 shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(12),
// // //                 ),
// // //                 padding: EdgeInsets.zero,
// // //               ),
// // //               child: SizedBox(
// // //                 width: 35,
// // //                 height: 35,
// // //                 child: RiveAnimation.asset(
// // //                   iconsRiv,
// // //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// // //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// // //                   onInit: onThemeRiveIconInit,
// // //                   fit: BoxFit.cover,
// // //                 ),
// // //               ),
// // //             );
// // //           }),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ FIXED: Clock-in method with proper GPX file creation
// // //   Future<void> _handleClockIn(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// // //
// // //     // ✅ STEP 1: Check Battery Saver FIRST
// // //     bool batterySaverValid = await BatterySaverService.checkBatterySaverForClockIn(context);
// // //     if (!batterySaverValid) {
// // //       debugPrint("❌ [BATTERY SAVER] Clock-in blocked - Battery Saver is ON");
// // //       return; // Stop here if battery saver is ON
// // //     }
// // //
// // //     // ✅ STEP 2: Location check (existing code)
// // //     bool locationAvailable = await attendanceViewModel.isLocationAvailable();
// // //     if (!locationAvailable) {
// // //       Get.snackbar(
// // //         'Location Required',
// // //         'Please enable Location Services to clock in',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.red.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //       );
// // //       return;
// // //     }
// // //
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     try {
// // //       // ✅ STEP 3: Double-check battery saver before proceeding
// // //       bool finalBatteryCheck = await BatterySaverService.isBatterySaverOn();
// // //       if (finalBatteryCheck) {
// // //         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //         Get.snackbar(
// // //           'Battery Saver Detected',
// // //           'Please turn OFF Battery Saver to clock in',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.orange.shade700,
// // //           colorText: Colors.white,
// // //           duration: const Duration(seconds: 5),
// // //         );
// // //         return;
// // //       }
// // //
// // //       // ✅ FIX: Clear previous session data
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //       // ✅ FIX 1: Initialize LocationService PROPERLY
// // //       LocationService locationService = LocationService();
// // //
// // //       // ✅ FIX 2: Call init() to load user data BEFORE listenLocation()
// // //       await locationService.init();
// // //
// // //       // ✅ FIX 3: Start location listening
// // //       await locationService.listenLocation();
// // //
// // //       // ✅ FIX 4: Verify GPX file was created
// // //       await Future.delayed(const Duration(seconds: 2)); // Give time for file creation
// // //
// // //       // Check if GPX file exists
// // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //       final downloadDirectory = await getDownloadsDirectory();
// // //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// // //       File file = File(filePath);
// // //
// // //       if (!file.existsSync()) {
// // //         debugPrint("⚠️ GPX file was not created at: $filePath");
// // //         // Create an empty GPX file with proper structure
// // //         String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
// // // <gpx version="1.1" creator="OrderBookingApp">
// // //   <trk>
// // //     <name>Daily Track $date</name>
// // //     <trkseg>
// // //     </trkseg>
// // //   </trk>
// // // </gpx>''';
// // //         await file.writeAsString(initialGPX);
// // //         debugPrint("✅ Created empty GPX file for tracking");
// // //       }
// // //
// // //       // ✅ FIX 5: Check initial distance (should be 0)
// // //       double initialDistance = locationService.getCurrentDistance();
// // //       debugPrint("📍 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
// // //
// // //       if (initialDistance > 0.001) { // If more than 1 meter
// // //         debugPrint("⚠️ Suspicious initial distance, resetting...");
// // //         locationService.resetDistance();
// // //         initialDistance = 0.0;
// // //       }
// // //
// // //       // ✅ FIX 6: Save clock-in data
// // //       await attendanceViewModel.saveFormAttendanceIn();
// // //       _startBackgroundServices();
// // //
// // //       locationViewModel.isClockedIn.value = true;
// // //       attendanceViewModel.isClockedIn.value = true;
// // //
// // //       await prefs.setBool('isClockedIn', true);
// // //
// // //       // ✅ FIX 7: Also save the file path for verification
// // //       await prefs.setString('currentGpxFilePath', filePath);
// // //
// // //       // ✅ FIX: Save session info
// // //       await prefs.setString('currentSessionStart', DateTime.now().toIso8601String());
// // //
// // //       _isRiveAnimationActive = true;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //       _startLocationMonitoring();
// // //
// // //       travelTimeViewModel.startTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// // //
// // //       // ✅ UPDATE DISTANCE DISPLAY
// // //       await _updateCurrentDistance();
// // //
// // //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// // //       debugPrint("📏 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
// // //       debugPrint("📁 GPX File: $filePath");
// // //       debugPrint("📊 File Size: ${file.lengthSync()} bytes");
// // //
// // //       // Show success message
// // //       Get.snackbar(
// // //         'Clocked In Successfully',
// // //         'GPS tracking started',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [CLOCK-IN] Error: $e");
// // //       Get.snackbar('Error', 'Failed to clock in: $e',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.red,
// // //           colorText: Colors.white);
// // //     } finally {
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //     }
// // //   }
// // //
// // //   void _startBackgroundServices() async {
// // //     try {
// // //       debugPrint("🛰 [BACKGROUND] Starting services...");
// // //
// // //       final service = FlutterBackgroundService();
// // //       await location.enableBackgroundMode(enable: true);
// // //
// // //       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
// // //       service.startService().catchError((e) => debugPrint("Service start error: $e"));
// // //       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
// // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // //
// // //       debugPrint("✅ [BACKGROUND] Services started");
// // //     } catch (e) {
// // //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// // //     }
// // //   }
// // //
// // //   // ✅ FIXED: Clock-out method with GPX file verification
// // //   Future<void> _handleClockOut(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-OUT STARTED =====");
// // //
// // //     // ✅ ADD: Check GPX status before proceeding
// // //     await _checkGPXFileStatus();
// // //
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => const Center(child: CircularProgressIndicator()),
// // //     );
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //
// // //       // ✅ STEP 1: GET CURRENT DATA BEFORE ANYTHING ELSE
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double finalDistance = await locationService.calculateCurrentDistance();
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       // ✅ STEP 2: SAVE ALL DATA TO SHARED PREFERENCES FIRST (IMMEDIATE)
// // //       await _saveAllClockOutDataToPrefs(
// // //         finalDistance: finalDistance,
// // //         clockOutTime: clockOutTime,
// // //       );
// // //
// // //       debugPrint("✅ [PREFERENCE] All clock-out data saved to SharedPreferences");
// // //
// // //       // 🔥 DAILY CONSOLIDATION
// // //       await locationViewModel.consolidateDailyGPXData();
// // //       debugPrint("✅ [CONSOLIDATION] All today's points merged into single file");
// // //
// // //       // ✅ ABDULLAH: Added Travel Time Tracking STOP when user clocks out
// // //       travelTimeViewModel.stopTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped");
// // //
// // //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// // //       await prefs.setBool('clockOutPending', true);
// // //
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       // ✅ RESET DISTANCE DISPLAY
// // //       setState(() {
// // //         _currentDistance = 0.0;
// // //       });
// // //
// // //       service.invoke("stopService");
// // //
// // //       // ✅ ATTENDANCE OUT: Pass the distance and time
// // //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //       );
// // //
// // //       // 🔥 24 HOURS DATA PROCESSING - AB SINGLE FILE SE HOGA
// // //       await locationViewModel.updateTodayCentralPoint();
// // //       debugPrint("✅ [24HOURS] Daily GPX data processed from SINGLE FILE");
// // //
// // //       // ✅ VERIFY: Check if consolidated file exists
// // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //       final downloadDirectory = await getDownloadsDirectory();
// // //       final consolidatedFilePath = '${downloadDirectory!.path}/track$date.gpx';
// // //       File consolidatedFile = File(consolidatedFilePath);
// // //
// // //       if (consolidatedFile.existsSync()) {
// // //         debugPrint("✅ CONFIRMED: Consolidated GPX file exists");
// // //         debugPrint("   - Size: ${consolidatedFile.lengthSync()} bytes");
// // //
// // //         // Calculate and display actual distance from file
// // //         double actualDistance = await locationViewModel.calculateTotalDistance(consolidatedFilePath);
// // //         debugPrint("   - Actual Distance from file: ${actualDistance.toStringAsFixed(3)} km");
// // //
// // //         // Update SharedPreferences with actual distance
// // //         await prefs.setDouble('actualFinalDistance', actualDistance);
// // //       }
// // //
// // //       // 🔥🔥🔥 YEH NAYA METHOD USE KAREN - SINGLE FILE SE SAVE
// // //       await locationViewModel.saveLocationFromConsolidatedFile();
// // //       debugPrint("💾 Location saved from consolidated file");
// // //
// // //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
// // //
// // //       await location.enableBackgroundMode(enable: false);
// // //
// // //       // ✅ STEP 3: TRIGGER AUTO-SYNC (FIRE AND FORGET - DON'T WAIT)
// // //       _triggerPostClockOutSync();
// // //
// // //       debugPrint("✅ [CLOCK-OUT] ===== COMPLETED SUCCESSFULLY =====");
// // //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// // //
// // //       // ✅ QUICK SUCCESS MESSAGE (WITHIN 2-3 SECONDS)
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Clock Out Complete',
// // //         'Data saved locally. Syncing in background...',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [CLOCK-OUT] Error: $e");
// // //
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Clock Out Complete',
// // //         'Data saved locally. Will sync when online.',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.orange,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //     }
// // //   }
// // //
// // //   Future<void> _handleAutoClockOut() async {
// // //     if (_autoClockOutInProgress) return;
// // //     _autoClockOutInProgress = true;
// // //     debugPrint("🔄 [AUTO] Auto Clock-Out triggered due to location OFF");
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //
// // //       // ✅ GET CURRENT DISTANCE
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double finalDistance = await locationService.calculateCurrentDistance();
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// // //       await _saveAllClockOutDataToPrefs(
// // //         finalDistance: finalDistance,
// // //         clockOutTime: clockOutTime,
// // //         reason: 'location_off_auto',
// // //       );
// // //
// // //       debugPrint("✅ [PREFERENCE] Auto clock-out data saved to SharedPreferences");
// // //
// // //       // 🔥 DAILY CONSOLIDATION
// // //       await locationViewModel.consolidateDailyGPXData();
// // //       debugPrint("✅ [CONSOLIDATION] All today's points merged (Auto Clock-Out)");
// // //
// // //       // ✅ ABDULLAH: Added Travel Time Tracking STOP during auto clock-out
// // //       travelTimeViewModel.stopTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (auto clock-out)");
// // //
// // //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));
// // //
// // //       final service = FlutterBackgroundService();
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //
// // //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// // //       await prefs.setBool('clockOutPending', true);
// // //
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       // ✅ RESET DISTANCE DISPLAY
// // //       setState(() {
// // //         _currentDistance = 0.0;
// // //       });
// // //
// // //       service.invoke("stopService");
// // //
// // //       // ✅ ATTENDANCE OUT with auto flag
// // //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: true,
// // //         reason: 'location_off_auto',
// // //       );
// // //
// // //       // 🔥 24 HOURS DATA PROCESSING - AB SINGLE FILE SE HOGA
// // //       await locationViewModel.updateTodayCentralPoint();
// // //       debugPrint("✅ [24HOURS] Daily GPX data processed from SINGLE FILE (Auto Clock-Out)");
// // //
// // //       // 🔥🔥🔥 YEH NAYA METHOD USE KAREN - SINGLE FILE SE SAVE
// // //       await locationViewModel.saveLocationFromConsolidatedFile();
// // //       debugPrint("💾 Location saved from consolidated file (Auto Clock-Out)");
// // //
// // //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));
// // //
// // //       await location.enableBackgroundMode(enable: false);
// // //
// // //       // ✅ SYNC after auto clock-out (FIRE AND FORGET)
// // //       _triggerPostClockOutSync();
// // //
// // //       debugPrint("✅ [AUTO] Auto Clock-Out completed");
// // //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// // //
// // //       // Show auto clock-out notification
// // //       Get.snackbar(
// // //         'Auto Clock Out',
// // //         'Location services turned off. Data saved locally.',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.orange,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //       );
// // //     } catch (e) {
// // //       debugPrint("❌ [AUTO] Auto clock-out error: $e");
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   void _startLocationMonitoring() {
// // //     _wasLocationAvailable = true;
// // //     _autoClockOutInProgress = false;
// // //
// // //     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
// // //       if (!attendanceViewModel.isClockedIn.value) {
// // //         _stopLocationMonitoring();
// // //         return;
// // //       }
// // //
// // //       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
// // //
// // //       if (_wasLocationAvailable && !currentLocationAvailable) {
// // //         debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
// // //         await _handleAutoClockOut();
// // //       }
// // //
// // //       _wasLocationAvailable = currentLocationAvailable;
// // //     });
// // //   }
// // //
// // //   // TimerCard mein add karein
// // //   void _setupMidnightProcessing() {
// // //     // Calculate time until next midnight
// // //     DateTime now = DateTime.now();
// // //     DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
// // //     Duration timeUntilMidnight = nextMidnight.difference(now);
// // //
// // //     Timer(timeUntilMidnight, () {
// // //       // Process previous day's data
// // //       _processPreviousDayData();
// // //
// // //       // Setup for next day
// // //       _setupMidnightProcessing();
// // //     });
// // //   }
// // //
// // //   Future<void> _processPreviousDayData() async {
// // //     debugPrint("🌙 Processing previous day's data at midnight");
// // //
// // //     // 🔥 DAILY CONSOLIDATION PEHLE CALL KAREN
// // //     await locationViewModel.consolidateDailyGPXData();
// // //     debugPrint("✅ [MIDNIGHT] Previous day's data consolidated");
// // //
// // //     await locationViewModel.updateTodayCentralPoint();
// // //     await locationViewModel.generateDailySummary();
// // //
// // //     debugPrint("🌙 Midnight processing completed for previous day");
// // //   }
// // //
// // //   void _stopLocationMonitoring() {
// // //     _locationMonitorTimer?.cancel();
// // //     _locationMonitorTimer = null;
// // //     _autoClockOutInProgress = false;
// // //   }
// // //
// // //   // ✅ DIAGNOSTIC: Check GPX File Status
// // //   Future<void> _checkGPXFileStatus() async {
// // //     try {
// // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //       final downloadDirectory = await getDownloadsDirectory();
// // //
// // //       // Check both possible file formats
// // //       final filePath1 = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// // //       final filePath2 = "${downloadDirectory!.path}/track$date.gpx";
// // //
// // //       File file1 = File(filePath1);
// // //       File file2 = File(filePath2);
// // //
// // //       debugPrint("📁 FILE STATUS CHECK:");
// // //       debugPrint("   - File 1 ($filePath1): ${file1.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
// // //       if (file1.existsSync()) {
// // //         debugPrint("     Size: ${file1.lengthSync()} bytes");
// // //         debugPrint("     Points: ${await _countPointsInGPX(file1)}");
// // //       }
// // //
// // //       debugPrint("   - File 2 ($filePath2): ${file2.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
// // //       if (file2.existsSync()) {
// // //         debugPrint("     Size: ${file2.lengthSync()} bytes");
// // //         debugPrint("     Points: ${await _countPointsInGPX(file2)}");
// // //       }
// // //
// // //       // Check distance from LocationService
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double calculatedDistance = await locationService.calculateCurrentDistance();
// // //       debugPrint("   - Calculated Distance: ${calculatedDistance.toStringAsFixed(3)} km");
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ Error checking GPX status: $e");
// // //     }
// // //   }
// // //
// // //   Future<int> _countPointsInGPX(File file) async {
// // //     try {
// // //       String content = await file.readAsString();
// // //       if (content.isEmpty) return 0;
// // //
// // //       Gpx gpx = GpxReader().fromString(content);
// // //       int totalPoints = 0;
// // //
// // //       for (var track in gpx.trks) {
// // //         for (var segment in track.trksegs) {
// // //           totalPoints += segment.trkpts.length;
// // //         }
// // //       }
// // //
// // //       return totalPoints;
// // //     } catch (e) {
// // //       return 0;
// // //     }
// // //   }
// // // }
// // //
// //
// //
// //
// // ///26-12-2025 clockout auto
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_background_service/flutter_background_service.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // import 'package:rive/rive.dart';
// // import 'package:location/location.dart' as loc;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import '../../BatterySaverService.dart';
// // import '../../Databases/util.dart';
// // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // import '../../Tracker/location00.dart';
// // import '../../Tracker/trac.dart';
// // import '../../main.dart';
// // import 'assets.dart';
// // import 'menu_item.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:intl/intl.dart';
// // import 'package:gpx/gpx.dart';
// //
// // class TimerCard extends StatefulWidget {
// //   const TimerCard({super.key});
// //
// //   @override
// //   State<TimerCard> createState() => _TimerCardState();
// // }
// //
// // class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
// //   final locationViewModel = Get.find<LocationViewModel>();
// //   final attendanceViewModel = Get.find<AttendanceViewModel>();
// //   final attendanceOutViewModel = Get.find<AttendanceOutViewModel>();
// //   final updateFunctionViewModel = Get.find<UpdateFunctionViewModel>();
// //
// //   // ✅ ABDULLAH: Added Travel Time ViewModel initialization
// //   final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());
// //
// //   final loc.Location location = loc.Location();
// //   final Connectivity _connectivity = Connectivity();
// //
// //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// //   Timer? _locationMonitorTimer;
// //   bool _wasLocationAvailable = true;
// //   bool _autoClockOutInProgress = false;
// //
// //   bool _isRiveAnimationActive = false;
// //   Timer? _localBackupTimer;
// //   DateTime? _localClockInTime;
// //   String _localElapsedTime = '00:00:00';
// //
// //   // ✅ AUTO-SYNC VARIABLES
// //   Timer? _autoSyncTimer;
// //   bool _isOnline = false;
// //   bool _isSyncing = false; // ✅ ADD SYNC LOCK
// //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// //
// //   // ✅ ADD: Distance tracking
// //   double _currentDistance = 0.0;
// //   Timer? _distanceUpdateTimer;
// //
// //   // ✅ UPDATED: 11:58 PM AUTO CLOCK-OUT TIMER
// //   Timer? _elevenFiftyEightPMTimer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _initializeFromPersistentState();
// //     _startAutoSyncMonitoring();
// //     _setupMidnightProcessing();
// //     _startDistanceUpdater();
// //
// //     // ✅ START 11:58 PM DEVICE TIME CHECK
// //     _startElevenFiftyEightPMTimer();
// //     _startBatterySaverAutoClockOutMonitoring();
// //
// //     // ✅ CHECK FOR PENDING DATA ON STARTUP
// //     _checkAndSyncPendingData();
// //   }
// //
// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     _restoreEverything();
// //   }
// //
// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     _stopLocationMonitoring();
// //     _localBackupTimer?.cancel();
// //     _autoSyncTimer?.cancel();
// //     _connectivitySubscription?.cancel();
// //     _distanceUpdateTimer?.cancel();
// //     _elevenFiftyEightPMTimer?.cancel(); // ✅ STOP 11:58 PM TIMER
// //     super.dispose();
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     debugPrint("🔄 [LIFECYCLE] App state changed: $state");
// //
// //     if (state == AppLifecycleState.resumed) {
// //       _restoreEverything();
// //       _checkConnectivityAndSync();
// //
// //       // ✅ RESTART 11:58 PM TIMER WHEN APP RESUMES
// //       _startElevenFiftyEightPMTimer();
// //
// //       // ✅ CHECK FOR PENDING DATA WHEN APP RESUMES
// //       _checkAndSyncPendingData();
// //     }
// //   }
// //
// //   // ✅ NEW METHOD: Check and sync pending data
// //   void _checkAndSyncPendingData() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //     // Check for pending clock-out
// //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// //
// //     if (hasPendingClockOut || clockOutPending) {
// //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// //       _triggerAutoSync();
// //     }
// //   }
// //
// //   // ✅ BATTERY SAVER AUTO CLOCK-OUT MONITORING
// //   void _startBatterySaverAutoClockOutMonitoring() {
// //     Timer.periodic(const Duration(seconds: 10), (timer) async {
// //       if (!attendanceViewModel.isClockedIn.value) {
// //         return; // User not clocked in, no need to check
// //       }
// //
// //       try {
// //         bool isBatterySaverOn = await BatterySaverService.isBatterySaverOn();
// //
// //         if (isBatterySaverOn) {
// //           debugPrint("🔋 [BATTERY SAVER] Battery Saver ON detected - triggering auto clock-out");
// //           await _handleBatterySaverAutoClockOut();
// //         }
// //       } catch (e) {
// //         debugPrint("❌ Error checking battery saver: $e");
// //       }
// //     });
// //   }
// //
// //   // ✅ UPDATED: START 11:58 PM DEVICE TIME TIMER
// //   void _startElevenFiftyEightPMTimer() {
// //     // Cancel existing timer
// //     _elevenFiftyEightPMTimer?.cancel();
// //
// //     debugPrint("⏰ Starting 11:58 PM device time check");
// //
// //     // Check every minute if it's 11:58 PM
// //     _elevenFiftyEightPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// //       _checkForElevenFiftyEightPM();
// //     });
// //   }
// //
// //   // ✅ UPDATED: CHECK FOR 11:58 PM DEVICE TIME
// //   void _checkForElevenFiftyEightPM() async {
// //     try {
// //       // Get current device time
// //       DateTime now = DateTime.now();
// //
// //       // ✅ CHANGED: Check if it's exactly 11:58 PM (23:58)
// //       if (now.hour == 23 && now.minute == 58) {
// //         debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");
// //
// //         // Check if user is clocked in
// //         if (attendanceViewModel.isClockedIn.value) {
// //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
// //
// //           // Call auto clock-out at 11:58 PM
// //           await _handleElevenFiftyEightPMAutoClockOut();
// //         } else {
// //           debugPrint("⏰ User already clocked out at 11:58 PM");
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Error in 11:58 PM check: $e");
// //     }
// //   }
// //
// //   // ✅ BATTERY SAVER AUTO CLOCK-OUT
// //   Future<void> _handleBatterySaverAutoClockOut() async {
// //     if (_autoClockOutInProgress) return;
// //     _autoClockOutInProgress = true;
// //
// //     debugPrint("🔄 [BATTERY SAVER AUTO] Auto Clock-Out triggered - Battery Saver ON");
// //
// //     try {
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //
// //       // ✅ GET CURRENT DISTANCE
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double finalDistance = await locationService.calculateCurrentDistance();
// //       DateTime clockOutTime = DateTime.now();
// //
// //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// //       await _saveAllClockOutDataToPrefs(
// //         finalDistance: finalDistance,
// //         clockOutTime: clockOutTime,
// //         reason: 'battery_saver_auto',
// //       );
// //
// //       debugPrint("✅ [PREFERENCE] Battery saver auto clock-out data saved to SharedPreferences");
// //
// //       // 🔥 DAILY CONSOLIDATION
// //       await locationViewModel.consolidateDailyGPXData();
// //       debugPrint("✅ [BATTERY SAVER AUTO] All today's points merged");
// //
// //       // ✅ STOP TRAVEL TIME TRACKING
// //       travelTimeViewModel.stopTracking();
// //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (Battery Saver)");
// //
// //       locationViewModel.saveCurrentLocation().catchError((e)
// //       => debugPrint("Battery saver auto location error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //
// //       // UPDATE UI STATE
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //
// //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// //       await prefs.setBool('clockOutPending', true);
// //
// //       // UPDATE RIVE ANIMATION
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       // RESET LOCAL VARIABLES
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //       _currentDistance = 0.0;
// //
// //       // STOP BACKGROUND SERVICE
// //       service.invoke("stopService");
// //
// //       // ✅ SAVE ATTENDANCE OUT WITH BATTERY SAVER REASON
// //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// //         clockOutTime: clockOutTime,
// //         totalDistance: finalDistance,
// //         isAuto: true,
// //         reason: 'battery_saver_auto',
// //       );
// //
// //       // 🔥 24 HOURS DATA PROCESSING
// //       await locationViewModel.updateTodayCentralPoint();
// //       debugPrint("✅ [24HOURS] Daily GPX data processed (Battery Saver)");
// //
// //       // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
// //       await locationViewModel.saveLocationFromConsolidatedFile();
// //       debugPrint("💾 Location saved from consolidated file (Battery Saver)");
// //
// //       locationViewModel.saveClockStatus(false).catchError((e)
// //       => debugPrint("Battery saver clock status error: $e"));
// //
// //       await location.enableBackgroundMode(enable: false);
// //
// //       // ✅ SYNC after auto clock-out (FIRE AND FORGET)
// //       _triggerPostClockOutSync();
// //
// //       debugPrint("✅ [BATTERY SAVER AUTO] Auto Clock-Out completed");
// //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// //
// //       // Show battery saver auto clock-out notification
// //       Get.snackbar(
// //         '⚠️ Battery Saver Detected',
// //         'Auto clock-out due to Battery Saver mode. Data saved locally.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //         icon: Icon(Icons.battery_alert, color: Colors.white),
// //         mainButton: TextButton(
// //           onPressed: () {
// //             BatterySaverService.openBatterySaverSettings();
// //           },
// //           child: Text('SETTINGS', style: TextStyle(color: Colors.white)),
// //         ),
// //       );
// //
// //     } catch (e) {
// //       debugPrint("❌ [BATTERY SAVER AUTO] Error: $e");
// //
// //       // Emergency fallback - at least update the clock status
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       Get.snackbar(
// //         'Battery Saver Alert',
// //         'Please turn OFF Battery Saver for GPS tracking',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //       );
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
// //   // ✅ UPDATED: HANDLE 11:58 PM AUTO CLOCK-OUT
// //   Future<void> _handleElevenFiftyEightPMAutoClockOut() async {
// //     if (_autoClockOutInProgress) return;
// //     _autoClockOutInProgress = true;
// //
// //     debugPrint("🔄 [11:58 PM] Automatic clock-out triggered by device time");
// //
// //     try {
// //       // Stop monitoring timers
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //
// //       // ✅ GET CURRENT DATA
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double finalDistance = await locationService.calculateCurrentDistance();
// //       DateTime clockOutTime = DateTime.now();
// //
// //       // Adjust to exactly 11:58 PM
// //       clockOutTime = DateTime(clockOutTime.year, clockOutTime.month, clockOutTime.day, 23, 58, 0);
// //
// //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// //       await _saveAllClockOutDataToPrefs(
// //         finalDistance: finalDistance,
// //         clockOutTime: clockOutTime,
// //         reason: '11:58_pm_auto',
// //       );
// //
// //       debugPrint("✅ [PREFERENCE] 11:58 PM auto clock-out data saved to SharedPreferences");
// //
// //       // Save current location
// //       locationViewModel.saveCurrentLocation().catchError((e)
// //       => debugPrint("11:58 PM location error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //
// //       // Update UI state
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //
// //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// //       await prefs.setBool('clockOutPending', true);
// //
// //       // Update Rive animation
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       // Reset local variables
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //       _currentDistance = 0.0;
// //
// //       // Stop background service
// //       service.invoke("stopService");
// //
// //       // ✅ Save attendance with 11:58 PM timestamp
// //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// //         clockOutTime: clockOutTime,
// //         totalDistance: finalDistance,
// //         isAuto: true,
// //         reason: '11:58_pm_auto',
// //       );
// //
// //       // Process and save location data
// //       await locationViewModel.consolidateDailyGPXData();
// //       await locationViewModel.updateTodayCentralPoint();
// //       await locationViewModel.saveLocationFromConsolidatedFile();
// //       await locationViewModel.saveClockStatus(false);
// //
// //       // Disable background mode
// //       await location.enableBackgroundMode(enable: false);
// //
// //       // ✅ SYNC (FIRE AND FORGET)
// //       _triggerPostClockOutSync();
// //
// //       // Show notification
// //       Get.snackbar(
// //         'Auto Clock-Out',
// //         'Automatically clocked out at 11:58 PM. Data saved locally.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.purple.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //         icon: const Icon(Icons.access_time, color: Colors.white),
// //       );
// //
// //       debugPrint("✅ [11:58 PM] Auto clock-out completed successfully");
// //
// //     } catch (e) {
// //       debugPrint("❌ [11:58 PM] Error during auto clock-out: $e");
// //
// //       // Emergency fallback
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       Get.snackbar(
// //         'Auto Clock-Out',
// //         'System automatically ended your shift at 11:58 PM',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.purple.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //       );
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
// //   // ✅ NEW METHOD: Save all clock-out data to SharedPreferences
// //   Future<void> _saveAllClockOutDataToPrefs({
// //     required double finalDistance,
// //     required DateTime clockOutTime,
// //     String reason = 'manual',
// //   }) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //     // Save all critical data
// //     await prefs.setString('pendingClockOutTime', clockOutTime.toIso8601String());
// //     await prefs.setDouble('pendingTotalDistance', finalDistance);
// //     await prefs.setString('pendingClockOutReason', reason);
// //
// //     // Save location data
// //     await prefs.setDouble('pendingLatOut', locationViewModel.globalLatitude1.value);
// //     await prefs.setDouble('pendingLngOut', locationViewModel.globalLongitude1.value);
// //     await prefs.setString('pendingAddress', locationViewModel.shopAddress.value);
// //
// //     // ✅ IMPORTANT: Also save to a dedicated distance key
// //     await prefs.setDouble('lastClockOutDistance', finalDistance);
// //     await prefs.setDouble('clockOutDistance', finalDistance);
// //
// //     // Mark that we have pending clock-out data
// //     await prefs.setBool('hasPendingClockOutData', true);
// //
// //     debugPrint("📱 [PREFERENCE] Distance saved: ${finalDistance.toStringAsFixed(3)} km");
// //   }
// //
// //   // ✅ NEW METHOD: Trigger sync after clock-out (FIRE AND FORGET)
// //   void _triggerPostClockOutSync() async {
// //     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
// //
// //     try {
// //       // Check if we're online
// //       var results = await _connectivity.checkConnectivity();
// //       bool isOnline = results.isNotEmpty &&
// //           results.any((result) => result != ConnectivityResult.none);
// //
// //       if (isOnline && !_isSyncing) {
// //         _isSyncing = true;
// //
// //         // Try to sync all data
// //         await updateFunctionViewModel.syncAllLocalDataToServer();
// //
// //         // Clear pending flag if sync successful
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('hasPendingClockOutData', false);
// //         await prefs.setBool('clockOutPending', false);
// //
// //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// //
// //         // Show success notification
// //         Get.snackbar(
// //           'Sync Complete',
// //           'All data synchronized to server',
// //           snackPosition: SnackPosition.BOTTOM,
// //           backgroundColor: Colors.green,
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 2),
// //         );
// //       } else {
// //         debugPrint("🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
// //
// //         // Data is already saved in SharedPreferences, so it's safe
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('clockOutPending', true);
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
// //
// //       // Even on error, data is safe in SharedPreferences
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('clockOutPending', true);
// //     } finally {
// //       _isSyncing = false;
// //     }
// //   }
// //
// //   // GET GPX FILE NAME CONSISTENTLY
// //   String _getGpxFileName() {
// //     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //     return 'track_${user_id}_$date.gpx';
// //   }
// //
// //   String _getConsolidatedFileName() {
// //     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //     return 'track$date.gpx';
// //   }
// //
// //   // ✅ START DISTANCE UPDATER
// //   void _startDistanceUpdater() {
// //     _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
// //       if (attendanceViewModel.isClockedIn.value) {
// //         await _updateCurrentDistance();
// //       }
// //     });
// //   }
// //
// //   // ✅ UPDATE CURRENT DISTANCE
// //   Future<void> _updateCurrentDistance() async {
// //     try {
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double distance = await locationService.calculateCurrentDistance();
// //
// //       if (mounted) {
// //         setState(() {
// //           _currentDistance = distance;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Distance update error: $e");
// //     }
// //   }
// //
// //   // ✅ GET CURRENT DISTANCE
// //   Future<double> _getCurrentDistance() async {
// //     if (_currentDistance > 0) {
// //       return _currentDistance;
// //     }
// //
// //     try {
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       return await locationService.calculateCurrentDistance();
// //     } catch (e) {
// //       return 0.0;
// //     }
// //   }
// //
// //   // ✅ AUTO-SYNC MONITORING SYSTEM WITH SYNC LOCK
// //   void _startAutoSyncMonitoring() async {
// //     // Listen to connectivity changes
// //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
// //       bool wasOnline = _isOnline;
// //       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
// //
// //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'} | Was: ${wasOnline ? 'ONLINE' : 'OFFLINE'} | Syncing: $_isSyncing");
// //
// //       // ✅ FIX: Only trigger if we JUST came online AND not already syncing
// //       if (_isOnline && !wasOnline && !_isSyncing) {
// //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// //         _triggerAutoSync();
// //       }
// //     });
// //
// //     // ✅ FIX: Reduce frequency and add protection
// //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// //       if (!_isSyncing) {
// //         _checkConnectivityAndSync();
// //       }
// //     });
// //
// //     _checkConnectivityAndSync();
// //   }
// //
// //   // ✅ CHECK CONNECTIVITY AND SYNC WITH PROTECTION
// //   void _checkConnectivityAndSync() async {
// //     if (_isSyncing) {
// //       debugPrint('⏸️ Sync already in progress - skipping');
// //       return;
// //     }
// //
// //     try {
// //       var results = await _connectivity.checkConnectivity();
// //       bool wasOnline = _isOnline;
// //       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
// //
// //       if (_isOnline && !wasOnline && !_isSyncing) {
// //         debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
// //         _triggerAutoSync();
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
// //     }
// //   }
// //
// //   // ✅ TRIGGER AUTO-SYNC WITH SYNC LOCKING
// //   void _triggerAutoSync() async {
// //     // Prevent multiple simultaneous syncs
// //     if (_isSyncing) {
// //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// //       return;
// //     }
// //
// //     _isSyncing = true; // Lock sync
// //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// //
// //     try {
// //       // Show subtle notification
// //       Get.snackbar(
// //         'Syncing Data',
// //         'Auto-syncing offline data...',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.blue.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //
// //       // Sync all local data to server
// //       await updateFunctionViewModel.syncAllLocalDataToServer();
// //
// //       // ✅ Clear pending flags if sync successful
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('hasPendingClockOutData', false);
// //       await prefs.setBool('clockOutPending', false);
// //
// //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// //
// //     } catch (e) {
// //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// //     } finally {
// //       _isSyncing = false; // Release lock
// //       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
// //     }
// //   }
// //
// //   void _restoreEverything() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// //
// //     if (isClockedIn) {
// //       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
// //
// //       locationViewModel.isClockedIn.value = true;
// //       attendanceViewModel.isClockedIn.value = true;
// //
// //       _isRiveAnimationActive = true;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = true;
// //       }
// //
// //       _startLocalBackupTimer();
// //
// //       if (mounted) {
// //         setState(() {});
// //       }
// //
// //       debugPrint("✅ [BULLETPROOF] Everything restored successfully");
// //     }
// //   }
// //
// //   void _startLocalBackupTimer() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? clockInTimeString = prefs.getString('clockInTime');
// //
// //     if (clockInTimeString == null) return;
// //
// //     _localClockInTime = DateTime.parse(clockInTimeString);
// //     _localBackupTimer?.cancel();
// //
// //     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (_localClockInTime == null) return;
// //
// //       final now = DateTime.now();
// //       final duration = now.difference(_localClockInTime!);
// //
// //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// //       String hours = twoDigits(duration.inHours);
// //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// //
// //       _localElapsedTime = '$hours:$minutes:$seconds';
// //       attendanceViewModel.elapsedTime.value = _localElapsedTime;
// //
// //       if (mounted) {
// //         setState(() {});
// //       }
// //     });
// //
// //     debugPrint("✅ [BACKUP TIMER] Local backup timer started");
// //   }
// //
// //   Future<void> _initializeFromPersistentState() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// //
// //     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn");
// //
// //     locationViewModel.isClockedIn.value = isClockedIn;
// //     attendanceViewModel.isClockedIn.value = isClockedIn;
// //     _isRiveAnimationActive = isClockedIn;
// //
// //     if (isClockedIn) {
// //       debugPrint("✅ [INIT] User was clocked in - starting everything...");
// //
// //       _startBackgroundServices();
// //       _startLocationMonitoring();
// //       _startLocalBackupTimer();
// //
// //       debugPrint("✅ [INIT] Full clocked-in state restored");
// //     }
// //
// //     if (mounted) {
// //       setState(() {});
// //     }
// //   }
// //
// //   void onThemeRiveIconInit(Artboard artboard) {
// //     final controller = StateMachineController.fromArtboard(
// //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// //     if (controller != null) {
// //       artboard.addController(controller);
// //       _themeMenuIcon[0].riveIcon.status =
// //       controller.findInput<bool>("active") as SMIBool?;
// //
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// //         debugPrint("🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// //       }
// //     } else {
// //       debugPrint("StateMachineController not found!");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Time display
// //               Obx(() {
// //                 String displayTime = _localElapsedTime;
// //                 if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
// //                   displayTime = attendanceViewModel.elapsedTime.value;
// //                 }
// //
// //                 return Text(
// //                   displayTime,
// //                   style: const TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 );
// //               }),
// //               // ✅ ADD: Distance display
// //               Obx(() {
// //                 if (attendanceViewModel.isClockedIn.value) {
// //                   return FutureBuilder<double>(
// //                     future: _getCurrentDistance(),
// //                     builder: (context, snapshot) {
// //                       if (snapshot.hasData && snapshot.data! > 0) {
// //                         return Text(
// //                           '${snapshot.data!.toStringAsFixed(2)} km',
// //                           style: TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.blue.shade700,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         );
// //                       }
// //                       return const SizedBox.shrink();
// //                     },
// //                   );
// //                 }
// //                 return const SizedBox.shrink();
// //               }),
// //             ],
// //           ),
// //           Obx(() {
// //             return ElevatedButton(
// //               onPressed: () async {
// //                 debugPrint("🎯 [BUTTON] Button pressed");
// //                 debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");
// //
// //                 if (attendanceViewModel.isClockedIn.value) {
// //                   await _handleClockOut(context);
// //                 } else {
// //                   await _handleClockIn(context);
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: attendanceViewModel.isClockedIn.value
// //                     ? Colors.redAccent
// //                     : Colors.green,
// //                 minimumSize: const Size(30, 30),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 padding: EdgeInsets.zero,
// //               ),
// //               child: SizedBox(
// //                 width: 35,
// //                 height: 35,
// //                 child: RiveAnimation.asset(
// //                   iconsRiv,
// //                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// //                   artboard: _themeMenuIcon[0].riveIcon.artboard,
// //                   onInit: onThemeRiveIconInit,
// //                   fit: BoxFit.cover,
// //                 ),
// //               ),
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ FIXED: Clock-in method with proper GPX file creation
// //   Future<void> _handleClockIn(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// //
// //     // ✅ STEP 1: Check Battery Saver FIRST
// //     bool batterySaverValid = await BatterySaverService.checkBatterySaverForClockIn(context);
// //     if (!batterySaverValid) {
// //       debugPrint("❌ [BATTERY SAVER] Clock-in blocked - Battery Saver is ON");
// //       return; // Stop here if battery saver is ON
// //     }
// //
// //     // ✅ STEP 2: Location check (existing code)
// //     bool locationAvailable = await attendanceViewModel.isLocationAvailable();
// //     if (!locationAvailable) {
// //       Get.snackbar(
// //         'Location Required',
// //         'Please enable Location Services to clock in',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //       );
// //       return;
// //     }
// //
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     try {
// //       // ✅ STEP 3: Double-check battery saver before proceeding
// //       bool finalBatteryCheck = await BatterySaverService.isBatterySaverOn();
// //       if (finalBatteryCheck) {
// //         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //         Get.snackbar(
// //           'Battery Saver Detected',
// //           'Please turn OFF Battery Saver to clock in',
// //           snackPosition: SnackPosition.TOP,
// //           backgroundColor: Colors.orange.shade700,
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 5),
// //         );
// //         return;
// //       }
// //
// //       // ✅ FIX: Clear previous session data
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //       // ✅ FIX 1: Initialize LocationService PROPERLY
// //       LocationService locationService = LocationService();
// //
// //       // ✅ FIX 2: Call init() to load user data BEFORE listenLocation()
// //       await locationService.init();
// //
// //       // ✅ FIX 3: Start location listening
// //       await locationService.listenLocation();
// //
// //       // ✅ FIX 4: Verify GPX file was created
// //       await Future.delayed(const Duration(seconds: 2)); // Give time for file creation
// //
// //       // Check if GPX file exists
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       final downloadDirectory = await getDownloadsDirectory();
// //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// //       File file = File(filePath);
// //
// //       if (!file.existsSync()) {
// //         debugPrint("⚠️ GPX file was not created at: $filePath");
// //         // Create an empty GPX file with proper structure
// //         String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
// // <gpx version="1.1" creator="OrderBookingApp">
// //   <trk>
// //     <name>Daily Track $date</name>
// //     <trkseg>
// //     </trkseg>
// //   </trk>
// // </gpx>''';
// //         await file.writeAsString(initialGPX);
// //         debugPrint("✅ Created empty GPX file for tracking");
// //       }
// //
// //       // ✅ FIX 5: Check initial distance (should be 0)
// //       double initialDistance = locationService.getCurrentDistance();
// //       debugPrint("📍 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
// //
// //       if (initialDistance > 0.001) { // If more than 1 meter
// //         debugPrint("⚠️ Suspicious initial distance, resetting...");
// //         locationService.resetDistance();
// //         initialDistance = 0.0;
// //       }
// //
// //       // ✅ FIX 6: Save clock-in data
// //       await attendanceViewModel.saveFormAttendanceIn();
// //       _startBackgroundServices();
// //
// //       locationViewModel.isClockedIn.value = true;
// //       attendanceViewModel.isClockedIn.value = true;
// //
// //       await prefs.setBool('isClockedIn', true);
// //
// //       // ✅ FIX 7: Also save the file path for verification
// //       await prefs.setString('currentGpxFilePath', filePath);
// //
// //       // ✅ FIX: Save session info
// //       await prefs.setString('currentSessionStart', DateTime.now().toIso8601String());
// //
// //       _isRiveAnimationActive = true;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = true;
// //       }
// //
// //       _startLocalBackupTimer();
// //       _startLocationMonitoring();
// //
// //       travelTimeViewModel.startTracking();
// //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// //
// //       // ✅ UPDATE DISTANCE DISPLAY
// //       await _updateCurrentDistance();
// //
// //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// //       debugPrint("📏 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
// //       debugPrint("📁 GPX File: $filePath");
// //       debugPrint("📊 File Size: ${file.lengthSync()} bytes");
// //
// //       // Show success message
// //       Get.snackbar(
// //         'Clocked In Successfully',
// //         'GPS tracking started',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //
// //     } catch (e) {
// //       debugPrint("❌ [CLOCK-IN] Error: $e");
// //       Get.snackbar('Error', 'Failed to clock in: $e',
// //           snackPosition: SnackPosition.TOP,
// //           backgroundColor: Colors.red,
// //           colorText: Colors.white);
// //     } finally {
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //     }
// //   }
// //
// //   void _startBackgroundServices() async {
// //     try {
// //       debugPrint("🛰 [BACKGROUND] Starting services...");
// //
// //       final service = FlutterBackgroundService();
// //       await location.enableBackgroundMode(enable: true);
// //
// //       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
// //       service.startService().catchError((e) => debugPrint("Service start error: $e"));
// //       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
// //           .catchError((e) => debugPrint("Location settings error: $e"));
// //
// //       debugPrint("✅ [BACKGROUND] Services started");
// //     } catch (e) {
// //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// //     }
// //   }
// //
// //   // ✅ ENHANCED: Clock-out method with proper distance handling
// //   Future<void> _handleClockOut(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-OUT STARTED =====");
// //
// //     // ✅ ADD: Check GPX status before proceeding
// //     await _checkGPXFileStatus();
// //
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     try {
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //
// //       // ✅ STEP 1: GET ACCURATE DISTANCE FROM LOCATION SERVICE
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //
// //       // ✅ IMPORTANT: Calculate distance from LocationService first
// //       double finalDistance = await locationService.calculateCurrentDistance();
// //       debugPrint("📍 [DISTANCE] Calculated from LocationService: ${finalDistance.toStringAsFixed(3)} km");
// //
// //       // ✅ ALSO: Get distance from GPX file for verification
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       final downloadDirectory = await getDownloadsDirectory();
// //       final individualFilePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// //       File individualFile = File(individualFilePath);
// //
// //       double gpxDistance = 0.0;
// //       if (individualFile.existsSync()) {
// //         gpxDistance = await _calculateDistanceFromGPX(individualFile);
// //         debugPrint("📍 [GPX DISTANCE] From individual file: ${gpxDistance.toStringAsFixed(3)} km");
// //       }
// //
// //       // ✅ USE THE HIGHER OF THE TWO DISTANCES (more accurate)
// //       double actualDistance = finalDistance > gpxDistance ? finalDistance : gpxDistance;
// //       debugPrint("📍 [FINAL DISTANCE] Selected: ${actualDistance.toStringAsFixed(3)} km");
// //
// //       DateTime clockOutTime = DateTime.now();
// //
// //       // ✅ STEP 2: SAVE ALL DATA TO SHARED PREFERENCES FIRST (IMMEDIATE)
// //       await _saveAllClockOutDataToPrefs(
// //         finalDistance: actualDistance,
// //         clockOutTime: clockOutTime,
// //       );
// //
// //       debugPrint("✅ [PREFERENCE] All clock-out data saved to SharedPreferences");
// //
// //       // 🔥 DAILY CONSOLIDATION
// //       await locationViewModel.consolidateDailyGPXData();
// //       debugPrint("✅ [CONSOLIDATION] All today's points merged into single file");
// //
// //       // ✅ STOP TRAVEL TIME TRACKING
// //       travelTimeViewModel.stopTracking();
// //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped");
// //
// //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Location save error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       // ✅ SAVE DISTANCE TO SHAREDPREFERENCES FOR ATTENDANCE VIEWMODEL
// //       await prefs.setDouble('clockOutDistance', actualDistance);
// //
// //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// //       await prefs.setBool('clockOutPending', true);
// //
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //
// //       // ✅ RESET DISTANCE DISPLAY
// //       setState(() {
// //         _currentDistance = 0.0;
// //       });
// //
// //       service.invoke("stopService");
// //
// //       // ✅ ATTENDANCE OUT: Pass the distance and time
// //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// //         clockOutTime: clockOutTime,
// //         totalDistance: actualDistance,
// //       );
// //
// //       // 🔥 24 HOURS DATA PROCESSING
// //       await locationViewModel.updateTodayCentralPoint();
// //       debugPrint("✅ [24HOURS] Daily GPX data processed from SINGLE FILE");
// //
// //       // ✅ VERIFY: Check if consolidated file exists
// //       final consolidatedFilePath = '${downloadDirectory!.path}/track$date.gpx';
// //       File consolidatedFile = File(consolidatedFilePath);
// //
// //       if (consolidatedFile.existsSync()) {
// //         debugPrint("✅ CONFIRMED: Consolidated GPX file exists");
// //         debugPrint("   - Size: ${consolidatedFile.lengthSync()} bytes");
// //
// //         // Calculate and display actual distance from file
// //         double consolidatedDistance = await locationViewModel.calculateTotalDistance(consolidatedFilePath);
// //         debugPrint("   - Consolidated Distance: ${consolidatedDistance.toStringAsFixed(3)} km");
// //
// //         // Update SharedPreferences with actual distance
// //         await prefs.setDouble('consolidatedDistance', consolidatedDistance);
// //       }
// //
// //       // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
// //       await locationViewModel.saveLocationFromConsolidatedFile();
// //       debugPrint("💾 Location saved from consolidated file");
// //
// //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Clock status error: $e"));
// //
// //       await location.enableBackgroundMode(enable: false);
// //
// //       // ✅ STEP 3: TRIGGER AUTO-SYNC (FIRE AND FORGET)
// //       _triggerPostClockOutSync();
// //
// //       debugPrint("✅ [CLOCK-OUT] ===== COMPLETED SUCCESSFULLY =====");
// //       debugPrint("📏 Final Distance Posted: ${actualDistance.toStringAsFixed(3)} km");
// //
// //       // ✅ QUICK SUCCESS MESSAGE
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         'Clock Out Complete',
// //         'Distance: ${actualDistance.toStringAsFixed(2)} km\nData saved locally',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //
// //     } catch (e) {
// //       debugPrint("❌ [CLOCK-OUT] Error: $e");
// //
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         'Clock Out Complete',
// //         'Data saved locally. Will sync when online.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //     }
// //   }
// //
// //   // ✅ NEW METHOD: Calculate distance from GPX file
// //   Future<double> _calculateDistanceFromGPX(File file) async {
// //     try {
// //       if (!file.existsSync()) return 0.0;
// //
// //       String content = await file.readAsString();
// //       if (content.isEmpty) return 0.0;
// //
// //       Gpx gpx = GpxReader().fromString(content);
// //       double totalDistance = 0.0;
// //
// //       for (var track in gpx.trks) {
// //         for (var segment in track.trksegs) {
// //           if (segment.trkpts.length < 2) continue;
// //
// //           for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //             double distance = Geolocator.distanceBetween(
// //               segment.trkpts[i].lat ?? 0.0,
// //               segment.trkpts[i].lon ?? 0.0,
// //               segment.trkpts[i + 1].lat ?? 0.0,
// //               segment.trkpts[i + 1].lon ?? 0.0,
// //             ) / 1000; // Convert to kilometers
// //
// //             totalDistance += distance;
// //           }
// //         }
// //       }
// //
// //       return totalDistance;
// //     } catch (e) {
// //       debugPrint("❌ Error calculating distance from GPX: $e");
// //       return 0.0;
// //     }
// //   }
// //
// //   Future<void> _handleAutoClockOut() async {
// //     if (_autoClockOutInProgress) return;
// //     _autoClockOutInProgress = true;
// //     debugPrint("🔄 [AUTO] Auto Clock-Out triggered due to location OFF");
// //
// //     try {
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //
// //       // ✅ GET CURRENT DISTANCE
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double finalDistance = await locationService.calculateCurrentDistance();
// //       DateTime clockOutTime = DateTime.now();
// //
// //       // ✅ STEP 1: SAVE ALL DATA TO SHARED PREFERENCES FIRST
// //       await _saveAllClockOutDataToPrefs(
// //         finalDistance: finalDistance,
// //         clockOutTime: clockOutTime,
// //         reason: 'location_off_auto',
// //       );
// //
// //       debugPrint("✅ [PREFERENCE] Auto clock-out data saved to SharedPreferences");
// //
// //       // 🔥 DAILY CONSOLIDATION
// //       await locationViewModel.consolidateDailyGPXData();
// //       debugPrint("✅ [CONSOLIDATION] All today's points merged (Auto Clock-Out)");
// //
// //       // ✅ STOP TRAVEL TIME TRACKING
// //       travelTimeViewModel.stopTracking();
// //       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (auto clock-out)");
// //
// //       locationViewModel.saveCurrentLocation().catchError((e) => debugPrint("Auto clock-out location error: $e"));
// //
// //       final service = FlutterBackgroundService();
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //
// //       // ✅ UPDATE: Mark clock-out status in SharedPreferences
// //       await prefs.setBool('clockOutPending', true);
// //
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //
// //       // ✅ RESET DISTANCE DISPLAY
// //       setState(() {
// //         _currentDistance = 0.0;
// //       });
// //
// //       service.invoke("stopService");
// //
// //       // ✅ ATTENDANCE OUT with auto flag
// //       await attendanceOutViewModel.saveFormAttendanceOutWithPrefs(
// //         clockOutTime: clockOutTime,
// //         totalDistance: finalDistance,
// //         isAuto: true,
// //         reason: 'location_off_auto',
// //       );
// //
// //       // 🔥 24 HOURS DATA PROCESSING
// //       await locationViewModel.updateTodayCentralPoint();
// //       debugPrint("✅ [24HOURS] Daily GPX data processed from SINGLE FILE (Auto Clock-Out)");
// //
// //       // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
// //       await locationViewModel.saveLocationFromConsolidatedFile();
// //       debugPrint("💾 Location saved from consolidated file (Auto Clock-Out)");
// //
// //       locationViewModel.saveClockStatus(false).catchError((e) => debugPrint("Auto clock status error: $e"));
// //
// //       await location.enableBackgroundMode(enable: false);
// //
// //       // ✅ SYNC after auto clock-out (FIRE AND FORGET)
// //       _triggerPostClockOutSync();
// //
// //       debugPrint("✅ [AUTO] Auto Clock-Out completed");
// //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// //
// //       // Show auto clock-out notification
// //       Get.snackbar(
// //         'Auto Clock Out',
// //         'Location services turned off. Data saved locally.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //       );
// //     } catch (e) {
// //       debugPrint("❌ [AUTO] Auto clock-out error: $e");
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
// //   void _startLocationMonitoring() {
// //     _wasLocationAvailable = true;
// //     _autoClockOutInProgress = false;
// //
// //     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
// //       if (!attendanceViewModel.isClockedIn.value) {
// //         _stopLocationMonitoring();
// //         return;
// //       }
// //
// //       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
// //
// //       if (_wasLocationAvailable && !currentLocationAvailable) {
// //         debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
// //         await _handleAutoClockOut();
// //       }
// //
// //       _wasLocationAvailable = currentLocationAvailable;
// //     });
// //   }
// //
// //   // TimerCard mein add karein
// //   void _setupMidnightProcessing() {
// //     // Calculate time until next midnight
// //     DateTime now = DateTime.now();
// //     DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
// //     Duration timeUntilMidnight = nextMidnight.difference(now);
// //
// //     Timer(timeUntilMidnight, () {
// //       // Process previous day's data
// //       _processPreviousDayData();
// //
// //       // Setup for next day
// //       _setupMidnightProcessing();
// //     });
// //   }
// //
// //   Future<void> _processPreviousDayData() async {
// //     debugPrint("🌙 Processing previous day's data at midnight");
// //
// //     // 🔥 DAILY CONSOLIDATION PEHLE CALL KAREN
// //     await locationViewModel.consolidateDailyGPXData();
// //     debugPrint("✅ [MIDNIGHT] Previous day's data consolidated");
// //
// //     await locationViewModel.updateTodayCentralPoint();
// //     await locationViewModel.generateDailySummary();
// //
// //     debugPrint("🌙 Midnight processing completed for previous day");
// //   }
// //
// //   void _stopLocationMonitoring() {
// //     _locationMonitorTimer?.cancel();
// //     _locationMonitorTimer = null;
// //     _autoClockOutInProgress = false;
// //   }
// //
// //   // ✅ DIAGNOSTIC: Check GPX File Status
// //   Future<void> _checkGPXFileStatus() async {
// //     try {
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       final downloadDirectory = await getDownloadsDirectory();
// //
// //       // Check both possible file formats
// //       final filePath1 = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// //       final filePath2 = "${downloadDirectory!.path}/track$date.gpx";
// //
// //       File file1 = File(filePath1);
// //       File file2 = File(filePath2);
// //
// //       debugPrint("📁 FILE STATUS CHECK:");
// //       debugPrint("   - File 1 ($filePath1): ${file1.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
// //       if (file1.existsSync()) {
// //         debugPrint("     Size: ${file1.lengthSync()} bytes");
// //         debugPrint("     Points: ${await _countPointsInGPX(file1)}");
// //       }
// //
// //       debugPrint("   - File 2 ($filePath2): ${file2.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
// //       if (file2.existsSync()) {
// //         debugPrint("     Size: ${file2.lengthSync()} bytes");
// //         debugPrint("     Points: ${await _countPointsInGPX(file2)}");
// //       }
// //
// //       // Check distance from LocationService
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double calculatedDistance = await locationService.calculateCurrentDistance();
// //       debugPrint("   - Calculated Distance: ${calculatedDistance.toStringAsFixed(3)} km");
// //
// //     } catch (e) {
// //       debugPrint("❌ Error checking GPX status: $e");
// //     }
// //   }
// //
// //   Future<int> _countPointsInGPX(File file) async {
// //     try {
// //       String content = await file.readAsString();
// //       if (content.isEmpty) return 0;
// //
// //       Gpx gpx = GpxReader().fromString(content);
// //       int totalPoints = 0;
// //
// //       for (var track in gpx.trks) {
// //         for (var segment in track.trksegs) {
// //           totalPoints += segment.trkpts.length;
// //         }
// //       }
// //
// //       return totalPoints;
// //     } catch (e) {
// //       return 0;
// //     }
// //   }
// //
// //   // ✅ DEBUG METHOD: Check distance calculation
// //   Future<void> _debugDistanceCalculation() async {
// //     try {
// //       debugPrint("🔍 [DISTANCE DEBUG] Starting distance verification...");
// //
// //       // 1. Get from LocationService
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double serviceDistance = await locationService.calculateCurrentDistance();
// //       debugPrint("📍 [DEBUG] LocationService distance: ${serviceDistance.toStringAsFixed(3)} km");
// //
// //       // 2. Get from GPX file
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       final downloadDirectory = await getDownloadsDirectory();
// //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// //       File file = File(filePath);
// //
// //       double fileDistance = 0.0;
// //       if (file.existsSync()) {
// //         fileDistance = await _calculateDistanceFromGPX(file);
// //         debugPrint("📍 [DEBUG] GPX file distance: ${fileDistance.toStringAsFixed(3)} km");
// //       }
// //
// //       // 3. Get from SharedPreferences
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       double prefDistance = prefs.getDouble('clockOutDistance') ?? 0.0;
// //       debugPrint("📍 [DEBUG] SharedPreferences distance: ${prefDistance.toStringAsFixed(3)} km");
// //
// //       debugPrint("🔍 [DISTANCE DEBUG] Verification complete");
// //
// //     } catch (e) {
// //       debugPrint("❌ [DISTANCE DEBUG] Error: $e");
// //     }
// //   }
// // }
//
// ///for fast out
// ///26-12-2025 clockout auto
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// import 'package:rive/rive.dart';
// import 'package:location/location.dart' as loc;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import '../../BatterySaverService.dart';
// import '../../Databases/util.dart';
// import '../../LocatioPoints/ravelTimeViewModel.dart';
// import '../../Tracker/location00.dart';
// import '../../Tracker/trac.dart';
// import '../../main.dart';
// import 'assets.dart';
// import 'menu_item.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:gpx/gpx.dart';
//
// class TimerCard extends StatefulWidget {
//   const TimerCard({super.key});
//
//   @override
//   State<TimerCard> createState() => _TimerCardState();
// }
//
// class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
//   final locationViewModel = Get.find<LocationViewModel>();
//   final attendanceViewModel = Get.find<AttendanceViewModel>();
//   final attendanceOutViewModel = Get.find<AttendanceOutViewModel>();
//   final updateFunctionViewModel = Get.find<UpdateFunctionViewModel>();
//
//   // ✅ ABDULLAH: Added Travel Time ViewModel initialization
//   final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());
//
//   final loc.Location location = loc.Location();
//   final Connectivity _connectivity = Connectivity();
//
//   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
//   Timer? _locationMonitorTimer;
//   bool _wasLocationAvailable = true;
//   bool _autoClockOutInProgress = false;
//
//   bool _isRiveAnimationActive = false;
//   Timer? _localBackupTimer;
//   DateTime? _localClockInTime;
//   String _localElapsedTime = '00:00:00';
//
//   // ✅ AUTO-SYNC VARIABLES
//   Timer? _autoSyncTimer;
//   bool _isOnline = false;
//   bool _isSyncing = false; // ✅ ADD SYNC LOCK
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//
//   // ✅ ADD: Distance tracking
//   double _currentDistance = 0.0;
//   Timer? _distanceUpdateTimer;
//
//   // ✅ UPDATED: 11:58 PM AUTO CLOCK-OUT TIMER
//   Timer? _elevenFiftyEightPMTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeFromPersistentState();
//     _startAutoSyncMonitoring();
//     _setupMidnightProcessing();
//     _startDistanceUpdater();
//
//     // ✅ START 11:58 PM DEVICE TIME CHECK
//     _startElevenFiftyEightPMTimer();
//     _startBatterySaverAutoClockOutMonitoring();
//
//     // ✅ CHECK FOR PENDING DATA ON STARTUP
//     _checkAndSyncPendingData();
//
//     // ✅ CHECK FOR FAST SAVED DATA ON STARTUP
//     _checkForFastSavedData();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _restoreEverything();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopLocationMonitoring();
//     _localBackupTimer?.cancel();
//     _autoSyncTimer?.cancel();
//     _connectivitySubscription?.cancel();
//     _distanceUpdateTimer?.cancel();
//     _elevenFiftyEightPMTimer?.cancel(); // ✅ STOP 11:58 PM TIMER
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     debugPrint("🔄 [LIFECYCLE] App state changed: $state");
//
//     if (state == AppLifecycleState.resumed) {
//       _restoreEverything();
//       _checkConnectivityAndSync();
//
//       // ✅ RESTART 11:58 PM TIMER WHEN APP RESUMES
//       _startElevenFiftyEightPMTimer();
//
//       // ✅ CHECK FOR PENDING DATA WHEN APP RESUMES
//       _checkAndSyncPendingData();
//     }
//   }
//
//   // ✅ CHECK FOR FAST SAVED DATA
//   void _checkForFastSavedData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasFastData = prefs.getBool('hasFastClockOutData') ?? false;
//
//     if (hasFastData) {
//       debugPrint("🔄 Fast clock-out data found - user clocked out quickly");
//
//       // Update UI state
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       _isRiveAnimationActive = false;
//
//       // Trigger background sync
//       _triggerPostClockOutSync();
//     }
//   }
//
//   // ✅ NEW METHOD: Check and sync pending data
//   void _checkAndSyncPendingData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Check for pending clock-out
//     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
//     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
//
//     if (hasPendingClockOut || clockOutPending) {
//       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
//       _triggerAutoSync();
//     }
//   }
//
//   // ✅ BATTERY SAVER AUTO CLOCK-OUT MONITORING
//   void _startBatterySaverAutoClockOutMonitoring() {
//     Timer.periodic(const Duration(seconds: 10), (timer) async {
//       if (!attendanceViewModel.isClockedIn.value) {
//         return; // User not clocked in, no need to check
//       }
//
//       try {
//         bool isBatterySaverOn = await BatterySaverService.isBatterySaverOn();
//
//         if (isBatterySaverOn) {
//           debugPrint("🔋 [BATTERY SAVER] Battery Saver ON detected - triggering auto clock-out");
//           await _handleBatterySaverAutoClockOut();
//         }
//       } catch (e) {
//         debugPrint("❌ Error checking battery saver: $e");
//       }
//     });
//   }
//
//   // ✅ UPDATED: START 11:58 PM DEVICE TIME TIMER
//   void _startElevenFiftyEightPMTimer() {
//     // Cancel existing timer
//     _elevenFiftyEightPMTimer?.cancel();
//
//     debugPrint("⏰ Starting 11:58 PM device time check");
//
//     // Check every minute if it's 11:58 PM
//     _elevenFiftyEightPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkForElevenFiftyEightPM();
//     });
//   }
//
//   // ✅ UPDATED: CHECK FOR 11:58 PM DEVICE TIME
//   void _checkForElevenFiftyEightPM() async {
//     try {
//       // Get current device time
//       DateTime now = DateTime.now();
//
//       // ✅ CHANGED: Check if it's exactly 11:58 PM (23:58)
//       if (now.hour == 23 && now.minute == 58) {
//         debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");
//
//         // Check if user is clocked in
//         if (attendanceViewModel.isClockedIn.value) {
//           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
//
//           // Call fast auto clock-out at 11:58 PM
//           await _handleFastElevenFiftyEightPMAutoClockOut();
//         } else {
//           debugPrint("⏰ User already clocked out at 11:58 PM");
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error in 11:58 PM check: $e");
//     }
//   }
//
//   // ✅ UPDATED: FAST 11:58 PM AUTO CLOCK-OUT (2-3 seconds)
//   Future<void> _handleFastElevenFiftyEightPMAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//
//     debugPrint("⚡ [11:58 PM] Fast auto clock-out triggered");
//
//     try {
//       // ✅ IMMEDIATE STATE CHANGES (0.5 seconds)
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // Get distance quickly
//       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
//       DateTime clockOutTime = DateTime.now();
//
//       // Adjust to exactly 11:58 PM
//       clockOutTime = DateTime(clockOutTime.year, clockOutTime.month, clockOutTime.day, 23, 58, 0);
//
//       // ✅ SAVE TO PREFERENCES IMMEDIATELY
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//       await prefs.setString('fastClockOutReason', '11:58_pm_auto');
//
//       // ✅ UPDATE UI STATE IMMEDIATELY
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       // ✅ QUICK SAVE TO ATTENDANCE OUT
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//         isAuto: true,
//         reason: '11:58_pm_auto',
//       );
//
//       // ✅ STOP BACKGROUND SERVICES QUICKLY
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       // ✅ SHOW SUCCESS NOTIFICATION
//       Get.snackbar(
//         'Auto Clock-Out',
//         'Automatically clocked out at 11:58 PM',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.purple.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: const Icon(Icons.access_time, color: Colors.white),
//       );
//
//       debugPrint("✅ [11:58 PM] Fast auto clock-out completed in <3 seconds");
//
//       // ✅ SCHEDULE HEAVY OPERATIONS FOR LATER
//       _scheduleHeavyOperations(clockOutTime, finalDistance);
//
//     } catch (e) {
//       debugPrint("❌ [11:58 PM] Fast auto clock-out error: $e");
//
//       // Emergency fallback
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   // ✅ BATTERY SAVER AUTO CLOCK-OUT (FAST VERSION)
//   Future<void> _handleBatterySaverAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//
//     debugPrint("⚡ [BATTERY SAVER] Fast auto clock-out triggered");
//
//     try {
//       // ✅ IMMEDIATE STATE CHANGES
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
//       DateTime clockOutTime = DateTime.now();
//
//       // ✅ SAVE TO PREFERENCES IMMEDIATELY
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//       await prefs.setString('fastClockOutReason', 'battery_saver_auto');
//
//       // ✅ UPDATE UI STATE IMMEDIATELY
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       // ✅ QUICK SAVE TO ATTENDANCE OUT
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//         isAuto: true,
//         reason: 'battery_saver_auto',
//       );
//
//       // ✅ STOP BACKGROUND SERVICES QUICKLY
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       // ✅ SHOW BATTERY SAVER NOTIFICATION
//       Get.snackbar(
//         '⚠️ Battery Saver Detected',
//         'Auto clock-out completed. Data saved locally.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: Icon(Icons.battery_alert, color: Colors.white),
//       );
//
//       debugPrint("✅ [BATTERY SAVER] Fast auto clock-out completed in <3 seconds");
//
//       // ✅ SCHEDULE HEAVY OPERATIONS FOR LATER
//       _scheduleHeavyOperations(clockOutTime, finalDistance);
//
//     } catch (e) {
//       debugPrint("❌ [BATTERY SAVER] Fast auto clock-out error: $e");
//
//       // Emergency fallback
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   // ✅ ULTRA-FAST CLOCK-OUT METHOD - COMPLETES IN 2-3 SECONDS
//   // ✅ ULTRA-FAST CLOCK-OUT METHOD - COMPLETES IN 2-3 SECONDS
//   Future<void> _handleClockOut(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
//
//     // ✅ STEP 0: SHOW LOADING DIALOG FOR MINIMUM 3 SECONDS
//     bool showLoadingDialog = true;
//     DateTime startTime = DateTime.now();
//     Timer? loadingTimer;
//
//     if (showLoadingDialog) {
//       showDialog(
//         context: context,
//         barrierDismissible: false, // Change to false so user can't dismiss
//         builder: (_) => AlertDialog(
//           backgroundColor: Colors.white.withOpacity(0.9),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//               ),
//               SizedBox(height: 15),
//               Text(
//                 "Processing clock-out...",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 "Please wait 3 seconds",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//
//       // Set minimum 3 second timer
//       loadingTimer = Timer(Duration(seconds: 3), () {
//         // Timer will be cancelled manually when operations are done
//       });
//     }
//
//     try {
//       // ✅ STEP 1: IMMEDIATE STATE UPDATE (0.5 seconds)
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // Get current distance QUICKLY
//       double finalDistance = _currentDistance; // Use cached distance
//
//       // If no cached distance, use fast calculation
//       if (finalDistance <= 0) {
//         try {
//           LocationService locationService = LocationService();
//           await locationService.init();
//           // Quick distance - just get current without heavy calculation
//           finalDistance = locationService.getCurrentDistance();
//           if (finalDistance <= 0) finalDistance = 0.0;
//         } catch (e) {
//           finalDistance = 0.0;
//         }
//       }
//
//       DateTime clockOutTime = DateTime.now();
//
//       // ✅ STEP 2: SAVE TO PREFERENCES (FAST - 0.5 seconds)
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // Save minimal essential data FIRST
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//
//       // ✅ STEP 3: UPDATE UI STATE IMMEDIATELY (0.1 seconds)
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       _isRiveAnimationActive = false;
//
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // Reset timers and animation
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       // ✅ STEP 4: QUICK SAVE TO ATTENDANCE OUT (1 second max)
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//       );
//
//       // ✅ STEP 5: STOP BACKGROUND SERVICES (0.5 seconds)
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       // Disable background mode
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       // ✅ STEP 6: ENSURE MINIMUM 3 SECOND LOADING TIME
//       DateTime endTime = DateTime.now();
//       Duration elapsedTime = endTime.difference(startTime);
//
//       // Calculate remaining time to reach 3 seconds
//       if (elapsedTime.inSeconds < 3) {
//         int remainingSeconds = 3 - elapsedTime.inSeconds;
//         debugPrint("⏱️ Waiting $remainingSeconds more seconds to complete 3 seconds...");
//         await Future.delayed(Duration(seconds: remainingSeconds));
//       }
//
//       // ✅ STEP 7: SHOW SUCCESS
//       if (loadingTimer != null) loadingTimer.cancel();
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
//       // Show quick success message
//       Get.snackbar(
//         '✅ Clock Out Complete',
//         'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
//
//       debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");
//
//       // ✅ STEP 7: SCHEDULE HEAVY OPERATIONS FOR LATER
//       _scheduleHeavyOperations(clockOutTime, finalDistance);
//
//     } catch (e) {
//       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
//
//       // ✅ ENSURE MINIMUM 3 SECOND LOADING TIME IN ERROR TOO
//       DateTime endTime = DateTime.now();
//       Duration elapsedTime = endTime.difference(startTime);
//
//       // Calculate remaining time to reach 3 seconds
//       if (elapsedTime.inSeconds < 3) {
//         int remainingSeconds = 3 - elapsedTime.inSeconds;
//         debugPrint("⏱️ [ERROR] Waiting $remainingSeconds more seconds to complete 3 seconds...");
//         await Future.delayed(Duration(seconds: remainingSeconds));
//       }
//
//       // Still show success to user
//       if (loadingTimer != null) loadingTimer.cancel();
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
//       Get.snackbar(
//         'Clock Out Complete',
//         'Data saved locally',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
//     }
//   }
//
//   // ✅ SCHEDULE HEAVY OPERATIONS TO RUN IN BACKGROUND
//   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
//     debugPrint("🔄 Scheduling background operations...");
//
//     // Run in background after 5 seconds
//     Timer(Duration(seconds: 5), () async {
//       try {
//         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
//
//         // 1. GPX Consolidation
//         await locationViewModel.consolidateDailyGPXData();
//
//         // 2. Update central point
//         await locationViewModel.updateTodayCentralPoint();
//
//         // 3. Save location from consolidated file
//         await locationViewModel.saveLocationFromConsolidatedFile();
//
//         // 4. Update SharedPreferences with full data
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         // Save complete data for sync
//         await prefs.setDouble('fullClockOutDistance', distance);
//         await prefs.setString('fullClockOutTime', clockOutTime.toIso8601String());
//         await prefs.setDouble('pendingLatOut', locationViewModel.globalLatitude1.value);
//         await prefs.setDouble('pendingLngOut', locationViewModel.globalLongitude1.value);
//         await prefs.setString('pendingAddress', locationViewModel.shopAddress.value);
//
//         debugPrint("✅ [BACKGROUND] Heavy operations completed");
//
//         // 5. Try auto-sync if online
//         _triggerPostClockOutSync();
//
//       } catch (e) {
//         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
//         // Data is already safe in fast save
//       }
//     });
//   }
//
//   // ✅ NEW METHOD: Save all clock-out data to SharedPreferences
//   Future<void> _saveAllClockOutDataToPrefs({
//     required double finalDistance,
//     required DateTime clockOutTime,
//     String reason = 'manual',
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Save all critical data
//     await prefs.setString('pendingClockOutTime', clockOutTime.toIso8601String());
//     await prefs.setDouble('pendingTotalDistance', finalDistance);
//     await prefs.setString('pendingClockOutReason', reason);
//
//     // Save location data
//     await prefs.setDouble('pendingLatOut', locationViewModel.globalLatitude1.value);
//     await prefs.setDouble('pendingLngOut', locationViewModel.globalLongitude1.value);
//     await prefs.setString('pendingAddress', locationViewModel.shopAddress.value);
//
//     // ✅ IMPORTANT: Also save to a dedicated distance key
//     await prefs.setDouble('lastClockOutDistance', finalDistance);
//     await prefs.setDouble('clockOutDistance', finalDistance);
//
//     // Mark that we have pending clock-out data
//     await prefs.setBool('hasPendingClockOutData', true);
//
//     debugPrint("📱 [PREFERENCE] Distance saved: ${finalDistance.toStringAsFixed(3)} km");
//   }
//
//   // ✅ NEW METHOD: Trigger sync after clock-out (FIRE AND FORGET)
//   void _triggerPostClockOutSync() async {
//     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
//
//     try {
//       // Check if we're online
//       var results = await _connectivity.checkConnectivity();
//       bool isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       if (isOnline && !_isSyncing) {
//         _isSyncing = true;
//
//         // Try to sync all data
//         await updateFunctionViewModel.syncAllLocalDataToServer();
//
//         // Clear pending flag if sync successful
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('hasPendingClockOutData', false);
//         await prefs.setBool('clockOutPending', false);
//         await prefs.setBool('hasFastClockOutData', false);
//
//         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
//
//         // Show success notification (subtle)
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Get.snackbar(
//             'Sync Complete',
//             'All data synchronized to server',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 2),
//           );
//         });
//       } else {
//         debugPrint("🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
//
//         // Data is already saved in SharedPreferences, so it's safe
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('clockOutPending', true);
//       }
//     } catch (e) {
//       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
//
//       // Even on error, data is safe in SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('clockOutPending', true);
//     } finally {
//       _isSyncing = false;
//     }
//   }
//
//   // GET GPX FILE NAME CONSISTENTLY
//   String _getGpxFileName() {
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     return 'track_${user_id}_$date.gpx';
//   }
//
//   String _getConsolidatedFileName() {
//     final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     return 'track$date.gpx';
//   }
//
//   // ✅ START DISTANCE UPDATER
//   void _startDistanceUpdater() {
//     _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (attendanceViewModel.isClockedIn.value) {
//         await _updateCurrentDistance();
//       }
//     });
//   }
//
//   // ✅ UPDATE CURRENT DISTANCE
//   Future<void> _updateCurrentDistance() async {
//     try {
//       LocationService locationService = LocationService();
//       await locationService.init();
//       double distance = locationService.getCurrentDistance();
//
//       if (mounted) {
//         setState(() {
//           _currentDistance = distance;
//         });
//       }
//     } catch (e) {
//       debugPrint("❌ Distance update error: $e");
//     }
//   }
//
//   // ✅ GET CURRENT DISTANCE
//   Future<double> _getCurrentDistance() async {
//     if (_currentDistance > 0) {
//       return _currentDistance;
//     }
//
//     try {
//       LocationService locationService = LocationService();
//       await locationService.init();
//       return locationService.getCurrentDistance();
//     } catch (e) {
//       return 0.0;
//     }
//   }
//
//   // ✅ AUTO-SYNC MONITORING SYSTEM WITH SYNC LOCK
//   void _startAutoSyncMonitoring() async {
//     // Listen to connectivity changes
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
//       bool wasOnline = _isOnline;
//       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
//
//       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'} | Was: ${wasOnline ? 'ONLINE' : 'OFFLINE'} | Syncing: $_isSyncing");
//
//       // ✅ FIX: Only trigger if we JUST came online AND not already syncing
//       if (_isOnline && !wasOnline && !_isSyncing) {
//         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
//         _triggerAutoSync();
//       }
//     });
//
//     // ✅ FIX: Reduce frequency and add protection
//     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
//       if (!_isSyncing) {
//         _checkConnectivityAndSync();
//       }
//     });
//
//     _checkConnectivityAndSync();
//   }
//
//   // ✅ CHECK CONNECTIVITY AND SYNC WITH PROTECTION
//   void _checkConnectivityAndSync() async {
//     if (_isSyncing) {
//       debugPrint('⏸️ Sync already in progress - skipping');
//       return;
//     }
//
//     try {
//       var results = await _connectivity.checkConnectivity();
//       bool wasOnline = _isOnline;
//       _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
//
//       if (_isOnline && !wasOnline && !_isSyncing) {
//         debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
//         _triggerAutoSync();
//       }
//     } catch (e) {
//       debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
//     }
//   }
//
//   // ✅ TRIGGER AUTO-SYNC WITH SYNC LOCKING
//   void _triggerAutoSync() async {
//     // Prevent multiple simultaneous syncs
//     if (_isSyncing) {
//       debugPrint('⏸️ Auto-sync already in progress - skipping');
//       return;
//     }
//
//     _isSyncing = true; // Lock sync
//     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
//
//     try {
//       // Show subtle notification
//       Get.snackbar(
//         'Syncing Data',
//         'Auto-syncing offline data...',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.blue.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//
//       // Sync all local data to server
//       await updateFunctionViewModel.syncAllLocalDataToServer();
//
//       // ✅ Clear pending flags if sync successful
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('hasPendingClockOutData', false);
//       await prefs.setBool('clockOutPending', false);
//       await prefs.setBool('hasFastClockOutData', false);
//
//       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
//
//     } catch (e) {
//       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
//     } finally {
//       _isSyncing = false; // Release lock
//       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
//     }
//   }
//
//   void _restoreEverything() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//
//     if (isClockedIn) {
//       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
//
//       locationViewModel.isClockedIn.value = true;
//       attendanceViewModel.isClockedIn.value = true;
//
//       _isRiveAnimationActive = true;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = true;
//       }
//
//       _startLocalBackupTimer();
//
//       if (mounted) {
//         setState(() {});
//       }
//
//       debugPrint("✅ [BULLETPROOF] Everything restored successfully");
//     }
//   }
//
//   void _startLocalBackupTimer() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? clockInTimeString = prefs.getString('clockInTime');
//
//     if (clockInTimeString == null) return;
//
//     _localClockInTime = DateTime.parse(clockInTimeString);
//     _localBackupTimer?.cancel();
//
//     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_localClockInTime == null) return;
//
//       final now = DateTime.now();
//       final duration = now.difference(_localClockInTime!);
//
//       String twoDigits(int n) => n.toString().padLeft(2, '0');
//       String hours = twoDigits(duration.inHours);
//       String minutes = twoDigits(duration.inMinutes.remainder(60));
//       String seconds = twoDigits(duration.inSeconds.remainder(60));
//
//       _localElapsedTime = '$hours:$minutes:$seconds';
//       attendanceViewModel.elapsedTime.value = _localElapsedTime;
//
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     debugPrint("✅ [BACKUP TIMER] Local backup timer started");
//   }
//
//   Future<void> _initializeFromPersistentState() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//
//     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn");
//
//     locationViewModel.isClockedIn.value = isClockedIn;
//     attendanceViewModel.isClockedIn.value = isClockedIn;
//     _isRiveAnimationActive = isClockedIn;
//
//     if (isClockedIn) {
//       debugPrint("✅ [INIT] User was clocked in - starting everything...");
//
//       _startBackgroundServices();
//       _startLocationMonitoring(); // ✅ THIS LINE WAS CAUSING ERROR
//       _startLocalBackupTimer();
//
//       debugPrint("✅ [INIT] Full clocked-in state restored");
//     }
//
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   void onThemeRiveIconInit(Artboard artboard) {
//     final controller = StateMachineController.fromArtboard(
//         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
//     if (controller != null) {
//       artboard.addController(controller);
//       _themeMenuIcon[0].riveIcon.status =
//       controller.findInput<bool>("active") as SMIBool?;
//
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
//         debugPrint("🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
//       }
//     } else {
//       debugPrint("StateMachineController not found!");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 100.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Time display
//               Obx(() {
//                 String displayTime = _localElapsedTime;
//                 if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
//                   displayTime = attendanceViewModel.elapsedTime.value;
//                 }
//
//                 return Text(
//                   displayTime,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 );
//               }),
//               // ✅ ADD: Distance display
//               Obx(() {
//                 if (attendanceViewModel.isClockedIn.value) {
//                   return FutureBuilder<double>(
//                     future: _getCurrentDistance(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData && snapshot.data! > 0) {
//                         return Text(
//                           '${snapshot.data!.toStringAsFixed(2)} km',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.blue.shade700,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               }),
//             ],
//           ),
//           Obx(() {
//             return ElevatedButton(
//               onPressed: () async {
//                 debugPrint("🎯 [BUTTON] Button pressed");
//                 debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");
//
//                 if (attendanceViewModel.isClockedIn.value) {
//                   await _handleClockOut(context);
//                 } else {
//                   await _handleClockIn(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: attendanceViewModel.isClockedIn.value
//                     ? Colors.redAccent
//                     : Colors.green,
//                 minimumSize: const Size(30, 30),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: SizedBox(
//                 width: 35,
//                 height: 35,
//                 child: RiveAnimation.asset(
//                   iconsRiv,
//                   stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
//                   artboard: _themeMenuIcon[0].riveIcon.artboard,
//                   onInit: onThemeRiveIconInit,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // ✅ FIXED: Clock-in method with proper GPX file creation
//   Future<void> _handleClockIn(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
//
//     // ✅ STEP 1: Check Battery Saver FIRST
//     bool batterySaverValid = await BatterySaverService.checkBatterySaverForClockIn(context);
//     if (!batterySaverValid) {
//       debugPrint("❌ [BATTERY SAVER] Clock-in blocked - Battery Saver is ON");
//       return; // Stop here if battery saver is ON
//     }
//
//     // ✅ STEP 2: Location check (existing code)
//     bool locationAvailable = await attendanceViewModel.isLocationAvailable();
//     if (!locationAvailable) {
//       Get.snackbar(
//         'Location Required',
//         'Please enable Location Services to clock in',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       // ✅ STEP 3: Double-check battery saver before proceeding
//       bool finalBatteryCheck = await BatterySaverService.isBatterySaverOn();
//       if (finalBatteryCheck) {
//         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//         Get.snackbar(
//           'Battery Saver Detected',
//           'Please turn OFF Battery Saver to clock in',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 5),
//         );
//         return;
//       }
//
//       // ✅ FIX: Clear previous session data
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // ✅ FIX 1: Initialize LocationService PROPERLY
//       LocationService locationService = LocationService();
//
//       // ✅ FIX 2: Call init() to load user data BEFORE listenLocation()
//       await locationService.init();
//
//       // ✅ FIX 3: Start location listening
//       await locationService.listenLocation();
//
//       // ✅ FIX 4: Verify GPX file was created
//       await Future.delayed(const Duration(seconds: 2)); // Give time for file creation
//
//       // Check if GPX file exists
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       final downloadDirectory = await getDownloadsDirectory();
//       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
//       File file = File(filePath);
//
//       if (!file.existsSync()) {
//         debugPrint("⚠️ GPX file was not created at: $filePath");
//         // Create an empty GPX file with proper structure
//         String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
// <gpx version="1.1" creator="OrderBookingApp">
//   <trk>
//     <name>Daily Track $date</name>
//     <trkseg>
//     </trkseg>
//   </trk>
// </gpx>''';
//         await file.writeAsString(initialGPX);
//         debugPrint("✅ Created empty GPX file for tracking");
//       }
//
//       // ✅ FIX 5: Check initial distance (should be 0)
//       double initialDistance = locationService.getCurrentDistance();
//       debugPrint("📍 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
//
//       if (initialDistance > 0.001) { // If more than 1 meter
//         debugPrint("⚠️ Suspicious initial distance, resetting...");
//         locationService.resetDistance();
//         initialDistance = 0.0;
//       }
//
//       // ✅ FIX 6: Save clock-in data
//       await attendanceViewModel.saveFormAttendanceIn();
//       _startBackgroundServices();
//
//       locationViewModel.isClockedIn.value = true;
//       attendanceViewModel.isClockedIn.value = true;
//
//       await prefs.setBool('isClockedIn', true);
//
//       // ✅ FIX 7: Also save the file path for verification
//       await prefs.setString('currentGpxFilePath', filePath);
//
//       // ✅ FIX: Save session info
//       await prefs.setString('currentSessionStart', DateTime.now().toIso8601String());
//
//       _isRiveAnimationActive = true;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = true;
//       }
//
//       _startLocalBackupTimer();
//       _startLocationMonitoring(); // ✅ THIS LINE WAS CAUSING ERROR
//
//       travelTimeViewModel.startTracking();
//       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
//
//       // ✅ UPDATE DISTANCE DISPLAY
//       await _updateCurrentDistance();
//
//       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
//       debugPrint("📏 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
//       debugPrint("📁 GPX File: $filePath");
//       debugPrint("📊 File Size: ${file.lengthSync()} bytes");
//
//       // Show success message
//       Get.snackbar(
//         'Clocked In Successfully',
//         'GPS tracking started',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//
//     } catch (e) {
//       debugPrint("❌ [CLOCK-IN] Error: $e");
//       Get.snackbar('Error', 'Failed to clock in: $e',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//     } finally {
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//     }
//   }
//
//   // ✅ MISSING METHOD: _startLocationMonitoring - ADD THIS METHOD
//   void _startLocationMonitoring() {
//     _wasLocationAvailable = true;
//     _autoClockOutInProgress = false;
//
//     _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       if (!attendanceViewModel.isClockedIn.value) {
//         _stopLocationMonitoring();
//         return;
//       }
//
//       bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();
//
//       if (_wasLocationAvailable && !currentLocationAvailable) {
//         debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
//         await _handleFastLocationOffAutoClockOut();
//       }
//
//       _wasLocationAvailable = currentLocationAvailable;
//     });
//   }
//
//   // ✅ ADDED: Fast location off auto clock-out method
//   Future<void> _handleFastLocationOffAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//
//     debugPrint("⚡ [LOCATION OFF] Fast auto clock-out triggered");
//
//     try {
//       // ✅ IMMEDIATE STATE CHANGES
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
//       DateTime clockOutTime = DateTime.now();
//
//       // ✅ SAVE TO PREFERENCES IMMEDIATELY
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//       await prefs.setString('fastClockOutReason', 'location_off_auto');
//
//       // ✅ UPDATE UI STATE IMMEDIATELY
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       // ✅ QUICK SAVE TO ATTENDANCE OUT
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//         isAuto: true,
//         reason: 'location_off_auto',
//       );
//
//       // ✅ STOP BACKGROUND SERVICES QUICKLY
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       // ✅ SHOW LOCATION OFF NOTIFICATION
//       Get.snackbar(
//         'Location Turned Off',
//         'Auto clock-out completed. Data saved locally.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: Icon(Icons.location_off, color: Colors.white),
//       );
//
//       debugPrint("✅ [LOCATION OFF] Fast auto clock-out completed in <3 seconds");
//
//       // ✅ SCHEDULE HEAVY OPERATIONS FOR LATER
//       _scheduleHeavyOperations(clockOutTime, finalDistance);
//
//     } catch (e) {
//       debugPrint("❌ [LOCATION OFF] Fast auto clock-out error: $e");
//
//       // Emergency fallback
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   void _startBackgroundServices() async {
//     try {
//       debugPrint("🛰 [BACKGROUND] Starting services...");
//
//       final service = FlutterBackgroundService();
//       await location.enableBackgroundMode(enable: true);
//
//       initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
//       service.startService().catchError((e) => debugPrint("Service start error: $e"));
//       location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
//           .catchError((e) => debugPrint("Location settings error: $e"));
//
//       debugPrint("✅ [BACKGROUND] Services started");
//     } catch (e) {
//       debugPrint("⚠ [BACKGROUND] Services error: $e");
//     }
//   }
//
//   void _setupMidnightProcessing() {
//     // Calculate time until next midnight
//     DateTime now = DateTime.now();
//     DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
//     Duration timeUntilMidnight = nextMidnight.difference(now);
//
//     Timer(timeUntilMidnight, () {
//       // Process previous day's data
//       _processPreviousDayData();
//
//       // Setup for next day
//       _setupMidnightProcessing();
//     });
//   }
//
//   Future<void> _processPreviousDayData() async {
//     debugPrint("🌙 Processing previous day's data at midnight");
//
//     // 🔥 DAILY CONSOLIDATION PEHLE CALL KAREN
//     await locationViewModel.consolidateDailyGPXData();
//     debugPrint("✅ [MIDNIGHT] Previous day's data consolidated");
//
//     await locationViewModel.updateTodayCentralPoint();
//     await locationViewModel.generateDailySummary();
//
//     debugPrint("🌙 Midnight processing completed for previous day");
//   }
//
//   void _stopLocationMonitoring() {
//     _locationMonitorTimer?.cancel();
//     _locationMonitorTimer = null;
//     _autoClockOutInProgress = false;
//   }
//
//   // ✅ DIAGNOSTIC: Check GPX File Status
//   Future<void> _checkGPXFileStatus() async {
//     try {
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       final downloadDirectory = await getDownloadsDirectory();
//
//       // Check both possible file formats
//       final filePath1 = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
//       final filePath2 = "${downloadDirectory!.path}/track$date.gpx";
//
//       File file1 = File(filePath1);
//       File file2 = File(filePath2);
//
//       debugPrint("📁 FILE STATUS CHECK:");
//       debugPrint("   - File 1 ($filePath1): ${file1.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
//       if (file1.existsSync()) {
//         debugPrint("     Size: ${file1.lengthSync()} bytes");
//       }
//
//       debugPrint("   - File 2 ($filePath2): ${file2.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
//       if (file2.existsSync()) {
//         debugPrint("     Size: ${file2.lengthSync()} bytes");
//       }
//
//       // Check distance from LocationService
//       LocationService locationService = LocationService();
//       await locationService.init();
//       double calculatedDistance = locationService.getCurrentDistance();
//       debugPrint("   - Calculated Distance: ${calculatedDistance.toStringAsFixed(3)} km");
//
//     } catch (e) {
//       debugPrint("❌ Error checking GPX status: $e");
//     }
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
import 'package:rive/rive.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../BatterySaverService.dart';
import '../../Databases/util.dart';
import '../../LocatioPoints/ravelTimeViewModel.dart';
import '../../Tracker/location00.dart';
import '../../Tracker/trac.dart';
import '../../main.dart';
import 'assets.dart';
import 'menu_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({super.key});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
  final locationViewModel = Get.find<LocationViewModel>();
  final attendanceViewModel = Get.find<AttendanceViewModel>();
  final attendanceOutViewModel = Get.find<AttendanceOutViewModel>();
  final updateFunctionViewModel = Get.find<UpdateFunctionViewModel>();
  final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());

  final loc.Location location = loc.Location();
  final Connectivity _connectivity = Connectivity();

  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  Timer? _locationMonitorTimer;
  bool _wasLocationAvailable = true;
  bool _autoClockOutInProgress = false;

  bool _isRiveAnimationActive = false;
  Timer? _localBackupTimer;
  DateTime? _localClockInTime;
  String _localElapsedTime = '00:00:00';

  // Auto-sync variables
  Timer? _autoSyncTimer;
  bool _isOnline = false;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Distance tracking
  double _currentDistance = 0.0;
  Timer? _distanceUpdateTimer;

  // Battery Saver monitoring
  Timer? _batterySaverTimer;
  bool _wasBatterySaverOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFromPersistentState();
    _startAutoSyncMonitoring();
    _startDistanceUpdater();

    // ✅ START BATTERY SAVER MONITORING
    _startBatterySaverMonitoring();

    // ✅ CHECK FOR PENDING DATA ON STARTUP
    _checkAndSyncPendingData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreEverything();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationMonitoring();
    _localBackupTimer?.cancel();
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _distanceUpdateTimer?.cancel();
    _batterySaverTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("🔄 [LIFECYCLE] App state changed: $state");

    if (state == AppLifecycleState.resumed) {
      _restoreEverything();
      _checkConnectivityAndSync();

      // ✅ RESTART BATTERY SAVER MONITORING
      _startBatterySaverMonitoring();

      // ✅ CHECK BATTERY SAVER STATUS ON RESUME
      _checkBatterySaverOnResume();

      // ✅ CHECK FOR PENDING DATA
      _checkAndSyncPendingData();
    }
  }

  // ✅ CHECK BATTERY SAVER ON APP RESUME
  void _checkBatterySaverOnResume() async {
    if (attendanceViewModel.isClockedIn.value) {
      bool isBatterySaverOn = await BatterySaverService.isBatterySaverOn();

      if (isBatterySaverOn) {
        debugPrint("🔋 [RESUME] Battery Saver is ON while clocked in - immediate action!");

        // Immediate warning
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            '⚠️ Battery Saver Detected',
            'Auto clock-out will occur in 5 seconds...',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        });

        // Wait a moment then trigger auto clock-out
        await Future.delayed(const Duration(seconds: 5));

        bool stillBatterySaverOn = await BatterySaverService.isBatterySaverOn();
        if (stillBatterySaverOn) {
          await _handleBatterySaverAutoClockOut();
        }
      }
    }
  }

  // ✅ CHECK FOR PENDING DATA
  void _checkAndSyncPendingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
    bool clockOutPending = prefs.getBool('clockOutPending') ?? false;

    if (hasPendingClockOut || clockOutPending) {
      debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
      _triggerAutoSync();
    }
  }

  // ✅ BATTERY SAVER MONITORING SYSTEM WITH AUTO CLOCK-OUT
  void _startBatterySaverMonitoring() {
    // Cancel any existing timer
    _batterySaverTimer?.cancel();

    debugPrint("🔋 Starting Battery Saver monitoring...");

    // Check battery saver every 5 seconds
    _batterySaverTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!attendanceViewModel.isClockedIn.value) {
        _wasBatterySaverOn = false;
        return; // User not clocked in, no need to check
      }

      try {
        bool currentStatus = await BatterySaverService.isBatterySaverOn();

        debugPrint('🔋 [BATTERY] Status: $currentStatus | Clocked In: ${attendanceViewModel.isClockedIn.value} | Was: $_wasBatterySaverOn');

        // ✅ AUTO CLOCK-OUT LOGIC
        if (attendanceViewModel.isClockedIn.value && currentStatus && !_wasBatterySaverOn) {
          debugPrint('🚨 [BATTERY SAVER] Auto Clock-Out triggered!');

          // Show immediate warning
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              '⚠️ Battery Saver Detected',
              'Auto clock-out in 5 seconds...',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              icon: Icon(Icons.battery_alert, color: Colors.white),
            );
          });

          // Give user 5 seconds to turn OFF battery saver
          await Future.delayed(const Duration(seconds: 5));

          // Check again
          bool stillBatterySaverOn = await BatterySaverService.isBatterySaverOn();

          if (stillBatterySaverOn && attendanceViewModel.isClockedIn.value) {
            await _handleBatterySaverAutoClockOut();
          }
        }

        _wasBatterySaverOn = currentStatus;
      } catch (e) {
        debugPrint("❌ Error checking battery saver: $e");
      }
    });
  }

  // ✅ BATTERY SAVER AUTO CLOCK-OUT WITH TIMER RESET AND DATA SAVE
  Future<void> _handleBatterySaverAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;

    debugPrint("⚡ [BATTERY SAVER] Starting auto clock-out process...");

    try {
      // ✅ STEP 1: STOP ALL TIMERS AND MONITORING
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();
      _batterySaverTimer?.cancel();

      // ✅ STEP 2: GET FINAL DISTANCE
      double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
      DateTime clockOutTime = DateTime.now();

      // ✅ STEP 3: UPDATE UI STATE IMMEDIATELY (Timer to zero)
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      // RESET TIMER TO ZERO
      _isRiveAnimationActive = false;
      _localElapsedTime = '00:00:00';
      _localClockInTime = null;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      // Reset Rive animation
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      // ✅ STEP 4: SAVE TO SHARED PREFERENCES
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save basic clock-out data
      await prefs.setBool('isClockedIn', false);
      await prefs.setString('lastClockOutTime', clockOutTime.toIso8601String());
      await prefs.setString('clockOutReason', 'battery_saver_auto');

      // Save distance
      await prefs.setDouble('lastClockOutDistance', finalDistance);
      await prefs.setDouble('clockOutDistance', finalDistance);

      // Save for sync
      await prefs.setString('pendingClockOutTime', clockOutTime.toIso8601String());
      await prefs.setDouble('pendingTotalDistance', finalDistance);
      await prefs.setString('pendingClockOutReason', 'battery_saver_auto');

      // Mark as pending
      await prefs.setBool('clockOutPending', true);
      await prefs.setBool('hasPendingClockOutData', true);
      await prefs.setBool('wasBatterySaverClockOut', true);

      // ✅ STEP 5: SAVE TO ATTENDANCE OUT VIEWMODEL
      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: clockOutTime,
        totalDistance: finalDistance,
        isAuto: true,
        reason: 'battery_saver_auto',
      );

      // ✅ STEP 6: STOP BACKGROUND SERVICES
      final service = FlutterBackgroundService();
      service.invoke("stopService");

      try {
        await location.enableBackgroundMode(enable: false);
      } catch (e) {
        debugPrint("⚠️ Background mode disable error: $e");
      }

      // ✅ STEP 7: UPDATE UI (Force rebuild)
      if (mounted) {
        setState(() {
          _currentDistance = 0.0; // Reset distance
        });
      }

      // ✅ STEP 8: SHOW SUCCESS NOTIFICATION
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          '⚠️ Auto Clock-Out Complete',
          'Battery Saver detected\nDistance: ${finalDistance.toStringAsFixed(2)} km',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: Icon(Icons.battery_alert, color: Colors.white),
          mainButton: TextButton(
            onPressed: () {},
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        );
      });

      debugPrint("✅ [BATTERY SAVER] Auto clock-out completed successfully");
      debugPrint("📊 Distance recorded: ${finalDistance.toStringAsFixed(3)} km");

      // ✅ STEP 9: IMMEDIATE SYNC ATTEMPT
      _triggerImmediateSyncAfterBatterySaver();

      // ✅ STEP 10: SCHEDULE HEAVY OPERATIONS
      _scheduleHeavyOperations(clockOutTime, finalDistance);

    } catch (e) {
      debugPrint("❌ [BATTERY SAVER] Auto clock-out error: $e");

      // Emergency fallback - at least reset UI
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isClockedIn', false);

        locationViewModel.isClockedIn.value = false;
        attendanceViewModel.isClockedIn.value = false;

        _isRiveAnimationActive = false;
        _localElapsedTime = '00:00:00';

        if (mounted) {
          setState(() {});
        }

        Get.snackbar(
          'Clock-Out Error',
          'Auto clock-out due to Battery Saver',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (fallbackError) {
        debugPrint("❌ Emergency fallback also failed: $fallbackError");
      }
    } finally {
      _autoClockOutInProgress = false;
      // Restart battery saver monitoring for future checks
      _startBatterySaverMonitoring();
    }
  }

  // ✅ IMMEDIATE SYNC AFTER BATTERY SAVER CLOCK-OUT
  void _triggerImmediateSyncAfterBatterySaver() async {
    try {
      debugPrint("🔄 [IMMEDIATE SYNC] Starting sync after battery saver clock-out");

      // Check connectivity
      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline) {
        // Show sync notification
        Get.snackbar(
          'Syncing Data',
          'Uploading battery saver clock-out data...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Sync all data
        await updateFunctionViewModel.syncAllLocalDataToServer();

        // Clear flags
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('clockOutPending', false);
        await prefs.setBool('hasPendingClockOutData', false);
        await prefs.setBool('wasBatterySaverClockOut', false);

        debugPrint("✅ [IMMEDIATE SYNC] Battery saver data synced successfully");

        Get.snackbar(
          '✅ Sync Complete',
          'Battery saver clock-out data uploaded',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        debugPrint("🌐 [IMMEDIATE SYNC] Offline - will sync when connection available");
        // Data is saved locally, will sync when online
      }
    } catch (e) {
      debugPrint("❌ [IMMEDIATE SYNC] Error: $e");
      // Data is still saved locally
    }
  }

  // ✅ SCHEDULE HEAVY OPERATIONS TO RUN IN BACKGROUND
  void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
    debugPrint("🔄 Scheduling background operations...");

    // Run in background after 5 seconds
    Timer(Duration(seconds: 5), () async {
      try {
        debugPrint("🔄 [BACKGROUND] Starting heavy operations...");

        // 1. GPX Consolidation
        await locationViewModel.consolidateDailyGPXData();

        // 2. Update central point
        await locationViewModel.updateTodayCentralPoint();

        // 3. Save location from consolidated file
        await locationViewModel.saveLocationFromConsolidatedFile();

        // 4. Update SharedPreferences with full data
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save complete data for sync
        await prefs.setDouble('fullClockOutDistance', distance);
        await prefs.setString('fullClockOutTime', clockOutTime.toIso8601String());
        await prefs.setDouble('pendingLatOut', locationViewModel.globalLatitude1.value);
        await prefs.setDouble('pendingLngOut', locationViewModel.globalLongitude1.value);
        await prefs.setString('pendingAddress', locationViewModel.shopAddress.value);

        debugPrint("✅ [BACKGROUND] Heavy operations completed");

        // 5. Try auto-sync if online
        _triggerPostClockOutSync();

      } catch (e) {
        debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
        // Data is already safe in fast save
      }
    });
  }

  // ✅ POST CLOCK-OUT SYNC
  void _triggerPostClockOutSync() async {
    debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");

    try {
      // Check if we're online
      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline && !_isSyncing) {
        _isSyncing = true;

        // Try to sync all data
        await updateFunctionViewModel.syncAllLocalDataToServer();

        // Clear pending flag if sync successful
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasPendingClockOutData', false);
        await prefs.setBool('clockOutPending', false);
        await prefs.setBool('hasFastClockOutData', false);
        await prefs.setBool('wasBatterySaverClockOut', false);

        debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");

        // Show success notification (subtle)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Sync Complete',
            'All data synchronized to server',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        });
      } else {
        debugPrint("🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");

        // Data is already saved in SharedPreferences, so it's safe
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('clockOutPending', true);
      }
    } catch (e) {
      debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");

      // Even on error, data is safe in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clockOutPending', true);
    } finally {
      _isSyncing = false;
    }
  }

  // ✅ START DISTANCE UPDATER
  void _startDistanceUpdater() {
    _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (attendanceViewModel.isClockedIn.value) {
        await _updateCurrentDistance();
      }
    });
  }

  // ✅ UPDATE CURRENT DISTANCE
  Future<void> _updateCurrentDistance() async {
    try {
      LocationService locationService = LocationService();
      await locationService.init();
      double distance = locationService.getCurrentDistance();

      if (mounted) {
        setState(() {
          _currentDistance = distance;
        });
      }
    } catch (e) {
      debugPrint("❌ Distance update error: $e");
    }
  }

  // ✅ GET CURRENT DISTANCE
  Future<double> _getCurrentDistance() async {
    if (_currentDistance > 0) {
      return _currentDistance;
    }

    try {
      LocationService locationService = LocationService();
      await locationService.init();
      return locationService.getCurrentDistance();
    } catch (e) {
      return 0.0;
    }
  }

  // ✅ AUTO-SYNC MONITORING SYSTEM
  void _startAutoSyncMonitoring() async {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);

      debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'} | Was: ${wasOnline ? 'ONLINE' : 'OFFLINE'} | Syncing: $_isSyncing");

      if (_isOnline && !wasOnline && !_isSyncing) {
        debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
        _triggerAutoSync();
      }
    });

    _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!_isSyncing) {
        _checkConnectivityAndSync();
      }
    });

    _checkConnectivityAndSync();
  }

  // ✅ CHECK CONNECTIVITY AND SYNC
  void _checkConnectivityAndSync() async {
    if (_isSyncing) {
      debugPrint('⏸️ Sync already in progress - skipping');
      return;
    }

    try {
      var results = await _connectivity.checkConnectivity();
      bool wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);

      if (_isOnline && !wasOnline && !_isSyncing) {
        debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
        _triggerAutoSync();
      }
    } catch (e) {
      debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
    }
  }

  // ✅ TRIGGER AUTO-SYNC
  void _triggerAutoSync() async {
    if (_isSyncing) {
      debugPrint('⏸️ Auto-sync already in progress - skipping');
      return;
    }

    _isSyncing = true;
    debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');

    try {
      Get.snackbar(
        'Syncing Data',
        'Auto-syncing offline data...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await updateFunctionViewModel.syncAllLocalDataToServer();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasPendingClockOutData', false);
      await prefs.setBool('clockOutPending', false);
      await prefs.setBool('hasFastClockOutData', false);
      await prefs.setBool('wasBatterySaverClockOut', false);

      debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');

    } catch (e) {
      debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
    } finally {
      _isSyncing = false;
      debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
    }
  }

  void _restoreEverything() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isClockedIn = prefs.getBool('isClockedIn') ?? false;

    if (isClockedIn) {
      debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");

      locationViewModel.isClockedIn.value = true;
      attendanceViewModel.isClockedIn.value = true;

      _isRiveAnimationActive = true;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = true;
      }

      _startLocalBackupTimer();

      if (mounted) {
        setState(() {});
      }

      debugPrint("✅ [BULLETPROOF] Everything restored successfully");
    }
  }

  void _startLocalBackupTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clockInTimeString = prefs.getString('clockInTime');

    if (clockInTimeString == null) return;

    _localClockInTime = DateTime.parse(clockInTimeString);
    _localBackupTimer?.cancel();

    _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_localClockInTime == null) return;

      final now = DateTime.now();
      final duration = now.difference(_localClockInTime!);

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));

      _localElapsedTime = '$hours:$minutes:$seconds';
      attendanceViewModel.elapsedTime.value = _localElapsedTime;

      if (mounted) {
        setState(() {});
      }
    });

    debugPrint("✅ [BACKUP TIMER] Local backup timer started");
  }

  Future<void> _initializeFromPersistentState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isClockedIn = prefs.getBool('isClockedIn') ?? false;

    debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn");

    locationViewModel.isClockedIn.value = isClockedIn;
    attendanceViewModel.isClockedIn.value = isClockedIn;
    _isRiveAnimationActive = isClockedIn;

    if (isClockedIn) {
      debugPrint("✅ [INIT] User was clocked in - starting everything...");

      _startBackgroundServices();
      _startLocationMonitoring();
      _startLocalBackupTimer();

      debugPrint("✅ [INIT] Full clocked-in state restored");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onThemeRiveIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    if (controller != null) {
      artboard.addController(controller);
      _themeMenuIcon[0].riveIcon.status =
      controller.findInput<bool>("active") as SMIBool?;

      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
        debugPrint("🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
      }
    } else {
      debugPrint("StateMachineController not found!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Column(
        children: [
          // ✅ BATTERY SAVER WARNING
          _buildBatterySaverWarning(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer Display
                  Obx(() {
                    String displayTime = _localElapsedTime;
                    if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
                      displayTime = attendanceViewModel.elapsedTime.value;
                    }

                    return Text(
                      displayTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: attendanceViewModel.isClockedIn.value
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    );
                  }),

                  // Distance Display
                  Obx(() {
                    if (attendanceViewModel.isClockedIn.value && _currentDistance > 0) {
                      return Text(
                        '${_currentDistance.toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),

              // Clock In/Out Button
              Obx(() {
                return ElevatedButton(
                  onPressed: () async {
                    debugPrint("🎯 [BUTTON] Button pressed");
                    debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");

                    if (attendanceViewModel.isClockedIn.value) {
                      await _handleClockOut(context);
                    } else {
                      // ✅ CHECK BATTERY SAVER BEFORE CLOCK-IN
                      bool batterySaverOn = await BatterySaverService.isBatterySaverOn();

                      if (batterySaverOn) {
                        // Show battery saver blocking dialog
                        await _showBatterySaverBlockDialog(context);
                        return;
                      }

                      await _handleClockIn(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: attendanceViewModel.isClockedIn.value
                        ? Colors.redAccent
                        : Colors.green,
                    minimumSize: const Size(30, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: RiveAnimation.asset(
                      iconsRiv,
                      stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
                      artboard: _themeMenuIcon[0].riveIcon.artboard,
                      onInit: onThemeRiveIconInit,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ],
          ),

          // ✅ BATTERY SAVER STATUS INDICATOR
          Obx(() {
            if (attendanceViewModel.isClockedIn.value) {
              return FutureBuilder<bool>(
                future: BatterySaverService.isBatterySaverOn(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '⚠️ Battery Saver ON - Auto clock-out active',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // ✅ BATTERY SAVER WARNING WIDGET
  Widget _buildBatterySaverWarning() {
    return FutureBuilder<bool>(
      future: BatterySaverService.isBatterySaverOn(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! && attendanceViewModel.isClockedIn.value) {
          return Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.battery_alert, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Battery Saver ON - Auto clock-out may occur',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => BatterySaverService.openBatterySaverSettings(),
                  child: Text(
                    'Fix',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Future<void> _showBatterySaverBlockDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 360;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: screenHeight * 0.8,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.battery_alert,
                        color: Colors.orange,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          'Battery Saver Detected',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Message
                  Text(
                    'Your device has Battery Saver mode enabled.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Warning Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: Text(
                            'Clock-In is NOT ALLOWED while Battery Saver is ON',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Instructions Title
                  Text(
                    'To clock in:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Instructions - Using a simpler inline approach
                  _buildInstructionStepWidget(1, 'Go to Settings', isSmallScreen),
                  SizedBox(height: 6),
                  _buildInstructionStepWidget(2, 'Find "Battery" or "Battery Saver"', isSmallScreen),
                  SizedBox(height: 6),
                  _buildInstructionStepWidget(3, 'Turn OFF Battery Saver', isSmallScreen),
                  SizedBox(height: 6),
                  _buildInstructionStepWidget(4, 'Return to this app', isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Note/Important Information
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: isSmallScreen ? 16 : 18,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 10),
                        Expanded(
                          child: Text(
                            'Note: Accurate GPS tracking requires Battery Saver to be OFF.',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                      SizedBox(width: isSmallScreen ? 8 : 12),

                      // Settings Button
                      ElevatedButton.icon(
                        onPressed: () {
                          BatterySaverService.openBatterySaverSettings();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.settings,
                          size: isSmallScreen ? 14 : 16,
                        ),
                        label: Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 14 : 18,
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method for instruction steps - ADD THIS METHOD TO YOUR CLASS
  Widget _buildInstructionStepWidget(int number, String text, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Circle
          Container(
            width: isSmallScreen ? 22 : 24,
            height: isSmallScreen ? 22 : 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: isSmallScreen ? 10 : 12),

          // Instruction Text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ULTRA-FAST CLOCK-OUT METHOD
  Future<void> _handleClockOut(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");

    // Show loading dialog
    bool showLoadingDialog = true;
    DateTime startTime = DateTime.now();
    Timer? loadingTimer;

    if (showLoadingDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 15),
              Text(
                "Processing clock-out...",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Please wait 3 seconds",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );

      loadingTimer = Timer(Duration(seconds: 3), () {});
    }

    try {
      // Immediate state update
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      double finalDistance = _currentDistance;
      if (finalDistance <= 0) {
        try {
          LocationService locationService = LocationService();
          await locationService.init();
          finalDistance = locationService.getCurrentDistance();
          if (finalDistance <= 0) finalDistance = 0.0;
        } catch (e) {
          finalDistance = 0.0;
        }
      }

      DateTime clockOutTime = DateTime.now();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      await prefs.setDouble('fastClockOutDistance', finalDistance);
      await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
      await prefs.setBool('clockOutPending', true);
      await prefs.setBool('hasFastClockOutData', true);

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      _isRiveAnimationActive = false;

      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;

      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: clockOutTime,
        totalDistance: finalDistance,
      );

      final service = FlutterBackgroundService();
      service.invoke("stopService");

      try {
        await location.enableBackgroundMode(enable: false);
      } catch (e) {
        debugPrint("⚠️ Background mode disable error: $e");
      }

      DateTime endTime = DateTime.now();
      Duration elapsedTime = endTime.difference(startTime);

      if (elapsedTime.inSeconds < 3) {
        int remainingSeconds = 3 - elapsedTime.inSeconds;
        await Future.delayed(Duration(seconds: remainingSeconds));
      }

      if (loadingTimer != null) loadingTimer.cancel();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        '✅ Clock Out Complete',
        'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");

      _scheduleHeavyOperations(clockOutTime, finalDistance);

    } catch (e) {
      debugPrint("❌ [FAST CLOCK-OUT] Error: $e");

      DateTime endTime = DateTime.now();
      Duration elapsedTime = endTime.difference(startTime);

      if (elapsedTime.inSeconds < 3) {
        int remainingSeconds = 3 - elapsedTime.inSeconds;
        await Future.delayed(Duration(seconds: remainingSeconds));
      }

      if (loadingTimer != null) loadingTimer.cancel();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        'Clock Out Complete',
        'Data saved locally',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  // ✅ CLOCK-IN METHOD
  Future<void> _handleClockIn(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");

    // Location check
    bool locationAvailable = await attendanceViewModel.isLocationAvailable();
    if (!locationAvailable) {
      Get.snackbar(
        'Location Required',
        'Please enable Location Services to clock in',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 15),
            Text('Checking permissions...', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );

    try {
      // Final battery saver check
      bool finalBatteryCheck = await BatterySaverService.isBatterySaverOn();
      if (finalBatteryCheck) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        Get.snackbar(
          'Battery Saver Still ON',
          'Please turn OFF Battery Saver completely to clock in',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: Icon(Icons.battery_alert, color: Colors.white),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      LocationService locationService = LocationService();
      await locationService.init();
      await locationService.listenLocation();

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
      File file = File(filePath);

      if (!file.existsSync()) {
        String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="OrderBookingApp">
  <trk>
    <name>Daily Track $date</name>
    <trkseg>
    </trkseg>
  </trk>
</gpx>''';
        await file.writeAsString(initialGPX);
        debugPrint("✅ Created empty GPX file for tracking");
      }

      double initialDistance = locationService.getCurrentDistance();
      if (initialDistance > 0.001) {
        locationService.resetDistance();
        initialDistance = 0.0;
      }

      await attendanceViewModel.saveFormAttendanceIn();
      _startBackgroundServices();

      locationViewModel.isClockedIn.value = true;
      attendanceViewModel.isClockedIn.value = true;

      await prefs.setBool('isClockedIn', true);
      await prefs.setString('currentGpxFilePath', filePath);
      await prefs.setString('currentSessionStart', DateTime.now().toIso8601String());

      _isRiveAnimationActive = true;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = true;
      }

      _startLocalBackupTimer();
      _startLocationMonitoring();

      travelTimeViewModel.startTracking();
      debugPrint("📍 [TRAVEL TIME] Travel tracking started");

      await _updateCurrentDistance();

      debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        '✅ Clocked In Successfully',
        'GPS tracking started\nBattery Saver: OFF',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e) {
      debugPrint("❌ [CLOCK-IN] Error: $e");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        'Error',
        'Failed to clock in: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ START LOCATION MONITORING
  void _startLocationMonitoring() {
    _wasLocationAvailable = true;
    _autoClockOutInProgress = false;

    _locationMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!attendanceViewModel.isClockedIn.value) {
        _stopLocationMonitoring();
        return;
      }

      bool currentLocationAvailable = await attendanceViewModel.isLocationAvailable();

      if (_wasLocationAvailable && !currentLocationAvailable) {
        debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
        await _handleFastLocationOffAutoClockOut();
      }

      _wasLocationAvailable = currentLocationAvailable;
    });
  }

  // ✅ FAST LOCATION OFF AUTO CLOCK-OUT
  Future<void> _handleFastLocationOffAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;

    debugPrint("⚡ [LOCATION OFF] Fast auto clock-out triggered");

    try {
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
      DateTime clockOutTime = DateTime.now();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isClockedIn', false);
      await prefs.setDouble('fastClockOutDistance', finalDistance);
      await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
      await prefs.setBool('clockOutPending', true);
      await prefs.setBool('hasFastClockOutData', true);
      await prefs.setString('fastClockOutReason', 'location_off_auto');

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      _isRiveAnimationActive = false;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;

      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: clockOutTime,
        totalDistance: finalDistance,
        isAuto: true,
        reason: 'location_off_auto',
      );

      final service = FlutterBackgroundService();
      service.invoke("stopService");

      try {
        await location.enableBackgroundMode(enable: false);
      } catch (e) {
        debugPrint("⚠️ Background mode disable error: $e");
      }

      Get.snackbar(
        'Location Turned Off',
        'Auto clock-out completed. Data saved locally.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.location_off, color: Colors.white),
      );

      debugPrint("✅ [LOCATION OFF] Fast auto clock-out completed");

      _scheduleHeavyOperations(clockOutTime, finalDistance);

    } catch (e) {
      debugPrint("❌ [LOCATION OFF] Fast auto clock-out error: $e");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

    } finally {
      _autoClockOutInProgress = false;
    }
  }

  void _startBackgroundServices() async {
    try {
      debugPrint("🛰 [BACKGROUND] Starting services...");

      final service = FlutterBackgroundService();
      await location.enableBackgroundMode(enable: true);

      initializeServiceLocation().catchError((e) => debugPrint("Service init error: $e"));
      service.startService().catchError((e) => debugPrint("Service start error: $e"));
      location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high)
          .catchError((e) => debugPrint("Location settings error: $e"));

      debugPrint("✅ [BACKGROUND] Services started");
    } catch (e) {
      debugPrint("⚠ [BACKGROUND] Services error: $e");
    }
  }

  void _stopLocationMonitoring() {
    _locationMonitorTimer?.cancel();
    _locationMonitorTimer = null;
    _autoClockOutInProgress = false;
  }
}