// // // import 'dart:convert';
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:intl/intl.dart';
// // //
// // // class CentralPointsModel {
// // //   int? id;
// // //   String? centralPointId;
// // //   String? userId;
// // //   double? overallCenterLat;
// // //   double? overallCenterLng;
// // //   int? totalClusters;
// // //   int? totalCoordinates;
// // //   String? processingDate;
// // //   String? bookerName;
// // //   String? clusterData;
// // //   String? createdAt;
// // //   String? clusterArea;
// // //   String? addressDistrict;
// // //   double? stayTimeInCluster;
// // //
// // //   CentralPointsModel({
// // //     this.id,
// // //     this.centralPointId,
// // //     this.userId,
// // //     this.overallCenterLat,
// // //     this.overallCenterLng,
// // //     this.totalClusters,
// // //     this.totalCoordinates,
// // //     this.processingDate,
// // //     this.bookerName,
// // //     this.clusterData,
// // //     this.createdAt,
// // //     this.clusterArea,
// // //     this.addressDistrict,
// // //     this.stayTimeInCluster,
// // //   });
// // //
// // //   factory CentralPointsModel.fromMap(Map<String, dynamic> map) {
// // //     return CentralPointsModel(
// // //       id: map['id'],
// // //       centralPointId: map['central_point_id'],
// // //       userId: map['user_id'],
// // //       overallCenterLat: map['overall_center_lat']?.toDouble(),
// // //       overallCenterLng: map['overall_center_lng']?.toDouble(),
// // //       totalClusters: map['total_clusters'],
// // //       totalCoordinates: map['total_coordinates'],
// // //       processingDate: map['processing_date'],
// // //       bookerName: map['booker_name'],
// // //       clusterData: map['cluster_data'],
// // //       createdAt: map['created_at'],
// // //       clusterArea: map['cluster_area'],
// // //       addressDistrict: map['address_district'],
// // //       stayTimeInCluster: map['stay_time_in_cluster']?.toDouble(),
// // //     );
// // //   }
// // //
// // //   Map<String, dynamic> toMap() {
// // //     return {
// // //       'id': id,
// // //       'central_point_id': centralPointId,
// // //       'user_id': userId,
// // //       'overall_center_lat': overallCenterLat,
// // //       'overall_center_lng': overallCenterLng,
// // //       'total_clusters': totalClusters,
// // //       'total_coordinates': totalCoordinates,
// // //       'processing_date': processingDate,
// // //       'booker_name': bookerName,
// // //       'cluster_data': clusterData,
// // //       'created_at': createdAt,
// // //       'cluster_area': clusterArea,
// // //       'address_district': addressDistrict,
// // //       'stay_time_in_cluster': stayTimeInCluster,
// // //     };
// // //   }
// // //
// // //   // Method to create INDIVIDUAL CLUSTER record with intelligent detection info
// // //   CentralPointsModel.createIndividualCluster({
// // //     required String mainCentralPointId,
// // //     required String userId,
// // //     required String userName,
// // //     required String processingDate,
// // //     required double overallCenterLat,
// // //     required double overallCenterLng,
// // //     required int totalClusters,
// // //     required int totalCoordinates,
// // //     required String clusterId,
// // //     required String clusterAddress, // Pure address without intelligent info
// // //     required double clusterLat,
// // //     required double clusterLng,
// // //     required int clusterPointsCount,
// // //     required double clusterStayTime,
// // //     required double clusterArea,
// // //     required double clusterDistance,
// // //   }) {
// // //     // Create enhanced address with intelligent detection info for cluster_data only
// // //     String intelligentAddress = """
// // // ${clusterAddress}
// // //
// // // === INTELLIGENT CLUSTER DETECTION ===
// // // Cluster Radius: ${clusterDistance.toStringAsFixed(0)} meters
// // // Detection Method: Repeated Movement Confirmation
// // // Minimum Points Required: 3
// // // Minimum Time Required: 2 minutes
// // // Status: Confirmed Cluster
// // // Created At: ${DateTime.now().toString()}
// // // Intelligent Detection: ENABLED
// // // """;
// // //
// // //     // Create single cluster data with intelligence info (for cluster_data field)
// // //     Map<String, dynamic> singleClusterData = {
// // //       'cluster_id': clusterId,
// // //       'cluster_address': intelligentAddress, // Intelligent address goes here
// // //       'cluster_lat': clusterLat,
// // //       'cluster_lng': clusterLng,
// // //       'cluster_points_count': clusterPointsCount,
// // //       'cluster_stay_time': clusterStayTime,
// // //       'cluster_area': clusterArea,
// // //       'cluster_intelligence': 'repeated_movement_detected',
// // //       'cluster_radius_meters': clusterDistance,
// // //       'detection_criteria_met': true,
// // //       'min_points_required': 3,
// // //       'min_time_required_minutes': 2,
// // //     };
// // //
// // //     // Set fields for INDIVIDUAL cluster record
// // //     this.centralPointId = clusterId;
// // //     this.userId = userId;
// // //     this.overallCenterLat = overallCenterLat;
// // //     this.overallCenterLng = overallCenterLng;
// // //     this.totalClusters = totalClusters;
// // //     this.totalCoordinates = totalCoordinates;
// // //     this.processingDate = processingDate;
// // //     this.bookerName = userName;
// // //
// // //     // Store SINGLE cluster data as JSON array string (with intelligent address)
// // //     this.clusterData = jsonEncode([singleClusterData]);
// // //
// // //     this.createdAt = DateTime.now().toIso8601String();
// // //     this.clusterArea = "${clusterArea.toStringAsFixed(6)} sq km";
// // //
// // //     // IMPORTANT: Store ONLY THE PURE ADDRESS (without intelligent info) in addressDistrict
// // //     // This is what will be sent to backend in the address_district field
// // //     this.addressDistrict = clusterAddress;
// // //
// // //     this.stayTimeInCluster = clusterStayTime;
// // //   }
// // //
// // //   Map<String, dynamic> toApiMap() {
// // //     Map<String, dynamic> apiMap = Map<String, dynamic>.from(toMap());
// // //
// // //     apiMap.remove('id');
// // //
// // //     final now = DateTime.now();
// // //     String formattedDateTime = DateFormat("dd-MMM-yyyy HH:mm:ss").format(now);
// // //     apiMap['created_at'] = formattedDateTime;
// // //
// // //     // Ensure cluster_data is a JSON ARRAY string
// // //     if (apiMap['cluster_data'] != null) {
// // //       try {
// // //         dynamic clusterData = apiMap['cluster_data'];
// // //
// // //         if (clusterData is String) {
// // //           dynamic parsed = jsonDecode(clusterData);
// // //
// // //           if (parsed is List) {
// // //             apiMap['cluster_data'] = jsonEncode(parsed);
// // //           } else if (parsed is Map) {
// // //             apiMap['cluster_data'] = jsonEncode([parsed]);
// // //           } else {
// // //             apiMap['cluster_data'] = jsonEncode([]);
// // //           }
// // //         } else if (clusterData is List) {
// // //           apiMap['cluster_data'] = jsonEncode(clusterData);
// // //         } else if (clusterData is Map) {
// // //           apiMap['cluster_data'] = jsonEncode([clusterData]);
// // //         } else {
// // //           apiMap['cluster_data'] = jsonEncode([]);
// // //         }
// // //
// // //       } catch (e) {
// // //         debugPrint("❌ Error normalizing cluster_data for API: $e");
// // //         apiMap['cluster_data'] = jsonEncode([]);
// // //       }
// // //     } else {
// // //       apiMap['cluster_data'] = jsonEncode([]);
// // //     }
// // //
// // //     // Debug: Check what's being sent to backend
// // //     debugPrint("📤 API Payload Debug:");
// // //     debugPrint("   address_district (pure address): ${apiMap['address_district']}");
// // //
// // //     if (apiMap['cluster_data'] != null && apiMap['cluster_data'] is String) {
// // //       try {
// // //         var clusterData = jsonDecode(apiMap['cluster_data'] as String);
// // //         if (clusterData is List && clusterData.isNotEmpty) {
// // //           debugPrint("   First cluster address in cluster_data: ${clusterData[0]['cluster_address']?.toString().split('\n').first}");
// // //         }
// // //       } catch (e) {
// // //         debugPrint("   Error parsing cluster_data for debug: $e");
// // //       }
// // //     }
// // //
// // //     return apiMap;
// // //   }
// // //
// // //   String toJson() {
// // //     return jsonEncode(toMap());
// // //   }
// // //
// // //   String toApiJson() {
// // //     return jsonEncode(toApiMap());
// // //   }
// // //
// // //   factory CentralPointsModel.fromJson(String json) {
// // //     return CentralPointsModel.fromMap(jsonDecode(json));
// // //   }
// // // }
// //
// // // Modified central_point_model.dart (only small change: createIndividualCluster accepts createdAt)
// // import 'dart:convert';
// // import 'package:flutter/cupertino.dart';
// // import 'package:intl/intl.dart';
// //
// // class CentralPointsModel {
// //   int? id;
// //   String? centralPointId;
// //   String? userId;
// //   double? overallCenterLat;
// //   double? overallCenterLng;
// //   int? totalClusters;
// //   int? totalCoordinates;
// //   String? processingDate;
// //   String? bookerName;
// //   String? clusterData;
// //   String? createdAt;
// //   String? clusterArea;
// //   String? addressDistrict;
// //   double? stayTimeInCluster;
// //
// //   CentralPointsModel({
// //     this.id,
// //     this.centralPointId,
// //     this.userId,
// //     this.overallCenterLat,
// //     this.overallCenterLng,
// //     this.totalClusters,
// //     this.totalCoordinates,
// //     this.processingDate,
// //     this.bookerName,
// //     this.clusterData,
// //     this.createdAt,
// //     this.clusterArea,
// //     this.addressDistrict,
// //     this.stayTimeInCluster,
// //   });
// //
// //   factory CentralPointsModel.fromMap(Map<String, dynamic> map) {
// //     return CentralPointsModel(
// //       id: map['id'],
// //       centralPointId: map['central_point_id'],
// //       userId: map['user_id'],
// //       overallCenterLat: map['overall_center_lat']?.toDouble(),
// //       overallCenterLng: map['overall_center_lng']?.toDouble(),
// //       totalClusters: map['total_clusters'],
// //       totalCoordinates: map['total_coordinates'],
// //       processingDate: map['processing_date'],
// //       bookerName: map['booker_name'],
// //       clusterData: map['cluster_data'],
// //       createdAt: map['created_at'],
// //       clusterArea: map['cluster_area'],
// //       addressDistrict: map['address_district'],
// //       stayTimeInCluster: map['stay_time_in_cluster']?.toDouble(),
// //     );
// //   }
// //
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'id': id,
// //       'central_point_id': centralPointId,
// //       'user_id': userId,
// //       'overall_center_lat': overallCenterLat,
// //       'overall_center_lng': overallCenterLng,
// //       'total_clusters': totalClusters,
// //       'total_coordinates': totalCoordinates,
// //       'processing_date': processingDate,
// //       'booker_name': bookerName,
// //       'cluster_data': clusterData,
// //       'created_at': createdAt,
// //       'cluster_area': clusterArea,
// //       'address_district': addressDistrict,
// //       'stay_time_in_cluster': stayTimeInCluster,
// //     };
// //   }
// //
// //   // Method to create INDIVIDUAL CLUSTER record with intelligent detection info
// //   // NOTE: added optional parameter clusterCreatedAt so we can set createdAt to device time when cluster was detected.
// //   CentralPointsModel.createIndividualCluster({
// //     required String mainCentralPointId,
// //     required String userId,
// //     required String userName,
// //     required String processingDate,
// //     required double overallCenterLat,
// //     required double overallCenterLng,
// //     required int totalClusters,
// //     required int totalCoordinates,
// //     required String clusterId,
// //     required String clusterAddress, // Pure address without intelligent info
// //     required double clusterLat,
// //     required double clusterLng,
// //     required int clusterPointsCount,
// //     required double clusterStayTime,
// //     required double clusterArea,
// //     required double clusterDistance,
// //     DateTime? clusterCreatedAt, // optional
// //   }) {
// //     // Create enhanced address with intelligent detection info for cluster_data only
// //     String intelligentAddress = """
// // ${clusterAddress}
// //
// // === INTELLIGENT CLUSTER DETECTION ===
// // Cluster Radius: ${clusterDistance.toStringAsFixed(0)} meters
// // Detection Method: Repeated Movement Confirmation
// // Minimum Points Required: 3
// // Minimum Time Required: 2 minutes
// // Status: Confirmed Cluster
// // Created At: ${clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String()}
// // Intelligent Detection: ENABLED
// // """;
// //
// //     // Create single cluster data with intelligence info (for cluster_data field)
// //     Map<String, dynamic> singleClusterData = {
// //       'cluster_id': clusterId,
// //       'cluster_address': intelligentAddress, // Intelligent address goes here
// //       'cluster_lat': clusterLat,
// //       'cluster_lng': clusterLng,
// //       'cluster_points_count': clusterPointsCount,
// //       'cluster_stay_time': clusterStayTime,
// //       'cluster_area': clusterArea,
// //       'cluster_intelligence': 'repeated_movement_detected',
// //       'cluster_radius_meters': clusterDistance,
// //       'detection_criteria_met': true,
// //       'min_points_required': 3,
// //       'min_time_required_minutes': 2,
// //       'created_at': clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
// //     };
// //
// //     // Set fields for INDIVIDUAL cluster record
// //     this.centralPointId = clusterId;
// //     this.userId = userId;
// //     this.overallCenterLat = overallCenterLat;
// //     this.overallCenterLng = overallCenterLng;
// //     this.totalClusters = totalClusters;
// //     this.totalCoordinates = totalCoordinates;
// //     this.processingDate = processingDate;
// //     this.bookerName = userName;
// //
// //     // Store SINGLE cluster data as JSON array string (with intelligent address)
// //     this.clusterData = jsonEncode([singleClusterData]);
// //
// //     this.createdAt = clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String();
// //     this.clusterArea = "${clusterArea.toStringAsFixed(6)} sq km";
// //
// //     // IMPORTANT: Store ONLY THE PURE ADDRESS (without intelligent info) in addressDistrict
// //     // This is what will be sent to backend in the address_district field
// //     this.addressDistrict = clusterAddress;
// //
// //     this.stayTimeInCluster = clusterStayTime;
// //   }
// //
// //   Map<String, dynamic> toApiMap() {
// //     Map<String, dynamic> apiMap = Map<String, dynamic>.from(toMap());
// //
// //     apiMap.remove('id');
// //
// //     final now = DateTime.now();
// //     String formattedDateTime = DateFormat("dd-MMM-yyyy HH:mm:ss").format(now);
// //     apiMap['created_at'] = formattedDateTime;
// //
// //     // Ensure cluster_data is a JSON ARRAY string
// //     if (apiMap['cluster_data'] != null) {
// //       try {
// //         dynamic clusterData = apiMap['cluster_data'];
// //
// //         if (clusterData is String) {
// //           dynamic parsed = jsonDecode(clusterData);
// //
// //           if (parsed is List) {
// //             apiMap['cluster_data'] = jsonEncode(parsed);
// //           } else if (parsed is Map) {
// //             apiMap['cluster_data'] = jsonEncode([parsed]);
// //           } else {
// //             apiMap['cluster_data'] = jsonEncode([]);
// //           }
// //         } else if (clusterData is List) {
// //           apiMap['cluster_data'] = jsonEncode(clusterData);
// //         } else if (clusterData is Map) {
// //           apiMap['cluster_data'] = jsonEncode([clusterData]);
// //         } else {
// //           apiMap['cluster_data'] = jsonEncode([]);
// //         }
// //
// //       } catch (e) {
// //         debugPrint("❌ Error normalizing cluster_data for API: $e");
// //         apiMap['cluster_data'] = jsonEncode([]);
// //       }
// //     } else {
// //       apiMap['cluster_data'] = jsonEncode([]);
// //     }
// //
// //     // Debug: Check what's being sent to backend
// //     debugPrint("📤 API Payload Debug:");
// //     debugPrint("   address_district (pure address): ${apiMap['address_district']}");
// //
// //     if (apiMap['cluster_data'] != null && apiMap['cluster_data'] is String) {
// //       try {
// //         var clusterData = jsonDecode(apiMap['cluster_data'] as String);
// //         if (clusterData is List && clusterData.isNotEmpty) {
// //           debugPrint("   First cluster address in cluster_data: ${clusterData[0]['cluster_address']?.toString().split('\n').first}");
// //         }
// //       } catch (e) {
// //         debugPrint("   Error parsing cluster_data for debug: $e");
// //       }
// //     }
// //
// //     return apiMap;
// //   }
// //
// //   String toJson() {
// //     return jsonEncode(toMap());
// //   }
// //
// //   String toApiJson() {
// //     return jsonEncode(toApiMap());
// //   }
// //
// //   factory CentralPointsModel.fromJson(String json) {
// //     return CentralPointsModel.fromMap(jsonDecode(json));
// //   }
// // }
//
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
//
// class CentralPointsModel {
//   int? id;
//   String? centralPointId;
//   String? userId;
//   double? overallCenterLat;
//   double? overallCenterLng;
//   int? totalClusters;
//   int? totalCoordinates;
//   String? processingDate;
//   String? bookerName;
//   String? clusterData;
//   String? createdAt;
//   String? clusterArea;
//   String? addressDistrict;
//   double? stayTimeInCluster;
//   int? posted;  // 0 = pending, 1 = posted to server
//
//   CentralPointsModel({
//     this.id,
//     this.centralPointId,
//     this.userId,
//     this.overallCenterLat,
//     this.overallCenterLng,
//     this.totalClusters,
//     this.totalCoordinates,
//     this.processingDate,
//     this.bookerName,
//     this.clusterData,
//     this.createdAt,
//     this.clusterArea,
//     this.addressDistrict,
//     this.stayTimeInCluster,
//     this.posted = 0,
//   });
//
//   factory CentralPointsModel.fromMap(Map<String, dynamic> map) {
//     return CentralPointsModel(
//       id: map['id'],
//       centralPointId: map['central_point_id'],
//       userId: map['user_id'],
//       overallCenterLat: map['overall_center_lat']?.toDouble(),
//       overallCenterLng: map['overall_center_lng']?.toDouble(),
//       totalClusters: map['total_clusters'],
//       totalCoordinates: map['total_coordinates'],
//       processingDate: map['processing_date'],
//       bookerName: map['booker_name'],
//       clusterData: map['cluster_data'],
//       createdAt: map['created_at'],
//       clusterArea: map['cluster_area'],
//       addressDistrict: map['address_district'],
//       stayTimeInCluster: map['stay_time_in_cluster']?.toDouble(),
//       posted: map['posted'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'central_point_id': centralPointId,
//       'user_id': userId,
//       'overall_center_lat': overallCenterLat,
//       'overall_center_lng': overallCenterLng,
//       'total_clusters': totalClusters,
//       'total_coordinates': totalCoordinates,
//       'processing_date': processingDate,
//       'booker_name': bookerName,
//       'cluster_data': clusterData,
//       'created_at': createdAt,
//       'cluster_area': clusterArea,
//       'address_district': addressDistrict,
//       'stay_time_in_cluster': stayTimeInCluster,
//       'posted': posted,
//     };
//   }
//
//   // Constructor for individual cluster record
//   CentralPointsModel.createIndividualCluster({
//     required String mainCentralPointId,
//     required String userId,
//     required String userName,
//     required String processingDate,
//     required double overallCenterLat,
//     required double overallCenterLng,
//     required int totalClusters,
//     required int totalCoordinates,
//     required String clusterId,
//     required String clusterAddress,
//     required double clusterLat,
//     required double clusterLng,
//     required int clusterPointsCount,
//     required double clusterStayTime,
//     required double clusterArea,
//     required double clusterDistance,
//     DateTime? clusterCreatedAt,
//   }) {
//     String intelligentAddress = """
// $clusterAddress
//
// === INTELLIGENT CLUSTER DETECTION ===
// Cluster Radius: ${clusterDistance.toStringAsFixed(0)} meters
// Detection Method: Repeated Movement Confirmation
// Minimum Points Required: 3
// Minimum Time Required: 2 minutes
// Status: Confirmed Cluster
// Created At: ${clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String()}
// Intelligent Detection: ENABLED
// """;
//
//     Map<String, dynamic> singleClusterData = {
//       'cluster_id': clusterId,
//       'cluster_address': intelligentAddress,
//       'cluster_lat': clusterLat,
//       'cluster_lng': clusterLng,
//       'cluster_points_count': clusterPointsCount,
//       'cluster_stay_time': clusterStayTime,
//       'cluster_area': clusterArea,
//       'cluster_intelligence': 'repeated_movement_detected',
//       'cluster_radius_meters': clusterDistance,
//       'detection_criteria_met': true,
//       'min_points_required': 3,
//       'min_time_required_minutes': 2,
//       'created_at': clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
//     };
//
//     this.centralPointId = clusterId;
//     this.userId = userId;
//     this.overallCenterLat = overallCenterLat;
//     this.overallCenterLng = overallCenterLng;
//     this.totalClusters = totalClusters;
//     this.totalCoordinates = totalCoordinates;
//     this.processingDate = processingDate;
//     this.bookerName = userName;
//     this.clusterData = jsonEncode([singleClusterData]);
//
//     // Store createdAt exactly as device time for the cluster creation (ISO string)
//     this.createdAt = clusterCreatedAt?.toIso8601String() ?? DateTime.now().toIso8601String();
//
//     this.clusterArea = "${clusterArea.toStringAsFixed(6)} sq km";
//     this.addressDistrict = clusterAddress;
//     this.stayTimeInCluster = clusterStayTime;
//     this.posted = 0;
//   }
//
//   Map<String, dynamic> toApiMap() {
//     Map<String, dynamic> apiMap = Map<String, dynamic>.from(toMap());
//     apiMap.remove('id');
//     apiMap.remove('posted'); // not sent to API
//
//     // Preserve the device-created createdAt (if present). Only set server-created formatted time
//     // if createdAt is missing or unparseable.
//     final now = DateTime.now();
//     String formattedNow = DateFormat("dd-MMM-yyyy HH:mm:ss").format(now);
//
//     if (apiMap['created_at'] != null && apiMap['created_at'].toString().isNotEmpty) {
//       try {
//         DateTime parsed;
//         // created_at might already be an ISO string
//         parsed = DateTime.parse(apiMap['created_at'].toString());
//         apiMap['created_at'] = DateFormat("dd-MMM-yyyy HH:mm:ss").format(parsed);
//       } catch (e) {
//         // fallback to now
//         apiMap['created_at'] = formattedNow;
//       }
//     } else {
//       apiMap['created_at'] = formattedNow;
//     }
//
//     // Ensure cluster_data is a JSON array string
//     if (apiMap['cluster_data'] != null) {
//       try {
//         dynamic cd = apiMap['cluster_data'];
//         if (cd is String) {
//           dynamic parsed = jsonDecode(cd);
//           apiMap['cluster_data'] = jsonEncode(parsed is List ? parsed : [parsed]);
//         } else if (cd is List) {
//           apiMap['cluster_data'] = jsonEncode(cd);
//         } else if (cd is Map) {
//           apiMap['cluster_data'] = jsonEncode([cd]);
//         } else {
//           apiMap['cluster_data'] = jsonEncode([]);
//         }
//       } catch (e) {
//         debugPrint("Error normalizing cluster_data: $e");
//         apiMap['cluster_data'] = jsonEncode([]);
//       }
//     } else {
//       apiMap['cluster_data'] = jsonEncode([]);
//     }
//
//     return apiMap;
//   }
//
//   String toApiJson() => jsonEncode(toApiMap());
// }


import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CentralPointsModel {
  int? id;
  String? centralPointId;
  String? userId;
  double? overallCenterLat;
  double? overallCenterLng;
  int? totalClusters;
  int? totalCoordinates;
  String? processingDate;
  String? bookerName;
  String? clusterData;
  String? createdAt;
  String? clusterArea;
  String? addressDistrict;
  double? stayTimeInCluster;

  CentralPointsModel({
    this.id,
    this.centralPointId,
    this.userId,
    this.overallCenterLat,
    this.overallCenterLng,
    this.totalClusters,
    this.totalCoordinates,
    this.processingDate,
    this.bookerName,
    this.clusterData,
    this.createdAt,
    this.clusterArea,
    this.addressDistrict,
    this.stayTimeInCluster,
  });

  factory CentralPointsModel.fromMap(Map<String, dynamic> map) {
    return CentralPointsModel(
      id: map['id'],
      centralPointId: map['central_point_id'],
      userId: map['user_id'],
      overallCenterLat: map['overall_center_lat']?.toDouble(),
      overallCenterLng: map['overall_center_lng']?.toDouble(),
      totalClusters: map['total_clusters'],
      totalCoordinates: map['total_coordinates'],
      processingDate: map['processing_date'],
      bookerName: map['booker_name'],
      clusterData: map['cluster_data'],
      createdAt: map['created_at'],
      clusterArea: map['cluster_area'],
      addressDistrict: map['address_district'],
      stayTimeInCluster: map['stay_time_in_cluster']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'central_point_id': centralPointId,
      'user_id': userId,
      'overall_center_lat': overallCenterLat,
      'overall_center_lng': overallCenterLng,
      'total_clusters': totalClusters,
      'total_coordinates': totalCoordinates,
      'processing_date': processingDate,
      'booker_name': bookerName,
      'cluster_data': clusterData,
      'created_at': createdAt,
      'cluster_area': clusterArea,
      'address_district': addressDistrict,
      'stay_time_in_cluster': stayTimeInCluster,
    };
  }

  // Method to create INDIVIDUAL CLUSTER record with intelligent detection info
  CentralPointsModel.createIndividualCluster({
    required String mainCentralPointId,
    required String userId,
    required String userName,
    required String processingDate,
    required double overallCenterLat,
    required double overallCenterLng,
    required int totalClusters,
    required int totalCoordinates,
    required String clusterId,
    required String clusterAddress, // Pure address without intelligent info
    required double clusterLat,
    required double clusterLng,
    required int clusterPointsCount,
    required double clusterStayTime,
    required double clusterArea,
    required double clusterDistance,
  }) {
    // Create enhanced address with intelligent detection info for cluster_data only
    String intelligentAddress = """
${clusterAddress}

=== INTELLIGENT CLUSTER DETECTION ===
Cluster Radius: ${clusterDistance.toStringAsFixed(0)} meters
Detection Method: Repeated Movement Confirmation
Minimum Points Required: 3
Minimum Time Required: 2 minutes
Status: Confirmed Cluster
Created At: ${DateTime.now().toString()}
Intelligent Detection: ENABLED
""";

    // Create single cluster data with intelligence info (for cluster_data field)
    Map<String, dynamic> singleClusterData = {
      'cluster_id': clusterId,
      'cluster_address': intelligentAddress, // Intelligent address goes here
      'cluster_lat': clusterLat,
      'cluster_lng': clusterLng,
      'cluster_points_count': clusterPointsCount,
      'cluster_stay_time': clusterStayTime,
      'cluster_area': clusterArea,
      'cluster_intelligence': 'repeated_movement_detected',
      'cluster_radius_meters': clusterDistance,
      'detection_criteria_met': true,
      'min_points_required': 3,
      'min_time_required_minutes': 2,
    };

    // Set fields for INDIVIDUAL cluster record
    this.centralPointId = clusterId;
    this.userId = userId;
    this.overallCenterLat = overallCenterLat;
    this.overallCenterLng = overallCenterLng;
    this.totalClusters = totalClusters;
    this.totalCoordinates = totalCoordinates;
    this.processingDate = processingDate;
    this.bookerName = userName;

    // Store SINGLE cluster data as JSON array string (with intelligent address)
    this.clusterData = jsonEncode([singleClusterData]);

    this.createdAt = DateTime.now().toIso8601String();
    this.clusterArea = "${clusterArea.toStringAsFixed(6)} sq km";

    // IMPORTANT: Store ONLY THE PURE ADDRESS (without intelligent info) in addressDistrict
    // This is what will be sent to backend in the address_district field
    this.addressDistrict = clusterAddress;

    this.stayTimeInCluster = clusterStayTime;
  }

  Map<String, dynamic> toApiMap() {
    Map<String, dynamic> apiMap = Map<String, dynamic>.from(toMap());

    apiMap.remove('id');

    final now = DateTime.now();
    String formattedDateTime = DateFormat("dd-MMM-yyyy HH:mm:ss").format(now);
    apiMap['created_at'] = formattedDateTime;

    // Ensure cluster_data is a JSON ARRAY string
    if (apiMap['cluster_data'] != null) {
      try {
        dynamic clusterData = apiMap['cluster_data'];

        if (clusterData is String) {
          dynamic parsed = jsonDecode(clusterData);

          if (parsed is List) {
            apiMap['cluster_data'] = jsonEncode(parsed);
          } else if (parsed is Map) {
            apiMap['cluster_data'] = jsonEncode([parsed]);
          } else {
            apiMap['cluster_data'] = jsonEncode([]);
          }
        } else if (clusterData is List) {
          apiMap['cluster_data'] = jsonEncode(clusterData);
        } else if (clusterData is Map) {
          apiMap['cluster_data'] = jsonEncode([clusterData]);
        } else {
          apiMap['cluster_data'] = jsonEncode([]);
        }

      } catch (e) {
        debugPrint("❌ Error normalizing cluster_data for API: $e");
        apiMap['cluster_data'] = jsonEncode([]);
      }
    } else {
      apiMap['cluster_data'] = jsonEncode([]);
    }

    // Debug: Check what's being sent to backend
    debugPrint("📤 API Payload Debug:");
    debugPrint("   address_district (pure address): ${apiMap['address_district']}");

    if (apiMap['cluster_data'] != null && apiMap['cluster_data'] is String) {
      try {
        var clusterData = jsonDecode(apiMap['cluster_data'] as String);
        if (clusterData is List && clusterData.isNotEmpty) {
          debugPrint("   First cluster address in cluster_data: ${clusterData[0]['cluster_address']?.toString().split('\n').first}");
        }
      } catch (e) {
        debugPrint("   Error parsing cluster_data for debug: $e");
      }
    }

    return apiMap;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  String toApiJson() {
    return jsonEncode(toApiMap());
  }

  factory CentralPointsModel.fromJson(String json) {
    return CentralPointsModel.fromMap(jsonDecode(json));
  }
}
