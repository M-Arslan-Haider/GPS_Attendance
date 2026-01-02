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
import '../GPX/intelligent_cluster_detector.dart';

class CentralPointViewModel extends GetxController {
  final CentralPointsRepository centralPointsRepo = CentralPointsRepository();
  final GPXCoordinateService gpxService = GPXCoordinateService();
  final IntelligentClusterDetector clusterDetector = IntelligentClusterDetector();

  var allCentralPoints = <CentralPointsModel>[].obs;
  var clusterCenters = <String, LatLng>{}.obs;
  var centralPoint = LatLng(0.0, 0.0).obs;
  var isDailyProcessingComplete = false.obs;
  var lastProcessedDate = ''.obs;

  // REAL-TIME cluster monitoring
  var observedAreas = <String, dynamic>{}.obs;
  var pendingClusters = <String, dynamic>{}.obs;

  int clusterPointSerialCounter = 1;
  String user_id = '';
  String userName = '';

  // Cluster distance FIXED at 50 meters
  final double clusterDistanceMeters = 50.0;

  @override
  void onInit() {
    super.onInit();
    fetchAllCentralPoints();
    _initializeDailyProcessing();
    _initializeClusterCounter();
  }

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

  // ENHANCED: Process GPX with intelligent clustering
  Future<void> processGPXAndStoreCentralPoint() async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var existingPoints = await centralPointsRepo.getCentralPoints();
      var todayPoints = existingPoints.where((point) =>
      point.processingDate == today && point.userId == user_id).toList();

      if (todayPoints.isNotEmpty) {
        debugPrint("⚠️ Central points already exist for today, deleting old ones...");

        for (var oldPoint in todayPoints) {
          if (oldPoint.centralPointId != null) {
            await centralPointsRepo.deleteCentralPoint(oldPoint.centralPointId!);
          }
        }
      }

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      debugPrint("""
      🟦🟦🟦 STARTING INTELLIGENT CLUSTER PROCESSING 🟦🟦🟦
      📏 Using STRICT ${clusterDistanceMeters.toStringAsFixed(0)} METER clustering
      🔍 Waiting for repeated movement confirmation
      """);

      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);

      if (allPoints.isEmpty) {
        debugPrint("❌ No points found in GPX file");
        Get.snackbar(
          'No Data',
          'No points found in GPX file',
          backgroundColor: Colors.orange,
        );
        return;
      }

      debugPrint("📍 Extracted ${allPoints.length} points with timestamps");

      List<LatLng> allCoordinates = [];
      int newClustersCreated = 0;

      for (int i = 0; i < allPoints.length; i++) {
        var point = allPoints[i];
        if (point.lat != null && point.lon != null && point.time != null) {
          LatLng latLng = LatLng(point.lat!.toDouble(), point.lon!.toDouble());
          allCoordinates.add(latLng);

          var result = await clusterDetector.processPointWithTime(latLng, point.time!);

          if (result['is_new_cluster'] == true) {
            newClustersCreated++;
            debugPrint("🎯 NEW CLUSTER #$newClustersCreated CREATED!");
            debugPrint("   Cluster Key: ${result['cluster_key']}");
            debugPrint("   Points: ${result['total_points']}");
            debugPrint("   Time Observed: ${result['time_observed_minutes']} minutes");
          }

          observedAreas.value = Map.from(clusterDetector.getObservedAreas()
              .map((key, area) => MapEntry(key, {
            'points': area.points.length,
            'time_minutes': area.timeRange.inMinutes,
            'center': {'lat': area.center.latitude, 'lng': area.center.longitude}
          })));
        }

        if (i % 100 == 0 && i > 0) {
          debugPrint("📊 Progress: $i/${allPoints.length} points processed");
        }
      }

      var finalClusters = clusterDetector.getConfirmedClusters();
      var finalCenters = clusterDetector.getClusterCenters();

      LatLng overallCenter = allCoordinates.isNotEmpty ?
      gpxService.calculateCentralPoint(allCoordinates) : LatLng(0.0, 0.0);
      centralPoint.value = overallCenter;

      clusterCenters.value = finalCenters;

      debugPrint("""
      ✅✅✅ INTELLIGENT PROCESSING COMPLETE ✅✅✅
      Total Points Processed: ${allCoordinates.length}
      Total Clusters Created: ${finalClusters.length}
      New Clusters Today: $newClustersCreated
      Cluster Radius: ${clusterDistanceMeters}m
      Overall Center: ${overallCenter.latitude}, ${overallCenter.longitude}
      """);

      var stats = clusterDetector.getStatistics();
      debugPrint("📊 FINAL STATISTICS:");
      debugPrint("   - Confirmed Clusters: ${stats['total_clusters']}");
      debugPrint("   - Observed Areas: ${stats['total_observed_areas']}");
      debugPrint("   - Processed Points: ${stats['total_processed_points']}");

      for (var cluster in stats['clusters']) {
        debugPrint("   🔸 Cluster ${cluster['key']}: ${cluster['points']} points");
      }

      await storeCentralPointsToAPI(
          overallCenter,
          finalCenters,
          finalClusters,
          allCoordinates.length,
          allPoints
      );

      debugPrint("✅ Intelligent cluster processing completed successfully");

    } catch (e) {
      debugPrint("❌ Error processing GPX: $e");
      Get.snackbar(
        'Error',
        'Failed to process GPX: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // REAL-TIME: Process single point
  Future<Map<String, dynamic>> processSinglePoint(LatLng point, DateTime timestamp) async {
    try {
      debugPrint("📍 Processing real-time point at ${timestamp.toString()}");

      var result = await clusterDetector.processPointWithTime(point, timestamp);

      observedAreas.value = Map.from(clusterDetector.getObservedAreas()
          .map((key, area) => MapEntry(key, {
        'points': area.points.length,
        'time_minutes': area.timeRange.inMinutes,
        'center': {'lat': area.center.latitude, 'lng': area.center.longitude}
      })));

      if (result['is_new_cluster'] == true) {
        debugPrint("🎯 REAL-TIME: New cluster created!");

        await _storeSingleCluster(
            result['cluster_key']!,
            result['center']!,
            clusterDetector.getConfirmedClusters()[result['cluster_key']]!,
            timestamp
        );
      }

      return result;
    } catch (e) {
      debugPrint("❌ Error processing single point: $e");
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // Store single cluster immediately
  Future<void> _storeSingleCluster(
      String clusterKey,
      LatLng center,
      List<LatLng> clusterPoints,
      DateTime timestamp
      ) async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // PURE ADDRESS get karein (intelligent info ke bina)
      String pureAddress = await _getExtremelyDetailedAddressFromLatLng(center);

      // Sirf first line ya basic address rakhein
      String basicAddress = pureAddress.split('\n').first;

      String uniqueClusterId = centralPointsRepo.generateCentralPointId();

      double stayTime = await _calculateClusterStayTime(clusterPoints, timestamp);
      double area = _calculatePolygonArea(clusterPoints);

      debugPrint("""
  🔥🔥🔥 STORING SINGLE CLUSTER 🔥🔥🔥
     ID: $uniqueClusterId
     Center: ${center.latitude}, ${center.longitude}
     Points: ${clusterPoints.length}
     Stay Time: ${stayTime.toStringAsFixed(2)} min
     Area: ${area.toStringAsFixed(6)} sq km
     Address: $basicAddress
  """);

      CentralPointsModel clusterRecord = CentralPointsModel.createIndividualCluster(
        mainCentralPointId: "REALTIME-${DateFormat('yyyyMMdd').format(DateTime.now())}-$user_id",
        userId: user_id,
        userName: userName,
        processingDate: today,
        overallCenterLat: center.latitude,
        overallCenterLng: center.longitude,
        totalClusters: 1,
        totalCoordinates: clusterPoints.length,
        clusterId: uniqueClusterId,
        clusterAddress: basicAddress, // Sirf basic address pass karein
        clusterLat: center.latitude,
        clusterLng: center.longitude,
        clusterPointsCount: clusterPoints.length,
        clusterStayTime: stayTime,
        clusterArea: area,
        clusterDistance: clusterDistanceMeters,
      );

      await centralPointsRepo.addCentralPoint(clusterRecord);

      bool apiSuccess = await centralPointsRepo.postCentralPointToAPI(clusterRecord);

      if (apiSuccess) {
        debugPrint("✅✅✅ Single cluster stored and posted to API!");
        debugPrint("📤 Address sent: $basicAddress");
        await fetchAllCentralPoints();
      }

    } catch (e) {
      debugPrint("❌ Error storing single cluster: $e");
    }
  }

  Future<double> _calculateClusterStayTime(List<LatLng> points, DateTime referenceTime) async {
    double estimatedTime = points.length * 0.5;
    return estimatedTime.clamp(0.0, 120.0);
  }

  // MAIN METHOD: Store each cluster as separate record
  Future<void> storeCentralPointsToAPI(
      LatLng overallCenter,
      Map<String, LatLng> clusterCenters,
      Map<String, List<LatLng>> originalClusters,
      int totalCoordinates,
      List<Wpt> allPoints,
      ) async {
    try {
      debugPrint("🚀 START: Storing confirmed clusters...");
      debugPrint("📏 Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters");
      debugPrint("🔍 Clusters to store: ${clusterCenters.length}");

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var existingPoints = await centralPointsRepo.getCentralPoints();
      var todayPoints = existingPoints.where((point) =>
      point.processingDate == today && point.userId == user_id).toList();

      if (todayPoints.isNotEmpty) {
        debugPrint("🗑️ Deleting ${todayPoints.length} old entries");
        for (var oldPoint in todayPoints) {
          if (oldPoint.centralPointId != null) {
            await centralPointsRepo.deleteCentralPoint(oldPoint.centralPointId!);
          }
        }
      }

      debugPrint("""
      🔬 FINAL CLUSTER ANALYSIS:
         Total Points: $totalCoordinates
         Confirmed Clusters: ${clusterCenters.length}
         Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters
         Intelligent Detection: ENABLED
      """);

      var stayTimes = await _calculateClusterStayTimes(allPoints, originalClusters);
      var clusterAreas = _calculateClusterAreas(originalClusters);

      if (clusterCenters.isEmpty) {
        debugPrint("⚠️ WARNING: No confirmed clusters found!");
        Get.snackbar(
          'No Clusters',
          'No confirmed clusters found within ${clusterDistanceMeters.toStringAsFixed(0)} meters distance',
          backgroundColor: Colors.orange,
        );
        return;
      }

      String mainProcessingId = "INTELLIGENT-${DateFormat('yyyyMMdd').format(DateTime.now())}-$user_id";

      List<CentralPointsModel> allClusterRecords = [];
      int clusterNumber = 1;

      for (var clusterKey in clusterCenters.keys) {
        LatLng center = clusterCenters[clusterKey]!;
        List<LatLng> clusterPoints = originalClusters[clusterKey] ?? [];
        int pointsCount = clusterPoints.length;
        double stayTime = stayTimes[clusterKey] ?? 0.0;
        double area = clusterAreas[clusterKey] ?? 0.0;

        String clusterAddress = await _getExtremelyDetailedAddressFromLatLng(center);

        String uniqueClusterId = centralPointsRepo.generateCentralPointId();

        debugPrint("""
        🔥🔥🔥 PROCESSING CONFIRMED CLUSTER ${clusterNumber} 🔥🔥🔥
           ✅ Unique Cluster ID: $uniqueClusterId
           ✅ Main Processing ID: $mainProcessingId
           ✅ Points in Cluster: $pointsCount
           ✅ Stay Time: ${stayTime.toStringAsFixed(2)} min
           ✅ Area: ${area.toStringAsFixed(6)} sq km
           ✅ Center: ${center.latitude}, ${center.longitude}
           ✅ Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters
           ✅ Confirmed via Repeated Movement: YES
        """);

        CentralPointsModel clusterRecord = CentralPointsModel.createIndividualCluster(
          mainCentralPointId: mainProcessingId,
          userId: user_id,
          userName: userName,
          processingDate: today,
          overallCenterLat: overallCenter.latitude,
          overallCenterLng: overallCenter.longitude,
          totalClusters: clusterCenters.length,
          totalCoordinates: totalCoordinates,
          clusterId: uniqueClusterId,
          clusterAddress: clusterAddress,
          clusterLat: center.latitude,
          clusterLng: center.longitude,
          clusterPointsCount: pointsCount,
          clusterStayTime: stayTime,
          clusterArea: area,
          clusterDistance: clusterDistanceMeters,
        );

        allClusterRecords.add(clusterRecord);
        clusterNumber++;
      }

      await centralPointsRepo.saveIndividualClusters(allClusterRecords);
      debugPrint("💾 Saved ${allClusterRecords.length} confirmed cluster records");

      int successfullyPosted = 0;
      for (int i = 0; i < allClusterRecords.length; i++) {
        var cluster = allClusterRecords[i];
        debugPrint("🔄 Posting Cluster ${i + 1}/${allClusterRecords.length} to API...");
        bool apiSuccess = await centralPointsRepo.postCentralPointToAPI(cluster);

        if (apiSuccess) {
          successfullyPosted++;
          debugPrint("✅✅✅ SUCCESS: Cluster ${i + 1} sent to backend!");
        } else {
          debugPrint("⚠️ WARNING: Cluster ${i + 1} failed to post");
        }

        if (i < allClusterRecords.length - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      debugPrint("""
      🎉🎉🎉 PROCESSING COMPLETE! 🎉🎉🎉
      Total Confirmed Clusters: ${clusterCenters.length}
      Successfully Posted: $successfullyPosted
      Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters
      Main Processing ID: $mainProcessingId
      Intelligence: ENABLED (repeated movement detection)
      """);

      await fetchAllCentralPoints();

      Get.snackbar(
        'Success',
        'Created ${clusterCenters.length} confirmed clusters with ${clusterDistanceMeters.toStringAsFixed(0)}m radius',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      clusterDetector.clear();
      observedAreas.clear();

    } catch (e) {
      debugPrint("❌❌❌ ERROR in storeCentralPointsToAPI: $e ❌❌❌");
      Get.snackbar(
        'Error',
        'Failed to process clusters: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get cluster detection statistics
  Map<String, dynamic> getClusterDetectionStats() {
    return clusterDetector.getStatistics();
  }

  // Clear intelligent detector
  void clearIntelligentDetector() {
    clusterDetector.clear();
    observedAreas.clear();
    debugPrint("🧹 Intelligent detector cleared");
  }

  // Test intelligent clustering with sample data
  Future<void> testIntelligentClustering() async {
    try {
      debugPrint("🧪 TESTING INTELLIGENT CLUSTERING...");

      List<Map<String, dynamic>> testPoints = [
        // Area 1: Repeated movement in first 50m radius
        {'lat': 33.6844, 'lng': 73.0479, 'time': DateTime.now().subtract(Duration(minutes: 30))},
        {'lat': 33.6845, 'lng': 73.0480, 'time': DateTime.now().subtract(Duration(minutes: 28))},
        {'lat': 33.6843, 'lng': 73.0478, 'time': DateTime.now().subtract(Duration(minutes: 26))},
        {'lat': 33.6846, 'lng': 73.0481, 'time': DateTime.now().subtract(Duration(minutes: 24))},
        {'lat': 33.6844, 'lng': 73.0479, 'time': DateTime.now().subtract(Duration(minutes: 22))},

        // Area 2: Single point (should not create cluster)
        {'lat': 33.6850, 'lng': 73.0485, 'time': DateTime.now().subtract(Duration(minutes: 20))},

        // Area 3: Repeated movement in second 50m radius
        {'lat': 33.6900, 'lng': 73.0500, 'time': DateTime.now().subtract(Duration(minutes: 18))},
        {'lat': 33.6901, 'lng': 73.0501, 'time': DateTime.now().subtract(Duration(minutes: 16))},
        {'lat': 33.6899, 'lng': 73.0499, 'time': DateTime.now().subtract(Duration(minutes: 14))},
        {'lat': 33.6902, 'lng': 73.0502, 'time': DateTime.now().subtract(Duration(minutes: 12))},
      ];

      clearIntelligentDetector();

      for (var point in testPoints) {
        var result = await processSinglePoint(
            LatLng(point['lat'], point['lng']),
            point['time']
        );

        await Future.delayed(Duration(milliseconds: 100));
      }

      var stats = getClusterDetectionStats();
      debugPrint("""
      🧪 TEST RESULTS:
      - Expected Clusters: 2 (areas with repeated movement)
      - Actual Clusters: ${stats['total_clusters']}
      - Cluster Radius: ${stats['cluster_radius_meters']}m
      - Minimum Points: ${stats['min_points_for_cluster']}
      - Minimum Time: ${stats['min_time_minutes']} minutes
      """);

    } catch (e) {
      debugPrint("❌ Error testing intelligent clustering: $e");
    }
  }

  Future<String> _getExtremelyDetailedAddressFromLatLng(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add("Street: ${place.street!}");

        if (place.name != null && place.name!.isNotEmpty && place.name != place.street)
          addressParts.add("Place: ${place.name!}");

        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          addressParts.add("Sublocality: ${place.subLocality!}");

        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add("Locality: ${place.locality!}");

        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty)
          addressParts.add("SubAdmin: ${place.subAdministrativeArea!}");

        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)
          addressParts.add("Admin Area: ${place.administrativeArea!}");

        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          addressParts.add("Postal Code: ${place.postalCode!}");

        if (place.country != null && place.country!.isNotEmpty)
          addressParts.add("Country: ${place.country!}");

        if (place.isoCountryCode != null && place.isoCountryCode!.isNotEmpty)
          addressParts.add("Country Code: ${place.isoCountryCode!}");

        addressParts.add("Coordinates: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}");

        addressParts.add("Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters");

        String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        addressParts.add("Processed: $currentTime");

        addressParts.add("Note: ${clusterDistanceMeters.toStringAsFixed(0)}m cluster distance");

        String fullAddress = addressParts.join('\n');

        debugPrint("📍 EXTREMELY DETAILED ADDRESS FOR CLUSTER:");
        debugPrint(fullAddress);

        return fullAddress;
      }
    } catch (e) {
      debugPrint("❌ Error getting extremely detailed address: $e");
    }

    String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    return """Coordinates: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}
Cluster Radius: ${clusterDistanceMeters.toStringAsFixed(0)} meters
Processed: $currentTime
Note: ${clusterDistanceMeters.toStringAsFixed(0)}m cluster distance
Location details not available""";
  }

  Future<Map<String, double>> _calculateClusterStayTimes(
      List<Wpt> points,
      Map<String, List<LatLng>> clusters,
      {double timeThresholdMinutes = 1.0}
      ) async {
    debugPrint("⏱️ Calculating ACTUAL cluster stay times...");

    Map<String, double> stayTimes = {};
    Map<String, List<DateTime>> clusterTimestamps = {};

    for (var point in points) {
      if (point.lat == null || point.lon == null || point.time == null) continue;

      LatLng pointLatLng = LatLng(point.lat!.toDouble(), point.lon!.toDouble());

      for (var clusterKey in clusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distanceMeters = _calculateHaversineDistanceMeters(pointLatLng, clusterCenter);

        if (distanceMeters <= clusterDistanceMeters) {
          if (!clusterTimestamps.containsKey(clusterKey)) {
            clusterTimestamps[clusterKey] = [];
          }
          clusterTimestamps[clusterKey]!.add(point.time!);
          break;
        }
      }
    }

    clusterTimestamps.forEach((clusterKey, timestamps) {
      if (timestamps.length < 2) {
        stayTimes[clusterKey] = 0.0;
        debugPrint("⏱️ Cluster $clusterKey: Only 1 point, stay time = 0");
        return;
      }

      timestamps.sort();

      double totalStayTime = 0.0;
      DateTime? entryTime;
      DateTime? lastTimeInCluster;

      for (int i = 0; i < timestamps.length; i++) {
        DateTime currentTime = timestamps[i];

        if (entryTime == null) {
          entryTime = currentTime;
          lastTimeInCluster = currentTime;
          debugPrint("🟢 Cluster $clusterKey: Entry at ${DateFormat('HH:mm:ss').format(currentTime)}");
          continue;
        }

        double timeGap = currentTime.difference(lastTimeInCluster!).inMinutes.toDouble();

        if (timeGap <= timeThresholdMinutes) {
          lastTimeInCluster = currentTime;
        } else {
          double sessionStayTime = lastTimeInCluster.difference(entryTime!).inMinutes.toDouble();
          totalStayTime += sessionStayTime;
          debugPrint("🔴 Session ended: ${sessionStayTime.toStringAsFixed(2)} min");

          entryTime = currentTime;
          lastTimeInCluster = currentTime;
        }
      }

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

  double _calculatePolygonArea(List<LatLng> points) {
    double area = 0.0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      LatLng current = points[i];
      LatLng next = points[(i + 1) % n];

      area += (current.longitude * next.latitude - next.longitude * current.latitude);
    }

    return (area.abs() / 2) * 111.32 * 111.32;
  }

  LatLng _parseClusterKey(String key) {
    debugPrint("🔧 Parsing cluster key: $key");
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  double _calculateHaversineDistanceMeters(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000.0;

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
      clusterPointSerialCounter = prefs.getInt('clusterPointSerialCounter') ?? 1;
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

    String uniqueId = "CD-$user_id-$day-$month-${clusterPointSerialCounter.toString().padLeft(3, '0')}";

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
  - Cluster Distance: ${clusterDistanceMeters.toStringAsFixed(0)} meters
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
    return (distanceInMeters / 1000);
  }

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

  bool isCentralPointsFeatureEnabled() {
    return centralPointsRepo != null && gpxService != null;
  }

  void setUserData(String userId, String name) {
    user_id = userId;
    userName = name;
    debugPrint("✅ User data set: $userId, $name");
  }

  Future<void> testAPIConnection() async {
    debugPrint("""
    🔬🔬🔬 API CONNECTION TEST WITH CLUSTER INFO 🔬🔬🔬
    Cluster Distance: ${clusterDistanceMeters.toStringAsFixed(0)} meters
    """);
    await centralPointsRepo.testAPIConnection();
  }

  Future<void> testClusteringWithDifferentDistances() async {
    try {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final downloadDirectory = await getDownloadsDirectory();
      final gpxFilePath = '${downloadDirectory!.path}/track$date.gpx';

      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates for testing");
        return;
      }

      debugPrint("🧪 TESTING CLUSTERING WITH DIFFERENT DISTANCES:");
      debugPrint("📊 Total coordinates: ${coordinates.length}");

      List<double> testDistances = [25.0, 50.0, 100.0, 200.0];

      for (var distance in testDistances) {
        var clusters = gpxService.clusterCoordinates(coordinates, clusterDistanceMeters: distance);
        debugPrint("   📏 ${distance.toStringAsFixed(0)}m -> ${clusters.length} clusters");
      }

    } catch (e) {
      debugPrint("❌ Error testing clustering: $e");
    }
  }

  Future<void> process24HoursGPXData() async {
    try {
      final gpxFilePath = await getCurrentGPXFilePath();
      debugPrint("🕐 Processing 24 hours GPX data from: $gpxFilePath");

      List<LatLng> coordinates = await gpxService.extractCoordinatesFromGPX(gpxFilePath);

      if (coordinates.isEmpty) {
        debugPrint("❌ No coordinates found in 24 hours data");
        return;
      }

      debugPrint("📍 Total coordinates in 24 hours: ${coordinates.length}");

      List<Wpt> allPoints = await _extractAllPointsWithTime(gpxFilePath);
      LatLng overallCenter = gpxService.calculateCentralPoint(coordinates);

      var clusters = gpxService.clusterCoordinates(coordinates, clusterDistanceMeters: clusterDistanceMeters);
      var centers = gpxService.calculateClusterCenters(clusters);

      debugPrint("🗂 24 Hours Summary:");
      debugPrint("   - Total Coordinates: ${coordinates.length}");
      debugPrint("   - Total Clusters: ${centers.length}");
      debugPrint("   - Overall Center: ${overallCenter.latitude}, ${overallCenter.longitude}");
      debugPrint("   - Cluster Distance: ${clusterDistanceMeters.toStringAsFixed(0)} meters");

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

  String getDailyGPXFileName() {
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return 'track$date.gpx';
  }

  Future<String> getCurrentGPXFilePath() async {
    final downloadDirectory = await getDownloadsDirectory();
    return '${downloadDirectory!.path}/${getDailyGPXFileName()}';
  }

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
}