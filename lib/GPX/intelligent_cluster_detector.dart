// import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
//
// /// IntelligentClusterDetector - Single cluster per 100m area, REAL time
// /// NO NEW FIELDS - Uses only existing data structure
// class IntelligentClusterDetector {
//   // ✅ FIX: Fixed cluster radius in meters (100 m)
//   final double clusterRadiusMeters = 100.0;
//
//   // ✅ FIX: Minimum unique points required
//   final int minPointsForCluster = 3;
//
//   // ✅ FIX: Minimum time in minutes (1 MINUTE) - STRICT ENFORCEMENT
//   final double minTimeInAreaMinutes = 1.0;
//
//   // Core data structures
//   final Map<String, List<ProcessedPoint>> _confirmedClusters = {};
//   final Map<String, LatLng> _clusterCenters = {};
//   final Map<String, AreaObservation> _observedAreas = {};
//
//   // Track processed points to avoid duplicates
//   final Map<String, DateTime> _processedPointMap = {};
//
//   // Track processed centers (100-meter rule)
//   final Set<String> _processedCenters = {};
//
//   // ✅ FIX: Track cluster attempts to prevent duplicates
//   final Map<String, int> _clusterAttempts = {};
//
//   IntelligentClusterDetector();
//
//   /// Process point with timestamp
//   Future<Map<String, dynamic>> processPointWithTime(LatLng point, DateTime timestamp) async {
//     debugPrint("🔍 [DETECTOR] Processing point at ${DateFormat('HH:mm:ss').format(timestamp)}");
//
//     // Validate timestamp
//     DateTime now = DateTime.now();
//     if (timestamp.isAfter(now)) {
//       timestamp = now;
//       debugPrint("⚠️ Corrected future timestamp to current time");
//     }
//
//     // Prevent duplicate points within 5 seconds
//     String pointKey = _generatePointKey(point);
//     if (_processedPointMap.containsKey(pointKey)) {
//       DateTime lastTime = _processedPointMap[pointKey]!;
//       if (timestamp.difference(lastTime).inSeconds.abs() < 5) {
//         return {'status': 'duplicate_skipped', 'is_new_cluster': false};
//       }
//     }
//     _processedPointMap[pointKey] = timestamp;
//
//     ProcessedPoint processed = ProcessedPoint(point, timestamp);
//
//     // Check existing confirmed clusters
//     for (var clusterKey in _confirmedClusters.keys.toList()) {
//       LatLng center = _clusterCenters[clusterKey]!;
//       double distance = _calculateDistanceMeters(point, center);
//
//       if (distance <= clusterRadiusMeters) {
//         // Add to existing cluster
//         _confirmedClusters[clusterKey]!.add(processed);
//         _updateClusterCenter(clusterKey);
//
//         debugPrint("✅ Updated existing cluster: $clusterKey (${_confirmedClusters[clusterKey]!.length} points)");
//
//         return {
//           'status': 'updated_existing',
//           'cluster_key': clusterKey,
//           'is_new_cluster': false,
//           'total_points': _confirmedClusters[clusterKey]!.length,
//         };
//       }
//     }
//
//     // Check observed areas
//     String? matchingAreaKey;
//     AreaObservation? matchingArea;
//
//     for (var areaKey in _observedAreas.keys) {
//       AreaObservation area = _observedAreas[areaKey]!;
//       double distance = _calculateDistanceMeters(point, area.center);
//
//       if (distance <= clusterRadiusMeters) {
//         matchingAreaKey = areaKey;
//         matchingArea = area;
//         break;
//       }
//     }
//
//     if (matchingAreaKey != null && matchingArea != null) {
//       // Add point to observed area
//       matchingArea.addPoint(point, timestamp);
//
//       debugPrint("📝 Added to observed area: $matchingAreaKey");
//       debugPrint("   Points: ${matchingArea.points.length}, Time: ${matchingArea.timeRange.inSeconds}s");
//
//       // Check if should become cluster
//       if (_shouldBecomeCluster(matchingArea)) {
//         return _convertAreaToCluster(matchingAreaKey, matchingArea);
//       }
//
//       return {
//         'status': 'added_to_observed',
//         'area_key': matchingAreaKey,
//         'points_count': matchingArea.points.length,
//         'time_range_seconds': matchingArea.timeRange.inSeconds,
//         'is_new_cluster': false
//       };
//     }
//
//     // Check if point is near any existing area
//     bool nearExistingArea = false;
//     for (var area in _observedAreas.values) {
//       double distance = _calculateDistanceMeters(point, area.center);
//       if (distance <= clusterRadiusMeters * 2) {
//         nearExistingArea = true;
//         break;
//       }
//     }
//
//     if (!nearExistingArea) {
//       // Create new observed area
//       String newAreaKey = "area_${timestamp.millisecondsSinceEpoch}";
//       _observedAreas[newAreaKey] = AreaObservation(
//           center: point,
//           points: [ProcessedPoint(point, timestamp)],
//           firstSeen: timestamp,
//           lastSeen: timestamp
//       );
//
//       debugPrint("🆕 Created new observed area: $newAreaKey");
//
//       return {
//         'status': 'new_area_created',
//         'area_key': newAreaKey,
//         'is_new_cluster': false
//       };
//     }
//
//     return {'status': 'processed_no_match', 'is_new_cluster': false};
//   }
//
//   /// Check if area should become cluster - STRICT ENFORCEMENT 1 MINUTE MINIMUM
//   bool _shouldBecomeCluster(AreaObservation area) {
//     int uniquePoints = _countUniquePoints(area.points);
//     double timeMinutes = area.timeRange.inSeconds / 60.0;
//
//     // Validate time range is realistic
//     DateTime now = DateTime.now();
//     if (area.firstSeen.isAfter(now)) {
//       area.firstSeen = now.subtract(Duration(minutes: 1));
//     }
//     if (area.lastSeen.isAfter(now)) {
//       area.lastSeen = now;
//     }
//     if (area.lastSeen.isBefore(area.firstSeen)) {
//       DateTime temp = area.firstSeen;
//       area.firstSeen = area.lastSeen;
//       area.lastSeen = temp;
//     }
//
//     timeMinutes = area.lastSeen.difference(area.firstSeen).inSeconds / 60.0;
//
//     bool hasEnoughPoints = uniquePoints >= minPointsForCluster;
//     bool hasEnoughTime = timeMinutes >= minTimeInAreaMinutes; // ✅ 1 MINUTE STRICT
//
//     debugPrint("""
// 🔬 Cluster Validation:
//    Points: $uniquePoints/$minPointsForCluster → ${hasEnoughPoints ? '✅' : '❌'}
//    Time: ${timeMinutes.toStringAsFixed(2)}/$minTimeInAreaMinutes min → ${hasEnoughTime ? '✅' : '❌'} ✅ ENFORCING 1 MINUTE
// """);
//
//     // ✅ STRICT: Must have at least 1 minute AND 3 points
//     return hasEnoughPoints && hasEnoughTime;
//   }
//
//   /// Convert area to cluster - ADD TIME VALIDATION AND 100-METER RULE
//   Map<String, dynamic> _convertAreaToCluster(String areaKey, AreaObservation area) {
//     List<ProcessedPoint> points = List.from(area.points);
//     LatLng centroid = _calculateCentroid(points.map((p) => p.point).toList());
//
//     // Generate cluster key
//     String clusterKey = "${centroid.latitude.toStringAsFixed(5)},${centroid.longitude.toStringAsFixed(5)}";
//
//     // ✅ FIX: Check for duplicate attempts
//     if (_clusterAttempts.containsKey(clusterKey) && _clusterAttempts[clusterKey]! > 2) {
//       debugPrint("⚠️ Too many attempts for cluster: $clusterKey");
//       _observedAreas.remove(areaKey);
//       return {
//         'status': 'too_many_attempts',
//         'is_new_cluster': false,
//       };
//     }
//
//     // Check if center already processed (100-meter rule)
//     for (var existingCenterKey in _processedCenters) {
//       var parts = existingCenterKey.split('|');
//       if (parts.length == 2) {
//         double existingLat = double.parse(parts[0]);
//         double existingLng = double.parse(parts[1]);
//
//         double distance = _calculateDistanceMeters(
//             LatLng(existingLat, existingLng),
//             centroid
//         );
//
//         if (distance <= clusterRadiusMeters) {
//           debugPrint("⚠️ Duplicate within 100m detected: ${distance.toStringAsFixed(1)}m");
//           _observedAreas.remove(areaKey);
//           _clusterAttempts[clusterKey] = (_clusterAttempts[clusterKey] ?? 0) + 1;
//           return {
//             'status': 'duplicate_within_100m',
//             'distance_meters': distance,
//             'is_new_cluster': false,
//           };
//         }
//       }
//     }
//
//     // ✅ Check minimum time requirement again
//     double timeMinutes = area.timeRange.inSeconds / 60.0;
//
//     // Validate timestamps
//     DateTime now = DateTime.now();
//     if (area.firstSeen.isAfter(now)) area.firstSeen = now.subtract(Duration(minutes: 1));
//     if (area.lastSeen.isAfter(now)) area.lastSeen = now;
//     if (area.lastSeen.isBefore(area.firstSeen)) {
//       DateTime temp = area.firstSeen;
//       area.firstSeen = area.lastSeen;
//       area.lastSeen = temp;
//     }
//
//     timeMinutes = area.lastSeen.difference(area.firstSeen).inSeconds / 60.0;
//
//     if (timeMinutes < minTimeInAreaMinutes) {
//       debugPrint("⏭️ Area doesn't meet minimum time requirement: ${timeMinutes.toStringAsFixed(2)} min");
//       _observedAreas.remove(areaKey);
//       _clusterAttempts[clusterKey] = (_clusterAttempts[clusterKey] ?? 0) + 1;
//       return {
//         'status': 'insufficient_time',
//         'time_minutes': timeMinutes,
//         'is_new_cluster': false,
//       };
//     }
//
//     // ✅ Check minimum points requirement
//     int uniquePoints = _countUniquePoints(points);
//     if (uniquePoints < minPointsForCluster) {
//       debugPrint("⏭️ Area doesn't meet minimum points requirement: $uniquePoints points");
//       _observedAreas.remove(areaKey);
//       _clusterAttempts[clusterKey] = (_clusterAttempts[clusterKey] ?? 0) + 1;
//       return {
//         'status': 'insufficient_points',
//         'points': uniquePoints,
//         'is_new_cluster': false,
//       };
//     }
//
//     // Ensure unique cluster key
//     int suffix = 1;
//     String finalClusterKey = clusterKey;
//     while (_confirmedClusters.containsKey(finalClusterKey)) {
//       finalClusterKey = "$clusterKey-$suffix";
//       suffix++;
//     }
//
//     // Create new cluster
//     _confirmedClusters[finalClusterKey] = points;
//     _clusterCenters[finalClusterKey] = centroid;
//
//     // Mark center as processed (100-meter rule)
//     String centerKey = "${centroid.latitude.toStringAsFixed(5)}|${centroid.longitude.toStringAsFixed(5)}";
//     _processedCenters.add(centerKey);
//
//     // Remove observed area
//     _observedAreas.remove(areaKey);
//
//     // Clear attempts for this cluster
//     _clusterAttempts.remove(clusterKey);
//
//     // Calculate stats
//     DateTime firstSeen = area.firstSeen;
//     DateTime lastSeen = area.lastSeen;
//     double timeMinutesActual = lastSeen.difference(firstSeen).inSeconds / 60.0;
//
//     // Validate final time
//     if (timeMinutesActual > 120.0) {
//       debugPrint("⚠️ Suspicious final time detected: ${timeMinutesActual.toStringAsFixed(2)} min");
//       timeMinutesActual = uniquePoints * 0.5;
//       timeMinutesActual = timeMinutesActual.clamp(1.0, 30.0);
//       debugPrint("✅ Using validated time: ${timeMinutesActual.toStringAsFixed(2)} min");
//     }
//
//     debugPrint("""
// 🎉🎉🎉 NEW CLUSTER CREATED: $finalClusterKey
//    Unique Points: $uniquePoints (≥$minPointsForCluster required)
//    Total Points: ${points.length}
//    ✅ Time Range: ${timeMinutesActual.toStringAsFixed(2)} minutes (≥$minTimeInAreaMinutes min required)
//    Center: ${centroid.latitude.toStringAsFixed(6)}, ${centroid.longitude.toStringAsFixed(6)}
//    First Seen: ${DateFormat('HH:mm:ss').format(firstSeen)}
//    Last Seen: ${DateFormat('HH:mm:ss').format(lastSeen)}
//    Cluster Radius: ${clusterRadiusMeters}m (100-METER RULE)
// """);
//
//     return {
//       'status': 'new_cluster_created',
//       'cluster_key': finalClusterKey,
//       'center': centroid,
//       'total_points': points.length,
//       'unique_points': uniquePoints,
//       'time_observed_minutes': timeMinutesActual,
//       'first_seen': firstSeen,
//       'last_seen': lastSeen,
//       'is_new_cluster': true,
//     };
//   }
//
//   // ========== PUBLIC GETTER METHODS ==========
//
//   /// Get confirmed clusters (LatLng lists)
//   Map<String, List<LatLng>> getConfirmedClusters() {
//     final Map<String, List<LatLng>> result = {};
//     _confirmedClusters.forEach((key, points) {
//       result[key] = points.map((p) => p.point).toList();
//     });
//     return result;
//   }
//
//   /// Get confirmed clusters with timestamps
//   Map<String, List<ProcessedPoint>> getConfirmedClustersWithPoints() {
//     return Map.from(_confirmedClusters);
//   }
//
//   /// Get cluster centers
//   Map<String, LatLng> getClusterCenters() {
//     return Map.from(_clusterCenters);
//   }
//
//   /// Get observed areas
//   Map<String, AreaObservation> getObservedAreas() {
//     return Map.from(_observedAreas);
//   }
//
//   /// Get cluster stay time in minutes
//   double getClusterStayTime(String clusterKey) {
//     if (!_confirmedClusters.containsKey(clusterKey) || _confirmedClusters[clusterKey]!.isEmpty) {
//       return 0.0;
//     }
//
//     var points = _confirmedClusters[clusterKey]!;
//     DateTime earliest = points.first.timestamp;
//     DateTime latest = points.first.timestamp;
//
//     for (var p in points) {
//       if (p.timestamp.isBefore(earliest)) earliest = p.timestamp;
//       if (p.timestamp.isAfter(latest)) latest = p.timestamp;
//     }
//
//     // Validate timestamps
//     DateTime now = DateTime.now();
//     if (earliest.isAfter(now)) earliest = now.subtract(Duration(minutes: 1));
//     if (latest.isAfter(now)) latest = now;
//     if (latest.isBefore(earliest)) {
//       DateTime temp = earliest;
//       earliest = latest;
//       latest = temp;
//     }
//
//     double stayTime = latest.difference(earliest).inSeconds / 60.0;
//
//     // ✅ FIX: Detect suspicious times
//     if (stayTime > 120.0) { // More than 2 hours is suspicious
//       debugPrint("⚠️ Suspicious stay time detected for $clusterKey: ${stayTime.toStringAsFixed(2)} min");
//       // Use realistic calculation
//       double realisticTime = points.length * 0.5;
//       realisticTime = realisticTime.clamp(0.1, 30.0);
//       stayTime = realisticTime;
//       debugPrint("✅ Using realistic time: ${stayTime.toStringAsFixed(2)} min");
//     }
//
//     // ✅ FIX: Enforce minimum 1 minute
//     if (stayTime < 1.0) {
//       stayTime = 1.0;
//       debugPrint("✅ Enforced minimum 1 minute for $clusterKey");
//     }
//
//     debugPrint("⏱️ Cluster $clusterKey stay time: ${stayTime.toStringAsFixed(2)} minutes");
//     return stayTime;
//   }
//
//   /// Get all cluster statistics
//   Map<String, dynamic> getStatistics() {
//     List<Map<String, dynamic>> clustersInfo = [];
//
//     _confirmedClusters.forEach((key, points) {
//       if (points.isNotEmpty) {
//         DateTime earliest = points.first.timestamp;
//         DateTime latest = points.first.timestamp;
//         Set<String> uniquePoints = {};
//
//         for (var p in points) {
//           if (p.timestamp.isBefore(earliest)) earliest = p.timestamp;
//           if (p.timestamp.isAfter(latest)) latest = p.timestamp;
//           uniquePoints.add("${p.point.latitude.toStringAsFixed(5)},${p.point.longitude.toStringAsFixed(5)}");
//         }
//
//         // Validate timestamps
//         DateTime now = DateTime.now();
//         if (earliest.isAfter(now)) earliest = now.subtract(Duration(minutes: 1));
//         if (latest.isAfter(now)) latest = now;
//         if (latest.isBefore(earliest)) {
//           DateTime temp = earliest;
//           earliest = latest;
//           latest = temp;
//         }
//
//         Duration timeRange = latest.difference(earliest);
//         double stayTimeMinutes = timeRange.inSeconds / 60.0;
//
//         // ✅ FIX: Apply time correction for suspicious times
//         if (stayTimeMinutes > 120.0) {
//           double realisticTime = points.length * 0.5;
//           realisticTime = realisticTime.clamp(0.1, 30.0);
//           stayTimeMinutes = realisticTime;
//         }
//
//         // ✅ FIX: Enforce minimum 1 minute
//         if (stayTimeMinutes < 1.0) {
//           stayTimeMinutes = 1.0;
//         }
//
//         clustersInfo.add({
//           'key': key,
//           'points': points.length,
//           'unique_points': uniquePoints.length,
//           'time_range_minutes': stayTimeMinutes,
//           'first_seen': earliest,
//           'last_seen': latest,
//           'center': _clusterCenters.containsKey(key) ? {
//             'lat': _clusterCenters[key]!.latitude,
//             'lng': _clusterCenters[key]!.longitude
//           } : null,
//           'meets_minimum_time': stayTimeMinutes >= minTimeInAreaMinutes,
//           'meets_minimum_points': uniquePoints.length >= minPointsForCluster,
//         });
//       }
//     });
//
//     return {
//       'total_clusters': _confirmedClusters.length,
//       'total_observed_areas': _observedAreas.length,
//       'total_processed_points': _processedPointMap.length,
//       'cluster_radius_meters': clusterRadiusMeters,
//       'min_points_for_cluster': minPointsForCluster,
//       'min_time_minutes': minTimeInAreaMinutes,
//       'cluster_attempts': _clusterAttempts.length,
//       'clusters': clustersInfo
//     };
//   }
//
//   /// Clear all internal state
//   void clear() {
//     _confirmedClusters.clear();
//     _clusterCenters.clear();
//     _observedAreas.clear();
//     _processedPointMap.clear();
//     _processedCenters.clear();
//     _clusterAttempts.clear();
//     debugPrint("🧹 IntelligentClusterDetector cleared");
//   }
//
//   // ========== PRIVATE HELPER METHODS ==========
//
//   int _countUniquePoints(List<ProcessedPoint> points) {
//     final Set<String> unique = {};
//     for (var p in points) {
//       unique.add("${p.point.latitude.toStringAsFixed(5)},${p.point.longitude.toStringAsFixed(5)}");
//     }
//     return unique.length;
//   }
//
//   LatLng _calculateCentroid(List<LatLng> points) {
//     if (points.isEmpty) return LatLng(0, 0);
//     double totalLat = 0.0, totalLng = 0.0;
//     for (var p in points) {
//       totalLat += p.latitude;
//       totalLng += p.longitude;
//     }
//     return LatLng(totalLat / points.length, totalLng / points.length);
//   }
//
//   void _updateClusterCenter(String clusterKey) {
//     if (!_confirmedClusters.containsKey(clusterKey) || _confirmedClusters[clusterKey]!.isEmpty) return;
//     List<LatLng> latlngs = _confirmedClusters[clusterKey]!.map((p) => p.point).toList();
//     _clusterCenters[clusterKey] = _calculateCentroid(latlngs);
//   }
//
//   double _calculateDistanceMeters(LatLng p1, LatLng p2) {
//     const double earthRadius = 6371000.0; // meters
//
//     double lat1 = p1.latitude * (pi / 180.0);
//     double lon1 = p1.longitude * (pi / 180.0);
//     double lat2 = p2.latitude * (pi / 180.0);
//     double lon2 = p2.longitude * (pi / 180.0);
//
//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;
//
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
//
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   String _generatePointKey(LatLng point) {
//     return "${point.latitude.toStringAsFixed(5)}|${point.longitude.toStringAsFixed(5)}";
//   }
// }
//
// /// Processed point with timestamp
// class ProcessedPoint {
//   final LatLng point;
//   final DateTime timestamp;
//
//   ProcessedPoint(this.point, this.timestamp);
// }
//
// /// Observed area
// class AreaObservation {
//   LatLng center;
//   List<ProcessedPoint> points;
//   DateTime firstSeen;
//   DateTime lastSeen;
//
//   AreaObservation({
//     required this.center,
//     required this.points,
//     required this.firstSeen,
//     required this.lastSeen,
//   });
//
//   void addPoint(LatLng point, DateTime timestamp) {
//     points.add(ProcessedPoint(point, timestamp));
//     if (timestamp.isBefore(firstSeen)) firstSeen = timestamp;
//     if (timestamp.isAfter(lastSeen)) lastSeen = timestamp;
//     center = _calculateCenter(points.map((p) => p.point).toList());
//   }
//
//   Duration get timeRange => lastSeen.difference(firstSeen);
//
//   LatLng _calculateCenter(List<LatLng> points) {
//     if (points.isEmpty) return center;
//     double totalLat = 0.0, totalLng = 0.0;
//     for (var p in points) {
//       totalLat += p.latitude;
//       totalLng += p.longitude;
//     }
//     return LatLng(totalLat / points.length, totalLng / points.length);
//   }
// }