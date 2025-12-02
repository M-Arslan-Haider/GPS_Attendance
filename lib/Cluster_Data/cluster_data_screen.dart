// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:order_booking_app/Cluster_Data/cluster_view_model.dart';
// import 'package:order_booking_app/Cluster_Data/travel_cluster_model.dart';
//
// class ClusterDataScreen extends StatefulWidget {
//   const ClusterDataScreen({super.key});
//
//   @override
//   State<ClusterDataScreen> createState() => _ClusterDataScreenState();
// }
//
// class _ClusterDataScreenState extends State<ClusterDataScreen> {
//   final LocationViewModel locationVM = Get.put(LocationViewModel(), permanent: true);
//   final ClusterViewModel clusterVM = Get.put(ClusterViewModel(), permanent: true);
//
//   GoogleMapController? _controller;
//   Set<Marker> _movementMarkers = {};
//   Set<Circle> _clusterCircles = {};
//   StreamSubscription<QuerySnapshot>? _movementStream;
//   bool _mapInitialized = false;
//   Timer? _locationUpdateTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeFirebase();
//     _startLocationTracking();
//     _listenToMovementData();
//   }
//
//   /// 🔹 Initialize Firebase connection
//   Future<void> _initializeFirebase() async {
//     try {
//       await Firebase.initializeApp(
//         options: const FirebaseOptions(
//           apiKey: "AIzaSyA8uucF_ZuwxXOkYhoQgDCD3FEURkTcxSY",
//           authDomain: "bookit-438707.firebaseapp.com",
//           projectId: "bookit-438707",
//           storageBucket: "bookit-438707.firebasestorage.app",
//           messagingSenderId: "102485570520",
//           appId: "1:102485570520:android:42481db59a893709b738ad",
//         ),
//       );
//       debugPrint("✅ Firebase initialized successfully");
//     } catch (e) {
//       debugPrint("⚠ Firebase initialization error: $e");
//     }
//   }
//
//   /// 🔹 Start continuous location tracking
//   void _startLocationTracking() {
//     // Save initial location
//     locationVM.saveCurrentLocation();
//
//     // Update location every 30 seconds
//     _locationUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
//       locationVM.saveCurrentLocation();
//       clusterVM.performClustering();
//     });
//   }
//
//   /// 🔹 Listen to movement data from Firebase
//   void _listenToMovementData() {
//     _movementStream = FirebaseFirestore.instance
//         .collection('movement_data') // New collection for movement data
//         .snapshots()
//         .listen((snapshot) {
//       _updateMovementMarkers(snapshot);
//       clusterVM.performClustering(); // Re-cluster when new data arrives
//     });
//   }
//
//   /// 🔹 Update movement markers on map
//   void _updateMovementMarkers(QuerySnapshot snapshot) {
//     final Set<Marker> updatedMarkers = {};
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       if (data.containsKey('latitude') && data.containsKey('longitude')) {
//
//         final markerColor = _getMarkerColor(data['location_type'] ?? 'MOVEMENT');
//
//         updatedMarkers.add(
//           Marker(
//             markerId: MarkerId(doc.id),
//             position: LatLng(data['latitude'], data['longitude']),
//             infoWindow: InfoWindow(
//               title: 'User: ${data['user_id'] ?? 'Unknown'}',
//               snippet: 'Type: ${data['location_type'] ?? 'Movement'}\n'
//                   'Time: ${data['start_time'] ?? 'N/A'}',
//             ),
//             icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
//           ),
//         );
//       }
//     }
//
//     setState(() => _movementMarkers = updatedMarkers);
//   }
//
//   /// 🔹 Get marker color based on location type
//   double _getMarkerColor(String locationType) {
//     switch (locationType) {
//       case 'STAY':
//         return BitmapDescriptor.hueBlue;
//       case 'CLOCK_IN':
//         return BitmapDescriptor.hueGreen;
//       case 'CLOCK_OUT':
//         return BitmapDescriptor.hueRed;
//       case 'MOVEMENT':
//       default:
//         return BitmapDescriptor.hueOrange;
//     }
//   }
//
//   /// 🔹 Build cluster circles
//   void _buildClusterCircles(List<TravelClusterModel> clusters) {
//     final Set<Circle> circles = {};
//
//     for (final cluster in clusters) {
//       final circleColor = _getClusterColor(cluster.clusterType);
//
//       circles.add(
//         Circle(
//           circleId: CircleId("cluster_${cluster.clusterId}"),
//           center: LatLng(cluster.centerLat, cluster.centerLon),
//           radius: cluster.pointCount * 100.0, // Radius based on cluster size
//           fillColor: circleColor.withOpacity(0.3),
//           strokeColor: circleColor,
//           strokeWidth: 2,
//         ),
//       );
//     }
//
//     setState(() => _clusterCircles = circles);
//   }
//
//   /// 🔹 Get cluster circle color based on type
//   Color _getClusterColor(String clusterType) {
//     switch (clusterType) {
//       case 'HIGH_ACTIVITY_ZONE':
//         return Colors.red;
//       case 'MOVEMENT_CORRIDOR':
//         return Colors.orange;
//       case 'ROUTE_SEGMENT':
//         return Colors.yellow;
//       case 'STAY_POINT':
//         return Colors.blue;
//       default:
//         return Colors.green;
//     }
//   }
//
//   @override
//   void dispose() {
//     _movementStream?.cancel();
//     _locationUpdateTimer?.cancel();
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   /// 🔹 Build the Google Map
//   Widget _buildMap() {
//     return Obx(() {
//       final liveLat = locationVM.globalLatitude1.value;
//       final liveLon = locationVM.globalLongitude1.value;
//       final clusters = clusterVM.clusters;
//
//       // Build cluster circles when clusters update
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _buildClusterCircles(clusters);
//       });
//
//       final Set<Marker> allMarkers = {..._movementMarkers};
//
//       // 🟢 Add Live Marker for current user
//       if (liveLat != 0.0 && liveLon != 0.0) {
//         allMarkers.add(
//           Marker(
//             markerId: const MarkerId('live_location'),
//             position: LatLng(liveLat, liveLon),
//             infoWindow: const InfoWindow(title: 'My Live Location'),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//           ),
//         );
//       }
//
//       // Add cluster center markers
//       for (final cluster in clusters) {
//         allMarkers.add(
//           Marker(
//             markerId: MarkerId('cluster_${cluster.clusterId}'),
//             position: LatLng(cluster.centerLat, cluster.centerLon),
//             infoWindow: InfoWindow(
//               title: 'Cluster ${cluster.clusterType}',
//               snippet: 'Points: ${cluster.pointCount}\n'
//                   'Type: ${cluster.locationType}',
//             ),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
//           ),
//         );
//       }
//
//       return GoogleMap(
//         mapType: MapType.normal,
//         markers: allMarkers,
//         circles: _clusterCircles,
//         zoomControlsEnabled: true,
//         zoomGesturesEnabled: true,
//         initialCameraPosition: CameraPosition(
//           target: liveLat != 0.0 && liveLon != 0.0
//               ? LatLng(liveLat, liveLon)
//               : const LatLng(33.6844, 73.0479), // Default to Islamabad
//           zoom: 12,
//         ),
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//           _mapInitialized = true;
//         },
//       );
//     });
//   }
//
//   /// 🔹 AppBar actions
//   List<Widget> _buildAppBarActions() {
//     return [
//       IconButton(
//         icon: const Icon(Icons.refresh),
//         tooltip: "Refresh Data",
//         onPressed: () {
//           locationVM.saveCurrentLocation();
//           clusterVM.performClustering();
//           Get.snackbar('Data Refreshed', 'Movement data & clusters updated',
//               backgroundColor: Colors.green, colorText: Colors.white);
//         },
//       ),
//       IconButton(
//         icon: const Icon(Icons.my_location),
//         tooltip: "Go to My Location",
//         onPressed: () async {
//           final lat = locationVM.globalLatitude1.value;
//           final lon = locationVM.globalLongitude1.value;
//           if (_controller != null && lat != 0.0 && lon != 0.0) {
//             await _controller!.animateCamera(
//               CameraUpdate.newCameraPosition(
//                 CameraPosition(target: LatLng(lat, lon), zoom: 14),
//               ),
//             );
//           }
//         },
//       ),
//       PopupMenuButton<String>(
//         onSelected: (value) {
//           _handleClusterFilter(value);
//         },
//         itemBuilder: (BuildContext context) => [
//           const PopupMenuItem(value: 'all', child: Text('Show All')),
//           const PopupMenuItem(value: 'high_activity', child: Text('High Activity Zones')),
//           const PopupMenuItem(value: 'stay_points', child: Text('Stay Points')),
//           const PopupMenuItem(value: 'movement', child: Text('Movement Corridors')),
//         ],
//       ),
//     ];
//   }
//
//   void _handleClusterFilter(String filter) {
//     switch (filter) {
//       case 'high_activity':
//         clusterVM.updateClusterTypes(['HIGH_ACTIVITY_ZONE']);
//         break;
//       case 'stay_points':
//         clusterVM.updateClusterTypes(['STAY_POINT']);
//         break;
//       case 'movement':
//         clusterVM.updateClusterTypes(['MOVEMENT_CORRIDOR', 'ROUTE_SEGMENT']);
//         break;
//       default:
//         clusterVM.updateClusterTypes([]);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Live Movement Tracker & Clustering"),
//         backgroundColor: Colors.blue,
//         actions: _buildAppBarActions(),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(child: _buildMap()),
//             Container(
//               padding: const EdgeInsets.all(8),
//               color: Colors.blue.withOpacity(0.1),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildLegendItem(Colors.orange, "Movement"),
//                   _buildLegendItem(Colors.blue, "Stay Points"),
//                   _buildLegendItem(Colors.green, "Live Location"),
//                   _buildLegendItem(Colors.red, "High Activity"),
//                 ],
//               ),
//             ),
//             Obx(() {
//               final stats = clusterVM.getClusterStatistics();
//               return Container(
//                 padding: const EdgeInsets.all(8),
//                 color: Colors.grey[100],
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatItem('Clusters', stats['totalClusters'].toString()),
//                     _buildStatItem('Points', stats['totalPoints'].toString()),
//                     _buildStatItem('Hotspots', stats['hotspotClusters'].toString()),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(Color color, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(text, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
//
//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }
// }