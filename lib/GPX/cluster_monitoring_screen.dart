// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
//
// class ClusterMonitoringScreen extends StatefulWidget {
//   @override
//   _ClusterMonitoringScreenState createState() => _ClusterMonitoringScreenState();
// }
//
// class _ClusterMonitoringScreenState extends State<ClusterMonitoringScreen> {
//   final LocationViewModel locationVM = Get.find<LocationViewModel>();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Intelligent Cluster Monitoring'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () => locationVM.centralPointVM.clearIntelligentDetector(),
//             tooltip: 'Clear Detector',
//           ),
//           IconButton(
//             icon: Icon(Icons.play_arrow),
//             onPressed: () => locationVM.centralPointVM.testIntelligentClustering(),
//             tooltip: 'Test Clustering',
//           ),
//         ],
//       ),
//       body: _buildMonitoringBody(),
//     );
//   }
//
//   Widget _buildMonitoringBody() {
//     var stats = locationVM.centralPointVM.getClusterDetectionStats();
//     var observedAreas = locationVM.centralPointVM.observedAreas.value;
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.smart_toy, color: Colors.blue, size: 32),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Intelligent Cluster Detection',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             Text(
//                               '50-meter radius • Repeated movement confirmation',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Clusters are ONLY created when repeated movement is detected within a 50m radius area. '
//                         'System observes user movement and waits for confirmation before creating clusters.',
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Detection Statistics',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   _buildStatRow('Confirmed Clusters', '${stats['total_clusters']}', Icons.check_circle),
//                   _buildStatRow('Observed Areas', '${stats['total_observed_areas']}', Icons.visibility),
//                   _buildStatRow('Processed Points', '${stats['total_processed_points']}', Icons.location_on),
//                   _buildStatRow('Cluster Radius', '${stats['cluster_radius_meters']}m', Icons.radar),
//                   _buildStatRow('Min Points Required', '${stats['min_points_for_cluster']}', Icons.filter_3),
//                   _buildStatRow('Min Time Required', '${stats['min_time_minutes']} min', Icons.timer),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           if (observedAreas.isNotEmpty)
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Observed Areas (Pending Confirmation)',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     ...observedAreas.entries.map((entry) => _buildObservedAreaCard(entry.key, entry.value)).toList(),
//                   ],
//                 ),
//               ),
//             ),
//
//           if (stats['clusters'] != null && (stats['clusters'] as List).isNotEmpty)
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Confirmed Clusters',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     ...(stats['clusters'] as List).map((cluster) => _buildClusterCard(cluster)).toList(),
//                   ],
//                 ),
//               ),
//             ),
//
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Controls',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.purple,
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: () => locationVM.centralPointVM.clearIntelligentDetector(),
//                         icon: Icon(Icons.clear_all),
//                         label: Text('Clear Detector'),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: () => locationVM.centralPointVM.testIntelligentClustering(),
//                         icon: Icon(Icons.play_arrow),
//                         label: Text('Test Clustering'),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: () => locationVM.processGPXAndStoreCentralPoint(),
//                         icon: Icon(Icons.incomplete_circle),
//                         label: Text('Process GPX'),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 32),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.blueGrey),
//           SizedBox(width: 12),
//           Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildObservedAreaCard(String key, dynamic area) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 8),
//       color: Colors.orange[50],
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.visibility, size: 16, color: Colors.orange),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Observed Area',
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800]),
//                   ),
//                 ),
//                 Chip(
//                   label: Text('${area['points']} points'),
//                   backgroundColor: Colors.orange[100],
//                   labelStyle: TextStyle(color: Colors.orange[800]),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Key: $key',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.timer, size: 14, color: Colors.grey),
//                 SizedBox(width: 4),
//                 Text('Observed for ${area['time_minutes']} minutes'),
//               ],
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Center: ${area['center']['lat'].toStringAsFixed(6)}, ${area['center']['lng'].toStringAsFixed(6)}',
//               style: TextStyle(fontSize: 12, fontFamily: 'Monospace'),
//             ),
//             SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: (area['points'] as int) / 3.0,
//               backgroundColor: Colors.orange[100],
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//             ),
//             SizedBox(height: 4),
//             Text(
//               '${area['points']}/3 points collected (${((area['points'] as int) / 3.0 * 100).toStringAsFixed(0)}%)',
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClusterCard(dynamic cluster) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 8),
//       color: Colors.green[50],
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.check_circle, size: 16, color: Colors.green),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Confirmed Cluster',
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
//                   ),
//                 ),
//                 Chip(
//                   label: Text('${cluster['points']} points'),
//                   backgroundColor: Colors.green[100],
//                   labelStyle: TextStyle(color: Colors.green[800]),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Key: ${cluster['key']}',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             SizedBox(height: 4),
//             if (cluster['center'] != null)
//               Text(
//                 'Center: ${cluster['center']['lat'].toStringAsFixed(6)}, ${cluster['center']['lng'].toStringAsFixed(6)}',
//                 style: TextStyle(fontSize: 12, fontFamily: 'Monospace'),
//               ),
//             SizedBox(height: 8),
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '✅ Repeated movement confirmed within 50m radius',
//                 style: TextStyle(fontSize: 12, color: Colors.green[800]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

