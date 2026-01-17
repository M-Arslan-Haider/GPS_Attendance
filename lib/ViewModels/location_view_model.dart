

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Repositories/location_services_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../GPX/central_point_model.dart';
import '../GPX/central_point_repository.dart';
import '../GPX/gpx_coordinate_service.dart';
import '../Models/location_model.dart';
import '../Repositories/location_repository.dart';
import 'package:geocoding/geocoding.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import '../Tracker/trac.dart';

class LocationViewModel extends GetxController {
  var allLocation = <LocationModel>[].obs;
  LocationRepository locationRepository = LocationRepository();
  var globalLatitude1 = 0.0.obs;
  var globalLongitude1 = 0.0.obs;
  var shopAddress = ''.obs;


  var lastProcessedDate = ''.obs;
  var isDailyProcessingComplete = false.obs;


  RxInt secondsPassed = 0.obs;
  Timer? _timer;
  RxBool isClockedIn = false.obs;
  var isGPSEnabled = false.obs;
  var newsecondpassed = 0.obs;
  int locationSerialCounter = 1;
  String locationCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';

  final CentralPointsRepository centralPointsRepo = CentralPointsRepository();
  var allCentralPoints = <CentralPointsModel>[].obs;

  final GPXCoordinateService gpxService = GPXCoordinateService();
  var clusterCenters = <String, LatLng>{}.obs;
  var centralPoint = LatLng(0.0, 0.0).obs;

  int clusterPointSerialCounter = 1;

  @override
  void onInit() {
    super.onInit();
    fetchAllLocation();
    loadClockStatus();
    startTimerIfClockedIn();
    fetchAllCentralPoints();

    _initializeDailyProcessing();
    _initializeClusterCounter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ----------------------
  // Timer Logic
  // ----------------------
  void startTimerIfClockedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
    if (isClockedIn.value) {
      secondsPassed.value = prefs.getInt('secondsPassed') ?? 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        secondsPassed.value++;
        _saveSecondsToPrefs(secondsPassed.value);
      });
    }
  }

  void startTimer() async {
    _timer?.cancel();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    secondsPassed.value = prefs.getInt('secondsPassed') ?? 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      secondsPassed.value++;
      _saveSecondsToPrefs(secondsPassed.value);
    });
  }

  void _saveSecondsToPrefs(int seconds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondsPassed', seconds);
  }

  Future<String> stopTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _timer?.cancel();

    String totalTime = _formatDuration(secondsPassed.value);

    secondsPassed.value = 0;
    newsecondpassed.value = 0;

    await prefs.setInt('secondsPassed', 0);
    await prefs.setString('totalTime', totalTime);

    return totalTime;
  }

  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secs';
  }

  // ----------------------
  // 24 Hours GPX Data Processing
  // ----------------------

  // Daily file management methods
  String getDailyGPXFileName() {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return 'track$date.gpx';
  }
// LocationViewModel.dart mein yeh method add karein:

// ✅ NEW: Immediate distance check method
  Future<double> getImmediateDistance() async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";

      File file = File(filePath);

      if (file.existsSync()) {
        return await calculateTotalDistance(filePath);
      } else {
        return 0.0;
      }
    } catch (e) {
      debugPrint("❌ Error getting immediate distance: $e");
      return 0.0;
    }
  }

// ✅ NEW: Check if location service is working
  Future<Map<String, dynamic>> checkLocationServiceStatus() async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final filePath = "${downloadDirectory!.path}/track_${user_id}_$date.gpx";

      File file = File(filePath);
      bool fileExists = file.existsSync();
      int fileSize = fileExists ? file.lengthSync() : 0;
      int pointCount = 0;

      if (fileExists) {
        String content = await file.readAsString();
        Gpx gpx = GpxReader().fromString(content);
        pointCount = _getTotalPoints(gpx);
      }

      return {
        'serviceActive': true,
        'fileExists': fileExists,
        'fileSize': fileSize,
        'pointsRecorded': pointCount,
        'filePath': filePath,
      };
    } catch (e) {
      return {
        'serviceActive': false,
        'error': e.toString(),
      };
    }
  }

  int _getTotalPoints(Gpx gpx) {
    int total = 0;
    for (var track in gpx.trks) {
      for (var segment in track.trksegs) {
        total += segment.trkpts.length;
      }
    }
    return total;
  }
  Future<String> getCurrentGPXFilePath() async {
    final downloadDirectory = await getDownloadsDirectory();
    return '${downloadDirectory!.path}/${getDailyGPXFileName()}';
  }

  // Time-based filtering helper method
  Future<List<LatLng>> _filterCoordinatesByTimeRange(
      List<Wpt> points, DateTime startTime, DateTime endTime) async {

    List<LatLng> filteredCoords = [];

    for (var point in points) {
      if (point.lat != null && point.lon != null && point.time != null) {
        if (point.time!.isAfter(startTime) && point.time!.isBefore(endTime)) {
          filteredCoords.add(LatLng(
              point.lat!.toDouble(),
              point.lon!.toDouble()
          ));
        }
      }
    }

    debugPrint("⏰ Time range ${DateFormat('HH:mm').format(startTime)}-${DateFormat('HH:mm').format(endTime)}: ${filteredCoords.length} points");
    return filteredCoords;
  }

  // 24 Hours processing method
  Future<void> process24HoursGPXData() async {
    try {
      final gpxFilePath = await getCurrentGPXFilePath();
      debugPrint("🕐 Processing 24 hours GPX data from: $gpxFilePath");

      // 1. Extract all coordinates from today's file
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates found in 24 hours data");
        return;
      }

      debugPrint("📍 Total coordinates in 24 hours: ${coordinates.length}");

      // 2. Extract all points with time data
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      // 3. Calculate overall central point
      LatLng overallCenter = gpxService.calculateCentralPoint(coordinates);

      // 4. Create clusters
      var clusters = gpxService.clusterCoordinates(coordinates, clusterDistanceMeters: 0.1);
      var centers = gpxService.calculateClusterCenters(clusters);

      debugPrint("🗂 24 Hours Summary:");
      debugPrint("   - Total Coordinates: ${coordinates.length}");
      debugPrint("   - Total Clusters: ${centers.length}");
      debugPrint("   - Overall Center: ${overallCenter.latitude}, ${overallCenter.longitude}");

      // 5. Store enhanced data
      await storeCentralPointsToAPI(
          overallCenter,
          centers,
          clusters,
          coordinates.length,
          allPoints
      );

      debugPrint("✅ 24 hours GPX processing completed");

    } catch (e) {
      debugPrint("❌ Error processing 24 hours GPX data: $e");
    }
  }

  // Time-based clustering
  Future<Map<String, List<LatLng>>> clusterByTimeRanges(
      List<LatLng> coordinates,
      List<Wpt> points) async {

    Map<String, List<LatLng>> timeClusters = {};

    // Morning (6 AM - 12 PM)
    DateTime morningStart = DateTime.now().copyWith(hour: 6, minute: 0, second: 0);
    DateTime morningEnd = DateTime.now().copyWith(hour: 12, minute: 0, second: 0);

    // Afternoon (12 PM - 6 PM)
    DateTime afternoonStart = DateTime.now().copyWith(hour: 12, minute: 0, second: 0);
    DateTime afternoonEnd = DateTime.now().copyWith(hour: 18, minute: 0, second: 0);

    // Evening (6 PM - 12 AM)
    DateTime eveningStart = DateTime.now().copyWith(hour: 18, minute: 0, second: 0);
    DateTime eveningEnd = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

    // Filter coordinates by time ranges
    var morningCoords = await _filterCoordinatesByTimeRange(points, morningStart, morningEnd);
    var afternoonCoords = await _filterCoordinatesByTimeRange(points, afternoonStart, afternoonEnd);
    var eveningCoords = await _filterCoordinatesByTimeRange(points, eveningStart, eveningEnd);

    timeClusters['morning'] = morningCoords;
    timeClusters['afternoon'] = afternoonCoords;
    timeClusters['evening'] = eveningCoords;

    return timeClusters;
  }

  Future<void> generateDailySummary() async {
    try {
      final gpxFilePath = await getCurrentGPXFilePath();

      // 1. Basic metrics
      double totalDistance = await calculateTotalDistance(gpxFilePath);
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(gpxFilePath);
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      // 2. Time-based analysis
      var timeClusters = await clusterByTimeRanges(coordinates, allPoints);

      // 3. Enhanced cluster analysis
      var clusters = gpxService.clusterCoordinates(coordinates, clusterDistanceMeters: 0.1);
      var stayTimes = await _calculateClusterStayTimes(allPoints, clusters);
      var clusterAreas = _calculateClusterAreas(clusters);

      // 4. Generate daily report
      Map<String, dynamic> dailyReport = {
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'total_distance_km': totalDistance,
        'total_coordinates': coordinates.length,
        'total_clusters': clusters.length,
        'time_analysis': {
          'morning_points': timeClusters['morning']?.length ?? 0,
          'afternoon_points': timeClusters['afternoon']?.length ?? 0,
          'evening_points': timeClusters['evening']?.length ?? 0,
        },
        'cluster_metrics': {
          'total_stay_time_minutes': stayTimes.values.fold(0.0, (sum, time) => sum + time),
          'total_area_sq_km': clusterAreas.values.fold(0.0, (sum, area) => sum + area),
        }
      };

      debugPrint("📊 Daily Summary: ${jsonEncode(dailyReport)}");

      // Save to shared preferences for quick access
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('dailySummary', jsonEncode(dailyReport));

    } catch (e) {
      debugPrint("❌ Error generating daily summary: $e");
    }
  }

  // ----------------------
  // Central Points Logic with Remote Config
  // ----------------------

  // MAIN METHOD: GPX se central points process karein aur API mein bhejein
  // EXISTING METHOD KO YEH SE REPLACE KARO:
  Future<void> processGPXAndStoreCentralPoint() async {
    try {
      // ✅ NEW CHECK ADD KARO - Pehle check karo agar aaj ka data already process ho chuka hai
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var existingPoints = await centralPointsRepo.getCentralPoints();
      var todayPoints = existingPoints.where((point) =>
      point.processingDate == today && point.userId == user_id).toList();

      if (todayPoints.isNotEmpty) {
        debugPrint("⚠️ Central point already exists for today, skipping...");
        Get.snackbar(
          'Already Processed',
          'Today\'s central point already exists!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // 🟦 REST OF YOUR EXISTING CODE...
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      debugPrint("🟦 Starting enhanced GPX processing...");

      // 1. Coordinates extract karein
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(gpxFilePath);

      // Extract all points with time data for stay time calculation
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates found in GPX file");
        return;
      }

      debugPrint("📍 Extracted ${coordinates.length} coordinates");

      // 2. Overall central point calculate karein
      LatLng overallCenter = gpxService.calculateCentralPoint(coordinates);
      centralPoint.value = overallCenter;

      debugPrint("🎯 Overall Central Point: ${overallCenter.latitude}, ${overallCenter.longitude}");

      // 3. Clustering karein
      var clusters = gpxService.clusterCoordinates(coordinates, clusterDistanceMeters: 0.1);;
      var centers = gpxService.calculateClusterCenters(clusters);
      clusterCenters.value = centers;

      debugPrint("🗂 Total Clusters Created: ${centers.length}");

      // 4. Enhanced storage with new fields
      await storeCentralPointsToAPI(
          overallCenter,
          centers,
          clusters,
          coordinates.length,
          allPoints  // Pass all points for time calculations
      );

      debugPrint("✅ Enhanced GPX processing completed successfully");

    } catch (e) {
      debugPrint("❌ Error processing GPX: $e");
    }
  }

  // ENHANCED CENTRAL POINTS STORE KARNE KA COMPLETE METHOD WITH NEW FIELDS
  // ENHANCED CENTRAL POINTS STORE KARNE KA COMPLETE METHOD WITH NEW FIELDS
  // ENHANCED CENTRAL POINTS STORE KARNE KA COMPLETE METHOD WITH NEW FIELDS
  // ENHANCED CENTRAL POINTS STORE KARNE KA COMPLETE METHOD WITH NEW FIELDS - FIXED DUPLICATES

  // ENHANCED CENTRAL POINTS STORE KARNE KA METHOD - FIXED INCREMENT
  Future<void> storeCentralPointsToAPI(
      LatLng overallCenter,
      Map<String, LatLng> clusterCenters,
      Map<String, List<LatLng>> originalClusters,
      int totalCoordinates,
      List<Wpt> allPoints,
      ) async {
    try {
      debugPrint("🟦 Storing enhanced central points to API...");

      // ✅ Pehle counter initialize karein
      await _initializeClusterCounter();

      // ✅ Check existing entries for today
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var existingPoints = await centralPointsRepo.getCentralPoints();
      var todayPoints = existingPoints.where((point) =>
      point.processingDate == today && point.userId == user_id).toList();

      if (todayPoints.isNotEmpty) {
        debugPrint("🔄 Existing entries found for today - DELETING OLD");
        for (var oldPoint in todayPoints) {
          if (oldPoint.centralPointId != null) {
            await centralPointsRepo.deleteCentralPoint(oldPoint.centralPointId!);
          }
        }
        debugPrint("🗑️ Deleted ${todayPoints.length} old entries");
      }

      // ✅ Calculate additional metrics
      var stayTimes = await _calculateClusterStayTimes(allPoints, originalClusters);
      var clusterAreas = _calculateClusterAreas(originalClusters);

      // ✅ Get address for overall center
      String overallAddress = await _getAddressFromLatLng(overallCenter);

      // ✅ Enhanced cluster data preparation
      List<Map<String, dynamic>> clustersData = [];

      for (var clusterKey in clusterCenters.keys) {
        LatLng center = clusterCenters[clusterKey]!;
        int pointsCount = originalClusters[clusterKey]?.length ?? 0;
        double stayTime = stayTimes[clusterKey] ?? 0.0;
        double area = clusterAreas[clusterKey] ?? 0.0;

        String clusterAddress = await _getAddressFromLatLng(center);

        clustersData.add({
          'cluster_id': clusterKey,
          'center_lat': center.latitude,
          'center_lng': center.longitude,
          'cluster_points_count': pointsCount,
          'stay_time_minutes': stayTime,
          'cluster_area_sq_km': area,
          'cluster_address': clusterAddress,
          'cluster_created_at': DateTime.now().toIso8601String(),
        });
      }

      debugPrint("📊 Prepared ${clustersData.length} enhanced clusters data");

      // ✅ Calculate total metrics
      double totalStayTime = stayTimes.values.fold(0.0, (sum, time) => sum + time);
      double totalClusterArea = clusterAreas.values.fold(0.0, (sum, area) => sum + area);

      // ✅ PROPER ID GENERATION USE KAREIN
      String uniqueId = await getNextClusterPointId(user_id);

      // ✅ Enhanced database save
      CentralPointsModel centralPoint = CentralPointsModel(
        centralPointId: uniqueId,

        userId: user_id,
        overallCenterLat: overallCenter.latitude,
        overallCenterLng: overallCenter.longitude,
        totalClusters: clusterCenters.length,
        totalCoordinates: totalCoordinates,
        processingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        bookerName: userName,
        clusterData: jsonEncode(clustersData),
        // posted: 0,
        createdAt: DateTime.now().toIso8601String(),
        clusterArea: "${totalClusterArea.toStringAsFixed(4)} sq km",
        addressDistrict: overallAddress,
        stayTimeInCluster: totalStayTime,
      );

      // ✅ Local database mein save karein
      await centralPointsRepo.addCentralPoint(centralPoint);
      debugPrint("💾 Enhanced central point saved to local database with ID: $uniqueId");

      // ✅ API sync karein
      bool apiSuccess = await centralPointsRepo.postCentralPointToAPI(centralPoint);

      // ✅ Refresh list
      await fetchAllCentralPoints();

      debugPrint("🎉 Enhanced central points storage process completed");

    } catch (e) {
      debugPrint("❌ Error storing enhanced central points: $e");
    }
  }

// Testing ke liye - Current counter status check karein
  Future<void> checkClusterCounterStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCounter = prefs.getInt('clusterPointSerialCounter') ?? 1;
    String lastDay = prefs.getString('lastClusterDay') ?? '';
    String lastMonth = prefs.getString('lastClusterMonth') ?? '';

    debugPrint("""
  📊 CLUSTER COUNTER STATUS:
  - Current Counter: $currentCounter
  - Last Processed Day: $lastDay
  - Last Processed Month: $lastMonth
  - Next ID: ${_generateClusterPointId(user_id)}
  """);
  }

// Manual counter reset (if needed)
  Future<void> resetClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clusterPointSerialCounter = 1;
    await prefs.setInt('clusterPointSerialCounter', 1);
    await prefs.remove('lastClusterDay');
    await prefs.remove('lastClusterMonth');
    debugPrint("🔄 Cluster counter manually reset to 1");
  }
  Future<Map<String, double>> _calculateClusterStayTimes(
      List<Wpt> points,
      Map<String, List<LatLng>> clusters,
      {double timeThresholdMinutes = 2.0}
      ) async {
    debugPrint("⏱️ Calculating ACTUAL cluster stay times...");

    Map<String, double> stayTimes = {};
    Map<String, List<DateTime>> clusterTimestamps = {};

    // Group points by cluster
    for (var point in points) {
      if (point.lat == null || point.lon == null || point.time == null) continue;

      LatLng pointLatLng = LatLng(point.lat!.toDouble(), point.lon!.toDouble());

      // Find which cluster this point belongs to
      for (var clusterKey in clusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distance = _calculateHaversineDistance(pointLatLng, clusterCenter);

        if (distance <= 0.1) { // 100 meters threshold
          if (!clusterTimestamps.containsKey(clusterKey)) {
            clusterTimestamps[clusterKey] = [];
          }
          clusterTimestamps[clusterKey]!.add(point.time!);
          break;
        }
      }
    }

    // Calculate ACTUAL stay time for each cluster
    clusterTimestamps.forEach((clusterKey, timestamps) {
      if (timestamps.length < 2) {
        stayTimes[clusterKey] = 0.0;
        debugPrint("⏱️ Cluster $clusterKey: Only 1 point, stay time = 0");
        return;
      }

      // Sort timestamps
      timestamps.sort();

      double totalStayTime = 0.0;
      DateTime? entryTime;
      DateTime? lastTimeInCluster;

      for (int i = 0; i < timestamps.length; i++) {
        DateTime currentTime = timestamps[i];

        // Check if this is a new stay session
        if (entryTime == null) {
          entryTime = currentTime;
          lastTimeInCluster = currentTime;
          debugPrint("🟢 Cluster $clusterKey: Entry at ${currentTime.toString()}");
          continue;
        }

        // Check time gap from last point
        double timeGap = currentTime.difference(lastTimeInCluster!).inMinutes.toDouble();

        if (timeGap <= timeThresholdMinutes) {
          // Continuous stay - update last time
          lastTimeInCluster = currentTime;
        } else {
          // Break in stay - calculate previous session and start new
          double sessionStayTime = lastTimeInCluster.difference(entryTime!).inMinutes.toDouble();
          totalStayTime += sessionStayTime;
          debugPrint("🔴 Session ended: ${sessionStayTime.toStringAsFixed(2)} min");

          entryTime = currentTime;
          lastTimeInCluster = currentTime;
        }
      }

      // Add the last session
      if (entryTime != null && lastTimeInCluster != null) {
        double lastSessionStayTime = lastTimeInCluster.difference(entryTime).inMinutes.toDouble();
        totalStayTime += lastSessionStayTime;
        debugPrint("🔴 Final session: ${lastSessionStayTime.toStringAsFixed(2)} min");
      }

      stayTimes[clusterKey] = totalStayTime;
      debugPrint("⏱️ Cluster $clusterKey TOTAL stay time: ${totalStayTime.toStringAsFixed(2)} minutes");
    });

    return stayTimes;
  }

  // Calculate cluster area in square kilometers
  Map<String, double> _calculateClusterAreas(Map<String, List<LatLng>> clusters) {
    debugPrint("📐 Calculating cluster areas...");

    Map<String, double> clusterAreas = {};

    clusters.forEach((clusterKey, points) {
      if (points.length < 3) {
        clusterAreas[clusterKey] = 0.0;
        return;
      }

      double area = _calculatePolygonArea(points);
      clusterAreas[clusterKey] = area;
      debugPrint("📐 Cluster $clusterKey area: ${area.toStringAsFixed(6)} sq km");
    });

    return clusterAreas;
  }

  // Calculate polygon area using shoelace formula
  double _calculatePolygonArea(List<LatLng> points) {
    double area = 0.0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      LatLng current = points[i];
      LatLng next = points[(i + 1) % n];

      area += (current.longitude * next.latitude - next.longitude * current.latitude);
    }

    return (area.abs() / 2) * 111.32 * 111.32; // Convert to sq km (approximate)
  }

  // Get address from coordinates
  // Get FULL address from coordinates
  // Get COMPREHENSIVE address from coordinates
  Future<String> _getAddressFromLatLng(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          point.latitude,
          point.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build comprehensive address
        StringBuffer addressBuffer = StringBuffer();

        // Street address
        if (place.street != null && place.street!.isNotEmpty) {
          addressBuffer.write(place.street!);
        }

        // Locality details
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.subLocality!);
        }

        // City/Town
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.locality!);
        }

        // District/County
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.subAdministrativeArea!);
        }

        // State/Province
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.administrativeArea!);
        }

        // Postal Code
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(' - ');
          addressBuffer.write(place.postalCode!);
        }

        // Country
        if (place.country != null && place.country!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.country!);
        }

        String fullAddress = addressBuffer.toString();

        // If address is still empty, provide a meaningful fallback
        if (fullAddress.isEmpty) {
          return 'Near ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        }

        debugPrint("📍 Comprehensive Address: $fullAddress");
        return fullAddress;
      }
    } catch (e) {
      debugPrint("❌ Error getting comprehensive address: $e");

      // Fallback with coordinates if address fails
      return 'Near ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    }

    return 'Address Not Available';
  }

  // Parse cluster key to LatLng
  LatLng _parseClusterKey(String key) {
    debugPrint("🔧 Parsing cluster key: $key");
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  // Calculate Haversine distance between two points
  double _calculateHaversineDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0;

    double lat1 = point1.latitude * (pi / 180.0);
    double lon1 = point1.longitude * (pi / 180.0);
    double lat2 = point2.latitude * (pi / 180.0);
    double lon2 = point2.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Helper method to extract all points with time data
  Future<List<Wpt>> _extractAllPointsWithTime(String filePath) async {
    try {
      File file = File(filePath);
      String gpxContent = await file.readAsString();
      Gpx gpx = GpxReader().fromString(gpxContent);

      List<Wpt> allPoints = [];

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          allPoints.addAll(segment.trkpts);
        }
      }

      return allPoints;
    } catch (e) {
      debugPrint("❌ Error extracting points with time: $e");
      return [];
    }
  }

  // SABHI CENTRAL POINTS FETCH KAREIN
  Future<void> fetchAllCentralPoints() async {
    try {
      var points = await centralPointsRepo.getCentralPoints();
      allCentralPoints.value = points;
      debugPrint("📥 Fetched ${points.length} central points");
    } catch (e) {
      debugPrint("❌ Error fetching central points: $e");
    }
  }

  // MANUAL SYNC KARNE KA METHOD
  Future<void> syncCentralPointsToAPI() async {
    try {
      debugPrint("🟨 Manual sync started...");
      // Option 1: Post all pending in batch
      await centralPointsRepo.postCentralPointsInBatch();

      // (Removed: await centralPointsRepo.postCentralPointToAPI(someCentralPointModel);)
      await fetchAllCentralPoints();
      debugPrint("✅ Manual sync completed");
    } catch (e) {
      debugPrint("�� Error in manual sync: $e");
    }
  }

  // ----------------------
  // Location Saving Methods
  // ----------------------

  // Method 1: Basic location save (existing functionality)
  Future<void> saveLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';
    final maingpxFile = File(gpxFilePath);

    if (!maingpxFile.existsSync()) {
      debugPrint('❌ GPX file does not exist');
      return;
    }

    try {
      double totalDistance = await calculateTotalDistance(gpxFilePath);
      await prefs.setDouble('totalDistance', totalDistance);

      List<int> gpxBytesList = await maingpxFile.readAsBytes();
      Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);

      await _loadCounter();
      final orderSerial = generateNewOrderId(user_id);

      await addLocation(LocationModel(
        location_id: orderSerial.toString(),
        user_id: user_id.toString(),
        total_distance: totalDistance.toString(),
        file_name: "$date.gpx",
        booker_name: userName,
        body: gpxBytes,
      ));

      await locationRepository.postDataFromDatabaseToAPI();

      debugPrint("✅ Location data saved successfully");

    } catch (e) {
      debugPrint("❌ Error in saveLocation: $e");
    }
  }

  // Method 2: Advanced save with central points processing
  Future<void> saveLocationWithCentralPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

    if (!File(gpxFilePath).existsSync()) {
      debugPrint('❌ GPX file does not exist');
      return;
    }

    try {
      debugPrint("🟦 Starting enhanced location save...");

      // 1. Calculate total distance
      double totalDistance = await calculateTotalDistance(gpxFilePath);
      await prefs.setDouble('totalDistance', totalDistance);
      debugPrint("📏 Total Distance: $totalDistance km");

      // 2. Process central points and clusters (API automatic call hoga)
      await processGPXAndStoreCentralPoint();

      // 3. Save to local database (original functionality)
      List<int> gpxBytesList = await File(gpxFilePath).readAsBytes();
      Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);

      await _loadCounter();
      final orderSerial = generateNewOrderId(user_id);

      await addLocation(LocationModel(
        location_id: orderSerial.toString(),
        user_id: user_id.toString(),
        total_distance: totalDistance.toString(),
        file_name: "$date.gpx",
        booker_name: userName,
        body: gpxBytes,
      ));

      // 4. Sync location data to API
      await locationRepository.postDataFromDatabaseToAPI();

      debugPrint("✅ Enhanced location save completed successfully");

    } catch (e) {
      debugPrint("❌ Error in saveLocationWithCentralPoints: $e");
    }
  }

  // ----------------------
  // Counter Logic
  // ----------------------
  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    locationSerialCounter = (prefs.getInt('locationSerialCounter') ?? locationHighestSerial ?? 1);
    locationCurrentMonth =
        prefs.getString('locationCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (locationCurrentMonth != currentMonth) {
      locationSerialCounter = 1;
      locationCurrentMonth = currentMonth;
    }
    debugPrint('SR: $locationSerialCounter');
  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('locationSerialCounter', locationSerialCounter);
    await prefs.setString('locationCurrentMonth', locationCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      locationSerialCounter = locationHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (locationCurrentMonth != currentMonth) {
      locationSerialCounter = 1;
      locationCurrentMonth = currentMonth;
    }

    String orderId =
        "LOC-$user_id-$currentMonth-${locationSerialCounter.toString().padLeft(3, '0')}";
    locationSerialCounter++;
    _saveCounter();
    return orderId;
  }

  // ----------------------
  // Location Logic
  // ----------------------
  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude1.value = position.latitude;
        globalLongitude1.value = position.longitude;

        List<Placemark> placemarks = await placemarkFromCoordinates(
            globalLatitude1.value, globalLongitude1.value);

        if (placemarks.isNotEmpty) {
          Placemark currentPlace = placemarks[0];
          String address =
              "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";
          shopAddress.value = address.trim().isEmpty ? "Not Verified" : address;
        }

        debugPrint('Latitude: ${globalLatitude1.value}, Longitude: ${globalLongitude1.value}');
        debugPrint('Address is: ${shopAddress.value}');
      } catch (e) {
        debugPrint("Error getting location: $e");
      }
    }
  }

  loadClockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isClockedIn.value = prefs.getBool('isClockedIn') ?? false;
    if (!isClockedIn.value) {
      prefs.setInt('secondsPassed', 0);
    }
  }

  saveClockStatus(bool clockedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isClockedIn', clockedIn);
    isClockedIn.value = clockedIn;
  }

  saveCurrentTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    String formattedTime = _formatDateTime(currentTime);
    await prefs.setString('savedTime', formattedTime);
    debugPrint("Save Current Time");
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }

  // ----------------------
  // GPX & Distance Logic
  // ----------------------
  Future<double> calculateTotalDistance(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      return 0.0;
    }

    String gpxContent = await file.readAsString();
    if (gpxContent.isEmpty) {
      return 0.0;
    }

    Gpx gpx;
    try {
      gpx = GpxReader().fromString(gpxContent);
    } catch (e) {
      debugPrint("Error parsing GPX content: $e");
      return 0.0;
    }

    double totalDistance = 0.0;
    for (var track in gpx.trks) {
      for (var segment in track.trksegs) {
        for (int i = 0; i < segment.trkpts.length - 1; i++) {
          double distance = calculateDistance(
            segment.trkpts[i].lat?.toDouble() ?? 0.0,
            segment.trkpts[i].lon?.toDouble() ?? 0.0,
            segment.trkpts[i + 1].lat?.toDouble() ?? 0.0,
            segment.trkpts[i + 1].lon?.toDouble() ?? 0.0,
          );
          totalDistance += distance;
        }
      }
    }

    debugPrint("CUT: $totalDistance");
    return totalDistance;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000); // Distance in kilometers
  }

  Future<double> calculateShiftDistance(DateTime shiftStartTime) async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      File file = File(gpxFilePath);
      if (!file.existsSync()) return 0.0;

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return 0.0;

      Gpx gpx = GpxReader().fromString(gpxContent);
      double shiftDistance = 0.0;

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          List<Wpt> shiftPoints = [];
          for (var point in segment.trkpts) {
            if (point.time != null && point.time!.isAfter(shiftStartTime)) {
              shiftPoints.add(point);
            }
          }

          for (int i = 0; i < shiftPoints.length - 1; i++) {
            double distance = calculateDistance(
              shiftPoints[i].lat?.toDouble() ?? 0.0,
              shiftPoints[i].lon?.toDouble() ?? 0.0,
              shiftPoints[i + 1].lat?.toDouble() ?? 0.0,
              shiftPoints[i + 1].lon?.toDouble() ?? 0.0,
            );
            shiftDistance += distance;
          }
        }
      }

      debugPrint("📍 Shift Distance: $shiftDistance km");
      return shiftDistance;
    } catch (e) {
      debugPrint("❌ Error calculating shift distance: $e");
      return 0.0;
    }
  }

  // ----------------------
  // Permissions Logic
  // ----------------------
  Future<void> requestPermissions() async {
    if (await Permission.notification.request().isDenied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _showLocationRequiredDialog();
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationRequiredDialog();
      return;
    }

    if (await Permission.locationAlways.request().isDenied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }
  }

  void _showLocationRequiredDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('For a better experience, your device will need to use Location Accuracy.', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text('The following settings should be on:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Device location'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Location Accuracy'),
                  ],
                ),
                SizedBox(height: 12),
                Text('Location Accuracy provides more accurate location for apps and services.', style: TextStyle(fontSize: 14, color: Colors.grey)),
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

  // ----------------------
  // Database CRUD
  // ----------------------
  Future<void> fetchAllLocation() async {
    var location = await locationRepository.getLocation();
    allLocation.value = location;
  }

  addLocation(LocationModel locationModel) {
    locationRepository.add(locationModel);
    fetchAllLocation();
  }

  void updateLocation(LocationModel locationModel) {
    locationRepository.update(locationModel);
    fetchAllLocation();
  }

  void deleteLocation(String id) {
    locationRepository.delete(id);
    fetchAllLocation();
  }

  serialCounterGet() async {
    await locationRepository.serialNumberGeneratorApi();
  }
  // 🔥 YEH NAYA METHOD ADD KAREN 🔥
  void _initializeDailyProcessing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastProcessedDate.value = prefs.getString('lastProcessedDate') ?? '';
    isDailyProcessingComplete.value = prefs.getBool('isDailyProcessingComplete') ?? false;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastProcessedDate.value != today) {
      isDailyProcessingComplete.value = false;
      await prefs.setBool('isDailyProcessingComplete', false);
    }
  }


  // ----------------------
  // Utility Methods
  // ----------------------

  // Get unposted central points count
  Future<int> getUnpostedCentralPointsCount() async {
    var unposted = await centralPointsRepo.getUnPostedCentralPoints();
    return unposted.length;
  }
  // ----------------------
// Central Points Counter Logic - FIXED
// ----------------------

// Initialize counter
  Future<void> _initializeClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get current month and day
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    String currentDay = DateFormat('dd').format(DateTime.now());

    // Check if we're in a new day or month
    String lastProcessedDay = prefs.getString('lastClusterDay') ?? '';
    String lastProcessedMonth = prefs.getString('lastClusterMonth') ?? '';

    if (lastProcessedDay != currentDay || lastProcessedMonth != currentMonth) {
      // New day or month - reset counter to 1
      clusterPointSerialCounter = 1;
      await prefs.setInt('clusterPointSerialCounter', 1);
      await prefs.setString('lastClusterDay', currentDay);
      await prefs.setString('lastClusterMonth', currentMonth);
      debugPrint("🔄 Cluster counter reset to 1 for new day/month");
    } else {
      // Same day - load existing counter
      clusterPointSerialCounter = prefs.getInt('clusterPointSerialCounter') ?? 1;
    }

    debugPrint("🔢 Initialized cluster counter: $clusterPointSerialCounter");
  }

// Save counter to SharedPreferences
  Future<void> _saveClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clusterPointSerialCounter', clusterPointSerialCounter);
    debugPrint("💾 Saved cluster counter: $clusterPointSerialCounter");
  }

// Generate unique ID with proper increment
  String _generateClusterPointId(String user_id) {
    final now = DateTime.now();
    String day = DateFormat('dd').format(now);
    String month = DateFormat('MMM').format(now);

    // Format: CD-USER_ID-DAY-MONTH-SERIAL (e.g., CD-TEST07-22-Nov-001)
    String uniqueId = "CD-$user_id-$day-$month-${clusterPointSerialCounter.toString().padLeft(3, '0')}";

    debugPrint("🆕 Generated Cluster ID: $uniqueId");
    return uniqueId;
  }

// Enhanced method to handle ID generation properly
  Future<String> getNextClusterPointId(String user_id) async {
    await _initializeClusterCounter();

    // Generate ID with current counter
    String newId = _generateClusterPointId(user_id);

    // Increment counter for next use
    clusterPointSerialCounter++;
    await _saveClusterCounter();

    return newId;
  }
  // 🔥 YEH NAYA METHOD ADD KAREN - DAILY SINGLE FILE
  Future<void> consolidateDailyGPXData() async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final dailyGPXFilePath = '${downloadDirectory!.path}/track$date.gpx';

      debugPrint("🔄 Starting Daily GPX Consolidation for: $date");

      // Check if main daily file exists
      File dailyFile = File(dailyGPXFilePath);

      if (!dailyFile.existsSync()) {
        debugPrint("📄 Daily file doesn't exist, creating new one");
        // Create empty GPX structure
        String initialGPX = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="OrderBookingApp">
  <trk>
    <name>Daily Track $date</name>
    <trkseg>
    </trkseg>
  </trk>
</gpx>''';

        await dailyFile.writeAsString(initialGPX);
      }

      // Read existing daily file
      String dailyContent = await dailyFile.readAsString();
      Gpx dailyGpx = GpxReader().fromString(dailyContent);

      // Get main track segment
      if (dailyGpx.trks.isEmpty) {
        dailyGpx.trks.add(Trk());
      }
      if (dailyGpx.trks.first.trksegs.isEmpty) {
        dailyGpx.trks.first.trksegs.add(Trkseg());
      }

      Trkseg mainSegment = dailyGpx.trks.first.trksegs.first;
      int initialPoints = mainSegment.trkpts.length;

      debugPrint("📊 Initial points in daily file: $initialPoints");

      // Find and merge all temporary/partial files from today
      List<File> allGPXFiles = await _findAllTodayGPXFiles(downloadDirectory, date);
      debugPrint("📁 Found ${allGPXFiles.length} GPX files for today");

      int totalMergedPoints = 0;

      for (File tempFile in allGPXFiles) {
        if (tempFile.path != dailyGPXFilePath) { // Don't merge with self
          try {
            String tempContent = await tempFile.readAsString();
            Gpx tempGpx = GpxReader().fromString(tempContent);

            // Merge all points from temporary file
            for (var track in tempGpx.trks) {
              for (var segment in track.trksegs) {
                for (var point in segment.trkpts) {
                  // Add point to main segment (avoid duplicates)
                  if (!_containsPoint(mainSegment.trkpts, point)) {
                    mainSegment.trkpts.add(point);
                    totalMergedPoints++;
                  }
                }
              }
            }

            debugPrint("✅ Merged ${tempFile.path}");

            // Optional: Delete temporary file after merging
            // await tempFile.delete();

          } catch (e) {
            debugPrint("⚠️ Error merging ${tempFile.path}: $e");
          }
        }
      }

      // Sort points by timestamp (if available)
      mainSegment.trkpts.sort((a, b) {
        if (a.time == null || b.time == null) return 0;
        return a.time!.compareTo(b.time!);
      });

      // Save consolidated file
      String consolidatedGPX = GpxWriter().asString(dailyGpx);
      await dailyFile.writeAsString(consolidatedGPX);

      debugPrint("🎉 DAILY CONSOLIDATION COMPLETED");
      debugPrint("📈 Points: $initialPoints → ${mainSegment.trkpts.length}");
      debugPrint("🔄 Merged: $totalMergedPoints new points");
      debugPrint("💾 Saved to: $dailyGPXFilePath");

    } catch (e) {
      debugPrint("❌ Error in daily consolidation: $e");
    }
  }

// Helper: Find all GPX files from today
  Future<List<File>> _findAllTodayGPXFiles(Directory directory, String date) async {
    List<File> todayFiles = [];

    try {
      List<FileSystemEntity> entities = await directory.list().toList();

      for (FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith('.gpx')) {
          String fileName = entity.path.split('/').last;

          // Check if file is from today
          if (fileName.contains(date) || _isFileFromToday(entity)) {
            todayFiles.add(entity);
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error finding today's files: $e");
    }

    return todayFiles;
  }

// Helper: Check if file was created today
  bool _isFileFromToday(File file) {
    try {
      DateTime fileTime = file.lastModifiedSync();
      DateTime today = DateTime.now();

      return fileTime.year == today.year &&
          fileTime.month == today.month &&
          fileTime.day == today.day;
    } catch (e) {
      return false;
    }
  }

// Helper: Check if point already exists in list
  bool _containsPoint(List<Wpt> points, Wpt newPoint) {
    for (Wpt point in points) {
      if (point.lat == newPoint.lat &&
          point.lon == newPoint.lon &&
          point.time == newPoint.time) {
        return true;
      }
    }
    return false;
  }
  // LocationViewModel.dart mein yeh naya method add karein:

  Future<void> saveLocationFromConsolidatedFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final downloadDirectory = await getDownloadsDirectory();
    final consolidatedGPXFilePath = '${downloadDirectory!.path}/track$date.gpx';
    final consolidatedFile = File(consolidatedGPXFilePath);

    if (!consolidatedFile.existsSync()) {
      debugPrint('❌ Consolidated GPX file does not exist');
      return;
    }

    try {
      // Calculate total distance from SINGLE consolidated file
      double totalDistance = await calculateTotalDistance(consolidatedGPXFilePath);
      await prefs.setDouble('totalDistance', totalDistance);

      // Read bytes from SINGLE consolidated file
      List<int> gpxBytesList = await consolidatedFile.readAsBytes();
      Uint8List gpxBytes = Uint8List.fromList(gpxBytesList);

      await _loadCounter();
      final orderSerial = generateNewOrderId(user_id);

      // Save to database
      await addLocation(LocationModel(
        location_id: orderSerial.toString(),
        user_id: user_id.toString(),
        total_distance: totalDistance.toString(),
        file_name: "$date.gpx", // Single file name
        booker_name: userName,
        body: gpxBytes,
      ));

      // Sync to API
      await locationRepository.postDataFromDatabaseToAPI();

      debugPrint("✅ Location data saved from CONSOLIDATED file");
      debugPrint("📁 File: $date.gpx");
      debugPrint("📏 Distance: $totalDistance km");

    } catch (e) {
      debugPrint("❌ Error in saveLocationFromConsolidatedFile: $e");
    }
  }
  // 🔥 YEH NAYA METHOD ADD KAREN - LocationViewModel.dart mein
  Future<void> updateTodayCentralPoint() async {
    try {
      debugPrint("🔄 Starting updateTodayCentralPoint...");

      // Pehle daily consolidation karein
      await consolidateDailyGPXData();

      // Phir central points process karein
      await processGPXAndStoreCentralPoint();

      // Phir 24 hours data process karein
      await process24HoursGPXData();

      debugPrint("✅ updateTodayCentralPoint completed successfully");

    } catch (e) {
      debugPrint("❌ Error in updateTodayCentralPoint: $e");
    }
  }

  // Clear all central points (for testing)
  Future<void> clearAllCentralPoints() async {
    var points = await centralPointsRepo.getCentralPoints();
    for (var point in points) {
      if (point.centralPointId != null) {
        await centralPointsRepo.deleteCentralPoint(point.centralPointId!);
      }
    }

    await fetchAllCentralPoints();
    debugPrint("🗑 All central points cleared");
  }

  // Check if central points feature is enabled
  bool isCentralPointsFeatureEnabled() {
    return centralPointsRepo != null && gpxService != null;
  }

// Add these helper methods to your existing location_view_model.dart file:

// In the existing location_view_model.dart file, add these methods:

// ✅ NEW: Fast distance calculation
  Future<double> calculateShiftDistanceFast(DateTime shiftStartTime) async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      File file = File(gpxFilePath);
      if (!file.existsSync()) return 0.0;

      // Quick read without parsing entire GPX
      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) return 0.0;

      // Simple regex to extract coordinates (fast)
      RegExp coordPattern = RegExp(r'lat="([^"]+)" lon="([^"]+)"');
      List<RegExpMatch> matches = coordPattern.allMatches(gpxContent).toList();

      if (matches.length < 2) return 0.0;

      double totalDistance = 0.0;
      double? prevLat, prevLon;

      for (int i = 0; i < matches.length; i++) {
        double lat = double.parse(matches[i].group(1)!);
        double lon = double.parse(matches[i].group(2)!);

        if (prevLat != null && prevLon != null) {
          totalDistance += calculateDistance(prevLat, prevLon, lat, lon);
        }

        prevLat = lat;
        prevLon = lon;
      }

      return totalDistance;
    } catch (e) {
      debugPrint("❌ Fast distance calculation error: $e");
      return 0.0;
    }
  }

// ✅ NEW: Check pending sync status
  Future<Map<String, dynamic>> checkSyncStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String syncStatus = prefs.getString('clockOutSyncStatus') ?? 'unknown';
    String? lastClockOutTime = prefs.getString('lastClockOutTime');
    double? lastDistance = prefs.getDouble('lastClockOutDistance');

    return {
      'syncStatus': syncStatus,
      'lastClockOutTime': lastClockOutTime,
      'lastDistance': lastDistance,
      'hasPendingSync': syncStatus == 'pending' || syncStatus == 'pending_local' || syncStatus == 'retry_needed'
    };
  }

// ✅ NEW: Clear sync status (for testing)
  Future<void> clearSyncStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockOutSyncStatus');
    await prefs.remove('lastClockOutTime');
    await prefs.remove('lastClockOutDistance');
    await prefs.remove('pendingAttendanceOutId');
    debugPrint("🧹 Sync status cleared");
  }


}