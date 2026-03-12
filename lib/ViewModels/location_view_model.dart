// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:synchronized/synchronized.dart';
// import 'package:uuid/uuid.dart';
//
// import '../Models/location_model.dart';
// import '../Repositories/location_repository.dart';
//
// class LocationViewModel extends GetxController {
//   // ── Dependencies ──────────────────────────────────────────────────────────
//   final LocationRepository _repo = LocationRepository();
//
//   // ── Observables ───────────────────────────────────────────────────────────
//   var allLocation               = <LocationModel>[].obs;
//   var globalLatitude1           = 0.0.obs;
//   var globalLongitude1          = 0.0.obs;
//   var shopAddress               = ''.obs;
//   var isGPSEnabled              = false.obs;
//   var isClockedIn               = false.obs;
//   var secondsPassed             = 0.obs;
//   var newsecondpassed           = 0.obs;
//   var lastProcessedDate         = ''.obs;
//   var isDailyProcessingComplete = false.obs;
//
//   // ── Internal state ────────────────────────────────────────────────────────
//   Timer?    _timer;
//   Timer?    _gpxSyncTimer;
//   bool      _isAutoSyncing    = false;
//   bool      _isGpxAutoSyncing = false;
//
//   // File-read lock (coordinates with background LocationService writes)
//   final Lock _fileReadLock = Lock();
//
//   // Distance cache (5-second validity)
//   double?   _cachedDistance;
//   DateTime? _lastDistanceCalc;
//   static const Duration _cacheValidity = Duration(seconds: 5);
//
//   // ── SharedPreferences keys ────────────────────────────────────────────────
//   static const String _keyIsClockedIn              = 'isClockedIn';
//   static const String _keySecondsPassed            = 'secondsPassed';
//   static const String _keyTotalTime                = 'totalTime';
//   static const String _keyTotalDistance            = 'totalDistance';
//   static const String _keyLastProcessedDate        = 'lastProcessedDate';
//   static const String _keyIsDailyProcessingComplete= 'isDailyProcessingComplete';
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // LIFECYCLE
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllLocation();
//     loadClockStatus();
//     startTimerIfClockedIn();
//     _initializeDailyProcessing();
//
//     // Auto-sync GPX after a short delay to let the app settle
//     Future.delayed(const Duration(seconds: 3), _startGpxAutoSync);
//   }
//
//   @override
//   void onClose() {
//     _timer?.cancel();
//     _gpxSyncTimer?.cancel();
//     super.onClose();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // TIMER
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> startTimerIfClockedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     isClockedIn.value = prefs.getBool(_keyIsClockedIn) ?? false;
//     if (isClockedIn.value) {
//       secondsPassed.value = prefs.getInt(_keySecondsPassed) ?? 0;
//       _timer?.cancel();
//       _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//         secondsPassed.value++;
//         _saveSecondsToPrefs(secondsPassed.value);
//       });
//     }
//   }
//
//   void startTimer() async {
//     _timer?.cancel();
//     final prefs = await SharedPreferences.getInstance();
//     secondsPassed.value = prefs.getInt(_keySecondsPassed) ?? 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       secondsPassed.value++;
//       _saveSecondsToPrefs(secondsPassed.value);
//     });
//   }
//
//   Future<String> stopTimer() async {
//     _timer?.cancel();
//     final prefs        = await SharedPreferences.getInstance();
//     final totalTime    = _formatDuration(secondsPassed.value);
//     secondsPassed.value    = 0;
//     newsecondpassed.value  = 0;
//     await prefs.setInt(_keySecondsPassed, 0);
//     await prefs.setString(_keyTotalTime, totalTime);
//     return totalTime;
//   }
//
//   void _saveSecondsToPrefs(int seconds) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_keySecondsPassed, seconds);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // CLOCK STATUS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> loadClockStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     isClockedIn.value = prefs.getBool(_keyIsClockedIn) ?? false;
//     if (!isClockedIn.value) await prefs.setInt(_keySecondsPassed, 0);
//   }
//
//   Future<void> saveClockStatus(bool clockedIn) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyIsClockedIn, clockedIn);
//     isClockedIn.value = clockedIn;
//   }
//
//   Future<void> saveCurrentTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('savedTime', DateFormat('HH:mm:ss').format(DateTime.now()));
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> saveCurrentLocation() async {
//     final permission = await Permission.location.request();
//     if (!permission.isGranted) return;
//
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       globalLatitude1.value  = pos.latitude;
//       globalLongitude1.value = pos.longitude;
//
//       final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         final addr =
//             '${p.thoroughfare ?? ''} ${p.subLocality ?? ''}, ${p.locality ?? ''} ${p.postalCode ?? ''}, ${p.country ?? ''}';
//         shopAddress.value = addr.trim().isEmpty ? 'Not Verified' : addr;
//       }
//
//       debugPrint('📍 Location: ${pos.latitude}, ${pos.longitude}');
//       debugPrint('🏠 Address: ${shopAddress.value}');
//     } catch (e) {
//       debugPrint('❌ saveCurrentLocation error: $e');
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // GPX FILE HELPERS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   String _dateStr([DateTime? date]) =>
//       DateFormat('dd-MM-yyyy').format(date ?? DateTime.now());
//
//   Future<String> _gpxFilePath([DateTime? date]) async {
//     final dir = await getDownloadsDirectory();
//     return '${dir!.path}/track${_dateStr(date)}.gpx';
//   }
//
//   Future<String> _userGpxFilePath([DateTime? date]) async {
//     final dir = await getDownloadsDirectory();
//     // File written by background LocationService
//     return '${dir!.path}/track_empId_${_dateStr(date)}.gpx';
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // DISTANCE CALCULATION
//   // ─────────────────────────────────────────────────────────────────────────
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
//   }
//
//   Future<double> calculateTotalDistance(String filePath) async {
//     try {
//       final file = File(filePath);
//       if (!await file.exists()) return 0.0;
//
//       final content = await _fileReadLock.synchronized(
//               () => file.readAsString());
//       if (content.isEmpty) return 0.0;
//
//       Gpx gpx;
//       try {
//         gpx = GpxReader().fromString(content);
//       } catch (e) {
//         debugPrint('❌ GPX parse error: $e');
//         return 0.0;
//       }
//
//       double total = 0.0;
//       for (final trk in gpx.trks) {
//         for (final seg in trk.trksegs) {
//           if (seg.trkpts.length < 2) continue;
//           for (int i = 0; i < seg.trkpts.length - 1; i++) {
//             final a = seg.trkpts[i];
//             final b = seg.trkpts[i + 1];
//             if (a.lat == null || a.lon == null || b.lat == null || b.lon == null)
//               continue;
//             total += calculateDistance(a.lat!.toDouble(), a.lon!.toDouble(),
//                 b.lat!.toDouble(), b.lon!.toDouble());
//           }
//         }
//       }
//
//       debugPrint('📏 Total distance: ${total.toStringAsFixed(3)} km');
//       return total;
//     } catch (e) {
//       debugPrint('❌ calculateTotalDistance error: $e');
//       return 0.0;
//     }
//   }
//
//   Future<double> getImmediateDistance() async {
//     // Return from cache if recent enough
//     if (_cachedDistance != null &&
//         _lastDistanceCalc != null &&
//         DateTime.now().difference(_lastDistanceCalc!) < _cacheValidity) {
//       return _cachedDistance!;
//     }
//
//     try {
//       final filePath = await _gpxFilePath();
//       if (!await File(filePath).exists()) return 0.0;
//
//       final dist = await _fileReadLock.synchronized(
//               () => calculateTotalDistance(filePath));
//
//       _cachedDistance      = dist;
//       _lastDistanceCalc    = DateTime.now();
//       return dist;
//     } catch (e) {
//       debugPrint('❌ getImmediateDistance error: $e');
//       return 0.0;
//     }
//   }
//
//   Future<double> calculateShiftDistance(DateTime shiftStart) async {
//     try {
//       final filePath = await _gpxFilePath();
//       final file     = File(filePath);
//       if (!await file.exists()) return 0.0;
//
//       final content = await file.readAsString();
//       if (content.isEmpty) return 0.0;
//
//       final gpx      = GpxReader().fromString(content);
//       double dist    = 0.0;
//
//       for (final trk in gpx.trks) {
//         for (final seg in trk.trksegs) {
//           final pts = seg.trkpts
//               .where((p) => p.time != null && p.time!.isAfter(shiftStart))
//               .toList();
//
//           for (int i = 0; i < pts.length - 1; i++) {
//             dist += calculateDistance(
//               pts[i].lat?.toDouble()     ?? 0.0,
//               pts[i].lon?.toDouble()     ?? 0.0,
//               pts[i + 1].lat?.toDouble() ?? 0.0,
//               pts[i + 1].lon?.toDouble() ?? 0.0,
//             );
//           }
//         }
//       }
//
//       debugPrint('📍 Shift distance: ${dist.toStringAsFixed(3)} km');
//       return dist;
//     } catch (e) {
//       debugPrint('❌ calculateShiftDistance error: $e');
//       return 0.0;
//     }
//   }
//
//   Future<double> calculateShiftDistanceFast(DateTime shiftStart) async {
//     try {
//       final filePath = await _gpxFilePath();
//       final file     = File(filePath);
//       if (!await file.exists()) return 0.0;
//
//       final content  = await file.readAsString();
//       if (content.isEmpty) return 0.0;
//
//       final matches  =
//       RegExp(r'lat="([^"]+)" lon="([^"]+)"').allMatches(content).toList();
//       if (matches.length < 2) return 0.0;
//
//       double total  = 0.0;
//       double? pLat, pLon;
//
//       for (final m in matches) {
//         final lat = double.parse(m.group(1)!);
//         final lon = double.parse(m.group(2)!);
//         if (pLat != null && pLon != null) {
//           total += calculateDistance(pLat, pLon, lat, lon);
//         }
//         pLat = lat;
//         pLon = lon;
//       }
//
//       return total;
//     } catch (e) {
//       debugPrint('❌ calculateShiftDistanceFast error: $e');
//       return 0.0;
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // GPX CONSOLIDATION
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> consolidateDailyGPXData() async =>
//       consolidateDailyGPXDataForDate(DateTime.now());
//
//   Future<void> consolidateDailyGPXDataForDate(DateTime eventDate) async {
//     try {
//       final dateStr      = _dateStr(eventDate);
//       final dir          = await getDownloadsDirectory();
//       final dailyPath    = '${dir!.path}/track$dateStr.gpx';
//
//       debugPrint('🔄 [GPX] Consolidating for: $dateStr');
//
//       await _fileReadLock.synchronized(() async {
//         final dailyFile = File(dailyPath);
//
//         if (!await dailyFile.exists()) {
//           await dailyFile.writeAsString(
//             '<?xml version="1.0" encoding="UTF-8"?>\n'
//                 '<gpx version="1.1" creator="EmployeePortal">\n'
//                 '  <trk><name>Daily Track $dateStr</name>'
//                 '<trkseg></trkseg></trk>\n</gpx>',
//             flush: true,
//           );
//         }
//
//         final dailyGpx = GpxReader().fromString(await dailyFile.readAsString());
//         if (dailyGpx.trks.isEmpty) dailyGpx.trks.add(Trk());
//         if (dailyGpx.trks.first.trksegs.isEmpty)
//           dailyGpx.trks.first.trksegs.add(Trkseg());
//
//         final mainSeg   = dailyGpx.trks.first.trksegs.first;
//         final initCount = mainSeg.trkpts.length;
//         int merged      = 0;
//
//         final allFiles = await _findGpxFilesForDate(dir, dateStr);
//
//         for (final f in allFiles) {
//           if (f.path == dailyPath) continue;
//           try {
//             final tempGpx = GpxReader().fromString(await f.readAsString());
//             for (final trk in tempGpx.trks) {
//               for (final seg in trk.trksegs) {
//                 for (final pt in seg.trkpts) {
//                   if (!_containsPoint(mainSeg.trkpts, pt)) {
//                     mainSeg.trkpts.add(pt);
//                     merged++;
//                   }
//                 }
//               }
//             }
//           } catch (e) {
//             debugPrint('⚠️ [GPX] Error merging ${f.path}: $e');
//           }
//         }
//
//         mainSeg.trkpts.sort((a, b) {
//           if (a.time == null || b.time == null) return 0;
//           return a.time!.compareTo(b.time!);
//         });
//
//         await dailyFile.writeAsString(GpxWriter().asString(dailyGpx),
//             flush: true);
//
//         debugPrint(
//             '🎉 [GPX] Consolidation done: $initCount → ${mainSeg.trkpts.length} pts ($merged merged)');
//       });
//     } catch (e) {
//       debugPrint('❌ [GPX] consolidateDailyGPXDataForDate error: $e');
//     }
//   }
//
//   Future<List<File>> _findGpxFilesForDate(
//       Directory dir, String dateStr) async {
//     final files = <File>[];
//     try {
//       await for (final entity in dir.list()) {
//         if (entity is File &&
//             entity.path.endsWith('.gpx') &&
//             entity.path.split('/').last.contains(dateStr)) {
//           files.add(entity);
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ [GPX] _findGpxFilesForDate error: $e');
//     }
//     return files;
//   }
//
//   bool _containsPoint(List<Wpt> pts, Wpt p) => pts.any(
//           (e) => e.lat == p.lat && e.lon == p.lon && e.time == p.time);
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION SAVING (to local DB + sync)
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> saveLocation() async =>
//       saveLocationFromConsolidatedFileForDate(DateTime.now());
//
//   Future<void> saveLocationFromConsolidatedFile() async =>
//       saveLocationFromConsolidatedFileForDate(DateTime.now());
//
//   Future<void> saveLocationFromConsolidatedFileForDate(
//       DateTime eventDate) async {
//     try {
//       final dateStr  = _dateStr(eventDate);
//       final dir      = await getDownloadsDirectory();
//       final filePath = '${dir!.path}/track$dateStr.gpx';
//       final file     = File(filePath);
//
//       if (!await file.exists()) {
//         debugPrint('❌ [LocVM] GPX file not found: $filePath');
//         return;
//       }
//
//       final totalDist = await calculateTotalDistance(filePath);
//       final prefs     = await SharedPreferences.getInstance();
//       await prefs.setDouble(_keyTotalDistance, totalDist);
//
//       final bytes = await _fileReadLock.synchronized(
//               () => file.readAsBytes());
//
//       final model = LocationModel(
//         location_id    : const Uuid().v4(),
//         emp_id         : prefs.getString('emp_id') ?? '',
//         emp_name       : prefs.getString('emp_name') ?? '',
//         total_distance : totalDist.toString(),
//         file_name      : '$dateStr.gpx',
//         body           : Uint8List.fromList(bytes),
//         location_date  : eventDate,
//         location_time  : eventDate,
//         posted         : 0,
//       );
//
//       await addLocation(model);
//       await _repo.syncUnposted(deleteAfterPost: true);
//
//       debugPrint(
//           '✅ [LocVM] Location saved: $dateStr.gpx | dist=${totalDist.toStringAsFixed(3)} km');
//     } catch (e) {
//       debugPrint('❌ [LocVM] saveLocationFromConsolidatedFileForDate error: $e');
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // LOCATION SERVICE STATUS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<Map<String, dynamic>> checkLocationServiceStatus() async {
//     try {
//       final filePath = await _gpxFilePath();
//       final file     = File(filePath);
//       final exists   = await file.exists();
//       final size     = exists ? await file.length() : 0;
//       int   pts      = 0;
//
//       if (exists) {
//         final content = await _fileReadLock.synchronized(
//                 () => file.readAsString());
//         if (content.isNotEmpty) {
//           pts = _getTotalPoints(GpxReader().fromString(content));
//         }
//       }
//
//       return {
//         'serviceActive'   : true,
//         'fileExists'      : exists,
//         'fileSize'        : size,
//         'pointsRecorded'  : pts,
//         'filePath'        : filePath,
//       };
//     } catch (e) {
//       return {'serviceActive': false, 'error': e.toString()};
//     }
//   }
//
//   int _getTotalPoints(Gpx gpx) => gpx.trks
//       .expand((t) => t.trksegs)
//       .fold(0, (sum, s) => sum + s.trkpts.length);
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SYNC STATUS HELPERS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<Map<String, dynamic>> checkSyncStatus() async {
//     final prefs  = await SharedPreferences.getInstance();
//     final status = prefs.getString('clockOutSyncStatus') ?? 'unknown';
//     return {
//       'syncStatus'     : status,
//       'lastClockOutTime': prefs.getString('lastClockOutTime'),
//       'lastDistance'   : prefs.getDouble('lastClockOutDistance'),
//       'hasPendingSync' : ['pending', 'pending_local', 'retry_needed']
//           .contains(status),
//     };
//   }
//
//   Future<void> clearSyncStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('clockOutSyncStatus');
//     await prefs.remove('lastClockOutTime');
//     await prefs.remove('lastClockOutDistance');
//     await prefs.remove('pendingAttendanceOutId');
//     debugPrint('🧹 [LocVM] Sync status cleared');
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // DATABASE CRUD
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> fetchAllLocation() async {
//     allLocation.value = await _repo.getAll();
//   }
//
//   Future<void> addLocation(LocationModel model) async {
//     await _repo.add(model);
//     await fetchAllLocation();
//   }
//
//   Future<void> deleteLocation(String id) async {
//     await _repo.delete(id);
//     await fetchAllLocation();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // PERMISSIONS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   Future<void> requestPermissions() async {
//     if (await Permission.notification.request().isDenied) {
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//       return;
//     }
//
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//     }
//
//     if (perm == LocationPermission.denied ||
//         perm == LocationPermission.deniedForever) {
//       _showLocationDialog();
//       return;
//     }
//
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       _showLocationDialog();
//       return;
//     }
//
//     if (await Permission.locationAlways.request().isDenied) {
//       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//     }
//   }
//
//   void _showLocationDialog() {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: AlertDialog(
//           title: const Text('Location Required',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           content: const SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                     'For a better experience, your device will need to use Location Accuracy.'),
//                 SizedBox(height: 16),
//                 Text('The following settings should be on:',
//                     style: TextStyle(fontWeight: FontWeight.w600)),
//                 SizedBox(height: 8),
//                 Row(children: [
//                   Icon(Icons.radio_button_checked,
//                       size: 16, color: Colors.green),
//                   SizedBox(width: 8),
//                   Text('Device location'),
//                 ]),
//                 Row(children: [
//                   Icon(Icons.radio_button_checked,
//                       size: 16, color: Colors.green),
//                   SizedBox(width: 8),
//                   Text('Location Accuracy'),
//                 ]),
//                 SizedBox(height: 12),
//                 Text(
//                   'Location Accuracy provides more accurate location for apps and services.',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             SizedBox(
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
//                 child: const Text('TURN ON'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // DAILY PROCESSING INIT
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _initializeDailyProcessing() async {
//     final prefs = await SharedPreferences.getInstance();
//     lastProcessedDate.value         = prefs.getString(_keyLastProcessedDate) ?? '';
//     isDailyProcessingComplete.value =
//         prefs.getBool(_keyIsDailyProcessingComplete) ?? false;
//
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     if (lastProcessedDate.value != today) {
//       isDailyProcessingComplete.value = false;
//       await prefs.setBool(_keyIsDailyProcessingComplete, false);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // AUTO SYNC (on open + every 5 minutes)
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _startGpxAutoSync() {
//     debugPrint('🚀 [LocVM] GPX auto-sync started');
//     _syncGpxIfOnline(); // immediate
//     _gpxSyncTimer =
//         Timer.periodic(const Duration(minutes: 5), (_) => _syncGpxIfOnline());
//   }
//
//   Future<void> _syncGpxIfOnline() async {
//     if (_isGpxAutoSyncing) return;
//     _isGpxAutoSyncing = true;
//     try {
//       if (!await _hasInternet()) {
//         debugPrint('❌ [LocVM] No internet — GPX sync skipped');
//         return;
//       }
//       await _repo.syncUnposted(deleteAfterPost: true);
//       debugPrint('✅ [LocVM] GPX sync complete');
//     } catch (e) {
//       debugPrint('❌ [LocVM] GPX sync error: $e');
//     } finally {
//       _isGpxAutoSyncing = false;
//     }
//   }
//
//   Future<bool> _hasInternet() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
//     } on SocketException {
//       return false;
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   String _formatDuration(int seconds) {
//     final d = Duration(seconds: seconds);
//     String two(int n) => n.toString().padLeft(2, '0');
//     return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
//   }
// }

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

import '../Models/location_model.dart';
import '../Repositories/location_repository.dart';

class LocationViewModel extends GetxController {
  // ── Dependencies ──────────────────────────────────────────────────────────
  final LocationRepository _repo = LocationRepository();

  // ── Observables ───────────────────────────────────────────────────────────
  var allLocation               = <LocationModel>[].obs;
  var globalLatitude1           = 0.0.obs;
  var globalLongitude1          = 0.0.obs;
  var shopAddress               = ''.obs;
  var isGPSEnabled              = false.obs;
  var isClockedIn               = false.obs;
  var secondsPassed             = 0.obs;
  var newsecondpassed           = 0.obs;
  var lastProcessedDate         = ''.obs;
  var isDailyProcessingComplete = false.obs;

  // ── Internal state ────────────────────────────────────────────────────────
  Timer?    _timer;
  Timer?    _gpxSyncTimer;
  bool      _isAutoSyncing    = false;
  bool      _isGpxAutoSyncing = false;

  // File-read lock (coordinates with background LocationService writes)
  final Lock _fileReadLock = Lock();

  // Distance cache (5-second validity)
  double?   _cachedDistance;
  DateTime? _lastDistanceCalc;
  static const Duration _cacheValidity = Duration(seconds: 5);

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String _keyIsClockedIn              = 'isClockedIn';
  static const String _keySecondsPassed            = 'secondsPassed';
  static const String _keyTotalTime                = 'totalTime';
  static const String _keyTotalDistance            = 'totalDistance';
  static const String _keyLastProcessedDate        = 'lastProcessedDate';
  static const String _keyIsDailyProcessingComplete= 'isDailyProcessingComplete';

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchAllLocation();
    loadClockStatus();
    startTimerIfClockedIn();
    _initializeDailyProcessing();

    // Auto-sync GPX after a short delay to let the app settle
    Future.delayed(const Duration(seconds: 3), _startGpxAutoSync);
  }

  @override
  void onClose() {
    _timer?.cancel();
    _gpxSyncTimer?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> startTimerIfClockedIn() async {
    final prefs = await SharedPreferences.getInstance();
    isClockedIn.value = prefs.getBool(_keyIsClockedIn) ?? false;
    if (isClockedIn.value) {
      secondsPassed.value = prefs.getInt(_keySecondsPassed) ?? 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        secondsPassed.value++;
        _saveSecondsToPrefs(secondsPassed.value);
      });
    }
  }

  void startTimer() async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    secondsPassed.value = prefs.getInt(_keySecondsPassed) ?? 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      secondsPassed.value++;
      _saveSecondsToPrefs(secondsPassed.value);
    });
  }

  Future<String> stopTimer() async {
    _timer?.cancel();
    final prefs        = await SharedPreferences.getInstance();
    final totalTime    = _formatDuration(secondsPassed.value);
    secondsPassed.value    = 0;
    newsecondpassed.value  = 0;
    await prefs.setInt(_keySecondsPassed, 0);
    await prefs.setString(_keyTotalTime, totalTime);
    return totalTime;
  }

  void _saveSecondsToPrefs(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySecondsPassed, seconds);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLOCK STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadClockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isClockedIn.value = prefs.getBool(_keyIsClockedIn) ?? false;
    if (!isClockedIn.value) await prefs.setInt(_keySecondsPassed, 0);
  }

  Future<void> saveClockStatus(bool clockedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsClockedIn, clockedIn);
    isClockedIn.value = clockedIn;
  }

  Future<void> saveCurrentTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedTime', DateFormat('HH:mm:ss').format(DateTime.now()));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveCurrentLocation() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      globalLatitude1.value  = pos.latitude;
      globalLongitude1.value = pos.longitude;

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr =
            '${p.thoroughfare ?? ''} ${p.subLocality ?? ''}, ${p.locality ?? ''} ${p.postalCode ?? ''}, ${p.country ?? ''}';
        shopAddress.value = addr.trim().isEmpty ? 'Not Verified' : addr;
      }

      debugPrint('📍 Location: ${pos.latitude}, ${pos.longitude}');
      debugPrint('🏠 Address: ${shopAddress.value}');
    } catch (e) {
      debugPrint('❌ saveCurrentLocation error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GPX FILE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  // ✅ FIX: Date string format must match location00.dart which uses 'dd-MM-yyyy'
  // e.g. 11-03-2026  (used only for file naming, NOT for API date field)
  String _dateStr([DateTime? date]) =>
      DateFormat('dd-MM-yyyy').format(date ?? DateTime.now());

  // ✅ FIX: Read emp_id from SharedPreferences so file path matches
  // location00.dart which names files as: track_{userId}_{dd-MM-yyyy}.gpx
  Future<String> _gpxFilePath([DateTime? date]) async {
    final dir    = await getDownloadsDirectory();
    final prefs  = await SharedPreferences.getInstance();
    // location00.dart uses 'userId' key — fall back to 'emp_id' if not found
    final userId = prefs.getString('userId') ?? prefs.getString('emp_id') ?? '';
    final dateStr = _dateStr(date);
    // ✅ FIXED: was 'track$dateStr.gpx', now matches location00.dart pattern
    return '${dir!.path}/track_${userId}_$dateStr.gpx';
  }

  // Consolidated daily file (written by consolidateDailyGPXDataForDate)
  Future<String> _consolidatedGpxFilePath([DateTime? date]) async {
    final dir     = await getDownloadsDirectory();
    final dateStr = _dateStr(date);
    return '${dir!.path}/track$dateStr.gpx';
  }

  Future<String> _userGpxFilePath([DateTime? date]) async {
    final dir = await getDownloadsDirectory();
    // File written by background LocationService
    return '${dir!.path}/track_empId_${_dateStr(date)}.gpx';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISTANCE CALCULATION
  // ─────────────────────────────────────────────────────────────────────────

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
  }

  Future<double> calculateTotalDistance(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return 0.0;

      final content = await _fileReadLock.synchronized(
              () => file.readAsString());
      if (content.isEmpty) return 0.0;

      Gpx gpx;
      try {
        gpx = GpxReader().fromString(content);
      } catch (e) {
        debugPrint('❌ GPX parse error: $e');
        return 0.0;
      }

      double total = 0.0;
      for (final trk in gpx.trks) {
        for (final seg in trk.trksegs) {
          if (seg.trkpts.length < 2) continue;
          for (int i = 0; i < seg.trkpts.length - 1; i++) {
            final a = seg.trkpts[i];
            final b = seg.trkpts[i + 1];
            if (a.lat == null || a.lon == null || b.lat == null || b.lon == null)
              continue;
            total += calculateDistance(a.lat!.toDouble(), a.lon!.toDouble(),
                b.lat!.toDouble(), b.lon!.toDouble());
          }
        }
      }

      debugPrint('📏 Total distance: ${total.toStringAsFixed(3)} km');
      return total;
    } catch (e) {
      debugPrint('❌ calculateTotalDistance error: $e');
      return 0.0;
    }
  }

  Future<double> getImmediateDistance() async {
    // Return from cache if recent enough
    if (_cachedDistance != null &&
        _lastDistanceCalc != null &&
        DateTime.now().difference(_lastDistanceCalc!) < _cacheValidity) {
      return _cachedDistance!;
    }

    try {
      // ✅ FIX: Use _gpxFilePath() which now matches location00.dart naming
      final filePath = await _gpxFilePath();
      if (!await File(filePath).exists()) return 0.0;

      final dist = await _fileReadLock.synchronized(
              () => calculateTotalDistance(filePath));

      _cachedDistance      = dist;
      _lastDistanceCalc    = DateTime.now();
      return dist;
    } catch (e) {
      debugPrint('❌ getImmediateDistance error: $e');
      return 0.0;
    }
  }

  Future<double> calculateShiftDistance(DateTime shiftStart) async {
    try {
      // ✅ FIX: Use _gpxFilePath() which now matches location00.dart naming
      final filePath = await _gpxFilePath();
      final file     = File(filePath);
      if (!await file.exists()) return 0.0;

      final content = await file.readAsString();
      if (content.isEmpty) return 0.0;

      final gpx      = GpxReader().fromString(content);
      double dist    = 0.0;

      for (final trk in gpx.trks) {
        for (final seg in trk.trksegs) {
          final pts = seg.trkpts
              .where((p) => p.time != null && p.time!.isAfter(shiftStart))
              .toList();

          for (int i = 0; i < pts.length - 1; i++) {
            dist += calculateDistance(
              pts[i].lat?.toDouble()     ?? 0.0,
              pts[i].lon?.toDouble()     ?? 0.0,
              pts[i + 1].lat?.toDouble() ?? 0.0,
              pts[i + 1].lon?.toDouble() ?? 0.0,
            );
          }
        }
      }

      debugPrint('📍 Shift distance: ${dist.toStringAsFixed(3)} km');
      return dist;
    } catch (e) {
      debugPrint('❌ calculateShiftDistance error: $e');
      return 0.0;
    }
  }

  Future<double> calculateShiftDistanceFast(DateTime shiftStart) async {
    try {
      // ✅ FIX: Use _gpxFilePath() which now matches location00.dart naming
      final filePath = await _gpxFilePath();
      final file     = File(filePath);
      if (!await file.exists()) return 0.0;

      final content  = await file.readAsString();
      if (content.isEmpty) return 0.0;

      final matches  =
      RegExp(r'lat="([^"]+)" lon="([^"]+)"').allMatches(content).toList();
      if (matches.length < 2) return 0.0;

      double total  = 0.0;
      double? pLat, pLon;

      for (final m in matches) {
        final lat = double.parse(m.group(1)!);
        final lon = double.parse(m.group(2)!);
        if (pLat != null && pLon != null) {
          total += calculateDistance(pLat, pLon, lat, lon);
        }
        pLat = lat;
        pLon = lon;
      }

      return total;
    } catch (e) {
      debugPrint('❌ calculateShiftDistanceFast error: $e');
      return 0.0;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GPX CONSOLIDATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> consolidateDailyGPXData() async =>
      consolidateDailyGPXDataForDate(DateTime.now());

  Future<void> consolidateDailyGPXDataForDate(DateTime eventDate) async {
    try {
      final dateStr   = _dateStr(eventDate);
      final dir       = await getDownloadsDirectory();

      // ✅ FIX: consolidated file keeps simple name (no userId) — separate from source file
      final dailyPath = '${dir!.path}/track$dateStr.gpx';

      debugPrint('🔄 [GPX] Consolidating for: $dateStr');

      await _fileReadLock.synchronized(() async {
        final dailyFile = File(dailyPath);

        if (!await dailyFile.exists()) {
          await dailyFile.writeAsString(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
                '<gpx version="1.1" creator="EmployeePortal">\n'
                '  <trk><n>Daily Track $dateStr</n>'
                '<trkseg></trkseg></trk>\n</gpx>',
            flush: true,
          );
        }

        final dailyGpx = GpxReader().fromString(await dailyFile.readAsString());
        if (dailyGpx.trks.isEmpty) dailyGpx.trks.add(Trk());
        if (dailyGpx.trks.first.trksegs.isEmpty)
          dailyGpx.trks.first.trksegs.add(Trkseg());

        final mainSeg   = dailyGpx.trks.first.trksegs.first;
        final initCount = mainSeg.trkpts.length;
        int merged      = 0;

        final allFiles = await _findGpxFilesForDate(dir, dateStr);

        for (final f in allFiles) {
          if (f.path == dailyPath) continue;
          try {
            final tempGpx = GpxReader().fromString(await f.readAsString());
            for (final trk in tempGpx.trks) {
              for (final seg in trk.trksegs) {
                for (final pt in seg.trkpts) {
                  if (!_containsPoint(mainSeg.trkpts, pt)) {
                    mainSeg.trkpts.add(pt);
                    merged++;
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ [GPX] Error merging ${f.path}: $e');
          }
        }

        mainSeg.trkpts.sort((a, b) {
          if (a.time == null || b.time == null) return 0;
          return a.time!.compareTo(b.time!);
        });

        await dailyFile.writeAsString(GpxWriter().asString(dailyGpx),
            flush: true);

        debugPrint(
            '🎉 [GPX] Consolidation done: $initCount → ${mainSeg.trkpts.length} pts ($merged merged)');
      });
    } catch (e) {
      debugPrint('❌ [GPX] consolidateDailyGPXDataForDate error: $e');
    }
  }

  Future<List<File>> _findGpxFilesForDate(
      Directory dir, String dateStr) async {
    final files = <File>[];
    try {
      await for (final entity in dir.list()) {
        if (entity is File &&
            entity.path.endsWith('.gpx') &&
            entity.path.split('/').last.contains(dateStr)) {
          files.add(entity);
        }
      }
    } catch (e) {
      debugPrint('❌ [GPX] _findGpxFilesForDate error: $e');
    }
    return files;
  }

  bool _containsPoint(List<Wpt> pts, Wpt p) => pts.any(
          (e) => e.lat == p.lat && e.lon == p.lon && e.time == p.time);

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION SAVING (to local DB + sync)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveLocation() async =>
      saveLocationFromConsolidatedFileForDate(DateTime.now());

  Future<void> saveLocationFromConsolidatedFile() async =>
      saveLocationFromConsolidatedFileForDate(DateTime.now());

  Future<void> saveLocationFromConsolidatedFileForDate(
      DateTime eventDate) async {
    try {
      final dateStr = _dateStr(eventDate);
      final dir     = await getDownloadsDirectory();

      // ✅ FIX: First try the user-specific file written by location00.dart
      //         (track_{userId}_{dd-MM-yyyy}.gpx), then fall back to consolidated
      final prefs  = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? prefs.getString('emp_id') ?? '';

      final userFilePath        = '${dir!.path}/track_${userId}_$dateStr.gpx';
      final consolidatedFilePath = '${dir.path}/track$dateStr.gpx';

      String filePath;
      if (await File(userFilePath).exists()) {
        filePath = userFilePath;
        debugPrint('📂 [LocVM] Using user GPX file: $userFilePath');
      } else if (await File(consolidatedFilePath).exists()) {
        filePath = consolidatedFilePath;
        debugPrint('📂 [LocVM] Using consolidated GPX file: $consolidatedFilePath');
      } else {
        debugPrint('❌ [LocVM] No GPX file found for $dateStr');
        debugPrint('   Looked for: $userFilePath');
        debugPrint('   Looked for: $consolidatedFilePath');
        return;
      }

      final totalDist = await calculateTotalDistance(filePath);
      await prefs.setDouble(_keyTotalDistance, totalDist);

      final bytes = await _fileReadLock.synchronized(
              () => File(filePath).readAsBytes());

      final model = LocationModel(
        location_id    : const Uuid().v4(),
        emp_id         : prefs.getString('emp_id') ?? '',
        emp_name       : prefs.getString('emp_name') ?? '',
        total_distance : totalDist.toString(),
        file_name      : '$dateStr.gpx',
        body           : Uint8List.fromList(bytes),
        location_date  : eventDate,
        location_time  : eventDate,
        posted         : 0,
      );

      await addLocation(model);
      await _repo.syncUnposted(deleteAfterPost: true);

      debugPrint(
          '✅ [LocVM] Location saved: $dateStr.gpx | dist=${totalDist.toStringAsFixed(3)} km');
    } catch (e) {
      debugPrint('❌ [LocVM] saveLocationFromConsolidatedFileForDate error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ NEW: PUBLIC CLOCK-OUT HELPER
  // Call this from your clock-out flow BEFORE clearing clock-in state:
  //
  //   await locationViewModel.saveLocationOnClockOut();
  //
  // It consolidates all GPX segments for today, then saves + posts to server.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveLocationOnClockOut() async {
    debugPrint('🏁 [LocVM] Clock-out: saving GPX location data...');
    try {
      // Step 1: merge all segment files into one daily consolidated file
      await consolidateDailyGPXData();
      // Step 2: save consolidated file to local DB and sync to API
      await saveLocationFromConsolidatedFileForDate(DateTime.now());
      debugPrint('✅ [LocVM] Clock-out GPX save complete');
    } catch (e) {
      debugPrint('❌ [LocVM] saveLocationOnClockOut error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION SERVICE STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkLocationServiceStatus() async {
    try {
      // ✅ FIX: Use corrected path
      final filePath = await _gpxFilePath();
      final file     = File(filePath);
      final exists   = await file.exists();
      final size     = exists ? await file.length() : 0;
      int   pts      = 0;

      if (exists) {
        final content = await _fileReadLock.synchronized(
                () => file.readAsString());
        if (content.isNotEmpty) {
          pts = _getTotalPoints(GpxReader().fromString(content));
        }
      }

      return {
        'serviceActive'   : true,
        'fileExists'      : exists,
        'fileSize'        : size,
        'pointsRecorded'  : pts,
        'filePath'        : filePath,
      };
    } catch (e) {
      return {'serviceActive': false, 'error': e.toString()};
    }
  }

  int _getTotalPoints(Gpx gpx) => gpx.trks
      .expand((t) => t.trksegs)
      .fold(0, (sum, s) => sum + s.trkpts.length);

  // ─────────────────────────────────────────────────────────────────────────
  // SYNC STATUS HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkSyncStatus() async {
    final prefs  = await SharedPreferences.getInstance();
    final status = prefs.getString('clockOutSyncStatus') ?? 'unknown';
    return {
      'syncStatus'     : status,
      'lastClockOutTime': prefs.getString('lastClockOutTime'),
      'lastDistance'   : prefs.getDouble('lastClockOutDistance'),
      'hasPendingSync' : ['pending', 'pending_local', 'retry_needed']
          .contains(status),
    };
  }

  Future<void> clearSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockOutSyncStatus');
    await prefs.remove('lastClockOutTime');
    await prefs.remove('lastClockOutDistance');
    await prefs.remove('pendingAttendanceOutId');
    debugPrint('🧹 [LocVM] Sync status cleared');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATABASE CRUD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> fetchAllLocation() async {
    allLocation.value = await _repo.getAll();
  }

  Future<void> addLocation(LocationModel model) async {
    await _repo.add(model);
    await fetchAllLocation();
  }

  Future<void> deleteLocation(String id) async {
    await _repo.delete(id);
    await fetchAllLocation();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PERMISSIONS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> requestPermissions() async {
    if (await Permission.notification.request().isDenied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _showLocationDialog();
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showLocationDialog();
      return;
    }

    if (await Permission.locationAlways.request().isDenied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  void _showLocationDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Location Required',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'For a better experience, your device will need to use Location Accuracy.'),
                SizedBox(height: 16),
                Text('The following settings should be on:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.radio_button_checked,
                      size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Device location'),
                ]),
                Row(children: [
                  Icon(Icons.radio_button_checked,
                      size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Location Accuracy'),
                ]),
                SizedBox(height: 12),
                Text(
                  'Location Accuracy provides more accurate location for apps and services.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('TURN ON'),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DAILY PROCESSING INIT
  // ─────────────────────────────────────────────────────────────────────────

  void _initializeDailyProcessing() async {
    final prefs = await SharedPreferences.getInstance();
    lastProcessedDate.value         = prefs.getString(_keyLastProcessedDate) ?? '';
    isDailyProcessingComplete.value =
        prefs.getBool(_keyIsDailyProcessingComplete) ?? false;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastProcessedDate.value != today) {
      isDailyProcessingComplete.value = false;
      await prefs.setBool(_keyIsDailyProcessingComplete, false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTO SYNC (on open + every 5 minutes)
  // ─────────────────────────────────────────────────────────────────────────

  void _startGpxAutoSync() {
    debugPrint('🚀 [LocVM] GPX auto-sync started');
    _syncGpxIfOnline(); // immediate
    _gpxSyncTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _syncGpxIfOnline());
  }

  Future<void> _syncGpxIfOnline() async {
    if (_isGpxAutoSyncing) return;
    _isGpxAutoSyncing = true;
    try {
      if (!await _hasInternet()) {
        debugPrint('❌ [LocVM] No internet — GPX sync skipped');
        return;
      }
      await _repo.syncUnposted(deleteAfterPost: true);
      debugPrint('✅ [LocVM] GPX sync complete');
    } catch (e) {
      debugPrint('❌ [LocVM] GPX sync error: $e');
    } finally {
      _isGpxAutoSyncing = false;
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}