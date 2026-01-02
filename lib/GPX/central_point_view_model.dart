import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import '../GPX/central_point_model.dart';
import '../GPX/central_point_repository.dart';
import '../GPX/gpx_coordinate_service.dart';

class CentralPointViewModel extends GetxController {
  final CentralPointsRepository centralPointsRepo = CentralPointsRepository();
  final GPXCoordinateService gpxService = GPXCoordinateService();

  var allCentralPoints = <CentralPointsModel>[].obs;
  var clusterCenters = <String, LatLng>{}.obs;
  var centralPoint = LatLng(0.0, 0.0).obs;
  var isDailyProcessingComplete = false.obs;
  var lastProcessedDate = ''.obs;

  int clusterPointSerialCounter = 1;
  String user_id = ''; // Initialize from your user management
  String userName = ''; // Initialize from your user management

  @override
  void onInit() {
    super.onInit();
    fetchAllCentralPoints();
    _initializeDailyProcessing();
    _initializeClusterCounter();
  }

  // ----------------------
  // Daily Processing Logic
  // ----------------------

  void _initializeDailyProcessing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastProcessedDate.value = prefs.getString('lastProcessedDate') ?? '';
    isDailyProcessingComplete.value =
        prefs.getBool('isDailyProcessingComplete') ?? false;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastProcessedDate.value != today) {
      isDailyProcessingComplete.value = false;
      await prefs.setBool('isDailyProcessingComplete', false);
    }
  }

  // ----------------------
  // 24 Hours GPX Data Processing
  // ----------------------

  String getDailyGPXFileName() {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return 'track$date.gpx';
  }

  Future<String> getCurrentGPXFilePath() async {
    final downloadDirectory = await getDownloadsDirectory();
    return '${downloadDirectory!.path}/${getDailyGPXFileName()}';
  }

  // Time-based filtering helper method
  Future<List<LatLng>> _filterCoordinatesByTimeRange(List<Wpt> points,
      DateTime startTime, DateTime endTime) async {
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

    debugPrint(
        "⏰ Time range ${DateFormat('HH:mm').format(startTime)}-${DateFormat(
            'HH:mm').format(endTime)}: ${filteredCoords.length} points");
    return filteredCoords;
  }

  // 24 Hours processing method
  Future<void> process24HoursGPXData() async {
    try {
      final gpxFilePath = await getCurrentGPXFilePath();
      debugPrint("🕐 Processing 24 hours GPX data from: $gpxFilePath");

      // 1. Extract all coordinates from today's file
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(
          gpxFilePath);

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
      var clusters = gpxService.clusterCoordinates(
          coordinates, clusterDistance: 0.1);
      var centers = gpxService.calculateClusterCenters(clusters);

      debugPrint("🗂 24 Hours Summary:");
      debugPrint("   - Total Coordinates: ${coordinates.length}");
      debugPrint("   - Total Clusters: ${centers.length}");
      debugPrint(
          "   - Overall Center: ${overallCenter.latitude}, ${overallCenter
              .longitude}");

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
    DateTime morningStart = DateTime.now().copyWith(
        hour: 6, minute: 0, second: 0);
    DateTime morningEnd = DateTime.now().copyWith(
        hour: 12, minute: 0, second: 0);

    // Afternoon (12 PM - 6 PM)
    DateTime afternoonStart = DateTime.now().copyWith(
        hour: 12, minute: 0, second: 0);
    DateTime afternoonEnd = DateTime.now().copyWith(
        hour: 18, minute: 0, second: 0);

    // Evening (6 PM - 12 AM)
    DateTime eveningStart = DateTime.now().copyWith(
        hour: 18, minute: 0, second: 0);
    DateTime eveningEnd = DateTime.now().copyWith(
        hour: 23, minute: 59, second: 59);

    // Filter coordinates by time ranges
    var morningCoords = await _filterCoordinatesByTimeRange(
        points, morningStart, morningEnd);
    var afternoonCoords = await _filterCoordinatesByTimeRange(
        points, afternoonStart, afternoonEnd);
    var eveningCoords = await _filterCoordinatesByTimeRange(
        points, eveningStart, eveningEnd);

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
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(
          gpxFilePath);
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      // 2. Time-based analysis
      var timeClusters = await clusterByTimeRanges(coordinates, allPoints);

      // 3. Enhanced cluster analysis
      var clusters = gpxService.clusterCoordinates(
          coordinates, clusterDistance: 0.1);
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
          'total_stay_time_minutes': stayTimes.values.fold(
              0.0, (sum, time) => sum + time),
          'total_area_sq_km': clusterAreas.values.fold(
              0.0, (sum, area) => sum + area),
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
  // Central Points Logic
  // ----------------------

  Future<void> processGPXAndStoreCentralPoint() async {
    try {
      // ✅ Check if today's data already processed
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

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      debugPrint("🟦 Starting enhanced GPX processing...");

      // 1. Extract coordinates
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(
          gpxFilePath);
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates found in GPX file");
        return;
      }

      debugPrint("📍 Extracted ${coordinates.length} coordinates");

      // 2. Calculate overall central point
      LatLng overallCenter = gpxService.calculateCentralPoint(coordinates);
      centralPoint.value = overallCenter;

      debugPrint(
          "🎯 Overall Central Point: ${overallCenter.latitude}, ${overallCenter
              .longitude}");

      // 3. Create clusters
      var clusters = gpxService.clusterCoordinates(
          coordinates, clusterDistance: 0.1);
      var centers = gpxService.calculateClusterCenters(clusters);
      clusterCenters.value = centers;

      debugPrint("🗂 Total Clusters Created: ${centers.length}");

      // 4. Enhanced storage with new fields
      await storeCentralPointsToAPI(
          overallCenter,
          centers,
          clusters,
          coordinates.length,
          allPoints
      );

      debugPrint("✅ Enhanced GPX processing completed successfully");
    } catch (e) {
      debugPrint("❌ Error processing GPX: $e");
    }
  }

  // Enhanced central points storage
  Future<void> storeCentralPointsToAPI(LatLng overallCenter,
      Map<String, LatLng> clusterCenters,
      Map<String, List<LatLng>> originalClusters,
      int totalCoordinates,
      List<Wpt> allPoints,) async {
    try {
      debugPrint("🟦 Storing enhanced central points to API...");

      // ✅ Initialize counter
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
            await centralPointsRepo.deleteCentralPoint(
                oldPoint.centralPointId!);
          }
        }
        debugPrint("🗑️ Deleted ${todayPoints.length} old entries");
      }

      // ✅ Calculate additional metrics
      var stayTimes = await _calculateClusterStayTimes(
          allPoints, originalClusters);
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
      double totalStayTime = stayTimes.values.fold(
          0.0, (sum, time) => sum + time);
      double totalClusterArea = clusterAreas.values.fold(
          0.0, (sum, area) => sum + area);

      // ✅ Generate unique ID
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
        createdAt: DateTime.now().toIso8601String(),
        clusterArea: "${totalClusterArea.toStringAsFixed(4)} sq km",
        addressDistrict: overallAddress,
        stayTimeInCluster: totalStayTime,
      );

      // ✅ Local database save
      await centralPointsRepo.addCentralPoint(centralPoint);
      debugPrint(
          "💾 Enhanced central point saved to local database with ID: $uniqueId");

      // ✅ API sync
      bool apiSuccess = await centralPointsRepo.postCentralPointToAPI(
          centralPoint);

      // ✅ Refresh list
      await fetchAllCentralPoints();

      debugPrint("🎉 Enhanced central points storage process completed");
    } catch (e) {
      debugPrint("❌ Error storing enhanced central points: $e");
    }
  }

  // ----------------------
  // Cluster Analysis Methods
  // ----------------------

  Future<Map<String, double>> _calculateClusterStayTimes(List<Wpt> points,
      Map<String, List<LatLng>> clusters,
      {double timeThresholdMinutes = 2.0}) async {
    debugPrint("⏱️ Calculating ACTUAL cluster stay times...");

    Map<String, double> stayTimes = {};
    Map<String, List<DateTime>> clusterTimestamps = {};

    // Group points by cluster
    for (var point in points) {
      if (point.lat == null || point.lon == null || point.time == null)
        continue;

      LatLng pointLatLng = LatLng(point.lat!.toDouble(), point.lon!.toDouble());

      // Find which cluster this point belongs to
      for (var clusterKey in clusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distance = _calculateHaversineDistance(
            pointLatLng, clusterCenter);

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
          debugPrint(
              "🟢 Cluster $clusterKey: Entry at ${currentTime.toString()}");
          continue;
        }

        // Check time gap from last point
        double timeGap = currentTime
            .difference(lastTimeInCluster!)
            .inMinutes
            .toDouble();

        if (timeGap <= timeThresholdMinutes) {
          // Continuous stay - update last time
          lastTimeInCluster = currentTime;
        } else {
          // Break in stay - calculate previous session and start new
          double sessionStayTime = lastTimeInCluster
              .difference(entryTime!)
              .inMinutes
              .toDouble();
          totalStayTime += sessionStayTime;
          debugPrint(
              "🔴 Session ended: ${sessionStayTime.toStringAsFixed(2)} min");

          entryTime = currentTime;
          lastTimeInCluster = currentTime;
        }
      }

      // Add the last session
      if (entryTime != null && lastTimeInCluster != null) {
        double lastSessionStayTime = lastTimeInCluster
            .difference(entryTime)
            .inMinutes
            .toDouble();
        totalStayTime += lastSessionStayTime;
        debugPrint(
            "🔴 Final session: ${lastSessionStayTime.toStringAsFixed(2)} min");
      }

      stayTimes[clusterKey] = totalStayTime;
      debugPrint("⏱️ Cluster $clusterKey TOTAL stay time: ${totalStayTime
          .toStringAsFixed(2)} minutes");
    });

    return stayTimes;
  }

  Map<String, double> _calculateClusterAreas(
      Map<String, List<LatLng>> clusters) {
    debugPrint("📐 Calculating cluster areas...");

    Map<String, double> clusterAreas = {};

    clusters.forEach((clusterKey, points) {
      if (points.length < 3) {
        clusterAreas[clusterKey] = 0.0;
        return;
      }

      double area = _calculatePolygonArea(points);
      clusterAreas[clusterKey] = area;
      debugPrint(
          "📐 Cluster $clusterKey area: ${area.toStringAsFixed(6)} sq km");
    });

    return clusterAreas;
  }

  double _calculatePolygonArea(List<LatLng> points) {
    double area = 0.0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      LatLng current = points[i];
      LatLng next = points[(i + 1) % n];

      area +=
      (current.longitude * next.latitude - next.longitude * current.latitude);
    }

    return (area.abs() / 2) * 111.32 * 111.32; // Convert to sq km (approximate)
  }

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
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          if (addressBuffer.isNotEmpty) addressBuffer.write(', ');
          addressBuffer.write(place.subAdministrativeArea!);
        }

        // State/Province
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
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
          return 'Near ${point.latitude.toStringAsFixed(4)}, ${point.longitude
              .toStringAsFixed(4)}';
        }

        debugPrint("📍 Comprehensive Address: $fullAddress");
        return fullAddress;
      }
    } catch (e) {
      debugPrint("❌ Error getting comprehensive address: $e");
      return 'Near ${point.latitude.toStringAsFixed(4)}, ${point.longitude
          .toStringAsFixed(4)}';
    }

    return 'Address Not Available';
  }

  LatLng _parseClusterKey(String key) {
    debugPrint("🔧 Parsing cluster key: $key");
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

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

  // ----------------------
  // Central Points Management
  // ----------------------

  Future<void> fetchAllCentralPoints() async {
    try {
      var points = await centralPointsRepo.getCentralPoints();
      allCentralPoints.value = points;
      debugPrint("📥 Fetched ${points.length} central points");
    } catch (e) {
      debugPrint("❌ Error fetching central points: $e");
    }
  }

  Future<void> syncCentralPointsToAPI() async {
    try {
      debugPrint("🟨 Manual sync started...");
      await centralPointsRepo.postCentralPointsToAPI();
      await fetchAllCentralPoints();
      debugPrint("✅ Manual sync completed");
    } catch (e) {
      debugPrint("❌ Error in manual sync: $e");
    }
  }

  Future<int> getUnpostedCentralPointsCount() async {
    var unposted = await centralPointsRepo.getUnPostedCentralPoints();
    return unposted.length;
  }

  // ----------------------
  // Counter Logic
  // ----------------------

  Future<void> _initializeClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String currentMonth = DateFormat('MMM').format(DateTime.now());
    String currentDay = DateFormat('dd').format(DateTime.now());

    String lastProcessedDay = prefs.getString('lastClusterDay') ?? '';
    String lastProcessedMonth = prefs.getString('lastClusterMonth') ?? '';

    if (lastProcessedDay != currentDay || lastProcessedMonth != currentMonth) {
      clusterPointSerialCounter = 1;
      await prefs.setInt('clusterPointSerialCounter', 1);
      await prefs.setString('lastClusterDay', currentDay);
      await prefs.setString('lastClusterMonth', currentMonth);
      debugPrint("🔄 Cluster counter reset to 1 for new day/month");
    } else {
      clusterPointSerialCounter =
          prefs.getInt('clusterPointSerialCounter') ?? 1;
    }

    debugPrint("🔢 Initialized cluster counter: $clusterPointSerialCounter");
  }

  Future<void> _saveClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clusterPointSerialCounter', clusterPointSerialCounter);
    debugPrint("💾 Saved cluster counter: $clusterPointSerialCounter");
  }

  String _generateClusterPointId(String user_id) {
    final now = DateTime.now();
    String day = DateFormat('dd').format(now);
    String month = DateFormat('MMM').format(now);

    String uniqueId = "CD-$user_id-$day-$month-${clusterPointSerialCounter
        .toString().padLeft(3, '0')}";

    debugPrint("🆕 Generated Cluster ID: $uniqueId");
    return uniqueId;
  }

  Future<String> getNextClusterPointId(String user_id) async {
    await _initializeClusterCounter();

    String newId = _generateClusterPointId(user_id);

    clusterPointSerialCounter++;
    await _saveClusterCounter();

    return newId;
  }

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

  Future<void> resetClusterCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clusterPointSerialCounter = 1;
    await prefs.setInt('clusterPointSerialCounter', 1);
    await prefs.remove('lastClusterDay');
    await prefs.remove('lastClusterMonth');
    debugPrint("🔄 Cluster counter manually reset to 1");
  }

  // ----------------------
  // Utility Methods
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
    double distanceInMeters = Geolocator.distanceBetween(
        lat1, lon1, lat2, lon2);
    return (distanceInMeters / 1000); // Distance in kilometers
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

  // Set user data
  void setUserData(String userId, String name) {
    user_id = userId;
    userName = name;
  }

  // Central point processing mein 50m rule implement karein
  Future<void> processGPXAndStoreCentralPointWith50mRule() async {
    try {
      // ✅ Check if today's data already processed
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

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      debugPrint("🟦 Starting enhanced GPX processing with 50m rule...");

      // 1. Extract coordinates
      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(
          gpxFilePath);
      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates found in GPX file");
        return;
      }

      debugPrint("📍 Extracted ${coordinates.length} coordinates");

      // 2. Calculate overall central point
      LatLng overallCenter = gpxService.calculateCentralPoint(coordinates);
      centralPoint.value = overallCenter;

      debugPrint(
          "🎯 Overall Central Point: ${overallCenter.latitude}, ${overallCenter
              .longitude}");

      // 3. Create clusters with 50m rule
      var clusters = gpxService.clusterCoordinatesWith50mRule(
          coordinates, clusterRadiusMeters: 50.0);
      var centers = gpxService.calculateClusterCenters(clusters);
      clusterCenters.value = centers;

      debugPrint("🗂️ Total Clusters Created with 50m rule: ${centers.length}");

      // Debug: Print cluster distances
      _debugClusterDistances(centers);

      // 4. Enhanced storage with new fields
      await storeCentralPointsToAPI(
          overallCenter,
          centers,
          clusters,
          coordinates.length,
          allPoints
      );

      debugPrint(
          "✅ Enhanced GPX processing with 50m rule completed successfully");
    } catch (e) {
      debugPrint("❌ Error processing GPX: $e");
    }
  }

// Helper method to debug cluster distances
  void _debugClusterDistances(Map<String, LatLng> centers) {
    debugPrint("📏 Cluster Distance Analysis:");
    List<String> keys = centers.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      for (int j = i + 1; j < keys.length; j++) {
        LatLng center1 = centers[keys[i]]!;
        LatLng center2 = centers[keys[j]]!;

        double distance = gpxService.calculateHaversineDistanceInMeters(
            center1, center2);
        debugPrint(
            "   Cluster ${i + 1} ↔ Cluster ${j + 1}: ${distance.toStringAsFixed(
                2)} meters");

        if (distance < 50) {
          debugPrint(
              "   ⚠️ WARNING: Clusters are within 50m! Might need merging");
        }
      }
    }
  }

// New method for incremental clustering (real-time)
  Future<Map<String, LatLng>> processIncrementalClustering({
    required LatLng newPoint,
    required Map<String, LatLng> existingClusters,
    double clusterRadiusMeters = 50.0,
  }) async {

  debugPrint("🔄 Processing incremental clustering for new point");
  debugPrint("   New point: ${newPoint.latitude}, ${newPoint.longitude}");
  debugPrint("   Existing clusters: ${existingClusters.length}");

  bool addedToExisting = false;
  String targetClusterKey = "";

  // Check if new point is within 50m of any existing cluster center
  for (var entry in existingClusters.entries) {
  String clusterKey = entry.key;
  LatLng clusterCenter = entry.value;

  double distance = gpxService.calculateHaversineDistanceInMeters(newPoint, clusterCenter);

  debugPrint("   📏 Distance from cluster '$clusterKey': ${distance.toStringAsFixed(2)}m");

  if (distance <= clusterRadiusMeters) {
  debugPrint("   ✅ Point is within ${clusterRadiusMeters}m - belongs to existing cluster");
  targetClusterKey = clusterKey;
  addedToExisting = true;
  break;
  }
  }

  if (!addedToExisting) {
  // Create new cluster
  String newClusterKey = "${newPoint.latitude},${newPoint.longitude}";
  debugPrint("   🆕 Creating NEW cluster (outside ${clusterRadiusMeters}m radius)");
  existingClusters[newClusterKey] = newPoint;

  // Get address for new cluster
  String address = await _getAddressFromLatLng(newPoint);
  debugPrint("   📍 New cluster address: $address");
  }

  return existingClusters;
  }


}