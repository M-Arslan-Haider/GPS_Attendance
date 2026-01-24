

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
  final TravelTimeViewModel travelTimeViewModel = Get.put(
      TravelTimeViewModel());

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeFromPersistentState();
    _startAutoSyncMonitoring();
    _startDistanceUpdater();

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("🔄 [LIFECYCLE] App state changed: $state");

    if (state == AppLifecycleState.resumed) {
      _restoreEverything();
      _checkConnectivityAndSync();

      // ✅ CHECK FOR PENDING DATA
      _checkAndSyncPendingData();
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

  // ✅ START DISTANCE UPDATER
  void _startDistanceUpdater() {
    _distanceUpdateTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
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
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results) {
      bool wasOnline = _isOnline;
      _isOnline = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      debugPrint("🌐 [CONNECTIVITY] Status: ${_isOnline
          ? 'ONLINE'
          : 'OFFLINE'} | Was: ${wasOnline
          ? 'ONLINE'
          : 'OFFLINE'} | Syncing: $_isSyncing");

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
          mainAxisSize: MainAxisSize.min, // 👈 important
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer + Distance
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  String displayTime = _localElapsedTime;
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

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return SizedBox(
                      width: 120, // Fixed width
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
                            // Icon(Icons.play_arrow, color: Colors.white),
                            Text("Clock In", style: TextStyle(
                              color: Colors.white,
                              fontSize: 15, // Text size
                              fontWeight: FontWeight.w600, // Boldness
                              letterSpacing: 0.5, // Space between letters
                            ))
                          ],
                        ),
                      )
                  );
                }),

                const SizedBox(width: 5),

                Obx(() { return SizedBox(
                    width: 120, // Fixed width
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
                          // Icon(Icons.stop, color: Colors.white),
                          Text("Clock Out", style: TextStyle(
                            color: Colors.white,
                            fontSize: 15, // Text size
                            fontWeight: FontWeight.w600, // Boldness
                            letterSpacing: 0.5, // Space between letters
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

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 100.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Timer Display
//                   Obx(() {
//                     String displayTime = _localElapsedTime;
//                     if (displayTime == '00:00:00' &&
//                         attendanceViewModel.isClockedIn.value) {
//                       displayTime = attendanceViewModel.elapsedTime.value;
//                     }
//
//                     return Text(
//                       displayTime,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: attendanceViewModel.isClockedIn.value
//                             ? Colors.black87
//                             : Colors.grey,
//                       ),
//                     );
//                   }),
//
//                   // Distance Display
//                   Obx(() {
//                     if (attendanceViewModel.isClockedIn.value &&
//                         _currentDistance > 0) {
//                       return Text(
//                         '${_currentDistance.toStringAsFixed(2)} km',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.blue.shade700,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   }),
//                 ],
//               ),
//
//               // Clock In/Out Button
//               // Obx(() {
//               //   return ElevatedButton(
//               //     onPressed: () async {
//               //       debugPrint("🎯 [BUTTON] Button pressed");
//               //       debugPrint(
//               //           "   - Clocked In: ${attendanceViewModel.isClockedIn
//               //               .value}");
//               //
//               //       if (attendanceViewModel.isClockedIn.value) {
//               //         await _handleClockOut(context);
//               //       } else {
//               //         await _handleClockIn(context);
//               //       }
//               //     },
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: attendanceViewModel.isClockedIn.value
//               //           ? Colors.redAccent
//               //           : Colors.green,
//               //       minimumSize: const Size(30, 30),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(12),
//               //       ),
//               //       padding: EdgeInsets.zero,
//               //     ),
//               //     child: SizedBox(
//               //       width: 35,
//               //       height: 35,
//               //       child: RiveAnimation.asset(
//               //         iconsRiv,
//               //         stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
//               //         artboard: _themeMenuIcon[0].riveIcon.artboard,
//               //         onInit: onThemeRiveIconInit,
//               //         fit: BoxFit.cover,
//               //       ),
//               //     ),
//               //   );
//               // }),
//               // Start Button
//               Obx(() {
//                 return ElevatedButton(
//                   onPressed: attendanceViewModel.isClockedIn.value ? null : () async {
//                     debugPrint("▶️ [BUTTON] Start button pressed");
//                     await _handleClockIn(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     minimumSize: const Size(60, 30),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.zero,
//                   ),
//                   child: const SizedBox(
//                     width: 35,
//                     height: 35,
//                     child: Icon(Icons.play_arrow, color: Colors.white),
//                   ),
//                 );
//               }),
//
// // Add some spacing between buttons
//               const SizedBox(width: 10),
//
// // Stop Button
//               Obx(() {
//                 return ElevatedButton(
//                   onPressed: attendanceViewModel.isClockedIn.value ? () async {
//                     debugPrint("⏹️ [BUTTON] Stop button pressed");
//                     await _handleClockOut(context);
//                   } : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     minimumSize: const Size(60, 30),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.zero,
//                   ),
//                   child: const SizedBox(
//                     width: 35,
//                     height: 35,
//                     child: Icon(Icons.stop, color: Colors.white),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
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
      // ADD THIS HERE ↓↓↓
      await DailyWorkTimeManager.recordClockOut(DateTime.now());


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
      await prefs.setString(
          'currentSessionStart', DateTime.now().toIso8601String());

      _isRiveAnimationActive = true;
      if (_themeMenuIcon[0].riveIcon.status != null) {
        _themeMenuIcon[0].riveIcon.status!.value = true;
      }

      _startLocalBackupTimer();
      _startLocationMonitoring();

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

  // ✅ START LOCATION MONITORING
  void _startLocationMonitoring() {
    _wasLocationAvailable = true;
    _autoClockOutInProgress = false;

    _locationMonitorTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
          if (!attendanceViewModel.isClockedIn.value) {
            _stopLocationMonitoring();
            return;
          }

          bool currentLocationAvailable = await attendanceViewModel
              .isLocationAvailable();

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
        await prefs.setString(
            'fullClockOutTime', clockOutTime.toIso8601String());
        await prefs.setDouble(
            'pendingLatOut', locationViewModel.globalLatitude1.value);
        await prefs.setDouble(
            'pendingLngOut', locationViewModel.globalLongitude1.value);
        await prefs.setString(
            'pendingAddress', locationViewModel.shopAddress.value);

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
        debugPrint(
            "🌐 [POST-CLOCKOUT] Offline - Will sync when connection available");

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
}