
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/GPX/central_point_model.dart';

import 'gpx_viewer_screen.dart';

class CentralPointsTestScreen extends StatefulWidget {
  const CentralPointsTestScreen({super.key});

  @override
  State<CentralPointsTestScreen> createState() => _CentralPointsTestScreenState();
}

class _CentralPointsTestScreenState extends State<CentralPointsTestScreen> {
  // ✅ YEH NAYA OBSERVABLE ADD KARO - StatefulWidget mein
  final isProcessing = false.obs;

  @override
  Widget build(BuildContext context) {
    final LocationViewModel locationVM = Get.find<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title:const Text('Central Points Testing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Database Controls
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // CentralPointsTestScreen میں یہ button اضافی کریں
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GPXViewerScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child:const Text('View GPX Files'),
                    ),
                    const Text(
                      'DATABASE CONTROLS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => locationVM.fetchAllCentralPoints(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child:const Text('Refresh Data'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const  SizedBox(height: 16),

            // Central Points Actions
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const  Text(
                      'CENTRAL POINTS ACTIONS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () => locationVM.saveLocationWithCentralPoints(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child:const Text('Save with Central Points'),
                        ),

                        // ✅ YEH BUTTON UPDATE KARO
                        Obx(() => ElevatedButton(
                          onPressed: isProcessing.value ? null : () async {
                            isProcessing.value = true;
                            await locationVM.processGPXAndStoreCentralPoint();
                            isProcessing.value = false;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isProcessing.value ? Colors.grey : Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: isProcessing.value
                              ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Processing...'),
                            ],
                          )
                              :const Text('Process GPX Only'),
                        )),

                        ElevatedButton(
                          onPressed: () => locationVM.syncCentralPointsToAPI(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child:const Text('Sync to API'),
                        ),
                        ElevatedButton(
                          onPressed: () => locationVM.clearAllCentralPoints(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child:const Text('Clear All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics
            Obx(() => Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'STATISTICS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total Points',
                          locationVM.allCentralPoints.length.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Unposted',
                          '${locationVM.getUnpostedCentralPointsCount()}',
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Clusters',
                          locationVM.clusterCenters.length.toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),

            const  SizedBox(height: 16),

            // Central Points List
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const   Text(
                        'CENTRAL POINTS LIST',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const  SizedBox(height: 10),
                      Expanded(
                        child: Obx(() {
                          if (locationVM.allCentralPoints.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No Central Points Found',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap "Save with Central Points" to create',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: locationVM.allCentralPoints.length,
                            itemBuilder: (context, index) {
                              CentralPointsModel point = locationVM.allCentralPoints[index];
                              return _buildCentralPointCard(point, index);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Quick Actions
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => locationVM.saveLocationWithCentralPoints(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            heroTag: "save_central",
            child:const Icon(Icons.save),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => locationVM.syncCentralPointsToAPI(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            heroTag: "sync_api",
            child:const Icon(Icons.cloud_upload),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding:const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const  SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCentralPointCard(CentralPointsModel point, int index) {
    return Card(
      margin:const EdgeInsets.symmetric(vertical: 4),
      // color: point.posted == 1 ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    point.centralPointId ?? 'No ID',
                    style:const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // color: point.posted == 1 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // child: Text(
                  //   // point.posted == 1 ? 'POSTED' : 'PENDING',
                  //   // style: TextStyle(
                  //   //   color: Colors.white,
                  //   //   fontSize: 10,
                  //   //   fontWeight: FontWeight.bold,
                  //   // ),
                  // ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Booker Name and Processing Date
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  point.bookerName ?? 'No Name',
                  style:const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const  SizedBox(width: 4),
                Text(
                  point.processingDate ?? 'No Date',
                  style:const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Coordinates
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${point.overallCenterLat?.toStringAsFixed(6) ?? 'N/A'}, '
                        '${point.overallCenterLng?.toStringAsFixed(6) ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Clusters and Points Count
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: Colors.purple),
                const  SizedBox(width: 4),
                Text('Clusters: ${point.totalClusters ?? 0}'),
                const SizedBox(width: 16),
                const Icon(Icons.place, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('Points: ${point.totalCoordinates ?? 0}'),
              ],
            ),
            const SizedBox(height: 8),

            // NEW FIELDS: Cluster Area, Address, and Stay Time
            if (point.clusterArea != null) ...[
              Row(
                children: [
                  const Icon(Icons.area_chart, size: 14, color: Colors.teal),
                  SizedBox(width: 4),
                  Text(
                    'Area: ${point.clusterArea}',
                    style: TextStyle(fontSize: 12, color: Colors.teal),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],

            if (point.addressDistrict != null && point.addressDistrict!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_city, size: 14, color: Colors.indigo),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Address: ${point.addressDistrict}',
                      style: TextStyle(fontSize: 12, color: Colors.indigo),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],

            // screen.dart mein _buildCentralPointCard method mein
            if (point.stayTimeInCluster != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Stay Time: ${point.stayTimeInCluster!.toStringAsFixed(2)} min',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],

            // Created At
            if (point.createdAt != null)
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Created: ${_formatDateTime(point.createdAt!)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),

            // Additional Info Section
            if (point.clusterArea != null || point.addressDistrict != null || point.stayTimeInCluster != null)
              Divider(height: 16, thickness: 1),

            // Enhanced Statistics
            if (point.totalClusters != null && point.totalClusters! > 0)
              _buildEnhancedStats(point),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStats(CentralPointsModel point) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cluster Analysis:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            if (point.totalClusters != null)
              _buildMiniStat('Clusters', point.totalClusters.toString(), Icons.category),
            if (point.totalCoordinates != null)
              _buildMiniStat('Points', point.totalCoordinates.toString(), Icons.place),
            if (point.stayTimeInCluster != null && point.stayTimeInCluster! > 0)
              _buildMiniStat('Total Time', '${point.stayTimeInCluster!.toStringAsFixed(1)}m', Icons.timer),
            if (point.clusterArea != null)
              _buildMiniStat('Total Area', point.clusterArea!, Icons.area_chart),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueGrey),
          SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${DateFormat('MMM dd').format(dateTime)} at ${DateFormat('HH:mm').format(dateTime)}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}

