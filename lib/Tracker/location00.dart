import 'dart:async' show Future, StreamSubscription, Completer;
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

import 'dart:async' show Future, StreamSubscription, Completer;
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
  late final filepath;
  late final Directory? downloadDirectory;
  late double totalDistance;
  late Position? lastTrackPoint;
  String gpxString = "";

  // ✅ FIXED: Better initialization tracking
  bool _isInitialized = false;
  bool _isFirstLocationRecorded = false;
  Completer<void>? _initializationCompleter;

  LocationService() {
    totalDistance = 0.0;
    lastTrackPoint = null;
    _isInitialized = false;
    _isFirstLocationRecorded = false;
    init();
    Firebase.initializeApp();
    lat = 0.0;
    longi = 0.0;
    isConnected = false;
  }

  StreamSubscription<Position>? positionStream;
  LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // ✅ Increased to 10 meters
    forceLocationManager: true,
  );

  Future<void> listenLocation() async {
    if (!_isInitialized) {
      await _initializeService();
    }

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      await _handleLocationUpdate(position);
    });
  }

  Future<void> _initializeService() async {
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    _initializationCompleter = Completer<void>();

    try {
      debugPrint("🔄 Initializing Location Service...");

      // 1. Load user data first
      await _loadUserData();

      // 2. Initialize GPX file
      await _initializeGpxFile();

      // 3. Wait for first valid location (BUT DON'T ADD TO DISTANCE)
      await _waitForFirstValidLocation();

      _isInitialized = true;
      _initializationCompleter!.complete();

      debugPrint("✅ Location Service Initialized Successfully");

    } catch (e) {
      debugPrint("❌ Location Service Initialization Failed: $e");
      _initializationCompleter!.completeError(e);
    }
  }

  // ✅ FIXED: Wait for first location but don't add to distance
  Future<void> _waitForFirstValidLocation() async {
    try {
      debugPrint("📍 Waiting for first valid location...");

      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      // ✅ SET INITIAL POSITION BUT DON'T ADD TO TRACK POINTS
      lat = initialPosition.latitude.toString();
      longi = initialPosition.longitude.toString();

      // ✅ SET LAST TRACK POINT FOR FUTURE DISTANCE CALCULATION
      lastTrackPoint = Position(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        accuracy: initialPosition.accuracy,
        altitude: initialPosition.altitude,
        altitudeAccuracy: initialPosition.altitudeAccuracy ?? 0,
        heading: initialPosition.heading ?? 0,
        headingAccuracy: initialPosition.headingAccuracy ?? 0,
        speed: initialPosition.speed,
        speedAccuracy: initialPosition.speedAccuracy ?? 0,
        timestamp: initialPosition.timestamp,
      );

      _isFirstLocationRecorded = true;

      debugPrint("🎯 Initial Position Set (Not added to track):");
      debugPrint("   - Lat: ${initialPosition.latitude}");
      debugPrint("   - Lng: ${initialPosition.longitude}");
      debugPrint("   - Accuracy: ${initialPosition.accuracy} meters");

    } catch (e) {
      debugPrint("⚠️ Could not get initial position: $e");
      // Set default values to avoid null issues
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
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
  }

  Future<void> _initializeGpxFile() async {
    try {
      gpx = Gpx();
      track = Trk();
      segment = Trkseg();

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      downloadDirectory = await getDownloadsDirectory();

      final filePath = "${downloadDirectory!.path}/track_${userIdForLocation}_$date.gpx";
      file = File(filePath);

      if (file.existsSync()) {
        String existingContent = file.readAsStringSync();
        if (existingContent.trim().isNotEmpty) {
          Gpx existingGpx = GpxReader().fromString(existingContent);
          if (existingGpx.trks.isNotEmpty && existingGpx.trks[0].trksegs.isNotEmpty) {
            gpx.trks.add(existingGpx.trks[0]);
            track = gpx.trks[0];
            segment = track.trksegs.last;
            isFirstRun = false;

            // ✅ CALCULATE EXISTING DISTANCE FROM FILE
            totalDistance = await _calculateDistanceFromExistingFile();
            debugPrint("📂 Existing GPX loaded. Distance: ${totalDistance.toStringAsFixed(3)} km");
          } else {
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

  // ✅ FIXED: Calculate distance from existing file
  Future<double> _calculateDistanceFromExistingFile() async {
    try {
      if (!file.existsSync()) return 0.0;

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return 0.0;

      Gpx existingGpx = GpxReader().fromString(gpxContent);
      double existingDistance = 0.0;

      for (var track in existingGpx.trks) {
        for (var segment in track.trksegs) {
          if (segment.trkpts.length < 2) continue;

          for (int i = 0; i < segment.trkpts.length - 1; i++) {
            double distance = calculateDistance(
              segment.trkpts[i].lat?.toDouble() ?? 0.0,
              segment.trkpts[i].lon?.toDouble() ?? 0.0,
              segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
              segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
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

    track.trksegs.add(segment);
    gpx.trks.add(track);

    isFirstRun = true;
    file.createSync(recursive: true);
    totalDistance = 0.0; // ✅ RESET DISTANCE FOR NEW FILE
  }

  // ✅ FIXED: Handle location updates with proper distance calculation
  Future<void> _handleLocationUpdate(Position position) async {
    // ✅ IGNORE LOW ACCURACY POSITIONS
    if (position.accuracy > 50.0) { // Ignore positions with accuracy worse than 50 meters
      debugPrint("⚠️ Ignoring low accuracy position: ${position.accuracy}m");
      return;
    }

    // ✅ UPDATE CURRENT COORDINATES
    lat = position.latitude.toString();
    longi = position.longitude.toString();

    // ✅ CREATE TRACK POINT
    final trackPoint = Wpt(
      lat: position.latitude,
      lon: position.longitude,
      time: DateTime.now(),
    );

    // ✅ ADD TO SEGMENT ONLY IF WE HAVE PREVIOUS POINT FOR DISTANCE CALCULATION
    bool shouldAddPoint = false;
    double segmentDistance = 0.0;

    if (lastTrackPoint != null) {
      // ✅ CALCULATE DISTANCE FROM LAST POINT
      segmentDistance = calculateDistance(
        lastTrackPoint!.latitude,
        lastTrackPoint!.longitude,
        position.latitude,
        position.longitude,
      );
      // if (segmentDistance > 0.005) { // 5 meters in kilometers
      //   shouldAddPoint = true;
      //   totalDistance += segmentDistance;
      //
      //   debugPrint("📍 Movement Detected:");
      //   debugPrint("   - Distance: ${segmentDistance.toStringAsFixed(3)} km");
      //   debugPrint("   - Total: ${totalDistance.toStringAsFixed(3)} km");
      // }
      // ✅ ONLY ADD POINT IF MOVED SIGNIFICANT DISTANCE (more than 5 meters)
      if (segmentDistance > 0.010) { // 10 meters in kilometers
        shouldAddPoint = true;
        totalDistance += segmentDistance;

        debugPrint("📍 Movement Detected:");
        debugPrint(" - Distance: ${(segmentDistance * 1000).toStringAsFixed(1)} meters"); // Meters mein show karein
        debugPrint(" - Total: ${totalDistance.toStringAsFixed(3)} km");
      }else {
        debugPrint("➡️ Minimal movement: ${(segmentDistance * 1000).toStringAsFixed(1)} meters - Ignoring");
        // debugPrint("➡️ Minimal movement: ${segmentDistance.toStringAsFixed(3)} km - Ignoring");
      }
    } else {
      // ✅ FIRST POINT AFTER INITIALIZATION - ADD IT
      shouldAddPoint = true;
      debugPrint("🎯 Adding first track point");
    }

    if (shouldAddPoint) {
      segment.trkpts.add(trackPoint);
      _updateGpxFile();
    }

    // ✅ UPDATE LAST TRACK POINT FOR NEXT CALCULATION
    lastTrackPoint = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      altitudeAccuracy: position.altitudeAccuracy ?? 0,
      heading: position.heading ?? 0,
      headingAccuracy: position.headingAccuracy ?? 0,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy ?? 0,
      timestamp: position.timestamp,
    );

    // ✅ UPDATE FIREBASE
    await _updateFirebase(position);
  }

  void _updateGpxFile() {
    try {
      gpxString = GpxWriter().asString(gpx, pretty: true);
      file.writeAsStringSync(gpxString);
    } catch (e) {
      debugPrint('❌ Error updating GPX file: $e');
    }
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
          'isActive': true,
          'totalDistance': totalDistance,
          'accuracy': position.accuracy,
          'lastUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Firebase update error: $e');
      }
    }
  }

  // ✅ FIXED: Get current distance
  double getCurrentDistance() {
    return double.parse(totalDistance.toStringAsFixed(3)); // Return with 3 decimal places
  }

  Future<double> calculateCurrentDistance() async {
    try {
      if (!file.existsSync()) {
        return totalDistance;
      }

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return totalDistance;

      Gpx gpx = GpxReader().fromString(gpxContent);
      double calculatedDistance = 0.0;

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          if (segment.trkpts.length < 2) continue;

          for (int i = 0; i < segment.trkpts.length - 1; i++) {
            double distance = calculateDistance(
              segment.trkpts[i].lat?.toDouble() ?? 0.0,
              segment.trkpts[i].lon?.toDouble() ?? 0.0,
              segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
              segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
            );
            calculatedDistance += distance;
          }
        }
      }

      // Update total distance
      totalDistance = calculatedDistance;
      return totalDistance;

    } catch (e) {
      debugPrint('❌ Error in calculateCurrentDistance: $e');
      return totalDistance;
    }
  }

  // Rest of your existing methods remain the same...
  Future<void> init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.reload();
    userNameForLocation = pref.getString("userName") ?? "USERName";
    userIdForLocation = pref.getString("userId") ?? "USERId";
    nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
    rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
    smIdForLocation = pref.getString("userSM") ?? "smUSER";
    userCityForLocatiion = pref.getString("userCity") ?? "CITY";
    userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000); // Convert to kilometers
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
      await calculateCurrentDistance();

      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setDouble("TotalDistance", totalDistance);

      debugPrint("🛑 Location listening stopped");
      debugPrint("📏 Final Distance: ${totalDistance.toStringAsFixed(3)} km");

    } catch (e) {
      debugPrint("❌ ERROR in stopListening: ${e.toString()}");
    }
  }

  // ✅ NEW: Reset distance (for testing)
  void resetDistance() {
    totalDistance = 0.0;
    debugPrint("🔄 Distance reset to 0");
  }

  // ✅ NEW: Get service status for debugging
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'isFirstLocationRecorded': _isFirstLocationRecorded,
      'totalDistance': totalDistance,
      'pointsRecorded': segment.trkpts.length,
      'lastTrackPoint': lastTrackPoint != null ?
      '${lastTrackPoint!.latitude}, ${lastTrackPoint!.longitude}' : 'None',
    };
  }
}








//
// import 'dart:async' show Future, StreamSubscription;
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
//
// class LocationService {
//   //late LocationManager locationManager;
//   late Gpx gpx;
//   late Trk track;
//   late Trkseg segment;
//   late File file;
//   late bool isFirstRun;
//   late bool isConnected;
//   late var lat, longi;
//   //late StreamSubscription<LocationDto> locationSubscription;
//   late String userIdForLocation;
//   late String userCityForLocatiion;
//   late String userDesignationForLocation;
//
//   late String userNameForLocation;
//   late String rsmIdForLocation;
//   late String nsmIdForLocation;
//   late String smIdForLocation;
//   late final filepath;
//   late final Directory? downloadDirectory;
//   late double totalDistance;
//   late Position? lastTrackPoint;
//   String gpxString = "";
//
//   LocationService() {
//     totalDistance = 0.0;
//     lastTrackPoint = null;
//     init();
//     Firebase.initializeApp();
//     lat = 0.0;
//     longi = 0.0;
//     isConnected =false;
//   }
//
//   StreamSubscription<Position>? positionStream;
//   LocationSettings locationSettings = AndroidSettings(
//     accuracy: LocationAccuracy.high,
//     distanceFilter: 9,
//     forceLocationManager: true,
//     // intervalDuration: const Duration(seconds:1 ),
//   );
//
//   Future<void> listenLocation() async {
//     positionStream =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position position) async {
//           if (kDebugMode) {
//             print("W100 Repeat");
//           }
//
//           longi = position.longitude.toString();
//           lat = position.latitude.toString();
//           final trackPoint = Wpt(
//             lat: position.latitude,
//             lon: position.longitude,
//             time: DateTime.now(),
//           );
//
//           segment.trkpts.add(trackPoint);
//
//           if (isFirstRun) {
//             track.trksegs.add(segment);
//             gpx.trks.add(track);
//             isFirstRun = false;
//           }
//
//           if (lastTrackPoint != null) {
//             totalDistance += calculateDistance(
//               lastTrackPoint!.latitude,
//               lastTrackPoint!.longitude,
//               position.latitude,
//               position.longitude,
//             );
//           }
//
//           lastTrackPoint = Position(
//             latitude: position.latitude,
//             longitude: position.longitude,
//             accuracy: 0,
//             altitude: 0,
//             altitudeAccuracy: 0,
//             heading: 0,
//             headingAccuracy: 0,
//             speed: 0,
//             speedAccuracy: 0,
//             timestamp: DateTime.now(),
//           );
//           gpxString = GpxWriter().asString(gpx, pretty: true);
//           if (kDebugMode) {
//             print("W100 $gpxString");
//           }
//           file.writeAsStringSync(gpxString);
//
//            isConnected = await isNetworkAvailableForFirebase();
//            // isConnected = await isNetworkAvailable();
//           if (isConnected) {
//             debugPrint("FIrebaseeeeeeeeeeeeeeeeeeee");
//             await FirebaseFirestore.instance
//                 .collection('location')
//                 .doc(userIdForLocation.toString())
//                 .set({
//               'latitude': position.latitude,
//               'longitude': position.longitude,
//               'name': userNameForLocation.toString(),
//               'userId': userIdForLocation.toString(),
//               'city': userCityForLocatiion.toString(),
//               'designation': userDesignationForLocation.toString(),
//               'RSM_ID': rsmIdForLocation.toString(),
//               'NSM_ID':nsmIdForLocation.toString(),
//               'SM_ID':smIdForLocation.toString() ,
//               'isActive': true
//             }, SetOptions(merge: true));
//             debugPrint("FIrebaseeingggggggggggggggggggg");
//           }
//         });
//
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     await pref.reload();
//     userNameForLocation = pref.getString("userName") ?? "USERName";
//     userIdForLocation = pref.getString("userId") ?? "USERId";
//     nsmIdForLocation = pref.getString("userNSM") ?? "nsmUSER";
//     rsmIdForLocation = pref.getString("userRSM") ?? "rsmUSER";
//     smIdForLocation = pref.getString("userSM") ?? "smUSER";
//     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
//     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
//     debugPrint('User ID: $userIdForLocation');
//     debugPrint('User Name: $userNameForLocation');
//     debugPrint('User City: $userCityForLocatiion');
//     debugPrint('User Designation: $userDesignationForLocation');
//     debugPrint('User RSM ID: $rsmIdForLocation');
//     debugPrint('User NSM ID: $nsmIdForLocation');
//     debugPrint('User SM ID: $smIdForLocation');
//
//     try {
//       gpx = Gpx();
//       track = Trk();
//       segment = Trkseg();
//       if (kDebugMode) {
//         print("W100 Start");
//       }
//       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
//
//       final downloadDirectory = await getDownloadsDirectory();
//       final filePath = "${downloadDirectory!.path}/track$date.gpx";
//
//       file = File(filePath);
//       isFirstRun = !file.existsSync();
//       if (!file.existsSync()) {
//         file.createSync();
//       } else {
//         Gpx existingGpx = GpxReader().fromString(file.readAsStringSync());
//         gpx.trks.add(existingGpx.trks[0]);
//         track = gpx.trks[0];
//         segment = Trkseg();
//         track.trksegs.add(segment);
//       }
//
//       if (kDebugMode) {
//         print("W100 END");
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('W100 An error occurred: $e');
//       }
//     }
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
//     userCityForLocatiion = pref.getString("userCity") ?? "CITY";
//     userDesignationForLocation = pref.getString("userDesignation") ?? "DESIGNATION";
//   }
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     double distanceInMeters =
//     Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//     return (distanceInMeters / 1000); // Multiply the result by 2
//   }
//
//   // Future<void> deleteDocument() async {
//   //   await FirebaseFirestore.instance
//   //       .collection('location')
//   //       .doc(userIdForLocation)
//   //       .delete()
//   //       .then(
//   //         (doc) => print("Document deleted"),
//   //     onError: (e) => print("Error updating document $e"),
//   //   );
//   // }
//
//   Future<void> deleteDocument() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('location')
//           .doc(userIdForLocation)
//           .delete();
//
//       if (kDebugMode) {
//         print("Document deleted");
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error deleting document $e");
//       }
//     }
//   }
//
//   Future<void> stopListening() async {
//     try {
//       //WakelockPlus.disable();
//       positionStream?.cancel();
//       SharedPreferences pref = await SharedPreferences.getInstance();
//       pref.setDouble("TotalDistance", totalDistance);
//     } catch (e) {
//       if (kDebugMode) {
//         print("ERROR ${e.toString()}");
//       }
//     }
//   }
// }
// // Future<double> calculateTotalDistance(String filePath) async {
// //   File file = File(filePath);
// //   if (!file.existsSync()) {
// //     return 0.0;
// //   }
// //
// //   // Read GPX content from file
// //   String gpxContent = await file.readAsString();
// //
// //   // Parse GPX content
// //   Gpx gpx = GpxReader().fromString(gpxContent);
// //
// //   // Calculate total distance
// //   double totalDistance = 0.0;
// //
// //   // Iterate through each track segment
// //   for (var track in gpx.trks) {
// //     for (var segment in track.trksegs) {
// //       for (int i = 0; i < segment.trkpts.length - 1; i++) {
// //         double distance = calculateDistance(
// //           segment.trkpts[i].lat!.toDouble(),
// //           segment.trkpts[i].lon!.toDouble(),
// //           segment.trkpts[i + 1].lat!.toDouble(),
// //           segment.trkpts[i + 1].lon!.toDouble(),
// //         );
// //         totalDistance += distance;
// //       }
// //     }
// //   }
// //
// //   if (kDebugMode) {
// //     print("CUT: $totalDistance");
// //   }
// //
// //   // Ensure totalDistance is not zero
// //   return totalDistance != 0.0 ? totalDistance : 0.0;
// // }
// Future<double> calculateTotalDistance(String filePath) async {
//   File file = File(filePath);
//   if (!file.existsSync()) {
//     return 0.0;
//   }
//
//   // Read GPX content from file
//   String gpxContent = await file.readAsString();
//   if (gpxContent.isEmpty) {
//     return 0.0;
//   }
//
//   // Parse GPX content
//   Gpx gpx;
//   try {
//     gpx = GpxReader().fromString(gpxContent);
//   } catch (e) {
//     if (kDebugMode) {
//       print("Error parsing GPX content: $e");
//     }
//     return 0.0;
//   }
//
//   // Calculate total distance
//   double totalDistance = 0.0;
//   for (var track in gpx.trks) {
//     for (var segment in track.trksegs) {
//       for (int i = 0; i < segment.trkpts.length - 1; i++) {
//         double distance = calculateDistance(
//           segment.trkpts[i].lat?.toDouble() ?? 0.0,
//           segment.trkpts[i].lon?.toDouble() ?? 0.0,
//           segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
//           segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
//         );
//         totalDistance += distance;
//       }
//     }
//   }
//
//   if (kDebugMode) {
//     print("CUT: $totalDistance");
//   }
//
//   return totalDistance;
// }
// double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//   double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
//   return (distanceInMeters / 1000); // Multiply the result by 2
// }
//
// // Future<bool> isInternetConnected() async {
// //   bool isConnected = await InternetConnectionChecker().hasConnection;
// //   if (kDebugMode) {
// //     print('Internet Connected: $isConnected');
// //   }
// //   return isConnected;
// // }