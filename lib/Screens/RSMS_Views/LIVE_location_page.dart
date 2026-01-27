// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_search/dropdown_search.dart';
//
// import '../../Databases/util.dart';
//
// Future<Map<String, LatLng>> fetchMarkersByDesignation(List<String> designations) async {
//   Map<String, LatLng> markers = {};
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection('location')
//       .where('designation', whereIn: designations)
//       .where('RSM_ID', whereIn: [user_id])
//       .get();
//
//   for (var doc in snapshot.docs) {
//     final data = doc.data() as Map<String, dynamic>;
//     markers[data['name']] = LatLng(data['latitude'], data['longitude']);
//   }
//   return markers;
// }
//
// class LiveLocationPage extends StatefulWidget {
//   @override
//   _LiveLocationPageState createState() => _LiveLocationPageState();
// }
//
// class _LiveLocationPageState extends State<LiveLocationPage> {
//   late GoogleMapController mapController;
//   Map<String, LatLng> _markers = {};
//   final LatLng _initialCameraPosition = const LatLng(24.8607, 67.0011);
//   final List<String> designations = ['ASM', 'SO', 'SOS', 'SPO'];
//
//   Timer? _refreshTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMarkers();
//
//     // Auto refresh every 20 seconds (you can adjust)
//     _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
//       _loadMarkers();
//     });
//   }
//
//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _loadMarkers() async {
//     // Query only bookers with status = "clockedIn"
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('location')
//         .where('designation', whereIn: designations)
//         .where('RSM_ID', isEqualTo: user_id)
//         .where('status', isEqualTo: "clockedIn") // ✅ Only clockedIn
//         .get();
//
//     Map<String, LatLng> activeMarkers = {};
//     for (var doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       activeMarkers[data['name']] =
//           LatLng(data['latitude'], data['longitude']);
//     }
//
//     setState(() {
//       _markers = activeMarkers; // ✅ only clockedIn markers remain
//     });
//
//     _fitAllMarkers();
//   }
//
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     _fitAllMarkers();
//   }
//
//   void _onMarkerSelected(String markerName) {
//     LatLng? position = _markers[markerName];
//     if (position != null) {
//       mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
//     }
//   }
//
//   void _fitAllMarkers() {
//     if (_markers.isNotEmpty) {
//       LatLng southwest = LatLng(
//         _markers.values
//             .map((latlng) => latlng.latitude)
//             .reduce((a, b) => a < b ? a : b),
//         _markers.values
//             .map((latlng) => latlng.longitude)
//             .reduce((a, b) => a < b ? a : b),
//       );
//       LatLng northeast = LatLng(
//         _markers.values
//             .map((latlng) => latlng.latitude)
//             .reduce((a, b) => a > b ? a : b),
//         _markers.values
//             .map((latlng) => latlng.longitude)
//             .reduce((a, b) => a > b ? a : b),
//       );
//
//       mapController.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(southwest: southwest, northeast: northeast),
//           50,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Booker's Live Location"),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _initialCameraPosition,
//               zoom: 5.0,
//             ),
//             markers: _markers.entries.map((entry) {
//               return Marker(
//                 markerId: MarkerId(entry.key),
//                 position: entry.value,
//                 infoWindow: InfoWindow(title: entry.key),
//               );
//             }).toSet(),
//           ),
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Card(
//               elevation: 5,
//               child: DropdownSearch<String>(
//                 items: _markers.keys.toList(),
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     _onMarkerSelected(newValue);
//                   }
//                 },
//                 selectedItem: _markers.isNotEmpty ? _markers.keys.first : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _loadMarkers(); // 🔄 Manual refresh
//         },
//         backgroundColor: Colors.blueGrey,
//         child: const Icon(Icons.refresh, color: Colors.white),
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../Databases/util.dart';

Future<Map<String, LatLng>> fetchMarkersByDesignation(List<String> designations) async {
  Map<String, LatLng> markers = {};
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('location')
      .where('designation', whereIn: designations)
      .where('RSM_ID', whereIn: [user_id])
      .get();

  for (var doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    markers[data['name']] = LatLng(data['latitude'], data['longitude']);
  }
  return markers;
}

class LiveLocationPage extends StatefulWidget {
  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  late GoogleMapController mapController;
  Map<String, LatLng> _markers = {};
  final LatLng _initialCameraPosition = const LatLng(24.8607, 67.0011);
  final List<String> designations = ['ASM', 'SO', 'SOS', 'SPO'];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    Map<String, LatLng> fetchedMarkers = await fetchMarkersByDesignation(designations);
    setState(() {
      _markers = fetchedMarkers; // Update state with fetched markers
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitAllMarkers();
  }

  void _onMarkerSelected(String markerName) {
    LatLng? position = _markers[markerName];
    if (position != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _fitAllMarkers() {
    if (_markers.isNotEmpty) {
      LatLngBounds bounds;
      LatLng southwest = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a < b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a < b ? a : b),
      );
      LatLng northeast = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a > b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a > b ? a : b),
      );
      bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // Padding of 50 pixels
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booker's Live Location"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 4.0,
            ),
            markers: _markers.entries.map((entry) {
              return Marker(
                markerId: MarkerId(entry.key),
                position: entry.value,
                infoWindow: InfoWindow(title: entry.key),
              );
            }).toSet(),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownSearch<String>(
                  items: _markers.keys.toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _onMarkerSelected(newValue);
                    }
                  },
                  selectedItem: _markers.isNotEmpty ? _markers.keys.first : null,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select Marker",
                      prefixIcon: const Icon(Icons.location_on),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search Marker",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    menuProps: MenuProps(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.animateCamera(CameraUpdate.newLatLngZoom(_initialCameraPosition, 6));
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

