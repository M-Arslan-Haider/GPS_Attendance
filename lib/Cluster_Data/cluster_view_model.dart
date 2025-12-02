// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'ClusteringService.dart';
// import 'cluster_model.dart';
// import 'cluster_repository.dart';
// import 'travel_cluster_model.dart';
//
// // Add this custom class instead of using RangeValues
// class DateRange {
//   final int startDays;
//   final int endDays;
//
//   DateRange(this.startDays, this.endDays);
// }
//
// class ClusterViewModel extends GetxController {
//   var travelDataList = <ClusterModel>[].obs;
//   var clusters = <TravelClusterModel>[].obs;
//   var isLoading = false.obs;
//   final ClusterRepository repository = ClusterRepository();
//   final ClusteringService clusteringService = ClusteringService();
//
//   // Use custom DateRange instead of RangeValues
//   var selectedDateRange = DateRange(0, 30).obs;
//   var selectedClusterTypes = <String>[].obs;
//   var minDistanceFilter = 0.0.obs;
//   var maxDistanceFilter = 100.0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeWithTestData();
//   }
//
//   Future<void> _initializeWithTestData() async {
//     print('🔄 Data initialization start...');
//     isLoading.value = true;
//
//     try {
//       // Pehle existing data check karein
//       final existingData = await repository.getAllTravelData();
//       print('📊 Existing data in database: ${existingData.length} points');
//
//       if (existingData.isEmpty) {
//         print('➕ Database empty hai, test data insert kar raha hun...');
//         await _insertSampleTestData();
//       } else {
//         print('✅ Database mein already data available hai');
//         travelDataList.value = existingData;
//       }
//
//       await fetchAllTravelData();
//
//     } catch (e) {
//       print('❌ Initialization error: $e');
//       Get.snackbar('Error', 'Data initialization failed: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _insertSampleTestData() async {
//     try {
//       print('🎯 Sample test data insert kar raha hun...');
//
//       // Sample test data - Realistic coordinates around Islamabad
//       final testPoints = [
//         // Cluster 1 - Blue Area
//         ClusterModel(
//           userId: 'user_001',
//           travelDate: '2024-01-15',
//           startTime: '09:00',
//           endTime: '09:30',
//           totalTravelTime: '30 minutes',
//           totalTravelDistance: 2.5,
//           averageSpeed: 5.0,
//           latitude: 33.6844,
//           longitude: 73.0479,
//           locationType: 'MOVEMENT',
//         ),
//         ClusterModel(
//           userId: 'user_001',
//           travelDate: '2024-01-15',
//           startTime: '09:05',
//           endTime: '09:35',
//           totalTravelTime: '30 minutes',
//           totalTravelDistance: 0.2,
//           averageSpeed: 4.0,
//           latitude: 33.6845,
//           longitude: 73.0480,
//           locationType: 'MOVEMENT',
//         ),
//         ClusterModel(
//           userId: 'user_001',
//           travelDate: '2024-01-15',
//           startTime: '09:10',
//           endTime: '09:40',
//           totalTravelTime: '30 minutes',
//           totalTravelDistance: 0.3,
//           averageSpeed: 6.0,
//           latitude: 33.6843,
//           longitude: 73.0478,
//           locationType: 'MOVEMENT',
//         ),
//
//         // Cluster 2 - F-7 Markaz
//         ClusterModel(
//           userId: 'user_002',
//           travelDate: '2024-01-15',
//           startTime: '10:00',
//           endTime: '10:45',
//           totalTravelTime: '45 minutes',
//           totalTravelDistance: 1.8,
//           averageSpeed: 2.4,
//           latitude: 33.7288,
//           longitude: 73.0934,
//           locationType: 'STAY',
//         ),
//         ClusterModel(
//           userId: 'user_002',
//           travelDate: '2024-01-15',
//           startTime: '10:15',
//           endTime: '10:50',
//           totalTravelTime: '35 minutes',
//           totalTravelDistance: 0.1,
//           averageSpeed: 0.2,
//           latitude: 33.7289,
//           longitude: 73.0935,
//           locationType: 'STAY',
//         ),
//
//         // Cluster 3 - G-11
//         ClusterModel(
//           userId: 'user_003',
//           travelDate: '2024-01-15',
//           startTime: '11:00',
//           endTime: '11:20',
//           totalTravelTime: '20 minutes',
//           totalTravelDistance: 3.2,
//           averageSpeed: 9.6,
//           latitude: 33.6881,
//           longitude: 73.0247,
//           locationType: 'MOVEMENT',
//         ),
//         ClusterModel(
//           userId: 'user_003',
//           travelDate: '2024-01-15',
//           startTime: '11:10',
//           endTime: '11:25',
//           totalTravelTime: '15 minutes',
//           totalTravelDistance: 0.4,
//           averageSpeed: 1.6,
//           latitude: 33.6882,
//           longitude: 73.0248,
//           locationType: 'MOVEMENT',
//         ),
//         ClusterModel(
//           userId: 'user_003',
//           travelDate: '2024-01-15',
//           startTime: '11:15',
//           endTime: '11:30',
//           totalTravelTime: '15 minutes',
//           totalTravelDistance: 0.3,
//           averageSpeed: 1.2,
//           latitude: 33.6880,
//           longitude: 73.0246,
//           locationType: 'MOVEMENT',
//         ),
//         ClusterModel(
//           userId: 'user_003',
//           travelDate: '2024-01-15',
//           startTime: '11:20',
//           endTime: '11:35',
//           totalTravelTime: '15 minutes',
//           totalTravelDistance: 0.2,
//           averageSpeed: 0.8,
//           latitude: 33.6883,
//           longitude: 73.0249,
//           locationType: 'MOVEMENT',
//         ),
//
//         // Single points - Bahria Town
//         ClusterModel(
//           userId: 'user_004',
//           travelDate: '2024-01-15',
//           startTime: '14:00',
//           endTime: '14:30',
//           totalTravelTime: '30 minutes',
//           totalTravelDistance: 8.5,
//           averageSpeed: 17.0,
//           latitude: 33.5922,
//           longitude: 73.1234,
//           locationType: 'MOVEMENT',
//         ),
//
//         // Single point - DHA
//         ClusterModel(
//           userId: 'user_005',
//           travelDate: '2024-01-15',
//           startTime: '15:00',
//           endTime: '15:45',
//           totalTravelTime: '45 minutes',
//           totalTravelDistance: 5.2,
//           averageSpeed: 6.9,
//           latitude: 33.6678,
//           longitude: 73.1567,
//           locationType: 'MOVEMENT',
//         ),
//       ];
//
//       // Sabhi test points insert karein
//       int successCount = 0;
//       for (var point in testPoints) {
//         try {
//           await repository.insertTravelData(point);
//           successCount++;
//           print('✅ Point inserted: (${point.latitude}, ${point.longitude})');
//         } catch (e) {
//           print('❌ Point insert failed: $e');
//         }
//       }
//
//       print('🎉 Total ${successCount}/${testPoints.length} test points successfully insert hue');
//
//     } catch (e) {
//       print('❌ Test data insertion failed: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> fetchAllTravelData() async {
//     isLoading.value = true;
//     try {
//       travelDataList.value = await repository.getAllTravelData();
//       print('✅ Database se ${travelDataList.value.length} points fetch hue');
//
//       // Debug: Check kya data aa raha hai
//       if (travelDataList.isNotEmpty) {
//         print('📋 === FETCHED POINTS DETAILS ===');
//         for (var i = 0; i < travelDataList.value.length; i++) {
//           final point = travelDataList.value[i];
//           print('${i + 1}. ID: ${point.id} | '
//               'User: ${point.userId} | '
//               'Location: (${point.latitude?.toStringAsFixed(6)}, ${point.longitude?.toStringAsFixed(6)}) | '
//               'Time: ${point.startTime} | '
//               'Type: ${point.locationType}');
//         }
//         print('=== END FETCHED POINTS ===');
//       } else {
//         print('❌ Koi data fetch nahi hua');
//       }
//
//       await performClustering();
//     } catch (e) {
//       print('❌ Database fetch error: $e');
//       Get.snackbar('Error', 'Failed to fetch travel data: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> performClustering() async {
//     print('🔄 Clustering start ho raha hai...');
//     try {
//       final filteredData = _filterData(travelDataList);
//       print('🎯 Filtered data for clustering: ${filteredData.length} points');
//
//       final newClusters = clusteringService.performDBSCANClustering(filteredData);
//
//       clusters.value = newClusters;
//       print('✅ Clustering complete: ${newClusters.length} clusters bane');
//
//       // Update travel data with cluster information
//       _updateTravelDataWithClusters(newClusters);
//
//     } catch (e) {
//       print('❌ Clustering failed: $e');
//       Get.snackbar('Error', 'Clustering failed: $e');
//     }
//   }
//
//   List<ClusterModel> _filterData(List<ClusterModel> data) {
//     return data.where((point) {
//       // Date range filter
//       final pointDate = _parseDate(point.travelDate);
//       if (pointDate != null) {
//         final daysAgo = DateTime.now().difference(pointDate).inDays;
//         if (daysAgo < selectedDateRange.value.startDays ||
//             daysAgo > selectedDateRange.value.endDays) {
//           return false;
//         }
//       }
//
//       // Distance filter
//       final distance = point.totalTravelDistance ?? 0.0;
//       if (distance < minDistanceFilter.value || distance > maxDistanceFilter.value) {
//         return false;
//       }
//
//       return true;
//     }).toList();
//   }
//
//   void _updateTravelDataWithClusters(List<TravelClusterModel> clusters) {
//     print('🔄 Travel data ko clusters se update kar raha hun...');
//     int updateCount = 0;
//
//     for (final cluster in clusters) {
//       for (final point in cluster.points) {
//         final index = travelDataList.indexWhere((p) => p.id == point.id);
//         if (index != -1) {
//           travelDataList[index] = travelDataList[index].copyWith(
//             clusterId: cluster.clusterId,
//             clusterType: cluster.clusterType,
//             clusterCenterLat: cluster.centerLat,
//             clusterCenterLon: cluster.centerLon,
//             pointsInCluster: cluster.pointCount,
//           );
//           updateCount++;
//         }
//       }
//     }
//
//     print('✅ Total $updateCount points cluster information se update hue');
//   }
//
//   // Update date range
//   void updateDateRange(int startDays, int endDays) {
//     selectedDateRange.value = DateRange(startDays, endDays);
//     performClustering();
//   }
//
//   // Update distance filter
//   void updateDistanceFilter(double min, double max) {
//     minDistanceFilter.value = min;
//     maxDistanceFilter.value = max;
//     performClustering();
//   }
//
//   // Update cluster types filter
//   void updateClusterTypes(List<String> types) {
//     selectedClusterTypes.value = types;
//   }
//
//   // Get statistics
//   Map<String, dynamic> getClusterStatistics() {
//     final totalClusters = clusters.length;
//     final totalPoints = clusters.fold<int>(0, (sum, cluster) => sum + cluster.pointCount);
//     final averageClusterSize = totalClusters > 0 ? totalPoints / totalClusters : 0;
//
//     final hotspotClusters = clusters.where((c) => c.clusterType == 'HIGH_ACTIVITY_ZONE').length;
//     final frequentClusters = clusters.where((c) => c.clusterType == 'MOVEMENT_CORRIDOR').length;
//     final stayClusters = clusters.where((c) => c.clusterType == 'STAY_POINT').length;
//
//     return {
//       'totalClusters': totalClusters,
//       'totalPoints': totalPoints,
//       'averageClusterSize': averageClusterSize.toStringAsFixed(2),
//       'hotspotClusters': hotspotClusters,
//       'frequentClusters': frequentClusters,
//       'stayClusters': stayClusters,
//     };
//   }
//
//   // Filter clusters by type
//   List<TravelClusterModel> getFilteredClusters() {
//     if (selectedClusterTypes.isEmpty) return clusters;
//
//     return clusters.where((cluster) =>
//         selectedClusterTypes.contains(cluster.clusterType)
//     ).toList();
//   }
//
//   Future<void> addTravelData(ClusterModel data) async {
//     await repository.insertTravelData(data);
//     await fetchAllTravelData();
//   }
//
//   Future<void> updateTravelData(ClusterModel data) async {
//     await repository.updateTravelData(data);
//     await fetchAllTravelData();
//   }
//
//   Future<void> deleteTravelData(int id) async {
//     await repository.deleteTravelData(id);
//     await fetchAllTravelData();
//   }
//
//   // Manual test data reset function
//   Future<void> resetWithTestData() async {
//     print('🔄 Manual test data reset...');
//     isLoading.value = true;
//
//     try {
//       // Pehle existing data delete karein
//       final existingData = await repository.getAllTravelData();
//       for (var point in existingData) {
//         if (point.id != null) {
//           await repository.deleteTravelData(point.id!);
//         }
//       // }
//
//       debugPrint('🗑️ Existing data delete ho gayi');
//
//       // Naye test data insert karein
//       await _insertSampleTestData();
//       await fetchAllTravelData();
//
//       Get.snackbar('Success', 'Test data reset successfully',
//           backgroundColor: Colors.green, colorText: Colors.white);
//
//     } catch (e) {
//       debugPrint('❌ Reset failed: $e');
//       Get.snackbar('Error', 'Reset failed: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
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