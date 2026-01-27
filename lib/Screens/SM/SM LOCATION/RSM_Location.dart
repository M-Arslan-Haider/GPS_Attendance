import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_booking_app/Databases/util.dart';

Future<Map<String, LatLng>> fetchRSMMarkers() async {
  Map<String, LatLng> markers = {};
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('location')
      .where('designation', whereIn: ['RSM'])
      .where('SM_ID', whereIn: [user_id])
      .get();

  for (var doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    markers[data['name']] = LatLng(data['latitude'], data['longitude']);
  }

  return markers;
}

class RSMLocation extends StatefulWidget {
  const RSMLocation({super.key});

  @override
  _RSMLocationState createState() => _RSMLocationState();
}

class _RSMLocationState extends State<RSMLocation> {
  late GoogleMapController mapController;
  Map<String, LatLng> _markers = {};
  LatLng _initialCameraPosition = const LatLng(24.8607, 67.0011);
  String? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    Map<String, LatLng> fetchedMarkers = await fetchRSMMarkers();
    setState(() {
      _markers = fetchedMarkers;
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
      setState(() {
        _selectedMarker = markerName;
      });
    }
  }

  void _fitAllMarkers() {
    if (_markers.isNotEmpty) {
      LatLng southwest = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a < b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a < b ? a : b),
      );
      LatLng northeast = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a > b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a > b ? a : b),
      );
      LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double halfScreenHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      body: Column(
        children: [Padding(
          padding: const EdgeInsets.all(16.0),
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
          // Map takes 50% of screen height
          SizedBox(
            height: 380,
            width: 380,
            child: GoogleMap(
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
          ),
          // Dropdown below the map
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Card(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     elevation: 5,
          //     child: Padding(
          //       padding: const EdgeInsets.all(12.0),
          //       child: DropdownSearch<String>(
          //         items: _markers.keys.toList(),
          //         onChanged: (String? newValue) {
          //           if (newValue != null) {
          //             _onMarkerSelected(newValue);
          //           }
          //         },
          //         selectedItem: _markers.isNotEmpty ? _markers.keys.first : null,
          //         dropdownDecoratorProps: DropDownDecoratorProps(
          //           dropdownSearchDecoration: InputDecoration(
          //             labelText: "Select Marker",
          //             prefixIcon: const Icon(Icons.location_on),
          //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //             border: OutlineInputBorder(
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //           ),
          //         ),
          //         popupProps: PopupProps.menu(
          //           showSearchBox: true,
          //           searchFieldProps: TextFieldProps(
          //             decoration: InputDecoration(
          //               hintText: "Search Marker",
          //               border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //           ),
          //           menuProps: MenuProps(
          //             elevation: 8,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Optional: Display selected marker at bottom
          if (_selectedMarker != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _selectedMarker!,
                    style: const TextStyle(fontSize: 16),
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
