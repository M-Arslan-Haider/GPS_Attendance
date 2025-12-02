// // pubspec.yaml dependencies
// // google_maps_flutter: ^2.2.5
// // google_maps_flutter_cluster_manager: ^1.0.0
// // geolocator: ^10.2.1
// // get: ^4.6.5
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_cluster_manager/google_maps_flutter_cluster_manager.dart';
// import '../ViewModels/location_view_model.dart';
//
//
// class ClusterMapScreen extends StatefulWidget {
//   @override
//   _ClusterMapScreenState createState() => _ClusterMapScreenState();
// }
//
// class _ClusterMapScreenState extends State<ClusterMapScreen> {
//   final LocationViewModel locationVM = Get.put(LocationViewModel());
//   final Completer<GoogleMapController> _mapController = Completer();
//
//   late ClusterManager<LocationModel> _clusterManager;
//
//   final CameraPosition _initialCamera = CameraPosition(
//     target: LatLng(24.8607, 67.0011), // default Karachi
//     zoom: 10,
//   );
//
//   Set<Marker> markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ** Load saved locations from DB **
//     locationVM.fetchAllLocation().then((_) {
//       _clusterManager = _initClusterManager(locationVM.allLocation);
//       setState(() {}); // refresh map
//     });
//
//     // Observe changes in location list and update clusters
//     locationVM.allLocation.listen((locations) {
//       _clusterManager.setItems(locations);
//     });
//   }
//
//   ClusterManager<LocationModel> _initClusterManager(RxList<LocationModel> locations) {
//     return ClusterManager<LocationModel>(
//       locations.toList(),
//       _updateMarkers,
//       markerBuilder: _markerBuilder,
//       initialZoom: _initialCamera.zoom,
//       stopClusteringZoom: 17,
//     );
//   }
//
//   void _updateMarkers(Set<Marker> updatedMarkers) {
//     setState(() {
//       markers = updatedMarkers;
//     });
//   }
//
//   Future<Marker> Function(Cluster<LocationModel>) get _markerBuilder => (cluster) async {
//     if (cluster.isMultiple) {
//       // Cluster marker
//       return Marker(
//         markerId: MarkerId(cluster.getId()),
//         position: cluster.location,
//         infoWindow: InfoWindow(title: '${cluster.count} users here'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       );
//     } else {
//       final loc = cluster.items.first;
//       return Marker(
//         markerId: MarkerId(loc.location_id.toString()),
//         position: LatLng(
//           double.tryParse(loc.bodyLatitude ?? "0") ?? 0,
//           double.tryParse(loc.bodyLongitude ?? "0") ?? 0,
//         ),
//         infoWindow: InfoWindow(
//           title: loc.booker_name ?? "Unknown",
//           snippet: "Distance: ${loc.total_distance ?? "0"} km",
//         ),
//       );
//     }
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Cluster Map')),
//       body: GoogleMap(
//         initialCameraPosition: _initialCamera,
//         markers: markers,
//         onMapCreated: (controller) {
//           _mapController.complete(controller);
//           _clusterManager.setMapId(controller.mapId);
//         },
//         onCameraMove: _clusterManager.onCameraMove,
//         onCameraIdle: _clusterManager.updateMap,
//       ),
//     );
//   }
// }
