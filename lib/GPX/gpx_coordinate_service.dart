import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';

class GPXCoordinateService {
  // Default cluster distance in meters (50 m)
  final double defaultClusterDistanceMeters = 50.0;

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

  /// Clustering function with strict distance in meters (default 50 m).
  /// Guarantees there will not be more than one cluster whose centroids are within the threshold.
  Map<String, List<LatLng>> clusterCoordinates(
      List<LatLng> coordinates, {
        double clusterDistanceMeters = 50.0, // meters
      }) {
    debugPrint("🗂️ Starting clustering of ${coordinates.length} points...");
    debugPrint("📏 Cluster distance threshold: ${clusterDistanceMeters.toStringAsFixed(0)} METERS");

    if (coordinates.isEmpty) {
      debugPrint("⚠️ No coordinates to cluster");
      return {};
    }

    // Each cluster is represented as a Map {'center': LatLng, 'points': List<LatLng>}
    List<_Cluster> clusters = [];

    for (final point in coordinates) {
      // find nearest cluster
      double minDist = double.infinity;
      int? nearestIndex;

      for (int i = 0; i < clusters.length; i++) {
        final c = clusters[i];
        double dist = _haversineDistanceMeters(point, c.center);
        if (dist < minDist) {
          minDist = dist;
          nearestIndex = i;
        }
      }

      if (nearestIndex != null && minDist <= clusterDistanceMeters) {
        // Add point to nearest cluster and update centroid
        clusters[nearestIndex].points.add(point);
        clusters[nearestIndex].recalculateCenter();
      } else {
        // Create new cluster
        clusters.add(_Cluster(center: point, points: [point]));
      }
    }

    debugPrint("🔁 Initial clustering created ${clusters.length} clusters. Now merging close clusters...");

    // Merge clusters whose centers are within clusterDistanceMeters (agglomerative)
    bool mergedSomething = true;
    while (mergedSomething) {
      mergedSomething = false;

      outer:
      for (int i = 0; i < clusters.length; i++) {
        for (int j = i + 1; j < clusters.length; j++) {
          double dist = _haversineDistanceMeters(clusters[i].center, clusters[j].center);
          if (dist <= clusterDistanceMeters) {
            // Merge j into i
            clusters[i].points.addAll(clusters[j].points);
            clusters[i].recalculateCenter();
            clusters.removeAt(j);
            mergedSomething = true;
            break outer;
          }
        }
      }
    }

    debugPrint("✅ Clustering COMPLETE. Final clusters: ${clusters.length}");

    Map<String, List<LatLng>> result = {};
    for (var c in clusters) {
      String key = "${c.center.latitude.toStringAsFixed(6)},${c.center.longitude.toStringAsFixed(6)}";
      result[key] = List<LatLng>.from(c.points);
      debugPrint("   Cluster: $key -> ${c.points.length} points (center)");
    }

    return result;
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

  /// Haversine distance between two LatLng points in meters.
  double _haversineDistanceMeters(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000.0; // meters

    double lat1 = p1.latitude * (pi / 180.0);
    double lon1 = p1.longitude * (pi / 180.0);
    double lat2 = p2.latitude * (pi / 180.0);
    double lon2 = p2.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // meters
  }

  // The following public helper returns meters (keeps naming similarity to earlier API)
  double calculateDistanceMeters(LatLng p1, LatLng p2) {
    return _haversineDistanceMeters(p1, p2);
  }

  // For compatibility with other modules: a public method that returns stay times, areas etc.
  Map<String, double> calculateClusterStayTimes(
      List<Wpt> points,
      Map<String, List<LatLng>> clusters, {
        double timeThresholdMinutes = 5.0,
        double clusterDistanceMeters = 50.0,
      }) {
    debugPrint("⏱️ Calculating ACTUAL cluster stay times...");

    Map<String, double> stayTimes = {};
    Map<String, List<DateTime>> clusterTimestamps = {};

    for (var point in points) {
      if (point.lat == null || point.lon == null || point.time == null) continue;

      LatLng pointLatLng = LatLng(point.lat!.toDouble(), point.lon!.toDouble());

      for (var clusterKey in clusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distanceMeters = _haversineDistanceMeters(pointLatLng, clusterCenter);

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
          continue;
        }

        double timeGap = currentTime.difference(lastTimeInCluster!).inMinutes.toDouble();

        if (timeGap <= timeThresholdMinutes) {
          lastTimeInCluster = currentTime;
        } else {
          double sessionStayTime = lastTimeInCluster.difference(entryTime!).inMinutes.toDouble();
          totalStayTime += sessionStayTime;

          entryTime = currentTime;
          lastTimeInCluster = currentTime;
        }
      }

      if (entryTime != null && lastTimeInCluster != null) {
        double lastSessionStayTime = lastTimeInCluster.difference(entryTime).inMinutes.toDouble();
        totalStayTime += lastSessionStayTime;
      }

      stayTimes[clusterKey] = totalStayTime;
      debugPrint("⏱️ Cluster $clusterKey TOTAL stay time: ${totalStayTime.toStringAsFixed(2)} minutes");
    });

    return stayTimes;
  }

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

  // ENHANCED: Get VERY DETAILED address and include in cluster data
  Future<String> getExtremelyDetailedAddress(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build super detailed address with ALL available fields
        List<String> addressParts = [];

        // Add ALL available fields
        if (place.street != null && place.street!.isNotEmpty) addressParts.add("Street: ${place.street!}");
        if (place.name != null && place.name!.isNotEmpty && place.name != place.street) addressParts.add("Name: ${place.name!}");
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add("Sublocality: ${place.subLocality!}");
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add("Locality: ${place.locality!}");
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) addressParts.add("SubAdmin: ${place.subAdministrativeArea!}");
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add("Admin Area: ${place.administrativeArea!}");
        if (place.postalCode != null && place.postalCode!.isNotEmpty) addressParts.add("Postal: ${place.postalCode!}");
        if (place.country != null && place.country!.isNotEmpty) addressParts.add("Country: ${place.country!}");
        if (place.isoCountryCode != null && place.isoCountryCode!.isNotEmpty) addressParts.add("Code: ${place.isoCountryCode!}");

        // Add coordinates
        addressParts.add("Coordinates: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}");

        // Add timestamp
        String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        addressParts.add("Processed: $currentTime");

        String fullAddress = addressParts.join('\n');

        debugPrint("📍 EXTREMELY DETAILED ADDRESS:");
        debugPrint(fullAddress);

        return fullAddress;
      }
    } catch (e) {
      debugPrint("❌ Error getting detailed address: $e");
    }

    // Fallback with coordinates
    String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    return """Coordinates: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}
Location details not available
Processed: $currentTime""";
  }

  // Original method for backward compatibility
  Future<String> getAddressFromLatLng(LatLng point) async {
    return await getExtremelyDetailedAddress(point);
  }
}

class _Cluster {
  LatLng center;
  List<LatLng> points;

  _Cluster({required this.center, required this.points});

  void recalculateCenter() {
    if (points.isEmpty) return;
    double lat = 0.0, lng = 0.0;
    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    center = LatLng(lat / points.length, lng / points.length);
  }
}