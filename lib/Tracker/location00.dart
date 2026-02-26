// //
// // import 'dart:async' show Future, StreamSubscription, Completer;
// // import 'dart:io';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:gpx/gpx.dart';
// // import 'package:intl/intl.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class LocationService {
// //   late Gpx gpx;
// //   late Trk track;
// //   late Trkseg segment;
// //   late File file;
// //   late bool isFirstRun;
// //   late bool isConnected;
// //   late var lat, longi;
// //   late String userIdForLocation;
// //   late String userCityForLocatiion;
// //   late String userDesignationForLocation;
// //   late String userNameForLocation;
// //   late String rsmIdForLocation;
// //   late String nsmIdForLocation;
// //   late String smIdForLocation;
// //   late String dispatcherIdForLocation;
// //   late final filepath;
// //   late final Directory? downloadDirectory;
// //   late double totalDistance;
// //   late Position? lastTrackPoint;
// //   String gpxString = "";
// //
// //   // ✅ FIXED: Better initialization tracking
// //   bool _isInitialized = false;
// //   bool _isFirstLocationRecorded = false;
// //   Completer<void>? _initializationCompleter;
// //
// //   // ✅ ADD: Session management
// //   DateTime? _sessionStartTime;
// //   String? _lastSessionId;
// //   List<Trkseg> _segments = [];
// //
// //   LocationService() {
// //     totalDistance = 0.0;
// //     lastTrackPoint = null;
// //     _isInitialized = false;
// //     _isFirstLocationRecorded = false;
// //     _sessionStartTime = null;
// //     _lastSessionId = null;
// //     init();
// //     Firebase.initializeApp();
// //     lat = 0.0;
// //     longi = 0.0;
// //     isConnected = false;
// //   }
// //
// //   StreamSubscription<Position>? positionStream;
// //   LocationSettings locationSettings = AndroidSettings(
// //     accuracy: LocationAccuracy.high,
// //     distanceFilter: 10, // ✅ Increased to 10 meters
// //     forceLocationManager: true,
// //   );
// //
// //   Future<void> listenLocation() async {
// //     if (!_isInitialized) {
// //       await _initializeService();
// //     }
// //
// //     positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
// //         .listen((Position position) async {
// //       await _handleLocationUpdate(position);
// //     });
// //   }
// //
// //   // ✅ NEW: Check if we should start new segment for new session
// //   Future<void> checkAndStartNewSegment() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? lastClockOutTimeString = prefs.getString('lastClockOutTime');
// //     String? currentSessionStartString = prefs.getString('currentSessionStart');
// //
// //     if (lastClockOutTimeString != null && currentSessionStartString != null) {
// //       DateTime lastClockOutTime = DateTime.parse(lastClockOutTimeString);
// //       DateTime currentSessionStart = DateTime.parse(currentSessionStartString);
// //
// //       // If more than 30 minutes since last clock-out, start new segment
// //       if (currentSessionStart.difference(lastClockOutTime).inMinutes > 30) {
// //         await _startNewSegment();
// //         debugPrint("🔄 Starting new GPX segment - Previous session was ${currentSessionStart.difference(lastClockOutTime).inMinutes} minutes ago");
// //       }
// //     }
// //   }
// //
// //   // ✅ NEW: Start new segment
// //   Future<void> _startNewSegment() async {
// //     try {
// //       // Save current segment
// //       if (segment.trkpts.isNotEmpty) {
// //         _segments.add(segment);
// //       }
// //
// //       // Create new segment
// //       segment = Trkseg();
// //
// //       // Add to track if it exists, otherwise create new track
// //       if (track.trksegs.isEmpty) {
// //         track.trksegs = [segment];
// //       } else {
// //         track.trksegs.add(segment);
// //       }
// //
// //       // Reset last track point for new segment
// //       lastTrackPoint = null;
// //
// //       debugPrint("🔄 Started new GPX segment for new session");
// //       debugPrint("   - Previous segments: ${_segments.length}");
// //       debugPrint("   - Current segment points: ${segment.trkpts.length}");
// //
// //     } catch (e) {
// //       debugPrint("❌ Error starting new segment: $e");
// //     }
// //   }
// //
// //   Future<void> _initializeService() async {
// //     if (_initializationCompleter != null) {
// //       return _initializationCompleter!.future;
// //     }
// //
// //     _initializationCompleter = Completer<void>();
// //
// //     try {
// //       debugPrint("🔄 Initializing Location Service...");
// //
// //       // 1. Load user data first
// //       await _loadUserData();
// //
// //       // 2. Check for new session
// //       await checkAndStartNewSegment();
// //
// //       // 3. Initialize GPX file
// //       await _initializeGpxFile();
// //
// //       // 4. Wait for first valid location (BUT DON'T ADD TO DISTANCE)
// //       await _waitForFirstValidLocation();
// //
// //       _isInitialized = true;
// //       _initializationCompleter!.complete();
// //
// //       debugPrint("✅ Location Service Initialized Successfully");
// //
// //     } catch (e) {
// //       debugPrint("❌ Location Service Initialization Failed: $e");
// //       _initializationCompleter!.completeError(e);
// //     }
// //   }
// //
// //   // ✅ FIXED: Wait for first location but don't add to distance
// //   Future<void> _waitForFirstValidLocation() async {
// //     try {
// //       debugPrint("📍 Waiting for first valid location...");
// //
// //       Position initialPosition = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //         timeLimit: Duration(seconds: 15),
// //       );
// //
// //       // ✅ SET INITIAL POSITION BUT DON'T ADD TO TRACK POINTS
// //       lat = initialPosition.latitude.toString();
// //       longi = initialPosition.longitude.toString();
// //
// //       // ✅ SET LAST TRACK POINT FOR FUTURE DISTANCE CALCULATION
// //       lastTrackPoint = Position(
// //         latitude: initialPosition.latitude,
// //         longitude: initialPosition.longitude,
// //         accuracy: initialPosition.accuracy,
// //         altitude: initialPosition.altitude,
// //         altitudeAccuracy: initialPosition.altitudeAccuracy ?? 0,
// //         heading: initialPosition.heading ?? 0,
// //         headingAccuracy: initialPosition.headingAccuracy ?? 0,
// //         speed: initialPosition.speed,
// //         speedAccuracy: initialPosition.speedAccuracy ?? 0,
// //         timestamp: initialPosition.timestamp,
// //       );
// //
// //       _isFirstLocationRecorded = true;
// //
// //       debugPrint("🎯 Initial Position Set (Not added to track):");
// //       debugPrint("   - Lat: ${initialPosition.latitude}");
// //       debugPrint("   - Lng: ${initialPosition.longitude}");
// //       debugPrint("   - Accuracy: ${initialPosition.accuracy} meters");
// //
// //     } catch (e) {
// //       debugPrint("⚠️ Could not get initial position: $e");
// //       // Set default values to avoid null issues
// //       lastTrackPoint = null;
// //     }
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     SharedPreferences pref = await SharedPreferences.getInstance();
// //     await pref.reload();
// //
// //     userNameForLocation = pref.getString("userName") ?? "USERName";
// //     userIdForLocation = pref.getString("userId") ?? "USERId";
// //     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
// //     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
// //     smIdForLocation = pref.getString("userSM") ?? "smUSER";
// //     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
// //     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
// //     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
// //   }
// //
// //   Future<void> _initializeGpxFile() async {
// //     try {
// //       gpx = Gpx();
// //       track = Trk();
// //       segment = Trkseg();
// //       _segments = [];
// //
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       downloadDirectory = await getDownloadsDirectory();
// //
// //       final filePath = "${downloadDirectory!.path}/track_${userIdForLocation}_$date.gpx";
// //       file = File(filePath);
// //
// //       if (file.existsSync()) {
// //         String existingContent = file.readAsStringSync();
// //         if (existingContent.trim().isNotEmpty) {
// //           Gpx existingGpx = GpxReader().fromString(existingContent);
// //           if (existingGpx.trks.isNotEmpty) {
// //             // Load existing tracks and segments
// //             gpx.trks = existingGpx.trks;
// //             track = gpx.trks[0];
// //
// //             // Load all existing segments
// //             if (track.trksegs.isNotEmpty) {
// //               _segments = List<Trkseg>.from(track.trksegs);
// //               segment = track.trksegs.last;
// //             } else {
// //               track.trksegs.add(segment);
// //             }
// //
// //             isFirstRun = false;
// //
// //             // ✅ CALCULATE EXISTING DISTANCE FROM FILE
// //             totalDistance = await _calculateDistanceFromExistingFile();
// //             debugPrint("📂 Existing GPX loaded. Distance: ${totalDistance.toStringAsFixed(3)} km");
// //             debugPrint("   - Segments: ${track.trksegs.length}");
// //             debugPrint("   - Total points: ${_getTotalPoints()}");
// //           } else {
// //             _createNewGpxStructure();
// //           }
// //         } else {
// //           _createNewGpxStructure();
// //         }
// //       } else {
// //         _createNewGpxStructure();
// //       }
// //
// //     } catch (e) {
// //       debugPrint('❌ Error initializing GPX file: $e');
// //       _createNewGpxStructure();
// //     }
// //   }
// //
// //   // ✅ FIXED: Calculate distance from existing file
// //   Future<double> _calculateDistanceFromExistingFile() async {
// //     try {
// //       if (!file.existsSync()) return 0.0;
// //
// //       String gpxContent = await file.readAsString();
// //       if (gpxContent.isEmpty) return 0.0;
// //
// //       Gpx existingGpx = GpxReader().fromString(gpxContent);
// //       double existingDistance = 0.0;
// //
// //       for (var track in existingGpx.trks) {
// //         for (var segment in track.trksegs) {
// //           if (segment.trkpts.length < 2) continue;
// //
// //           for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //             double distance = calculateDistance(
// //               segment.trkpts[i].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i].lon?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
// //             );
// //             existingDistance += distance;
// //           }
// //         }
// //       }
// //
// //       return existingDistance;
// //     } catch (e) {
// //       debugPrint("❌ Error calculating existing distance: $e");
// //       return 0.0;
// //     }
// //   }
// //
// //   void _createNewGpxStructure() {
// //     gpx = Gpx();
// //     track = Trk();
// //     segment = Trkseg();
// //     _segments = [];
// //
// //     track.trksegs.add(segment);
// //     gpx.trks.add(track);
// //
// //     isFirstRun = true;
// //     file.createSync(recursive: true);
// //     totalDistance = 0.0; // ✅ RESET DISTANCE FOR NEW FILE
// //     debugPrint("📁 Created new GPX file structure");
// //   }
// //
// //   // ✅ FIXED: Handle location updates with proper distance calculation
// //   Future<void> _handleLocationUpdate(Position position) async {
// //     // ✅ IGNORE LOW ACCURACY POSITIONS
// //     if (position.accuracy > 30.0) { // Reduced from 50m to 30m for better accuracy
// //       debugPrint("⚠️ Ignoring low accuracy position: ${position.accuracy}m");
// //       return;
// //     }
// //
// //     // ✅ CHECK FOR IMPOSSIBLE SPEEDS (GPS drift)
// //     if (position.speed > 300) { // If speed > 300 km/h (83 m/s), it's GPS error
// //       debugPrint("⚠️ Ignoring impossible speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h");
// //       return;
// //     }
// //
// //     // ✅ CHECK FOR SUDDEN JUMPS (GPS spikes)
// //     if (lastTrackPoint != null) {
// //       double distanceFromLast = calculateDistance(
// //         lastTrackPoint!.latitude,
// //         lastTrackPoint!.longitude,
// //         position.latitude,
// //         position.longitude,
// //       );
// //
// //       // If jumped more than 500 meters in 3 seconds (600 km/h), ignore
// //       if (distanceFromLast > 0.5 && position.timestamp.difference(lastTrackPoint!.timestamp).inSeconds < 3) {
// //         debugPrint("⚠️ Ignoring GPS spike: ${(distanceFromLast * 1000).toStringAsFixed(0)} meters in ${position.timestamp.difference(lastTrackPoint!.timestamp).inSeconds} seconds");
// //         return;
// //       }
// //     }
// //
// //     // ✅ UPDATE CURRENT COORDINATES
// //     lat = position.latitude.toString();
// //     longi = position.longitude.toString();
// //
// //     // ✅ CREATE TRACK POINT
// //     final trackPoint = Wpt(
// //       lat: position.latitude,
// //       lon: position.longitude,
// //       time: DateTime.now(),
// //     );
// //
// //     // ✅ ADD TO SEGMENT ONLY IF WE HAVE PREVIOUS POINT FOR DISTANCE CALCULATION
// //     bool shouldAddPoint = false;
// //     double segmentDistance = 0.0;
// //
// //     if (lastTrackPoint != null) {
// //       // ✅ CALCULATE DISTANCE FROM LAST POINT
// //       segmentDistance = calculateDistance(
// //         lastTrackPoint!.latitude,
// //         lastTrackPoint!.longitude,
// //         position.latitude,
// //         position.longitude,
// //       );
// //
// //       // ✅ ONLY ADD POINT IF MOVED SIGNIFICANT DISTANCE (more than 10 meters)
// //       if (segmentDistance > 0.010) { // 10 meters in kilometers
// //         shouldAddPoint = true;
// //         totalDistance += segmentDistance;
// //
// //         debugPrint("📍 Movement Detected:");
// //         debugPrint("   - Distance: ${(segmentDistance * 1000).toStringAsFixed(1)} meters");
// //         debugPrint("   - Total: ${totalDistance.toStringAsFixed(3)} km");
// //         debugPrint("   - Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h");
// //         debugPrint("   - Accuracy: ${position.accuracy}m");
// //       } else {
// //         debugPrint("➡️ Minimal movement: ${(segmentDistance * 1000).toStringAsFixed(1)} meters - Ignoring");
// //       }
// //     } else {
// //       // ✅ FIRST POINT AFTER INITIALIZATION - ADD IT
// //       shouldAddPoint = true;
// //       debugPrint("🎯 Adding first track point of segment");
// //       debugPrint("   - Lat: ${position.latitude}");
// //       debugPrint("   - Lng: ${position.longitude}");
// //       debugPrint("   - Accuracy: ${position.accuracy}m");
// //     }
// //
// //     if (shouldAddPoint) {
// //       segment.trkpts.add(trackPoint);
// //
// //       // ✅ LIMIT SEGMENT SIZE TO PREVENT MEMORY ISSUES
// //       if (segment.trkpts.length > 1000) {
// //         await _startNewSegment();
// //       }
// //
// //       _updateGpxFile();
// //     }
// //
// //     // ✅ UPDATE LAST TRACK POINT FOR NEXT CALCULATION
// //     lastTrackPoint = Position(
// //       latitude: position.latitude,
// //       longitude: position.longitude,
// //       accuracy: position.accuracy,
// //       altitude: position.altitude,
// //       altitudeAccuracy: position.altitudeAccuracy ?? 0,
// //       heading: position.heading ?? 0,
// //       headingAccuracy: position.headingAccuracy ?? 0,
// //       speed: position.speed,
// //       speedAccuracy: position.speedAccuracy ?? 0,
// //       timestamp: position.timestamp,
// //     );
// //
// //     // ✅ UPDATE FIREBASE
// //     await _updateFirebase(position);
// //   }
// //
// //   void _updateGpxFile() {
// //     try {
// //       // Ensure all segments are included in track
// //       if (_segments.isNotEmpty) {
// //         track.trksegs = List<Trkseg>.from(_segments);
// //         if (!track.trksegs.contains(segment)) {
// //           track.trksegs.add(segment);
// //         }
// //       }
// //
// //       gpxString = GpxWriter().asString(gpx, pretty: true);
// //       file.writeAsStringSync(gpxString);
// //
// //       // Debug info
// //       debugPrint("📁 GPX File Updated:");
// //       debugPrint("   - Segments: ${track.trksegs.length}");
// //       debugPrint("   - Current segment points: ${segment.trkpts.length}");
// //       debugPrint("   - Total points: ${_getTotalPoints()}");
// //       debugPrint("   - File size: ${file.lengthSync()} bytes");
// //
// //     } catch (e) {
// //       debugPrint('❌ Error updating GPX file: $e');
// //     }
// //   }
// //
// //   Future<void> _updateFirebase(Position position) async {
// //     isConnected = await isNetworkAvailableForFirebase();
// //
// //     if (isConnected) {
// //       try {
// //         await FirebaseFirestore.instance
// //             .collection('location')
// //             .doc(userIdForLocation.toString())
// //             .set({
// //           'latitude': position.latitude,
// //           'longitude': position.longitude,
// //           'name': userNameForLocation.toString(),
// //           'userId': userIdForLocation.toString(),
// //           'city': userCityForLocatiion.toString(),
// //           'designation': userDesignationForLocation.toString(),
// //           'RSM_ID': rsmIdForLocation.toString(),
// //           'NSM_ID': nsmIdForLocation.toString(),
// //           'SM_ID': smIdForLocation.toString(),
// //           'DISPATCHER_ID' : dispatcherIdForLocation.toString(),
// //           'isActive': true,
// //           'totalDistance': totalDistance,
// //           'accuracy': position.accuracy,
// //           'speed': position.speed * 3.6, // Convert m/s to km/h
// //           'altitude': position.altitude,
// //           'heading': position.heading,
// //           'segments': track.trksegs.length,
// //           'points': _getTotalPoints(),
// //           'lastUpdate': FieldValue.serverTimestamp(),
// //         }, SetOptions(merge: true));
// //       } catch (e) {
// //         debugPrint('❌ Firebase update error: $e');
// //       }
// //     }
// //   }
// //
// //   // ✅ FIXED: Get current distance
// //   double getCurrentDistance() {
// //     return double.parse(totalDistance.toStringAsFixed(3)); // Return with 3 decimal places
// //   }
// //
// //   Future<double> calculateCurrentDistance() async {
// //     try {
// //       // First calculate from memory
// //       double memoryDistance = totalDistance;
// //
// //       // Then verify with file calculation
// //       if (!file.existsSync()) {
// //         return memoryDistance;
// //       }
// //
// //       String gpxContent = await file.readAsString();
// //       if (gpxContent.isEmpty) return memoryDistance;
// //
// //       Gpx gpx = GpxReader().fromString(gpxContent);
// //       double calculatedDistance = 0.0;
// //
// //       for (var track in gpx.trks) {
// //         for (var segment in track.trksegs) {
// //           if (segment.trkpts.length < 2) continue;
// //
// //           for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //             double distance = calculateDistance(
// //               segment.trkpts[i].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i].lon?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
// //             );
// //             calculatedDistance += distance;
// //           }
// //         }
// //       }
// //
// //       // Use the larger of the two distances (memory vs file)
// //       double finalDistance = calculatedDistance > memoryDistance ? calculatedDistance : memoryDistance;
// //
// //       // Update total distance
// //       totalDistance = finalDistance;
// //
// //       debugPrint("📏 Distance Calculation:");
// //       debugPrint("   - Memory: ${memoryDistance.toStringAsFixed(3)} km");
// //       debugPrint("   - File: ${calculatedDistance.toStringAsFixed(3)} km");
// //       debugPrint("   - Final: ${finalDistance.toStringAsFixed(3)} km");
// //
// //       return finalDistance;
// //
// //     } catch (e) {
// //       debugPrint('❌ Error in calculateCurrentDistance: $e');
// //       return totalDistance;
// //     }
// //   }
// //
// //   // Helper method to get total points
// //   int _getTotalPoints() {
// //     int total = 0;
// //     for (var seg in track.trksegs) {
// //       total += seg.trkpts.length;
// //     }
// //     return total;
// //   }
// //
// //   // Rest of your existing methods...
// //   Future<void> init() async {
// //     SharedPreferences pref = await SharedPreferences.getInstance();
// //     await pref.reload();
// //     userNameForLocation = pref.getString("userName") ?? "USERName";
// //     userIdForLocation = pref.getString("userId") ?? "USERId";
// //     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
// //     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
// //     smIdForLocation = pref.getString("userSM") ?? "smUSER";
// //     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
// //     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
// //     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
// //   }
// //
// //   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// //     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
// //     return (distanceInMeters / 1000); // Convert to kilometers
// //   }
// //
// //   Future<void> deleteDocument() async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('location')
// //           .doc(userIdForLocation)
// //           .delete();
// //     } catch (e) {
// //       debugPrint("❌ Error deleting document: $e");
// //     }
// //   }
// //
// //   Future<void> stopListening() async {
// //     try {
// //       positionStream?.cancel();
// //       await calculateCurrentDistance();
// //
// //       SharedPreferences pref = await SharedPreferences.getInstance();
// //       await pref.setDouble("TotalDistance", totalDistance);
// //
// //       // Save last session info
// //       await pref.setString("lastSessionEnd", DateTime.now().toIso8601String());
// //
// //       debugPrint("🛑 Location listening stopped");
// //       debugPrint("📏 Final Distance: ${totalDistance.toStringAsFixed(3)} km");
// //       debugPrint("📊 Session Summary:");
// //       debugPrint("   - Segments: ${track.trksegs.length}");
// //       debugPrint("   - Total points: ${_getTotalPoints()}");
// //       debugPrint("   - File: ${file.path}");
// //       debugPrint("   - File size: ${file.lengthSync()} bytes");
// //
// //     } catch (e) {
// //       debugPrint("❌ ERROR in stopListening: ${e.toString()}");
// //     }
// //   }
// //
// //   // ✅ NEW: Reset distance (for testing)
// //   void resetDistance() {
// //     totalDistance = 0.0;
// //     debugPrint("🔄 Distance reset to 0");
// //   }
// //
// //   // ✅ NEW: Get service status for debugging
// //   Map<String, dynamic> getServiceStatus() {
// //     return {
// //       'isInitialized': _isInitialized,
// //       'isFirstLocationRecorded': _isFirstLocationRecorded,
// //       'totalDistance': totalDistance,
// //       'pointsRecorded': segment.trkpts.length,
// //       'totalSegments': track.trksegs.length,
// //       'totalAllPoints': _getTotalPoints(),
// //       'lastTrackPoint': lastTrackPoint != null ?
// //       '${lastTrackPoint!.latitude}, ${lastTrackPoint!.longitude}' : 'None',
// //       'filePath': file.path,
// //       'fileExists': file.existsSync(),
// //       'fileSize': file.existsSync() ? file.lengthSync() : 0,
// //     };
// //   }
// //
// //   // ✅ NEW: Get GPX file content
// //   Future<String> getGpxContent() async {
// //     try {
// //       if (file.existsSync()) {
// //         return await file.readAsString();
// //       }
// //       return gpxString;
// //     } catch (e) {
// //       debugPrint("❌ Error getting GPX content: $e");
// //       return "";
// //     }
// //   }
// //
// //   // ✅ NEW: Get consolidated GPX data (all segments)
// //   Future<String> getConsolidatedGpx() async {
// //     try {
// //       // Create a consolidated GPX with all segments
// //       Gpx consolidatedGpx = Gpx();
// //       Trk consolidatedTrack = Trk();
// //       consolidatedTrack.name = "Consolidated Track ${DateFormat('dd-MM-yyyy').format(DateTime.now())}";
// //
// //       // Add all segments to consolidated track
// //       for (var seg in track.trksegs) {
// //         if (seg.trkpts.isNotEmpty) {
// //           consolidatedTrack.trksegs.add(seg);
// //         }
// //       }
// //
// //       consolidatedGpx.trks.add(consolidatedTrack);
// //       return GpxWriter().asString(consolidatedGpx, pretty: true);
// //     } catch (e) {
// //       debugPrint("❌ Error consolidating GPX: $e");
// //       return gpxString;
// //     }
// //   }
// //
// //   // ✅ NEW: Save GPX file with specific name (for consolidation)
// //   Future<void> saveGpxFile(String filePath) async {
// //     try {
// //       File outputFile = File(filePath);
// //       String content = await getConsolidatedGpx();
// //       await outputFile.writeAsString(content);
// //       debugPrint("💾 GPX saved to: $filePath");
// //       debugPrint("   - Size: ${outputFile.lengthSync()} bytes");
// //       debugPrint("   - Segments: ${track.trksegs.length}");
// //       debugPrint("   - Points: ${_getTotalPoints()}");
// //     } catch (e) {
// //       debugPrint("❌ Error saving GPX file: $e");
// //     }
// //   }
// // }
//
//
// ///added 24-02-2026
// // import 'dart:async';
// // import 'dart:async' show Future, StreamSubscription, Completer;
// // import 'dart:io';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:gpx/gpx.dart';
// // import 'package:intl/intl.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:synchronized/synchronized.dart'; // Add this dependency
// //
// // class LocationService {
// //   late Gpx gpx;
// //   late Trk track;
// //   late Trkseg segment;
// //   late File file;
// //   late bool isFirstRun;
// //   late bool isConnected;
// //   late var lat, longi;
// //   late String userIdForLocation;
// //   late String userCityForLocatiion;
// //   late String userDesignationForLocation;
// //   late String userNameForLocation;
// //   late String rsmIdForLocation;
// //   late String nsmIdForLocation;
// //   late String smIdForLocation;
// //   late String dispatcherIdForLocation;
// //   late final filepath;
// //   late final Directory? downloadDirectory;
// //   late double totalDistance;
// //   late Position? lastTrackPoint;
// //   String gpxString = "";
// //
// //   // ✅ FIXED: Better initialization tracking
// //   bool _isInitialized = false;
// //   bool _isFirstLocationRecorded = false;
// //   Completer<void>? _initializationCompleter;
// //
// //   // ✅ ADD: Session management
// //   DateTime? _sessionStartTime;
// //   String? _lastSessionId;
// //   List<Trkseg> _segments = [];
// //
// //   // ✅ CRITICAL: File write lock to prevent race conditions
// //   final Lock _fileWriteLock = Lock();
// //
// //   // ✅ ADD: Write debouncing
// //   Timer? _writeDebounceTimer;
// //   static const Duration _writeDebounceDelay = Duration(seconds: 2);
// //
// //   // ✅ ADD: Batch writing
// //   bool _pendingWrite = false;
// //
// //   LocationService() {
// //     totalDistance = 0.0;
// //     lastTrackPoint = null;
// //     _isInitialized = false;
// //     _isFirstLocationRecorded = false;
// //     _sessionStartTime = null;
// //     _lastSessionId = null;
// //     init();
// //     Firebase.initializeApp();
// //     lat = 0.0;
// //     longi = 0.0;
// //     isConnected = false;
// //   }
// //
// //   StreamSubscription<Position>? positionStream;
// //   LocationSettings locationSettings = AndroidSettings(
// //     accuracy: LocationAccuracy.high,
// //     distanceFilter: 10,
// //     forceLocationManager: true,
// //   );
// //
// //   Future<void> listenLocation() async {
// //     if (!_isInitialized) {
// //       await _initializeService();
// //     }
// //
// //     positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
// //         .listen((Position position) async {
// //       await _handleLocationUpdate(position);
// //     });
// //   }
// //
// //   Future<void> checkAndStartNewSegment() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? lastClockOutTimeString = prefs.getString('lastClockOutTime');
// //     String? currentSessionStartString = prefs.getString('currentSessionStart');
// //
// //     if (lastClockOutTimeString != null && currentSessionStartString != null) {
// //       DateTime lastClockOutTime = DateTime.parse(lastClockOutTimeString);
// //       DateTime currentSessionStart = DateTime.parse(currentSessionStartString);
// //
// //       if (currentSessionStart.difference(lastClockOutTime).inMinutes > 30) {
// //         await _startNewSegment();
// //         debugPrint("🔄 Starting new GPX segment");
// //       }
// //     }
// //   }
// //
// //   Future<void> _startNewSegment() async {
// //     try {
// //       if (segment.trkpts.isNotEmpty) {
// //         _segments.add(segment);
// //       }
// //
// //       segment = Trkseg();
// //
// //       if (track.trksegs.isEmpty) {
// //         track.trksegs = [segment];
// //       } else {
// //         track.trksegs.add(segment);
// //       }
// //
// //       lastTrackPoint = null;
// //       debugPrint("🔄 Started new GPX segment");
// //     } catch (e) {
// //       debugPrint("❌ Error starting new segment: $e");
// //     }
// //   }
// //
// //   Future<void> _initializeService() async {
// //     if (_initializationCompleter != null) {
// //       return _initializationCompleter!.future;
// //     }
// //
// //     _initializationCompleter = Completer<void>();
// //
// //     try {
// //       debugPrint("🔄 Initializing Location Service...");
// //       await _loadUserData();
// //       await checkAndStartNewSegment();
// //       await _initializeGpxFile();
// //       await _waitForFirstValidLocation();
// //
// //       _isInitialized = true;
// //       _initializationCompleter!.complete();
// //       debugPrint("✅ Location Service Initialized");
// //     } catch (e) {
// //       debugPrint("❌ Initialization Failed: $e");
// //       _initializationCompleter!.completeError(e);
// //     }
// //   }
// //
// //   Future<void> _waitForFirstValidLocation() async {
// //     try {
// //       debugPrint("📍 Waiting for first valid location...");
// //       Position initialPosition = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //         timeLimit: Duration(seconds: 15),
// //       );
// //
// //       lat = initialPosition.latitude.toString();
// //       longi = initialPosition.longitude.toString();
// //
// //       lastTrackPoint = Position(
// //         latitude: initialPosition.latitude,
// //         longitude: initialPosition.longitude,
// //         accuracy: initialPosition.accuracy,
// //         altitude: initialPosition.altitude,
// //         altitudeAccuracy: initialPosition.altitudeAccuracy ?? 0,
// //         heading: initialPosition.heading ?? 0,
// //         headingAccuracy: initialPosition.headingAccuracy ?? 0,
// //         speed: initialPosition.speed,
// //         speedAccuracy: initialPosition.speedAccuracy ?? 0,
// //         timestamp: initialPosition.timestamp,
// //       );
// //
// //       _isFirstLocationRecorded = true;
// //       debugPrint("🎯 Initial Position Set");
// //     } catch (e) {
// //       debugPrint("⚠️ Could not get initial position: $e");
// //       lastTrackPoint = null;
// //     }
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     SharedPreferences pref = await SharedPreferences.getInstance();
// //     await pref.reload();
// //
// //     userNameForLocation = pref.getString("userName") ?? "USERName";
// //     userIdForLocation = pref.getString("userId") ?? "USERId";
// //     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
// //     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
// //     smIdForLocation = pref.getString("userSM") ?? "smUSER";
// //     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
// //     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
// //     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
// //   }
// //
// //   Future<void> _initializeGpxFile() async {
// //     try {
// //       gpx = Gpx();
// //       track = Trk();
// //       segment = Trkseg();
// //       _segments = [];
// //
// //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
// //       downloadDirectory = await getDownloadsDirectory();
// //
// //       final filePath = "${downloadDirectory!.path}/track_${userIdForLocation}_$date.gpx";
// //       file = File(filePath);
// //
// //       if (file.existsSync()) {
// //         String existingContent = await file.readAsString(); // ✅ Use async
// //         if (existingContent.trim().isNotEmpty) {
// //           try {
// //             Gpx existingGpx = GpxReader().fromString(existingContent);
// //             if (existingGpx.trks.isNotEmpty) {
// //               gpx.trks = existingGpx.trks;
// //               track = gpx.trks[0];
// //
// //               if (track.trksegs.isNotEmpty) {
// //                 _segments = List<Trkseg>.from(track.trksegs);
// //                 segment = track.trksegs.last;
// //               } else {
// //                 track.trksegs.add(segment);
// //               }
// //
// //               isFirstRun = false;
// //               totalDistance = await _calculateDistanceFromExistingFile();
// //               debugPrint("📂 Existing GPX loaded: ${totalDistance.toStringAsFixed(3)} km");
// //             } else {
// //               _createNewGpxStructure();
// //             }
// //           } catch (e) {
// //             debugPrint("⚠️ Corrupted GPX file, creating new: $e");
// //             _createNewGpxStructure();
// //           }
// //         } else {
// //           _createNewGpxStructure();
// //         }
// //       } else {
// //         _createNewGpxStructure();
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error initializing GPX file: $e');
// //       _createNewGpxStructure();
// //     }
// //   }
// //
// //   Future<double> _calculateDistanceFromExistingFile() async {
// //     try {
// //       if (!file.existsSync()) return 0.0;
// //       String gpxContent = await file.readAsString();
// //       if (gpxContent.isEmpty) return 0.0;
// //
// //       Gpx existingGpx = GpxReader().fromString(gpxContent);
// //       double existingDistance = 0.0;
// //
// //       for (var track in existingGpx.trks) {
// //         for (var segment in track.trksegs) {
// //           if (segment.trkpts.length < 2) continue;
// //           for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //             double distance = calculateDistance(
// //               segment.trkpts[i].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i].lon?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
// //             );
// //             existingDistance += distance;
// //           }
// //         }
// //       }
// //       return existingDistance;
// //     } catch (e) {
// //       debugPrint("❌ Error calculating existing distance: $e");
// //       return 0.0;
// //     }
// //   }
// //
// //   void _createNewGpxStructure() {
// //     gpx = Gpx();
// //     track = Trk();
// //     segment = Trkseg();
// //     _segments = [];
// //
// //     track.trksegs.add(segment);
// //     gpx.trks.add(track);
// //
// //     isFirstRun = true;
// //     file.createSync(recursive: true);
// //     totalDistance = 0.0;
// //     debugPrint("📁 Created new GPX file structure");
// //   }
// //
// //   Future<void> _handleLocationUpdate(Position position) async {
// //     // ✅ Quality checks
// //     if (position.accuracy > 30.0) {
// //       debugPrint("⚠️ Low accuracy: ${position.accuracy}m");
// //       return;
// //     }
// //
// //     if (position.speed > 300) {
// //       debugPrint("⚠️ Impossible speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h");
// //       return;
// //     }
// //
// //     if (lastTrackPoint != null) {
// //       double distanceFromLast = calculateDistance(
// //         lastTrackPoint!.latitude,
// //         lastTrackPoint!.longitude,
// //         position.latitude,
// //         position.longitude,
// //       );
// //
// //       if (distanceFromLast > 0.5 && position.timestamp.difference(lastTrackPoint!.timestamp).inSeconds < 3) {
// //         debugPrint("⚠️ GPS spike detected");
// //         return;
// //       }
// //     }
// //
// //     lat = position.latitude.toString();
// //     longi = position.longitude.toString();
// //
// //     final trackPoint = Wpt(
// //       lat: position.latitude,
// //       lon: position.longitude,
// //       time: DateTime.now(),
// //     );
// //
// //     bool shouldAddPoint = false;
// //     double segmentDistance = 0.0;
// //
// //     if (lastTrackPoint != null) {
// //       segmentDistance = calculateDistance(
// //         lastTrackPoint!.latitude,
// //         lastTrackPoint!.longitude,
// //         position.latitude,
// //         position.longitude,
// //       );
// //
// //       if (segmentDistance > 0.010) { // 10 meters
// //         shouldAddPoint = true;
// //         totalDistance += segmentDistance;
// //         debugPrint("📍 Movement: ${(segmentDistance * 1000).toStringAsFixed(1)}m, Total: ${totalDistance.toStringAsFixed(3)} km");
// //       }
// //     } else {
// //       shouldAddPoint = true;
// //       debugPrint("🎯 First track point added");
// //     }
// //
// //     if (shouldAddPoint) {
// //       segment.trkpts.add(trackPoint);
// //
// //       // ✅ Limit segment size
// //       if (segment.trkpts.length > 1000) {
// //         await _startNewSegment();
// //       }
// //
// //       // ✅ Debounced file write instead of immediate write
// //       _debouncedUpdateGpxFile();
// //     }
// //
// //     lastTrackPoint = Position(
// //       latitude: position.latitude,
// //       longitude: position.longitude,
// //       accuracy: position.accuracy,
// //       altitude: position.altitude,
// //       altitudeAccuracy: position.altitudeAccuracy ?? 0,
// //       heading: position.heading ?? 0,
// //       headingAccuracy: position.headingAccuracy ?? 0,
// //       speed: position.speed,
// //       speedAccuracy: position.speedAccuracy ?? 0,
// //       timestamp: position.timestamp,
// //     );
// //
// //     await _updateFirebase(position);
// //   }
// //
// //   // ✅ NEW: Debounced file writing to prevent race conditions
// //   void _debouncedUpdateGpxFile() {
// //     _pendingWrite = true;
// //     _writeDebounceTimer?.cancel();
// //     _writeDebounceTimer = Timer(_writeDebounceDelay, () {
// //       _performFileWrite();
// //     });
// //   }
// //
// //   // ✅ NEW: Synchronized file write with proper locking
// //   Future<void> _performFileWrite() async {
// //     if (!_pendingWrite) return;
// //
// //     await _fileWriteLock.synchronized(() async {
// //       try {
// //         // Ensure all segments are included
// //         if (_segments.isNotEmpty) {
// //           track.trksegs = List<Trkseg>.from(_segments);
// //           if (!track.trksegs.contains(segment)) {
// //             track.trksegs.add(segment);
// //           }
// //         }
// //
// //         gpxString = GpxWriter().asString(gpx, pretty: true);
// //
// //         // ✅ Use async write with flush for data integrity
// //         await file.writeAsString(gpxString, flush: true);
// //         _pendingWrite = false;
// //
// //         debugPrint("📁 GPX Updated: ${track.trksegs.length} segments, ${_getTotalPoints()} points");
// //       } catch (e) {
// //         debugPrint('❌ Error writing GPX: $e');
// //       }
// //     });
// //   }
// //
// //   Future<void> _updateFirebase(Position position) async {
// //     isConnected = await isNetworkAvailableForFirebase();
// //
// //     if (isConnected) {
// //       try {
// //         await FirebaseFirestore.instance
// //             .collection('location')
// //             .doc(userIdForLocation.toString())
// //             .set({
// //           'latitude': position.latitude,
// //           'longitude': position.longitude,
// //           'name': userNameForLocation.toString(),
// //           'userId': userIdForLocation.toString(),
// //           'city': userCityForLocatiion.toString(),
// //           'designation': userDesignationForLocation.toString(),
// //           'RSM_ID': rsmIdForLocation.toString(),
// //           'NSM_ID': nsmIdForLocation.toString(),
// //           'SM_ID': smIdForLocation.toString(),
// //           'DISPATCHER_ID': dispatcherIdForLocation.toString(),
// //           'isActive': true,
// //           'totalDistance': totalDistance,
// //           'accuracy': position.accuracy,
// //           'speed': position.speed * 3.6,
// //           'altitude': position.altitude,
// //           'heading': position.heading,
// //           'segments': track.trksegs.length,
// //           'points': _getTotalPoints(),
// //           'lastUpdate': FieldValue.serverTimestamp(),
// //         }, SetOptions(merge: true));
// //       } catch (e) {
// //         debugPrint('❌ Firebase update error: $e');
// //       }
// //     }
// //   }
// //
// //   double getCurrentDistance() {
// //     return double.parse(totalDistance.toStringAsFixed(3));
// //   }
// //
// //   Future<double> calculateCurrentDistance() async {
// //     try {
// //       double memoryDistance = totalDistance;
// //
// //       if (!file.existsSync()) return memoryDistance;
// //
// //       String gpxContent = await file.readAsString();
// //       if (gpxContent.isEmpty) return memoryDistance;
// //
// //       Gpx gpx = GpxReader().fromString(gpxContent);
// //       double calculatedDistance = 0.0;
// //
// //       for (var track in gpx.trks) {
// //         for (var segment in track.trksegs) {
// //           if (segment.trkpts.length < 2) continue;
// //           for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //             double distance = calculateDistance(
// //               segment.trkpts[i].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i].lon?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
// //               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
// //             );
// //             calculatedDistance += distance;
// //           }
// //         }
// //       }
// //
// //       double finalDistance = calculatedDistance > memoryDistance ? calculatedDistance : memoryDistance;
// //       totalDistance = finalDistance;
// //
// //       debugPrint("📏 Distance: Memory=${memoryDistance.toStringAsFixed(3)}km, File=${calculatedDistance.toStringAsFixed(3)}km");
// //       return finalDistance;
// //     } catch (e) {
// //       debugPrint('❌ Error calculating distance: $e');
// //       return totalDistance;
// //     }
// //   }
// //
// //   int _getTotalPoints() {
// //     int total = 0;
// //     for (var seg in track.trksegs) {
// //       total += seg.trkpts.length;
// //     }
// //     return total;
// //   }
// //
// //   Future<void> init() async {
// //     SharedPreferences pref = await SharedPreferences.getInstance();
// //     await pref.reload();
// //     userNameForLocation = pref.getString("userName") ?? "USERName";
// //     userIdForLocation = pref.getString("userId") ?? "USERId";
// //     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
// //     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
// //     smIdForLocation = pref.getString("userSM") ?? "smUSER";
// //     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
// //     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
// //     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
// //   }
// //
// //   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// //     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
// //     return (distanceInMeters / 1000);
// //   }
// //
// //   Future<void> deleteDocument() async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('location')
// //           .doc(userIdForLocation)
// //           .delete();
// //     } catch (e) {
// //       debugPrint("❌ Error deleting document: $e");
// //     }
// //   }
// //
// //   Future<void> stopListening() async {
// //     try {
// //       positionStream?.cancel();
// //
// //       // ✅ Ensure pending writes complete before stopping
// //       _writeDebounceTimer?.cancel();
// //       if (_pendingWrite) {
// //         await _performFileWrite();
// //       }
// //
// //       await calculateCurrentDistance();
// //
// //       SharedPreferences pref = await SharedPreferences.getInstance();
// //       await pref.setDouble("TotalDistance", totalDistance);
// //       await pref.setString("lastSessionEnd", DateTime.now().toIso8601String());
// //
// //       debugPrint("🛑 Stopped. Final: ${totalDistance.toStringAsFixed(3)} km");
// //     } catch (e) {
// //       debugPrint("❌ ERROR in stopListening: ${e.toString()}");
// //     }
// //   }
// //
// //   void resetDistance() {
// //     totalDistance = 0.0;
// //     debugPrint("🔄 Distance reset");
// //   }
// //
// //   Map<String, dynamic> getServiceStatus() {
// //     return {
// //       'isInitialized': _isInitialized,
// //       'isFirstLocationRecorded': _isFirstLocationRecorded,
// //       'totalDistance': totalDistance,
// //       'pointsRecorded': segment.trkpts.length,
// //       'totalSegments': track.trksegs.length,
// //       'totalAllPoints': _getTotalPoints(),
// //       'lastTrackPoint': lastTrackPoint != null ?
// //       '${lastTrackPoint!.latitude}, ${lastTrackPoint!.longitude}' : 'None',
// //       'filePath': file.path,
// //       'fileExists': file.existsSync(),
// //       'fileSize': file.existsSync() ? file.lengthSync() : 0,
// //       'pendingWrite': _pendingWrite,
// //     };
// //   }
// //
// //   Future<String> getGpxContent() async {
// //     try {
// //       if (file.existsSync()) {
// //         return await file.readAsString();
// //       }
// //       return gpxString;
// //     } catch (e) {
// //       debugPrint("❌ Error reading GPX: $e");
// //       return "";
// //     }
// //   }
// //
// //   Future<String> getConsolidatedGpx() async {
// //     try {
// //       Gpx consolidatedGpx = Gpx();
// //       Trk consolidatedTrack = Trk();
// //       consolidatedTrack.name = "Consolidated Track ${DateFormat('dd-MM-yyyy').format(DateTime.now())}";
// //
// //       for (var seg in track.trksegs) {
// //         if (seg.trkpts.isNotEmpty) {
// //           consolidatedTrack.trksegs.add(seg);
// //         }
// //       }
// //
// //       consolidatedGpx.trks.add(consolidatedTrack);
// //       return GpxWriter().asString(consolidatedGpx, pretty: true);
// //     } catch (e) {
// //       debugPrint("❌ Error consolidating GPX: $e");
// //       return gpxString;
// //     }
// //   }
// //
// //   Future<void> saveGpxFile(String filePath) async {
// //     try {
// //       File outputFile = File(filePath);
// //       String content = await getConsolidatedGpx();
// //       await outputFile.writeAsString(content, flush: true);
// //       debugPrint("💾 GPX saved: $filePath");
// //     } catch (e) {
// //       debugPrint("❌ Error saving GPX: $e");
// //     }
// //   }
// // }
//
//
// ///26-02-2026
// import 'dart:async';
// import 'dart:async' show Future, StreamSubscription, Completer;
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gpx/gpx.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:synchronized/synchronized.dart';
//
// class LocationService {
//   late Gpx gpx;
//   late Trk track;
//   late Trkseg segment;
//   late File file;
//   late bool isFirstRun;
//   late bool isConnected;
//   late var lat, longi;
//   late String userIdForLocation;
//   late String userCityForLocatiion;
//   late String userDesignationForLocation;
//   late String userNameForLocation;
//   late String rsmIdForLocation;
//   late String nsmIdForLocation;
//   late String smIdForLocation;
//   late String dispatcherIdForLocation;
//   late final filepath;
//   late final Directory? downloadDirectory;
//   late double totalDistance;
//   late Position? lastTrackPoint;
//   String gpxString = "";
//
//   bool _isInitialized = false;
//   bool _isFirstLocationRecorded = false;
//   Completer<void>? _initializationCompleter;
//   DateTime? _sessionStartTime;
//   String? _lastSessionId;
//   List<Trkseg> _segments = [];
//   final Lock _fileWriteLock = Lock();
//   Timer? _writeDebounceTimer;
//   static const Duration _writeDebounceDelay = Duration(seconds: 2);
//   bool _pendingWrite = false;
//
//   // ✅ NEW: Adaptive tracking state
//   DateTime? _lastPointTime;
//   static const int _maxTimeBetweenPoints = 15; // Force point every 15 seconds max
//   static const double _minDistanceFilter = 5.0; // 5 meters for high density
//   static const double _maxDistanceFilter = 15.0; // 15 meters when moving fast
//   double _currentDistanceFilter = 5.0;
//
//   LocationService() {
//     totalDistance = 0.0;
//     lastTrackPoint = null;
//     _isInitialized = false;
//     _isFirstLocationRecorded = false;
//     _sessionStartTime = null;
//     _lastSessionId = null;
//     init();
//     Firebase.initializeApp();
//     lat = 0.0;
//     longi = 0.0;
//     isConnected = false;
//   }
//
//   StreamSubscription<Position>? positionStream;
//
//   // ✅ FIXED: Optimized for high-density tracking with time-based updates
//   LocationSettings locationSettings = AndroidSettings(
//     accuracy: LocationAccuracy.bestForNavigation, // ✅ Highest accuracy for navigation
//     distanceFilter: 5, // ✅ REDUCED from 10 to 5 meters for denser points
//     forceLocationManager: true,
//     intervalDuration: const Duration(seconds: 5), // ✅ Force check every 5 seconds
//   );
//
//   Future<void> listenLocation() async {
//     if (!_isInitialized) {
//       await _initializeService();
//     }
//
//     positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
//         .listen((Position position) async {
//       await _handleLocationUpdate(position);
//     });
//   }
//
//   Future<void> checkAndStartNewSegment() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? lastClockOutTimeString = prefs.getString('lastClockOutTime');
//     String? currentSessionStartString = prefs.getString('currentSessionStart');
//
//     if (lastClockOutTimeString != null && currentSessionStartString != null) {
//       DateTime lastClockOutTime = DateTime.parse(lastClockOutTimeString);
//       DateTime currentSessionStart = DateTime.parse(currentSessionStartString);
//
//       if (currentSessionStart.difference(lastClockOutTime).inMinutes > 30) {
//         await _startNewSegment();
//         debugPrint("🔄 Starting new GPX segment");
//       }
//     }
//   }
//
//   Future<void> _startNewSegment() async {
//     try {
//       if (segment.trkpts.isNotEmpty) {
//         _segments.add(segment);
//       }
//
//       segment = Trkseg();
//
//       if (track.trksegs.isEmpty) {
//         track.trksegs = [segment];
//       } else {
//         track.trksegs.add(segment);
//       }
//
//       lastTrackPoint = null;
//       debugPrint("🔄 Started new GPX segment");
//     } catch (e) {
//       debugPrint("❌ Error starting new segment: $e");
//     }
//   }
//
//   Future<void> _initializeService() async {
//     if (_initializationCompleter != null) {
//       return _initializationCompleter!.future;
//     }
//
//     _initializationCompleter = Completer<void>();
//
//     try {
//       debugPrint("🔄 Initializing Location Service...");
//       await _loadUserData();
//       await checkAndStartNewSegment();
//       await _initializeGpxFile();
//       await _waitForFirstValidLocation();
//
//       _isInitialized = true;
//       _initializationCompleter!.complete();
//       debugPrint("✅ Location Service Initialized");
//     } catch (e) {
//       debugPrint("❌ Initialization Failed: $e");
//       _initializationCompleter!.completeError(e);
//     }
//   }
//
//   Future<void> _waitForFirstValidLocation() async {
//     try {
//       debugPrint("📍 Waiting for first valid location...");
//       Position initialPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation, // ✅ Highest accuracy
//         timeLimit: Duration(seconds: 15),
//       );
//
//       lat = initialPosition.latitude.toString();
//       longi = initialPosition.longitude.toString();
//
//       lastTrackPoint = Position(
//         latitude: initialPosition.latitude,
//         longitude: initialPosition.longitude,
//         accuracy: initialPosition.accuracy,
//         altitude: initialPosition.altitude,
//         altitudeAccuracy: initialPosition.altitudeAccuracy ?? 0,
//         heading: initialPosition.heading ?? 0,
//         headingAccuracy: initialPosition.headingAccuracy ?? 0,
//         speed: initialPosition.speed,
//         speedAccuracy: initialPosition.speedAccuracy ?? 0,
//         timestamp: initialPosition.timestamp,
//       );
//
//       _isFirstLocationRecorded = true;
//       _lastPointTime = DateTime.now();
//       debugPrint("🎯 Initial Position Set");
//     } catch (e) {
//       debugPrint("⚠️ Could not get initial position: $e");
//       lastTrackPoint = null;
//     }
//   }
//
//   Future<void> _loadUserData() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     await pref.reload();
//
//     userNameForLocation = pref.getString("userName") ?? "USERName";
//     userIdForLocation = pref.getString("userId") ?? "USERId";
//     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
//     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
//     smIdForLocation = pref.getString("userSM") ?? "smUSER";
//     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
//     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
//     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
//   }
//
//   Future<void> _initializeGpxFile() async {
//     try {
//       gpx = Gpx();
//       track = Trk();
//       segment = Trkseg();
//       _segments = [];
//
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//       downloadDirectory = await getDownloadsDirectory();
//
//       final filePath = "${downloadDirectory!.path}/track_${userIdForLocation}_$date.gpx";
//       file = File(filePath);
//
//       if (file.existsSync()) {
//         String existingContent = await file.readAsString();
//         if (existingContent.trim().isNotEmpty) {
//           try {
//             Gpx existingGpx = GpxReader().fromString(existingContent);
//             if (existingGpx.trks.isNotEmpty) {
//               gpx.trks = existingGpx.trks;
//               track = gpx.trks[0];
//
//               if (track.trksegs.isNotEmpty) {
//                 _segments = List<Trkseg>.from(track.trksegs);
//                 segment = track.trksegs.last;
//               } else {
//                 track.trksegs.add(segment);
//               }
//
//               isFirstRun = false;
//               totalDistance = await _calculateDistanceFromExistingFile();
//               debugPrint("📂 Existing GPX loaded: ${totalDistance.toStringAsFixed(3)} km");
//             } else {
//               _createNewGpxStructure();
//             }
//           } catch (e) {
//             debugPrint("⚠️ Corrupted GPX file, creating new: $e");
//             _createNewGpxStructure();
//           }
//         } else {
//           _createNewGpxStructure();
//         }
//       } else {
//         _createNewGpxStructure();
//       }
//     } catch (e) {
//       debugPrint('❌ Error initializing GPX file: $e');
//       _createNewGpxStructure();
//     }
//   }
//
//   Future<double> _calculateDistanceFromExistingFile() async {
//     try {
//       if (!file.existsSync()) return 0.0;
//       String gpxContent = await file.readAsString();
//       if (gpxContent.isEmpty) return 0.0;
//
//       Gpx existingGpx = GpxReader().fromString(gpxContent);
//       double existingDistance = 0.0;
//
//       for (var track in existingGpx.trks) {
//         for (var segment in track.trksegs) {
//           if (segment.trkpts.length < 2) continue;
//           for (int i = 0; i < segment.trkpts.length - 1; i++) {
//             double distance = calculateDistance(
//               segment.trkpts[i].lat?.toDouble() ?? 0.0,
//               segment.trkpts[i].lon?.toDouble() ?? 0.0,
//               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//             );
//             existingDistance += distance;
//           }
//         }
//       }
//       return existingDistance;
//     } catch (e) {
//       debugPrint("❌ Error calculating existing distance: $e");
//       return 0.0;
//     }
//   }
//
//   void _createNewGpxStructure() {
//     gpx = Gpx();
//     track = Trk();
//     segment = Trkseg();
//     _segments = [];
//
//     track.trksegs.add(segment);
//     gpx.trks.add(track);
//
//     isFirstRun = true;
//     file.createSync(recursive: true);
//     totalDistance = 0.0;
//     debugPrint("📁 Created new GPX file structure");
//   }
//
//   // ✅ FIXED: Adaptive distance calculation with time-based forced updates
//   Future<void> _handleLocationUpdate(Position position) async {
//     // ✅ Quality checks - relaxed slightly for better coverage
//     if (position.accuracy > 50.0) { // Allow up to 50m accuracy (was 30m)
//       debugPrint("⚠️ Low accuracy: ${position.accuracy}m");
//       return;
//     }
//
//     if (position.speed > 50) { // 180 km/h - reasonable max for vehicles
//       debugPrint("⚠️ Impossible speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h");
//       return;
//     }
//
//     lat = position.latitude.toString();
//     longi = position.longitude.toString();
//
//     final trackPoint = Wpt(
//       lat: position.latitude,
//       lon: position.longitude,
//       time: DateTime.now(),
//     );
//
//     bool shouldAddPoint = false;
//     double segmentDistance = 0.0;
//     int secondsSinceLastPoint = _lastPointTime != null
//         ? DateTime.now().difference(_lastPointTime!).inSeconds
//         : 999;
//
//     // ✅ ADAPTIVE LOGIC: Force point if too much time passed
//     if (lastTrackPoint != null) {
//       segmentDistance = calculateDistance(
//         lastTrackPoint!.latitude,
//         lastTrackPoint!.longitude,
//         position.latitude,
//         position.longitude,
//       );
//
//       // ✅ Add point if moved 5+ meters OR if 15+ seconds passed regardless of distance
//       if (segmentDistance >= _minDistanceFilter || secondsSinceLastPoint >= _maxTimeBetweenPoints) {
//         shouldAddPoint = true;
//
//         // Only add to total distance if actually moved (avoid drift accumulation)
//         if (segmentDistance >= _minDistanceFilter) {
//           totalDistance += segmentDistance;
//         }
//
//         debugPrint("📍 ${secondsSinceLastPoint >= _maxTimeBetweenPoints ? 'TIME' : 'DISTANCE'} | "
//             "Moved: ${(segmentDistance * 1000).toStringAsFixed(1)}m | "
//             "Time: ${secondsSinceLastPoint}s | "
//             "Total: ${totalDistance.toStringAsFixed(3)} km");
//       }
//     } else {
//       shouldAddPoint = true;
//       debugPrint("🎯 First track point added");
//     }
//
//     if (shouldAddPoint) {
//       segment.trkpts.add(trackPoint);
//       _lastPointTime = DateTime.now();
//
//       // ✅ Limit segment size (prevent memory issues)
//       if (segment.trkpts.length > 2000) { // Increased from 1000
//         await _startNewSegment();
//       }
//
//       // ✅ Debounced file write
//       _debouncedUpdateGpxFile();
//     }
//
//     lastTrackPoint = Position(
//       latitude: position.latitude,
//       longitude: position.longitude,
//       accuracy: position.accuracy,
//       altitude: position.altitude,
//       altitudeAccuracy: position.altitudeAccuracy ?? 0,
//       heading: position.heading ?? 0,
//       headingAccuracy: position.headingAccuracy ?? 0,
//       speed: position.speed,
//       speedAccuracy: position.speedAccuracy ?? 0,
//       timestamp: position.timestamp,
//     );
//
//     await _updateFirebase(position);
//   }
//
//   void _debouncedUpdateGpxFile() {
//     _pendingWrite = true;
//     _writeDebounceTimer?.cancel();
//     _writeDebounceTimer = Timer(_writeDebounceDelay, () {
//       _performFileWrite();
//     });
//   }
//
//   Future<void> _performFileWrite() async {
//     if (!_pendingWrite) return;
//
//     await _fileWriteLock.synchronized(() async {
//       try {
//         if (_segments.isNotEmpty) {
//           track.trksegs = List<Trkseg>.from(_segments);
//           if (!track.trksegs.contains(segment)) {
//             track.trksegs.add(segment);
//           }
//         }
//
//         gpxString = GpxWriter().asString(gpx, pretty: true);
//         await file.writeAsString(gpxString, flush: true);
//         _pendingWrite = false;
//
//         debugPrint("📁 GPX Updated: ${track.trksegs.length} segments, ${_getTotalPoints()} points");
//       } catch (e) {
//         debugPrint('❌ Error writing GPX: $e');
//       }
//     });
//   }
//
//   Future<void> _updateFirebase(Position position) async {
//     isConnected = await isNetworkAvailableForFirebase();
//
//     if (isConnected) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('location')
//             .doc(userIdForLocation.toString())
//             .set({
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//           'name': userNameForLocation.toString(),
//           'userId': userIdForLocation.toString(),
//           'city': userCityForLocatiion.toString(),
//           'designation': userDesignationForLocation.toString(),
//           'RSM_ID': rsmIdForLocation.toString(),
//           'NSM_ID': nsmIdForLocation.toString(),
//           'SM_ID': smIdForLocation.toString(),
//           'DISPATCHER_ID': dispatcherIdForLocation.toString(),
//           'isActive': true,
//           'totalDistance': totalDistance,
//           'accuracy': position.accuracy,
//           'speed': position.speed * 3.6,
//           'altitude': position.altitude,
//           'heading': position.heading,
//           'segments': track.trksegs.length,
//           'points': _getTotalPoints(),
//           'lastUpdate': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       } catch (e) {
//         debugPrint('❌ Firebase update error: $e');
//       }
//     }
//   }
//
//   double getCurrentDistance() {
//     return double.parse(totalDistance.toStringAsFixed(3));
//   }
//
//   Future<double> calculateCurrentDistance() async {
//     try {
//       double memoryDistance = totalDistance;
//
//       if (!file.existsSync()) return memoryDistance;
//
//       String gpxContent = await file.readAsString();
//       if (gpxContent.isEmpty) return memoryDistance;
//
//       Gpx gpx = GpxReader().fromString(gpxContent);
//       double calculatedDistance = 0.0;
//
//       for (var track in gpx.trks) {
//         for (var segment in track.trksegs) {
//           if (segment.trkpts.length < 2) continue;
//           for (int i = 0; i < segment.trkpts.length - 1; i++) {
//             double distance = calculateDistance(
//               segment.trkpts[i].lat?.toDouble() ?? 0.0,
//               segment.trkpts[i].lon?.toDouble() ?? 0.0,
//               segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//               segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//             );
//             calculatedDistance += distance;
//           }
//         }
//       }
//
//       double finalDistance = calculatedDistance > memoryDistance ? calculatedDistance : memoryDistance;
//       totalDistance = finalDistance;
//
//       debugPrint("📏 Distance: Memory=${memoryDistance.toStringAsFixed(3)}km, File=${calculatedDistance.toStringAsFixed(3)}km");
//       return finalDistance;
//     } catch (e) {
//       debugPrint('❌ Error calculating distance: $e');
//       return totalDistance;
//     }
//   }
//
//   int _getTotalPoints() {
//     int total = 0;
//     for (var seg in track.trksegs) {
//       total += seg.trkpts.length;
//     }
//     return total;
//   }
//
//   Future<void> init() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     await pref.reload();
//     userNameForLocation = pref.getString("userName") ?? "USERName";
//     userIdForLocation = pref.getString("userId") ?? "USERId";
//     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
//     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
//     smIdForLocation = pref.getString("userSM") ?? "smUSER";
//     dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
//     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
//     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
//   }
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000);
//   }
//
//   Future<void> deleteDocument() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('location')
//           .doc(userIdForLocation)
//           .delete();
//     } catch (e) {
//       debugPrint("❌ Error deleting document: $e");
//     }
//   }
//
//   Future<void> stopListening() async {
//     try {
//       positionStream?.cancel();
//       _writeDebounceTimer?.cancel();
//       if (_pendingWrite) {
//         await _performFileWrite();
//       }
//
//       await calculateCurrentDistance();
//
//       SharedPreferences pref = await SharedPreferences.getInstance();
//       await pref.setDouble("TotalDistance", totalDistance);
//       await pref.setString("lastSessionEnd", DateTime.now().toIso8601String());
//
//       debugPrint("🛑 Stopped. Final: ${totalDistance.toStringAsFixed(3)} km | Points: ${_getTotalPoints()}");
//     } catch (e) {
//       debugPrint("❌ ERROR in stopListening: ${e.toString()}");
//     }
//   }
//
//   void resetDistance() {
//     totalDistance = 0.0;
//     debugPrint("🔄 Distance reset");
//   }
//
//   Map<String, dynamic> getServiceStatus() {
//     return {
//       'isInitialized': _isInitialized,
//       'isFirstLocationRecorded': _isFirstLocationRecorded,
//       'totalDistance': totalDistance,
//       'pointsRecorded': segment.trkpts.length,
//       'totalSegments': track.trksegs.length,
//       'totalAllPoints': _getTotalPoints(),
//       'lastTrackPoint': lastTrackPoint != null ?
//       '${lastTrackPoint!.latitude}, ${lastTrackPoint!.longitude}' : 'None',
//       'filePath': file.path,
//       'fileExists': file.existsSync(),
//       'fileSize': file.existsSync() ? file.lengthSync() : 0,
//       'pendingWrite': _pendingWrite,
//       'currentDistanceFilter': _currentDistanceFilter,
//     };
//   }
//
//   Future<String> getGpxContent() async {
//     try {
//       if (file.existsSync()) {
//         return await file.readAsString();
//       }
//       return gpxString;
//     } catch (e) {
//       debugPrint("❌ Error reading GPX: $e");
//       return "";
//     }
//   }
//
//   Future<String> getConsolidatedGpx() async {
//     try {
//       Gpx consolidatedGpx = Gpx();
//       Trk consolidatedTrack = Trk();
//       consolidatedTrack.name = "Consolidated Track ${DateFormat('dd-MM-yyyy').format(DateTime.now())}";
//
//       for (var seg in track.trksegs) {
//         if (seg.trkpts.isNotEmpty) {
//           consolidatedTrack.trksegs.add(seg);
//         }
//       }
//
//       consolidatedGpx.trks.add(consolidatedTrack);
//       return GpxWriter().asString(consolidatedGpx, pretty: true);
//     } catch (e) {
//       debugPrint("❌ Error consolidating GPX: $e");
//       return gpxString;
//     }
//   }
//
//   Future<void> saveGpxFile(String filePath) async {
//     try {
//       File outputFile = File(filePath);
//       String content = await getConsolidatedGpx();
//       await outputFile.writeAsString(content, flush: true);
//       debugPrint("💾 GPX saved: $filePath");
//     } catch (e) {
//       debugPrint("❌ Error saving GPX: $e");
//     }
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  late Gpx gpx;
  late Trk track;
  late Trkseg segment;
  late File file;
  late bool isFirstRun;
  late bool isConnected;
  late var lat, longi;
  late String userIdForLocation;
  late String userCityForLocatiion;
  late String userDesignationForLocation;
  late String userNameForLocation;
  late String rsmIdForLocation;
  late String nsmIdForLocation;
  late String smIdForLocation;
  late String dispatcherIdForLocation;
  late final Directory? downloadDirectory;
  late double totalDistance;
  Position? lastTrackPoint;
  String gpxString = "";

  bool _isInitialized = false;
  bool _isFirstLocationRecorded = false;
  Completer<void>? _initializationCompleter;
  List<Trkseg> _segments = [];
  final Lock _fileWriteLock = Lock();
  Timer? _writeDebounceTimer;
  Timer? _forcedUpdateTimer; // ✅ NEW: Forces points even when stationary
  static const Duration _writeDebounceDelay = Duration(seconds: 1);
  bool _pendingWrite = false;

  // ✅ ULTRA SETTINGS: Maximum accuracy configuration
  static const double _minDistanceFilter = 1.0; // 1 meter - maximum density
  static const int _maxTimeBetweenPoints = 5; // Force point every 5 seconds
  static const double _maxAcceptableAccuracy = 20.0; // Allow up to 20m (urban canyons)
  static const double _maxSpeedThreshold = 60.0; // 216 km/h - filter impossible speeds

  DateTime? _lastPointTime;
  int _consecutiveLowAccuracy = 0;

  LocationSettings? _locationSettings; // Will be configured for raw GPS

  UltraLocationService() {
    totalDistance = 0.0;
    lastTrackPoint = null;
    _isInitialized = false;
    _isFirstLocationRecorded = false;
    _segments = [];
    init();
    Firebase.initializeApp();
    lat = 0.0;
    longi = 0.0;
    isConnected = false;
  }

  StreamSubscription<Position>? positionStream;

  /// ✅ CONFIGURE FOR RAW GPS - Maximum accuracy
  Future<void> _configureLocationSettings() async {
    // For Android: Use bestForNavigation with minimal filtering
    // This bypasses FLP and uses raw GNSS when possible
    _locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Raw GPS, no FLP fusion
      distanceFilter: 1, // 1 meter - capture every tiny movement
      forceLocationManager: true, // Force raw GPS, ignore FLP
      intervalDuration: const Duration(seconds: 1), // Check every second
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: 'Ultra GPS Tracking Active',
        notificationTitle: 'Recording precise location',
        enableWakeLock: true, // Keep CPU awake for accuracy
      ),
    );
  }

  Future<void> listenLocation() async {
    if (!_isInitialized) {
      await _initializeService();
    }

    // ✅ Start forced update timer (captures points even when stopped at turns)
    _startForcedUpdateTimer();

    positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings!)
        .listen((Position position) async {
      await _handleLocationUpdate(position);
    }, onError: (error) {
      debugPrint("❌ Location stream error: $error");
    });
  }

  /// ✅ Forces a point every 5 seconds even if not moved (captures stopped time at intersections)
  void _startForcedUpdateTimer() {
    _forcedUpdateTimer?.cancel();
    _forcedUpdateTimer = Timer.periodic(
      const Duration(seconds: _maxTimeBetweenPoints),
          (timer) async {
        if (lastTrackPoint != null && _lastPointTime != null) {
          int secondsSinceLast = DateTime.now().difference(_lastPointTime!).inSeconds;
          if (secondsSinceLast >= _maxTimeBetweenPoints) {
            // Force insert a point at current location to maintain timeline
            await _insertForcedPoint();
          }
        }
      },
    );
  }

  /// ✅ Inserts a point even if we haven't moved (maintains track continuity)
  Future<void> _insertForcedPoint() async {
    if (lastTrackPoint == null) return;

    final forcedPoint = Wpt(
      lat: lastTrackPoint!.latitude,
      lon: lastTrackPoint!.longitude,
      time: DateTime.now(),
      // Add metadata to identify forced points
      name: 'forced',
    );

    segment.trkpts.add(forcedPoint);
    _lastPointTime = DateTime.now();

    debugPrint("⏰ Forced point inserted at ${segment.trkpts.length} total points");
    _debouncedUpdateGpxFile();
  }

  Future<void> checkAndStartNewSegment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastClockOutTimeString = prefs.getString('lastClockOutTime');
    String? currentSessionStartString = prefs.getString('currentSessionStart');

    if (lastClockOutTimeString != null && currentSessionStartString != null) {
      DateTime lastClockOutTime = DateTime.parse(lastClockOutTimeString);
      DateTime currentSessionStart = DateTime.parse(currentSessionStartString);

      if (currentSessionStart.difference(lastClockOutTime).inMinutes > 30) {
        await _startNewSegment();
        debugPrint("🔄 Starting new GPX segment");
      }
    }
  }

  Future<void> _startNewSegment() async {
    try {
      if (segment.trkpts.isNotEmpty) {
        _segments.add(segment);
      }

      segment = Trkseg();
      lastTrackPoint = null; // Reset to force new first point

      if (track.trksegs.isEmpty) {
        track.trksegs = [segment];
      } else {
        track.trksegs.add(segment);
      }

      debugPrint("🔄 Started new GPX segment #${track.trksegs.length}");
    } catch (e) {
      debugPrint("❌ Error starting new segment: $e");
    }
  }

  Future<void> _initializeService() async {
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    _initializationCompleter = Completer<void>();

    try {
      debugPrint("🔄 Initializing Ultra Location Service...");
      await _configureLocationSettings(); // ✅ Configure raw GPS
      await _loadUserData();
      await checkAndStartNewSegment();
      await _initializeGpxFile();
      await _waitForFirstValidLocation();

      _isInitialized = true;
      _initializationCompleter!.complete();
      debugPrint("✅ Ultra Location Service Initialized - Raw GPS Mode");
    } catch (e) {
      debugPrint("❌ Initialization Failed: $e");
      _initializationCompleter!.completeError(e);
    }
  }

  Future<void> _waitForFirstValidLocation() async {
    try {
      debugPrint("📍 Acquiring ultra-precise initial fix...");

      // Try to get best possible initial fix
      Position? initialPosition;
      int attempts = 0;
      const maxAttempts = 30; // 30 seconds max

      while (attempts < maxAttempts && initialPosition == null) {
        try {
          initialPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 2),
          );

          // Only accept if accuracy is good enough
          if (initialPosition.accuracy > _maxAcceptableAccuracy) {
            debugPrint("⚠️ Initial fix accuracy ${initialPosition.accuracy}m, retrying...");
            initialPosition = null;
            await Future.delayed(const Duration(seconds: 1));
          }
        } catch (e) {
          // Timeout or error, retry
        }
        attempts++;
      }

      if (initialPosition == null) {
        // Fallback to any position
        initialPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      lat = initialPosition.latitude.toString();
      longi = initialPosition.longitude.toString();

      lastTrackPoint = Position(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        accuracy: initialPosition.accuracy,
        altitude: initialPosition.altitude,
        altitudeAccuracy: initialPosition.altitudeAccuracy ?? 0,
        heading: initialPosition.heading,
        headingAccuracy: initialPosition.headingAccuracy ?? 0,
        speed: initialPosition.speed,
        speedAccuracy: initialPosition.speedAccuracy ?? 0,
        timestamp: initialPosition.timestamp,
      );

      _isFirstLocationRecorded = true;
      _lastPointTime = DateTime.now();
      debugPrint("🎯 Ultra-precise initial fix: ${initialPosition.accuracy}m accuracy");
    } catch (e) {
      debugPrint("⚠️ Could not get initial position: $e");
      lastTrackPoint = null;
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.reload();

    userNameForLocation = pref.getString("userName") ?? "USERName";
    userIdForLocation = pref.getString("userId") ?? "USERId";
    nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
    rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
    smIdForLocation = pref.getString("userSM") ?? "smUSER";
    dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
  }

  Future<void> _initializeGpxFile() async {
    try {
      gpx = Gpx();
      track = Trk();
      segment = Trkseg();
      _segments = [];

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      downloadDirectory = await getDownloadsDirectory();

      final filePath = "${downloadDirectory!.path}/track_${userIdForLocation}_$date.gpx";
      file = File(filePath);

      if (await file.exists()) {
        String existingContent = await file.readAsString();
        if (existingContent.trim().isNotEmpty) {
          try {
            Gpx existingGpx = GpxReader().fromString(existingContent);
            if (existingGpx.trks.isNotEmpty) {
              gpx.trks = existingGpx.trks;
              track = gpx.trks[0];

              if (track.trksegs.isNotEmpty) {
                _segments = List<Trkseg>.from(track.trksegs);
                segment = track.trksegs.last;
              } else {
                track.trksegs.add(segment);
              }

              isFirstRun = false;
              totalDistance = await _calculateDistanceFromExistingFile();
              debugPrint("📂 Existing GPX loaded: ${totalDistance.toStringAsFixed(3)} km, ${_getTotalPoints()} points");
            } else {
              _createNewGpxStructure();
            }
          } catch (e) {
            debugPrint("⚠️ Corrupted GPX file, creating new: $e");
            _createNewGpxStructure();
          }
        } else {
          _createNewGpxStructure();
        }
      } else {
        _createNewGpxStructure();
      }
    } catch (e) {
      debugPrint('❌ Error initializing GPX file: $e');
      _createNewGpxStructure();
    }
  }

  Future<double> _calculateDistanceFromExistingFile() async {
    try {
      if (!await file.exists()) return 0.0;
      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return 0.0;

      Gpx existingGpx = GpxReader().fromString(gpxContent);
      double existingDistance = 0.0;

      for (var trk in existingGpx.trks) {
        for (var seg in trk.trksegs) {
          if (seg.trkpts.length < 2) continue;
          for (int i = 0; i < seg.trkpts.length - 1; i++) {
            double distance = calculateDistance(
              seg.trkpts[i].lat?.toDouble() ?? 0.0,
              seg.trkpts[i].lon?.toDouble() ?? 0.0,
              seg.trkpts[i + 1].lat?.toDouble() ?? 0.0,
              seg.trkpts[i + 1].lon?.toDouble() ?? 0.0,
            );
            existingDistance += distance;
          }
        }
      }
      return existingDistance;
    } catch (e) {
      debugPrint("❌ Error calculating existing distance: $e");
      return 0.0;
    }
  }

  void _createNewGpxStructure() {
    gpx = Gpx();
    track = Trk();
    segment = Trkseg();
    _segments = [];

    track.trksegs.add(segment);
    gpx.trks.add(track);

    isFirstRun = true;
    file.createSync(recursive: true);
    totalDistance = 0.0;
    debugPrint("📁 Created new ultra-precision GPX file");
  }

  /// ✅ ULTRA-HANDLER: Maximum accuracy with intelligent filtering
  Future<void> _handleLocationUpdate(Position position) async {
    // ✅ RELAXED accuracy check - accept up to 20m (urban canyons cause reflections)
    if (position.accuracy > _maxAcceptableAccuracy) {
      _consecutiveLowAccuracy++;
      if (_consecutiveLowAccuracy > 5) {
        debugPrint("⚠️ Too many low accuracy readings (${position.accuracy}m), accepting anyway");
        // Continue processing despite low accuracy after 5 consecutive bad readings
      } else {
        debugPrint("⚠️ Low accuracy: ${position.accuracy}m, skipping (${_consecutiveLowAccuracy}/5)");
        return;
      }
    } else {
      _consecutiveLowAccuracy = 0; // Reset counter on good reading
    }

    // ✅ Speed check - filter impossible speeds (60 m/s = 216 km/h)
    if (position.speed > _maxSpeedThreshold) {
      debugPrint("⚠️ Impossible speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h");
      return;
    }

    lat = position.latitude.toString();
    longi = position.longitude.toString();

    final trackPoint = Wpt(
      lat: position.latitude,
      lon: position.longitude,
      time: DateTime.now(),
      ele: position.altitude,
      // Store additional metadata in GPX
      name: position.speed > 0.5 ? 'moving' : 'stationary',
    );

    bool shouldAddPoint = false;
    double segmentDistance = 0.0;
    int secondsSinceLastPoint = _lastPointTime != null
        ? DateTime.now().difference(_lastPointTime!).inSeconds
        : 999;

    if (lastTrackPoint != null) {
      segmentDistance = calculateDistance(
        lastTrackPoint!.latitude,
        lastTrackPoint!.longitude,
        position.latitude,
        position.longitude,
      );

      // ✅ ULTRA LOGIC: Add point if moved 1m+ OR if 5+ seconds passed
      // This captures micro-movements and maintains density at stops
      if (segmentDistance >= _minDistanceFilter || secondsSinceLastPoint >= _maxTimeBetweenPoints) {
        shouldAddPoint = true;

        if (segmentDistance >= _minDistanceFilter) {
          totalDistance += segmentDistance;
        }

        debugPrint("📍 ${secondsSinceLastPoint >= _maxTimeBetweenPoints ? '⏰ TIME' : '📏 DIST'} | "
            "Moved: ${(segmentDistance * 1000).toStringAsFixed(1)}m | "
            "Time: ${secondsSinceLastPoint}s | "
            "Acc: ${position.accuracy.toStringAsFixed(1)}m | "
            "Total: ${totalDistance.toStringAsFixed(3)} km | "
            "Points: ${_getTotalPoints()}");
      }
    } else {
      shouldAddPoint = true;
      debugPrint("🎯 First ultra-precise point added (${position.accuracy}m accuracy)");
    }

    if (shouldAddPoint) {
      segment.trkpts.add(trackPoint);
      _lastPointTime = DateTime.now();

      // ✅ Larger segment size for ultra-density (5000 points = ~5km at 1m intervals)
      if (segment.trkpts.length > 5000) {
        await _startNewSegment();
      }

      _debouncedUpdateGpxFile();
    }

    // ✅ Always update lastTrackPoint for heading/speed calculations
    lastTrackPoint = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      altitudeAccuracy: position.altitudeAccuracy ?? 0,
      heading: position.heading,
      headingAccuracy: position.headingAccuracy ?? 0,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy ?? 0,
      timestamp: position.timestamp,
    );

    await _updateFirebase(position);
  }

  void _debouncedUpdateGpxFile() {
    _pendingWrite = true;
    _writeDebounceTimer?.cancel();
    _writeDebounceTimer = Timer(_writeDebounceDelay, () {
      _performFileWrite();
    });
  }

  Future<void> _performFileWrite() async {
    if (!_pendingWrite) return;

    await _fileWriteLock.synchronized(() async {
      try {
        if (_segments.isNotEmpty) {
          track.trksegs = List<Trkseg>.from(_segments);
          if (!track.trksegs.contains(segment)) {
            track.trksegs.add(segment);
          }
        }

        // ✅ Pretty print for debugging, compact for production
        gpxString = GpxWriter().asString(gpx, pretty: true);
        await file.writeAsString(gpxString, flush: true);
        _pendingWrite = false;

        debugPrint("💾 GPX Saved: ${track.trksegs.length} segments, ${_getTotalPoints()} points, "
            "${(await file.length() / 1024).toStringAsFixed(1)} KB");
      } catch (e) {
        debugPrint('❌ Error writing GPX: $e');
      }
    });
  }

  Future<void> _updateFirebase(Position position) async {
    isConnected = await isNetworkAvailableForFirebase();

    if (isConnected) {
      try {
        await FirebaseFirestore.instance
            .collection('location')
            .doc(userIdForLocation.toString())
            .set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'name': userNameForLocation.toString(),
          'userId': userIdForLocation.toString(),
          'city': userCityForLocatiion.toString(),
          'designation': userDesignationForLocation.toString(),
          'RSM_ID': rsmIdForLocation.toString(),
          'NSM_ID': nsmIdForLocation.toString(),
          'SM_ID': smIdForLocation.toString(),
          'DISPATCHER_ID': dispatcherIdForLocation.toString(),
          'isActive': true,
          'totalDistance': totalDistance,
          'accuracy': position.accuracy,
          'speed': position.speed * 3.6,
          'altitude': position.altitude,
          'heading': position.heading,
          'segments': track.trksegs.length,
          'points': _getTotalPoints(),
          'lastUpdate': FieldValue.serverTimestamp(),
          'trackingMode': 'ultra', // Identify this as high-accuracy track
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Firebase update error: $e');
      }
    }
  }

  double getCurrentDistance() {
    return double.parse(totalDistance.toStringAsFixed(3));
  }

  Future<double> calculateCurrentDistance() async {
    try {
      double memoryDistance = totalDistance;

      if (!await file.exists()) return memoryDistance;

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return memoryDistance;

      Gpx gpx = GpxReader().fromString(gpxContent);
      double calculatedDistance = 0.0;

      for (var trk in gpx.trks) {
        for (var seg in trk.trksegs) {
          if (seg.trkpts.length < 2) continue;
          for (int i = 0; i < seg.trkpts.length - 1; i++) {
            double distance = calculateDistance(
              seg.trkpts[i].lat?.toDouble() ?? 0.0,
              seg.trkpts[i].lon?.toDouble() ?? 0.0,
              seg.trkpts[i + 1].lat?.toDouble() ?? 0.0,
              seg.trkpts[i + 1].lon?.toDouble() ?? 0.0,
            );
            calculatedDistance += distance;
          }
        }
      }

      double finalDistance = calculatedDistance > memoryDistance ? calculatedDistance : memoryDistance;
      totalDistance = finalDistance;

      return finalDistance;
    } catch (e) {
      debugPrint('❌ Error calculating distance: $e');
      return totalDistance;
    }
  }

  int _getTotalPoints() {
    int total = 0;
    for (var seg in track.trksegs) {
      total += seg.trkpts.length;
    }
    return total;
  }

  Future<void> init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.reload();
    userNameForLocation = pref.getString("userName") ?? "USERName";
    userIdForLocation = pref.getString("userId") ?? "USERId";
    nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
    rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
    smIdForLocation = pref.getString("userSM") ?? "smUSER";
    dispatcherIdForLocation = pref.getString("userDISPATCHER") ?? "dispatcherUSER";
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000);
  }

  Future<void> deleteDocument() async {
    try {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(userIdForLocation)
          .delete();
    } catch (e) {
      debugPrint("❌ Error deleting document: $e");
    }
  }

  Future<void> stopListening() async {
    try {
      positionStream?.cancel();
      _forcedUpdateTimer?.cancel(); // ✅ Stop forced updates
      _writeDebounceTimer?.cancel();

      if (_pendingWrite) {
        await _performFileWrite();
      }

      await calculateCurrentDistance();

      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setDouble("TotalDistance", totalDistance);
      await pref.setString("lastSessionEnd", DateTime.now().toIso8601String());

      debugPrint("🛑 Stopped. Final: ${totalDistance.toStringAsFixed(3)} km | Points: ${_getTotalPoints()}");
    } catch (e) {
      debugPrint("❌ ERROR in stopListening: ${e.toString()}");
    }
  }

  void resetDistance() {
    totalDistance = 0.0;
    debugPrint("🔄 Distance reset");
  }

  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'isFirstLocationRecorded': _isFirstLocationRecorded,
      'totalDistance': totalDistance,
      'pointsRecorded': segment.trkpts.length,
      'totalSegments': track.trksegs.length,
      'totalAllPoints': _getTotalPoints(),
      'lastTrackPoint': lastTrackPoint != null ?
      '${lastTrackPoint!.latitude.toStringAsFixed(6)}, ${lastTrackPoint!.longitude.toStringAsFixed(6)}' : 'None',
      'filePath': file.path,
      'fileExists': file.existsSync(),
      'fileSize': file.existsSync() ? file.lengthSync() : 0,
      'pendingWrite': _pendingWrite,
      'mode': 'ULTRA',
      'accuracy': lastTrackPoint?.accuracy,
    };
  }

  Future<String> getGpxContent() async {
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
      return gpxString;
    } catch (e) {
      debugPrint("❌ Error reading GPX: $e");
      return "";
    }
  }

  Future<String> getConsolidatedGpx() async {
    try {
      Gpx consolidatedGpx = Gpx();
      Trk consolidatedTrack = Trk();
      consolidatedTrack.name = "Ultra Track ${DateFormat('dd-MM-yyyy').format(DateTime.now())}";

      for (var seg in track.trksegs) {
        if (seg.trkpts.isNotEmpty) {
          consolidatedTrack.trksegs.add(seg);
        }
      }

      consolidatedGpx.trks.add(consolidatedTrack);
      return GpxWriter().asString(consolidatedGpx, pretty: true);
    } catch (e) {
      debugPrint("❌ Error consolidating GPX: $e");
      return gpxString;
    }
  }

  Future<void> saveGpxFile(String filePath) async {
    try {
      File outputFile = File(filePath);
      String content = await getConsolidatedGpx();
      await outputFile.writeAsString(content, flush: true);
      debugPrint("💾 GPX saved: $filePath");
    } catch (e) {
      debugPrint("❌ Error saving GPX: $e");
    }
  }
}