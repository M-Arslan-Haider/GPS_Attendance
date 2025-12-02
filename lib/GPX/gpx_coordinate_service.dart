import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';

class GPXCoordinateService {

  Future<List<LatLng>> extractCoordinatesFromGPX(String filePath) async {
    debugPrint("🔍 extractCoordinatesFromGPX() called with path: $filePath");

    try {
      File file = File(filePath);

      debugPrint("📄 Checking if GPX file exists...");
      if (!file.existsSync()) {
        debugPrint("❌ GPX file not found: $filePath");
        return [];
      }

      debugPrint("📖 Reading GPX file...");
      String gpxContent = await file.readAsString();

      if (gpxContent.isEmpty) {
        debugPrint("❌ GPX file is empty");
        return [];
      }

      debugPrint("📦 Parsing GPX content...");
      Gpx gpx = GpxReader().fromString(gpxContent);
      List<LatLng> allCoordinates = [];

      debugPrint("🔍 Extracting tracks, segments, and points...");
      for (var track in gpx.trks) {
        debugPrint("➡️ Track found with ${track.trksegs.length} segments");

        for (var segment in track.trksegs) {
          debugPrint("   ➡️ Segment found with ${segment.trkpts.length} points");

          for (var point in segment.trkpts) {
            debugPrint("      🔹 Point lat=${point.lat}, lon=${point.lon}, time=${point.time}");

            if (point.lat != null && point.lon != null) {
              allCoordinates.add(LatLng(
                point.lat!.toDouble(),
                point.lon!.toDouble(),
              ));
            }
          }
        }
      }

      debugPrint("📍 Total Extracted Coordinates: ${allCoordinates.length}");
      return allCoordinates;

    } catch (e) {
      debugPrint("❌ Error extracting coordinates: $e");
      return [];
    }
  }

  LatLng calculateCentralPoint(List<LatLng> coordinates) {
    debugPrint("🎯 Calculating central point for ${coordinates.length} coordinates...");

    if (coordinates.isEmpty) {
      debugPrint("⚠️ No coordinates provided. Returning (0,0)");
      return LatLng(0.0, 0.0);
    }

    if (coordinates.length == 1) {
      debugPrint("✔️ Only 1 coordinate. Returning same point.");
      return coordinates.first;
    }

    double totalLat = 0.0;
    double totalLng = 0.0;

    for (var coord in coordinates) {
      debugPrint("   ➕ Adding Lat=${coord.latitude}, Lng=${coord.longitude}");
      totalLat += coord.latitude;
      totalLng += coord.longitude;
    }

    double centerLat = totalLat / coordinates.length;
    double centerLng = totalLng / coordinates.length;

    debugPrint("🎯 Central Point → Lat: $centerLat, Lng: $centerLng");

    return LatLng(centerLat, centerLng);
  }

  Map<String, List<LatLng>> clusterCoordinates(
      List<LatLng> coordinates,
      {double clusterDistance = 0.1}
      ) {
    debugPrint("🗂️ Starting clustering of ${coordinates.length} points...");
    debugPrint("📏 Cluster distance threshold: $clusterDistance km");

    Map<String, List<LatLng>> clusters = {};

    for (var coord in coordinates) {
      debugPrint("📌 Checking point: ${coord.latitude}, ${coord.longitude}");

      bool addedToCluster = false;

      for (var clusterKey in clusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distance = _calculateHaversineDistance(coord, clusterCenter);

        debugPrint("   📏 Distance from existing cluster ($clusterKey): $distance km");

        if (distance <= clusterDistance) {
          debugPrint("   ➕ Adding to cluster: $clusterKey");
          clusters[clusterKey]!.add(coord);
          addedToCluster = true;
          break;
        }
      }

      if (!addedToCluster) {
        String newClusterKey = "${coord.latitude},${coord.longitude}";
        debugPrint("   🆕 Creating new cluster: $newClusterKey");
        clusters[newClusterKey] = [coord];
      }
    }

    debugPrint("🗂️ Total clusters created: ${clusters.length}");
    return clusters;
  }

  Map<String, LatLng> calculateClusterCenters(Map<String, List<LatLng>> clusters) {
    debugPrint("📡 Calculating center for each cluster...");
    Map<String, LatLng> clusterCenters = {};

    clusters.forEach((key, clusterPoints) {
      debugPrint("➡️ Cluster: $key has ${clusterPoints.length} points");
      clusterCenters[key] = calculateCentralPoint(clusterPoints);
    });

    return clusterCenters;
  }

  double _calculateHaversineDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0;

    debugPrint("🌍 Calculating distance between:");
    debugPrint("   P1 → ${point1.latitude}, ${point1.longitude}");
    debugPrint("   P2 → ${point2.latitude}, ${point2.longitude}");

    double lat1 = point1.latitude * (pi / 180.0);
    double lon1 = point1.longitude * (pi / 180.0);
    double lat2 = point2.latitude * (pi / 180.0);
    double lon2 = point2.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    debugPrint("   📏 Haversine distance = $distance km");

    return distance;
  }

  LatLng _parseClusterKey(String key) {
    debugPrint("🔧 Parsing cluster key: $key");
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }
  // Calculate stay time in each cluster
  // gpx_coordinate_service.dart mein
  // gpx_coordinate_service.dart mein
  Map<String, double> calculateClusterStayTimes(
      List<Wpt> points,
      Map<String, List<LatLng>> clusters,
      {double timeThresholdMinutes = 5.0}
      ) {
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
          debugPrint("   ↳ Continuous stay, last time updated to: ${currentTime.toString()}");
        } else {
          // Break in stay - calculate previous session and start new
          double sessionStayTime = lastTimeInCluster.difference(entryTime!).inMinutes.toDouble();
          totalStayTime += sessionStayTime;
          debugPrint("🔴 Session ended: ${sessionStayTime.toStringAsFixed(2)} min");
          debugPrint("🟢 New session started at: ${currentTime.toString()}");

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
  Map<String, double> calculateClusterAreas(Map<String, List<LatLng>> clusters) {
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

  // Get address/district from coordinates
  Future<String> getAddressFromLatLng(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          point.latitude,
          point.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String district = place.subAdministrativeArea ?? place.locality ?? 'Unknown';
        String area = place.locality ?? place.subLocality ?? 'Unknown';

        return '$area, $district';
      }
    } catch (e) {
      debugPrint("❌ Error getting address: $e");
    }

    return 'Unknown Area';
  }

  Future<List<LatLng>> extractCoordinatesByTimeRange(String filePath, DateTime startTime, DateTime endTime) async {
    debugPrint("⏱️ extractCoordinatesByTimeRange() called");
    debugPrint("   Start: $startTime");
    debugPrint("   End:   $endTime");

    try {
      File file = File(filePath);

      if (!file.existsSync()) {
        debugPrint("❌ GPX file not found");
        return [];
      }

      String gpxContent = await file.readAsString();
      if (gpxContent.isEmpty) {
        debugPrint("❌ Empty GPX file");
        return [];
      }

      Gpx gpx = GpxReader().fromString(gpxContent);
      List<LatLng> filteredCoordinates = [];

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          for (var point in segment.trkpts) {
            debugPrint("🔹 Checking point time: ${point.time}");

            if (point.lat != null && point.lon != null && point.time != null) {
              if (point.time!.isAfter(startTime) && point.time!.isBefore(endTime)) {
                debugPrint("   ✔️ Added: ${point.lat}, ${point.lon}");
                filteredCoordinates.add(LatLng(
                    point.lat!.toDouble(),
                    point.lon!.toDouble()
                ));
              }
            }
          }
        }
      }

      debugPrint("📍 Total coordinates inside time range: ${filteredCoordinates.length}");
      return filteredCoordinates;

    } catch (e) {
      debugPrint("❌ Error extracting coordinates by time range: $e");
      return [];
    }
  }
}
