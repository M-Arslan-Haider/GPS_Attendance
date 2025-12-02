import 'dart:convert';
import 'package:flutter/cupertino.dart';

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
  // String? clusterData;
  // int? posted;
  String? createdAt;

  // New fields
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
    // this.posted = 0,
    this.createdAt,
    // New fields
    this.clusterArea,
    this.addressDistrict,
    this.stayTimeInCluster,
  });

  factory CentralPointsModel.fromMap(Map<String, dynamic> map) {
    return CentralPointsModel(
      id: map['id'],
      centralPointId: map['central_point_id'],
      userId: map['user_id'],
      overallCenterLat: map['overall_center_lat'],
      overallCenterLng: map['overall_center_lng'],
      totalClusters: map['total_clusters'],
      totalCoordinates: map['total_coordinates'],
      processingDate: map['processing_date'],
      bookerName: map['booker_name'],
      clusterData: map['cluster_data'],
      // posted: map['posted'],
      createdAt: map['created_at'],
      // New fields
      clusterArea: map['cluster_area'],
      addressDistrict: map['address_district'],
      stayTimeInCluster: map['stay_time_in_cluster'],
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
      // 'posted': posted,
      'created_at': createdAt,
      // New fields
      'cluster_area': clusterArea,
      'address_district': addressDistrict,
      'stay_time_in_cluster': stayTimeInCluster,
    };
  }

  // CentralPointsModel.dart mein
  Map<String, dynamic> toApiMap() {
    Map<String, dynamic> apiMap = toMap();

    // Remove local DB fields
    apiMap.remove('id');
    apiMap.remove('created_at');

    // 👉 Generate formatted date & time
    final now = DateTime.now();
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String formattedDateTime =
        "${now.day.toString().padLeft(2,'0')}-"
        "${months[now.month]}-"
        "${now.year} "
        "${now.hour.toString().padLeft(2,'0')}:"
        "${now.minute.toString().padLeft(2,'0')}:"
        "${now.second.toString().padLeft(2,'0')}";

    // 👉 Set created_at
    apiMap['created_at'] = formattedDateTime;


    // apiMap['stay_time_in_cluster'] = formattedDateTime; // ❌ YEHT LINE REMOVE KAREIN

    // Convert cluster_data to clusters for API
    if (apiMap['cluster_data'] != null) {
      try {
        apiMap['clusters'] = jsonDecode(apiMap['cluster_data']);
        apiMap.remove('cluster_data');
      } catch (e) {
        debugPrint("Error decoding cluster_data: $e");
        apiMap['clusters'] = [];
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
