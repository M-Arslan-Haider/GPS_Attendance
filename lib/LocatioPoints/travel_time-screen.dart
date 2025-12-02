// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/LocatioPoints/ravelTimeViewModel.dart';
//
// class TravelTimeTestScreen extends StatelessWidget {
//   final TravelTimeViewModel travelTimeVM = Get.put(TravelTimeViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Travel Time Analytics'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Obx(() {
//         var todaySummary = travelTimeVM.getTodaySummary();
//
//         return SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Today's Summary Card
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "📊 Today's Summary",
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 16),
//                       _buildSummaryItem('🚗 Travel Time', '${todaySummary['travelTime']?.toStringAsFixed(2)} minutes'),
//                       _buildSummaryItem('💼 Working Time', '${todaySummary['workingTime']?.toStringAsFixed(2)} minutes'),
//                       _buildSummaryItem('⏸️ Stationary Time', '${todaySummary['stationaryTime']?.toStringAsFixed(2)} minutes'),
//                       _buildSummaryItem('📍 Total Distance', '${todaySummary['totalDistance']?.toStringAsFixed(2)} km'),
//                       _buildSummaryItem('🚀 Average Speed', '${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h'),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 16),
//
//               // Controls
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         travelTimeVM.printTravelTimeData();
//                         Get.snackbar(
//                           'Success',
//                           'Data printed to console!',
//                           snackPosition: SnackPosition.BOTTOM,
//                         );
//                       },
//                       child: Text('Print to Console'),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         travelTimeVM.syncData();
//                         Get.snackbar(
//                           'Success',
//                           'Data synced to server!',
//                           snackPosition: SnackPosition.BOTTOM,
//                         );
//                       },
//                       child: Text('Sync to Server'),
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 16),
//
//               // Detailed Data
//               Text(
//                 '📋 Recent Records',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//
//               ...travelTimeVM.travelTimeData.take(5).map((data) => Card(
//                 margin: EdgeInsets.only(bottom: 8),
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '🕒 ${data.startTime}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: _getTypeColor(data.travelType),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               data.travelType?.toUpperCase() ?? '',
//                               style: TextStyle(color: Colors.white, fontSize: 12),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       if (data.travelDistance != null && data.travelDistance! > 0)
//                         Text('📍 Distance: ${data.travelDistance!.toStringAsFixed(2)} km'),
//                       if (data.travelTime != null && data.travelTime! > 0)
//                         Text('⏱️ Duration: ${data.travelTime!.toStringAsFixed(2)} min'),
//                       if (data.averageSpeed != null && data.averageSpeed! > 0)
//                         Text('🚀 Speed: ${data.averageSpeed!.toStringAsFixed(2)} km/h'),
//                       if (data.address != null)
//                         Text('🏠 ${data.address}'),
//                     ],
//                   ),
//                 ),
//               )).toList(),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildSummaryItem(String title, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title),
//           Text(
//             value,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getTypeColor(String? type) {
//     switch (type) {
//       case 'traveling':
//         return Colors.blue;
//       case 'working':
//         return Colors.green;
//       case 'stationary':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// travel_time-screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/LocatioPoints/ravelTimeViewModel.dart';

class TravelTimeTestScreen extends StatelessWidget {
  final TravelTimeViewModel travelTimeVM = Get.put(TravelTimeViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Time Analytics'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              travelTimeVM.fetchTravelTimeData();
              Get.snackbar('Refreshed', 'Data updated successfully');
            },
          ),
        ],
      ),
      body: Obx(() {
        var todaySummary = travelTimeVM.getTodaySummary();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tracking Status Card
              Card(
                elevation: 4,
                color: travelTimeVM.isTracking ? Colors.green[50] : Colors.grey[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "🎯 Tracking Status",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: travelTimeVM.isTracking ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              travelTimeVM.isTracking ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusItem('🚗', '${travelTimeVM.totalTravelTime.toStringAsFixed(1)}m'),
                          _buildStatusItem('💼', '${travelTimeVM.totalWorkingTime.toStringAsFixed(1)}m'),
                          _buildStatusItem('⏸️', '${travelTimeVM.totalIdleTime.toStringAsFixed(1)}m'),
                          _buildStatusItem('📍', '${travelTimeVM.totalDistance.toStringAsFixed(2)}km'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Today's Summary Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📊 Today's Summary",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildSummaryItem('🚗 Travel Time', '${todaySummary['travelTime']?.toStringAsFixed(2)} minutes'),
                      _buildSummaryItem('💼 Working Time', '${todaySummary['workingTime']?.toStringAsFixed(2)} minutes'),
                      _buildSummaryItem('⏸️ Idle Time', '${todaySummary['idleTime']?.toStringAsFixed(2)} minutes'),
                      _buildSummaryItem('📍 Total Distance', '${todaySummary['totalDistance']?.toStringAsFixed(2)} km'),
                      _buildSummaryItem('🚀 Average Speed', '${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Controls - FIXED BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (travelTimeVM.isTracking) {
                          travelTimeVM.stopTracking();
                          Get.snackbar('Stopped', 'Tracking stopped');
                        } else {
                          travelTimeVM.startTracking();
                          Get.snackbar('Started', 'Tracking started');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: travelTimeVM.isTracking ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(travelTimeVM.isTracking ? Icons.stop : Icons.play_arrow),
                          SizedBox(width: 8),
                          Text(travelTimeVM.isTracking ? 'Stop Tracking' : 'Start Tracking'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        travelTimeVM.printTravelTimeData();
                        travelTimeVM.printRealTimeTracking();
                        Get.snackbar('Printed', 'Data printed to console');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print),
                          SizedBox(width: 8),
                          Text('Print Data'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        travelTimeVM.syncData();
                        Get.snackbar('Syncing', 'Data sync started');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync),
                          SizedBox(width: 8),
                          Text('Sync to Server'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        travelTimeVM.fetchTravelTimeData();
                        Get.snackbar('Refreshed', 'Data updated');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Detailed Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📋 Recent Records',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: ${travelTimeVM.travelTimeData.length}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 10),

              if (travelTimeVM.travelTimeData.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No travel data available\nStart tracking to collect data',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else
                ...travelTimeVM.travelTimeData.take(5).map((data) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🕒 ${data.startTime} - ${data.endTime}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getTypeColor(data.travelType),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data.travelType?.toUpperCase() ?? '',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (data.travelDistance != null && data.travelDistance! > 0)
                          Text('📍 Distance: ${data.travelDistance!.toStringAsFixed(2)} km'),
                        if (data.travelTime != null && data.travelTime! > 0)
                          Text('⏱️ Duration: ${data.travelTime!.toStringAsFixed(2)} min'),
                        if (data.averageSpeed != null && data.averageSpeed! > 0)
                          Text('🚀 Speed: ${data.averageSpeed!.toStringAsFixed(2)} km/h'),
                        if (data.address != null && data.address!.isNotEmpty)
                          Text('🏠 ${data.address}'),
                      ],
                    ),
                  ),
                )).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String icon, String value) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'traveling':
        return Colors.blue;
      case 'working':
        return Colors.green;
      case 'idle':
        return Colors.orange;
      case 'session_summary':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}