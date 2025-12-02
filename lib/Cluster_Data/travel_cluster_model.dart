// // lib/Cluster_Data/travel_cluster_model.dart
// import 'cluster_model.dart';
//
// class TravelCluster {
//   final int clusterId;
//   final String clusterType;
//   final double centerLat;
//   final double centerLon;
//   final int pointCount;
//   final double totalDistance;
//   final double averageSpeed;
//   final List<TravelDataModel> points;
//   final DateTime clusterDate;
//
//   TravelCluster({
//     required this.clusterId,
//     required this.clusterType,
//     required this.centerLat,
//     required this.centerLon,
//     required this.pointCount,
//     required this.totalDistance,
//     required this.averageSpeed,
//     required this.points,
//     required this.clusterDate,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'cluster_id': clusterId,
//       'cluster_type': clusterType,
//       'center_lat': centerLat,
//       'center_lon': centerLon,
//       'point_count': pointCount,
//       'total_distance': totalDistance,
//       'average_speed': averageSpeed,
//       'cluster_date': clusterDate.toIso8601String(),
//     };
//   }
// }
// lib/Cluster_Data/travel_cluster_model.dart
import 'cluster_model.dart';

class TravelClusterModel {
  final int clusterId;
  final String clusterType;
  final double centerLat;
  final double centerLon;
  final int pointCount;
  final double totalDistance;
  final double averageSpeed;
  final List<ClusterModel> points;
  final DateTime clusterDate;

  TravelClusterModel({
    required this.clusterId,
    required this.clusterType,
    required this.centerLat,
    required this.centerLon,
    required this.pointCount,
    required this.totalDistance,
    required this.averageSpeed,
    required this.points,
    required this.clusterDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'cluster_id': clusterId,
      'cluster_type': clusterType,
      'center_lat': centerLat,
      'center_lon': centerLon,
      'point_count': pointCount,
      'total_distance': totalDistance,
      'average_speed': averageSpeed,
      'cluster_date': clusterDate.toIso8601String(),
    };
  }
}