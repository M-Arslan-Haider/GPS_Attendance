import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gpx/gpx.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GPXViewerScreen extends StatefulWidget {
  @override
  _GPXViewerScreenState createState() => _GPXViewerScreenState();
}

class _GPXViewerScreenState extends State<GPXViewerScreen> {
  List<LatLng> coordinates = [];
  List<Wpt> waypoints = [];
  String? selectedFilePath;
  bool isLoading = false;
  String fileContent = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPX File Viewer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _pickGPXFile,
          ),
        ],
      ),
      body: Column(
        children: [
          // File Info Card
          if (selectedFilePath != null) _buildFileInfoCard(),

          // Map and Data Tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.map), text: 'Map View'),
                      Tab(icon: Icon(Icons.list), text: 'Coordinates'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Map Tab
                        _buildMapView(),

                        // Coordinates List Tab
                        _buildCoordinatesList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickGPXFile,
        child: Icon(Icons.folder_open),
        tooltip: 'Open GPX File',
      ),
    );
  }

  Widget _buildFileInfoCard() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected File:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              selectedFilePath!.split('/').last,
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('Points: ${coordinates.length}'),
                SizedBox(width: 16),
                Icon(Icons.flag, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text('Waypoints: ${waypoints.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (coordinates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No GPX File Loaded',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the folder icon to open a GPX file',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: coordinates.isNotEmpty ? coordinates.first : LatLng(0, 0),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gpx_viewer',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: coordinates,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Start point marker
            if (coordinates.isNotEmpty)
              Marker(
                point: coordinates.first,
                width: 30,
                height: 30,
                child: Icon(Icons.play_arrow, color: Colors.green, size: 30),
              ),
            // End point marker
            if (coordinates.length > 1)
              Marker(
                point: coordinates.last,
                width: 30,
                height: 30,
                child: Icon(Icons.stop, color: Colors.red, size: 30),
              ),
            // Waypoints markers
            ...waypoints.map((waypoint) => Marker(
              point: LatLng(waypoint.lat!.toDouble(), waypoint.lon!.toDouble()),
              width: 20,
              height: 20,
              child: Icon(Icons.location_pin, color: Colors.orange, size: 20),
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinatesList() {
    if (coordinates.isEmpty) {
      return Center(
        child: Text('No coordinates to display'),
      );
    }

    return ListView.builder(
      itemCount: coordinates.length,
      itemBuilder: (context, index) {
        LatLng coord = coordinates[index];
        Wpt? waypoint = index < waypoints.length ? waypoints[index] : null;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index == 0 ? Colors.green :
              index == coordinates.length - 1 ? Colors.red : Colors.blue,
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(
              '${coord.latitude.toStringAsFixed(6)}, ${coord.longitude.toStringAsFixed(6)}',
              style: TextStyle(fontFamily: 'Monospace'),
            ),
            subtitle: waypoint?.name != null ? Text(waypoint!.name!) : null,
            trailing: Icon(
              index == 0 ? Icons.play_arrow :
              index == coordinates.length - 1 ? Icons.stop : Icons.location_on,
              color: index == 0 ? Colors.green :
              index == coordinates.length - 1 ? Colors.red : Colors.blue,
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickGPXFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          isLoading = true;
          selectedFilePath = result.files.single.path!;
        });

        await _parseGPXFile(selectedFilePath!);

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error loading file: $e');
    }
  }

  Future<void> _parseGPXFile(String filePath) async {
    try {
      File file = File(filePath);
      String gpxContent = await file.readAsString();

      Gpx gpx = GpxReader().fromString(gpxContent);

      List<LatLng> parsedCoordinates = [];
      List<Wpt> parsedWaypoints = [];

      // Extract track points
      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          for (var point in segment.trkpts) {
            if (point.lat != null && point.lon != null) {
              parsedCoordinates.add(LatLng(
                point.lat!.toDouble(),
                point.lon!.toDouble(),
              ));
            }
          }
        }
      }

      // Extract waypoints
      parsedWaypoints.addAll(gpx.wpts);

      setState(() {
        coordinates = parsedCoordinates;
        waypoints = parsedWaypoints;
        fileContent = gpxContent;
      });

      _showSuccess('GPX file loaded successfully!\n'
          'Points: ${coordinates.length}\n'
          'Waypoints: ${waypoints.length}');

    } catch (e) {
      _showError('Error parsing GPX file: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
