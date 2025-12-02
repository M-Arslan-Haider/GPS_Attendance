// // import 'dart:math';
// // import 'package:collection/collection.dart';
// // import 'package:order_booking_app/Cluster_Data/travel_cluster_model.dart';
// // import 'cluster_model.dart';
// //
// // class ClusteringService {
// //   static const double CLUSTER_RADIUS_KM = 0.1; // 100 meters for more precise clustering
// //   static const int MIN_CLUSTER_POINTS = 3; // Reduced for better clustering
// //   static const int STAY_TIME_THRESHOLD_MINUTES = 10; // 10 minutes stay time
// //
// //   // Enhanced DBSCAN Clustering Algorithm for movement data
// //   List<TravelClusterModel> performDBSCANClustering(List<ClusterModel> points) {
// //     if (points.isEmpty) return [];
// //
// //     final clusters = <TravelClusterModel>[];
// //     final visited = <int>{};
// //     int clusterId = 0;
// //
// //     // Sort points by time to analyze movement patterns
// //     points.sort((a, b) {
// //       final timeA = _parseTime(a.startTime);
// //       final timeB = _parseTime(b.startTime);
// //       return timeA.compareTo(timeB);
// //     });
// //
// //     for (final point in points) {
// //       if (point.id == null || visited.contains(point.id)) continue;
// //
// //       visited.add(point.id!);
// //
// //       // Find neighbors based on both location and time proximity
// //       final neighbors = _findEnhancedNeighbors(point, points);
// //
// //       if (neighbors.length < MIN_CLUSTER_POINTS) {
// //         // Check if this is a stay point (multiple points in same location over time)
// //         final stayPoints = _findStayPoints(point, points, visited);
// //         if (stayPoints.length >= 2) {
// //           clusters.add(_createStayCluster(stayPoints, clusterId++));
// //         } else {
// //           // Single movement point
// //           clusters.add(_createSinglePointCluster(point, clusterId++, 'MOVEMENT'));
// //         }
// //       } else {
// //         // Expand cluster for movement patterns
// //         final clusterPoints = _expandCluster(point, neighbors, visited, points);
// //         final clusterType = _analyzeMovementPattern(clusterPoints);
// //         clusters.add(_createClusterFromPoints(clusterPoints, clusterId++, clusterType));
// //       }
// //     }
// //
// //     return clusters;
// //   }
// //
// //   List<ClusterModel> _findEnhancedNeighbors(ClusterModel point, List<ClusterModel> allPoints) {
// //     return allPoints.where((otherPoint) {
// //       if (otherPoint.id == point.id ||
// //           otherPoint.latitude == null ||
// //           otherPoint.longitude == null ||
// //           point.latitude == null ||
// //           point.longitude == null) {
// //         return false;
// //       }
// //
// //       // Distance check
// //       final distance = _calculateDistance(
// //         point.latitude!,
// //         point.longitude!,
// //         otherPoint.latitude!,
// //         otherPoint.longitude!,
// //       );
// //
// //       // Time proximity check (within 30 minutes)
// //       final timeDiff = _calculateTimeDifference(point.startTime, otherPoint.startTime);
// //
// //       return distance <= CLUSTER_RADIUS_KM && timeDiff <= 30;
// //     }).toList();
// //   }
// //
// //   List<ClusterModel> _findStayPoints(ClusterModel point, List<ClusterModel> allPoints, Set<int> visited) {
// //     final stayPoints = <ClusterModel>[point];
// //
// //     for (final otherPoint in allPoints) {
// //       if (otherPoint.id == point.id || visited.contains(otherPoint.id!) ||
// //           otherPoint.latitude == null || otherPoint.longitude == null) {
// //         continue;
// //       }
// //
// //       final distance = _calculateDistance(
// //         point.latitude!,
// //         point.longitude!,
// //         otherPoint.latitude!,
// //         otherPoint.longitude!,
// //       );
// //
// //       final timeDiff = _calculateTimeDifference(point.startTime, otherPoint.startTime);
// //
// //       // If same location and within time threshold, consider as stay point
// //       if (distance <= 0.05 && timeDiff <= STAY_TIME_THRESHOLD_MINUTES) { // 50 meters
// //         stayPoints.add(otherPoint);
// //         visited.add(otherPoint.id!);
// //       }
// //     }
// //
// //     return stayPoints;
// //   }
// //
// //   List<ClusterModel> _expandCluster(
// //       ClusterModel point,
// //       List<ClusterModel> neighbors,
// //       Set<int> visited,
// //       List<ClusterModel> allPoints,
// //       ) {
// //     final clusterPoints = <ClusterModel>[...neighbors];
// //     final queue = QueueList<ClusterModel>.from(neighbors);
// //
// //     while (queue.isNotEmpty) {
// //       final currentPoint = queue.removeFirst();
// //
// //       if (currentPoint.id == null || visited.contains(currentPoint.id)) continue;
// //
// //       visited.add(currentPoint.id!);
// //       final currentNeighbors = _findEnhancedNeighbors(currentPoint, allPoints);
// //
// //       if (currentNeighbors.length >= MIN_CLUSTER_POINTS) {
// //         for (final neighbor in currentNeighbors) {
// //           if (neighbor.id == null || visited.contains(neighbor.id)) continue;
// //
// //           if (!clusterPoints.any((p) => p.id == neighbor.id)) {
// //             clusterPoints.add(neighbor);
// //             queue.add(neighbor);
// //           }
// //         }
// //       }
// //     }
// //
// //     return clusterPoints;
// //   }
// //
// //   TravelClusterModel _createSinglePointCluster(ClusterModel point, int clusterId, String type) {
// //     return TravelClusterModel(
// //       clusterId: clusterId,
// //       clusterType: type,
// //       centerLat: point.latitude ?? 0.0,
// //       centerLon: point.longitude ?? 0.0,
// //       pointCount: 1,
// //       totalDistance: point.totalTravelDistance ?? 0.0,
// //       averageSpeed: point.averageSpeed ?? 0.0,
// //       points: [point],
// //       clusterDate: _parseDate(point.travelDate) ?? DateTime.now(),
// //       locationType: point.locationType ?? 'MOVEMENT',
// //     );
// //   }
// //
// //   TravelClusterModel _createStayCluster(List<ClusterModel> points, int clusterId) {
// //     final center = _calculateCentroid(points);
// //
// //     return TravelClusterModel(
// //       clusterId: clusterId,
// //       clusterType: 'STAY_POINT',
// //       centerLat: center.latitude,
// //       centerLon: center.longitude,
// //       pointCount: points.length,
// //       totalDistance: 0.0,
// //       averageSpeed: 0.0,
// //       points: points,
// //       clusterDate: _parseDate(points.first.travelDate) ?? DateTime.now(),
// //       locationType: 'STAY',
// //     );
// //   }
// //
// //   TravelClusterModel _createClusterFromPoints(List<ClusterModel> points, int clusterId, String clusterType) {
// //     if (points.isEmpty) throw ArgumentError('Points cannot be empty');
// //
// //     final center = _calculateCentroid(points);
// //     final totalDistance = points.fold<double>(
// //         0.0, (sum, point) => sum + (point.totalTravelDistance ?? 0.0)
// //     );
// //
// //     final averageSpeed = points.fold<double>(
// //         0.0, (sum, point) => sum + (point.averageSpeed ?? 0.0)
// //     ) / points.length;
// //
// //     return TravelClusterModel(
// //       clusterId: clusterId,
// //       clusterType: clusterType,
// //       centerLat: center.latitude,
// //       centerLon: center.longitude,
// //       pointCount: points.length,
// //       totalDistance: totalDistance,
// //       averageSpeed: averageSpeed,
// //       points: points,
// //       clusterDate: _parseDate(points.first.travelDate) ?? DateTime.now(),
// //       locationType: _getDominantLocationType(points),
// //     );
// //   }
// //
// //   String _analyzeMovementPattern(List<ClusterModel> points) {
// //     if (points.length >= 8) return 'HIGH_ACTIVITY_ZONE';
// //     if (points.length >= 5) return 'MOVEMENT_CORRIDOR';
// //     if (points.length >= 3) return 'ROUTE_SEGMENT';
// //     return 'MOVEMENT_GROUP';
// //   }
// //
// //   String _getDominantLocationType(List<ClusterModel> points) {
// //     final typeCount = <String, int>{};
// //
// //     for (final point in points) {
// //       final locationType = point.locationType ?? 'MOVEMENT';
// //       typeCount[locationType] = (typeCount[locationType] ?? 0) + 1;
// //     }
// //
// //     return typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
// //   }
// //
// //   LatLng _calculateCentroid(List<ClusterModel> points) {
// //     double sumLat = 0.0;
// //     double sumLon = 0.0;
// //     int count = 0;
// //
// //     for (final point in points) {
// //       if (point.latitude != null && point.longitude != null) {
// //         sumLat += point.latitude!;
// //         sumLon += point.longitude!;
// //         count++;
// //       }
// //     }
// //
// //     return LatLng(
// //       count > 0 ? sumLat / count : 0.0,
// //       count > 0 ? sumLon / count : 0.0,
// //     );
// //   }
// //
// //   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// //     const earthRadius = 6371.0;
// //
// //     final dLat = _toRadians(lat2 - lat1);
// //     final dLon = _toRadians(lon2 - lon1);
// //
// //     final a = sin(dLat / 2) * sin(dLat / 2) +
// //         cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
// //
// //     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
// //
// //     return earthRadius * c;
// //   }
// //
// //   int _calculateTimeDifference(String? time1, String? time2) {
// //     try {
// //       final t1 = _parseTime(time1);
// //       final t2 = _parseTime(time2);
// //       return (t1.difference(t2).inMinutes).abs();
// //     } catch (e) {
// //       return 999;
// //     }
// //   }
// //
// //   DateTime _parseTime(String? timeString) {
// //     if (timeString == null) return DateTime.now();
// //
// //     try {
// //       final today = DateTime.now();
// //       final timeParts = timeString.split(':');
// //       if (timeParts.length >= 2) {
// //         final hour = int.tryParse(timeParts[0]) ?? 0;
// //         final minute = int.tryParse(timeParts[1]) ?? 0;
// //         return DateTime(
// //             today.year, today.month, today.day,
// //             hour, minute
// //         );
// //       }
// //       return DateTime.now();
// //     } catch (e) {
// //       return DateTime.now();
// //     }
// //   }
// //
// //   double _toRadians(double degrees) => degrees * pi / 180.0;
// //
// //   DateTime? _parseDate(String? dateString) {
// //     if (dateString == null) return null;
// //     try {
// //       return DateTime.parse(dateString);
// //     } catch (e) {
// //       return null;
// //     }
// //   }
// // }
// //
// // class LatLng {
// //   final double latitude;
// //   final double longitude;
// //
// //   LatLng(this.latitude, this.longitude);
// // }
// import 'dart:math';
// import 'package:collection/collection.dart';
// import 'package:order_booking_app/Cluster_Data/travel_cluster_model.dart';
// import 'cluster_model.dart';
//
// class ClusteringService {
//   static const double CLUSTER_RADIUS_KM = 0.1; // 100 meters for more precise clustering
//   static const int MIN_CLUSTER_POINTS = 3; // Reduced for better clustering
//   static const int STAY_TIME_THRESHOLD_MINUTES = 10; // 10 minutes stay time
//
//   // Enhanced DBSCAN Clustering Algorithm for movement data
//   List<TravelClusterModel> performDBSCANClustering(List<ClusterModel> points) {
//     print('🚀 === CLUSTERING STARTED ===');
//     print('📊 Total points received: ${points.length}');
//
//     if (points.isEmpty) {
//       print('❌ No points to cluster');
//       return [];
//     }
//
//     // Debug: Print all points with details
//     _printAllPoints(points);
//
//     final clusters = <TravelClusterModel>[];
//     final visited = <int>{};
//     int clusterId = 0;
//
//     // Sort points by time to analyze movement patterns
//     points.sort((a, b) {
//       final timeA = _parseTime(a.startTime);
//       final timeB = _parseTime(b.startTime);
//       return timeA.compareTo(timeB);
//     });
//
//     print('🕒 Points sorted by time');
//
//     for (final point in points) {
//       if (point.id == null || visited.contains(point.id)) continue;
//
//       visited.add(point.id!);
//
//       print('\n🔍 Processing Point ID: ${point.id}');
//       print('📍 Location: (${point.latitude}, ${point.longitude})');
//       print('⏰ Time: ${point.startTime}');
//       print('👤 User: ${point.userId}');
//       print('📅 Date: ${point.travelDate}');
//
//       // Find neighbors based on both location and time proximity
//       final neighbors = _findEnhancedNeighbors(point, points);
//       print('🤝 Found ${neighbors.length} neighbors');
//
//       if (neighbors.length < MIN_CLUSTER_POINTS) {
//         print('➖ Insufficient neighbors, checking for stay points...');
//
//         // Check if this is a stay point (multiple points in same location over time)
//         final stayPoints = _findStayPoints(point, points, visited);
//         print('⏳ Stay points found: ${stayPoints.length}');
//
//         if (stayPoints.length >= 2) {
//           print('🏨 Creating STAY cluster with ${stayPoints.length} points');
//           clusters.add(_createStayCluster(stayPoints, clusterId++));
//         } else {
//           // Single movement point
//           print('🚶 Creating SINGLE movement point cluster');
//           clusters.add(_createSinglePointCluster(point, clusterId++, 'MOVEMENT'));
//         }
//       } else {
//         // Expand cluster for movement patterns
//         print('🔄 Expanding cluster with ${neighbors.length} neighbors');
//         final clusterPoints = _expandCluster(point, neighbors, visited, points);
//         final clusterType = _analyzeMovementPattern(clusterPoints);
//
//         print('✅ Created ${clusterType} cluster with ${clusterPoints.length} points');
//         clusters.add(_createClusterFromPoints(clusterPoints, clusterId++, clusterType));
//       }
//     }
//
//     print('\n🎉 === CLUSTERING COMPLETED ===');
//     print('📈 Total clusters created: ${clusters.length}');
//
//     // Print cluster summary
//     _printClusterSummary(clusters);
//
//     return clusters;
//   }
//
//   // Helper method to print all points
//   void _printAllPoints(List<ClusterModel> points) {
//     print('\n📋 === ALL POINTS DETAILS ===');
//     for (int i = 0; i < points.length; i++) {
//       final point = points[i];
//       print('${i + 1}. ID: ${point.id} | '
//           'User: ${point.userId} | '
//           'Location: (${point.latitude?.toStringAsFixed(6)}, ${point.longitude?.toStringAsFixed(6)}) | '
//           'Time: ${point.startTime} | '
//           'Date: ${point.travelDate} | '
//           'Type: ${point.locationType} | '
//           'Distance: ${point.totalTravelDistance?.toStringAsFixed(2)} km');
//     }
//     print('=== END POINTS DETAILS ===\n');
//   }
//
//   // Helper method to print cluster summary
//   void _printClusterSummary(List<TravelClusterModel> clusters) {
//     print('\n📊 === CLUSTER SUMMARY ===');
//
//     if (clusters.isEmpty) {
//       print('No clusters created');
//       return;
//     }
//
//     final clusterTypes = <String, int>{};
//     int totalPoints = 0;
//
//     for (final cluster in clusters) {
//       clusterTypes[cluster.clusterType] = (clusterTypes[cluster.clusterType] ?? 0) + 1;
//       totalPoints += cluster.pointCount;
//
//       print('Cluster ${cluster.clusterId}: '
//           'Type: ${cluster.clusterType} | '
//           'Points: ${cluster.pointCount} | '
//           'Center: (${cluster.centerLat.toStringAsFixed(6)}, ${cluster.centerLon.toStringAsFixed(6)}) | '
//           'Location Type: ${cluster.locationType}');
//     }
//
//     print('\n📈 === STATISTICS ===');
//     print('Total Clusters: ${clusters.length}');
//     print('Total Points in Clusters: $totalPoints');
//     clusterTypes.forEach((type, count) {
//       print('$type: $count clusters');
//     });
//     print('=== END SUMMARY ===\n');
//   }
//
//   List<ClusterModel> _findEnhancedNeighbors(ClusterModel point, List<ClusterModel> allPoints) {
//     final neighbors = allPoints.where((otherPoint) {
//       if (otherPoint.id == point.id ||
//           otherPoint.latitude == null ||
//           otherPoint.longitude == null ||
//           point.latitude == null ||
//           point.longitude == null) {
//         return false;
//       }
//
//       // Distance check
//       final distance = _calculateDistance(
//         point.latitude!,
//         point.longitude!,
//         otherPoint.latitude!,
//         otherPoint.longitude!,
//       );
//
//       // Time proximity check (within 30 minutes)
//       final timeDiff = _calculateTimeDifference(point.startTime, otherPoint.startTime);
//
//       final isNeighbor = distance <= CLUSTER_RADIUS_KM && timeDiff <= 30;
//
//       if (isNeighbor) {
//         print('   👥 Neighbor found - ID: ${otherPoint.id}, '
//             'Distance: ${distance.toStringAsFixed(3)} km, '
//             'Time Diff: ${timeDiff} min');
//       }
//
//       return isNeighbor;
//     }).toList();
//
//     return neighbors;
//   }
//
//   List<ClusterModel> _findStayPoints(ClusterModel point, List<ClusterModel> allPoints, Set<int> visited) {
//     final stayPoints = <ClusterModel>[point];
//
//     print('   🔎 Searching for stay points around point ${point.id}');
//
//     for (final otherPoint in allPoints) {
//       if (otherPoint.id == point.id || visited.contains(otherPoint.id!) ||
//           otherPoint.latitude == null || otherPoint.longitude == null) {
//         continue;
//       }
//
//       final distance = _calculateDistance(
//         point.latitude!,
//         point.longitude!,
//         otherPoint.latitude!,
//         otherPoint.longitude!,
//       );
//
//       final timeDiff = _calculateTimeDifference(point.startTime, otherPoint.startTime);
//
//       // If same location and within time threshold, consider as stay point
//       if (distance <= 0.05 && timeDiff <= STAY_TIME_THRESHOLD_MINUTES) { // 50 meters
//         print('   🕒 Stay point found - ID: ${otherPoint.id}, '
//             'Distance: ${distance.toStringAsFixed(3)} km, '
//             'Time Diff: ${timeDiff} min');
//         stayPoints.add(otherPoint);
//         visited.add(otherPoint.id!);
//       }
//     }
//
//     return stayPoints;
//   }
//
//   List<ClusterModel> _expandCluster(
//       ClusterModel point,
//       List<ClusterModel> neighbors,
//       Set<int> visited,
//       List<ClusterModel> allPoints,
//       ) {
//     print('   🔄 Expanding cluster from point ${point.id}');
//
//     final clusterPoints = <ClusterModel>[...neighbors];
//     final queue = QueueList<ClusterModel>.from(neighbors);
//
//     int expansionCount = 0;
//
//     while (queue.isNotEmpty) {
//       final currentPoint = queue.removeFirst();
//
//       if (currentPoint.id == null || visited.contains(currentPoint.id)) continue;
//
//       visited.add(currentPoint.id!);
//       final currentNeighbors = _findEnhancedNeighbors(currentPoint, allPoints);
//
//       if (currentNeighbors.length >= MIN_CLUSTER_POINTS) {
//         for (final neighbor in currentNeighbors) {
//           if (neighbor.id == null || visited.contains(neighbor.id)) continue;
//
//           if (!clusterPoints.any((p) => p.id == neighbor.id)) {
//             clusterPoints.add(neighbor);
//             queue.add(neighbor);
//             expansionCount++;
//             print('     ➕ Added neighbor ${neighbor.id} to cluster');
//           }
//         }
//       }
//     }
//
//     print('   ✅ Cluster expansion completed. Added $expansionCount additional points');
//     return clusterPoints;
//   }
//
//   TravelClusterModel _createSinglePointCluster(ClusterModel point, int clusterId, String type) {
//     print('   🎯 Creating single point cluster: ID $clusterId, Type: $type');
//
//     return TravelClusterModel(
//       clusterId: clusterId,
//       clusterType: type,
//       centerLat: point.latitude ?? 0.0,
//       centerLon: point.longitude ?? 0.0,
//       pointCount: 1,
//       totalDistance: point.totalTravelDistance ?? 0.0,
//       averageSpeed: point.averageSpeed ?? 0.0,
//       points: [point],
//       clusterDate: _parseDate(point.travelDate) ?? DateTime.now(),
//       locationType: point.locationType ?? 'MOVEMENT',
//     );
//   }
//
//   TravelClusterModel _createStayCluster(List<ClusterModel> points, int clusterId) {
//     final center = _calculateCentroid(points);
//
//     print('   🏨 Creating stay cluster: ID $clusterId, Points: ${points.length}');
//
//     return TravelClusterModel(
//       clusterId: clusterId,
//       clusterType: 'STAY_POINT',
//       centerLat: center.latitude,
//       centerLon: center.longitude,
//       pointCount: points.length,
//       totalDistance: 0.0,
//       averageSpeed: 0.0,
//       points: points,
//       clusterDate: _parseDate(points.first.travelDate) ?? DateTime.now(),
//       locationType: 'STAY',
//     );
//   }
//
//   TravelClusterModel _createClusterFromPoints(List<ClusterModel> points, int clusterId, String clusterType) {
//     if (points.isEmpty) throw ArgumentError('Points cannot be empty');
//
//     final center = _calculateCentroid(points);
//     final totalDistance = points.fold<double>(
//         0.0, (sum, point) => sum + (point.totalTravelDistance ?? 0.0)
//     );
//
//     final averageSpeed = points.fold<double>(
//         0.0, (sum, point) => sum + (point.averageSpeed ?? 0.0)
//     ) / points.length;
//
//     print('   🎪 Creating cluster: ID $clusterId, Type: $clusterType, '
//         'Points: ${points.length}, Center: (${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)})');
//
//     return TravelClusterModel(
//       clusterId: clusterId,
//       clusterType: clusterType,
//       centerLat: center.latitude,
//       centerLon: center.longitude,
//       pointCount: points.length,
//       totalDistance: totalDistance,
//       averageSpeed: averageSpeed,
//       points: points,
//       clusterDate: _parseDate(points.first.travelDate) ?? DateTime.now(),
//       locationType: _getDominantLocationType(points),
//     );
//   }
//
//   String _analyzeMovementPattern(List<ClusterModel> points) {
//     final clusterType =
//     points.length >= 8 ? 'HIGH_ACTIVITY_ZONE' :
//     points.length >= 5 ? 'MOVEMENT_CORRIDOR' :
//     points.length >= 3 ? 'ROUTE_SEGMENT' : 'MOVEMENT_GROUP';
//
//     print('   📊 Movement pattern analyzed: ${points.length} points -> $clusterType');
//
//     return clusterType;
//   }
//
//   String _getDominantLocationType(List<ClusterModel> points) {
//     final typeCount = <String, int>{};
//
//     for (final point in points) {
//       final locationType = point.locationType ?? 'MOVEMENT';
//       typeCount[locationType] = (typeCount[locationType] ?? 0) + 1;
//     }
//
//     final dominantType = typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
//     print('   🏷️ Dominant location type: $dominantType (counts: $typeCount)');
//
//     return dominantType;
//   }
//
//   LatLng _calculateCentroid(List<ClusterModel> points) {
//     double sumLat = 0.0;
//     double sumLon = 0.0;
//     int count = 0;
//
//     for (final point in points) {
//       if (point.latitude != null && point.longitude != null) {
//         sumLat += point.latitude!;
//         sumLon += point.longitude!;
//         count++;
//       }
//     }
//
//     final centroid = LatLng(
//       count > 0 ? sumLat / count : 0.0,
//       count > 0 ? sumLon / count : 0.0,
//     );
//
//     print('   📍 Centroid calculated: (${centroid.latitude.toStringAsFixed(6)}, ${centroid.longitude.toStringAsFixed(6)}) from $count points');
//
//     return centroid;
//   }
//
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const earthRadius = 6371.0;
//
//     final dLat = _toRadians(lat2 - lat1);
//     final dLon = _toRadians(lon2 - lon1);
//
//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
//
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   int _calculateTimeDifference(String? time1, String? time2) {
//     try {
//       final t1 = _parseTime(time1);
//       final t2 = _parseTime(time2);
//       final difference = (t1.difference(t2).inMinutes).abs();
//       return difference;
//     } catch (e) {
//       return 999;
//     }
//   }
//
//   DateTime _parseTime(String? timeString) {
//     if (timeString == null) return DateTime.now();
//
//     try {
//       final today = DateTime.now();
//       final timeParts = timeString.split(':');
//       if (timeParts.length >= 2) {
//         final hour = int.tryParse(timeParts[0]) ?? 0;
//         final minute = int.tryParse(timeParts[1]) ?? 0;
//         return DateTime(
//             today.year, today.month, today.day,
//             hour, minute
//         );
//       }
//       return DateTime.now();
//     } catch (e) {
//       return DateTime.now();
//     }
//   }
//
//   double _toRadians(double degrees) => degrees * pi / 180.0;
//
//   DateTime? _parseDate(String? dateString) {
//     if (dateString == null) return null;
//     try {
//       return DateTime.parse(dateString);
//     } catch (e) {
//       return null;
//     }
//   }
// }
//
// class LatLng {
//   final double latitude;
//   final double longitude;
//
//   LatLng(this.latitude, this.longitude);
// }