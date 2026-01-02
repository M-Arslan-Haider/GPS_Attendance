import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class IntelligentClusterDetector {
  // Fixed cluster radius in meters
  final double clusterRadiusMeters = 50.0;

  // Minimum points required in an area before creating a cluster
  final int minPointsForCluster = 3;

  // Time threshold for considering repeated movement (minutes)
  final double minTimeInAreaMinutes = 1.0;

  // Store pending areas that are being observed
  Map<String, AreaObservation> _observedAreas = {};

  // Confirmed clusters
  Map<String, List<LatLng>> _confirmedClusters = {};

  // Cluster centers
  Map<String, LatLng> _clusterCenters = {};

  // Track points that have been processed
  List<ProcessedPoint> _processedPoints = [];

  // Process a new point with timestamp
  Future<Map<String, dynamic>> processPointWithTime(LatLng point, DateTime timestamp) async {
    debugPrint("🔍 Processing point at ${timestamp.toString()}");
    debugPrint("📍 Coordinates: ${point.latitude}, ${point.longitude}");

    // Add to processed points
    _processedPoints.add(ProcessedPoint(point, timestamp));

    // Check if this point belongs to any existing confirmed cluster
    for (var clusterKey in _confirmedClusters.keys) {
      var clusterCenter = _parseClusterKey(clusterKey);
      double distance = _calculateDistanceMeters(point, clusterCenter);

      if (distance <= clusterRadiusMeters) {
        // Point belongs to existing cluster
        _confirmedClusters[clusterKey]!.add(point);
        _updateClusterCenter(clusterKey);

        debugPrint("✅ Added to existing cluster: $clusterKey");
        debugPrint("   Total points in cluster: ${_confirmedClusters[clusterKey]!.length}");

        return {
          'status': 'added_to_existing',
          'cluster_key': clusterKey,
          'total_points': _confirmedClusters[clusterKey]!.length,
          'is_new_cluster': false
        };
      }
    }

    // Check if point belongs to any observed area
    bool addedToObservedArea = false;
    for (var areaKey in _observedAreas.keys) {
      var areaCenter = _observedAreas[areaKey]!.center;
      double distance = _calculateDistanceMeters(point, areaCenter);

      if (distance <= clusterRadiusMeters) {
        // Add to observed area
        _observedAreas[areaKey]!.addPoint(point, timestamp);
        addedToObservedArea = true;

        debugPrint("📝 Added to observed area: $areaKey");
        debugPrint("   Points in area: ${_observedAreas[areaKey]!.points.length}");
        debugPrint("   Time range: ${_observedAreas[areaKey]!.timeRange.inMinutes} minutes");

        // Check if this area should become a confirmed cluster
        if (_shouldBecomeCluster(_observedAreas[areaKey]!)) {
          return _convertAreaToCluster(areaKey);
        }

        return {
          'status': 'observed',
          'area_key': areaKey,
          'points_count': _observedAreas[areaKey]!.points.length,
          'time_range_minutes': _observedAreas[areaKey]!.timeRange.inMinutes,
          'is_new_cluster': false
        };
      }
    }

    // Create new observed area
    if (!addedToObservedArea) {
      String newAreaKey = "${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}";
      _observedAreas[newAreaKey] = AreaObservation(
          center: point,
          points: [ProcessedPoint(point, timestamp)],
          firstSeen: timestamp,
          lastSeen: timestamp
      );

      debugPrint("🆕 Created new observed area: $newAreaKey");
      debugPrint("   Cluster radius: ${clusterRadiusMeters}m");

      return {
        'status': 'new_area_created',
        'area_key': newAreaKey,
        'cluster_radius_meters': clusterRadiusMeters,
        'is_new_cluster': false
      };
    }

    return {'status': 'processed', 'is_new_cluster': false};
  }

  // Check if an observed area should become a cluster
  bool _shouldBecomeCluster(AreaObservation area) {
    // Condition 1: Minimum number of points
    bool hasEnoughPoints = area.points.length >= minPointsForCluster;

    // Condition 2: Minimum time spent in area
    bool hasEnoughTime = area.timeRange.inMinutes >= minTimeInAreaMinutes;

    // Condition 3: Points are not just passing through (repeated movement)
    bool hasRepeatedMovement = _checkRepeatedMovement(area);

    debugPrint("""
    🔬 Area Evaluation:
       Points: ${area.points.length} (need $minPointsForCluster) → ${hasEnoughPoints ? '✅' : '❌'}
       Time: ${area.timeRange.inMinutes.toStringAsFixed(1)} min (need $minTimeInAreaMinutes) → ${hasEnoughTime ? '✅' : '❌'}
       Repeated Movement: ${hasRepeatedMovement ? '✅' : '❌'}
    """);

    return hasEnoughPoints && hasEnoughTime && hasRepeatedMovement;
  }

  // Check for repeated movement in an area
  bool _checkRepeatedMovement(AreaObservation area) {
    if (area.points.length < 3) return false;

    // Group points by time windows to detect if user left and returned
    List<DateTime> timestamps = area.points.map((p) => p.timestamp).toList();
    timestamps.sort();

    // Check if there are at least 2 distinct visits to this area
    int distinctVisits = 1;
    for (int i = 1; i < timestamps.length; i++) {
      double gap = timestamps[i].difference(timestamps[i-1]).inMinutes.toDouble();
      if (gap > 5.0) { // If gap is more than 5 minutes, consider it a new visit
        distinctVisits++;
      }
    }

    bool hasMultipleVisits = distinctVisits >= 2;

    // Check if points show exploration (not just straight line)
    bool showsExploration = _showsExplorationPattern(area.points.map((p) => p.point).toList());

    return hasMultipleVisits || showsExploration;
  }

  // Check if points show exploration pattern
  bool _showsExplorationPattern(List<LatLng> points) {
    if (points.length < 4) return false;

    // Calculate standard deviation of distances from centroid
    LatLng centroid = _calculateCentroid(points);
    List<double> distances = points.map((p) => _calculateDistanceMeters(p, centroid)).toList();

    double mean = distances.reduce((a, b) => a + b) / distances.length;
    double variance = distances.map((d) => pow(d - mean, 2)).reduce((a, b) => a + b) / distances.length;
    double stdDev = sqrt(variance);

    // If stdDev is significant compared to cluster radius, it shows exploration
    return stdDev > (clusterRadiusMeters * 0.3);
  }

  // Convert observed area to confirmed cluster
  Map<String, dynamic> _convertAreaToCluster(String areaKey) {
    var area = _observedAreas[areaKey]!;

    // Create cluster key
    String clusterKey = "${area.center.latitude.toStringAsFixed(6)},${area.center.longitude.toStringAsFixed(6)}";

    // Add all points from area to cluster
    _confirmedClusters[clusterKey] = area.points.map((p) => p.point).toList();

    // Calculate cluster center
    _clusterCenters[clusterKey] = _calculateCentroid(_confirmedClusters[clusterKey]!);

    debugPrint("""
    🎉🎉🎉 AREA CONVERTED TO CLUSTER! 🎉🎉🎉
    Area Key: $areaKey → Cluster Key: $clusterKey
    Total Points: ${_confirmedClusters[clusterKey]!.length}
    Time Observed: ${area.timeRange.inMinutes.toStringAsFixed(1)} minutes
    Cluster Radius: ${clusterRadiusMeters}m
    Center: ${_clusterCenters[clusterKey]!.latitude}, ${_clusterCenters[clusterKey]!.longitude}
    """);

    // Remove from observed areas
    _observedAreas.remove(areaKey);

    return {
      'status': 'new_cluster_created',
      'cluster_key': clusterKey,
      'total_points': _confirmedClusters[clusterKey]!.length,
      'center': _clusterCenters[clusterKey],
      'time_observed_minutes': area.timeRange.inMinutes,
      'is_new_cluster': true
    };
  }

  // Get all confirmed clusters
  Map<String, List<LatLng>> getConfirmedClusters() {
    return Map.from(_confirmedClusters);
  }

  // Get cluster centers
  Map<String, LatLng> getClusterCenters() {
    return Map.from(_clusterCenters);
  }

  // Get observed areas (for debugging/monitoring)
  Map<String, AreaObservation> getObservedAreas() {
    return Map.from(_observedAreas);
  }

  // Calculate centroid of points
  LatLng _calculateCentroid(List<LatLng> points) {
    double totalLat = 0.0;
    double totalLng = 0.0;

    for (var point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(totalLat / points.length, totalLng / points.length);
  }

  // Update cluster center
  void _updateClusterCenter(String clusterKey) {
    if (_confirmedClusters.containsKey(clusterKey)) {
      _clusterCenters[clusterKey] = _calculateCentroid(_confirmedClusters[clusterKey]!);
    }
  }

  // Calculate distance in meters
  double _calculateDistanceMeters(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000.0;

    double lat1 = p1.latitude * (pi / 180.0);
    double lon1 = p1.longitude * (pi / 180.0);
    double lat2 = p2.latitude * (pi / 180.0);
    double lon2 = p2.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Parse cluster key
  LatLng _parseClusterKey(String key) {
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  // Clear all data
  void clear() {
    _observedAreas.clear();
    _confirmedClusters.clear();
    _clusterCenters.clear();
    _processedPoints.clear();
    debugPrint("🧹 Cleared all cluster detection data");
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total_clusters': _confirmedClusters.length,
      'total_observed_areas': _observedAreas.length,
      'total_processed_points': _processedPoints.length,
      'cluster_radius_meters': clusterRadiusMeters,
      'min_points_for_cluster': minPointsForCluster,
      'min_time_minutes': minTimeInAreaMinutes,
      'clusters': _confirmedClusters.keys.map((key) => {
        'key': key,
        'points': _confirmedClusters[key]!.length,
        'center': _clusterCenters.containsKey(key) ? {
          'lat': _clusterCenters[key]!.latitude,
          'lng': _clusterCenters[key]!.longitude
        } : null
      }).toList()
    };
  }
}

// Helper class for processed points
class ProcessedPoint {
  final LatLng point;
  final DateTime timestamp;

  ProcessedPoint(this.point, this.timestamp);
}

// Helper class for area observation
class AreaObservation {
  LatLng center;
  List<ProcessedPoint> points;
  DateTime firstSeen;
  DateTime lastSeen;

  AreaObservation({
    required this.center,
    required this.points,
    required this.firstSeen,
    required this.lastSeen,
  });

  void addPoint(LatLng point, DateTime timestamp) {
    points.add(ProcessedPoint(point, timestamp));
    lastSeen = timestamp;
    // Recalculate center
    center = _calculateCenter(points.map((p) => p.point).toList());
  }

  Duration get timeRange => lastSeen.difference(firstSeen);

  LatLng _calculateCenter(List<LatLng> points) {
    double totalLat = 0.0;
    double totalLng = 0.0;

    for (var point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(totalLat / points.length, totalLng / points.length);
  }
}