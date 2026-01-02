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
// // //     // ✅ START 11:58 PM DEVICE TIME CHECK
// // //     _startEleven58PMTimer(); // Updated method name
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
// // //       // ✅ RESTART 11:58 PM TIMER WHEN APP RESUMES
// // //       _startEleven58PMTimer(); // Updated method name
// // //     }
// // //   }
// // // // ✅ SIMPLE: START 11:58 PM DEVICE TIME TIMER
// // //   void _startEleven58PMTimer() {
// // //     // Cancel existing timer
// // //     _elevenPMTimer?.cancel();
// // //
// // //     debugPrint("⏰ Starting 11:58 PM device time check");
// // //
// // //     // Check every minute if it's 11:58 PM
// // //     _elevenPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// // //       _checkForEleven58PM();
// // //     });
// // //   }
// // //
// // // // ✅ SIMPLE: CHECK FOR 11:58 PM DEVICE TIME
// // //   void _checkForEleven58PM() async {
// // //     try {
// // //       // Get current device time
// // //       DateTime now = DateTime.now();
// // //
// // //       // Check if it's exactly 11:58 PM
// // //       if (now.hour == 23 && now.minute == 58) {
// // //         debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");
// // //
// // //         // Check if user is clocked in
// // //         if (attendanceViewModel.isClockedIn.value) {
// // //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
// // //
// // //           // Call auto clock-out at 11:58 PM
// // //           await _handleEleven58PMAutoClockOut();
// // //         } else {
// // //           debugPrint("⏰ User already clocked out at 11:58 PM");
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint("❌ Error in 11:58 PM check: $e");
// // //     }
// // //   }
// // //
// // // // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
// // //   Future<void> _handleEleven58PMAutoClockOut() async {
// // //     if (_autoClockOutInProgress) return;
// // //     _autoClockOutInProgress = true;
// // //
// // //     debugPrint("🔄 [11:58 PM] Automatic clock-out triggered by device time");
// // //
// // //     try {
// // //       // Stop monitoring timers
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //
// // //       // Save current location
// // //       locationViewModel.saveCurrentLocation().catchError((e)
// // //       => debugPrint("11:58 PM location error: $e"));
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
// // //       // ✅ Save attendance with 11:58 PM timestamp
// // //       // Create 11:58 PM timestamp
// // //       DateTime now = DateTime.now();
// // //       DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
// // //
// // //       await attendanceOutViewModel.saveFormAttendanceOut(clockOutTime: clockOutTime);
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
// // //       // Sync data if online
// // //       if (!_isSyncing) {
// // //         await updateFunctionViewModel.syncAllLocalDataToServer();
// // //         debugPrint("🔄 [SYNC] Data synced after 11:58 PM auto clock-out");
// // //       }
// // //
// // //       // Show notification
// // //       Get.snackbar(
// // //         'Auto Clock-Out',
// // //         'Automatically clocked out at 11:58 PM',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.purple.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 10),
// // //         icon: const Icon(Icons.access_time, color: Colors.white),
// // //       );
// // //
// // //       debugPrint("✅ [11:58 PM] Auto clock-out completed successfully");
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [11:58 PM] Error during auto clock-out: $e");
// // //
// // //       // Emergency fallback
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       Get.snackbar(
// // //         'Auto Clock-Out',
// // //         'System automatically ended your shift at 11:58 PM',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.purple.shade700,
// // //         colorText: Colors.white,
// // //       );
// // //     } finally {
// // //       _autoClockOutInProgress = false;
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
// // //     // Location check
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
// // //       // ✅ GET CURRENT DISTANCE BEFORE STOPPING
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double finalDistance = await locationService.calculateCurrentDistance();
// // //
// // //       // 🔥 DAILY CONSOLIDATION - PEHLE CALL KAREN
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
// // //       // ✅ SAVE CLOCK-OUT TIME AND DISTANCE
// // //       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
// // //       await prefs.setDouble('lastDistance', finalDistance);
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
// // //       await attendanceOutViewModel.saveFormAttendanceOut();
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
// // //         // Show user the actual distance
// // //         Get.snackbar(
// // //           'Clock Out Complete',
// // //           'Distance tracked: ${actualDistance.toStringAsFixed(2)} km',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.green,
// // //           colorText: Colors.white,
// // //           duration: const Duration(seconds: 5),
// // //         );
// // //       } else {
// // //         debugPrint("❌ WARNING: Consolidated GPX file was NOT created!");
// // //         // Show distance from LocationService instead
// // //         Get.snackbar(
// // //           'Clock Out Complete',
// // //           'Distance: ${finalDistance.toStringAsFixed(2)} km',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.green,
// // //           colorText: Colors.white,
// // //           duration: const Duration(seconds: 5),
// // //         );
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
// // //       // ✅ SYNC after clock-out with sync lock
// // //       if (!_isSyncing) {
// // //         await updateFunctionViewModel.syncAllLocalDataToServer();
// // //         debugPrint("🔄 [SYNC] Data synced after clock-out");
// // //       }
// // //
// // //       debugPrint("✅ [CLOCK-OUT] ===== COMPLETED SUCCESSFULLY =====");
// // //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// // //
// // //     } catch (e) {
// // //       debugPrint("❌ [CLOCK-OUT] Error: $e");
// // //       Get.snackbar('Error', 'Failed to clock out: $e',
// // //           snackPosition: SnackPosition.TOP,
// // //           backgroundColor: Colors.red,
// // //           colorText: Colors.white);
// // //     } finally {
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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
// // //       // ✅ SAVE CLOCK-OUT TIME
// // //       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
// // //       await prefs.setDouble('lastDistance', finalDistance);
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
// // //       await attendanceOutViewModel.saveFormAttendanceOut();
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
// // //       // ✅ SYNC after auto clock-out with sync lock
// // //       if (!_isSyncing) {
// // //         await updateFunctionViewModel.syncAllLocalDataToServer();
// // //         debugPrint("🔄 [SYNC] Data synced after auto clock-out");
// // //       }
// // //
// // //       debugPrint("✅ [AUTO] Auto Clock-Out completed");
// // //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// // //
// // //       // Show auto clock-out notification
// // //       Get.snackbar(
// // //         'Auto Clock Out',
// // //         'Location services turned off. Distance: ${finalDistance.toStringAsFixed(2)} km',
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
// // //
// // // }
// //
// // ///gpx osted
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_background_service/flutter_background_service.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // import 'package:rive/rive.dart';
// // import 'package:location/location.dart' as loc;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:connectivity_plus/connectivity_plus.dart';
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
// //   // ✅ SIMPLE 11:00 PM AUTO CLOCK-OUT TIMER
// //   Timer? _elevenPMTimer;
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
// //     _startEleven58PMTimer(); // Updated method name
// //
// //   }
// //
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
// //     _elevenPMTimer?.cancel(); // ✅ STOP 11:00 PM TIMER
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
// //       _startEleven58PMTimer();
// //
// //     }
// //   }
// //
// //
// // // ✅ SIMPLE: START 11:58 PM DEVICE TIME TIMER
// //   void _startEleven58PMTimer() {
// //     // Cancel existing timer
// //     _elevenPMTimer?.cancel();
// //
// //     debugPrint("⏰ Starting 11:58 PM device time check");
// //
// //     // Check every minute if it's 11:58 PM
// //     _elevenPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
// //       _checkForEleven58PM();
// //     });
// //   }
// //
// // // ✅ SIMPLE: CHECK FOR 11:58 PM DEVICE TIME
// //   void _checkForEleven58PM() async {
// //     try {
// //       // Get current device time
// //       DateTime now = DateTime.now();
// //
// //       // Check if it's exactly 11:58 PM
// //       if (now.hour == 23 && now.minute == 58) {
// //         debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");
// //
// //         // Check if user is clocked in
// //         if (attendanceViewModel.isClockedIn.value) {
// //           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
// //
// //           // Call auto clock-out at 11:58 PM
// //           await _handleEleven58PMAutoClockOut();
// //         } else {
// //           debugPrint("⏰ User already clocked out at 11:58 PM");
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Error in 11:58 PM check: $e");
// //     }
// //   }
// //
// // // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
// //   // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
// //   // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
// //   Future<void> _handleEleven58PMAutoClockOut() async {
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
// //       // ✅ ADD: Reset timer variables
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //
// //       // Force UI update
// //       if (mounted) {
// //         setState(() {});
// //       }
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
// //       attendanceViewModel.elapsedTime.value = '00:00:00'; // ADD THIS
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       await prefs.remove('clockInTime'); // ADD THIS: Clear stored clock-in time
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
// //       // Create 11:58 PM timestamp
// //       DateTime now = DateTime.now();
// //       DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
// //
// //       await attendanceOutViewModel.saveFormAttendanceOut(clockOutTime: clockOutTime);
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
// //       // Sync data if online
// //       if (!_isSyncing) {
// //         await updateFunctionViewModel.syncAllLocalDataToServer();
// //         debugPrint("🔄 [SYNC] Data synced after 11:58 PM auto clock-out");
// //       }
// //
// //       // Show notification
// //       Get.snackbar(
// //         'Auto Clock-Out',
// //         'Automatically clocked out at 11:58 PM',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.purple.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 10),
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
// //       attendanceViewModel.elapsedTime.value = '00:00:00'; // ADD THIS
// //
// //       Get.snackbar(
// //         'Auto Clock-Out',
// //         'System automatically ended your shift at 11:58 PM',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.purple.shade700,
// //         colorText: Colors.white,
// //       );
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
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
// //         padding: const EdgeInsets.symmetric(horizontal: 100.0),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Time display
// //                 Obx(() {
// //                   String displayTime = _localElapsedTime;
// //                   if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
// //                     displayTime = attendanceViewModel.elapsedTime.value;
// //                   }
// //
// //                   return Text(
// //                     displayTime,
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black87,
// //                     ),
// //                   );
// //                 }),
// //                 // ✅ ADD: Distance display
// //                 Obx(() {
// //                   if (attendanceViewModel.isClockedIn.value) {
// //                     return FutureBuilder<double>(
// //                       future: _getCurrentDistance(),
// //                       builder: (context, snapshot) {
// //                         if (snapshot.hasData && snapshot.data! > 0) {
// //                           return Text(
// //                             '${snapshot.data!.toStringAsFixed(2)} km',
// //                             style: TextStyle(
// //                               fontSize: 12,
// //                               color: Colors.blue.shade700,
// //                               fontWeight: FontWeight.w500,
// //                             ),
// //                           );
// //                         }
// //                         return const SizedBox.shrink();
// //                       },
// //                     );
// //                   }
// //                   return const SizedBox.shrink();
// //                 }),
// //               ],
// //             ),
// //             Obx(() {
// //               return ElevatedButton(
// //                 onPressed: () async {
// //                   debugPrint("🎯 [BUTTON] Button pressed");
// //                   debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");
// //
// //                   if (attendanceViewModel.isClockedIn.value) {
// //                     await _handleClockOut(context);
// //                   } else {
// //                     await _handleClockIn(context);
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: attendanceViewModel.isClockedIn.value
// //                       ? Colors.redAccent
// //                       : Colors.green,
// //                   minimumSize: const Size(30, 30),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   padding: EdgeInsets.zero,
// //                 ),
// //                 child: SizedBox(
// //                   width: 35,
// //                   height: 35,
// //                   child: RiveAnimation.asset(
// //                     iconsRiv,
// //                     stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// //                     artboard: _themeMenuIcon[0].riveIcon.artboard,
// //                     onInit: onThemeRiveIconInit,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //               );
// //             }),
// //           ],
// //         )
// //     );
// //   }
// //
// //   // ✅ FIXED: Clock-in method with proper GPX file creation
// //   Future<void> _handleClockIn(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// //
// //     // Location check
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
// //   // ✅ FIXED: 2-SECOND CLOCK-OUT METHOD - IMMEDIATE LOCAL SAVE
// //   // ✅ FIXED: 2-SECOND CLOCK-OUT METHOD - IMMEDIATE LOCAL SAVE WITH TIMER RESET
// //   // ✅ FIXED: 2-SECOND CLOCK-OUT METHOD WITH PROPER GPX POSTING
// //   Future<void> _handleClockOut(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== 2-SECOND CLOCK-OUT STARTED =====");
// //
// //     // Show immediate processing dialog
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => const Center(child: CircularProgressIndicator()),
// //     );
// //
// //     try {
// //       // ✅ STEP 1: IMMEDIATE LOCAL SAVE (2 seconds max)
// //       debugPrint("⚡ Step 1: Immediate local save");
// //
// //       // Stop monitoring timers
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //
// //       // Get final distance BEFORE stopping service
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double finalDistance = await locationService.calculateCurrentDistance();
// //
// //       // ✅ STEP 2: Save clock-out data LOCALLY first
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //       // ✅ CRITICAL: SAVE clock-out time BEFORE clearing clockInTime
// //       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
// //       await prefs.setDouble('lastDistance', finalDistance);
// //       await prefs.setBool('isClockedIn', false);
// //
// //       // Update UI state IMMEDIATELY
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       attendanceViewModel.elapsedTime.value = '00:00:00'; // ✅ Reset ViewModel timer
// //
// //       // Stop Rive animation
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       // ✅ STEP 3: Save attendance out LOCALLY with posted=0
// //       // NOTE: This needs clockInTime to calculate shift duration
// //       await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
// //           clockOutTime: DateTime.now(),
// //           distance: finalDistance
// //       );
// //
// //       // ✅ STEP 4: Process GPX data BEFORE clearing clockInTime
// //       debugPrint("📁 Processing GPX data for posting...");
// //
// //       // 🔥 DAILY CONSOLIDATION - PEHLE CALL KAREN
// //       await locationViewModel.consolidateDailyGPXData();
// //       debugPrint("✅ [CONSOLIDATION] All today's points merged into single file");
// //
// //       // ✅ STEP 5: Save location data LOCALLY with posted=0
// //       await locationViewModel.saveLocationLocallyOnly();
// //       debugPrint("💾 Location saved locally with posted=0");
// //
// //       // ✅ STEP 6: Now reset timer UI (after GPX processing)
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //       _currentDistance = 0.0;
// //
// //       // ✅ Clear clockInTime AFTER processing is done
// //       await prefs.remove('clockInTime');
// //
// //       // Force UI update
// //       if (mounted) {
// //         setState(() {});
// //       }
// //
// //       // ✅ STEP 7: Stop background services
// //       final service = FlutterBackgroundService();
// //       service.invoke("stopService");
// //       await location.enableBackgroundMode(enable: false);
// //
// //       // Close dialog after 2 seconds MAX
// //       Future.delayed(const Duration(seconds: 2), () {
// //         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //       });
// //
// //       // Show immediate success message
// //       Get.snackbar(
// //         'Clocked Out',
// //         'Data saved locally. Will sync when online.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //
// //       debugPrint("✅ [CLOCK-OUT] Local save completed in 2 seconds");
// //       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
// //       debugPrint("⏰ [TIMER RESET] Timer reset to 00:00:00");
// //
// //       // ✅ STEP 8: Try background sync in background (won't block UI)
// //       _tryBackgroundSync();
// //
// //     } catch (e) {
// //       debugPrint("❌ [CLOCK-OUT] Error: $e");
// //
// //       // Emergency fallback - at least save clock-out status
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       attendanceViewModel.elapsedTime.value = '00:00:00';
// //
// //       // Reset UI
// //       _localElapsedTime = '00:00:00';
// //       if (mounted) setState(() {});
// //
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         'Clocked Out',
// //         'Basic data saved. Full sync will complete later.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //       );
// //     }
// //   }
// //
// //   // ✅ NEW: Try background sync if online
// //   // ✅ NEW: Try background sync if online with GPX posting
// //   void _tryBackgroundSync() async {
// //     if (_isOnline && !_isSyncing) {
// //       debugPrint("🔄 Trying background sync after clock-out");
// //
// //       try {
// //         // ✅ TRY TO POST LOCATION DATA (GPX)
// //         await locationViewModel.locationRepository.postDataFromDatabaseToAPI();
// //         debugPrint("📤 GPX data posted to API");
// //
// //         // ✅ TRY TO POST ATTENDANCE OUT DATA
// //         await attendanceOutViewModel.attendanceOutRepository.postDataFromDatabaseToAPI();
// //         debugPrint("📤 Attendance out data posted to API");
// //
// //       } catch (e) {
// //         debugPrint("❌ Error in background sync: $e");
// //       }
// //     } else {
// //       debugPrint("⏸️ Offline - Sync will happen when online");
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
// //
// //       // Save clock-out data LOCALLY first
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //       // ✅ SAVE FIRST, CLEAR LATER
// //       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
// //       await prefs.setDouble('lastDistance', finalDistance);
// //       await prefs.setBool('isClockedIn', false);
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       attendanceViewModel.elapsedTime.value = '00:00:00';
// //
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       // ✅ Save attendance out LOCALLY
// //       await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
// //           clockOutTime: DateTime.now(),
// //           distance: finalDistance
// //       );
// //
// //       // ✅ Process GPX data BEFORE clearing
// //       await locationViewModel.consolidateDailyGPXData();
// //       await locationViewModel.saveLocationLocallyOnly();
// //
// //       // ✅ Now reset timer UI
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //       _currentDistance = 0.0;
// //
// //       // ✅ Clear clockInTime AFTER processing
// //       await prefs.remove('clockInTime');
// //
// //       if (mounted) {
// //         setState(() {});
// //       }
// //
// //       final service = FlutterBackgroundService();
// //       service.invoke("stopService");
// //       await location.enableBackgroundMode(enable: false);
// //
// //       debugPrint("✅ [AUTO] Auto Clock-Out completed locally");
// //       debugPrint("📏 Distance: ${finalDistance.toStringAsFixed(3)} km");
// //
// //       // Show auto clock-out notification
// //       Get.snackbar(
// //         'Auto Clock Out',
// //         'Location off. Data saved locally.',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //       );
// //
// //       // Try background sync
// //       _tryBackgroundSync();
// //
// //     } catch (e) {
// //       debugPrint("❌ [AUTO] Auto clock-out error: $e");
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
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
// //       }
// //
// //       debugPrint("   - File 2 ($filePath2): ${file2.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
// //       if (file2.existsSync()) {
// //         debugPrint("     Size: ${file2.lengthSync()} bytes");
// //       }
// //
// //     } catch (e) {
// //       debugPrint("❌ Error checking GPX status: $e");
// //     }
// //   }
// //
// // }
//
// ///gpx osted
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// import 'package:rive/rive.dart';
// import 'package:location/location.dart' as loc;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
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
// // ✅ ADD: Battery Saver Import
// import '../../BatterySaverService.dart';
//
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
//   // ✅ SIMPLE 11:58 PM AUTO CLOCK-OUT TIMER
//   Timer? _elevenPMTimer;
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
//     _startEleven58PMTimer();
//
//     // ✅ ADD: Start Battery Saver Monitoring
//     _startBatterySaverAutoClockOutMonitoring();
//   }
//
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
//     _elevenPMTimer?.cancel(); // ✅ STOP 11:58 PM TIMER
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
//       _startEleven58PMTimer();
//     }
//   }
//
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
//   // ✅ BATTERY SAVER AUTO CLOCK-OUT
//   Future<void> _handleBatterySaverAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//
//     debugPrint("🔄 [BATTERY SAVER AUTO] Auto Clock-Out triggered - Battery Saver ON");
//
//     try {
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // ✅ GET CURRENT DISTANCE
//       LocationService locationService = LocationService();
//       await locationService.init();
//       double finalDistance = await locationService.calculateCurrentDistance();
//
//       // 🔥 DAILY CONSOLIDATION
//       await locationViewModel.consolidateDailyGPXData();
//       debugPrint("✅ [BATTERY SAVER AUTO] All today's points merged");
//
//       // ✅ STOP TRAVEL TIME TRACKING
//       travelTimeViewModel.stopTracking();
//       debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (Battery Saver)");
//
//       locationViewModel.saveCurrentLocation().catchError((e)
//       => debugPrint("Battery saver auto location error: $e"));
//
//       final service = FlutterBackgroundService();
//
//       // UPDATE UI STATE
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//
//       // ✅ SAVE CLOCK-OUT TIME AND REASON
//       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
//       await prefs.setDouble('lastDistance', finalDistance);
//       await prefs.setString('clockOutReason', 'battery_saver_auto');
//
//       // UPDATE RIVE ANIMATION
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // RESET LOCAL VARIABLES
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//       _currentDistance = 0.0;
//
//       // STOP BACKGROUND SERVICE
//       service.invoke("stopService");
//
//       // ✅ SAVE ATTENDANCE OUT WITH BATTERY SAVER REASON
//       await attendanceOutViewModel.saveFormAttendanceOut();
//
//       // 🔥 24 HOURS DATA PROCESSING
//       await locationViewModel.updateTodayCentralPoint();
//       debugPrint("✅ [24HOURS] Daily GPX data processed (Battery Saver)");
//
//       // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
//       await locationViewModel.saveLocationFromConsolidatedFile();
//       debugPrint("💾 Location saved from consolidated file (Battery Saver)");
//
//       locationViewModel.saveClockStatus(false).catchError((e)
//       => debugPrint("Battery saver clock status error: $e"));
//
//       await location.enableBackgroundMode(enable: false);
//
//       // ✅ SYNC after auto clock-out
//       if (!_isSyncing) {
//         await updateFunctionViewModel.syncAllLocalDataToServer();
//         debugPrint("🔄 [SYNC] Data synced after battery saver auto clock-out");
//       }
//
//       debugPrint("✅ [BATTERY SAVER AUTO] Auto Clock-Out completed");
//       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
//
//       // Show battery saver auto clock-out notification
//       Get.snackbar(
//         '⚠️ Battery Saver Detected',
//         'Auto clock-out due to Battery Saver mode. Distance: ${finalDistance.toStringAsFixed(2)} km',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 8),
//         icon: Icon(Icons.battery_alert, color: Colors.white),
//         mainButton: TextButton(
//           onPressed: () {
//             BatterySaverService.openBatterySaverSettings();
//           },
//           child: Text('SETTINGS', style: TextStyle(color: Colors.white)),
//         ),
//       );
//
//     } catch (e) {
//       debugPrint("❌ [BATTERY SAVER AUTO] Error: $e");
//
//       // Emergency fallback - at least update the clock status
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       Get.snackbar(
//         'Battery Saver Alert',
//         'Please turn OFF Battery Saver for GPS tracking',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
// // ✅ SIMPLE: START 11:58 PM DEVICE TIME TIMER
//   void _startEleven58PMTimer() {
//     // Cancel existing timer
//     _elevenPMTimer?.cancel();
//
//     debugPrint("⏰ Starting 11:58 PM device time check");
//
//     // Check every minute if it's 11:58 PM
//     _elevenPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkForEleven58PM();
//     });
//   }
//
// // ✅ SIMPLE: CHECK FOR 11:58 PM DEVICE TIME
//   void _checkForEleven58PM() async {
//     try {
//       // Get current device time
//       DateTime now = DateTime.now();
//
//       // Check if it's exactly 11:58 PM
//       if (now.hour == 23 && now.minute == 58) {
//         debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");
//
//         // Check if user is clocked in
//         if (attendanceViewModel.isClockedIn.value) {
//           debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
//
//           // Call auto clock-out at 11:58 PM
//           await _handleEleven58PMAutoClockOut();
//         } else {
//           debugPrint("⏰ User already clocked out at 11:58 PM");
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error in 11:58 PM check: $e");
//     }
//   }
//
// // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
//   Future<void> _handleEleven58PMAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//
//     debugPrint("🔄 [11:58 PM] Automatic clock-out triggered by device time");
//
//     try {
//       // Stop monitoring timers
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // ✅ ADD: Reset timer variables
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       // Force UI update
//       if (mounted) {
//         setState(() {});
//       }
//
//       // Save current location
//       locationViewModel.saveCurrentLocation().catchError((e)
//       => debugPrint("11:58 PM location error: $e"));
//
//       final service = FlutterBackgroundService();
//
//       // Update UI state
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       attendanceViewModel.elapsedTime.value = '00:00:00'; // ADD THIS
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       await prefs.remove('clockInTime'); // ADD THIS: Clear stored clock-in time
//
//       // Update Rive animation
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // Reset local variables
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//       _currentDistance = 0.0;
//
//       // Stop background service
//       service.invoke("stopService");
//
//       // ✅ Save attendance with 11:58 PM timestamp
//       // Create 11:58 PM timestamp
//       DateTime now = DateTime.now();
//       DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);
//
//       await attendanceOutViewModel.saveFormAttendanceOut(clockOutTime: clockOutTime);
//
//       // Process and save location data
//       await locationViewModel.consolidateDailyGPXData();
//       await locationViewModel.updateTodayCentralPoint();
//       await locationViewModel.saveLocationFromConsolidatedFile();
//       await locationViewModel.saveClockStatus(false);
//
//       // Disable background mode
//       await location.enableBackgroundMode(enable: false);
//
//       // Sync data if online
//       if (!_isSyncing) {
//         await updateFunctionViewModel.syncAllLocalDataToServer();
//         debugPrint("🔄 [SYNC] Data synced after 11:58 PM auto clock-out");
//       }
//
//       // Show notification
//       Get.snackbar(
//         'Auto Clock-Out',
//         'Automatically clocked out at 11:58 PM',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.purple.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 10),
//         icon: const Icon(Icons.access_time, color: Colors.white),
//       );
//
//       debugPrint("✅ [11:58 PM] Auto clock-out completed successfully");
//
//     } catch (e) {
//       debugPrint("❌ [11:58 PM] Error during auto clock-out: $e");
//
//       // Emergency fallback
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       attendanceViewModel.elapsedTime.value = '00:00:00'; // ADD THIS
//
//       Get.snackbar(
//         'Auto Clock-Out',
//         'System automatically ended your shift at 11:58 PM',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.purple.shade700,
//         colorText: Colors.white,
//       );
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
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
//       double distance = await locationService.calculateCurrentDistance();
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
//       return await locationService.calculateCurrentDistance();
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
//       _startLocationMonitoring();
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
//         padding: const EdgeInsets.symmetric(horizontal: 100.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Time display
//                 Obx(() {
//                   String displayTime = _localElapsedTime;
//                   if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
//                     displayTime = attendanceViewModel.elapsedTime.value;
//                   }
//
//                   return Text(
//                     displayTime,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   );
//                 }),
//                 // ✅ ADD: Distance display
//                 Obx(() {
//                   if (attendanceViewModel.isClockedIn.value) {
//                     return FutureBuilder<double>(
//                       future: _getCurrentDistance(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData && snapshot.data! > 0) {
//                           return Text(
//                             '${snapshot.data!.toStringAsFixed(2)} km',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.blue.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//             ),
//             Obx(() {
//               return ElevatedButton(
//                 onPressed: () async {
//                   debugPrint("🎯 [BUTTON] Button pressed");
//                   debugPrint("   - Clocked In: ${attendanceViewModel.isClockedIn.value}");
//
//                   if (attendanceViewModel.isClockedIn.value) {
//                     await _handleClockOut(context);
//                   } else {
//                     await _handleClockIn(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: attendanceViewModel.isClockedIn.value
//                       ? Colors.redAccent
//                       : Colors.green,
//                   minimumSize: const Size(30, 30),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: EdgeInsets.zero,
//                 ),
//                 child: SizedBox(
//                   width: 35,
//                   height: 35,
//                   child: RiveAnimation.asset(
//                     iconsRiv,
//                     stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
//                     artboard: _themeMenuIcon[0].riveIcon.artboard,
//                     onInit: onThemeRiveIconInit,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               );
//             }),
//           ],
//         )
//     );
//   }
//
//   // ✅ FIXED: Clock-in method with proper GPX file creation
//   Future<void> _handleClockIn(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
//
//     // Location check
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
//       _startLocationMonitoring();
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
//   // ✅ FIXED: 2-SECOND CLOCK-OUT METHOD - IMMEDIATE LOCAL SAVE
//   Future<void> _handleClockOut(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== 2-SECOND CLOCK-OUT STARTED =====");
//
//     // Show immediate processing dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       // ✅ STEP 1: IMMEDIATE LOCAL SAVE (2 seconds max)
//       debugPrint("⚡ Step 1: Immediate local save");
//
//       // Stop monitoring timers
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // Get final distance BEFORE stopping service
//       LocationService locationService = LocationService();
//       await locationService.init();
//       double finalDistance = await locationService.calculateCurrentDistance();
//
//       // ✅ STEP 2: Save clock-out data LOCALLY first
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // ✅ CRITICAL: SAVE clock-out time BEFORE clearing clockInTime
//       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
//       await prefs.setDouble('lastDistance', finalDistance);
//       await prefs.setBool('isClockedIn', false);
//
//       // Update UI state IMMEDIATELY
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       attendanceViewModel.elapsedTime.value = '00:00:00'; // ✅ Reset ViewModel timer
//
//       // Stop Rive animation
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // ✅ STEP 3: Save attendance out LOCALLY with posted=0
//       // NOTE: This needs clockInTime to calculate shift duration
//       await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
//           clockOutTime: DateTime.now(),
//           distance: finalDistance
//       );
//
//       // ✅ STEP 4: Process GPX data BEFORE clearing clockInTime
//       debugPrint("📁 Processing GPX data for posting...");
//
//       // 🔥 DAILY CONSOLIDATION - PEHLE CALL KAREN
//       await locationViewModel.consolidateDailyGPXData();
//       debugPrint("✅ [CONSOLIDATION] All today's points merged into single file");
//
//       // ✅ STEP 5: Save location data LOCALLY with posted=0
//       await locationViewModel.saveLocationLocallyOnly();
//       debugPrint("💾 Location saved locally with posted=0");
//
//       // ✅ STEP 6: Now reset timer UI (after GPX processing)
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//       _currentDistance = 0.0;
//
//       // ✅ Clear clockInTime AFTER processing is done
//       await prefs.remove('clockInTime');
//
//       // Force UI update
//       if (mounted) {
//         setState(() {});
//       }
//
//       // ✅ STEP 7: Stop background services
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//       await location.enableBackgroundMode(enable: false);
//
//       // Close dialog after 2 seconds MAX
//       Future.delayed(const Duration(seconds: 2), () {
//         if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//       });
//
//       // Show immediate success message
//       Get.snackbar(
//         'Clocked Out',
//         'Data saved locally. Will sync when online.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//
//       debugPrint("✅ [CLOCK-OUT] Local save completed in 2 seconds");
//       debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
//       debugPrint("⏰ [TIMER RESET] Timer reset to 00:00:00");
//
//       // ✅ STEP 8: Try background sync in background (won't block UI)
//       _tryBackgroundSync();
//
//     } catch (e) {
//       debugPrint("❌ [CLOCK-OUT] Error: $e");
//
//       // Emergency fallback - at least save clock-out status
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       attendanceViewModel.elapsedTime.value = '00:00:00';
//
//       // Reset UI
//       _localElapsedTime = '00:00:00';
//       if (mounted) setState(() {});
//
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
//       Get.snackbar(
//         'Clocked Out',
//         'Basic data saved. Full sync will complete later.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // ✅ NEW: Try background sync if online
//   void _tryBackgroundSync() async {
//     if (_isOnline && !_isSyncing) {
//       debugPrint("🔄 Trying background sync after clock-out");
//
//       try {
//         // ✅ TRY TO POST LOCATION DATA (GPX)
//         await locationViewModel.locationRepository.postDataFromDatabaseToAPI();
//         debugPrint("📤 GPX data posted to API");
//
//         // ✅ TRY TO POST ATTENDANCE OUT DATA
//         await attendanceOutViewModel.attendanceOutRepository.postDataFromDatabaseToAPI();
//         debugPrint("📤 Attendance out data posted to API");
//
//       } catch (e) {
//         debugPrint("❌ Error in background sync: $e");
//       }
//     } else {
//       debugPrint("⏸️ Offline - Sync will happen when online");
//     }
//   }
//
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
//         await _handleAutoClockOut();
//       }
//
//       _wasLocationAvailable = currentLocationAvailable;
//     });
//   }
//
//   Future<void> _handleAutoClockOut() async {
//     if (_autoClockOutInProgress) return;
//     _autoClockOutInProgress = true;
//     debugPrint("🔄 [AUTO] Auto Clock-Out triggered due to location OFF");
//
//     try {
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//
//       // ✅ GET CURRENT DISTANCE
//       LocationService locationService = LocationService();
//       await locationService.init();
//       double finalDistance = await locationService.calculateCurrentDistance();
//
//       // Save clock-out data LOCALLY first
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // ✅ SAVE FIRST, CLEAR LATER
//       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
//       await prefs.setDouble('lastDistance', finalDistance);
//       await prefs.setBool('isClockedIn', false);
//
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       attendanceViewModel.elapsedTime.value = '00:00:00';
//
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // ✅ Save attendance out LOCALLY
//       await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
//           clockOutTime: DateTime.now(),
//           distance: finalDistance
//       );
//
//       // ✅ Process GPX data BEFORE clearing
//       await locationViewModel.consolidateDailyGPXData();
//       await locationViewModel.saveLocationLocallyOnly();
//
//       // ✅ Now reset timer UI
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//       _currentDistance = 0.0;
//
//       // ✅ Clear clockInTime AFTER processing
//       await prefs.remove('clockInTime');
//
//       if (mounted) {
//         setState(() {});
//       }
//
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//       await location.enableBackgroundMode(enable: false);
//
//       debugPrint("✅ [AUTO] Auto Clock-Out completed locally");
//       debugPrint("📏 Distance: ${finalDistance.toStringAsFixed(3)} km");
//
//       // Show auto clock-out notification
//       Get.snackbar(
//         'Auto Clock Out',
//         'Location off. Data saved locally.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//
//       // Try background sync
//       _tryBackgroundSync();
//
//     } catch (e) {
//       debugPrint("❌ [AUTO] Auto clock-out error: $e");
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   // TimerCard mein add karein
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
//     } catch (e) {
//       debugPrint("❌ Error checking GPX status: $e");
//     }
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
import 'package:rive/rive.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Databases/util.dart';
import '../../LocatioPoints/ravelTimeViewModel.dart';
import '../../Tracker/location00.dart';
import '../../Tracker/trac.dart';
import '../../main.dart';
import 'assets.dart';
import 'menu_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:gpx/gpx.dart';
import '../../BatterySaverService.dart';

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

  // ✅ AUTO-SYNC VARIABLES
  Timer? _autoSyncTimer;
  bool _isOnline = false;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // ✅ ADD: Distance tracking
  double _currentDistance = 0.0;
  Timer? _distanceUpdateTimer;

  // ✅ SIMPLE 11:58 PM AUTO CLOCK-OUT TIMER
  Timer? _elevenPMTimer;

  // ✅ ADD: Battery saver monitoring
  bool _isBatterySaverOn = false;
  Timer? _batterySaverCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFromPersistentState();
    _startAutoSyncMonitoring();
    _setupMidnightProcessing();
    _startDistanceUpdater();

    // ✅ START 11:58 PM DEVICE TIME CHECK
    _startEleven58PMTimer();

    // ✅ ADD: Start Battery Saver Monitoring
    _startBatterySaverMonitoring();
    _checkInitialBatterySaverStatus();
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
    _elevenPMTimer?.cancel();
    _batterySaverCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("🔄 [LIFECYCLE] App state changed: $state");

    if (state == AppLifecycleState.resumed) {
      _restoreEverything();
      _checkConnectivityAndSync();

      // ✅ RESTART 11:58 PM TIMER WHEN APP RESUMES
      _startEleven58PMTimer();

      // ✅ CHECK BATTERY SAVER ON RESUME
      _checkBatterySaverOnResume();
    }
  }

  // ✅ START BATTERY SAVER MONITORING
  void _startBatterySaverMonitoring() {
    // Check every 10 seconds
    _batterySaverCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkBatterySaverStatus();
    });
  }

  // ✅ CHECK BATTERY SAVER STATUS
  Future<void> _checkBatterySaverStatus() async {
    try {
      bool previousStatus = _isBatterySaverOn;
      _isBatterySaverOn = await BatterySaverService.isBatterySaverOn();

      debugPrint("🔋 [BATTERY] Status: $_isBatterySaverOn | Previous: $previousStatus | Clocked In: ${attendanceViewModel.isClockedIn.value}");

      // If user is clocked in and battery saver turned ON
      if (attendanceViewModel.isClockedIn.value && previousStatus != _isBatterySaverOn && _isBatterySaverOn) {
        debugPrint("🚨 [BATTERY] Battery Saver turned ON during tracking - Auto clock-out!");
        await _handleBatterySaverAutoClockOut();
      }

      // Update UI if status changed
      if (mounted && previousStatus != _isBatterySaverOn) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("❌ Error checking battery saver: $e");
    }
  }

  // ✅ CHECK INITIAL BATTERY SAVER STATUS
  void _checkInitialBatterySaverStatus() async {
    try {
      _isBatterySaverOn = await BatterySaverService.isBatterySaverOn();
      debugPrint("🔋 Initial Battery Saver Status: $_isBatterySaverOn");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("❌ Error checking initial battery saver status: $e");
    }
  }

  // ✅ CHECK BATTERY SAVER ON APP RESUME
  void _checkBatterySaverOnResume() async {
    try {
      bool previousStatus = _isBatterySaverOn;
      _isBatterySaverOn = await BatterySaverService.isBatterySaverOn();

      debugPrint("🔋 [RESUME] Battery Saver Status: $_isBatterySaverOn | Was: $previousStatus");

      // If user is clocked in and battery saver turned on while app was in background
      if (attendanceViewModel.isClockedIn.value && !previousStatus && _isBatterySaverOn) {
        debugPrint("🚨 [BATTERY] Battery Saver turned ON while app was in background!");
        await _handleBatterySaverAutoClockOut();
      }

      if (mounted && previousStatus != _isBatterySaverOn) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("❌ Error checking battery saver on resume: $e");
    }
  }

  // ✅ BATTERY SAVER AUTO CLOCK-OUT
  Future<void> _handleBatterySaverAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;

    debugPrint("🔄 [BATTERY SAVER AUTO] Auto Clock-Out triggered - Battery Saver ON");

    try {
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      // ✅ GET CURRENT DISTANCE
      LocationService locationService = LocationService();
      await locationService.init();
      double finalDistance = await locationService.calculateCurrentDistance();

      // 🔥 DAILY CONSOLIDATION
      await locationViewModel.consolidateDailyGPXData();
      debugPrint("✅ [BATTERY SAVER AUTO] All today's points merged");

      // ✅ STOP TRAVEL TIME TRACKING
      travelTimeViewModel.stopTracking();
      debugPrint("📍 [TRAVEL TIME] Travel tracking stopped (Battery Saver)");

      locationViewModel.saveCurrentLocation().catchError((e)
      => debugPrint("Battery saver auto location error: $e"));

      final service = FlutterBackgroundService();

      // UPDATE UI STATE
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);

      // ✅ SAVE CLOCK-OUT TIME AND REASON
      await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
      await prefs.setDouble('lastDistance', finalDistance);
      await prefs.setString('clockOutReason', 'battery_saver_auto');

      // UPDATE RIVE ANIMATION
      _isRiveAnimationActive = false;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      // RESET LOCAL VARIABLES
      _localElapsedTime = '00:00:00';
      _localClockInTime = null;
      _currentDistance = 0.0;

      // STOP BACKGROUND SERVICE
      service.invoke("stopService");

      // ✅ SAVE ATTENDANCE OUT WITH BATTERY SAVER REASON
      await attendanceOutViewModel.saveFormAttendanceOut();

      // 🔥 24 HOURS DATA PROCESSING
      await locationViewModel.updateTodayCentralPoint();
      debugPrint("✅ [24HOURS] Daily GPX data processed (Battery Saver)");

      // 🔥 SAVE LOCATION FROM CONSOLIDATED FILE
      await locationViewModel.saveLocationFromConsolidatedFile();
      debugPrint("💾 Location saved from consolidated file (Battery Saver)");

      locationViewModel.saveClockStatus(false).catchError((e)
      => debugPrint("Battery saver clock status error: $e"));

      await location.enableBackgroundMode(enable: false);

      // ✅ SYNC after auto clock-out
      if (!_isSyncing) {
        await updateFunctionViewModel.syncAllLocalDataToServer();
        debugPrint("🔄 [SYNC] Data synced after battery saver auto clock-out");
      }

      debugPrint("✅ [BATTERY SAVER AUTO] Auto Clock-Out completed");
      debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");

      // Show battery saver auto clock-out notification
      Get.snackbar(
        '⚠️ Battery Saver Detected',
        'Auto clock-out due to Battery Saver mode. Distance: ${finalDistance.toStringAsFixed(2)} km',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
        icon: Icon(Icons.battery_alert, color: Colors.white),
        mainButton: TextButton(
          onPressed: () {
            BatterySaverService.openBatterySaverSettings();
          },
          child: Text('SETTINGS', style: TextStyle(color: Colors.white)),
        ),
      );

    } catch (e) {
      debugPrint("❌ [BATTERY SAVER AUTO] Error: $e");

      // Emergency fallback
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      Get.snackbar(
        'Battery Saver Alert',
        'Auto clock-out completed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  // ✅ SIMPLE: START 11:58 PM DEVICE TIME TIMER
  void _startEleven58PMTimer() {
    _elevenPMTimer?.cancel();

    debugPrint("⏰ Starting 11:58 PM device time check");

    _elevenPMTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForEleven58PM();
    });
  }

  // ✅ SIMPLE: CHECK FOR 11:58 PM DEVICE TIME
  void _checkForEleven58PM() async {
    try {
      DateTime now = DateTime.now();

      if (now.hour == 23 && now.minute == 58) {
        debugPrint("🕰 11:58 PM DEVICE TIME DETECTED");

        if (attendanceViewModel.isClockedIn.value) {
          debugPrint("🤖 User is clocked in - triggering auto clock-out at 11:58 PM");
          await _handleEleven58PMAutoClockOut();
        } else {
          debugPrint("⏰ User already clocked out at 11:58 PM");
        }
      }
    } catch (e) {
      debugPrint("❌ Error in 11:58 PM check: $e");
    }
  }

  // ✅ SIMPLE: HANDLE 11:58 PM AUTO CLOCK-OUT
  Future<void> _handleEleven58PMAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;

    debugPrint("🔄 [11:58 PM] Automatic clock-out triggered by device time");

    try {
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;

      if (mounted) {
        setState(() {});
      }

      locationViewModel.saveCurrentLocation().catchError((e)
      => debugPrint("11:58 PM location error: $e"));

      final service = FlutterBackgroundService();

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      await prefs.remove('clockInTime');

      _isRiveAnimationActive = false;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;
      _currentDistance = 0.0;

      service.invoke("stopService");

      DateTime now = DateTime.now();
      DateTime clockOutTime = DateTime(now.year, now.month, now.day, 23, 58, 0);

      await attendanceOutViewModel.saveFormAttendanceOut(clockOutTime: clockOutTime);

      await locationViewModel.consolidateDailyGPXData();
      await locationViewModel.updateTodayCentralPoint();
      await locationViewModel.saveLocationFromConsolidatedFile();
      await locationViewModel.saveClockStatus(false);

      await location.enableBackgroundMode(enable: false);

      if (!_isSyncing) {
        await updateFunctionViewModel.syncAllLocalDataToServer();
        debugPrint("🔄 [SYNC] Data synced after 11:58 PM auto clock-out");
      }

      Get.snackbar(
        'Auto Clock-Out',
        'Automatically clocked out at 11:58 PM',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.purple.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
        icon: const Icon(Icons.access_time, color: Colors.white),
      );

      debugPrint("✅ [11:58 PM] Auto clock-out completed successfully");

    } catch (e) {
      debugPrint("❌ [11:58 PM] Error during auto clock-out: $e");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      Get.snackbar(
        'Auto Clock-Out',
        'System automatically ended your shift at 11:58 PM',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.purple.shade700,
        colorText: Colors.white,
      );
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  // GET GPX FILE NAME CONSISTENTLY
  String _getGpxFileName() {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return 'track_${user_id}_$date.gpx';
  }

  String _getConsolidatedFileName() {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return 'track$date.gpx';
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
      double distance = await locationService.calculateCurrentDistance();

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
      return await locationService.calculateCurrentDistance();
    } catch (e) {
      return 0.0;
    }
  }

  // ✅ AUTO-SYNC MONITORING SYSTEM WITH SYNC LOCK
  void _startAutoSyncMonitoring() async {
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

  // ✅ CHECK CONNECTIVITY AND SYNC WITH PROTECTION
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

  // ✅ TRIGGER AUTO-SYNC WITH SYNC LOCKING
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time display
                Obx(() {
                  String displayTime = _localElapsedTime;
                  if (displayTime == '00:00:00' && attendanceViewModel.isClockedIn.value) {
                    displayTime = attendanceViewModel.elapsedTime.value;
                  }

                  return Text(
                    displayTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                }),
                // ✅ ADD: Distance display
                Obx(() {
                  if (attendanceViewModel.isClockedIn.value) {
                    return FutureBuilder<double>(
                      future: _getCurrentDistance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data! > 0) {
                          return Text(
                            '${snapshot.data!.toStringAsFixed(2)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            // ✅ MODIFIED: Add battery saver detection and visual indicator
            Obx(() {
              bool isClockedIn = attendanceViewModel.isClockedIn.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Battery saver indicator (only shown when NOT clocked in)
                  if (!isClockedIn && _isBatterySaverOn)
                    _buildBatterySaverIndicator(),

                  // Clock button
                  _buildClockButton(isClockedIn),
                ],
              );
            }),
          ],
        )
    );
  }

  // ✅ NEW: Build battery saver indicator
  Widget _buildBatterySaverIndicator() {
    return GestureDetector(
      onTap: () async {
        await _showBatterySaverDialog(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade100,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.battery_alert,
          color: Colors.orange.shade700,
          size: 14,
        ),
      ),
    );
  }

  // ✅ NEW: Build clock button
  Widget _buildClockButton(bool isClockedIn) {
    bool isButtonDisabled = !isClockedIn && _isBatterySaverOn;

    return ElevatedButton(
      onPressed: isButtonDisabled ? null : () async {
        debugPrint("🎯 [BUTTON] Button pressed");
        debugPrint("   - Clocked In: $isClockedIn");
        debugPrint("   - Battery Saver: $_isBatterySaverOn");

        if (isClockedIn) {
          await _handleClockOut(context);
        } else {
          // ✅ Check battery saver before allowing clock-in
          await _checkBatterySaverAndClockIn(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isClockedIn ? Colors.redAccent : Colors.green,
        minimumSize: const Size(30, 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.zero,
        // Disable button if battery saver is ON and user is not clocked in
        foregroundColor: isButtonDisabled ? Colors.grey[400] : null,
        side: isButtonDisabled ? BorderSide(color: Colors.grey.shade300) : null,
      ),
      child: SizedBox(
        width: 35,
        height: 35,
        child: Opacity(
          opacity: isButtonDisabled ? 0.5 : 1.0,
          child: RiveAnimation.asset(
            iconsRiv,
            stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
            artboard: _themeMenuIcon[0].riveIcon.artboard,
            onInit: onThemeRiveIconInit,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Check battery saver before clock-in
  Future<void> _checkBatterySaverAndClockIn(BuildContext context) async {
    // Check battery saver status
    if (_isBatterySaverOn) {
      debugPrint("🔋 Battery Saver ON - Clock-in disabled");

      // Show battery saver dialog
      bool shouldProceed = await _showBatterySaverDialog(context);

      if (!shouldProceed) {
        debugPrint("⏸️ User cancelled clock-in due to battery saver");
        return;
      }

      // Check again after dialog
      _isBatterySaverOn = await BatterySaverService.isBatterySaverOn();

      if (_isBatterySaverOn) {
        Get.snackbar(
          'Battery Saver Still ON',
          'Please turn OFF Battery Saver to clock in',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        if (mounted) setState(() {});
        return;
      }
    }

    // Battery saver is OFF, proceed with clock-in
    await _handleClockIn(context);
  }

  // ✅ NEW: Show battery saver dialog
  Future<bool> _showBatterySaverDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Battery Saver Detected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ Battery Saver is currently ON.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Clock-In is BLOCKED',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You cannot clock-in while Battery Saver is active. '
                          'GPS tracking requires full battery optimization.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'To continue, please:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              _buildInstructionStep('1. Open Battery Settings', Icons.settings),
              _buildInstructionStep('2. Turn OFF "Power Saving Mode"', Icons.power_settings_new),
              _buildInstructionStep('3. Return to this app', Icons.refresh),
              SizedBox(height: 20),
              Text(
                'Note: Battery Saver limits GPS accuracy and may cause auto clock-out.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('CANCEL', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              BatterySaverService.openBatterySaverSettings();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.settings, size: 18),
            label: Text('OPEN SETTINGS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ) ?? false;
  }

  Widget _buildInstructionStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Icon(icon, size: 14, color: Colors.blue.shade700),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Clock-in method with proper GPX file creation
  Future<void> _handleClockIn(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");

    // ✅ ADD: Battery saver check
    if (_isBatterySaverOn) {
      debugPrint("🔋 Battery Saver ON - Cannot clock in");
      Get.snackbar(
        'Battery Saver ON',
        'Please turn OFF Battery Saver to clock in',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

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
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      LocationService locationService = LocationService();
      await locationService.init();
      await locationService.listenLocation();

      await Future.delayed(const Duration(seconds: 2));

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
      File file = File(filePath);

      if (!file.existsSync()) {
        debugPrint("⚠️ GPX file was not created at: $filePath");
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
      debugPrint("📍 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");

      if (initialDistance > 0.001) {
        debugPrint("⚠️ Suspicious initial distance, resetting...");
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
      debugPrint("📏 Initial Distance: ${initialDistance.toStringAsFixed(3)} km");
      debugPrint("📁 GPX File: $filePath");
      debugPrint("📊 File Size: ${file.lengthSync()} bytes");

      Get.snackbar(
        'Clocked In Successfully',
        'GPS tracking started',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      debugPrint("❌ [CLOCK-IN] Error: $e");
      Get.snackbar('Error', 'Failed to clock in: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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

  // ✅ FIXED: 2-SECOND CLOCK-OUT METHOD - IMMEDIATE LOCAL SAVE
  Future<void> _handleClockOut(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== 2-SECOND CLOCK-OUT STARTED =====");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint("⚡ Step 1: Immediate local save");

      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      LocationService locationService = LocationService();
      await locationService.init();
      double finalDistance = await locationService.calculateCurrentDistance();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
      await prefs.setDouble('lastDistance', finalDistance);
      await prefs.setBool('isClockedIn', false);

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      _isRiveAnimationActive = false;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
          clockOutTime: DateTime.now(),
          distance: finalDistance
      );

      debugPrint("📁 Processing GPX data for posting...");

      await locationViewModel.consolidateDailyGPXData();
      debugPrint("✅ [CONSOLIDATION] All today's points merged into single file");

      await locationViewModel.saveLocationLocallyOnly();
      debugPrint("💾 Location saved locally with posted=0");

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;
      _currentDistance = 0.0;

      await prefs.remove('clockInTime');

      if (mounted) {
        setState(() {});
      }

      final service = FlutterBackgroundService();
      service.invoke("stopService");
      await location.enableBackgroundMode(enable: false);

      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });

      Get.snackbar(
        'Clocked Out',
        'Data saved locally. Will sync when online.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      debugPrint("✅ [CLOCK-OUT] Local save completed in 2 seconds");
      debugPrint("📏 Final Distance: ${finalDistance.toStringAsFixed(3)} km");
      debugPrint("⏰ [TIMER RESET] Timer reset to 00:00:00");

      _tryBackgroundSync();

    } catch (e) {
      debugPrint("❌ [CLOCK-OUT] Error: $e");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      _localElapsedTime = '00:00:00';
      if (mounted) setState(() {});

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        'Clocked Out',
        'Basic data saved. Full sync will complete later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ✅ NEW: Try background sync if online
  void _tryBackgroundSync() async {
    if (_isOnline && !_isSyncing) {
      debugPrint("🔄 Trying background sync after clock-out");

      try {
        await locationViewModel.locationRepository.postDataFromDatabaseToAPI();
        debugPrint("📤 GPX data posted to API");

        await attendanceOutViewModel.attendanceOutRepository.postDataFromDatabaseToAPI();
        debugPrint("📤 Attendance out data posted to API");

      } catch (e) {
        debugPrint("❌ Error in background sync: $e");
      }
    } else {
      debugPrint("⏸️ Offline - Sync will happen when online");
    }
  }

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
        await _handleAutoClockOut();
      }

      _wasLocationAvailable = currentLocationAvailable;
    });
  }

  Future<void> _handleAutoClockOut() async {
    if (_autoClockOutInProgress) return;
    _autoClockOutInProgress = true;
    debugPrint("🔄 [AUTO] Auto Clock-Out triggered due to location OFF");

    try {
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();

      LocationService locationService = LocationService();
      await locationService.init();
      double finalDistance = await locationService.calculateCurrentDistance();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
      await prefs.setDouble('lastDistance', finalDistance);
      await prefs.setBool('isClockedIn', false);

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      attendanceViewModel.elapsedTime.value = '00:00:00';

      _isRiveAnimationActive = false;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      await attendanceOutViewModel.saveFormAttendanceOutLocalOnly(
          clockOutTime: DateTime.now(),
          distance: finalDistance
      );

      await locationViewModel.consolidateDailyGPXData();
      await locationViewModel.saveLocationLocallyOnly();

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;
      _currentDistance = 0.0;

      await prefs.remove('clockInTime');

      if (mounted) {
        setState(() {});
      }

      final service = FlutterBackgroundService();
      service.invoke("stopService");
      await location.enableBackgroundMode(enable: false);

      debugPrint("✅ [AUTO] Auto Clock-Out completed locally");
      debugPrint("📏 Distance: ${finalDistance.toStringAsFixed(3)} km");

      Get.snackbar(
        'Auto Clock Out',
        'Location off. Data saved locally.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      _tryBackgroundSync();

    } catch (e) {
      debugPrint("❌ [AUTO] Auto clock-out error: $e");
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  // TimerCard mein add karein
  void _setupMidnightProcessing() {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    Timer(timeUntilMidnight, () {
      _processPreviousDayData();
      _setupMidnightProcessing();
    });
  }

  Future<void> _processPreviousDayData() async {
    debugPrint("🌙 Processing previous day's data at midnight");

    await locationViewModel.consolidateDailyGPXData();
    debugPrint("✅ [MIDNIGHT] Previous day's data consolidated");

    await locationViewModel.updateTodayCentralPoint();
    await locationViewModel.generateDailySummary();

    debugPrint("🌙 Midnight processing completed for previous day");
  }

  void _stopLocationMonitoring() {
    _locationMonitorTimer?.cancel();
    _locationMonitorTimer = null;
    _autoClockOutInProgress = false;
  }

  // ✅ DIAGNOSTIC: Check GPX File Status
  Future<void> _checkGPXFileStatus() async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();

      final filePath1 = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
      final filePath2 = "${downloadDirectory!.path}/track$date.gpx";

      File file1 = File(filePath1);
      File file2 = File(filePath2);

      debugPrint("📁 FILE STATUS CHECK:");
      debugPrint("   - File 1 ($filePath1): ${file1.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
      if (file1.existsSync()) {
        debugPrint("     Size: ${file1.lengthSync()} bytes");
      }

      debugPrint("   - File 2 ($filePath2): ${file2.existsSync() ? 'EXISTS' : 'NOT FOUND'}");
      if (file2.existsSync()) {
        debugPrint("     Size: ${file2.lengthSync()} bytes");
      }

    } catch (e) {
      debugPrint("❌ Error checking GPX status: $e");
    }
  }
}