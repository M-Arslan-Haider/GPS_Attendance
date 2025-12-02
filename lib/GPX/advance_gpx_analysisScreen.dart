import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gpx/gpx.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:math';

class FixedGPXClusterViewer extends StatefulWidget {
  @override
  _FixedGPXClusterViewerState createState() => _FixedGPXClusterViewerState();
}

class _FixedGPXClusterViewerState extends State<FixedGPXClusterViewer> {
  List<LatLng> coordinates = [];
  String? selectedFilePath;
  bool isLoading = false;

  // Cluster variables
  Map<String, List<LatLng>> clusters = {};
  Map<String, LatLng> clusterCenters = {};
  Map<String, int> clusterPointCounts = {};
  double clusterDistance = 0.01; // 100 meters
  LatLng? mapCenter;
  double mapZoom = 13.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPX Cluster Viewer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _pickGPXFile,
          ),
          if (coordinates.isNotEmpty) IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _analyzeClusters,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading GPX File...'),
          ],
        ),
      );
    }

    if (coordinates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // File Info
        _buildFileInfoCard(),

        // Cluster Controls
        if (clusters.isNotEmpty) _buildClusterControls(),

        // Tabs
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.map), text: 'MAP VIEW'),
                    Tab(icon: Icon(Icons.analytics), text: 'CLUSTERS LIST'),
                    Tab(icon: Icon(Icons.list), text: 'POINTS LIST'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildMapView(),
                      _buildClustersListView(),
                      _buildPointsListView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickGPXFile,
            icon: Icon(Icons.folder_open),
            label: Text('Select GPX File'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfoCard() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.description, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFilePath!.split('/').last,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Points: ${coordinates.length}'),
                      SizedBox(width: 16),
                      Icon(Icons.group_work, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('Clusters: ${clusters.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterControls() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'CLUSTER SETTINGS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('CLUSTERS', clusters.length.toString(), Icons.group_work),
                _buildStatItem('MAX POINTS', _getMaxClusterPoints().toString(), Icons.leaderboard),
                _buildStatItem('TOTAL', _getTotalClusterPoints().toString(), Icons.summarize),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.settings, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cluster Radius: ${(clusterDistance * 1000).toStringAsFixed(0)} meters',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Slider(
              value: clusterDistance,
              min: 0.005,
              max: 0.05,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  clusterDistance = value;
                });
                _analyzeClusters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMapView() {
    if (coordinates.isEmpty) return _buildEmptyState();

    return FlutterMap(
      options: MapOptions(
        initialCenter: mapCenter ?? coordinates.first,
        initialZoom: mapZoom,
        onMapReady: () {
          print('🗺️ Map is ready!');
        },
      ),
      children: [
        // Base Map Tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.metaxperts.order_booking_app',
        ),

        // Original Track (Blue Line)
        PolylineLayer(
          polylines: [
            Polyline(
              points: coordinates,
              strokeWidth: 3.0,
              color: Colors.blue.withOpacity(0.6),
            ),
          ],
        ),

        // CLUSTER CIRCLES - YEH WO CHEEZ HAI JO AAP KO CHAHIYE!
        CircleLayer(
          circles: clusterCenters.entries.map((entry) {
            String clusterKey = entry.key;
            LatLng center = entry.value;
            int pointCount = clusterPointCounts[clusterKey] ?? 0;

            // Circle size based on point count
            double radius = pointCount * 0.5;

            return CircleMarker(
              point: center,
              color: _getClusterColor(pointCount).withOpacity(0.3),
              borderColor: _getClusterColor(pointCount),
              borderStrokeWidth: 2,
              radius: radius,
            );
          }).toList(),
        ),

        // CLUSTER CENTER MARKERS WITH POINT COUNTS
        MarkerLayer(
          markers: clusterCenters.entries.map((entry) {
            String clusterKey = entry.key;
            LatLng center = entry.value;
            int pointCount = clusterPointCounts[clusterKey] ?? 0;

            return Marker(
              point: center,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: _getClusterColor(pointCount),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pointCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Start and End Markers
        MarkerLayer(
          markers: [
            if (coordinates.isNotEmpty)
              Marker(
                point: coordinates.first,
                width: 30,
                height: 30,
                child: Icon(Icons.play_arrow, color: Colors.green, size: 24),
              ),
            if (coordinates.length > 1)
              Marker(
                point: coordinates.last,
                width: 30,
                height: 30,
                child: Icon(Icons.stop, color: Colors.red, size: 24),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildClustersListView() {
    if (clusters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No clusters found'),
            SizedBox(height: 8),
            Text('Tap the analyze button to find clusters'),
          ],
        ),
      );
    }

    // Sort clusters by point count (descending)
    var sortedClusters = clusters.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return ListView.builder(
      itemCount: sortedClusters.length,
      itemBuilder: (context, index) {
        var cluster = sortedClusters[index];
        String key = cluster.key;
        List<LatLng> points = cluster.value;
        LatLng center = clusterCenters[key]!;
        int count = clusterPointCounts[key]!;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: _getClusterColor(count).withOpacity(0.1),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getClusterColor(count),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            title: Text(
              'Cluster ${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count points'),
                Text(
                  '${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 10, fontFamily: 'Monospace'),
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getClusterColor(count),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () => _showClusterDetails(key, points, center, count),
          ),
        );
      },
    );
  }

  Widget _buildPointsListView() {
    return ListView.builder(
      itemCount: coordinates.length,
      itemBuilder: (context, index) {
        LatLng point = coordinates[index];
        String? clusterInfo = _getPointClusterInfo(point);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: clusterInfo != null ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
            title: Text(
              'Lat: ${point.latitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 12, fontFamily: 'Monospace'),
            ),
            subtitle: Text(
              'Lng: ${point.longitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 10, fontFamily: 'Monospace'),
            ),
            trailing: clusterInfo != null
                ? Tooltip(
              message: clusterInfo,
              child: Icon(Icons.group_work, color: Colors.red, size: 18),
            )
                : Icon(Icons.location_on, color: Colors.blue, size: 18),
          ),
        );
      },
    );
  }

  // Cluster Analysis Methods
  void _analyzeClusters() {
    if (coordinates.isEmpty) {
      _showError('No coordinates to analyze');
      return;
    }

    setState(() {
      clusters = _performClustering(coordinates, clusterDistance);
      clusterCenters = _calculateClusterCenters(clusters);
      clusterPointCounts = _calculateClusterPointCounts(clusters);
    });

    _showSuccess(
        '✅ Cluster Analysis Complete!\n'
            '• Found ${clusters.length} clusters\n'
            '• ${_getTotalClusterPoints()} points in clusters\n'
            '• Largest cluster: ${_getMaxClusterPoints()} points'
    );

    print('🔍 Cluster Analysis Results:');
    print('   Total Clusters: ${clusters.length}');
    print('   Total Points in Clusters: ${_getTotalClusterPoints()}');
    print('   Max Points in Cluster: ${_getMaxClusterPoints()}');
  }

  Map<String, List<LatLng>> _performClustering(List<LatLng> points, double threshold) {
    Map<String, List<LatLng>> resultClusters = {};

    for (var point in points) {
      bool addedToCluster = false;

      for (var clusterKey in resultClusters.keys) {
        var clusterCenter = _parseClusterKey(clusterKey);
        double distance = _calculateHaversineDistance(point, clusterCenter);

        if (distance <= threshold) {
          resultClusters[clusterKey]!.add(point);
          addedToCluster = true;
          break;
        }
      }

      if (!addedToCluster) {
        String newClusterKey = "${point.latitude},${point.longitude}";
        resultClusters[newClusterKey] = [point];
      }
    }

    return resultClusters;
  }

  Map<String, LatLng> _calculateClusterCenters(Map<String, List<LatLng>> clusters) {
    Map<String, LatLng> centers = {};

    clusters.forEach((key, points) {
      double totalLat = 0.0;
      double totalLng = 0.0;

      for (var point in points) {
        totalLat += point.latitude;
        totalLng += point.longitude;
      }

      centers[key] = LatLng(
        totalLat / points.length,
        totalLng / points.length,
      );
    });

    return centers;
  }

  Map<String, int> _calculateClusterPointCounts(Map<String, List<LatLng>> clusters) {
    Map<String, int> counts = {};
    clusters.forEach((key, points) {
      counts[key] = points.length;
    });
    return counts;
  }

  String? _getPointClusterInfo(LatLng point) {
    for (var entry in clusters.entries) {
      if (entry.value.contains(point)) {
        return 'In cluster with ${entry.value.length} points';
      }
    }
    return null;
  }

  Color _getClusterColor(int pointCount) {
    if (pointCount > 100) return Colors.red;
    if (pointCount > 50) return Colors.orange;
    if (pointCount > 20) return Colors.yellow[700]!;
    if (pointCount > 10) return Colors.green;
    return Colors.blue;
  }

  int _getMaxClusterPoints() {
    if (clusterPointCounts.isEmpty) return 0;
    return clusterPointCounts.values.reduce((a, b) => a > b ? a : b);
  }

  int _getTotalClusterPoints() {
    if (clusterPointCounts.isEmpty) return 0;
    return clusterPointCounts.values.fold(0, (sum, count) => sum + count);
  }

  void _showClusterDetails(String key, List<LatLng> points, LatLng center, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cluster Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getClusterColor(count).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(count.toString()),
                      backgroundColor: _getClusterColor(count),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text('Center Coordinates:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Lat: ${center.latitude.toStringAsFixed(6)}'),
              Text('Lng: ${center.longitude.toStringAsFixed(6)}'),
              SizedBox(height: 12),
              Text('Sample Points:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...points.take(3).map((point) => Text(
                '• ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 10, fontFamily: 'Monospace'),
              )).toList(),
              if (points.length > 3)
                Text('... and ${points.length - 3} more points'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  double _calculateHaversineDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0;
    double lat1 = point1.latitude * (pi / 180.0);
    double lon1 = point1.longitude * (pi / 180.0);
    double lat2 = point2.latitude * (pi / 180.0);
    double lon2 = point2.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  LatLng _parseClusterKey(String key) {
    var parts = key.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  // File Picking and Parsing Methods
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

      setState(() {
        coordinates = parsedCoordinates;
        mapCenter = parsedCoordinates.isNotEmpty ? parsedCoordinates.first : null;
        clusters = {};
        clusterCenters = {};
        clusterPointCounts = {};
      });

      _showSuccess('✅ GPX file loaded successfully!\n${coordinates.length} points found');

    } catch (e) {
      _showError('Error parsing GPX file: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}