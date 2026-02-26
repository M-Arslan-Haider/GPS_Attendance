// // // //
// // // //
// // // // import 'dart:async';
// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // // import 'package:geolocator/geolocator.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // // // import 'package:rive/rive.dart';
// // // // import 'package:location/location.dart' as loc;
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // import '../../Databases/util.dart';
// // // // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // // // import '../../Tracker/location00.dart';
// // // // import '../../Tracker/trac.dart';
// // // // import '../../Utils/daily_work_time_manager.dart';
// // // // import '../../main.dart';
// // // // import 'assets.dart';
// // // // import 'menu_item.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:intl/intl.dart';
// // // //
// // // // class TimerCard extends StatefulWidget {
// // // //   const TimerCard({super.key});
// // // //
// // // //   @override
// // // //   State<TimerCard> createState() => _TimerCardState();
// // // // }
// // // //
// // // // class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
// // // //   final locationViewModel = Get.find<LocationViewModel>();
// // // //   final attendanceViewModel = Get.find<AttendanceViewModel>();
// // // //   final attendanceOutViewModel = Get.find<AttendanceOutViewModel>();
// // // //   final updateFunctionViewModel = Get.find<UpdateFunctionViewModel>();
// // // //   final TravelTimeViewModel travelTimeViewModel = Get.put(
// // // //       TravelTimeViewModel());
// // // //
// // // //   final loc.Location location = loc.Location();
// // // //   final Connectivity _connectivity = Connectivity();
// // // //
// // // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // // //   Timer? _locationMonitorTimer;
// // // //   bool _wasLocationAvailable = true;
// // // //   bool _autoClockOutInProgress = false;
// // // //
// // // //   bool _isRiveAnimationActive = false;
// // // //   Timer? _localBackupTimer;
// // // //   DateTime? _localClockInTime;
// // // //   String _localElapsedTime = '00:00:00';
// // // //
// // // //   // Auto-sync variables
// // // //   Timer? _autoSyncTimer;
// // // //   bool _isOnline = false;
// // // //   bool _isSyncing = false;
// // // //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// // // //
// // // //   // Distance tracking
// // // //   double _currentDistance = 0.0;
// // // //   Timer? _distanceUpdateTimer;
// // // //   // Permission monitoring
// // // //   bool _wasPermissionGranted = true;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     WidgetsBinding.instance.addObserver(this);
// // // //
// // // //     _initializeFromPersistentState();
// // // //     _startAutoSyncMonitoring();
// // // //     _startDistanceUpdater();
// // // //
// // // //     // ✅ CHECK FOR PENDING DATA ON STARTUP
// // // //     _checkAndSyncPendingData();
// // // //   }
// // // //
// // // //   @override
// // // //   void didChangeDependencies() {
// // // //     super.didChangeDependencies();
// // // //     _restoreEverything();
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     WidgetsBinding.instance.removeObserver(this);
// // // //     _stopLocationMonitoring();
// // // //     _localBackupTimer?.cancel();
// // // //     _autoSyncTimer?.cancel();
// // // //     _connectivitySubscription?.cancel();
// // // //     _distanceUpdateTimer?.cancel();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   @override
// // // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // // //     debugPrint("🔄 [LIFECYCLE] App state changed: $state");
// // // //
// // // //     if (state == AppLifecycleState.resumed) {
// // // //       _restoreEverything();
// // // //       _checkConnectivityAndSync();
// // // //
// // // //       // ✅ CHECK FOR PENDING DATA
// // // //       _checkAndSyncPendingData();
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ CHECK FOR PENDING DATA
// // // //   void _checkAndSyncPendingData() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// // // //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// // // //
// // // //     if (hasPendingClockOut || clockOutPending) {
// // // //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// // // //       _triggerAutoSync();
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ START DISTANCE UPDATER
// // // //   void _startDistanceUpdater() {
// // // //     _distanceUpdateTimer =
// // // //         Timer.periodic(const Duration(seconds: 5), (timer) async {
// // // //           if (attendanceViewModel.isClockedIn.value) {
// // // //             await _updateCurrentDistance();
// // // //           }
// // // //         });
// // // //   }
// // // //
// // // //   // ✅ UPDATE CURRENT DISTANCE
// // // //   Future<void> _updateCurrentDistance() async {
// // // //     try {
// // // //       LocationService locationService = LocationService();
// // // //       await locationService.init();
// // // //       double distance = locationService.getCurrentDistance();
// // // //
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           _currentDistance = distance;
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("❌ Distance update error: $e");
// // // //     }
// // // //   }
// // // //
// // // //   ///added on 21-02-2026
// // // //
// // // //
// // // //   // ✅ GET CURRENT DISTANCE
// // // //   Future<double> _getCurrentDistance() async {
// // // //     if (_currentDistance > 0) {
// // // //       return _currentDistance;
// // // //     }
// // // //
// // // //     try {
// // // //       LocationService locationService = LocationService();
// // // //       await locationService.init();
// // // //       return locationService.getCurrentDistance();
// // // //     } catch (e) {
// // // //       return 0.0;
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ AUTO-SYNC MONITORING SYSTEM
// // // //   void _startAutoSyncMonitoring() async {
// // // //     // Listen to connectivity changes
// // // //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
// // // //         List<ConnectivityResult> results) {
// // // //       bool wasOnline = _isOnline;
// // // //       _isOnline = results.isNotEmpty &&
// // // //           results.any((result) => result != ConnectivityResult.none);
// // // //
// // // //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline
// // // //           ? 'ONLINE'
// // // //           : 'OFFLINE'} | Was: ${wasOnline
// // // //           ? 'ONLINE'
// // // //           : 'OFFLINE'} | Syncing: $_isSyncing");
// // // //
// // // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // // //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// // // //         _triggerAutoSync();
// // // //       }
// // // //     });
// // // //
// // // //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// // // //       if (!_isSyncing) {
// // // //         _checkConnectivityAndSync();
// // // //       }
// // // //     });
// // // //
// // // //     _checkConnectivityAndSync();
// // // //   }
// // // //
// // // //   // ✅ CHECK CONNECTIVITY AND SYNC
// // // //   void _checkConnectivityAndSync() async {
// // // //     if (_isSyncing) {
// // // //       debugPrint('⏸️ Sync already in progress - skipping');
// // // //       return;
// // // //     }
// // // //
// // // //     try {
// // // //       var results = await _connectivity.checkConnectivity();
// // // //       bool wasOnline = _isOnline;
// // // //       _isOnline = results.isNotEmpty &&
// // // //           results.any((result) => result != ConnectivityResult.none);
// // // //
// // // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // // //         debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
// // // //         _triggerAutoSync();
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ TRIGGER AUTO-SYNC
// // // //   void _triggerAutoSync() async {
// // // //     if (_isSyncing) {
// // // //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// // // //       return;
// // // //     }
// // // //
// // // //     _isSyncing = true;
// // // //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// // // //
// // // //     try {
// // // //       Get.snackbar(
// // // //         'Syncing Data',
// // // //         'Auto-syncing offline data...',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.blue.shade700,
// // // //         colorText: Colors.white,
// // // //         duration: const Duration(seconds: 3),
// // // //       );
// // // //
// // // //       await updateFunctionViewModel.syncAllLocalDataToServer();
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('hasPendingClockOutData', false);
// // // //       await prefs.setBool('clockOutPending', false);
// // // //       await prefs.setBool('hasFastClockOutData', false);
// // // //
// // // //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// // // //     } catch (e) {
// // // //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// // // //     } finally {
// // // //       _isSyncing = false;
// // // //       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
// // // //     }
// // // //   }
// // // //
// // // //   void _restoreEverything() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // //
// // // //     if (isClockedIn) {
// // // //       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
// // // //
// // // //       locationViewModel.isClockedIn.value = true;
// // // //       attendanceViewModel.isClockedIn.value = true;
// // // //
// // // //       _isRiveAnimationActive = true;
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // // //       }
// // // //
// // // //       _startLocalBackupTimer();
// // // //
// // // //       if (mounted) {
// // // //         setState(() {});
// // // //       }
// // // //
// // // //       debugPrint("✅ [BULLETPROOF] Everything restored successfully");
// // // //     }
// // // //   }
// // // //
// // // //   void _startLocalBackupTimer() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     String? clockInTimeString = prefs.getString('clockInTime');
// // // //
// // // //     if (clockInTimeString == null) return;
// // // //
// // // //     _localClockInTime = DateTime.parse(clockInTimeString);
// // // //     _localBackupTimer?.cancel();
// // // //
// // // //     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // //       if (_localClockInTime == null) return;
// // // //
// // // //       final now = DateTime.now();
// // // //       final duration = now.difference(_localClockInTime!);
// // // //
// // // //       String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // //       String hours = twoDigits(duration.inHours);
// // // //       String minutes = twoDigits(duration.inMinutes.remainder(60));
// // // //       String seconds = twoDigits(duration.inSeconds.remainder(60));
// // // //
// // // //       _localElapsedTime = '$hours:$minutes:$seconds';
// // // //       attendanceViewModel.elapsedTime.value = _localElapsedTime;
// // // //
// // // //       if (mounted) {
// // // //         setState(() {});
// // // //       }
// // // //     });
// // // //
// // // //     debugPrint("✅ [BACKUP TIMER] Local backup timer started");
// // // //   }
// // // //
// // // //   Future<void> _initializeFromPersistentState() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// // // //
// // // //     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn");
// // // //
// // // //     locationViewModel.isClockedIn.value = isClockedIn;
// // // //     attendanceViewModel.isClockedIn.value = isClockedIn;
// // // //     _isRiveAnimationActive = isClockedIn;
// // // //
// // // //     if (isClockedIn) {
// // // //       debugPrint("✅ [INIT] User was clocked in - starting everything...");
// // // //
// // // //       _startBackgroundServices();
// // // //       _startLocationMonitoring();
// // // //       _startLocalBackupTimer();
// // // //
// // // //       debugPrint("✅ [INIT] Full clocked-in state restored");
// // // //     }
// // // //
// // // //     if (mounted) {
// // // //       setState(() {});
// // // //     }
// // // //   }
// // // //
// // // //   void onThemeRiveIconInit(Artboard artboard) {
// // // //     final controller = StateMachineController.fromArtboard(
// // // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // // //     if (controller != null) {
// // // //       artboard.addController(controller);
// // // //       _themeMenuIcon[0].riveIcon.status =
// // // //       controller.findInput<bool>("active") as SMIBool?;
// // // //
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// // // //         debugPrint(
// // // //             "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// // // //       }
// // // //     } else {
// // // //       debugPrint("StateMachineController not found!");
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Center(
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min, // 👈 important
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           crossAxisAlignment: CrossAxisAlignment.center,
// // // //           children: [
// // // //             // Timer + Distance
// // // //             Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.center,
// // // //               children: [
// // // //                 Obx(() {
// // // //                   String displayTime = _localElapsedTime;
// // // //                   if (displayTime == '00:00:00' &&
// // // //                       attendanceViewModel.isClockedIn.value) {
// // // //                     displayTime = attendanceViewModel.elapsedTime.value;
// // // //                   }
// // // //
// // // //                   return Text(
// // // //                     displayTime,
// // // //                     style: TextStyle(
// // // //                       fontSize: 20,
// // // //                       fontWeight: FontWeight.bold,
// // // //                       color: attendanceViewModel.isClockedIn.value
// // // //                           ? Colors.black87
// // // //                           : Colors.grey,
// // // //                     ),
// // // //                   );
// // // //                 }),
// // // //
// // // //                 Obx(() {
// // // //                   if (attendanceViewModel.isClockedIn.value &&
// // // //                       _currentDistance > 0) {
// // // //                     return Text(
// // // //                       '${_currentDistance.toStringAsFixed(2)} km',
// // // //                       style: TextStyle(
// // // //                         fontSize: 14,
// // // //                         color: Colors.blue.shade700,
// // // //                         fontWeight: FontWeight.w500,
// // // //                       ),
// // // //                     );
// // // //                   }
// // // //                   return const SizedBox.shrink();
// // // //                 }),
// // // //               ],
// // // //             ),
// // // //
// // // //             const SizedBox(height: 5),
// // // //
// // // //             // Buttons
// // // //             Row(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 Obx(() {
// // // //                   return SizedBox(
// // // //                       width: 120, // Fixed width
// // // //                       height: 30,
// // // //                       child:  ElevatedButton(
// // // //                         onPressed: attendanceViewModel.isClockedIn.value
// // // //                             ? null
// // // //                             : () async => _handleClockIn(context),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Colors.blueGrey,
// // // //                           shape: RoundedRectangleBorder(
// // // //                             borderRadius: BorderRadius.circular(8),
// // // //                           ),
// // // //                         ),
// // // //                         child: const Row(
// // // //                           mainAxisSize: MainAxisSize.min,
// // // //                           children: [
// // // //                             // Icon(Icons.play_arrow, color: Colors.white),
// // // //                             Text("Clock In", style: TextStyle(
// // // //                               color: Colors.white,
// // // //                               fontSize: 15, // Text size
// // // //                               fontWeight: FontWeight.w600, // Boldness
// // // //                               letterSpacing: 0.5, // Space between letters
// // // //                             ))
// // // //                           ],
// // // //                         ),
// // // //                       )
// // // //                   );
// // // //                 }),
// // // //
// // // //                 const SizedBox(width: 5),
// // // //
// // // //                 Obx(() { return SizedBox(
// // // //                     width: 120, // Fixed width
// // // //                     height: 30,
// // // //                     child:  ElevatedButton(
// // // //                       onPressed: attendanceViewModel.isClockedIn.value
// // // //                           ? () async => _handleClockOut(context)
// // // //                           : null,
// // // //                       style: ElevatedButton.styleFrom(
// // // //                         backgroundColor: Colors.redAccent,
// // // //                         shape: RoundedRectangleBorder(
// // // //                           borderRadius: BorderRadius.circular(8),
// // // //                         ),
// // // //                       ),
// // // //                       child: const Row(
// // // //                         mainAxisSize: MainAxisSize.min,
// // // //                         children: [
// // // //                           // Icon(Icons.stop, color: Colors.white),
// // // //                           Text("Clock Out", style: TextStyle(
// // // //                             color: Colors.white,
// // // //                             fontSize: 15, // Text size
// // // //                             fontWeight: FontWeight.w600, // Boldness
// // // //                             letterSpacing: 0.5, // Space between letters
// // // //                           ))
// // // //                         ],
// // // //                       ),
// // // //                     )
// // // //                 );
// // // //                 }),
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 100.0),
// // // // //       child: Column(
// // // // //         children: [
// // // // //           Row(
// // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //             children: [
// // // // //               Column(
// // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                 children: [
// // // // //                   // Timer Display
// // // // //                   Obx(() {
// // // // //                     String displayTime = _localElapsedTime;
// // // // //                     if (displayTime == '00:00:00' &&
// // // // //                         attendanceViewModel.isClockedIn.value) {
// // // // //                       displayTime = attendanceViewModel.elapsedTime.value;
// // // // //                     }
// // // // //
// // // // //                     return Text(
// // // // //                       displayTime,
// // // // //                       style: TextStyle(
// // // // //                         fontSize: 20,
// // // // //                         fontWeight: FontWeight.bold,
// // // // //                         color: attendanceViewModel.isClockedIn.value
// // // // //                             ? Colors.black87
// // // // //                             : Colors.grey,
// // // // //                       ),
// // // // //                     );
// // // // //                   }),
// // // // //
// // // // //                   // Distance Display
// // // // //                   Obx(() {
// // // // //                     if (attendanceViewModel.isClockedIn.value &&
// // // // //                         _currentDistance > 0) {
// // // // //                       return Text(
// // // // //                         '${_currentDistance.toStringAsFixed(2)} km',
// // // // //                         style: TextStyle(
// // // // //                           fontSize: 12,
// // // // //                           color: Colors.blue.shade700,
// // // // //                           fontWeight: FontWeight.w500,
// // // // //                         ),
// // // // //                       );
// // // // //                     }
// // // // //                     return const SizedBox.shrink();
// // // // //                   }),
// // // // //                 ],
// // // // //               ),
// // // // //
// // // // //               // Clock In/Out Button
// // // // //               // Obx(() {
// // // // //               //   return ElevatedButton(
// // // // //               //     onPressed: () async {
// // // // //               //       debugPrint("🎯 [BUTTON] Button pressed");
// // // // //               //       debugPrint(
// // // // //               //           "   - Clocked In: ${attendanceViewModel.isClockedIn
// // // // //               //               .value}");
// // // // //               //
// // // // //               //       if (attendanceViewModel.isClockedIn.value) {
// // // // //               //         await _handleClockOut(context);
// // // // //               //       } else {
// // // // //               //         await _handleClockIn(context);
// // // // //               //       }
// // // // //               //     },
// // // // //               //     style: ElevatedButton.styleFrom(
// // // // //               //       backgroundColor: attendanceViewModel.isClockedIn.value
// // // // //               //           ? Colors.redAccent
// // // // //               //           : Colors.green,
// // // // //               //       minimumSize: const Size(30, 30),
// // // // //               //       shape: RoundedRectangleBorder(
// // // // //               //         borderRadius: BorderRadius.circular(12),
// // // // //               //       ),
// // // // //               //       padding: EdgeInsets.zero,
// // // // //               //     ),
// // // // //               //     child: SizedBox(
// // // // //               //       width: 35,
// // // // //               //       height: 35,
// // // // //               //       child: RiveAnimation.asset(
// // // // //               //         iconsRiv,
// // // // //               //         stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
// // // // //               //         artboard: _themeMenuIcon[0].riveIcon.artboard,
// // // // //               //         onInit: onThemeRiveIconInit,
// // // // //               //         fit: BoxFit.cover,
// // // // //               //       ),
// // // // //               //     ),
// // // // //               //   );
// // // // //               // }),
// // // // //               // Start Button
// // // // //               Obx(() {
// // // // //                 return ElevatedButton(
// // // // //                   onPressed: attendanceViewModel.isClockedIn.value ? null : () async {
// // // // //                     debugPrint("▶️ [BUTTON] Start button pressed");
// // // // //                     await _handleClockIn(context);
// // // // //                   },
// // // // //                   style: ElevatedButton.styleFrom(
// // // // //                     backgroundColor: Colors.green,
// // // // //                     minimumSize: const Size(60, 30),
// // // // //                     shape: RoundedRectangleBorder(
// // // // //                       borderRadius: BorderRadius.circular(12),
// // // // //                     ),
// // // // //                     padding: EdgeInsets.zero,
// // // // //                   ),
// // // // //                   child: const SizedBox(
// // // // //                     width: 35,
// // // // //                     height: 35,
// // // // //                     child: Icon(Icons.play_arrow, color: Colors.white),
// // // // //                   ),
// // // // //                 );
// // // // //               }),
// // // // //
// // // // // // Add some spacing between buttons
// // // // //               const SizedBox(width: 10),
// // // // //
// // // // // // Stop Button
// // // // //               Obx(() {
// // // // //                 return ElevatedButton(
// // // // //                   onPressed: attendanceViewModel.isClockedIn.value ? () async {
// // // // //                     debugPrint("⏹️ [BUTTON] Stop button pressed");
// // // // //                     await _handleClockOut(context);
// // // // //                   } : null,
// // // // //                   style: ElevatedButton.styleFrom(
// // // // //                     backgroundColor: Colors.redAccent,
// // // // //                     minimumSize: const Size(60, 30),
// // // // //                     shape: RoundedRectangleBorder(
// // // // //                       borderRadius: BorderRadius.circular(12),
// // // // //                     ),
// // // // //                     padding: EdgeInsets.zero,
// // // // //                   ),
// // // // //                   child: const SizedBox(
// // // // //                     width: 35,
// // // // //                     height: 35,
// // // // //                     child: Icon(Icons.stop, color: Colors.white),
// // // // //                   ),
// // // // //                 );
// // // // //               }),
// // // // //             ],
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // //   }
// // // //
// // // //   // ✅ ULTRA-FAST CLOCK-OUT METHOD
// // // //   Future<void> _handleClockOut(BuildContext context) async {
// // // //     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
// // // //
// // // //     // Show loading dialog
// // // //     bool showLoadingDialog = true;
// // // //     DateTime startTime = DateTime.now();
// // // //     Timer? loadingTimer;
// // // //
// // // //     if (showLoadingDialog) {
// // // //       showDialog(
// // // //         context: context,
// // // //         barrierDismissible: false,
// // // //         builder: (_) =>
// // // //             AlertDialog(
// // // //               backgroundColor: Colors.white.withOpacity(0.9),
// // // //               shape: RoundedRectangleBorder(
// // // //                 borderRadius: BorderRadius.circular(15),
// // // //               ),
// // // //               content: Column(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 children: [
// // // //                   CircularProgressIndicator(
// // // //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
// // // //                   ),
// // // //                   SizedBox(height: 15),
// // // //                   Text(
// // // //                     "Processing clock-out...",
// // // //                     style: TextStyle(
// // // //                       fontWeight: FontWeight.w500,
// // // //                       color: Colors.black87,
// // // //                     ),
// // // //                   ),
// // // //                   SizedBox(height: 5),
// // // //                   Text(
// // // //                     "Please wait 3 seconds",
// // // //                     style: TextStyle(
// // // //                       fontSize: 12,
// // // //                       color: Colors.grey,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //       );
// // // //
// // // //       loadingTimer = Timer(Duration(seconds: 3), () {});
// // // //     }
// // // //
// // // //     try {
// // // //       // Immediate state update
// // // //       _stopLocationMonitoring();
// // // //       _localBackupTimer?.cancel();
// // // //
// // // //       double finalDistance = _currentDistance;
// // // //       if (finalDistance <= 0) {
// // // //         try {
// // // //           LocationService locationService = LocationService();
// // // //           await locationService.init();
// // // //           finalDistance = locationService.getCurrentDistance();
// // // //           if (finalDistance <= 0) finalDistance = 0.0;
// // // //         } catch (e) {
// // // //           finalDistance = 0.0;
// // // //         }
// // // //       }
// // // //
// // // //       DateTime clockOutTime = DateTime.now();
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('isClockedIn', false);
// // // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // // //       await prefs.setBool('clockOutPending', true);
// // // //       await prefs.setBool('hasFastClockOutData', true);
// // // //
// // // //       locationViewModel.isClockedIn.value = false;
// // // //       attendanceViewModel.isClockedIn.value = false;
// // // //       _isRiveAnimationActive = false;
// // // //
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // // //       }
// // // //
// // // //       _localElapsedTime = '00:00:00';
// // // //       _localClockInTime = null;
// // // //
// // // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // // //         clockOutTime: clockOutTime,
// // // //         totalDistance: finalDistance,
// // // //         isAuto: true,
// // // //         reason: 'location_off_auto',     // location turned off
// // // //       );
// // // //
// // // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // // //         clockOutTime: clockOutTime,
// // // //         totalDistance: finalDistance,
// // // //         isAuto: true,
// // // //         reason: 'permission_revoked_auto', // permission removed
// // // //       );
// // // //
// // // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // // //         clockOutTime: clockOutTime,
// // // //         totalDistance: finalDistance,
// // // //       );
// // // //       // ADD THIS HERE ↓↓↓
// // // //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// // // //
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       service.invoke("stopService");
// // // //
// // // //       try {
// // // //         await location.enableBackgroundMode(enable: false);
// // // //       } catch (e) {
// // // //         debugPrint("⚠️ Background mode disable error: $e");
// // // //       }
// // // //
// // // //       DateTime endTime = DateTime.now();
// // // //       Duration elapsedTime = endTime.difference(startTime);
// // // //
// // // //       if (elapsedTime.inSeconds < 3) {
// // // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // // //       }
// // // //
// // // //       if (loadingTimer != null) loadingTimer.cancel();
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //
// // // //       Get.snackbar(
// // // //         '✅ Clock Out Complete',
// // // //         'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.green,
// // // //         colorText: Colors.white,
// // // //         duration: Duration(seconds: 2),
// // // //       );
// // // //
// // // //       debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");
// // // //
// // // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // // //     } catch (e) {
// // // //       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
// // // //
// // // //       DateTime endTime = DateTime.now();
// // // //       Duration elapsedTime = endTime.difference(startTime);
// // // //
// // // //       if (elapsedTime.inSeconds < 3) {
// // // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // // //       }
// // // //
// // // //       if (loadingTimer != null) loadingTimer.cancel();
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //
// // // //       Get.snackbar(
// // // //         'Clock Out Complete',
// // // //         'Data saved locally',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.orange,
// // // //         colorText: Colors.white,
// // // //         duration: Duration(seconds: 2),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ CHECK & REQUEST LOCATION PERMISSION
// // // //   Future<bool> _checkLocationPermission(BuildContext context) async {
// // // //     LocationPermission permission = await Geolocator.checkPermission();
// // // //
// // // //     if (permission == LocationPermission.denied) {
// // // //       permission = await Geolocator.requestPermission();
// // // //     }
// // // //
// // // //     if (permission == LocationPermission.denied ||
// // // //         permission == LocationPermission.deniedForever) {
// // // //       await showDialog(
// // // //         context: context,
// // // //         barrierDismissible: false,
// // // //         builder: (ctx) => Dialog(
// // // //           shape: RoundedRectangleBorder(
// // // //             borderRadius: BorderRadius.circular(20),
// // // //           ),
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.all(20),
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 const Icon(
// // // //                   Icons.location_off,
// // // //                   size: 50,
// // // //                   color: Colors.redAccent,
// // // //                 ),
// // // //                 const SizedBox(height: 15),
// // // //                 const Text(
// // // //                   "Location Permission Required",
// // // //                   style: TextStyle(
// // // //                     fontSize: 18,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 10),
// // // //                 const Text(
// // // //                   "We need location access to continue.\n"
// // // //                       "Please enable location permission from app settings.",
// // // //                   textAlign: TextAlign.center,
// // // //                   style: TextStyle(color: Colors.grey),
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //
// // // //                 /// Buttons
// // // //                 Row(
// // // //                   children: [
// // // //                     Expanded(
// // // //                       child: TextButton(
// // // //                         style: TextButton.styleFrom(
// // // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                           shape: RoundedRectangleBorder(
// // // //                             borderRadius: BorderRadius.circular(12),
// // // //                           ),
// // // //                         ),
// // // //                         onPressed: () => Navigator.of(ctx).pop(),
// // // //                         child: const Text(
// // // //                           "Cancel",
// // // //                           style: TextStyle(color: Colors.grey),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(width: 10),
// // // //                     Expanded(
// // // //                       child: ElevatedButton(
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Colors.blueGrey,
// // // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                           shape: RoundedRectangleBorder(
// // // //                             borderRadius: BorderRadius.circular(12),
// // // //                           ),
// // // //                         ),
// // // //                         onPressed: () async {
// // // //                           Navigator.of(ctx).pop();
// // // //                           await Geolocator.openAppSettings();
// // // //                         },
// // // //                         child: const Text(
// // // //                           "Open Settings",
// // // //                           style: TextStyle(color: Colors.white),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 )
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       );
// // // //       return false;
// // // //     }
// // // //
// // // //     return true;
// // // //   }
// // // //
// // // //
// // // //   // ✅ CLOCK-IN METHOD
// // // //   Future<void> _handleClockIn(BuildContext context) async {
// // // //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// // // //
// // // //     // Location check
// // // //     // ✅ PERMISSION CHECK — block clock-in if not granted
// // // //     bool hasPermission = await _checkLocationPermission(context);
// // // //     if (!hasPermission) {
// // // //       debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
// // // //       return;
// // // //     }
// // // //
// // // //     // Location check
// // // //     bool locationAvailable = await attendanceViewModel.isLocationAvailable();
// // // //     if (!locationAvailable) {
// // // //       Get.snackbar(
// // // //         'Location Required',
// // // //         'Please enable Location Services to clock in',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.red.shade700,
// // // //         colorText: Colors.white,
// // // //         duration: const Duration(seconds: 5),
// // // //       );
// // // //       return;
// // // //     }
// // // //
// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (_) =>
// // // //           AlertDialog(
// // // //             backgroundColor: Colors.white,
// // // //             content: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 CircularProgressIndicator(color: Colors.green),
// // // //                 SizedBox(height: 15),
// // // //                 Text('Checking permissions...',
// // // //                     style: TextStyle(fontWeight: FontWeight.w500)),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //     );
// // // //
// // // //     try {
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       LocationService locationService = LocationService();
// // // //       await locationService.init();
// // // //       await locationService.listenLocation();
// // // //
// // // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // // //       final downloadDirectory = await getDownloadsDirectory();
// // // //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// // // //       File file = File(filePath);
// // // //
// // // //       if (!file.existsSync()) {
// // // //         String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
// // // // <gpx version="1.1" creator="OrderBookingApp">
// // // //   <trk>
// // // //     <name>Daily Track $date</name>
// // // //     <trkseg>
// // // //     </trkseg>
// // // //   </trk>
// // // // </gpx>''';
// // // //         await file.writeAsString(initialGPX);
// // // //         debugPrint("✅ Created empty GPX file for tracking");
// // // //       }
// // // //
// // // //       double initialDistance = locationService.getCurrentDistance();
// // // //       if (initialDistance > 0.001) {
// // // //         locationService.resetDistance();
// // // //         initialDistance = 0.0;
// // // //       }
// // // //
// // // //       await attendanceViewModel.saveFormAttendanceIn();
// // // //       _startBackgroundServices();
// // // //
// // // //       locationViewModel.isClockedIn.value = true;
// // // //       attendanceViewModel.isClockedIn.value = true;
// // // //
// // // //       await prefs.setBool('isClockedIn', true);
// // // //       await prefs.setString('currentGpxFilePath', filePath);
// // // //       await prefs.setString(
// // // //           'currentSessionStart', DateTime.now().toIso8601String());
// // // //
// // // //       _isRiveAnimationActive = true;
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // // //       }
// // // //
// // // //       _startLocalBackupTimer();
// // // //       _startLocationMonitoring();
// // // //
// // // //       travelTimeViewModel.startTracking();
// // // //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// // // //
// // // //       await _updateCurrentDistance();
// // // //       await DailyWorkTimeManager.recordClockIn(DateTime.now());
// // // //
// // // //
// // // //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// // // //
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //
// // // //       Get.snackbar(
// // // //         '✅ Clocked In Successfully',
// // // //         'GPS tracking started',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.green,
// // // //         colorText: Colors.white,
// // // //         duration: const Duration(seconds: 3),
// // // //         icon: Icon(Icons.check_circle, color: Colors.white),
// // // //       );
// // // //     } catch (e) {
// // // //       debugPrint("❌ [CLOCK-IN] Error: $e");
// // // //
// // // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // // //
// // // //       Get.snackbar(
// // // //         'Error',
// // // //         'Failed to clock in: ${e.toString()}',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.red,
// // // //         colorText: Colors.white,
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ START LOCATION MONITORING
// // // //   void _startLocationMonitoring() {
// // // //     _wasLocationAvailable = true;
// // // //     _autoClockOutInProgress = false;
// // // //
// // // //     _locationMonitorTimer =
// // // //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// // // //           if (!attendanceViewModel.isClockedIn.value) {
// // // //             _stopLocationMonitoring();
// // // //             return;
// // // //           }
// // // //
// // // //           // ✅ CHECK LOCATION ON/OFF
// // // //           bool currentLocationAvailable = await attendanceViewModel
// // // //               .isLocationAvailable();
// // // //
// // // //           if (_wasLocationAvailable && !currentLocationAvailable) {
// // // //             debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
// // // //             await _handleFastLocationOffAutoClockOut();
// // // //             return;
// // // //           }
// // // //           _wasLocationAvailable = currentLocationAvailable;
// // // //
// // // //           // ✅ CHECK PERMISSION REVOKED
// // // //           bool currentPermissionGranted = await _checkPermissionStatus();
// // // //
// // // //           if (_wasPermissionGranted && !currentPermissionGranted) {
// // // //             debugPrint("🔐 [PERMISSION] Permission REVOKED - triggering auto clock-out");
// // // //             await _handlePermissionRevokedAutoClockOut();
// // // //           }
// // // //           _wasPermissionGranted = currentPermissionGranted;
// // // //         });
// // // //   }
// // // //
// // // //   // ✅ FAST LOCATION OFF AUTO CLOCK-OUT
// // // //   Future<void> _handleFastLocationOffAutoClockOut() async {
// // // //     if (_autoClockOutInProgress) return;
// // // //     _autoClockOutInProgress = true;
// // // //
// // // //     debugPrint("⚡ [LOCATION OFF] Fast auto clock-out triggered");
// // // //
// // // //     try {
// // // //       _stopLocationMonitoring();
// // // //       _localBackupTimer?.cancel();
// // // //
// // // //       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
// // // //       DateTime clockOutTime = DateTime.now();
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //
// // // //       await prefs.setBool('isClockedIn', false);
// // // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // // //       await prefs.setBool('clockOutPending', true);
// // // //       await prefs.setBool('hasFastClockOutData', true);
// // // //       await prefs.setString('fastClockOutReason', 'location_off_auto');
// // // //
// // // //       locationViewModel.isClockedIn.value = false;
// // // //       attendanceViewModel.isClockedIn.value = false;
// // // //
// // // //       _isRiveAnimationActive = false;
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // // //       }
// // // //
// // // //       _localElapsedTime = '00:00:00';
// // // //       _localClockInTime = null;
// // // //
// // // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // // //         clockOutTime: clockOutTime,
// // // //         totalDistance: finalDistance,
// // // //         isAuto: true,
// // // //         reason: 'location_off_auto',
// // // //       );
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       service.invoke("stopService");
// // // //
// // // //       try {
// // // //         await location.enableBackgroundMode(enable: false);
// // // //       } catch (e) {
// // // //         debugPrint("⚠️ Background mode disable error: $e");
// // // //       }
// // // //
// // // //       Get.snackbar(
// // // //         'Location Turned Off',
// // // //         'Auto clock-out completed. Data saved locally.',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.orange,
// // // //         colorText: Colors.white,
// // // //         duration: const Duration(seconds: 3),
// // // //         icon: Icon(Icons.location_off, color: Colors.white),
// // // //       );
// // // //
// // // //       debugPrint("✅ [LOCATION OFF] Fast auto clock-out completed");
// // // //
// // // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // // //     } catch (e) {
// // // //       debugPrint("❌ [LOCATION OFF] Fast auto clock-out error: $e");
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('isClockedIn', false);
// // // //       locationViewModel.isClockedIn.value = false;
// // // //       attendanceViewModel.isClockedIn.value = false;
// // // //     } finally {
// // // //       _autoClockOutInProgress = false;
// // // //     }
// // // //   }
// // // //
// // // //   // ✅ PERMISSION REVOKED AUTO CLOCK-OUT
// // // //   Future<void> _handlePermissionRevokedAutoClockOut() async {
// // // //     if (_autoClockOutInProgress) return;
// // // //     _autoClockOutInProgress = true;
// // // //
// // // //     debugPrint("⚡ [PERMISSION REVOKED] Auto clock-out triggered");
// // // //
// // // //     try {
// // // //       _stopLocationMonitoring();
// // // //       _localBackupTimer?.cancel();
// // // //
// // // //       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
// // // //       DateTime clockOutTime = DateTime.now();
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //
// // // //       await prefs.setBool('isClockedIn', false);
// // // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // // //       await prefs.setBool('clockOutPending', true);
// // // //       await prefs.setBool('hasFastClockOutData', true);
// // // //       await prefs.setString('fastClockOutReason', 'permission_revoked_auto');
// // // //
// // // //       locationViewModel.isClockedIn.value = false;
// // // //       attendanceViewModel.isClockedIn.value = false;
// // // //
// // // //       _isRiveAnimationActive = false;
// // // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // // //       }
// // // //
// // // //       _localElapsedTime = '00:00:00';
// // // //       _localClockInTime = null;
// // // //
// // // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // // //         clockOutTime: clockOutTime,
// // // //         totalDistance: finalDistance,
// // // //         isAuto: true,
// // // //         reason: 'permission_revoked_auto',
// // // //       );
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       service.invoke("stopService");
// // // //
// // // //       try {
// // // //         await location.enableBackgroundMode(enable: false);
// // // //       } catch (e) {
// // // //         debugPrint("⚠️ Background mode disable error: $e");
// // // //       }
// // // //
// // // //       Get.snackbar(
// // // //         'Permission Revoked',
// // // //         'Location permission removed. Auto clock-out completed.',
// // // //         snackPosition: SnackPosition.TOP,
// // // //         backgroundColor: Colors.red.shade700,
// // // //         colorText: Colors.white,
// // // //         duration: const Duration(seconds: 4),
// // // //         icon: Icon(Icons.security, color: Colors.white),
// // // //       );
// // // //
// // // //       debugPrint("✅ [PERMISSION REVOKED] Auto clock-out completed");
// // // //
// // // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // // //     } catch (e) {
// // // //       debugPrint("❌ [PERMISSION REVOKED] Auto clock-out error: $e");
// // // //
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('isClockedIn', false);
// // // //       locationViewModel.isClockedIn.value = false;
// // // //       attendanceViewModel.isClockedIn.value = false;
// // // //     } finally {
// // // //       _autoClockOutInProgress = false;
// // // //     }
// // // //   }
// // // //
// // // //   void _startBackgroundServices() async {
// // // //     try {
// // // //       debugPrint("🛰 [BACKGROUND] Starting services...");
// // // //
// // // //       final service = FlutterBackgroundService();
// // // //       await location.enableBackgroundMode(enable: true);
// // // //
// // // //       initializeServiceLocation().catchError((e) =>
// // // //           debugPrint("Service init error: $e"));
// // // //       service.startService().catchError((e) =>
// // // //           debugPrint("Service start error: $e"));
// // // //       location.changeSettings(
// // // //           interval: 300, accuracy: loc.LocationAccuracy.high)
// // // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // // //
// // // //       debugPrint("✅ [BACKGROUND] Services started");
// // // //     } catch (e) {
// // // //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// // // //     }
// // // //   }
// // // //
// // // //   void _stopLocationMonitoring() {
// // // //     _locationMonitorTimer?.cancel();
// // // //     _locationMonitorTimer = null;
// // // //     _autoClockOutInProgress = false;
// // // //   }
// // // //
// // // //   // ✅ CHECK LOCATION PERMISSION STATUS
// // // //   Future<bool> _checkPermissionStatus() async {
// // // //     LocationPermission permission = await Geolocator.checkPermission();
// // // //     return permission == LocationPermission.always ||
// // // //         permission == LocationPermission.whileInUse;
// // // //   }
// // // //
// // // //   // ✅ SCHEDULE HEAVY OPERATIONS TO RUN IN BACKGROUND
// // // //   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
// // // //     debugPrint("🔄 Scheduling background operations...");
// // // //
// // // //     // Run in background after 5 seconds
// // // //     Timer(Duration(seconds: 5), () async {
// // // //       try {
// // // //         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
// // // //
// // // //         // 1. GPX Consolidation
// // // //         await locationViewModel.consolidateDailyGPXData();
// // // //
// // // //         // 2. Update central point
// // // //         // await locationViewModel.updateTodayCentralPoint();
// // // //
// // // //         // 3. Save location from consolidated file
// // // //         await locationViewModel.saveLocationFromConsolidatedFile();
// // // //
// // // //         // 4. Update SharedPreferences with full data
// // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //
// // // //         // Save complete data for sync
// // // //         await prefs.setDouble('fullClockOutDistance', distance);
// // // //         await prefs.setString(
// // // //             'fullClockOutTime', clockOutTime.toIso8601String());
// // // //         await prefs.setDouble(
// // // //             'pendingLatOut', locationViewModel.globalLatitude1.value);
// // // //         await prefs.setDouble(
// // // //             'pendingLngOut', locationViewModel.globalLongitude1.value);
// // // //         await prefs.setString(
// // // //             'pendingAddress', locationViewModel.shopAddress.value);
// // // //
// // // //         debugPrint("✅ [BACKGROUND] Heavy operations completed");
// // // //
// // // //         // 5. Try auto-sync if online
// // // //         _triggerPostClockOutSync();
// // // //       } catch (e) {
// // // //         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
// // // //         // Data is already safe in fast save
// // // //       }
// // // //     });
// // // //   }
// // // //
// // // //   // ✅ POST CLOCK-OUT SYNC
// // // //   void _triggerPostClockOutSync() async {
// // // //     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
// // // //
// // // //     try {
// // // //       // Check if we're online
// // // //       var results = await _connectivity.checkConnectivity();
// // // //       bool isOnline = results.isNotEmpty &&
// // // //           results.any((result) => result != ConnectivityResult.none);
// // // //
// // // //       if (isOnline && !_isSyncing) {
// // // //         _isSyncing = true;
// // // //
// // // //         // Try to sync all data
// // // //         await updateFunctionViewModel.syncAllLocalDataToServer();
// // // //
// // // //         // Clear pending flag if sync successful
// // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //         await prefs.setBool('hasPendingClockOutData', false);
// // // //         await prefs.setBool('clockOutPending', false);
// // // //         await prefs.setBool('hasFastClockOutData', false);
// // // //
// // // //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// // // //
// // // //         // Show success notification (subtle)
// // // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //           Get.snackbar(
// // // //             'Sync Complete',
// // // //             'All data synchronized to server',
// // // //             snackPosition: SnackPosition.BOTTOM,
// // // //             backgroundColor: Colors.green,
// // // //             colorText: Colors.white,
// // // //             duration: const Duration(seconds: 2),
// // // //           );
// // // //         });
// // // //       } else {
// // // //         debugPrint(
// // // //             "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
// // // //
// // // //         // Data is already saved in SharedPreferences, so it's safe
// // // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //         await prefs.setBool('clockOutPending', true);
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
// // // //
// // // //       // Even on error, data is safe in SharedPreferences
// // // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //       await prefs.setBool('clockOutPending', true);
// // // //     } finally {
// // // //       _isSyncing = false;
// // // //     }
// // // //   }
// // // // }
// // //
// // //
// // // //notifivation
// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // import 'package:geolocator/geolocator.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // // import 'package:rive/rive.dart';
// // // import 'package:location/location.dart' as loc;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // // import '../../Databases/util.dart';
// // // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // // import '../../Tracker/location00.dart';
// // // import '../../Tracker/trac.dart';
// // // import '../../Utils/daily_work_time_manager.dart';
// // // import '../../main.dart';
// // // import 'assets.dart';
// // // import 'menu_item.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:intl/intl.dart';
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
// // //   final TravelTimeViewModel travelTimeViewModel = Get.put(
// // //       TravelTimeViewModel());
// // //
// // //   final loc.Location location = loc.Location();
// // //   final Connectivity _connectivity = Connectivity();
// // //   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// // //
// // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // //   Timer? _locationMonitorTimer;
// // //   bool _wasLocationAvailable = true;
// // //   bool _autoClockOutInProgress = false;
// // //
// // //   // New timers for auto clockout features
// // //   Timer? _midnightClockOutTimer;
// // //   Timer? _permissionCheckTimer;
// // //   bool _isMidnightClockOutScheduled = false;
// // //
// // //   bool _isRiveAnimationActive = false;
// // //   Timer? _localBackupTimer;
// // //   DateTime? _localClockInTime;
// // //   String _localElapsedTime = '00:00:00';
// // //
// // //   // Auto-sync variables
// // //   Timer? _autoSyncTimer;
// // //   bool _isOnline = false;
// // //   bool _isSyncing = false;
// // //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// // //
// // //   // Distance tracking
// // //   double _currentDistance = 0.0;
// // //   Timer? _distanceUpdateTimer;
// // //
// // //   // Permission monitoring
// // //   bool _wasPermissionGranted = true;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //
// // //     _initializeNotifications();
// // //     _initializeFromPersistentState();
// // //     _startAutoSyncMonitoring();
// // //     _startDistanceUpdater();
// // //     _scheduleMidnightClockOut(); // ✅ Schedule midnight auto clockout
// // //     _startPermissionMonitoring(); // ✅ Start monitoring permissions
// // //
// // //     // ✅ CHECK FOR PENDING DATA ON STARTUP
// // //     _checkAndSyncPendingData();
// // //   }
// // //
// // //   // ✅ INITIALIZE NOTIFICATIONS
// // //   Future<void> _initializeNotifications() async {
// // //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// // //
// // //     const AndroidInitializationSettings androidSettings =
// // //     AndroidInitializationSettings('@mipmap/ic_launcher');
// // //
// // //     const DarwinInitializationSettings iosSettings =
// // //     DarwinInitializationSettings();
// // //
// // //     const InitializationSettings initSettings = InitializationSettings(
// // //       android: androidSettings,
// // //       iOS: iosSettings,
// // //     );
// // //
// // //     await flutterLocalNotificationsPlugin.initialize(initSettings);
// // //
// // //     // Create notification channel for Android
// // //     const AndroidNotificationChannel channel = AndroidNotificationChannel(
// // //       'auto_clockout_channel',
// // //       'Auto Clockout Notifications',
// // //       description: 'Channel for auto clockout notifications',
// // //       importance: Importance.high,
// // //     );
// // //
// // //     await flutterLocalNotificationsPlugin
// // //         .resolvePlatformSpecificImplementation<
// // //         AndroidFlutterLocalNotificationsPlugin>()
// // //         ?.createNotificationChannel(channel);
// // //   }
// // //
// // //   // ✅ SHOW NOTIFICATION METHOD
// // //   Future<void> _showNotification({
// // //     required String title,
// // //     required String body,
// // //     String? payload,
// // //   }) async {
// // //     const AndroidNotificationDetails androidDetails =
// // //     AndroidNotificationDetails(
// // //       'auto_clockout_channel',
// // //       'Auto Clockout Notifications',
// // //       channelDescription: 'Channel for auto clockout notifications',
// // //       importance: Importance.high,
// // //       priority: Priority.high,
// // //       icon: '@mipmap/ic_launcher',
// // //     );
// // //
// // //     const DarwinNotificationDetails iosDetails =
// // //     DarwinNotificationDetails();
// // //
// // //     const NotificationDetails notificationDetails = NotificationDetails(
// // //       android: androidDetails,
// // //       iOS: iosDetails,
// // //     );
// // //
// // //     await flutterLocalNotificationsPlugin.show(
// // //       DateTime.now().millisecond,
// // //       title,
// // //       body,
// // //       notificationDetails,
// // //       payload: payload,
// // //     );
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
// // //     _midnightClockOutTimer?.cancel();
// // //     _permissionCheckTimer?.cancel();
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
// // //       _rescheduleMidnightClockOut(); // ✅ Reschedule on app resume
// // //       _checkAndSyncPendingData();
// // //     }
// // //   }
// // //
// // //   // ✅ SCHEDULE MIDNIGHT AUTO CLOCKOUT (11:58 PM)
// // //   void _scheduleMidnightClockOut() {
// // //     if (!attendanceViewModel.isClockedIn.value) {
// // //       return;
// // //     }
// // //
// // //     _midnightClockOutTimer?.cancel();
// // //
// // //     final now = DateTime.now();
// // //     final scheduledTime = DateTime(
// // //       now.year,
// // //       now.month,
// // //       now.day,
// // //       23, // 11 PM
// // //       58, // 58 minutes
// // //     );
// // //
// // //     // If current time is past 11:58 PM, schedule for next day
// // //     Duration timeUntilMidnight;
// // //     if (now.isAfter(scheduledTime)) {
// // //       final tomorrow = scheduledTime.add(const Duration(days: 1));
// // //       timeUntilMidnight = tomorrow.difference(now);
// // //     } else {
// // //       timeUntilMidnight = scheduledTime.difference(now);
// // //     }
// // //
// // //     _midnightClockOutTimer = Timer(timeUntilMidnight, () async {
// // //       if (attendanceViewModel.isClockedIn.value) {
// // //         debugPrint("⏰ [MIDNIGHT] Auto clockout triggered at 11:58 PM");
// // //
// // //         // Show notification
// // //         await _showNotification(
// // //           title: 'Auto Clockout',
// // //           body: 'You have been automatically clocked out at 11:58 PM',
// // //         );
// // //
// // //         await _handleAutoClockOut(
// // //           reason: 'midnight_auto',
// // //           context: context,
// // //         );
// // //       }
// // //     });
// // //
// // //     _isMidnightClockOutScheduled = true;
// // //     debugPrint("⏰ [MIDNIGHT] Auto clockout scheduled for ${scheduledTime.hour}:${scheduledTime.minute}");
// // //   }
// // //
// // //   // ✅ RESCHEDULE MIDNIGHT CLOCKOUT
// // //   void _rescheduleMidnightClockOut() {
// // //     if (attendanceViewModel.isClockedIn.value) {
// // //       _scheduleMidnightClockOut();
// // //     }
// // //   }
// // //
// // //   // ✅ START PERMISSION MONITORING
// // //   void _startPermissionMonitoring() {
// // //     _permissionCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
// // //       if (!attendanceViewModel.isClockedIn.value) {
// // //         return;
// // //       }
// // //
// // //       // Check location services
// // //       bool locationEnabled = await attendanceViewModel.isLocationAvailable();
// // //       if (_wasLocationAvailable && !locationEnabled) {
// // //         debugPrint("📍 [LOCATION] Location turned OFF - auto clockout");
// // //         await _showNotification(
// // //           title: 'Location Turned Off',
// // //           body: 'Auto clockout triggered because location was turned off',
// // //         );
// // //         await _handleAutoClockOut(
// // //           reason: 'location_off_auto',
// // //           context: context,
// // //         );
// // //       }
// // //       _wasLocationAvailable = locationEnabled;
// // //
// // //       // Check location permissions
// // //       bool permissionGranted = await _checkPermissionStatus();
// // //       if (_wasPermissionGranted && !permissionGranted) {
// // //         debugPrint("🔐 [PERMISSION] Location permission revoked - auto clockout");
// // //         await _showNotification(
// // //           title: 'Permission Revoked',
// // //           body: 'Auto clockout triggered because location permission was removed',
// // //         );
// // //         await _handleAutoClockOut(
// // //           reason: 'permission_revoked_auto',
// // //           context: context,
// // //         );
// // //       }
// // //       _wasPermissionGranted = permissionGranted;
// // //     });
// // //   }
// // //
// // //   // ✅ CHECK LOCATION PERMISSION STATUS
// // //   Future<bool> _checkPermissionStatus() async {
// // //     LocationPermission permission = await Geolocator.checkPermission();
// // //     return permission == LocationPermission.always ||
// // //         permission == LocationPermission.whileInUse;
// // //   }
// // //
// // //   // ✅ CHECK & REQUEST LOCATION PERMISSION
// // //   Future<bool> _checkLocationPermission(BuildContext context) async {
// // //     LocationPermission permission = await Geolocator.checkPermission();
// // //
// // //     if (permission == LocationPermission.denied) {
// // //       permission = await Geolocator.requestPermission();
// // //     }
// // //
// // //     if (permission == LocationPermission.denied ||
// // //         permission == LocationPermission.deniedForever) {
// // //       await showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (ctx) => Dialog(
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(20),
// // //           ),
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(20),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 const Icon(
// // //                   Icons.location_off,
// // //                   size: 50,
// // //                   color: Colors.redAccent,
// // //                 ),
// // //                 const SizedBox(height: 15),
// // //                 const Text(
// // //                   "Location Permission Required",
// // //                   style: TextStyle(
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //                 const Text(
// // //                   "We need location access to continue.\n"
// // //                       "Please enable location permission from app settings.",
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(color: Colors.grey),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //
// // //                 /// Buttons
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: TextButton(
// // //                         style: TextButton.styleFrom(
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(12),
// // //                           ),
// // //                         ),
// // //                         onPressed: () => Navigator.of(ctx).pop(),
// // //                         child: const Text(
// // //                           "Cancel",
// // //                           style: TextStyle(color: Colors.grey),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: ElevatedButton(
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.blueGrey,
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(12),
// // //                           ),
// // //                         ),
// // //                         onPressed: () async {
// // //                           Navigator.of(ctx).pop();
// // //                           await Geolocator.openAppSettings();
// // //                         },
// // //                         child: const Text(
// // //                           "Open Settings",
// // //                           style: TextStyle(color: Colors.white),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 )
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //       return false;
// // //     }
// // //
// // //     return true;
// // //   }
// // //
// // //   // ✅ HANDLE AUTO CLOCKOUT (Unified method)
// // //   Future<void> _handleAutoClockOut({
// // //     required String reason,
// // //     required BuildContext context,
// // //   }) async {
// // //     if (_autoClockOutInProgress || !attendanceViewModel.isClockedIn.value) {
// // //       return;
// // //     }
// // //     _autoClockOutInProgress = true;
// // //
// // //     debugPrint("⚡ [AUTO CLOCKOUT] Triggered for reason: $reason");
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //       _midnightClockOutTimer?.cancel();
// // //
// // //       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //       await prefs.setBool('isClockedIn', false);
// // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // //       await prefs.setBool('clockOutPending', true);
// // //       await prefs.setBool('hasFastClockOutData', true);
// // //       await prefs.setString('fastClockOutReason', reason);
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       // Save attendance out
// // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: true,
// // //         reason: reason,
// // //       );
// // //
// // //       // Record daily work time
// // //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// // //
// // //       // Stop background service
// // //       final service = FlutterBackgroundService();
// // //       service.invoke("stopService");
// // //
// // //       try {
// // //         await location.enableBackgroundMode(enable: false);
// // //       } catch (e) {
// // //         debugPrint("⚠️ Background mode disable error: $e");
// // //       }
// // //
// // //       // Show success notification
// // //       String reasonMessage = _getReasonMessage(reason);
// // //       await _showNotification(
// // //         title: '✅ Auto Clockout Complete',
// // //         body: reasonMessage,
// // //       );
// // //
// // //       debugPrint("✅ [AUTO CLOCKOUT] Completed for reason: $reason");
// // //
// // //       // Schedule background operations
// // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // //     } catch (e) {
// // //       debugPrint("❌ [AUTO CLOCKOUT] Error: $e");
// // //
// // //       // Force state cleanup on error
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   // ✅ GET REASON MESSAGE FOR NOTIFICATION
// // //   String _getReasonMessage(String reason) {
// // //     switch (reason) {
// // //       case 'midnight_auto':
// // //         return 'You have been automatically clocked out at 11:58 PM';
// // //       case 'location_off_auto':
// // //         return 'Auto clockout because location services were turned off';
// // //       case 'permission_revoked_auto':
// // //         return 'Auto clockout because location permission was removed';
// // //       default:
// // //         return 'Auto clockout completed successfully';
// // //     }
// // //   }
// // //
// // //   // ✅ CHECK FOR PENDING DATA
// // //   void _checkAndSyncPendingData() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// // //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// // //
// // //     if (hasPendingClockOut || clockOutPending) {
// // //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// // //       _triggerAutoSync();
// // //     }
// // //   }
// // //
// // //   // ✅ START DISTANCE UPDATER
// // //   void _startDistanceUpdater() {
// // //     _distanceUpdateTimer =
// // //         Timer.periodic(const Duration(seconds: 5), (timer) async {
// // //           if (attendanceViewModel.isClockedIn.value) {
// // //             await _updateCurrentDistance();
// // //           }
// // //         });
// // //   }
// // //
// // //   // ✅ UPDATE CURRENT DISTANCE
// // //   Future<void> _updateCurrentDistance() async {
// // //     try {
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double distance = locationService.getCurrentDistance();
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
// // //       return locationService.getCurrentDistance();
// // //     } catch (e) {
// // //       return 0.0;
// // //     }
// // //   }
// // //
// // //   // ✅ AUTO-SYNC MONITORING SYSTEM
// // //   void _startAutoSyncMonitoring() async {
// // //     // Listen to connectivity changes
// // //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
// // //         List<ConnectivityResult> results) {
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty &&
// // //           results.any((result) => result != ConnectivityResult.none);
// // //
// // //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline
// // //           ? 'ONLINE'
// // //           : 'OFFLINE'} | Was: ${wasOnline
// // //           ? 'ONLINE'
// // //           : 'OFFLINE'} | Syncing: $_isSyncing");
// // //
// // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// // //         _triggerAutoSync();
// // //       }
// // //     });
// // //
// // //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// // //       if (!_isSyncing) {
// // //         _checkConnectivityAndSync();
// // //       }
// // //     });
// // //
// // //     _checkConnectivityAndSync();
// // //   }
// // //
// // //   // ✅ CHECK CONNECTIVITY AND SYNC
// // //   void _checkConnectivityAndSync() async {
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     try {
// // //       var results = await _connectivity.checkConnectivity();
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty &&
// // //           results.any((result) => result != ConnectivityResult.none);
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
// // //   // ✅ TRIGGER AUTO-SYNC
// // //   void _triggerAutoSync() async {
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     _isSyncing = true;
// // //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// // //
// // //     try {
// // //       Get.snackbar(
// // //         'Syncing Data',
// // //         'Auto-syncing offline data...',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.blue.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //
// // //       await updateFunctionViewModel.syncAllLocalDataToServer();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('hasPendingClockOutData', false);
// // //       await prefs.setBool('clockOutPending', false);
// // //       await prefs.setBool('hasFastClockOutData', false);
// // //
// // //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// // //     } catch (e) {
// // //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// // //     } finally {
// // //       _isSyncing = false;
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
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //       _scheduleMidnightClockOut(); // ✅ Reschedule midnight clockout
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
// // //       _scheduleMidnightClockOut(); // ✅ Schedule midnight clockout
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
// // //     if (_themeMenuIcon.isEmpty) return;
// // //
// // //     final controller = StateMachineController.fromArtboard(
// // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // //     if (controller != null) {
// // //       artboard.addController(controller);
// // //       _themeMenuIcon[0].riveIcon.status =
// // //       controller.findInput<bool>("active") as SMIBool?;
// // //
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// // //         debugPrint(
// // //             "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// // //       }
// // //     } else {
// // //       debugPrint("StateMachineController not found!");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Center(
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           crossAxisAlignment: CrossAxisAlignment.center,
// // //           children: [
// // //             // Timer + Distance
// // //             Column(
// // //               crossAxisAlignment: CrossAxisAlignment.center,
// // //               children: [
// // //                 Obx(() {
// // //                   String displayTime = _localElapsedTime;
// // //                   if (displayTime == '00:00:00' &&
// // //                       attendanceViewModel.isClockedIn.value) {
// // //                     displayTime = attendanceViewModel.elapsedTime.value;
// // //                   }
// // //
// // //                   return Text(
// // //                     displayTime,
// // //                     style: TextStyle(
// // //                       fontSize: 20,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: attendanceViewModel.isClockedIn.value
// // //                           ? Colors.black87
// // //                           : Colors.grey,
// // //                     ),
// // //                   );
// // //                 }),
// // //
// // //                 Obx(() {
// // //                   if (attendanceViewModel.isClockedIn.value &&
// // //                       _currentDistance > 0) {
// // //                     return Text(
// // //                       '${_currentDistance.toStringAsFixed(2)} km',
// // //                       style: TextStyle(
// // //                         fontSize: 14,
// // //                         color: Colors.blue.shade700,
// // //                         fontWeight: FontWeight.w500,
// // //                       ),
// // //                     );
// // //                   }
// // //                   return const SizedBox.shrink();
// // //                 }),
// // //               ],
// // //             ),
// // //
// // //             const SizedBox(height: 5),
// // //
// // //             // Buttons
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Obx(() {
// // //                   return SizedBox(
// // //                       width: 120,
// // //                       height: 30,
// // //                       child:  ElevatedButton(
// // //                         onPressed: attendanceViewModel.isClockedIn.value
// // //                             ? null
// // //                             : () async => _handleClockIn(context),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.blueGrey,
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                         ),
// // //                         child: const Row(
// // //                           mainAxisSize: MainAxisSize.min,
// // //                           children: [
// // //                             Text("Clock In", style: TextStyle(
// // //                               color: Colors.white,
// // //                               fontSize: 15,
// // //                               fontWeight: FontWeight.w600,
// // //                               letterSpacing: 0.5,
// // //                             ))
// // //                           ],
// // //                         ),
// // //                       )
// // //                   );
// // //                 }),
// // //
// // //                 const SizedBox(width: 5),
// // //
// // //                 Obx(() { return SizedBox(
// // //                     width: 120,
// // //                     height: 30,
// // //                     child:  ElevatedButton(
// // //                       onPressed: attendanceViewModel.isClockedIn.value
// // //                           ? () async => _handleClockOut(context)
// // //                           : null,
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.redAccent,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(8),
// // //                         ),
// // //                       ),
// // //                       child: const Row(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           Text("Clock Out", style: TextStyle(
// // //                             color: Colors.white,
// // //                             fontSize: 15,
// // //                             fontWeight: FontWeight.w600,
// // //                             letterSpacing: 0.5,
// // //                           ))
// // //                         ],
// // //                       ),
// // //                     )
// // //                 );
// // //                 }),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ ULTRA-FAST CLOCK-OUT METHOD
// // //   Future<void> _handleClockOut(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
// // //
// // //     // Show loading dialog
// // //     bool showLoadingDialog = true;
// // //     DateTime startTime = DateTime.now();
// // //     Timer? loadingTimer;
// // //
// // //     if (showLoadingDialog) {
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (_) =>
// // //             AlertDialog(
// // //               backgroundColor: Colors.white.withOpacity(0.9),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(15),
// // //               ),
// // //               content: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   CircularProgressIndicator(
// // //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
// // //                   ),
// // //                   SizedBox(height: 15),
// // //                   Text(
// // //                     "Processing clock-out...",
// // //                     style: TextStyle(
// // //                       fontWeight: FontWeight.w500,
// // //                       color: Colors.black87,
// // //                     ),
// // //                   ),
// // //                   SizedBox(height: 5),
// // //                   Text(
// // //                     "Please wait 3 seconds",
// // //                     style: TextStyle(
// // //                       fontSize: 12,
// // //                       color: Colors.grey,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //       );
// // //
// // //       loadingTimer = Timer(Duration(seconds: 3), () {});
// // //     }
// // //
// // //     try {
// // //       // Immediate state update
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //       _midnightClockOutTimer?.cancel();
// // //
// // //       double finalDistance = _currentDistance;
// // //       if (finalDistance <= 0) {
// // //         try {
// // //           LocationService locationService = LocationService();
// // //           await locationService.init();
// // //           finalDistance = locationService.getCurrentDistance();
// // //           if (finalDistance <= 0) finalDistance = 0.0;
// // //         } catch (e) {
// // //           finalDistance = 0.0;
// // //         }
// // //       }
// // //
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // //       await prefs.setBool('clockOutPending', true);
// // //       await prefs.setBool('hasFastClockOutData', true);
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //       _isRiveAnimationActive = false;
// // //
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: false,
// // //         reason: 'manual_clockout',
// // //       );
// // //
// // //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// // //
// // //       final service = FlutterBackgroundService();
// // //       service.invoke("stopService");
// // //
// // //       try {
// // //         await location.enableBackgroundMode(enable: false);
// // //       } catch (e) {
// // //         debugPrint("⚠️ Background mode disable error: $e");
// // //       }
// // //
// // //       DateTime endTime = DateTime.now();
// // //       Duration elapsedTime = endTime.difference(startTime);
// // //
// // //       if (elapsedTime.inSeconds < 3) {
// // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // //       }
// // //
// // //       if (loadingTimer != null) loadingTimer.cancel();
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         '✅ Clock Out Complete',
// // //         'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: Duration(seconds: 2),
// // //       );
// // //
// // //       debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");
// // //
// // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // //     } catch (e) {
// // //       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
// // //
// // //       DateTime endTime = DateTime.now();
// // //       Duration elapsedTime = endTime.difference(startTime);
// // //
// // //       if (elapsedTime.inSeconds < 3) {
// // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // //       }
// // //
// // //       if (loadingTimer != null) loadingTimer.cancel();
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Clock Out Complete',
// // //         'Data saved locally',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.orange,
// // //         colorText: Colors.white,
// // //         duration: Duration(seconds: 2),
// // //       );
// // //     }
// // //   }
// // //
// // //   // ✅ CLOCK-IN METHOD
// // //   Future<void> _handleClockIn(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// // //
// // //     // Location check
// // //     bool hasPermission = await _checkLocationPermission(context);
// // //     if (!hasPermission) {
// // //       debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
// // //       return;
// // //     }
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
// // //       builder: (_) =>
// // //           AlertDialog(
// // //             backgroundColor: Colors.white,
// // //             content: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 CircularProgressIndicator(color: Colors.green),
// // //                 SizedBox(height: 15),
// // //                 Text('Checking permissions...',
// // //                     style: TextStyle(fontWeight: FontWeight.w500)),
// // //               ],
// // //             ),
// // //           ),
// // //     );
// // //
// // //     try {
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       await locationService.listenLocation();
// // //
// // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //       final downloadDirectory = await getDownloadsDirectory();
// // //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// // //       File file = File(filePath);
// // //
// // //       if (!file.existsSync()) {
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
// // //       double initialDistance = locationService.getCurrentDistance();
// // //       if (initialDistance > 0.001) {
// // //         locationService.resetDistance();
// // //         initialDistance = 0.0;
// // //       }
// // //
// // //       await attendanceViewModel.saveFormAttendanceIn();
// // //       _startBackgroundServices();
// // //
// // //       locationViewModel.isClockedIn.value = true;
// // //       attendanceViewModel.isClockedIn.value = true;
// // //
// // //       await prefs.setBool('isClockedIn', true);
// // //       await prefs.setString('currentGpxFilePath', filePath);
// // //       await prefs.setString(
// // //           'currentSessionStart', DateTime.now().toIso8601String());
// // //
// // //       _isRiveAnimationActive = true;
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //       _startLocationMonitoring();
// // //       _scheduleMidnightClockOut(); // ✅ Schedule midnight clockout
// // //
// // //       travelTimeViewModel.startTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// // //
// // //       await _updateCurrentDistance();
// // //       await DailyWorkTimeManager.recordClockIn(DateTime.now());
// // //
// // //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// // //
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         '✅ Clocked In Successfully',
// // //         'GPS tracking started',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //         icon: Icon(Icons.check_circle, color: Colors.white),
// // //       );
// // //     } catch (e) {
// // //       debugPrint("❌ [CLOCK-IN] Error: $e");
// // //
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Error',
// // //         'Failed to clock in: ${e.toString()}',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.red,
// // //         colorText: Colors.white,
// // //       );
// // //     }
// // //   }
// // //
// // //   // ✅ START LOCATION MONITORING
// // //   void _startLocationMonitoring() {
// // //     _wasLocationAvailable = true;
// // //     _autoClockOutInProgress = false;
// // //
// // //     _locationMonitorTimer =
// // //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// // //           if (!attendanceViewModel.isClockedIn.value) {
// // //             _stopLocationMonitoring();
// // //             return;
// // //           }
// // //
// // //           // ✅ CHECK LOCATION ON/OFF
// // //           bool currentLocationAvailable = await attendanceViewModel
// // //               .isLocationAvailable();
// // //
// // //           if (_wasLocationAvailable && !currentLocationAvailable) {
// // //             debugPrint("📍 [LOCATION] Location OFF - triggering auto clock-out");
// // //             await _showNotification(
// // //               title: 'Location Turned Off',
// // //               body: 'Auto clockout triggered because location was turned off',
// // //             );
// // //             await _handleAutoClockOut(
// // //               reason: 'location_off_auto',
// // //               context: context,
// // //             );
// // //             return;
// // //           }
// // //           _wasLocationAvailable = currentLocationAvailable;
// // //
// // //           // ✅ CHECK PERMISSION REVOKED
// // //           bool currentPermissionGranted = await _checkPermissionStatus();
// // //
// // //           if (_wasPermissionGranted && !currentPermissionGranted) {
// // //             debugPrint("🔐 [PERMISSION] Permission REVOKED - triggering auto clock-out");
// // //             await _showNotification(
// // //               title: 'Permission Revoked',
// // //               body: 'Auto clockout triggered because location permission was removed',
// // //             );
// // //             await _handleAutoClockOut(
// // //               reason: 'permission_revoked_auto',
// // //               context: context,
// // //             );
// // //           }
// // //           _wasPermissionGranted = currentPermissionGranted;
// // //         });
// // //   }
// // //
// // //   void _startBackgroundServices() async {
// // //     try {
// // //       debugPrint("🛰 [BACKGROUND] Starting services...");
// // //
// // //       final service = FlutterBackgroundService();
// // //       await location.enableBackgroundMode(enable: true);
// // //
// // //       initializeServiceLocation().catchError((e) =>
// // //           debugPrint("Service init error: $e"));
// // //       service.startService().catchError((e) =>
// // //           debugPrint("Service start error: $e"));
// // //       location.changeSettings(
// // //           interval: 300, accuracy: loc.LocationAccuracy.high)
// // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // //
// // //       debugPrint("✅ [BACKGROUND] Services started");
// // //     } catch (e) {
// // //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// // //     }
// // //   }
// // //
// // //   void _stopLocationMonitoring() {
// // //     _locationMonitorTimer?.cancel();
// // //     _locationMonitorTimer = null;
// // //     _autoClockOutInProgress = false;
// // //   }
// // //
// // //   // ✅ SCHEDULE HEAVY OPERATIONS TO RUN IN BACKGROUND
// // //   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
// // //     debugPrint("🔄 Scheduling background operations...");
// // //
// // //     // Run in background after 5 seconds
// // //     Timer(Duration(seconds: 5), () async {
// // //       try {
// // //         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
// // //
// // //         // 1. GPX Consolidation
// // //         await locationViewModel.consolidateDailyGPXData();
// // //
// // //         // 2. Save location from consolidated file
// // //         await locationViewModel.saveLocationFromConsolidatedFile();
// // //
// // //         // 3. Update SharedPreferences with full data
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //         // Save complete data for sync
// // //         await prefs.setDouble('fullClockOutDistance', distance);
// // //         await prefs.setString(
// // //             'fullClockOutTime', clockOutTime.toIso8601String());
// // //         await prefs.setDouble(
// // //             'pendingLatOut', locationViewModel.globalLatitude1.value);
// // //         await prefs.setDouble(
// // //             'pendingLngOut', locationViewModel.globalLongitude1.value);
// // //         await prefs.setString(
// // //             'pendingAddress', locationViewModel.shopAddress.value);
// // //
// // //         debugPrint("✅ [BACKGROUND] Heavy operations completed");
// // //
// // //         // 4. Try auto-sync if online
// // //         _triggerPostClockOutSync();
// // //       } catch (e) {
// // //         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
// // //         // Data is already safe in fast save
// // //       }
// // //     });
// // //   }
// // //
// // //   // ✅ POST CLOCK-OUT SYNC
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
// // //         await prefs.setBool('hasFastClockOutData', false);
// // //
// // //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// // //
// // //         // Show success notification (subtle)
// // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // //           Get.snackbar(
// // //             'Sync Complete',
// // //             'All data synchronized to server',
// // //             snackPosition: SnackPosition.BOTTOM,
// // //             backgroundColor: Colors.green,
// // //             colorText: Colors.white,
// // //             duration: const Duration(seconds: 2),
// // //           );
// // //         });
// // //       } else {
// // //         debugPrint(
// // //             "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
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
// // // }
// // //
// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_background_service/flutter_background_service.dart';
// // // import 'package:geolocator/geolocator.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// // // import 'package:rive/rive.dart';
// // // import 'package:location/location.dart' as loc;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // // import '../../Databases/util.dart';
// // // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // // import '../../Tracker/location00.dart';
// // // import '../../Tracker/trac.dart';
// // // import '../../Utils/daily_work_time_manager.dart';
// // // import '../../main.dart';
// // // import 'assets.dart';
// // // import 'menu_item.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:intl/intl.dart';
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
// // //   final TravelTimeViewModel travelTimeViewModel = Get.put(
// // //       TravelTimeViewModel());
// // //
// // //   final loc.Location location = loc.Location();
// // //   final Connectivity _connectivity = Connectivity();
// // //   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// // //
// // //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// // //   Timer? _locationMonitorTimer;
// // //   bool _wasLocationAvailable = true;
// // //   bool _autoClockOutInProgress = false;
// // //
// // //   // New timers for auto clockout features
// // //   Timer? _midnightClockOutTimer;
// // //   Timer? _permissionCheckTimer;
// // //   bool _isMidnightClockOutScheduled = false;
// // //
// // //   bool _isRiveAnimationActive = false;
// // //   Timer? _localBackupTimer;
// // //   DateTime? _localClockInTime;
// // //   String _localElapsedTime = '00:00:00';
// // //
// // //   // Auto-sync variables
// // //   Timer? _autoSyncTimer;
// // //   bool _isOnline = false;
// // //   bool _isSyncing = false;
// // //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// // //
// // //   // Distance tracking
// // //   double _currentDistance = 0.0;
// // //   Timer? _distanceUpdateTimer;
// // //
// // //   // Permission monitoring
// // //   bool _wasPermissionGranted = true;
// // //
// // //   // Notification IDs
// // //   int _notificationId = 0;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //
// // //     _initializeUrgentNotifications(); // ✅ URGENT notification setup
// // //     _initializeFromPersistentState();
// // //     _startAutoSyncMonitoring();
// // //     _startDistanceUpdater();
// // //     _scheduleMidnightClockOut(); // ✅ Schedule midnight auto clockout
// // //     _startPermissionMonitoring(); // ✅ Start monitoring permissions
// // //
// // //     // ✅ CHECK FOR PENDING DATA ON STARTUP
// // //     _checkAndSyncPendingData();
// // //   }
// // //
// // //   // ✅ URGENT NOTIFICATION SETUP (IMMEDIATE)
// // //   Future<void> _initializeUrgentNotifications() async {
// // //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// // //
// // //     // Android high-priority channel for URGENT notifications
// // //     const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
// // //       'urgent_auto_clockout_channel',
// // //       'URGENT Auto Clockout Notifications',
// // //       description: 'High-priority channel for urgent auto clockout notifications',
// // //       importance: Importance.max, // MAX importance for immediate display
// // //       // priority: Priority.high, // HIGH priority
// // //       enableVibration: true,
// // //       playSound: true,
// // //       sound: RawResourceAndroidNotificationSound('notification_sound'), // Add custom sound if needed
// // //       enableLights: true,
// // //       ledColor: Colors.red,
// // //     );
// // //
// // //     // Android settings for URGENT notifications
// // //     const AndroidInitializationSettings androidSettings =
// // //     AndroidInitializationSettings('@mipmap/ic_launcher');
// // //
// // //     const DarwinInitializationSettings iosSettings =
// // //     DarwinInitializationSettings(
// // //       requestAlertPermission: true,
// // //       requestBadgePermission: true,
// // //       requestSoundPermission: true,
// // //     );
// // //
// // //     const InitializationSettings initSettings = InitializationSettings(
// // //       android: androidSettings,
// // //       iOS: iosSettings,
// // //     );
// // //
// // //     await flutterLocalNotificationsPlugin.initialize(
// // //       initSettings,
// // //       onDidReceiveNotificationResponse: (NotificationResponse response) async {
// // //         // Handle notification tap if needed
// // //         debugPrint('Notification tapped: ${response.payload}');
// // //       },
// // //     );
// // //
// // //     // Create URGENT notification channel for Android
// // //     await flutterLocalNotificationsPlugin
// // //         .resolvePlatformSpecificImplementation<
// // //         AndroidFlutterLocalNotificationsPlugin>()
// // //         ?.createNotificationChannel(urgentChannel);
// // //   }
// // //
// // //   // ✅ SHOW URGENT NOTIFICATION METHOD (IMMEDIATE)
// // //   Future<void> _showUrgentNotification({
// // //     required String title,
// // //     required String body,
// // //     String? payload,
// // //   }) async {
// // //     _notificationId++;
// // //
// // //     // Android URGENT notification details
// // //     const AndroidNotificationDetails androidDetails =
// // //     AndroidNotificationDetails(
// // //       'urgent_auto_clockout_channel',
// // //       'URGENT Auto Clockout Notifications',
// // //       channelDescription: 'High-priority channel for urgent auto clockout notifications',
// // //       importance: Importance.max, // MAX importance
// // //       priority: Priority.high, // HIGH priority
// // //       enableVibration: true,
// // //       playSound: true,
// // //       timeoutAfter: 5000, // Show for 5 seconds
// // //       category: AndroidNotificationCategory.alarm,
// // //       visibility: NotificationVisibility.public,
// // //       color: Colors.red,
// // //       ledColor: Colors.red,
// // //       ledOnMs: 1000,
// // //       ledOffMs: 500,
// // //       fullScreenIntent: true, // This will show even if device is locked
// // //       ongoing: false,
// // //       autoCancel: true,
// // //       styleInformation: BigTextStyleInformation(''),
// // //     );
// // //
// // //     // iOS URGENT notification details
// // //     const DarwinNotificationDetails iosDetails =
// // //     DarwinNotificationDetails(
// // //       presentAlert: true,
// // //       presentBadge: true,
// // //       presentSound: true,
// // //       sound: 'default',
// // //       interruptionLevel: InterruptionLevel.timeSensitive,
// // //     );
// // //
// // //     const NotificationDetails notificationDetails = NotificationDetails(
// // //       android: androidDetails,
// // //       iOS: iosDetails,
// // //     );
// // //
// // //     // Show notification immediately
// // //     await flutterLocalNotificationsPlugin.show(
// // //       _notificationId,
// // //       title,
// // //       body,
// // //       notificationDetails,
// // //       payload: payload,
// // //     );
// // //
// // //     debugPrint("🔔 [URGENT NOTIFICATION] Sent: $title");
// // //
// // //     // Also show GetX snackbar for immediate visual feedback in app
// // //     if (mounted) {
// // //       Get.snackbar(
// // //         title,
// // //         body,
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.red.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 5),
// // //         icon: const Icon(Icons.warning, color: Colors.white),
// // //         shouldIconPulse: true,
// // //         barBlur: 10,
// // //         isDismissible: true,
// // //       );
// // //     }
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
// // //     _midnightClockOutTimer?.cancel();
// // //     _permissionCheckTimer?.cancel();
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
// // //       _rescheduleMidnightClockOut(); // ✅ Reschedule on app resume
// // //       _checkAndSyncPendingData();
// // //     }
// // //   }
// // //
// // //   // ✅ SCHEDULE MIDNIGHT AUTO CLOCKOUT (11:58 PM)
// // //   void _scheduleMidnightClockOut() {
// // //     if (!attendanceViewModel.isClockedIn.value) {
// // //       return;
// // //     }
// // //
// // //     _midnightClockOutTimer?.cancel();
// // //
// // //     final now = DateTime.now();
// // //     final scheduledTime = DateTime(
// // //       now.year,
// // //       now.month,
// // //       now.day,
// // //       23, // 11 PM
// // //       58, // 58 minutes
// // //     );
// // //
// // //     // If current time is past 11:58 PM, schedule for next day
// // //     Duration timeUntilMidnight;
// // //     if (now.isAfter(scheduledTime)) {
// // //       final tomorrow = scheduledTime.add(const Duration(days: 1));
// // //       timeUntilMidnight = tomorrow.difference(now);
// // //     } else {
// // //       timeUntilMidnight = scheduledTime.difference(now);
// // //     }
// // //
// // //     _midnightClockOutTimer = Timer(timeUntilMidnight, () async {
// // //       if (attendanceViewModel.isClockedIn.value) {
// // //         debugPrint("⏰ [MIDNIGHT] Auto clockout triggered at 11:58 PM");
// // //
// // //         // Show URGENT notification immediately
// // //         await _showUrgentNotification(
// // //           title: '⚠️ AUTO CLOCKOUT - 11:58 PM',
// // //           body: 'You have been automatically clocked out at 11:58 PM',
// // //           payload: 'midnight_auto',
// // //         );
// // //
// // //         await _handleAutoClockOut(
// // //           reason: 'midnight_auto',
// // //           context: context,
// // //         );
// // //       }
// // //     });
// // //
// // //     _isMidnightClockOutScheduled = true;
// // //     debugPrint("⏰ [MIDNIGHT] Auto clockout scheduled for ${scheduledTime.hour}:${scheduledTime.minute}");
// // //   }
// // //
// // //   // ✅ RESCHEDULE MIDNIGHT CLOCKOUT
// // //   void _rescheduleMidnightClockOut() {
// // //     if (attendanceViewModel.isClockedIn.value) {
// // //       _scheduleMidnightClockOut();
// // //     }
// // //   }
// // //
// // //   // ✅ START PERMISSION MONITORING (FASTER CHECK)
// // //   void _startPermissionMonitoring() {
// // //     // Check every 2 seconds for URGENT detection
// // //     _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
// // //       if (!attendanceViewModel.isClockedIn.value) {
// // //         return;
// // //       }
// // //
// // //       // Check location services (immediate check)
// // //       bool locationEnabled = await attendanceViewModel.isLocationAvailable();
// // //       if (_wasLocationAvailable && !locationEnabled) {
// // //         debugPrint("📍 [LOCATION] Location turned OFF - URGENT auto clockout");
// // //
// // //         // Show URGENT notification immediately
// // //         await _showUrgentNotification(
// // //           title: '⚠️ LOCATION TURNED OFF',
// // //           body: 'Auto clockout triggered immediately because location was turned off',
// // //           payload: 'location_off_auto',
// // //         );
// // //
// // //         await _handleAutoClockOut(
// // //           reason: 'location_off_auto',
// // //           context: context,
// // //         );
// // //         return; // Stop further checks
// // //       }
// // //       _wasLocationAvailable = locationEnabled;
// // //
// // //       // Check location permissions (immediate check)
// // //       bool permissionGranted = await _checkPermissionStatus();
// // //       if (_wasPermissionGranted && !permissionGranted) {
// // //         debugPrint("🔐 [PERMISSION] Location permission revoked - URGENT auto clockout");
// // //
// // //         // Show URGENT notification immediately
// // //         await _showUrgentNotification(
// // //           title: '⚠️ PERMISSION REVOKED',
// // //           body: 'Auto clockout triggered immediately because location permission was removed',
// // //           payload: 'permission_revoked_auto',
// // //         );
// // //
// // //         await _handleAutoClockOut(
// // //           reason: 'permission_revoked_auto',
// // //           context: context,
// // //         );
// // //         return; // Stop further checks
// // //       }
// // //       _wasPermissionGranted = permissionGranted;
// // //     });
// // //   }
// // //
// // //   // ✅ CHECK LOCATION PERMISSION STATUS
// // //   Future<bool> _checkPermissionStatus() async {
// // //     LocationPermission permission = await Geolocator.checkPermission();
// // //     return permission == LocationPermission.always ||
// // //         permission == LocationPermission.whileInUse;
// // //   }
// // //
// // //   // ✅ CHECK & REQUEST LOCATION PERMISSION
// // //   Future<bool> _checkLocationPermission(BuildContext context) async {
// // //     LocationPermission permission = await Geolocator.checkPermission();
// // //
// // //     if (permission == LocationPermission.denied) {
// // //       permission = await Geolocator.requestPermission();
// // //     }
// // //
// // //     if (permission == LocationPermission.denied ||
// // //         permission == LocationPermission.deniedForever) {
// // //       await showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (ctx) => Dialog(
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(20),
// // //           ),
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(20),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 const Icon(
// // //                   Icons.location_off,
// // //                   size: 50,
// // //                   color: Colors.redAccent,
// // //                 ),
// // //                 const SizedBox(height: 15),
// // //                 const Text(
// // //                   "Location Permission Required",
// // //                   style: TextStyle(
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //                 const Text(
// // //                   "We need location access to continue.\n"
// // //                       "Please enable location permission from app settings.",
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(color: Colors.grey),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //
// // //                 /// Buttons
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: TextButton(
// // //                         style: TextButton.styleFrom(
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(12),
// // //                           ),
// // //                         ),
// // //                         onPressed: () => Navigator.of(ctx).pop(),
// // //                         child: const Text(
// // //                           "Cancel",
// // //                           style: TextStyle(color: Colors.grey),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: ElevatedButton(
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.blueGrey,
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(12),
// // //                           ),
// // //                         ),
// // //                         onPressed: () async {
// // //                           Navigator.of(ctx).pop();
// // //                           await Geolocator.openAppSettings();
// // //                         },
// // //                         child: const Text(
// // //                           "Open Settings",
// // //                           style: TextStyle(color: Colors.white),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 )
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //       return false;
// // //     }
// // //
// // //     return true;
// // //   }
// // //
// // //   // ✅ HANDLE AUTO CLOCKOUT (Unified method)
// // //   Future<void> _handleAutoClockOut({
// // //     required String reason,
// // //     required BuildContext context,
// // //   }) async {
// // //     if (_autoClockOutInProgress || !attendanceViewModel.isClockedIn.value) {
// // //       return;
// // //     }
// // //     _autoClockOutInProgress = true;
// // //
// // //     debugPrint("⚡ [AUTO CLOCKOUT] Triggered for reason: $reason");
// // //
// // //     try {
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //       _midnightClockOutTimer?.cancel();
// // //
// // //       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //       await prefs.setBool('isClockedIn', false);
// // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // //       await prefs.setBool('clockOutPending', true);
// // //       await prefs.setBool('hasFastClockOutData', true);
// // //       await prefs.setString('fastClockOutReason', reason);
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //
// // //       _isRiveAnimationActive = false;
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       // Save attendance out
// // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: true,
// // //         reason: reason,
// // //       );
// // //
// // //       // Record daily work time
// // //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// // //
// // //       // Stop background service
// // //       final service = FlutterBackgroundService();
// // //       service.invoke("stopService");
// // //
// // //       try {
// // //         await location.enableBackgroundMode(enable: false);
// // //       } catch (e) {
// // //         debugPrint("⚠️ Background mode disable error: $e");
// // //       }
// // //
// // //       // Show success notification (but less urgent than the trigger notification)
// // //       String reasonMessage = _getReasonMessage(reason);
// // //
// // //       debugPrint("✅ [AUTO CLOCKOUT] Completed for reason: $reason");
// // //
// // //       // Schedule background operations
// // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // //     } catch (e) {
// // //       debugPrint("❌ [AUTO CLOCKOUT] Error: $e");
// // //
// // //       // Force state cleanup on error
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //     } finally {
// // //       _autoClockOutInProgress = false;
// // //     }
// // //   }
// // //
// // //   // ✅ GET REASON MESSAGE FOR NOTIFICATION
// // //   String _getReasonMessage(String reason) {
// // //     switch (reason) {
// // //       case 'midnight_auto':
// // //         return 'You have been automatically clocked out at 11:58 PM';
// // //       case 'location_off_auto':
// // //         return 'Auto clockout because location services were turned off';
// // //       case 'permission_revoked_auto':
// // //         return 'Auto clockout because location permission was removed';
// // //       default:
// // //         return 'Auto clockout completed successfully';
// // //     }
// // //   }
// // //
// // //   // ✅ CHECK FOR PENDING DATA
// // //   void _checkAndSyncPendingData() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// // //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// // //
// // //     if (hasPendingClockOut || clockOutPending) {
// // //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// // //       _triggerAutoSync();
// // //     }
// // //   }
// // //
// // //   // ✅ START DISTANCE UPDATER
// // //   void _startDistanceUpdater() {
// // //     _distanceUpdateTimer =
// // //         Timer.periodic(const Duration(seconds: 5), (timer) async {
// // //           if (attendanceViewModel.isClockedIn.value) {
// // //             await _updateCurrentDistance();
// // //           }
// // //         });
// // //   }
// // //
// // //   // ✅ UPDATE CURRENT DISTANCE
// // //   Future<void> _updateCurrentDistance() async {
// // //     try {
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       double distance = locationService.getCurrentDistance();
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
// // //       return locationService.getCurrentDistance();
// // //     } catch (e) {
// // //       return 0.0;
// // //     }
// // //   }
// // //
// // //   // ✅ AUTO-SYNC MONITORING SYSTEM
// // //   void _startAutoSyncMonitoring() async {
// // //     // Listen to connectivity changes
// // //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
// // //         List<ConnectivityResult> results) {
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty &&
// // //           results.any((result) => result != ConnectivityResult.none);
// // //
// // //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline
// // //           ? 'ONLINE'
// // //           : 'OFFLINE'} | Was: ${wasOnline
// // //           ? 'ONLINE'
// // //           : 'OFFLINE'} | Syncing: $_isSyncing");
// // //
// // //       if (_isOnline && !wasOnline && !_isSyncing) {
// // //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// // //         _triggerAutoSync();
// // //       }
// // //     });
// // //
// // //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// // //       if (!_isSyncing) {
// // //         _checkConnectivityAndSync();
// // //       }
// // //     });
// // //
// // //     _checkConnectivityAndSync();
// // //   }
// // //
// // //   // ✅ CHECK CONNECTIVITY AND SYNC
// // //   void _checkConnectivityAndSync() async {
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     try {
// // //       var results = await _connectivity.checkConnectivity();
// // //       bool wasOnline = _isOnline;
// // //       _isOnline = results.isNotEmpty &&
// // //           results.any((result) => result != ConnectivityResult.none);
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
// // //   // ✅ TRIGGER AUTO-SYNC
// // //   void _triggerAutoSync() async {
// // //     if (_isSyncing) {
// // //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// // //       return;
// // //     }
// // //
// // //     _isSyncing = true;
// // //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// // //
// // //     try {
// // //       Get.snackbar(
// // //         'Syncing Data',
// // //         'Auto-syncing offline data...',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.blue.shade700,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //       );
// // //
// // //       await updateFunctionViewModel.syncAllLocalDataToServer();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('hasPendingClockOutData', false);
// // //       await prefs.setBool('clockOutPending', false);
// // //       await prefs.setBool('hasFastClockOutData', false);
// // //
// // //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// // //     } catch (e) {
// // //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// // //     } finally {
// // //       _isSyncing = false;
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
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //       _scheduleMidnightClockOut(); // ✅ Reschedule midnight clockout
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
// // //       _scheduleMidnightClockOut(); // ✅ Schedule midnight clockout
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
// // //     if (_themeMenuIcon.isEmpty) return;
// // //
// // //     final controller = StateMachineController.fromArtboard(
// // //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// // //     if (controller != null) {
// // //       artboard.addController(controller);
// // //       _themeMenuIcon[0].riveIcon.status =
// // //       controller.findInput<bool>("active") as SMIBool?;
// // //
// // //       if (_themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// // //         debugPrint(
// // //             "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// // //       }
// // //     } else {
// // //       debugPrint("StateMachineController not found!");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Center(
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           crossAxisAlignment: CrossAxisAlignment.center,
// // //           children: [
// // //             // Timer + Distance
// // //             Column(
// // //               crossAxisAlignment: CrossAxisAlignment.center,
// // //               children: [
// // //                 Obx(() {
// // //                   String displayTime = _localElapsedTime;
// // //                   if (displayTime == '00:00:00' &&
// // //                       attendanceViewModel.isClockedIn.value) {
// // //                     displayTime = attendanceViewModel.elapsedTime.value;
// // //                   }
// // //
// // //                   return Text(
// // //                     displayTime,
// // //                     style: TextStyle(
// // //                       fontSize: 20,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: attendanceViewModel.isClockedIn.value
// // //                           ? Colors.black87
// // //                           : Colors.grey,
// // //                     ),
// // //                   );
// // //                 }),
// // //
// // //                 Obx(() {
// // //                   if (attendanceViewModel.isClockedIn.value &&
// // //                       _currentDistance > 0) {
// // //                     return Text(
// // //                       '${_currentDistance.toStringAsFixed(2)} km',
// // //                       style: TextStyle(
// // //                         fontSize: 14,
// // //                         color: Colors.blue.shade700,
// // //                         fontWeight: FontWeight.w500,
// // //                       ),
// // //                     );
// // //                   }
// // //                   return const SizedBox.shrink();
// // //                 }),
// // //               ],
// // //             ),
// // //
// // //             const SizedBox(height: 5),
// // //
// // //             // Buttons
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Obx(() {
// // //                   return SizedBox(
// // //                       width: 120,
// // //                       height: 30,
// // //                       child:  ElevatedButton(
// // //                         onPressed: attendanceViewModel.isClockedIn.value
// // //                             ? null
// // //                             : () async => _handleClockIn(context),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.blueGrey,
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                         ),
// // //                         child: const Row(
// // //                           mainAxisSize: MainAxisSize.min,
// // //                           children: [
// // //                             Text("Clock In", style: TextStyle(
// // //                               color: Colors.white,
// // //                               fontSize: 15,
// // //                               fontWeight: FontWeight.w600,
// // //                               letterSpacing: 0.5,
// // //                             ))
// // //                           ],
// // //                         ),
// // //                       )
// // //                   );
// // //                 }),
// // //
// // //                 const SizedBox(width: 5),
// // //
// // //                 Obx(() { return SizedBox(
// // //                     width: 120,
// // //                     height: 30,
// // //                     child:  ElevatedButton(
// // //                       onPressed: attendanceViewModel.isClockedIn.value
// // //                           ? () async => _handleClockOut(context)
// // //                           : null,
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.redAccent,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(8),
// // //                         ),
// // //                       ),
// // //                       child: const Row(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           Text("Clock Out", style: TextStyle(
// // //                             color: Colors.white,
// // //                             fontSize: 15,
// // //                             fontWeight: FontWeight.w600,
// // //                             letterSpacing: 0.5,
// // //                           ))
// // //                         ],
// // //                       ),
// // //                     )
// // //                 );
// // //                 }),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ ULTRA-FAST CLOCK-OUT METHOD
// // //   Future<void> _handleClockOut(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
// // //
// // //     // Show loading dialog
// // //     bool showLoadingDialog = true;
// // //     DateTime startTime = DateTime.now();
// // //     Timer? loadingTimer;
// // //
// // //     if (showLoadingDialog) {
// // //       showDialog(
// // //         context: context,
// // //         barrierDismissible: false,
// // //         builder: (_) =>
// // //             AlertDialog(
// // //               backgroundColor: Colors.white.withOpacity(0.9),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(15),
// // //               ),
// // //               content: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   CircularProgressIndicator(
// // //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
// // //                   ),
// // //                   SizedBox(height: 15),
// // //                   Text(
// // //                     "Processing clock-out...",
// // //                     style: TextStyle(
// // //                       fontWeight: FontWeight.w500,
// // //                       color: Colors.black87,
// // //                     ),
// // //                   ),
// // //                   SizedBox(height: 5),
// // //                   Text(
// // //                     "Please wait 3 seconds",
// // //                     style: TextStyle(
// // //                       fontSize: 12,
// // //                       color: Colors.grey,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //       );
// // //
// // //       loadingTimer = Timer(Duration(seconds: 3), () {});
// // //     }
// // //
// // //     try {
// // //       // Immediate state update
// // //       _stopLocationMonitoring();
// // //       _localBackupTimer?.cancel();
// // //       _midnightClockOutTimer?.cancel();
// // //
// // //       double finalDistance = _currentDistance;
// // //       if (finalDistance <= 0) {
// // //         try {
// // //           LocationService locationService = LocationService();
// // //           await locationService.init();
// // //           finalDistance = locationService.getCurrentDistance();
// // //           if (finalDistance <= 0) finalDistance = 0.0;
// // //         } catch (e) {
// // //           finalDistance = 0.0;
// // //         }
// // //       }
// // //
// // //       DateTime clockOutTime = DateTime.now();
// // //
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       await prefs.setBool('isClockedIn', false);
// // //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// // //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// // //       await prefs.setBool('clockOutPending', true);
// // //       await prefs.setBool('hasFastClockOutData', true);
// // //
// // //       locationViewModel.isClockedIn.value = false;
// // //       attendanceViewModel.isClockedIn.value = false;
// // //       _isRiveAnimationActive = false;
// // //
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = false;
// // //       }
// // //
// // //       _localElapsedTime = '00:00:00';
// // //       _localClockInTime = null;
// // //
// // //       await attendanceOutViewModel.fastSaveAttendanceOut(
// // //         clockOutTime: clockOutTime,
// // //         totalDistance: finalDistance,
// // //         isAuto: false,
// // //         reason: 'manual_clockout',
// // //       );
// // //
// // //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// // //
// // //       final service = FlutterBackgroundService();
// // //       service.invoke("stopService");
// // //
// // //       try {
// // //         await location.enableBackgroundMode(enable: false);
// // //       } catch (e) {
// // //         debugPrint("⚠️ Background mode disable error: $e");
// // //       }
// // //
// // //       DateTime endTime = DateTime.now();
// // //       Duration elapsedTime = endTime.difference(startTime);
// // //
// // //       if (elapsedTime.inSeconds < 3) {
// // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // //       }
// // //
// // //       if (loadingTimer != null) loadingTimer.cancel();
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         '✅ Clock Out Complete',
// // //         'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: Duration(seconds: 2),
// // //       );
// // //
// // //       debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");
// // //
// // //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// // //     } catch (e) {
// // //       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
// // //
// // //       DateTime endTime = DateTime.now();
// // //       Duration elapsedTime = endTime.difference(startTime);
// // //
// // //       if (elapsedTime.inSeconds < 3) {
// // //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// // //         await Future.delayed(Duration(seconds: remainingSeconds));
// // //       }
// // //
// // //       if (loadingTimer != null) loadingTimer.cancel();
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Clock Out Complete',
// // //         'Data saved locally',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.orange,
// // //         colorText: Colors.white,
// // //         duration: Duration(seconds: 2),
// // //       );
// // //     }
// // //   }
// // //
// // //   // ✅ CLOCK-IN METHOD
// // //   Future<void> _handleClockIn(BuildContext context) async {
// // //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// // //
// // //     // Location check
// // //     bool hasPermission = await _checkLocationPermission(context);
// // //     if (!hasPermission) {
// // //       debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
// // //       return;
// // //     }
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
// // //       builder: (_) =>
// // //           AlertDialog(
// // //             backgroundColor: Colors.white,
// // //             content: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 CircularProgressIndicator(color: Colors.green),
// // //                 SizedBox(height: 15),
// // //                 Text('Checking permissions...',
// // //                     style: TextStyle(fontWeight: FontWeight.w500)),
// // //               ],
// // //             ),
// // //           ),
// // //     );
// // //
// // //     try {
// // //       SharedPreferences prefs = await SharedPreferences.getInstance();
// // //       LocationService locationService = LocationService();
// // //       await locationService.init();
// // //       await locationService.listenLocation();
// // //
// // //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// // //       final downloadDirectory = await getDownloadsDirectory();
// // //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// // //       File file = File(filePath);
// // //
// // //       if (!file.existsSync()) {
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
// // //       double initialDistance = locationService.getCurrentDistance();
// // //       if (initialDistance > 0.001) {
// // //         locationService.resetDistance();
// // //         initialDistance = 0.0;
// // //       }
// // //
// // //       await attendanceViewModel.saveFormAttendanceIn();
// // //       _startBackgroundServices();
// // //
// // //       locationViewModel.isClockedIn.value = true;
// // //       attendanceViewModel.isClockedIn.value = true;
// // //
// // //       await prefs.setBool('isClockedIn', true);
// // //       await prefs.setString('currentGpxFilePath', filePath);
// // //       await prefs.setString(
// // //           'currentSessionStart', DateTime.now().toIso8601String());
// // //
// // //       _isRiveAnimationActive = true;
// // //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// // //         _themeMenuIcon[0].riveIcon.status!.value = true;
// // //       }
// // //
// // //       _startLocalBackupTimer();
// // //       _startLocationMonitoring();
// // //       _scheduleMidnightClockOut(); // ✅ Schedule midnight clockout
// // //
// // //       travelTimeViewModel.startTracking();
// // //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// // //
// // //       await _updateCurrentDistance();
// // //       await DailyWorkTimeManager.recordClockIn(DateTime.now());
// // //
// // //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// // //
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         '✅ Clocked In Successfully',
// // //         'GPS tracking started',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.green,
// // //         colorText: Colors.white,
// // //         duration: const Duration(seconds: 3),
// // //         icon: Icon(Icons.check_circle, color: Colors.white),
// // //       );
// // //     } catch (e) {
// // //       debugPrint("❌ [CLOCK-IN] Error: $e");
// // //
// // //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// // //
// // //       Get.snackbar(
// // //         'Error',
// // //         'Failed to clock in: ${e.toString()}',
// // //         snackPosition: SnackPosition.TOP,
// // //         backgroundColor: Colors.red,
// // //         colorText: Colors.white,
// // //       );
// // //     }
// // //   }
// // //
// // //   // ✅ START LOCATION MONITORING
// // //   void _startLocationMonitoring() {
// // //     _wasLocationAvailable = true;
// // //     _autoClockOutInProgress = false;
// // //
// // //     _locationMonitorTimer =
// // //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// // //           if (!attendanceViewModel.isClockedIn.value) {
// // //             _stopLocationMonitoring();
// // //             return;
// // //           }
// // //
// // //           // ✅ CHECK LOCATION ON/OFF
// // //           bool currentLocationAvailable = await attendanceViewModel
// // //               .isLocationAvailable();
// // //
// // //           if (_wasLocationAvailable && !currentLocationAvailable) {
// // //             debugPrint("📍 [LOCATION] Location OFF - URGENT auto clock-out");
// // //
// // //             // Show URGENT notification immediately
// // //             await _showUrgentNotification(
// // //               title: '⚠️ LOCATION TURNED OFF',
// // //               body: 'Auto clockout triggered immediately because location was turned off',
// // //               payload: 'location_off_auto',
// // //             );
// // //
// // //             await _handleAutoClockOut(
// // //               reason: 'location_off_auto',
// // //               context: context,
// // //             );
// // //             return;
// // //           }
// // //           _wasLocationAvailable = currentLocationAvailable;
// // //
// // //           // ✅ CHECK PERMISSION REVOKED
// // //           bool currentPermissionGranted = await _checkPermissionStatus();
// // //
// // //           if (_wasPermissionGranted && !currentPermissionGranted) {
// // //             debugPrint("🔐 [PERMISSION] Permission REVOKED - URGENT auto clock-out");
// // //
// // //             // Show URGENT notification immediately
// // //             await _showUrgentNotification(
// // //               title: '⚠️ PERMISSION REVOKED',
// // //               body: 'Auto clockout triggered immediately because location permission was removed',
// // //               payload: 'permission_revoked_auto',
// // //             );
// // //
// // //             await _handleAutoClockOut(
// // //               reason: 'permission_revoked_auto',
// // //               context: context,
// // //             );
// // //           }
// // //           _wasPermissionGranted = currentPermissionGranted;
// // //         });
// // //   }
// // //
// // //   void _startBackgroundServices() async {
// // //     try {
// // //       debugPrint("🛰 [BACKGROUND] Starting services...");
// // //
// // //       final service = FlutterBackgroundService();
// // //       await location.enableBackgroundMode(enable: true);
// // //
// // //       initializeServiceLocation().catchError((e) =>
// // //           debugPrint("Service init error: $e"));
// // //       service.startService().catchError((e) =>
// // //           debugPrint("Service start error: $e"));
// // //       location.changeSettings(
// // //           interval: 300, accuracy: loc.LocationAccuracy.high)
// // //           .catchError((e) => debugPrint("Location settings error: $e"));
// // //
// // //       debugPrint("✅ [BACKGROUND] Services started");
// // //     } catch (e) {
// // //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// // //     }
// // //   }
// // //
// // //   void _stopLocationMonitoring() {
// // //     _locationMonitorTimer?.cancel();
// // //     _locationMonitorTimer = null;
// // //     _autoClockOutInProgress = false;
// // //   }
// // //
// // //   // ✅ SCHEDULE HEAVY OPERATIONS TO RUN IN BACKGROUND
// // //   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
// // //     debugPrint("🔄 Scheduling background operations...");
// // //
// // //     // Run in background after 5 seconds
// // //     Timer(Duration(seconds: 5), () async {
// // //       try {
// // //         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
// // //
// // //         // 1. GPX Consolidation
// // //         await locationViewModel.consolidateDailyGPXData();
// // //
// // //         // 2. Save location from consolidated file
// // //         await locationViewModel.saveLocationFromConsolidatedFile();
// // //
// // //         // 3. Update SharedPreferences with full data
// // //         SharedPreferences prefs = await SharedPreferences.getInstance();
// // //
// // //         // Save complete data for sync
// // //         await prefs.setDouble('fullClockOutDistance', distance);
// // //         await prefs.setString(
// // //             'fullClockOutTime', clockOutTime.toIso8601String());
// // //         await prefs.setDouble(
// // //             'pendingLatOut', locationViewModel.globalLatitude1.value);
// // //         await prefs.setDouble(
// // //             'pendingLngOut', locationViewModel.globalLongitude1.value);
// // //         await prefs.setString(
// // //             'pendingAddress', locationViewModel.shopAddress.value);
// // //
// // //         debugPrint("✅ [BACKGROUND] Heavy operations completed");
// // //
// // //         // 4. Try auto-sync if online
// // //         _triggerPostClockOutSync();
// // //       } catch (e) {
// // //         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
// // //         // Data is already safe in fast save
// // //       }
// // //     });
// // //   }
// // //
// // //   // ✅ POST CLOCK-OUT SYNC
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
// // //         await prefs.setBool('hasFastClockOutData', false);
// // //
// // //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// // //
// // //         // Show success notification (subtle)
// // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // //           Get.snackbar(
// // //             'Sync Complete',
// // //             'All data synchronized to server',
// // //             snackPosition: SnackPosition.BOTTOM,
// // //             backgroundColor: Colors.green,
// // //             colorText: Colors.white,
// // //             duration: const Duration(seconds: 2),
// // //           );
// // //         });
// // //       } else {
// // //         debugPrint(
// // //             "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
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
// // // }
// //
// //
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
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import '../../Databases/util.dart';
// // import '../../LocatioPoints/ravelTimeViewModel.dart';
// // import '../../Tracker/location00.dart';
// // import '../../Tracker/trac.dart';
// // import '../../Utils/daily_work_time_manager.dart';
// // import '../../main.dart';
// // import 'assets.dart';
// // import 'menu_item.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:intl/intl.dart';
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
// //   final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());
// //
// //   final loc.Location location = loc.Location();
// //   final Connectivity _connectivity = Connectivity();
// //   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// //
// //   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
// //   Timer? _locationMonitorTimer;
// //   bool _wasLocationAvailable = true;
// //   bool _autoClockOutInProgress = false;
// //
// //   Timer? _midnightClockOutTimer;
// //   Timer? _permissionCheckTimer;
// //   bool _isMidnightClockOutScheduled = false;
// //
// //   bool _isRiveAnimationActive = false;
// //   Timer? _localBackupTimer;
// //   DateTime? _localClockInTime;
// //   String _localElapsedTime = '00:00:00';
// //
// //   // Auto-sync variables
// //   Timer? _autoSyncTimer;
// //   bool _isOnline = false;
// //   bool _isSyncing = false;
// //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// //
// //   // Distance tracking
// //   double _currentDistance = 0.0;
// //   Timer? _distanceUpdateTimer;
// //
// //   // Permission monitoring
// //   bool _wasPermissionGranted = true;
// //
// //   // Notification IDs
// //   int _notificationId = 0;
// //
// //   // ✅ CRITICAL EVENT TIMESTAMP KEYS
// //   static const String KEY_EVENT_TIMESTAMP = 'critical_event_timestamp';
// //   static const String KEY_EVENT_REASON = 'critical_event_reason';
// //   static const String KEY_EVENT_DISTANCE = 'critical_event_distance';
// //   static const String KEY_HAS_CRITICAL_EVENT = 'has_critical_event_pending';
// //   static const String KEY_EVENT_LATITUDE = 'critical_event_latitude';
// //   static const String KEY_EVENT_LONGITUDE = 'critical_event_longitude';
// //
// //   // ✅ NEW: Keys to freeze timer at event time
// //   static const String KEY_EVENT_ELAPSED_TIME = 'critical_event_elapsed_time';
// //   static const String KEY_IS_TIMER_FROZEN = 'is_timer_frozen';
// //   static const String KEY_FROZEN_DISPLAY_TIME = 'frozen_display_time';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //
// //     _initializeUrgentNotifications();
// //     _initializeFromPersistentState();
// //     _startAutoSyncMonitoring();
// //     _startDistanceUpdater();
// //     _scheduleMidnightClockOut();
// //     _startPermissionMonitoring();
// //
// //     // ✅ CHECK FOR CRITICAL EVENTS ON STARTUP
// //     _checkAndProcessCriticalEvent();
// //   }
// //
// //   // ✅ CHECK AND PROCESS CRITICAL EVENT ON APP START
// //   Future<void> _checkAndProcessCriticalEvent() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool hasCriticalEvent = prefs.getBool(KEY_HAS_CRITICAL_EVENT) ?? false;
// //     bool isTimerFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //
// //     if (hasCriticalEvent || isTimerFrozen) {
// //       debugPrint("🚨 [CRITICAL EVENT] Found pending critical event on startup");
// //
// //       String? eventTimeStr = prefs.getString(KEY_EVENT_TIMESTAMP);
// //       String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
// //       String? eventReason = prefs.getString(KEY_EVENT_REASON);
// //       double? eventDistance = prefs.getDouble(KEY_EVENT_DISTANCE);
// //       double? eventLat = prefs.getDouble(KEY_EVENT_LATITUDE);
// //       double? eventLng = prefs.getDouble(KEY_EVENT_LONGITUDE);
// //
// //       if (eventTimeStr != null) {
// //         DateTime eventTime = DateTime.parse(eventTimeStr);
// //
// //         debugPrint("🚨 [CRITICAL EVENT] Event occurred at: $eventTime");
// //         debugPrint("🚨 [CRITICAL EVENT] Frozen elapsed time: $frozenTime");
// //         debugPrint("🚨 [CRITICAL EVENT] Reason: $eventReason");
// //
// //         // ✅ SET THE FROZEN TIME TO DISPLAY (don't calculate new time)
// //         if (frozenTime != null) {
// //           _localElapsedTime = frozenTime;
// //           attendanceViewModel.elapsedTime.value = frozenTime;
// //
// //           // ✅ IMPORTANT: Stop any running timer and keep the frozen state
// //           _localBackupTimer?.cancel();
// //           _localBackupTimer = null;
// //         }
// //
// //         // Update UI to show frozen state
// //         if (mounted) {
// //           setState(() {});
// //         }
// //
// //         // Show notification about the event
// //         Get.snackbar(
// //           '⚠️ Auto Clock-Out Occurred',
// //           'Event: ${_getReasonMessage(eventReason ?? 'unknown')}\nTime: ${DateFormat('HH:mm:ss').format(eventTime)}\nDuration: $frozenTime',
// //           snackPosition: SnackPosition.TOP,
// //           backgroundColor: Colors.orange.shade700,
// //           colorText: Colors.white,
// //           duration: const Duration(seconds: 5),
// //           icon: const Icon(Icons.warning, color: Colors.white),
// //         );
// //
// //         // Sync the data with the original timestamp
// //         await _syncCriticalEventData(
// //           eventTime: eventTime,
// //           reason: eventReason ?? 'unknown',
// //           distance: eventDistance ?? 0.0,
// //           latitude: eventLat ?? 0.0,
// //           longitude: eventLng ?? 0.0,
// //         );
// //
// //         // Clear critical event flags after processing but keep frozen time
// //         await _clearCriticalEventData();
// //       }
// //     }
// //   }
// //
// //   // ✅ SYNC CRITICAL EVENT DATA TO SERVER
// //   Future<void> _syncCriticalEventData({
// //     required DateTime eventTime,
// //     required String reason,
// //     required double distance,
// //     required double latitude,
// //     required double longitude,
// //   }) async {
// //     try {
// //       await attendanceOutViewModel.fastSaveAttendanceOut(
// //         clockOutTime: eventTime,
// //         totalDistance: distance,
// //         isAuto: true,
// //         reason: reason,
// //       );
// //
// //       debugPrint("✅ [SYNC] Critical event data synced with timestamp: $eventTime");
// //
// //       _triggerAutoSync();
// //
// //     } catch (e) {
// //       debugPrint("❌ [SYNC] Error syncing critical event: $e");
// //     }
// //   }
// //
// //   // ✅ CLEAR CRITICAL EVENT DATA (but keep frozen time visible)
// //   Future<void> _clearCriticalEventData() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove(KEY_HAS_CRITICAL_EVENT);
// //     await prefs.remove(KEY_EVENT_TIMESTAMP);
// //     await prefs.remove(KEY_EVENT_REASON);
// //     await prefs.remove(KEY_EVENT_DISTANCE);
// //     await prefs.remove(KEY_EVENT_LATITUDE);
// //     await prefs.remove(KEY_EVENT_LONGITUDE);
// //     // ✅ DON'T remove KEY_FROZEN_DISPLAY_TIME and KEY_IS_TIMER_FROZEN yet
// //     // Keep them so timer stays frozen until manual clock in next day
// //     debugPrint("🧹 [CLEAR] Critical event data cleared (timer remains frozen)");
// //   }
// //
// //   // ✅ SAVE CRITICAL EVENT DATA (Called when event happens)
// //   Future<void> _saveCriticalEventData({
// //     required DateTime eventTime,
// //     required String reason,
// //     required double distance,
// //     required double latitude,
// //     required double longitude,
// //   }) async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //     // ✅ CAPTURE CURRENT ELAPSED TIME BEFORE STOPPING TIMER
// //     String frozenElapsedTime = _localElapsedTime;
// //
// //     await prefs.setBool(KEY_HAS_CRITICAL_EVENT, true);
// //     await prefs.setBool(KEY_IS_TIMER_FROZEN, true);
// //     await prefs.setString(KEY_EVENT_TIMESTAMP, eventTime.toIso8601String());
// //     await prefs.setString(KEY_EVENT_REASON, reason);
// //     await prefs.setDouble(KEY_EVENT_DISTANCE, distance);
// //     await prefs.setDouble(KEY_EVENT_LATITUDE, latitude);
// //     await prefs.setDouble(KEY_EVENT_LONGITUDE, longitude);
// //     await prefs.setString(KEY_FROZEN_DISPLAY_TIME, frozenElapsedTime); // ✅ Save frozen time
// //
// //     debugPrint("💾 [SAVE] Critical event saved at: $eventTime");
// //     debugPrint("💾 [SAVE] Frozen elapsed time: $frozenElapsedTime");
// //     debugPrint("💾 [SAVE] Reason: $reason");
// //     debugPrint("💾 [SAVE] Distance: $distance");
// //   }
// //
// //   // ✅ URGENT NOTIFICATION SETUP (IMMEDIATE)
// //   Future<void> _initializeUrgentNotifications() async {
// //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //
// //     const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
// //       'urgent_auto_clockout_channel',
// //       'URGENT Auto Clockout Notifications',
// //       description: 'High-priority channel for urgent auto clockout notifications',
// //       importance: Importance.max,
// //       enableVibration: true,
// //       playSound: true,
// //       sound: RawResourceAndroidNotificationSound('notification_sound'),
// //       enableLights: true,
// //       ledColor: Colors.red,
// //     );
// //
// //     const AndroidInitializationSettings androidSettings =
// //     AndroidInitializationSettings('@mipmap/ic_launcher');
// //
// //     const DarwinInitializationSettings iosSettings =
// //     DarwinInitializationSettings(
// //       requestAlertPermission: true,
// //       requestBadgePermission: true,
// //       requestSoundPermission: true,
// //     );
// //
// //     const InitializationSettings initSettings = InitializationSettings(
// //       android: androidSettings,
// //       iOS: iosSettings,
// //     );
// //
// //     await flutterLocalNotificationsPlugin.initialize(
// //       initSettings,
// //       onDidReceiveNotificationResponse: (NotificationResponse response) async {
// //         debugPrint('Notification tapped: ${response.payload}');
// //       },
// //     );
// //
// //     await flutterLocalNotificationsPlugin
// //         .resolvePlatformSpecificImplementation<
// //         AndroidFlutterLocalNotificationsPlugin>()
// //         ?.createNotificationChannel(urgentChannel);
// //   }
// //
// //   // ✅ SHOW URGENT NOTIFICATION METHOD (IMMEDIATE)
// //   Future<void> _showUrgentNotification({
// //     required String title,
// //     required String body,
// //     String? payload,
// //   }) async {
// //     _notificationId++;
// //
// //     const AndroidNotificationDetails androidDetails =
// //     AndroidNotificationDetails(
// //       'urgent_auto_clockout_channel',
// //       'URGENT Auto Clockout Notifications',
// //       channelDescription: 'High-priority channel for urgent auto clockout notifications',
// //       importance: Importance.max,
// //       priority: Priority.high,
// //       enableVibration: true,
// //       playSound: true,
// //       timeoutAfter: 5000,
// //       category: AndroidNotificationCategory.alarm,
// //       visibility: NotificationVisibility.public,
// //       color: Colors.red,
// //       ledColor: Colors.red,
// //       ledOnMs: 1000,
// //       ledOffMs: 500,
// //       fullScreenIntent: true,
// //       ongoing: false,
// //       autoCancel: true,
// //       styleInformation: BigTextStyleInformation(''),
// //     );
// //
// //     const DarwinNotificationDetails iosDetails =
// //     DarwinNotificationDetails(
// //       presentAlert: true,
// //       presentBadge: true,
// //       presentSound: true,
// //       sound: 'default',
// //       interruptionLevel: InterruptionLevel.timeSensitive,
// //     );
// //
// //     const NotificationDetails notificationDetails = NotificationDetails(
// //       android: androidDetails,
// //       iOS: iosDetails,
// //     );
// //
// //     await flutterLocalNotificationsPlugin.show(
// //       _notificationId,
// //       title,
// //       body,
// //       notificationDetails,
// //       payload: payload,
// //     );
// //
// //     debugPrint("🔔 [URGENT NOTIFICATION] Sent: $title");
// //
// //     if (mounted) {
// //       Get.snackbar(
// //         title,
// //         body,
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 5),
// //         icon: const Icon(Icons.warning, color: Colors.white),
// //         shouldIconPulse: true,
// //         barBlur: 10,
// //         isDismissible: true,
// //       );
// //     }
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
// //     _midnightClockOutTimer?.cancel();
// //     _permissionCheckTimer?.cancel();
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
// //       _rescheduleMidnightClockOut();
// //       _checkAndProcessCriticalEvent(); // ✅ Check for critical events on resume
// //     }
// //   }
// //
// //   // ✅ SCHEDULE MIDNIGHT AUTO CLOCKOUT (11:58 PM)
// //   void _scheduleMidnightClockOut() {
// //     // ✅ DON'T schedule if timer is frozen (critical event already happened)
// //     SharedPreferences.getInstance().then((prefs) {
// //       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //       if (isFrozen) {
// //         debugPrint("⏰ [MIDNIGHT] Timer is frozen, not scheduling midnight clockout");
// //         return;
// //       }
// //
// //       if (!attendanceViewModel.isClockedIn.value) {
// //         return;
// //       }
// //
// //       _midnightClockOutTimer?.cancel();
// //
// //       final now = DateTime.now();
// //       final scheduledTime = DateTime(
// //         now.year,
// //         now.month,
// //         now.day,
// //         23,
// //         58,
// //       );
// //
// //       Duration timeUntilMidnight;
// //       if (now.isAfter(scheduledTime)) {
// //         final tomorrow = scheduledTime.add(const Duration(days: 1));
// //         timeUntilMidnight = tomorrow.difference(now);
// //       } else {
// //         timeUntilMidnight = scheduledTime.difference(now);
// //       }
// //
// //       _midnightClockOutTimer = Timer(timeUntilMidnight, () async {
// //         if (attendanceViewModel.isClockedIn.value) {
// //           debugPrint("⏰ [MIDNIGHT] Auto clockout triggered at 11:58 PM");
// //
// //           DateTime eventTime = DateTime.now();
// //           double currentDist = await _getCurrentDistance();
// //           double lat = locationViewModel.globalLatitude1.value;
// //           double lng = locationViewModel.globalLongitude1.value;
// //
// //           // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
// //           await _saveCriticalEventData(
// //             eventTime: eventTime,
// //             reason: 'midnight_auto',
// //             distance: currentDist,
// //             latitude: lat,
// //             longitude: lng,
// //           );
// //
// //           await _showUrgentNotification(
// //             title: '⚠️ AUTO CLOCKOUT - 11:58 PM',
// //             body: 'You have been automatically clocked out at 11:58 PM',
// //             payload: 'midnight_auto',
// //           );
// //
// //           await _handleAutoClockOut(
// //             reason: 'midnight_auto',
// //             context: context,
// //             eventTime: eventTime,
// //           );
// //         }
// //       });
// //
// //       _isMidnightClockOutScheduled = true;
// //       debugPrint("⏰ [MIDNIGHT] Auto clockout scheduled for ${scheduledTime.hour}:${scheduledTime.minute}");
// //     });
// //   }
// //
// //   void _rescheduleMidnightClockOut() {
// //     SharedPreferences.getInstance().then((prefs) {
// //       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //       if (!isFrozen && attendanceViewModel.isClockedIn.value) {
// //         _scheduleMidnightClockOut();
// //       }
// //     });
// //   }
// //
// //   // ✅ START PERMISSION MONITORING (FASTER CHECK)
// //   void _startPermissionMonitoring() {
// //     _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
// //       // ✅ Check if timer is frozen first
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //       if (isFrozen) {
// //         debugPrint("🔒 [MONITOR] Timer is frozen, stopping monitoring");
// //         timer.cancel();
// //         return;
// //       }
// //
// //       if (!attendanceViewModel.isClockedIn.value) {
// //         return;
// //       }
// //
// //       // Check location services
// //       bool locationEnabled = await attendanceViewModel.isLocationAvailable();
// //       if (_wasLocationAvailable && !locationEnabled) {
// //         debugPrint("📍 [LOCATION] Location turned OFF - URGENT auto clockout");
// //
// //         DateTime eventTime = DateTime.now();
// //         double currentDist = await _getCurrentDistance();
// //         double lat = locationViewModel.globalLatitude1.value;
// //         double lng = locationViewModel.globalLongitude1.value;
// //
// //         // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
// //         await _saveCriticalEventData(
// //           eventTime: eventTime,
// //           reason: 'location_off_auto',
// //           distance: currentDist,
// //           latitude: lat,
// //           longitude: lng,
// //         );
// //
// //         await _showUrgentNotification(
// //           title: '⚠️ LOCATION TURNED OFF',
// //           body: 'Auto clockout triggered immediately because location was turned off',
// //           payload: 'location_off_auto',
// //         );
// //
// //         await _handleAutoClockOut(
// //           reason: 'location_off_auto',
// //           context: context,
// //           eventTime: eventTime,
// //         );
// //         return;
// //       }
// //       _wasLocationAvailable = locationEnabled;
// //
// //       // Check location permissions
// //       bool permissionGranted = await _checkPermissionStatus();
// //       if (_wasPermissionGranted && !permissionGranted) {
// //         debugPrint("🔐 [PERMISSION] Location permission revoked - URGENT auto clockout");
// //
// //         DateTime eventTime = DateTime.now();
// //         double currentDist = await _getCurrentDistance();
// //         double lat = locationViewModel.globalLatitude1.value;
// //         double lng = locationViewModel.globalLongitude1.value;
// //
// //         // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
// //         await _saveCriticalEventData(
// //           eventTime: eventTime,
// //           reason: 'permission_revoked_auto',
// //           distance: currentDist,
// //           latitude: lat,
// //           longitude: lng,
// //         );
// //
// //         await _showUrgentNotification(
// //           title: '⚠️ PERMISSION REVOKED',
// //           body: 'Auto clockout triggered immediately because location permission was removed',
// //           payload: 'permission_revoked_auto',
// //         );
// //
// //         await _handleAutoClockOut(
// //           reason: 'permission_revoked_auto',
// //           context: context,
// //           eventTime: eventTime,
// //         );
// //         return;
// //       }
// //       _wasPermissionGranted = permissionGranted;
// //     });
// //   }
// //
// //   Future<bool> _checkPermissionStatus() async {
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     return permission == LocationPermission.always ||
// //         permission == LocationPermission.whileInUse;
// //   }
// //
// //   Future<bool> _checkLocationPermission(BuildContext context) async {
// //     LocationPermission permission = await Geolocator.checkPermission();
// //
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //     }
// //
// //     if (permission == LocationPermission.denied ||
// //         permission == LocationPermission.deniedForever) {
// //       await showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (ctx) => Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(20),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Icon(
// //                   Icons.location_off,
// //                   size: 50,
// //                   color: Colors.redAccent,
// //                 ),
// //                 const SizedBox(height: 15),
// //                 const Text(
// //                   "Location Permission Required",
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   "We need location access to continue.\n"
// //                       "Please enable location permission from app settings.",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextButton(
// //                         style: TextButton.styleFrom(
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                         ),
// //                         onPressed: () => Navigator.of(ctx).pop(),
// //                         child: const Text(
// //                           "Cancel",
// //                           style: TextStyle(color: Colors.grey),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     Expanded(
// //                       child: ElevatedButton(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.blueGrey,
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                         ),
// //                         onPressed: () async {
// //                           Navigator.of(ctx).pop();
// //                           await Geolocator.openAppSettings();
// //                         },
// //                         child: const Text(
// //                           "Open Settings",
// //                           style: TextStyle(color: Colors.white),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //       return false;
// //     }
// //
// //     return true;
// //   }
// //
// //   // ✅ HANDLE AUTO CLOCKOUT (Modified to accept eventTime)
// //   Future<void> _handleAutoClockOut({
// //     required String reason,
// //     required BuildContext context,
// //     DateTime? eventTime,
// //   }) async {
// //     if (_autoClockOutInProgress || !attendanceViewModel.isClockedIn.value) {
// //       return;
// //     }
// //     _autoClockOutInProgress = true;
// //
// //     DateTime clockOutTime = eventTime ?? DateTime.now();
// //
// //     debugPrint("⚡ [AUTO CLOCKOUT] Triggered for reason: $reason");
// //     debugPrint("⚡ [AUTO CLOCKOUT] Using timestamp: $clockOutTime");
// //
// //     try {
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel(); // ✅ Stop the timer immediately
// //       _midnightClockOutTimer?.cancel();
// //
// //       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //       await prefs.setBool('isClockedIn', false);
// //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// //       await prefs.setBool('clockOutPending', true);
// //       await prefs.setBool('hasFastClockOutData', true);
// //       await prefs.setString('fastClockOutReason', reason);
// //
// //       // ✅ DON'T reset _localElapsedTime - keep the frozen value
// //       // ✅ DON'T reset _localClockInTime - we need it for reference
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //
// //       _isRiveAnimationActive = false;
// //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       // Save attendance out with the EXACT event time
// //       await attendanceOutViewModel.fastSaveAttendanceOut(
// //         clockOutTime: clockOutTime,
// //         totalDistance: finalDistance,
// //         isAuto: true,
// //         reason: reason,
// //       );
// //
// //       await DailyWorkTimeManager.recordClockOut(clockOutTime);
// //
// //       final service = FlutterBackgroundService();
// //       service.invoke("stopService");
// //
// //       try {
// //         await location.enableBackgroundMode(enable: false);
// //       } catch (e) {
// //         debugPrint("⚠️ Background mode disable error: $e");
// //       }
// //
// //       debugPrint("✅ [AUTO CLOCKOUT] Completed for reason: $reason at $clockOutTime");
// //       debugPrint("✅ [AUTO CLOCKOUT] Frozen elapsed time: $_localElapsedTime");
// //
// //     } catch (e) {
// //       debugPrint("❌ [AUTO CLOCKOUT] Error: $e");
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isClockedIn', false);
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //     } finally {
// //       _autoClockOutInProgress = false;
// //     }
// //   }
// //
// //   String _getReasonMessage(String reason) {
// //     switch (reason) {
// //       case 'midnight_auto':
// //         return 'You have been automatically clocked out at 11:58 PM';
// //       case 'location_off_auto':
// //         return 'Auto clockout because location services were turned off';
// //       case 'permission_revoked_auto':
// //         return 'Auto clockout because location permission was removed';
// //       default:
// //         return 'Auto clockout completed successfully';
// //     }
// //   }
// //
// //   void _checkAndSyncPendingData() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
// //     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
// //
// //     if (hasPendingClockOut || clockOutPending) {
// //       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
// //       _triggerAutoSync();
// //     }
// //   }
// //
// //   void _startDistanceUpdater() {
// //     _distanceUpdateTimer =
// //         Timer.periodic(const Duration(seconds: 5), (timer) async {
// //           // ✅ Check if timer is frozen
// //           SharedPreferences prefs = await SharedPreferences.getInstance();
// //           bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //
// //           if (isFrozen) {
// //             timer.cancel();
// //             return;
// //           }
// //
// //           if (attendanceViewModel.isClockedIn.value) {
// //             await _updateCurrentDistance();
// //           }
// //         });
// //   }
// //
// //   Future<void> _updateCurrentDistance() async {
// //     try {
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       double distance = locationService.getCurrentDistance();
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
// //   Future<double> _getCurrentDistance() async {
// //     if (_currentDistance > 0) {
// //       return _currentDistance;
// //     }
// //
// //     try {
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       return locationService.getCurrentDistance();
// //     } catch (e) {
// //       return 0.0;
// //     }
// //   }
// //
// //   void _startAutoSyncMonitoring() async {
// //     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
// //         List<ConnectivityResult> results) {
// //       bool wasOnline = _isOnline;
// //       _isOnline = results.isNotEmpty &&
// //           results.any((result) => result != ConnectivityResult.none);
// //
// //       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'}");
// //
// //       if (_isOnline && !wasOnline && !_isSyncing) {
// //         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
// //         _triggerAutoSync();
// //       }
// //     });
// //
// //     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
// //       if (!_isSyncing) {
// //         _checkConnectivityAndSync();
// //       }
// //     });
// //
// //     _checkConnectivityAndSync();
// //   }
// //
// //   void _checkConnectivityAndSync() async {
// //     if (_isSyncing) {
// //       debugPrint('⏸️ Sync already in progress - skipping');
// //       return;
// //     }
// //
// //     try {
// //       var results = await _connectivity.checkConnectivity();
// //       bool wasOnline = _isOnline;
// //       _isOnline = results.isNotEmpty &&
// //           results.any((result) => result != ConnectivityResult.none);
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
// //   void _triggerAutoSync() async {
// //     if (_isSyncing) {
// //       debugPrint('⏸️ Auto-sync already in progress - skipping');
// //       return;
// //     }
// //
// //     _isSyncing = true;
// //     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
// //
// //     try {
// //       Get.snackbar(
// //         'Syncing Data',
// //         'Auto-syncing offline data...',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.blue.shade700,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //       );
// //
// //       await updateFunctionViewModel.syncAllLocalDataToServer();
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('hasPendingClockOutData', false);
// //       await prefs.setBool('clockOutPending', false);
// //       await prefs.setBool('hasFastClockOutData', false);
// //
// //       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
// //     } catch (e) {
// //       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
// //     } finally {
// //       _isSyncing = false;
// //       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
// //     }
// //   }
// //
// //   void _restoreEverything() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
// //     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
// //
// //     // ✅ If timer is frozen, don't restore clocked-in state
// //     if (isFrozen && frozenTime != null) {
// //       debugPrint("🔒 [RESTORE] Timer is frozen at $frozenTime, not restoring clocked-in state");
// //
// //       _localElapsedTime = frozenTime;
// //       attendanceViewModel.elapsedTime.value = frozenTime;
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       _isRiveAnimationActive = false;
// //
// //       if (mounted) {
// //         setState(() {});
// //       }
// //       return;
// //     }
// //
// //     if (isClockedIn) {
// //       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
// //
// //       locationViewModel.isClockedIn.value = true;
// //       attendanceViewModel.isClockedIn.value = true;
// //
// //       _isRiveAnimationActive = true;
// //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = true;
// //       }
// //
// //       _startLocalBackupTimer();
// //       _scheduleMidnightClockOut();
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
// //
// //     // ✅ Check if timer is frozen before starting
// //     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //     if (isFrozen) {
// //       debugPrint("🔒 [BACKUP TIMER] Timer is frozen, not starting backup timer");
// //       return;
// //     }
// //
// //     String? clockInTimeString = prefs.getString('clockInTime');
// //
// //     if (clockInTimeString == null) return;
// //
// //     _localClockInTime = DateTime.parse(clockInTimeString);
// //     _localBackupTimer?.cancel();
// //
// //     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       // ✅ Check if frozen during timer execution
// //       SharedPreferences.getInstance().then((prefs) {
// //         bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //         if (isFrozen) {
// //           timer.cancel();
// //           debugPrint("🔒 [BACKUP TIMER] Frozen state detected, stopping timer");
// //           return;
// //         }
// //       });
// //
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
// //     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
// //
// //     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn, isFrozen = $isFrozen");
// //
// //     // ✅ Handle frozen state first
// //     if (isFrozen && frozenTime != null) {
// //       debugPrint("🔒 [INIT] Timer is frozen at: $frozenTime");
// //
// //       _localElapsedTime = frozenTime;
// //       attendanceViewModel.elapsedTime.value = frozenTime;
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       _isRiveAnimationActive = false;
// //
// //       if (mounted) {
// //         setState(() {});
// //       }
// //       return;
// //     }
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
// //       _scheduleMidnightClockOut();
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
// //     if (_themeMenuIcon.isEmpty) return;
// //
// //     final controller = StateMachineController.fromArtboard(
// //         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
// //     if (controller != null) {
// //       artboard.addController(controller);
// //       _themeMenuIcon[0].riveIcon.status =
// //       controller.findInput<bool>("active") as SMIBool?;
// //
// //       if (_themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
// //         debugPrint(
// //             "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
// //       }
// //     } else {
// //       debugPrint("StateMachineController not found!");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 Obx(() {
// //                   // ✅ Check if we should show frozen time
// //                   String displayTime = _localElapsedTime;
// //
// //                   // If we have a frozen time in prefs, use it
// //                   SharedPreferences.getInstance().then((prefs) {
// //                     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //                     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
// //                     if (isFrozen && frozenTime != null) {
// //                       displayTime = frozenTime;
// //                     }
// //                   });
// //
// //                   if (displayTime == '00:00:00' &&
// //                       attendanceViewModel.isClockedIn.value) {
// //                     displayTime = attendanceViewModel.elapsedTime.value;
// //                   }
// //
// //                   return Text(
// //                     displayTime,
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: attendanceViewModel.isClockedIn.value
// //                           ? Colors.black87
// //                           : Colors.grey,
// //                     ),
// //                   );
// //                 }),
// //
// //                 Obx(() {
// //                   if (attendanceViewModel.isClockedIn.value &&
// //                       _currentDistance > 0) {
// //                     return Text(
// //                       '${_currentDistance.toStringAsFixed(2)} km',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.blue.shade700,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     );
// //                   }
// //                   return const SizedBox.shrink();
// //                 }),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 5),
// //
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Obx(() {
// //                   return SizedBox(
// //                       width: 120,
// //                       height: 30,
// //                       child:  ElevatedButton(
// //                         onPressed: attendanceViewModel.isClockedIn.value
// //                             ? null
// //                             : () async => _handleClockIn(context),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.blueGrey,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         child: const Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Text("Clock In", style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w600,
// //                               letterSpacing: 0.5,
// //                             ))
// //                           ],
// //                         ),
// //                       )
// //                   );
// //                 }),
// //
// //                 const SizedBox(width: 5),
// //
// //                 Obx(() { return SizedBox(
// //                     width: 120,
// //                     height: 30,
// //                     child:  ElevatedButton(
// //                       onPressed: attendanceViewModel.isClockedIn.value
// //                           ? () async => _handleClockOut(context)
// //                           : null,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.redAccent,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: const Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Text("Clock Out", style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.w600,
// //                             letterSpacing: 0.5,
// //                           ))
// //                         ],
// //                       ),
// //                     )
// //                 );
// //                 }),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _handleClockOut(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
// //
// //     bool showLoadingDialog = true;
// //     DateTime startTime = DateTime.now();
// //     Timer? loadingTimer;
// //
// //     if (showLoadingDialog) {
// //       showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (_) =>
// //             AlertDialog(
// //               backgroundColor: Colors.white.withOpacity(0.9),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(15),
// //               ),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   CircularProgressIndicator(
// //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
// //                   ),
// //                   SizedBox(height: 15),
// //                   Text(
// //                     "Processing clock-out...",
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w500,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                   SizedBox(height: 5),
// //                   Text(
// //                     "Please wait 3 seconds",
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: Colors.grey,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //       );
// //
// //       loadingTimer = Timer(Duration(seconds: 3), () {});
// //     }
// //
// //     try {
// //       _stopLocationMonitoring();
// //       _localBackupTimer?.cancel();
// //       _midnightClockOutTimer?.cancel();
// //
// //       double finalDistance = _currentDistance;
// //       if (finalDistance <= 0) {
// //         try {
// //           LocationService locationService = LocationService();
// //           await locationService.init();
// //           finalDistance = locationService.getCurrentDistance();
// //           if (finalDistance <= 0) finalDistance = 0.0;
// //         } catch (e) {
// //           finalDistance = 0.0;
// //         }
// //       }
// //
// //       DateTime clockOutTime = DateTime.now();
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //       // ✅ CLEAR FROZEN STATE ON MANUAL CLOCK OUT (new day started)
// //       await prefs.remove(KEY_IS_TIMER_FROZEN);
// //       await prefs.remove(KEY_FROZEN_DISPLAY_TIME);
// //
// //       await prefs.setBool('isClockedIn', false);
// //       await prefs.setDouble('fastClockOutDistance', finalDistance);
// //       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
// //       await prefs.setBool('clockOutPending', true);
// //       await prefs.setBool('hasFastClockOutData', true);
// //
// //       locationViewModel.isClockedIn.value = false;
// //       attendanceViewModel.isClockedIn.value = false;
// //       _isRiveAnimationActive = false;
// //
// //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = false;
// //       }
// //
// //       _localElapsedTime = '00:00:00';
// //       _localClockInTime = null;
// //
// //       await attendanceOutViewModel.fastSaveAttendanceOut(
// //         clockOutTime: clockOutTime,
// //         totalDistance: finalDistance,
// //         isAuto: false,
// //         reason: 'manual_clockout',
// //       );
// //
// //       await DailyWorkTimeManager.recordClockOut(DateTime.now());
// //
// //       final service = FlutterBackgroundService();
// //       service.invoke("stopService");
// //
// //       try {
// //         await location.enableBackgroundMode(enable: false);
// //       } catch (e) {
// //         debugPrint("⚠️ Background mode disable error: $e");
// //       }
// //
// //       DateTime endTime = DateTime.now();
// //       Duration elapsedTime = endTime.difference(startTime);
// //
// //       if (elapsedTime.inSeconds < 3) {
// //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// //         await Future.delayed(Duration(seconds: remainingSeconds));
// //       }
// //
// //       if (loadingTimer != null) loadingTimer.cancel();
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         '✅ Clock Out Complete',
// //         'Data saved locally\nDistance: ${finalDistance.toStringAsFixed(2)} km',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //         duration: Duration(seconds: 2),
// //       );
// //
// //       debugPrint("✅ [CLOCK-OUT] COMPLETED IN <3 SECONDS");
// //
// //       _scheduleHeavyOperations(clockOutTime, finalDistance);
// //     } catch (e) {
// //       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
// //
// //       DateTime endTime = DateTime.now();
// //       Duration elapsedTime = endTime.difference(startTime);
// //
// //       if (elapsedTime.inSeconds < 3) {
// //         int remainingSeconds = 3 - elapsedTime.inSeconds;
// //         await Future.delayed(Duration(seconds: remainingSeconds));
// //       }
// //
// //       if (loadingTimer != null) loadingTimer.cancel();
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         'Clock Out Complete',
// //         'Data saved locally',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //         duration: Duration(seconds: 2),
// //       );
// //     }
// //   }
// //
// //   Future<void> _handleClockIn(BuildContext context) async {
// //     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
// //
// //     // ✅ CLEAR FROZEN STATE ON NEW CLOCK IN
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove(KEY_IS_TIMER_FROZEN);
// //     await prefs.remove(KEY_FROZEN_DISPLAY_TIME);
// //     _localElapsedTime = '00:00:00';
// //
// //     bool hasPermission = await _checkLocationPermission(context);
// //     if (!hasPermission) {
// //       debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
// //       return;
// //     }
// //
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
// //       builder: (_) =>
// //           AlertDialog(
// //             backgroundColor: Colors.white,
// //             content: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 CircularProgressIndicator(color: Colors.green),
// //                 SizedBox(height: 15),
// //                 Text('Checking permissions...',
// //                     style: TextStyle(fontWeight: FontWeight.w500)),
// //               ],
// //             ),
// //           ),
// //     );
// //
// //     try {
// //       LocationService locationService = LocationService();
// //       await locationService.init();
// //       await locationService.listenLocation();
// //
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       final downloadDirectory = await getDownloadsDirectory();
// //       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
// //       File file = File(filePath);
// //
// //       if (!file.existsSync()) {
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
// //       double initialDistance = locationService.getCurrentDistance();
// //       if (initialDistance > 0.001) {
// //         locationService.resetDistance();
// //         initialDistance = 0.0;
// //       }
// //
// //       await attendanceViewModel.saveFormAttendanceIn();
// //       _startBackgroundServices();
// //
// //       locationViewModel.isClockedIn.value = true;
// //       attendanceViewModel.isClockedIn.value = true;
// //
// //       await prefs.setBool('isClockedIn', true);
// //       await prefs.setString('currentGpxFilePath', filePath);
// //       await prefs.setString(
// //           'currentSessionStart', DateTime.now().toIso8601String());
// //
// //       _isRiveAnimationActive = true;
// //       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
// //         _themeMenuIcon[0].riveIcon.status!.value = true;
// //       }
// //
// //       _startLocalBackupTimer();
// //       _startLocationMonitoring();
// //       _scheduleMidnightClockOut();
// //
// //       travelTimeViewModel.startTracking();
// //       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
// //
// //       await _updateCurrentDistance();
// //       await DailyWorkTimeManager.recordClockIn(DateTime.now());
// //
// //       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
// //
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         '✅ Clocked In Successfully',
// //         'GPS tracking started',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //         duration: const Duration(seconds: 3),
// //         icon: Icon(Icons.check_circle, color: Colors.white),
// //       );
// //     } catch (e) {
// //       debugPrint("❌ [CLOCK-IN] Error: $e");
// //
// //       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
// //
// //       Get.snackbar(
// //         'Error',
// //         'Failed to clock in: ${e.toString()}',
// //         snackPosition: SnackPosition.TOP,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //       );
// //     }
// //   }
// //
// //   void _startLocationMonitoring() {
// //     _wasLocationAvailable = true;
// //     _autoClockOutInProgress = false;
// //
// //     _locationMonitorTimer =
// //         Timer.periodic(const Duration(seconds: 3), (timer) async {
// //           // ✅ Check if frozen
// //           SharedPreferences prefs = await SharedPreferences.getInstance();
// //           bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
// //           if (isFrozen) {
// //             timer.cancel();
// //             return;
// //           }
// //
// //           if (!attendanceViewModel.isClockedIn.value) {
// //             _stopLocationMonitoring();
// //             return;
// //           }
// //
// //           bool currentLocationAvailable = await attendanceViewModel
// //               .isLocationAvailable();
// //
// //           if (_wasLocationAvailable && !currentLocationAvailable) {
// //             debugPrint("📍 [LOCATION] Location OFF - URGENT auto clock-out");
// //
// //             DateTime eventTime = DateTime.now();
// //             double currentDist = await _getCurrentDistance();
// //             double lat = locationViewModel.globalLatitude1.value;
// //             double lng = locationViewModel.globalLongitude1.value;
// //
// //             await _saveCriticalEventData(
// //               eventTime: eventTime,
// //               reason: 'location_off_auto',
// //               distance: currentDist,
// //               latitude: lat,
// //               longitude: lng,
// //             );
// //
// //             await _showUrgentNotification(
// //               title: '⚠️ LOCATION TURNED OFF',
// //               body: 'Auto clockout triggered immediately because location was turned off',
// //               payload: 'location_off_auto',
// //             );
// //
// //             await _handleAutoClockOut(
// //               reason: 'location_off_auto',
// //               context: context,
// //               eventTime: eventTime,
// //             );
// //             return;
// //           }
// //           _wasLocationAvailable = currentLocationAvailable;
// //
// //           bool currentPermissionGranted = await _checkPermissionStatus();
// //
// //           if (_wasPermissionGranted && !currentPermissionGranted) {
// //             debugPrint("🔐 [PERMISSION] Permission REVOKED - URGENT auto clock-out");
// //
// //             DateTime eventTime = DateTime.now();
// //             double currentDist = await _getCurrentDistance();
// //             double lat = locationViewModel.globalLatitude1.value;
// //             double lng = locationViewModel.globalLongitude1.value;
// //
// //             await _saveCriticalEventData(
// //               eventTime: eventTime,
// //               reason: 'permission_revoked_auto',
// //               distance: currentDist,
// //               latitude: lat,
// //               longitude: lng,
// //             );
// //
// //             await _showUrgentNotification(
// //               title: '⚠️ PERMISSION REVOKED',
// //               body: 'Auto clockout triggered immediately because location permission was removed',
// //               payload: 'permission_revoked_auto',
// //             );
// //
// //             await _handleAutoClockOut(
// //               reason: 'permission_revoked_auto',
// //               context: context,
// //               eventTime: eventTime,
// //             );
// //           }
// //           _wasPermissionGranted = currentPermissionGranted;
// //         });
// //   }
// //
// //   void _startBackgroundServices() async {
// //     try {
// //       debugPrint("🛰 [BACKGROUND] Starting services...");
// //
// //       final service = FlutterBackgroundService();
// //       await location.enableBackgroundMode(enable: true);
// //
// //       initializeServiceLocation().catchError((e) =>
// //           debugPrint("Service init error: $e"));
// //       service.startService().catchError((e) =>
// //           debugPrint("Service start error: $e"));
// //       location.changeSettings(
// //           interval: 300, accuracy: loc.LocationAccuracy.high)
// //           .catchError((e) => debugPrint("Location settings error: $e"));
// //
// //       debugPrint("✅ [BACKGROUND] Services started");
// //     } catch (e) {
// //       debugPrint("⚠ [BACKGROUND] Services error: $e");
// //     }
// //   }
// //
// //   void _stopLocationMonitoring() {
// //     _locationMonitorTimer?.cancel();
// //     _locationMonitorTimer = null;
// //     _autoClockOutInProgress = false;
// //   }
// //
// //   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
// //     debugPrint("🔄 Scheduling background operations...");
// //
// //     Timer(Duration(seconds: 5), () async {
// //       try {
// //         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
// //
// //         await locationViewModel.consolidateDailyGPXData();
// //         await locationViewModel.saveLocationFromConsolidatedFile();
// //
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //         await prefs.setDouble('fullClockOutDistance', distance);
// //         await prefs.setString(
// //             'fullClockOutTime', clockOutTime.toIso8601String());
// //         await prefs.setDouble(
// //             'pendingLatOut', locationViewModel.globalLatitude1.value);
// //         await prefs.setDouble(
// //             'pendingLngOut', locationViewModel.globalLongitude1.value);
// //         await prefs.setString(
// //             'pendingAddress', locationViewModel.shopAddress.value);
// //
// //         debugPrint("✅ [BACKGROUND] Heavy operations completed");
// //
// //         _triggerPostClockOutSync();
// //       } catch (e) {
// //         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
// //       }
// //     });
// //   }
// //
// //   void _triggerPostClockOutSync() async {
// //     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
// //
// //     try {
// //       var results = await _connectivity.checkConnectivity();
// //       bool isOnline = results.isNotEmpty &&
// //           results.any((result) => result != ConnectivityResult.none);
// //
// //       if (isOnline && !_isSyncing) {
// //         _isSyncing = true;
// //
// //         await updateFunctionViewModel.syncAllLocalDataToServer();
// //
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('hasPendingClockOutData', false);
// //         await prefs.setBool('clockOutPending', false);
// //         await prefs.setBool('hasFastClockOutData', false);
// //
// //         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
// //
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           Get.snackbar(
// //             'Sync Complete',
// //             'All data synchronized to server',
// //             snackPosition: SnackPosition.BOTTOM,
// //             backgroundColor: Colors.green,
// //             colorText: Colors.white,
// //             duration: const Duration(seconds: 2),
// //           );
// //         });
// //       } else {
// //         debugPrint(
// //             "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
// //
// //         SharedPreferences prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('clockOutPending', true);
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
// //
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('clockOutPending', true);
// //     } finally {
// //       _isSyncing = false;
// //     }
// //   }
// // }
//
// ///adeed 26-02-2026 event time
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../Databases/util.dart';
// import '../../LocatioPoints/ravelTimeViewModel.dart';
// import '../../Tracker/location00.dart';
// import '../../Tracker/trac.dart';
// import '../../Utils/daily_work_time_manager.dart';
// import '../../main.dart';
// import 'assets.dart';
// import 'menu_item.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
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
//   final TravelTimeViewModel travelTimeViewModel = Get.put(TravelTimeViewModel());
//
//   final loc.Location location = loc.Location();
//   final Connectivity _connectivity = Connectivity();
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//   final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
//   Timer? _locationMonitorTimer;
//   bool _wasLocationAvailable = true;
//   bool _autoClockOutInProgress = false;
//
//   Timer? _midnightClockOutTimer;
//   Timer? _permissionCheckTimer;
//   bool _isMidnightClockOutScheduled = false;
//
//   bool _isRiveAnimationActive = false;
//   Timer? _localBackupTimer;
//   DateTime? _localClockInTime;
//   String _localElapsedTime = '00:00:00';
//
//   // Auto-sync variables
//   Timer? _autoSyncTimer;
//   bool _isOnline = false;
//   bool _isSyncing = false;
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//
//   // Distance tracking
//   double _currentDistance = 0.0;
//   Timer? _distanceUpdateTimer;
//
//   // Permission monitoring
//   bool _wasPermissionGranted = true;
//
//   // Notification IDs
//   int _notificationId = 0;
//
//   // Method Channel for Native Service
//   static const platform = MethodChannel('com.metaxperts.order_booking_app/location_monitor');
//
//   // ✅ CRITICAL EVENT TIMESTAMP KEYS
//   static const String KEY_EVENT_TIMESTAMP = 'critical_event_timestamp';
//   static const String KEY_EVENT_REASON = 'critical_event_reason';
//   static const String KEY_EVENT_DISTANCE = 'critical_event_distance';
//   static const String KEY_HAS_CRITICAL_EVENT = 'has_critical_event_pending';
//   static const String KEY_EVENT_LATITUDE = 'critical_event_latitude';
//   static const String KEY_EVENT_LONGITUDE = 'critical_event_longitude';
//
//   // ✅ NEW: Keys to freeze timer at event time
//   static const String KEY_EVENT_ELAPSED_TIME = 'critical_event_elapsed_time';
//   static const String KEY_IS_TIMER_FROZEN = 'is_timer_frozen';
//   static const String KEY_FROZEN_DISPLAY_TIME = 'frozen_display_time';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _initializeUrgentNotifications();
//     _initializeFromPersistentState();
//     _startAutoSyncMonitoring();
//     _startDistanceUpdater();
//     _scheduleMidnightClockOut();
//
//     // ✅ START NATIVE MONITORING SERVICE
//     _startNativeMonitoringService();
//
//     // ✅ CHECK FOR CRITICAL EVENTS ON STARTUP
//     _checkAndProcessCriticalEvent();
//   }
//
//   // ✅ START NATIVE MONITORING SERVICE
//   Future<void> _startNativeMonitoringService() async {
//     try {
//       if (Platform.isAndroid) {
//         final bool result = await platform.invokeMethod('startMonitoring');
//         debugPrint("✅ [NATIVE SERVICE] Started: $result");
//       }
//     } catch (e) {
//       debugPrint("❌ [NATIVE SERVICE] Error starting: $e");
//     }
//   }
//
//   // ✅ STOP NATIVE MONITORING SERVICE
//   Future<void> _stopNativeMonitoringService() async {
//     try {
//       if (Platform.isAndroid) {
//         final bool result = await platform.invokeMethod('stopMonitoring');
//         debugPrint("🛑 [NATIVE SERVICE] Stopped: $result");
//       }
//     } catch (e) {
//       debugPrint("❌ [NATIVE SERVICE] Error stopping: $e");
//     }
//   }
//
//   // ✅ CHECK AND PROCESS CRITICAL EVENT ON APP START
//   Future<void> _checkAndProcessCriticalEvent() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasCriticalEvent = prefs.getBool(KEY_HAS_CRITICAL_EVENT) ?? false;
//     bool isTimerFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//
//     if (hasCriticalEvent || isTimerFrozen) {
//       debugPrint("🚨 [CRITICAL EVENT] Found pending critical event on startup");
//
//       String? eventTimeStr = prefs.getString(KEY_EVENT_TIMESTAMP);
//       String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
//       String? eventReason = prefs.getString(KEY_EVENT_REASON);
//       double? eventDistance = prefs.getDouble(KEY_EVENT_DISTANCE);
//       double? eventLat = prefs.getDouble(KEY_EVENT_LATITUDE);
//       double? eventLng = prefs.getDouble(KEY_EVENT_LONGITUDE);
//
//       if (eventTimeStr != null) {
//         DateTime eventTime = DateTime.parse(eventTimeStr);
//
//         debugPrint("🚨 [CRITICAL EVENT] Event occurred at: $eventTime");
//         debugPrint("🚨 [CRITICAL EVENT] Frozen elapsed time: $frozenTime");
//         debugPrint("🚨 [CRITICAL EVENT] Reason: $eventReason");
//
//         // ✅ SET THE FROZEN TIME TO DISPLAY (don't calculate new time)
//         if (frozenTime != null) {
//           _localElapsedTime = frozenTime;
//           attendanceViewModel.elapsedTime.value = frozenTime;
//
//           // ✅ IMPORTANT: Stop any running timer and keep the frozen state
//           _localBackupTimer?.cancel();
//           _localBackupTimer = null;
//         }
//
//         // Update UI to show frozen state
//         if (mounted) {
//           setState(() {});
//         }
//
//         // Show notification about the event
//         Get.snackbar(
//           '⚠️ Auto Clock-Out Occurred',
//           'Event: ${_getReasonMessage(eventReason ?? 'unknown')}\nTime: ${DateFormat('HH:mm:ss').format(eventTime)}\nDuration: $frozenTime',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 5),
//           icon: const Icon(Icons.warning, color: Colors.white),
//         );
//
//         // Sync the data with the original timestamp
//         await _syncCriticalEventData(
//           eventTime: eventTime,
//           reason: eventReason ?? 'unknown',
//           distance: eventDistance ?? 0.0,
//           latitude: eventLat ?? 0.0,
//           longitude: eventLng ?? 0.0,
//         );
//
//         // Clear critical event flags after processing but keep frozen time
//         await _clearCriticalEventData();
//       }
//     }
//   }
//
//   // ✅ SYNC CRITICAL EVENT DATA TO SERVER
//   Future<void> _syncCriticalEventData({
//     required DateTime eventTime,
//     required String reason,
//     required double distance,
//     required double latitude,
//     required double longitude,
//   }) async {
//     try {
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: eventTime,
//         totalDistance: distance,
//         isAuto: true,
//         reason: reason,
//       );
//
//       debugPrint("✅ [SYNC] Critical event data synced with timestamp: $eventTime");
//
//       _triggerAutoSync();
//
//     } catch (e) {
//       debugPrint("❌ [SYNC] Error syncing critical event: $e");
//     }
//   }
//
//   // ✅ CLEAR CRITICAL EVENT DATA (but keep frozen time visible)
//   Future<void> _clearCriticalEventData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(KEY_HAS_CRITICAL_EVENT);
//     await prefs.remove(KEY_EVENT_TIMESTAMP);
//     await prefs.remove(KEY_EVENT_REASON);
//     await prefs.remove(KEY_EVENT_DISTANCE);
//     await prefs.remove(KEY_EVENT_LATITUDE);
//     await prefs.remove(KEY_EVENT_LONGITUDE);
//     // ✅ DON'T remove KEY_FROZEN_DISPLAY_TIME and KEY_IS_TIMER_FROZEN yet
//     // Keep them so timer stays frozen until manual clock in next day
//     debugPrint("🧹 [CLEAR] Critical event data cleared (timer remains frozen)");
//   }
//
//   // ✅ SAVE CRITICAL EVENT DATA (Called when event happens in-app)
//   Future<void> _saveCriticalEventData({
//     required DateTime eventTime,
//     required String reason,
//     required double distance,
//     required double latitude,
//     required double longitude,
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // ✅ CAPTURE CURRENT ELAPSED TIME BEFORE STOPPING TIMER
//     String frozenElapsedTime = _localElapsedTime;
//
//     await prefs.setBool(KEY_HAS_CRITICAL_EVENT, true);
//     await prefs.setBool(KEY_IS_TIMER_FROZEN, true);
//     await prefs.setString(KEY_EVENT_TIMESTAMP, eventTime.toIso8601String());
//     await prefs.setString(KEY_EVENT_REASON, reason);
//     await prefs.setDouble(KEY_EVENT_DISTANCE, distance);
//     await prefs.setDouble(KEY_EVENT_LATITUDE, latitude);
//     await prefs.setDouble(KEY_EVENT_LONGITUDE, longitude);
//     await prefs.setString(KEY_FROZEN_DISPLAY_TIME, frozenElapsedTime); // ✅ Save frozen time
//
//     debugPrint("💾 [SAVE] Critical event saved at: $eventTime");
//     debugPrint("💾 [SAVE] Frozen elapsed time: $frozenElapsedTime");
//     debugPrint("💾 [SAVE] Reason: $reason");
//     debugPrint("💾 [SAVE] Distance: $distance");
//   }
//
//   // ✅ URGENT NOTIFICATION SETUP (IMMEDIATE)
//   Future<void> _initializeUrgentNotifications() async {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
//       'urgent_auto_clockout_channel',
//       'URGENT Auto Clockout Notifications',
//       description: 'High-priority channel for urgent auto clockout notifications',
//       importance: Importance.max,
//       enableVibration: true,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('notification_sound'),
//       enableLights: true,
//       ledColor: Colors.red,
//     );
//
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosSettings =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         debugPrint('Notification tapped: ${response.payload}');
//       },
//     );
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(urgentChannel);
//   }
//
//   // ✅ SHOW URGENT NOTIFICATION METHOD (IMMEDIATE)
//   Future<void> _showUrgentNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     _notificationId++;
//
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'urgent_auto_clockout_channel',
//       'URGENT Auto Clockout Notifications',
//       channelDescription: 'High-priority channel for urgent auto clockout notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//       timeoutAfter: 5000,
//       category: AndroidNotificationCategory.alarm,
//       visibility: NotificationVisibility.public,
//       color: Colors.red,
//       ledColor: Colors.red,
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       fullScreenIntent: true,
//       ongoing: false,
//       autoCancel: true,
//       styleInformation: BigTextStyleInformation(''),
//     );
//
//     const DarwinNotificationDetails iosDetails =
//     DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: 'default',
//       interruptionLevel: InterruptionLevel.timeSensitive,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       _notificationId,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//
//     debugPrint("🔔 [URGENT NOTIFICATION] Sent: $title");
//
//     if (mounted) {
//       Get.snackbar(
//         title,
//         body,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//         icon: const Icon(Icons.warning, color: Colors.white),
//         shouldIconPulse: true,
//         barBlur: 10,
//         isDismissible: true,
//       );
//     }
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
//     _midnightClockOutTimer?.cancel();
//     _permissionCheckTimer?.cancel();
//     // Don't stop native service here - it should keep running
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
//       _rescheduleMidnightClockOut();
//       _checkAndProcessCriticalEvent(); // ✅ Check for critical events on resume
//
//       // ✅ Restart native service if needed
//       _startNativeMonitoringService();
//     } else if (state == AppLifecycleState.paused) {
//       // ✅ Native service keeps running in background
//       debugPrint("✅ [LIFECYCLE] App paused - Native service continues monitoring");
//     }
//   }
//
//   // ✅ SCHEDULE MIDNIGHT AUTO CLOCKOUT (11:58 PM)
//   void _scheduleMidnightClockOut() {
//     // ✅ DON'T schedule if timer is frozen (critical event already happened)
//     SharedPreferences.getInstance().then((prefs) {
//       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//       if (isFrozen) {
//         debugPrint("⏰ [MIDNIGHT] Timer is frozen, not scheduling midnight clockout");
//         return;
//       }
//
//       if (!attendanceViewModel.isClockedIn.value) {
//         return;
//       }
//
//       _midnightClockOutTimer?.cancel();
//
//       final now = DateTime.now();
//       final scheduledTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         23,
//         58,
//       );
//
//       Duration timeUntilMidnight;
//       if (now.isAfter(scheduledTime)) {
//         final tomorrow = scheduledTime.add(const Duration(days: 1));
//         timeUntilMidnight = tomorrow.difference(now);
//       } else {
//         timeUntilMidnight = scheduledTime.difference(now);
//       }
//
//       _midnightClockOutTimer = Timer(timeUntilMidnight, () async {
//         if (attendanceViewModel.isClockedIn.value) {
//           debugPrint("⏰ [MIDNIGHT] Auto clockout triggered at 11:58 PM");
//
//           DateTime eventTime = DateTime.now();
//           double currentDist = await _getCurrentDistance();
//           double lat = locationViewModel.globalLatitude1.value;
//           double lng = locationViewModel.globalLongitude1.value;
//
//           // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
//           await _saveCriticalEventData(
//             eventTime: eventTime,
//             reason: 'midnight_auto',
//             distance: currentDist,
//             latitude: lat,
//             longitude: lng,
//           );
//
//           await _showUrgentNotification(
//             title: '⚠️ AUTO CLOCKOUT - 11:58 PM',
//             body: 'You have been automatically clocked out at 11:58 PM',
//             payload: 'midnight_auto',
//           );
//
//           await _handleAutoClockOut(
//             reason: 'midnight_auto',
//             context: context,
//             eventTime: eventTime,
//           );
//         }
//       });
//
//       _isMidnightClockOutScheduled = true;
//       debugPrint("⏰ [MIDNIGHT] Auto clockout scheduled for ${scheduledTime.hour}:${scheduledTime.minute}");
//     });
//   }
//
//   void _rescheduleMidnightClockOut() {
//     SharedPreferences.getInstance().then((prefs) {
//       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//       if (!isFrozen && attendanceViewModel.isClockedIn.value) {
//         _scheduleMidnightClockOut();
//       }
//     });
//   }
//
//   // ✅ START PERMISSION MONITORING (FASTER CHECK) - In-app backup
//   void _startPermissionMonitoring() {
//     _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       // ✅ Check if timer is frozen first
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//       if (isFrozen) {
//         debugPrint("🔒 [MONITOR] Timer is frozen, stopping monitoring");
//         timer.cancel();
//         return;
//       }
//
//       if (!attendanceViewModel.isClockedIn.value) {
//         return;
//       }
//
//       // Check location services
//       bool locationEnabled = await attendanceViewModel.isLocationAvailable();
//       if (_wasLocationAvailable && !locationEnabled) {
//         debugPrint("📍 [LOCATION] Location turned OFF - URGENT auto clockout");
//
//         DateTime eventTime = DateTime.now();
//         double currentDist = await _getCurrentDistance();
//         double lat = locationViewModel.globalLatitude1.value;
//         double lng = locationViewModel.globalLongitude1.value;
//
//         // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
//         await _saveCriticalEventData(
//           eventTime: eventTime,
//           reason: 'location_off_auto',
//           distance: currentDist,
//           latitude: lat,
//           longitude: lng,
//         );
//
//         await _showUrgentNotification(
//           title: '⚠️ LOCATION TURNED OFF',
//           body: 'Auto clockout triggered immediately because location was turned off',
//           payload: 'location_off_auto',
//         );
//
//         await _handleAutoClockOut(
//           reason: 'location_off_auto',
//           context: context,
//           eventTime: eventTime,
//         );
//         return;
//       }
//       _wasLocationAvailable = locationEnabled;
//
//       // Check location permissions
//       bool permissionGranted = await _checkPermissionStatus();
//       if (_wasPermissionGranted && !permissionGranted) {
//         debugPrint("🔐 [PERMISSION] Location permission revoked - URGENT auto clockout");
//
//         DateTime eventTime = DateTime.now();
//         double currentDist = await _getCurrentDistance();
//         double lat = locationViewModel.globalLatitude1.value;
//         double lng = locationViewModel.globalLongitude1.value;
//
//         // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
//         await _saveCriticalEventData(
//           eventTime: eventTime,
//           reason: 'permission_revoked_auto',
//           distance: currentDist,
//           latitude: lat,
//           longitude: lng,
//         );
//
//         await _showUrgentNotification(
//           title: '⚠️ PERMISSION REVOKED',
//           body: 'Auto clockout triggered immediately because location permission was removed',
//           payload: 'permission_revoked_auto',
//         );
//
//         await _handleAutoClockOut(
//           reason: 'permission_revoked_auto',
//           context: context,
//           eventTime: eventTime,
//         );
//         return;
//       }
//       _wasPermissionGranted = permissionGranted;
//     });
//   }
//
//   Future<bool> _checkPermissionStatus() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     return permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse;
//   }
//
//   Future<bool> _checkLocationPermission(BuildContext context) async {
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.location_off,
//                   size: 50,
//                   color: Colors.redAccent,
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Location Permission Required",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "We need location access to continue.\n"
//                       "Please enable location permission from app settings.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () => Navigator.of(ctx).pop(),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () async {
//                           Navigator.of(ctx).pop();
//                           await Geolocator.openAppSettings();
//                         },
//                         child: const Text(
//                           "Open Settings",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   // ✅ HANDLE AUTO CLOCKOUT (Modified to accept eventTime)
//   Future<void> _handleAutoClockOut({
//     required String reason,
//     required BuildContext context,
//     DateTime? eventTime,
//   }) async {
//     if (_autoClockOutInProgress || !attendanceViewModel.isClockedIn.value) {
//       return;
//     }
//     _autoClockOutInProgress = true;
//
//     DateTime clockOutTime = eventTime ?? DateTime.now();
//
//     debugPrint("⚡ [AUTO CLOCKOUT] Triggered for reason: $reason");
//     debugPrint("⚡ [AUTO CLOCKOUT] Using timestamp: $clockOutTime");
//
//     try {
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel(); // ✅ Stop the timer immediately
//       _midnightClockOutTimer?.cancel();
//
//       double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//       await prefs.setString('fastClockOutReason', reason);
//
//       // ✅ DON'T reset _localElapsedTime - keep the frozen value
//       // ✅ DON'T reset _localClockInTime - we need it for reference
//
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//
//       _isRiveAnimationActive = false;
//       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       // Save attendance out with the EXACT event time
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//         isAuto: true,
//         reason: reason,
//       );
//
//       await DailyWorkTimeManager.recordClockOut(clockOutTime);
//
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       // ✅ STOP NATIVE MONITORING
//       await _stopNativeMonitoringService();
//
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       debugPrint("✅ [AUTO CLOCKOUT] Completed for reason: $reason at $clockOutTime");
//       debugPrint("✅ [AUTO CLOCKOUT] Frozen elapsed time: $_localElapsedTime");
//
//     } catch (e) {
//       debugPrint("❌ [AUTO CLOCKOUT] Error: $e");
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//     } finally {
//       _autoClockOutInProgress = false;
//     }
//   }
//
//   String _getReasonMessage(String reason) {
//     switch (reason) {
//       case 'midnight_auto':
//         return 'You have been automatically clocked out at 11:58 PM';
//       case 'location_off_auto':
//         return 'Auto clockout because location services were turned off';
//       case 'permission_revoked_auto':
//         return 'Auto clockout because location permission was removed';
//       default:
//         return 'Auto clockout completed successfully';
//     }
//   }
//
//   void _checkAndSyncPendingData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
//     bool clockOutPending = prefs.getBool('clockOutPending') ?? false;
//
//     if (hasPendingClockOut || clockOutPending) {
//       debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
//       _triggerAutoSync();
//     }
//   }
//
//   void _startDistanceUpdater() {
//     _distanceUpdateTimer =
//         Timer.periodic(const Duration(seconds: 5), (timer) async {
//           // ✅ Check if timer is frozen
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//
//           if (isFrozen) {
//             timer.cancel();
//             return;
//           }
//
//           if (attendanceViewModel.isClockedIn.value) {
//             await _updateCurrentDistance();
//           }
//         });
//   }
//
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
//   void _startAutoSyncMonitoring() async {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
//         List<ConnectivityResult> results) {
//       bool wasOnline = _isOnline;
//       _isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'}");
//
//       if (_isOnline && !wasOnline && !_isSyncing) {
//         debugPrint("🔄 [AUTO-SYNC] Internet connected - triggering auto-sync");
//         _triggerAutoSync();
//       }
//     });
//
//     _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
//       if (!_isSyncing) {
//         _checkConnectivityAndSync();
//       }
//     });
//
//     _checkConnectivityAndSync();
//   }
//
//   void _checkConnectivityAndSync() async {
//     if (_isSyncing) {
//       debugPrint('⏸️ Sync already in progress - skipping');
//       return;
//     }
//
//     try {
//       var results = await _connectivity.checkConnectivity();
//       bool wasOnline = _isOnline;
//       _isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
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
//   void _triggerAutoSync() async {
//     if (_isSyncing) {
//       debugPrint('⏸️ Auto-sync already in progress - skipping');
//       return;
//     }
//
//     _isSyncing = true;
//     debugPrint('🔒 [AUTO-SYNC LOCKED] Starting automatic data sync...');
//
//     try {
//       Get.snackbar(
//         'Syncing Data',
//         'Auto-syncing offline data...',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.blue.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//
//       await updateFunctionViewModel.syncAllLocalDataToServer();
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('hasPendingClockOutData', false);
//       await prefs.setBool('clockOutPending', false);
//       await prefs.setBool('hasFastClockOutData', false);
//
//       debugPrint('✅ [AUTO-SYNC COMPLETED] Automatic sync completed');
//     } catch (e) {
//       debugPrint('❌ [AUTO-SYNC FAILED] Error during auto-sync: $e');
//     } finally {
//       _isSyncing = false;
//       debugPrint('🔓 [AUTO-SYNC UNLOCKED] Sync completed or failed');
//     }
//   }
//
//   void _restoreEverything() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
//     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
//
//     // ✅ If timer is frozen, don't restore clocked-in state
//     if (isFrozen && frozenTime != null) {
//       debugPrint("🔒 [RESTORE] Timer is frozen at $frozenTime, not restoring clocked-in state");
//
//       _localElapsedTime = frozenTime;
//       attendanceViewModel.elapsedTime.value = frozenTime;
//
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       _isRiveAnimationActive = false;
//
//       if (mounted) {
//         setState(() {});
//       }
//       return;
//     }
//
//     if (isClockedIn) {
//       debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");
//
//       locationViewModel.isClockedIn.value = true;
//       attendanceViewModel.isClockedIn.value = true;
//
//       _isRiveAnimationActive = true;
//       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = true;
//       }
//
//       _startLocalBackupTimer();
//       _scheduleMidnightClockOut();
//       _startPermissionMonitoring();
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
//
//     // ✅ Check if timer is frozen before starting
//     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//     if (isFrozen) {
//       debugPrint("🔒 [BACKUP TIMER] Timer is frozen, not starting backup timer");
//       return;
//     }
//
//     String? clockInTimeString = prefs.getString('clockInTime');
//
//     if (clockInTimeString == null) return;
//
//     _localClockInTime = DateTime.parse(clockInTimeString);
//     _localBackupTimer?.cancel();
//
//     _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       // ✅ Check if frozen during timer execution
//       SharedPreferences.getInstance().then((prefs) {
//         bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//         if (isFrozen) {
//           timer.cancel();
//           debugPrint("🔒 [BACKUP TIMER] Frozen state detected, stopping timer");
//           return;
//         }
//       });
//
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
//       // ✅ SAVE ELAPSED TIME TO PREFERENCES (for native service to read)
//       SharedPreferences.getInstance().then((prefs) {
//         prefs.setString('elapsed_time', _localElapsedTime);
//       });
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
//     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
//
//     debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn, isFrozen = $isFrozen");
//
//     // ✅ Handle frozen state first
//     if (isFrozen && frozenTime != null) {
//       debugPrint("🔒 [INIT] Timer is frozen at: $frozenTime");
//
//       _localElapsedTime = frozenTime;
//       attendanceViewModel.elapsedTime.value = frozenTime;
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       _isRiveAnimationActive = false;
//
//       if (mounted) {
//         setState(() {});
//       }
//       return;
//     }
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
//       _scheduleMidnightClockOut();
//       _startPermissionMonitoring();
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
//     if (_themeMenuIcon.isEmpty) return;
//
//     final controller = StateMachineController.fromArtboard(
//         artboard, _themeMenuIcon[0].riveIcon.stateMachine);
//     if (controller != null) {
//       artboard.addController(controller);
//       _themeMenuIcon[0].riveIcon.status =
//       controller.findInput<bool>("active") as SMIBool?;
//
//       if (_themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
//         debugPrint(
//             "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
//       }
//     } else {
//       debugPrint("StateMachineController not found!");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Obx(() {
//                   // ✅ Check if we should show frozen time
//                   String displayTime = _localElapsedTime;
//
//                   // If we have a frozen time in prefs, use it
//                   SharedPreferences.getInstance().then((prefs) {
//                     bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//                     String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
//                     if (isFrozen && frozenTime != null) {
//                       displayTime = frozenTime;
//                     }
//                   });
//
//                   if (displayTime == '00:00:00' &&
//                       attendanceViewModel.isClockedIn.value) {
//                     displayTime = attendanceViewModel.elapsedTime.value;
//                   }
//
//                   return Text(
//                     displayTime,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: attendanceViewModel.isClockedIn.value
//                           ? Colors.black87
//                           : Colors.grey,
//                     ),
//                   );
//                 }),
//
//                 Obx(() {
//                   if (attendanceViewModel.isClockedIn.value &&
//                       _currentDistance > 0) {
//                     return Text(
//                       '${_currentDistance.toStringAsFixed(2)} km',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.blue.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//             ),
//
//             const SizedBox(height: 5),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Obx(() {
//                   return SizedBox(
//                       width: 120,
//                       height: 30,
//                       child:  ElevatedButton(
//                         onPressed: attendanceViewModel.isClockedIn.value
//                             ? null
//                             : () async => _handleClockIn(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text("Clock In", style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.5,
//                             ))
//                           ],
//                         ),
//                       )
//                   );
//                 }),
//
//                 const SizedBox(width: 5),
//
//                 Obx(() { return SizedBox(
//                     width: 120,
//                     height: 30,
//                     child:  ElevatedButton(
//                       onPressed: attendanceViewModel.isClockedIn.value
//                           ? () async => _handleClockOut(context)
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text("Clock Out", style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5,
//                           ))
//                         ],
//                       ),
//                     )
//                 );
//                 }),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleClockOut(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");
//
//     bool showLoadingDialog = true;
//     DateTime startTime = DateTime.now();
//     Timer? loadingTimer;
//
//     if (showLoadingDialog) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) =>
//             AlertDialog(
//               backgroundColor: Colors.white.withOpacity(0.9),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                   ),
//                   SizedBox(height: 15),
//                   Text(
//                     "Processing clock-out...",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     "Please wait 3 seconds",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//       );
//
//       loadingTimer = Timer(Duration(seconds: 3), () {});
//     }
//
//     try {
//       _stopLocationMonitoring();
//       _localBackupTimer?.cancel();
//       _midnightClockOutTimer?.cancel();
//
//       double finalDistance = _currentDistance;
//       if (finalDistance <= 0) {
//         try {
//           LocationService locationService = LocationService();
//           await locationService.init();
//           finalDistance = locationService.getCurrentDistance();
//           if (finalDistance <= 0) finalDistance = 0.0;
//         } catch (e) {
//           finalDistance = 0.0;
//         }
//       }
//
//       DateTime clockOutTime = DateTime.now();
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       // ✅ CLEAR FROZEN STATE ON MANUAL CLOCK OUT (new day started)
//       await prefs.remove(KEY_IS_TIMER_FROZEN);
//       await prefs.remove(KEY_FROZEN_DISPLAY_TIME);
//
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setDouble('fastClockOutDistance', finalDistance);
//       await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
//       await prefs.setBool('clockOutPending', true);
//       await prefs.setBool('hasFastClockOutData', true);
//
//       locationViewModel.isClockedIn.value = false;
//       attendanceViewModel.isClockedIn.value = false;
//       _isRiveAnimationActive = false;
//
//       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = false;
//       }
//
//       _localElapsedTime = '00:00:00';
//       _localClockInTime = null;
//
//       await attendanceOutViewModel.fastSaveAttendanceOut(
//         clockOutTime: clockOutTime,
//         totalDistance: finalDistance,
//         isAuto: false,
//         reason: 'manual_clockout',
//       );
//
//       await DailyWorkTimeManager.recordClockOut(DateTime.now());
//
//       final service = FlutterBackgroundService();
//       service.invoke("stopService");
//
//       // ✅ STOP NATIVE MONITORING
//       await _stopNativeMonitoringService();
//
//       try {
//         await location.enableBackgroundMode(enable: false);
//       } catch (e) {
//         debugPrint("⚠️ Background mode disable error: $e");
//       }
//
//       DateTime endTime = DateTime.now();
//       Duration elapsedTime = endTime.difference(startTime);
//
//       if (elapsedTime.inSeconds < 3) {
//         int remainingSeconds = 3 - elapsedTime.inSeconds;
//         await Future.delayed(Duration(seconds: remainingSeconds));
//       }
//
//       if (loadingTimer != null) loadingTimer.cancel();
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
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
//       _scheduleHeavyOperations(clockOutTime, finalDistance);
//     } catch (e) {
//       debugPrint("❌ [FAST CLOCK-OUT] Error: $e");
//
//       DateTime endTime = DateTime.now();
//       Duration elapsedTime = endTime.difference(startTime);
//
//       if (elapsedTime.inSeconds < 3) {
//         int remainingSeconds = 3 - elapsedTime.inSeconds;
//         await Future.delayed(Duration(seconds: remainingSeconds));
//       }
//
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
//   Future<void> _handleClockIn(BuildContext context) async {
//     debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");
//
//     // ✅ CLEAR FROZEN STATE ON NEW CLOCK IN
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(KEY_IS_TIMER_FROZEN);
//     await prefs.remove(KEY_FROZEN_DISPLAY_TIME);
//     _localElapsedTime = '00:00:00';
//
//     bool hasPermission = await _checkLocationPermission(context);
//     if (!hasPermission) {
//       debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
//       return;
//     }
//
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
//       builder: (_) =>
//           AlertDialog(
//             backgroundColor: Colors.white,
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(color: Colors.green),
//                 SizedBox(height: 15),
//                 Text('Checking permissions...',
//                     style: TextStyle(fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//     );
//
//     try {
//       LocationService locationService = LocationService();
//       await locationService.init();
//       await locationService.listenLocation();
//
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       final downloadDirectory = await getDownloadsDirectory();
//       final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";
//       File file = File(filePath);
//
//       if (!file.existsSync()) {
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
//       double initialDistance = locationService.getCurrentDistance();
//       if (initialDistance > 0.001) {
//         locationService.resetDistance();
//         initialDistance = 0.0;
//       }
//
//       await attendanceViewModel.saveFormAttendanceIn();
//       _startBackgroundServices();
//
//       locationViewModel.isClockedIn.value = true;
//       attendanceViewModel.isClockedIn.value = true;
//
//       await prefs.setBool('isClockedIn', true);
//       await prefs.setString('currentGpxFilePath', filePath);
//       await prefs.setString(
//           'currentSessionStart', DateTime.now().toIso8601String());
//
//       _isRiveAnimationActive = true;
//       if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
//         _themeMenuIcon[0].riveIcon.status!.value = true;
//       }
//
//       _startLocalBackupTimer();
//       _startLocationMonitoring();
//       _scheduleMidnightClockOut();
//       _startPermissionMonitoring();
//
//       // ✅ START NATIVE MONITORING SERVICE
//       await _startNativeMonitoringService();
//
//       travelTimeViewModel.startTracking();
//       debugPrint("📍 [TRAVEL TIME] Travel tracking started");
//
//       await _updateCurrentDistance();
//       await DailyWorkTimeManager.recordClockIn(DateTime.now());
//
//       debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");
//
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
//       Get.snackbar(
//         '✅ Clocked In Successfully',
//         'GPS tracking started',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//         icon: Icon(Icons.check_circle, color: Colors.white),
//       );
//     } catch (e) {
//       debugPrint("❌ [CLOCK-IN] Error: $e");
//
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//
//       Get.snackbar(
//         'Error',
//         'Failed to clock in: ${e.toString()}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void _startLocationMonitoring() {
//     _wasLocationAvailable = true;
//     _autoClockOutInProgress = false;
//
//     _locationMonitorTimer =
//         Timer.periodic(const Duration(seconds: 3), (timer) async {
//           // ✅ Check if frozen
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
//           if (isFrozen) {
//             timer.cancel();
//             return;
//           }
//
//           if (!attendanceViewModel.isClockedIn.value) {
//             _stopLocationMonitoring();
//             return;
//           }
//
//           bool currentLocationAvailable = await attendanceViewModel
//               .isLocationAvailable();
//
//           if (_wasLocationAvailable && !currentLocationAvailable) {
//             debugPrint("📍 [LOCATION] Location OFF - URGENT auto clock-out");
//
//             DateTime eventTime = DateTime.now();
//             double currentDist = await _getCurrentDistance();
//             double lat = locationViewModel.globalLatitude1.value;
//             double lng = locationViewModel.globalLongitude1.value;
//
//             await _saveCriticalEventData(
//               eventTime: eventTime,
//               reason: 'location_off_auto',
//               distance: currentDist,
//               latitude: lat,
//               longitude: lng,
//             );
//
//             await _showUrgentNotification(
//               title: '⚠️ LOCATION TURNED OFF',
//               body: 'Auto clockout triggered immediately because location was turned off',
//               payload: 'location_off_auto',
//             );
//
//             await _handleAutoClockOut(
//               reason: 'location_off_auto',
//               context: context,
//               eventTime: eventTime,
//             );
//             return;
//           }
//           _wasLocationAvailable = currentLocationAvailable;
//
//           bool currentPermissionGranted = await _checkPermissionStatus();
//
//           if (_wasPermissionGranted && !currentPermissionGranted) {
//             debugPrint("🔐 [PERMISSION] Permission REVOKED - URGENT auto clock-out");
//
//             DateTime eventTime = DateTime.now();
//             double currentDist = await _getCurrentDistance();
//             double lat = locationViewModel.globalLatitude1.value;
//             double lng = locationViewModel.globalLongitude1.value;
//
//             await _saveCriticalEventData(
//               eventTime: eventTime,
//               reason: 'permission_revoked_auto',
//               distance: currentDist,
//               latitude: lat,
//               longitude: lng,
//             );
//
//             await _showUrgentNotification(
//               title: '⚠️ PERMISSION REVOKED',
//               body: 'Auto clockout triggered immediately because location permission was removed',
//               payload: 'permission_revoked_auto',
//             );
//
//             await _handleAutoClockOut(
//               reason: 'permission_revoked_auto',
//               context: context,
//               eventTime: eventTime,
//             );
//           }
//           _wasPermissionGranted = currentPermissionGranted;
//         });
//   }
//
//   void _startBackgroundServices() async {
//     try {
//       debugPrint("🛰 [BACKGROUND] Starting services...");
//
//       final service = FlutterBackgroundService();
//       await location.enableBackgroundMode(enable: true);
//
//       initializeServiceLocation().catchError((e) =>
//           debugPrint("Service init error: $e"));
//       service.startService().catchError((e) =>
//           debugPrint("Service start error: $e"));
//       location.changeSettings(
//           interval: 300, accuracy: loc.LocationAccuracy.high)
//           .catchError((e) => debugPrint("Location settings error: $e"));
//
//       debugPrint("✅ [BACKGROUND] Services started");
//     } catch (e) {
//       debugPrint("⚠ [BACKGROUND] Services error: $e");
//     }
//   }
//
//   void _stopLocationMonitoring() {
//     _locationMonitorTimer?.cancel();
//     _locationMonitorTimer = null;
//     _autoClockOutInProgress = false;
//   }
//
//   void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
//     debugPrint("🔄 Scheduling background operations...");
//
//     Timer(Duration(seconds: 5), () async {
//       try {
//         debugPrint("🔄 [BACKGROUND] Starting heavy operations...");
//
//         await locationViewModel.consolidateDailyGPXData();
//         await locationViewModel.saveLocationFromConsolidatedFile();
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         await prefs.setDouble('fullClockOutDistance', distance);
//         await prefs.setString(
//             'fullClockOutTime', clockOutTime.toIso8601String());
//         await prefs.setDouble(
//             'pendingLatOut', locationViewModel.globalLatitude1.value);
//         await prefs.setDouble(
//             'pendingLngOut', locationViewModel.globalLongitude1.value);
//         await prefs.setString(
//             'pendingAddress', locationViewModel.shopAddress.value);
//
//         debugPrint("✅ [BACKGROUND] Heavy operations completed");
//
//         _triggerPostClockOutSync();
//       } catch (e) {
//         debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
//       }
//     });
//   }
//
//   void _triggerPostClockOutSync() async {
//     debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");
//
//     try {
//       var results = await _connectivity.checkConnectivity();
//       bool isOnline = results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//
//       if (isOnline && !_isSyncing) {
//         _isSyncing = true;
//
//         await updateFunctionViewModel.syncAllLocalDataToServer();
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('hasPendingClockOutData', false);
//         await prefs.setBool('clockOutPending', false);
//         await prefs.setBool('hasFastClockOutData', false);
//
//         debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");
//
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
//         debugPrint(
//             "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('clockOutPending', true);
//       }
//     } catch (e) {
//       debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('clockOutPending', true);
//     } finally {
//       _isSyncing = false;
//     }
//   }
// }


///added 26-0202026 evetn time for 11:58
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../Databases/util.dart';
import '../../LocatioPoints/ravelTimeViewModel.dart';
import '../../Tracker/location00.dart';
import '../../Tracker/trac.dart';
import '../../Utils/daily_work_time_manager.dart';
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
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  Timer? _locationMonitorTimer;
  bool _wasLocationAvailable = true;
  bool _autoClockOutInProgress = false;

  Timer? _midnightClockOutTimer;
  Timer? _permissionCheckTimer;
  bool _isMidnightClockOutScheduled = false;

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

  // Permission monitoring
  bool _wasPermissionGranted = true;

  // Notification IDs
  int _notificationId = 0;

  // Method Channel for Native Service
  static const platform = MethodChannel('com.metaxperts.order_booking_app/location_monitor');

  // ✅ CRITICAL EVENT TIMESTAMP KEYS
  static const String KEY_EVENT_TIMESTAMP = 'critical_event_timestamp';
  static const String KEY_EVENT_REASON = 'critical_event_reason';
  static const String KEY_EVENT_DISTANCE = 'critical_event_distance';
  static const String KEY_HAS_CRITICAL_EVENT = 'has_critical_event_pending';
  static const String KEY_EVENT_LATITUDE = 'critical_event_latitude';
  static const String KEY_EVENT_LONGITUDE = 'critical_event_longitude';

  // ✅ NEW: Keys to freeze timer at event time
  static const String KEY_EVENT_ELAPSED_TIME = 'critical_event_elapsed_time';
  static const String KEY_IS_TIMER_FROZEN = 'is_timer_frozen';
  static const String KEY_FROZEN_DISPLAY_TIME = 'frozen_display_time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeUrgentNotifications();
    _initializeFromPersistentState();
    _startAutoSyncMonitoring();
    _startDistanceUpdater();
    _scheduleMidnightClockOut();

    // ✅ START NATIVE MONITORING SERVICE
    _startNativeMonitoringService();

    // ✅ CHECK FOR CRITICAL EVENTS ON STARTUP
    _checkAndProcessCriticalEvent();
  }

  // ✅ START NATIVE MONITORING SERVICE
  Future<void> _startNativeMonitoringService() async {
    try {
      if (Platform.isAndroid) {
        final bool result = await platform.invokeMethod('startMonitoring');
        debugPrint("✅ [NATIVE SERVICE] Started: $result");
      }
    } catch (e) {
      debugPrint("❌ [NATIVE SERVICE] Error starting: $e");
    }
  }

  // ✅ STOP NATIVE MONITORING SERVICE
  Future<void> _stopNativeMonitoringService() async {
    try {
      if (Platform.isAndroid) {
        final bool result = await platform.invokeMethod('stopMonitoring');
        debugPrint("🛑 [NATIVE SERVICE] Stopped: $result");
      }
    } catch (e) {
      debugPrint("❌ [NATIVE SERVICE] Error stopping: $e");
    }
  }

  // ✅ CHECK AND PROCESS CRITICAL EVENT ON APP START
  Future<void> _checkAndProcessCriticalEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCriticalEvent = prefs.getBool(KEY_HAS_CRITICAL_EVENT) ?? false;
    bool isTimerFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;

    if (hasCriticalEvent || isTimerFrozen) {
      debugPrint("🚨 [CRITICAL EVENT] Found pending critical event on startup");

      String? eventTimeStr = prefs.getString(KEY_EVENT_TIMESTAMP);
      String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
      String? eventReason = prefs.getString(KEY_EVENT_REASON);
      double? eventDistance = prefs.getDouble(KEY_EVENT_DISTANCE);
      double? eventLat = prefs.getDouble(KEY_EVENT_LATITUDE);
      double? eventLng = prefs.getDouble(KEY_EVENT_LONGITUDE);

      if (eventTimeStr != null) {
        DateTime eventTime = DateTime.parse(eventTimeStr);

        debugPrint("🚨 [CRITICAL EVENT] Event occurred at: $eventTime");
        debugPrint("🚨 [CRITICAL EVENT] Frozen elapsed time: $frozenTime");
        debugPrint("🚨 [CRITICAL EVENT] Reason: $eventReason");

        // ✅ SET THE FROZEN TIME TO DISPLAY (don't calculate new time)
        if (frozenTime != null) {
          _localElapsedTime = frozenTime;
          attendanceViewModel.elapsedTime.value = frozenTime;

          // ✅ IMPORTANT: Stop any running timer and keep the frozen state
          _localBackupTimer?.cancel();
          _localBackupTimer = null;
        }

        // Update UI to show frozen state
        if (mounted) {
          setState(() {});
        }

        // Show notification about the event
        Get.snackbar(
          '⚠️ Auto Clock-Out Occurred',
          'Event: ${_getReasonMessage(eventReason ?? 'unknown')}\nTime: ${DateFormat('HH:mm:ss').format(eventTime)}\nDuration: $frozenTime',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.warning, color: Colors.white),
        );

        // Sync the data with the original timestamp
        await _syncCriticalEventData(
          eventTime: eventTime,
          reason: eventReason ?? 'unknown',
          distance: eventDistance ?? 0.0,
          latitude: eventLat ?? 0.0,
          longitude: eventLng ?? 0.0,
        );

        // Clear critical event flags after processing but keep frozen time
        await _clearCriticalEventData();
      }
    }
  }

  // ✅ SYNC CRITICAL EVENT DATA TO SERVER
  Future<void> _syncCriticalEventData({
    required DateTime eventTime,
    required String reason,
    required double distance,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: eventTime,
        totalDistance: distance,
        isAuto: true,
        reason: reason,
      );

      debugPrint("✅ [SYNC] Critical event data synced with timestamp: $eventTime");

      _triggerAutoSync();

    } catch (e) {
      debugPrint("❌ [SYNC] Error syncing critical event: $e");
    }
  }

  // ✅ CLEAR CRITICAL EVENT DATA (but keep frozen time visible)
  Future<void> _clearCriticalEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_HAS_CRITICAL_EVENT);
    await prefs.remove(KEY_EVENT_TIMESTAMP);
    await prefs.remove(KEY_EVENT_REASON);
    await prefs.remove(KEY_EVENT_DISTANCE);
    await prefs.remove(KEY_EVENT_LATITUDE);
    await prefs.remove(KEY_EVENT_LONGITUDE);
    // ✅ DON'T remove KEY_FROZEN_DISPLAY_TIME and KEY_IS_TIMER_FROZEN yet
    // Keep them so timer stays frozen until manual clock in next day
    debugPrint("🧹 [CLEAR] Critical event data cleared (timer remains frozen)");
  }

  // ✅ SAVE CRITICAL EVENT DATA (Called when event happens in-app)
  Future<void> _saveCriticalEventData({
    required DateTime eventTime,
    required String reason,
    required double distance,
    required double latitude,
    required double longitude,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ CAPTURE CURRENT ELAPSED TIME BEFORE STOPPING TIMER
    String frozenElapsedTime = _localElapsedTime;

    await prefs.setBool(KEY_HAS_CRITICAL_EVENT, true);
    await prefs.setBool(KEY_IS_TIMER_FROZEN, true);
    await prefs.setString(KEY_EVENT_TIMESTAMP, eventTime.toIso8601String());
    await prefs.setString(KEY_EVENT_REASON, reason);
    await prefs.setDouble(KEY_EVENT_DISTANCE, distance);
    await prefs.setDouble(KEY_EVENT_LATITUDE, latitude);
    await prefs.setDouble(KEY_EVENT_LONGITUDE, longitude);
    await prefs.setString(KEY_FROZEN_DISPLAY_TIME, frozenElapsedTime); // ✅ Save frozen time

    debugPrint("💾 [SAVE] Critical event saved at: $eventTime");
    debugPrint("💾 [SAVE] Frozen elapsed time: $frozenElapsedTime");
    debugPrint("💾 [SAVE] Reason: $reason");
    debugPrint("💾 [SAVE] Distance: $distance");
  }

  // ✅ URGENT NOTIFICATION SETUP (IMMEDIATE)
  Future<void> _initializeUrgentNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
      'urgent_auto_clockout_channel',
      'URGENT Auto Clockout Notifications',
      description: 'High-priority channel for urgent auto clockout notifications',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableLights: true,
      ledColor: Colors.red,
    );

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentChannel);
  }

  // ✅ SHOW URGENT NOTIFICATION METHOD (IMMEDIATE)
  Future<void> _showUrgentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    _notificationId++;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'urgent_auto_clockout_channel',
      'URGENT Auto Clockout Notifications',
      channelDescription: 'High-priority channel for urgent auto clockout notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      timeoutAfter: 5000,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      color: Colors.red,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500,
      fullScreenIntent: true,
      ongoing: false,
      autoCancel: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint("🔔 [URGENT NOTIFICATION] Sent: $title");

    if (mounted) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.warning, color: Colors.white),
        shouldIconPulse: true,
        barBlur: 10,
        isDismissible: true,
      );
    }
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
    _midnightClockOutTimer?.cancel();
    _permissionCheckTimer?.cancel();
    // Don't stop native service here - it should keep running
    super.dispose();
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("🔄 [LIFECYCLE] App state changed: $state");

    if (state == AppLifecycleState.resumed) {
      // ✅ CHECK CRITICAL EVENT FIRST (before restoring anything)
      _checkAndProcessCriticalEvent();

      // ✅ THEN check permission status
      _checkPermissionOnResume();

      // ✅ THEN restore everything
      _restoreEverything();
      _checkConnectivityAndSync();
      _rescheduleMidnightClockOut();

      // Restart native service if needed
      _startNativeMonitoringService();
    } else if (state == AppLifecycleState.paused) {
      debugPrint("✅ [LIFECYCLE] App paused - Native service continues monitoring");
    }
  }

  // ✅ CHECK PERMISSION STATUS WHEN APP RESUMES (for when permission was revoked while app was killed)
  // ✅ CHECK PERMISSION STATUS WHEN APP RESUMES (for when permission was revoked while app was killed)
  Future<void> _checkPermissionOnResume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
    bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
    bool hasCriticalEvent = prefs.getBool(KEY_HAS_CRITICAL_EVENT) ?? false;

    // ✅ FIRST: Check if there's a pending critical event (from native service)
    if (hasCriticalEvent || isFrozen) {
      debugPrint("🔐 [RESUME CHECK] Found pending critical event from native service!");

      String? eventTimeStr = prefs.getString(KEY_EVENT_TIMESTAMP);
      String? eventReason = prefs.getString(KEY_EVENT_REASON);

      if (eventTimeStr != null) {
        DateTime eventTime = DateTime.parse(eventTimeStr);

        // Show notification that event was captured
        Get.snackbar(
          '⚠️ Auto Clock-Out Occurred',
          '${_getReasonMessage(eventReason ?? 'unknown')}\nTime: ${DateFormat('HH:mm:ss').format(eventTime)}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.warning, color: Colors.white),
        );

        // Process the critical event
        await _checkAndProcessCriticalEvent();
        return;
      }
    }

    // ✅ SECOND: Check if permission was revoked while app was closed (fallback)
    if (!isClockedIn || isFrozen) return;

    LocationPermission permission = await Geolocator.checkPermission();
    bool permissionGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (!permissionGranted) {
      debugPrint("🔐 [RESUME CHECK] Permission was revoked while app was closed!");

      DateTime eventTime = DateTime.now();
      double currentDist = await _getCurrentDistance();
      double lat = locationViewModel.globalLatitude1.value;
      double lng = locationViewModel.globalLongitude1.value;

      await _saveCriticalEventData(
        eventTime: eventTime,
        reason: 'permission_revoked_auto',
        distance: currentDist,
        latitude: lat,
        longitude: lng,
      );

      await _showUrgentNotification(
        title: '⚠️ PERMISSION REVOKED',
        body: 'Auto clockout triggered because location permission was removed',
        payload: 'permission_revoked_auto',
      );

      await _handleAutoClockOut(
        reason: 'permission_revoked_auto',
        context: context,
        eventTime: eventTime,
      );
    }
  }

  // ✅ SCHEDULE MIDNIGHT AUTO CLOCKOUT (11:58 PM) - Using same logic as location/permission events
  void _scheduleMidnightClockOut() {
    SharedPreferences.getInstance().then((prefs) {
      // ✅ DON'T schedule if timer is frozen (critical event already happened)
      bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
      if (isFrozen) {
        debugPrint("⏰ [MIDNIGHT] Timer is frozen, not scheduling midnight clockout");
        return;
      }

      if (!attendanceViewModel.isClockedIn.value) {
        return;
      }

      _midnightClockOutTimer?.cancel();

      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        58,
      );

      Duration timeUntilMidnight;
      if (now.isAfter(scheduledTime)) {
        final tomorrow = scheduledTime.add(const Duration(days: 1));
        timeUntilMidnight = tomorrow.difference(now);
      } else {
        timeUntilMidnight = scheduledTime.difference(now);
      }

      _midnightClockOutTimer = Timer(timeUntilMidnight, () async {
        if (attendanceViewModel.isClockedIn.value) {
          debugPrint("⏰ [MIDNIGHT] Auto clockout triggered at 11:58 PM");

          DateTime eventTime = DateTime.now();
          double currentDist = await _getCurrentDistance();
          double lat = locationViewModel.globalLatitude1.value;
          double lng = locationViewModel.globalLongitude1.value;

          // ✅ USE SAME FUNCTION LOGIC as location off and permission revoked
          await _saveCriticalEventData(
            eventTime: eventTime,
            reason: 'midnight_auto',
            distance: currentDist,
            latitude: lat,
            longitude: lng,
          );

          await _showUrgentNotification(
            title: '⚠️ AUTO CLOCKOUT - 11:58 PM',
            body: 'You have been automatically clocked out at 11:58 PM\nDuration: $_localElapsedTime',
            payload: 'midnight_auto',
          );

          // ✅ USE SAME HANDLE FUNCTION as other critical events
          await _handleAutoClockOut(
            reason: 'midnight_auto',
            context: context,
            eventTime: eventTime,
          );
        }
      });

      _isMidnightClockOutScheduled = true;
      debugPrint("⏰ [MIDNIGHT] Auto clockout scheduled for ${scheduledTime.hour}:${scheduledTime.minute}");
    });
  }

  void _rescheduleMidnightClockOut() {
    SharedPreferences.getInstance().then((prefs) {
      bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
      if (!isFrozen && attendanceViewModel.isClockedIn.value) {
        _scheduleMidnightClockOut();
      }
    });
  }

  // ✅ START PERMISSION MONITORING (FASTER CHECK) - In-app backup
  void _startPermissionMonitoring() {
    _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      // ✅ Check if timer is frozen first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
      if (isFrozen) {
        debugPrint("🔒 [MONITOR] Timer is frozen, stopping monitoring");
        timer.cancel();
        return;
      }

      if (!attendanceViewModel.isClockedIn.value) {
        return;
      }

      // Check location services
      bool locationEnabled = await attendanceViewModel.isLocationAvailable();
      if (_wasLocationAvailable && !locationEnabled) {
        debugPrint("📍 [LOCATION] Location turned OFF - URGENT auto clockout");

        DateTime eventTime = DateTime.now();
        double currentDist = await _getCurrentDistance();
        double lat = locationViewModel.globalLatitude1.value;
        double lng = locationViewModel.globalLongitude1.value;

        // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
        await _saveCriticalEventData(
          eventTime: eventTime,
          reason: 'location_off_auto',
          distance: currentDist,
          latitude: lat,
          longitude: lng,
        );

        await _showUrgentNotification(
          title: '⚠️ LOCATION TURNED OFF',
          body: 'Auto clockout triggered immediately because location was turned off',
          payload: 'location_off_auto',
        );

        await _handleAutoClockOut(
          reason: 'location_off_auto',
          context: context,
          eventTime: eventTime,
        );
        return;
      }
      _wasLocationAvailable = locationEnabled;

      // Check location permissions
      bool permissionGranted = await _checkPermissionStatus();
      if (_wasPermissionGranted && !permissionGranted) {
        debugPrint("🔐 [PERMISSION] Location permission revoked - URGENT auto clockout");

        DateTime eventTime = DateTime.now();
        double currentDist = await _getCurrentDistance();
        double lat = locationViewModel.globalLatitude1.value;
        double lng = locationViewModel.globalLongitude1.value;

        // ✅ SAVE CRITICAL EVENT DATA IMMEDIATELY (captures current elapsed time)
        await _saveCriticalEventData(
          eventTime: eventTime,
          reason: 'permission_revoked_auto',
          distance: currentDist,
          latitude: lat,
          longitude: lng,
        );

        await _showUrgentNotification(
          title: '⚠️ PERMISSION REVOKED',
          body: 'Auto clockout triggered immediately because location permission was removed',
          payload: 'permission_revoked_auto',
        );

        await _handleAutoClockOut(
          reason: 'permission_revoked_auto',
          context: context,
          eventTime: eventTime,
        );
        return;
      }
      _wasPermissionGranted = permissionGranted;
    });
  }

  Future<bool> _checkPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _checkLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 50,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Location Permission Required",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We need location access to continue.\n"
                      "Please enable location permission from app settings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await Geolocator.openAppSettings();
                        },
                        child: const Text(
                          "Open Settings",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
      return false;
    }

    return true;
  }

  // ✅ HANDLE AUTO CLOCKOUT (Modified to accept eventTime)
  Future<void> _handleAutoClockOut({
    required String reason,
    required BuildContext context,
    DateTime? eventTime,
  }) async {
    if (_autoClockOutInProgress || !attendanceViewModel.isClockedIn.value) {
      return;
    }
    _autoClockOutInProgress = true;

    DateTime clockOutTime = eventTime ?? DateTime.now();

    debugPrint("⚡ [AUTO CLOCKOUT] Triggered for reason: $reason");
    debugPrint("⚡ [AUTO CLOCKOUT] Using timestamp: $clockOutTime");

    try {
      _stopLocationMonitoring();
      _localBackupTimer?.cancel(); // ✅ Stop the timer immediately
      _midnightClockOutTimer?.cancel();

      double finalDistance = _currentDistance > 0 ? _currentDistance : 0.0;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isClockedIn', false);
      await prefs.setDouble('fastClockOutDistance', finalDistance);
      await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
      await prefs.setBool('clockOutPending', true);
      await prefs.setBool('hasFastClockOutData', true);
      await prefs.setString('fastClockOutReason', reason);

      // ✅ DON'T reset _localElapsedTime - keep the frozen value
      // ✅ DON'T reset _localClockInTime - we need it for reference

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;

      _isRiveAnimationActive = false;
      if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      // Save attendance out with the EXACT event time
      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: clockOutTime,
        totalDistance: finalDistance,
        isAuto: true,
        reason: reason,
      );

      await DailyWorkTimeManager.recordClockOut(clockOutTime);

      final service = FlutterBackgroundService();
      service.invoke("stopService");

      // ✅ STOP NATIVE MONITORING
      await _stopNativeMonitoringService();

      try {
        await location.enableBackgroundMode(enable: false);
      } catch (e) {
        debugPrint("⚠️ Background mode disable error: $e");
      }

      debugPrint("✅ [AUTO CLOCKOUT] Completed for reason: $reason at $clockOutTime");
      debugPrint("✅ [AUTO CLOCKOUT] Frozen elapsed time: $_localElapsedTime");

    } catch (e) {
      debugPrint("❌ [AUTO CLOCKOUT] Error: $e");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
    } finally {
      _autoClockOutInProgress = false;
    }
  }

  String _getReasonMessage(String reason) {
    switch (reason) {
      case 'midnight_auto':
        return 'You have been automatically clocked out at 11:58 PM';
      case 'location_off_auto':
        return 'Auto clockout because location services were turned off';
      case 'permission_revoked_auto':
        return 'Auto clockout because location permission was removed';
      default:
        return 'Auto clockout completed successfully';
    }
  }

  void _checkAndSyncPendingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPendingClockOut = prefs.getBool('hasPendingClockOutData') ?? false;
    bool clockOutPending = prefs.getBool('clockOutPending') ?? false;

    if (hasPendingClockOut || clockOutPending) {
      debugPrint("🔄 [PENDING SYNC] Found pending clock-out data - syncing...");
      _triggerAutoSync();
    }
  }

  void _startDistanceUpdater() {
    _distanceUpdateTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
          // ✅ Check if timer is frozen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;

          if (isFrozen) {
            timer.cancel();
            return;
          }

          if (attendanceViewModel.isClockedIn.value) {
            await _updateCurrentDistance();
          }
        });
  }

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

  void _startAutoSyncMonitoring() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results) {
      bool wasOnline = _isOnline;
      _isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'}");

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

  void _checkConnectivityAndSync() async {
    if (_isSyncing) {
      debugPrint('⏸️ Sync already in progress - skipping');
      return;
    }

    try {
      var results = await _connectivity.checkConnectivity();
      bool wasOnline = _isOnline;
      _isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (_isOnline && !wasOnline && !_isSyncing) {
        debugPrint("🔄 [AUTO-SYNC] Internet detected - triggering sync");
        _triggerAutoSync();
      }
    } catch (e) {
      debugPrint("❌ [CONNECTIVITY] Error checking connectivity: $e");
    }
  }

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
    bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
    String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);

    // ✅ If timer is frozen, DON'T restore clocked-in state
    if (isFrozen && frozenTime != null) {
      debugPrint("🔒 [RESTORE] Timer is frozen at $frozenTime, NOT restoring clocked-in state");

      _localElapsedTime = frozenTime;
      attendanceViewModel.elapsedTime.value = frozenTime;

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      _isRiveAnimationActive = false;

      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (isClockedIn) {
      debugPrint("🎯 [BULLETPROOF] Restoring EVERYTHING...");

      locationViewModel.isClockedIn.value = true;
      attendanceViewModel.isClockedIn.value = true;

      _isRiveAnimationActive = true;
      if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = true;
      }

      _startLocalBackupTimer();
      _scheduleMidnightClockOut();
      _startPermissionMonitoring();

      if (mounted) {
        setState(() {});
      }

      debugPrint("✅ [BULLETPROOF] Everything restored successfully");
    }
  }

  void _startLocalBackupTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ Check if timer is frozen before starting
    bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
    if (isFrozen) {
      debugPrint("🔒 [BACKUP TIMER] Timer is frozen, not starting backup timer");
      return;
    }

    String? clockInTimeString = prefs.getString('clockInTime');

    if (clockInTimeString == null) return;

    _localClockInTime = DateTime.parse(clockInTimeString);
    _localBackupTimer?.cancel();

    _localBackupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // ✅ Check if frozen during timer execution
      SharedPreferences.getInstance().then((prefs) {
        bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
        if (isFrozen) {
          timer.cancel();
          debugPrint("🔒 [BACKUP TIMER] Frozen state detected, stopping timer");
          return;
        }
      });

      if (_localClockInTime == null) return;

      final now = DateTime.now();
      final duration = now.difference(_localClockInTime!);

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));

      _localElapsedTime = '$hours:$minutes:$seconds';
      attendanceViewModel.elapsedTime.value = _localElapsedTime;

      // ✅ SAVE ELAPSED TIME TO PREFERENCES (for native service to read)
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('elapsed_time', _localElapsedTime);
      });

      if (mounted) {
        setState(() {});
      }
    });

    debugPrint("✅ [BACKUP TIMER] Local backup timer started");
  }

  Future<void> _initializeFromPersistentState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isClockedIn = prefs.getBool('isClockedIn') ?? false;
    bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
    String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);

    debugPrint("🔄 [INIT] Restoring state: isClockedIn = $isClockedIn, isFrozen = $isFrozen");

    // ✅ Handle frozen state first
    if (isFrozen && frozenTime != null) {
      debugPrint("🔒 [INIT] Timer is frozen at: $frozenTime");

      _localElapsedTime = frozenTime;
      attendanceViewModel.elapsedTime.value = frozenTime;
      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      _isRiveAnimationActive = false;

      if (mounted) {
        setState(() {});
      }
      return;
    }

    locationViewModel.isClockedIn.value = isClockedIn;
    attendanceViewModel.isClockedIn.value = isClockedIn;
    _isRiveAnimationActive = isClockedIn;

    if (isClockedIn) {
      debugPrint("✅ [INIT] User was clocked in - starting everything...");

      _startBackgroundServices();
      _startLocationMonitoring();
      _startLocalBackupTimer();
      _scheduleMidnightClockOut();
      _startPermissionMonitoring();

      debugPrint("✅ [INIT] Full clocked-in state restored");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onThemeRiveIconInit(Artboard artboard) {
    if (_themeMenuIcon.isEmpty) return;

    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    if (controller != null) {
      artboard.addController(controller);
      _themeMenuIcon[0].riveIcon.status =
      controller.findInput<bool>("active") as SMIBool?;

      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = _isRiveAnimationActive;
        debugPrint(
            "🎯 [RIVE] Animation initialized with state: $_isRiveAnimationActive");
      }
    } else {
      debugPrint("StateMachineController not found!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  // ✅ Check if we should show frozen time
                  String displayTime = _localElapsedTime;

                  // If we have a frozen time in prefs, use it
                  SharedPreferences.getInstance().then((prefs) {
                    bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
                    String? frozenTime = prefs.getString(KEY_FROZEN_DISPLAY_TIME);
                    if (isFrozen && frozenTime != null) {
                      displayTime = frozenTime;
                    }
                  });

                  if (displayTime == '00:00:00' &&
                      attendanceViewModel.isClockedIn.value) {
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

                Obx(() {
                  if (attendanceViewModel.isClockedIn.value &&
                      _currentDistance > 0) {
                    return Text(
                      '${_currentDistance.toStringAsFixed(2)} km',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return SizedBox(
                      width: 120,
                      height: 30,
                      child:  ElevatedButton(
                        onPressed: attendanceViewModel.isClockedIn.value
                            ? null
                            : () async => _handleClockIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Clock In", style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ))
                          ],
                        ),
                      )
                  );
                }),

                const SizedBox(width: 5),

                Obx(() { return SizedBox(
                    width: 120,
                    height: 30,
                    child:  ElevatedButton(
                      onPressed: attendanceViewModel.isClockedIn.value
                          ? () async => _handleClockOut(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Clock Out", style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ))
                        ],
                      ),
                    )
                );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClockOut(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== FAST CLOCK-OUT STARTED =====");

    bool showLoadingDialog = true;
    DateTime startTime = DateTime.now();
    Timer? loadingTimer;

    if (showLoadingDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            AlertDialog(
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
      _stopLocationMonitoring();
      _localBackupTimer?.cancel();
      _midnightClockOutTimer?.cancel();

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

      // ✅ CLEAR FROZEN STATE ON MANUAL CLOCK OUT (new day started)
      await prefs.remove(KEY_IS_TIMER_FROZEN);
      await prefs.remove(KEY_FROZEN_DISPLAY_TIME);

      await prefs.setBool('isClockedIn', false);
      await prefs.setDouble('fastClockOutDistance', finalDistance);
      await prefs.setString('fastClockOutTime', clockOutTime.toIso8601String());
      await prefs.setBool('clockOutPending', true);
      await prefs.setBool('hasFastClockOutData', true);

      locationViewModel.isClockedIn.value = false;
      attendanceViewModel.isClockedIn.value = false;
      _isRiveAnimationActive = false;

      if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = false;
      }

      _localElapsedTime = '00:00:00';
      _localClockInTime = null;

      await attendanceOutViewModel.fastSaveAttendanceOut(
        clockOutTime: clockOutTime,
        totalDistance: finalDistance,
        isAuto: false,
        reason: 'manual_clockout',
      );

      await DailyWorkTimeManager.recordClockOut(DateTime.now());

      final service = FlutterBackgroundService();
      service.invoke("stopService");

      // ✅ STOP NATIVE MONITORING
      await _stopNativeMonitoringService();

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

  Future<void> _handleClockIn(BuildContext context) async {
    debugPrint("🎯 [TIMERCARD] ===== CLOCK-IN STARTED =====");

    // ✅ CLEAR FROZEN STATE ON NEW CLOCK IN
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_IS_TIMER_FROZEN);
    await prefs.remove(KEY_FROZEN_DISPLAY_TIME);
    _localElapsedTime = '00:00:00';

    bool hasPermission = await _checkLocationPermission(context);
    if (!hasPermission) {
      debugPrint("🚫 [CLOCK-IN] Blocked — location permission not granted");
      return;
    }

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
      builder: (_) =>
          AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 15),
                Text('Checking permissions...',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
    );

    try {
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
      await prefs.setString(
          'currentSessionStart', DateTime.now().toIso8601String());

      _isRiveAnimationActive = true;
      if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = true;
      }

      _startLocalBackupTimer();
      _startLocationMonitoring();
      _scheduleMidnightClockOut();
      _startPermissionMonitoring();

      // ✅ START NATIVE MONITORING SERVICE
      await _startNativeMonitoringService();

      travelTimeViewModel.startTracking();
      debugPrint("📍 [TRAVEL TIME] Travel tracking started");

      await _updateCurrentDistance();
      await DailyWorkTimeManager.recordClockIn(DateTime.now());

      debugPrint("✅ [CLOCK-IN] ===== COMPLETED SUCCESSFULLY =====");

      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      Get.snackbar(
        '✅ Clocked In Successfully',
        'GPS tracking started',
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

  void _startLocationMonitoring() {
    _wasLocationAvailable = true;
    _autoClockOutInProgress = false;

    _locationMonitorTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
          // ✅ Check if frozen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool isFrozen = prefs.getBool(KEY_IS_TIMER_FROZEN) ?? false;
          if (isFrozen) {
            timer.cancel();
            return;
          }

          if (!attendanceViewModel.isClockedIn.value) {
            _stopLocationMonitoring();
            return;
          }

          bool currentLocationAvailable = await attendanceViewModel
              .isLocationAvailable();

          if (_wasLocationAvailable && !currentLocationAvailable) {
            debugPrint("📍 [LOCATION] Location OFF - URGENT auto clock-out");

            DateTime eventTime = DateTime.now();
            double currentDist = await _getCurrentDistance();
            double lat = locationViewModel.globalLatitude1.value;
            double lng = locationViewModel.globalLongitude1.value;

            await _saveCriticalEventData(
              eventTime: eventTime,
              reason: 'location_off_auto',
              distance: currentDist,
              latitude: lat,
              longitude: lng,
            );

            await _showUrgentNotification(
              title: '⚠️ LOCATION TURNED OFF',
              body: 'Auto clockout triggered immediately because location was turned off',
              payload: 'location_off_auto',
            );

            await _handleAutoClockOut(
              reason: 'location_off_auto',
              context: context,
              eventTime: eventTime,
            );
            return;
          }
          _wasLocationAvailable = currentLocationAvailable;

          bool currentPermissionGranted = await _checkPermissionStatus();

          if (_wasPermissionGranted && !currentPermissionGranted) {
            debugPrint("🔐 [PERMISSION] Permission REVOKED - URGENT auto clock-out");

            DateTime eventTime = DateTime.now();
            double currentDist = await _getCurrentDistance();
            double lat = locationViewModel.globalLatitude1.value;
            double lng = locationViewModel.globalLongitude1.value;

            await _saveCriticalEventData(
              eventTime: eventTime,
              reason: 'permission_revoked_auto',
              distance: currentDist,
              latitude: lat,
              longitude: lng,
            );

            await _showUrgentNotification(
              title: '⚠️ PERMISSION REVOKED',
              body: 'Auto clockout triggered immediately because location permission was removed',
              payload: 'permission_revoked_auto',
            );

            await _handleAutoClockOut(
              reason: 'permission_revoked_auto',
              context: context,
              eventTime: eventTime,
            );
          }
          _wasPermissionGranted = currentPermissionGranted;
        });
  }

  void _startBackgroundServices() async {
    try {
      debugPrint("🛰 [BACKGROUND] Starting services...");

      final service = FlutterBackgroundService();
      await location.enableBackgroundMode(enable: true);

      initializeServiceLocation().catchError((e) =>
          debugPrint("Service init error: $e"));
      service.startService().catchError((e) =>
          debugPrint("Service start error: $e"));
      location.changeSettings(
          interval: 300, accuracy: loc.LocationAccuracy.high)
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

  void _scheduleHeavyOperations(DateTime clockOutTime, double distance) async {
    debugPrint("🔄 Scheduling background operations...");

    Timer(Duration(seconds: 5), () async {
      try {
        debugPrint("🔄 [BACKGROUND] Starting heavy operations...");

        await locationViewModel.consolidateDailyGPXData();
        await locationViewModel.saveLocationFromConsolidatedFile();

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setDouble('fullClockOutDistance', distance);
        await prefs.setString(
            'fullClockOutTime', clockOutTime.toIso8601String());
        await prefs.setDouble(
            'pendingLatOut', locationViewModel.globalLatitude1.value);
        await prefs.setDouble(
            'pendingLngOut', locationViewModel.globalLongitude1.value);
        await prefs.setString(
            'pendingAddress', locationViewModel.shopAddress.value);

        debugPrint("✅ [BACKGROUND] Heavy operations completed");

        _triggerPostClockOutSync();
      } catch (e) {
        debugPrint("⚠️ [BACKGROUND] Error in heavy operations: $e");
      }
    });
  }

  void _triggerPostClockOutSync() async {
    debugPrint("🔄 [POST-CLOCKOUT] Starting background sync...");

    try {
      var results = await _connectivity.checkConnectivity();
      bool isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (isOnline && !_isSyncing) {
        _isSyncing = true;

        await updateFunctionViewModel.syncAllLocalDataToServer();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasPendingClockOutData', false);
        await prefs.setBool('clockOutPending', false);
        await prefs.setBool('hasFastClockOutData', false);

        debugPrint("✅ [POST-CLOCKOUT] Sync completed successfully");

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
        debugPrint(
            "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('clockOutPending', true);
      }
    } catch (e) {
      debugPrint("❌ [POST-CLOCKOUT] Sync error: $e");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clockOutPending', true);
    } finally {
      _isSyncing = false;
    }
  }
}