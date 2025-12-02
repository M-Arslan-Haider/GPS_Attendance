// // // // // travel_data_model.dart
// // // // class TravelDataModel {
// // // //   int? id;
// // // //   String? userId;
// // // //   String? travelDate;
// // // //   String? startTime;
// // // //   String? endTime;
// // // //   String? totalTravelTime;
// // // //   double? totalTravelDistance;
// // // //   double? averageSpeed;
// // // //   String? totalWorkingTime;
// // // //   double? startLat;
// // // //   double? startLon;
// // // //   double? endLat;
// // // //   double? endLon;
// // // //   double? radius;
// // // //   String? stayTime;
// // // //
// // // //   TravelDataModel({
// // // //     this.id,
// // // //     this.userId,
// // // //     this.travelDate,
// // // //     this.startTime,
// // // //     this.endTime,
// // // //     this.totalTravelTime,
// // // //     this.totalTravelDistance,
// // // //     this.averageSpeed,
// // // //     this.totalWorkingTime,
// // // //     this.startLat,
// // // //     this.startLon,
// // // //     this.endLat,
// // // //     this.endLon,
// // // //     this.radius,
// // // //     this.stayTime,
// // // //   });
// // // //
// // // //   Map<String, dynamic> toMap() => {
// // // //     'id': id,
// // // //     'user_id': userId,
// // // //     'travel_date': travelDate,
// // // //     'start_time': startTime,
// // // //     'end_time': endTime,
// // // //     'total_travel_time': totalTravelTime,
// // // //     'total_travel_distance': totalTravelDistance,
// // // //     'average_speed': averageSpeed,
// // // //     'total_working_time': totalWorkingTime,
// // // //     'start_lat': startLat,
// // // //     'start_lon': startLon,
// // // //     'end_lat': endLat,
// // // //     'end_lon': endLon,
// // // //     'radius': radius,
// // // //     'stay_time': stayTime,
// // // //   };
// // // //
// // // //   factory TravelDataModel.fromMap(Map<String, dynamic> map) => TravelDataModel(
// // // //     id: map['id'],
// // // //     userId: map['user_id'],
// // // //     travelDate: map['travel_date'],
// // // //     startTime: map['start_time'],
// // // //     endTime: map['end_time'],
// // // //     totalTravelTime: map['total_travel_time'],
// // // //     totalTravelDistance: map['total_travel_distance'],
// // // //     averageSpeed: map['average_speed'],
// // // //     totalWorkingTime: map['total_working_time'],
// // // //     startLat: map['start_lat'],
// // // //     startLon: map['start_lon'],
// // // //     endLat: map['end_lat'],
// // // //     endLon: map['end_lon'],
// // // //     radius: map['radius'],
// // // //     stayTime: map['stay_time'],
// // // //   );
// // // // }
// // //
// // // // cluster_model.dart
// // // import '../LocatioPoints/travelTimeModel.dart';
// // //
// // // class TravelCluster {
// // //   int clusterId;
// // //   String clusterType;
// // //   double centerLat;
// // //   double centerLon;
// // //   int pointCount;
// // //   double totalDistance;
// // //   double averageSpeed;
// // //   List<TravelDataModel> points;
// // //   DateTime clusterDate;
// // //
// // //   TravelCluster({
// // //     required this.clusterId,
// // //     required this.clusterType,
// // //     required this.centerLat,
// // //     required this.centerLon,
// // //     required this.pointCount,
// // //     required this.totalDistance,
// // //     required this.averageSpeed,
// // //     required this.points,
// // //     required this.clusterDate,
// // //   });
// // //
// // //   Map<String, dynamic> toMap() {
// // //     return {
// // //       'cluster_id': clusterId,
// // //       'cluster_type': clusterType,
// // //       'center_lat': centerLat,
// // //       'center_lon': centerLon,
// // //       'point_count': pointCount,
// // //       'total_distance': totalDistance,
// // //       'average_speed': averageSpeed,
// // //       'cluster_date': clusterDate.toIso8601String(),
// // //     };
// // //   }
// // // }
// // ///cliustin
// // // travel_data_model.dart
// // class TravelDataModel {
// //   int? id;
// //   String? userId;
// //   String? travelDate;
// //   String? startTime;
// //   String? endTime;
// //   String? totalTravelTime;
// //   double? totalTravelDistance;
// //   double? averageSpeed;
// //   String? totalWorkingTime;
// //   double? startLat;
// //   double? startLon;
// //   double? endLat;
// //   double? endLon;
// //   double? radius;
// //   String? stayTime;
// //
// //   // Clustering fields
// //   int? clusterId;
// //   String? clusterType;
// //   double? clusterCenterLat;
// //   double? clusterCenterLon;
// //   int? pointsInCluster;
// //
// //   TravelDataModel({
// //     this.id,
// //     this.userId,
// //     this.travelDate,
// //     this.startTime,
// //     this.endTime,
// //     this.totalTravelTime,
// //     this.totalTravelDistance,
// //     this.averageSpeed,
// //     this.totalWorkingTime,
// //     this.startLat,
// //     this.startLon,
// //     this.endLat,
// //     this.endLon,
// //     this.radius,
// //     this.stayTime,
// //     this.clusterId,
// //     this.clusterType,
// //     this.clusterCenterLat,
// //     this.clusterCenterLon,
// //     this.pointsInCluster,
// //   });
// //
// //   Map<String, dynamic> toMap() => {
// //     'id': id,
// //     'user_id': userId,
// //     'travel_date': travelDate,
// //     'start_time': startTime,
// //     'end_time': endTime,
// //     'total_travel_time': totalTravelTime,
// //     'total_travel_distance': totalTravelDistance,
// //     'average_speed': averageSpeed,
// //     'total_working_time': totalWorkingTime,
// //     'start_lat': startLat,
// //     'start_lon': startLon,
// //     'end_lat': endLat,
// //     'end_lon': endLon,
// //     'radius': radius,
// //     'stay_time': stayTime,
// //     'cluster_id': clusterId,
// //     'cluster_type': clusterType,
// //     'cluster_center_lat': clusterCenterLat,
// //     'cluster_center_lon': clusterCenterLon,
// //     'points_in_cluster': pointsInCluster,
// //   };
// //
// //   factory TravelDataModel.fromMap(Map<String, dynamic> map) => TravelDataModel(
// //     id: map['id'],
// //     userId: map['user_id'],
// //     travelDate: map['travel_date'],
// //     startTime: map['start_time'],
// //     endTime: map['end_time'],
// //     totalTravelTime: map['total_travel_time'],
// //     totalTravelDistance: map['total_travel_distance'],
// //     averageSpeed: map['average_speed'],
// //     totalWorkingTime: map['total_working_time'],
// //     startLat: map['start_lat'],
// //     startLon: map['start_lon'],
// //     endLat: map['end_lat'],
// //     endLon: map['end_lon'],
// //     radius: map['radius'],
// //     stayTime: map['stay_time'],
// //     clusterId: map['cluster_id'],
// //     clusterType: map['cluster_type'],
// //     clusterCenterLat: map['cluster_center_lat'],
// //     clusterCenterLon: map['cluster_center_lon'],
// //     pointsInCluster: map['points_in_cluster'],
// //   );
// // }
//
// ///clusting
// // travel_data_model.dart
// class TravelDataModel {
//   int? id;
//   String? userId;
//   String? travelDate;
//   String? startTime;
//   String? endTime;
//   String? totalTravelTime;
//   double? totalTravelDistance;
//   double? averageSpeed;
//   String? totalWorkingTime;
//   double? startLat;
//   double? startLon;
//   double? endLat;
//   double? endLon;
//   double? radius;
//   String? stayTime;
//
//   // Clustering fields
//   int? clusterId;
//   String? clusterType;
//   double? clusterCenterLat;
//   double? clusterCenterLon;
//   int? pointsInCluster;
//
//   TravelDataModel({
//     this.id,
//     this.userId,
//     this.travelDate,
//     this.startTime,
//     this.endTime,
//     this.totalTravelTime,
//     this.totalTravelDistance,
//     this.averageSpeed,
//     this.totalWorkingTime,
//     this.startLat,
//     this.startLon,
//     this.endLat,
//     this.endLon,
//     this.radius,
//     this.stayTime,
//     this.clusterId,
//     this.clusterType,
//     this.clusterCenterLat,
//     this.clusterCenterLon,
//     this.pointsInCluster,
//   });
//
//   Map<String, dynamic> toMap() => {
//     'id': id,
//     'user_id': userId,
//     'travel_date': travelDate,
//     'start_time': startTime,
//     'end_time': endTime,
//     'total_travel_time': totalTravelTime,
//     'total_travel_distance': totalTravelDistance,
//     'average_speed': averageSpeed,
//     'total_working_time': totalWorkingTime,
//     'start_lat': startLat,
//     'start_lon': startLon,
//     'end_lat': endLat,
//     'end_lon': endLon,
//     'radius': radius,
//     'stay_time': stayTime,
//     'cluster_id': clusterId,
//     'cluster_type': clusterType,
//     'cluster_center_lat': clusterCenterLat,
//     'cluster_center_lon': clusterCenterLon,
//     'points_in_cluster': pointsInCluster,
//   };
//
//   factory TravelDataModel.fromMap(Map<String, dynamic> map) => TravelDataModel(
//     id: map['id'],
//     userId: map['user_id'],
//     travelDate: map['travel_date'],
//     startTime: map['start_time'],
//     endTime: map['end_time'],
//     totalTravelTime: map['total_travel_time'],
//     totalTravelDistance: map['total_travel_distance'],
//     averageSpeed: map['average_speed'],
//     totalWorkingTime: map['total_working_time'],
//     startLat: map['start_lat'],
//     startLon: map['start_lon'],
//     endLat: map['end_lat'],
//     endLon: map['end_lon'],
//     radius: map['radius'],
//     stayTime: map['stay_time'],
//     clusterId: map['cluster_id'],
//     clusterType: map['cluster_type'],
//     clusterCenterLat: map['cluster_center_lat'],
//     clusterCenterLon: map['cluster_center_lon'],
//     pointsInCluster: map['points_in_cluster'],
//   );
//
//   // Add copyWith method directly to the class
//   TravelDataModel copyWith({
//     int? id,
//     String? userId,
//     String? travelDate,
//     String? startTime,
//     String? endTime,
//     String? totalTravelTime,
//     double? totalTravelDistance,
//     double? averageSpeed,
//     String? totalWorkingTime,
//     double? startLat,
//     double? startLon,
//     double? endLat,
//     double? endLon,
//     double? radius,
//     String? stayTime,
//     int? clusterId,
//     String? clusterType,
//     double? clusterCenterLat,
//     double? clusterCenterLon,
//     int? pointsInCluster,
//   }) {
//     return TravelDataModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       travelDate: travelDate ?? this.travelDate,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       totalTravelTime: totalTravelTime ?? this.totalTravelTime,
//       totalTravelDistance: totalTravelDistance ?? this.totalTravelDistance,
//       averageSpeed: averageSpeed ?? this.averageSpeed,
//       totalWorkingTime: totalWorkingTime ?? this.totalWorkingTime,
//       startLat: startLat ?? this.startLat,
//       startLon: startLon ?? this.startLon,
//       endLat: endLat ?? this.endLat,
//       endLon: endLon ?? this.endLon,
//       radius: radius ?? this.radius,
//       stayTime: stayTime ?? this.stayTime,
//       clusterId: clusterId ?? this.clusterId,
//       clusterType: clusterType ?? this.clusterType,
//       clusterCenterLat: clusterCenterLat ?? this.clusterCenterLat,
//       clusterCenterLon: clusterCenterLon ?? this.clusterCenterLon,
//       pointsInCluster: pointsInCluster ?? this.pointsInCluster,
//     );
//   }
// }
// cluster_model.dart
class ClusterModel {
  int? id;
  String? userId;
  String? travelDate;
  String? startTime;
  String? endTime;
  String? totalTravelTime;
  double? totalTravelDistance;
  double? averageSpeed;
  String? totalWorkingTime;
  double? startLat;
  double? startLon;
  double? endLat;
  double? endLon;
  double? radius;
  String? stayTime;

  // Clustering fields
  int? clusterId;
  String? clusterType;
  double? clusterCenterLat;
  double? clusterCenterLon;
  int? pointsInCluster;

  ClusterModel({
    this.id,
    this.userId,
    this.travelDate,
    this.startTime,
    this.endTime,
    this.totalTravelTime,
    this.totalTravelDistance,
    this.averageSpeed,
    this.totalWorkingTime,
    this.startLat,
    this.startLon,
    this.endLat,
    this.endLon,
    this.radius,
    this.stayTime,
    this.clusterId,
    this.clusterType,
    this.clusterCenterLat,
    this.clusterCenterLon,
    this.pointsInCluster,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'travel_date': travelDate,
    'start_time': startTime,
    'end_time': endTime,
    'total_travel_time': totalTravelTime,
    'total_travel_distance': totalTravelDistance,
    'average_speed': averageSpeed,
    'total_working_time': totalWorkingTime,
    'start_lat': startLat,
    'start_lon': startLon,
    'end_lat': endLat,
    'end_lon': endLon,
    'radius': radius,
    'stay_time': stayTime,
    'cluster_id': clusterId,
    'cluster_type': clusterType,
    'cluster_center_lat': clusterCenterLat,
    'cluster_center_lon': clusterCenterLon,
    'points_in_cluster': pointsInCluster,
  };

  factory ClusterModel.fromMap(Map<String, dynamic> map) => ClusterModel(
    id: map['id'],
    userId: map['user_id'],
    travelDate: map['travel_date'],
    startTime: map['start_time'],
    endTime: map['end_time'],
    totalTravelTime: map['total_travel_time'],
    totalTravelDistance: map['total_travel_distance'],
    averageSpeed: map['average_speed'],
    totalWorkingTime: map['total_working_time'],
    startLat: map['start_lat'],
    startLon: map['start_lon'],
    endLat: map['end_lat'],
    endLon: map['end_lon'],
    radius: map['radius'],
    stayTime: map['stay_time'],
    clusterId: map['cluster_id'],
    clusterType: map['cluster_type'],
    clusterCenterLat: map['cluster_center_lat'],
    clusterCenterLon: map['cluster_center_lon'],
    pointsInCluster: map['points_in_cluster'],
  );

  // Add copyWith method directly to the class
  ClusterModel copyWith({
    int? id,
    String? userId,
    String? travelDate,
    String? startTime,
    String? endTime,
    String? totalTravelTime,
    double? totalTravelDistance,
    double? averageSpeed,
    String? totalWorkingTime,
    double? startLat,
    double? startLon,
    double? endLat,
    double? endLon,
    double? radius,
    String? stayTime,
    int? clusterId,
    String? clusterType,
    double? clusterCenterLat,
    double? clusterCenterLon,
    int? pointsInCluster,
  }) {
    return ClusterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      travelDate: travelDate ?? this.travelDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalTravelTime: totalTravelTime ?? this.totalTravelTime,
      totalTravelDistance: totalTravelDistance ?? this.totalTravelDistance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      totalWorkingTime: totalWorkingTime ?? this.totalWorkingTime,
      startLat: startLat ?? this.startLat,
      startLon: startLon ?? this.startLon,
      endLat: endLat ?? this.endLat,
      endLon: endLon ?? this.endLon,
      radius: radius ?? this.radius,
      stayTime: stayTime ?? this.stayTime,
      clusterId: clusterId ?? this.clusterId,
      clusterType: clusterType ?? this.clusterType,
      clusterCenterLat: clusterCenterLat ?? this.clusterCenterLat,
      clusterCenterLon: clusterCenterLon ?? this.clusterCenterLon,
      pointsInCluster: pointsInCluster ?? this.pointsInCluster,
    );
  }
}