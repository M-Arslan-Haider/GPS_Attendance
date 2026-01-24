// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import '../../Databases/util.dart';
// //
// // class OrderReportScreen extends StatefulWidget {
// //   const OrderReportScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   _OrderReportScreenState createState() => _OrderReportScreenState();
// // }
// //
// // class _OrderReportScreenState extends State<OrderReportScreen> {
// //   List<Map<String, dynamic>> orders = [];
// //   bool isLoading = true;
// //   String errorMessage = '';
// //   String searchQuery = '';
// //   double totalAmount = 0.0;
// //   int totalOrders = 0;
// //   int postedOrders = 0;
// //   int pendingOrders = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchOrders();
// //   }
// //
// //   Future<void> fetchOrders() async {
// //     try {
// //       setState(() {
// //         isLoading = true;
// //         errorMessage = '';
// //       });
// //
// //       final url = 'https://cloud.metaxperts.net:8443/erp/valor_trading/ordermastergetuser/get/$user_id';
// //       debugPrint('🔗 Fetching orders from: $url');
// //
// //       final response = await http.get(
// //         Uri.parse(url),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Accept': 'application/json',
// //         },
// //       );
// //
// //       debugPrint('📊 Order API Status: ${response.statusCode}');
// //
// //       if (response.statusCode == 200) {
// //         final dynamic responseData = json.decode(response.body);
// //         debugPrint('📊 Response Type: ${responseData.runtimeType}');
// //
// //         List<Map<String, dynamic>> processedData = [];
// //
// //         if (responseData is List) {
// //           // Direct list response
// //           for (var item in responseData) {
// //             if (item is Map) {
// //               final Map<String, dynamic> convertedItem = {};
// //               item.forEach((key, value) {
// //                 convertedItem[key.toString()] = value;
// //               });
// //               processedData.add(_processOrderItem(convertedItem));
// //             }
// //           }
// //         } else if (responseData is Map) {
// //           final Map<String, dynamic> convertedResponse = {};
// //           responseData.forEach((key, value) {
// //             convertedResponse[key.toString()] = value;
// //           });
// //
// //           // Try to find list in response - check common keys
// //           List<String> possibleListKeys = [
// //             'data',
// //             'orders',
// //             'order_masters',
// //             'orderMasters',
// //             'results',
// //             'items',
// //             'records',
// //             'list'
// //           ];
// //
// //           bool foundList = false;
// //           for (var key in possibleListKeys) {
// //             if (convertedResponse.containsKey(key) && convertedResponse[key] is List) {
// //               debugPrint('✅ Found data in key: "$key"');
// //               final dataList = convertedResponse[key] as List;
// //               for (var item in dataList) {
// //                 if (item is Map) {
// //                   final Map<String, dynamic> convertedItem = {};
// //                   item.forEach((k, v) {
// //                     convertedItem[k.toString()] = v;
// //                   });
// //                   processedData.add(_processOrderItem(convertedItem));
// //                 }
// //               }
// //               foundList = true;
// //               break;
// //             }
// //           }
// //
// //           // If no standard list keys found, look for ANY list
// //           if (!foundList) {
// //             convertedResponse.forEach((key, value) {
// //               if (value is List && !foundList) {
// //                 debugPrint('✅ Found list in key: "$key"');
// //                 for (var item in value) {
// //                   if (item is Map) {
// //                     final Map<String, dynamic> convertedItem = {};
// //                     item.forEach((k, v) {
// //                       convertedItem[k.toString()] = v;
// //                     });
// //                     processedData.add(_processOrderItem(convertedItem));
// //                   }
// //                 }
// //                 foundList = true;
// //               }
// //             });
// //           }
// //         }
// //
// //         // Calculate statistics
// //         double amount = 0.0;
// //         int posted = 0;
// //         int pending = 0;
// //
// //         for (var order in processedData) {
// //           final orderAmount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
// //           amount += orderAmount;
// //
// //           if (order['posted']?.toString() == '1') {
// //             posted++;
// //           } else {
// //             pending++;
// //           }
// //         }
// //
// //         setState(() {
// //           orders = processedData;
// //           totalAmount = amount;
// //           totalOrders = processedData.length;
// //           postedOrders = posted;
// //           pendingOrders = pending;
// //           isLoading = false;
// //         });
// //
// //         debugPrint('✅ Successfully loaded ${orders.length} orders');
// //         if (orders.isNotEmpty) {
// //           debugPrint('📋 First order keys: ${orders[0].keys}');
// //         }
// //       } else {
// //         throw Exception('HTTP ${response.statusCode}: ${response.body}');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Order API Error: $e');
// //       setState(() {
// //         errorMessage = e.toString();
// //         isLoading = false;
// //       });
// //       Get.snackbar(
// //         'Error',
// //         'Failed to load orders: $e',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //       );
// //     }
// //   }
// //
// //   // Add this method inside the _OrderReportScreenState class
// //   Map<String, dynamic> _processOrderItem(Map<String, dynamic> item) {
// //     debugPrint('📋 Processing order with keys: ${item.keys}');
// //
// //     // Common field names for order master data
// //     return {
// //       'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? item['id'] ?? 'N/A',
// //       'shop_name': item['shop_name'] ?? item['Shop_Name'] ?? item['shopName'] ?? item['shop'] ?? 'N/A',
// //       'shop_address': item['shop_address'] ?? item['Shop_Address'] ?? item['shopAddress'] ?? 'N/A',
// //       'owner_name': item['owner_name'] ?? item['Owner_Name'] ?? item['ownerName'] ?? 'N/A',
// //       'booker_name': item['booker_name'] ?? item['Booker_Name'] ?? item['bookerName'] ?? 'N/A',
// //       'order_amount': item['order_amount'] ?? item['Order_Amount'] ?? item['orderAmount'] ?? item['amount'] ?? '0.0',
// //       'order_date': item['order_date'] ?? item['Order_Date'] ?? item['orderDate'] ?? item['date'] ?? 'N/A',
// //       'order_time': item['order_time'] ?? item['Order_Time'] ?? item['orderTime'] ?? item['time'] ?? 'N/A',
// //       'user_id': item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? 'N/A',
// //       'posted': item['posted'] ?? item['Posted'] ?? '0',
// //       'city': item['city'] ?? item['City'] ?? 'N/A',
// //       'brand': item['brand'] ?? item['Brand'] ?? 'N/A',
// //       'latitude': item['latitude'] ?? item['Latitude'] ?? 'N/A',
// //       'longitude': item['longitude'] ?? item['Longitude'] ?? 'N/A',
// //       'address': item['address'] ?? item['Address'] ?? 'N/A',
// //       // Add all raw data for debugging
// //       '_raw_data': item,
// //     };
// //   }
// //
// //   List<Map<String, dynamic>> get filteredOrders {
// //     if (searchQuery.isEmpty) return orders;
// //
// //     return orders.where((order) {
// //       final shopName = order['shop_name']?.toString().toLowerCase();
// //       final orderId = order['order_master_id']?.toString().toLowerCase();
// //       final ownerName = order['owner_name']?.toString().toLowerCase();
// //       // final city = order['city']?.toString().toLowerCase();
// //       final brand = order['brand']?.toString().toLowerCase();
// //       final query = searchQuery.toLowerCase();
// //
// //       return (shopName != null && shopName.contains(query)) ||
// //           (orderId != null && orderId.contains(query)) ||
// //           (ownerName != null && ownerName.contains(query)) ||
// //           // (city != null && city.contains(query)) ||
// //           (brand != null && brand.contains(query));
// //     }).toList();
// //   }
// //
// //   void showOrderDetails(Map<String, dynamic> order) {
// //     Get.bottomSheet(
// //       Container(
// //         height: MediaQuery.of(context).size.height * 0.8,
// //         padding: const EdgeInsets.all(16),
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.only(
// //             topLeft: Radius.circular(20),
// //             topRight: Radius.circular(20),
// //           ),
// //         ),
// //         child: Column(
// //           children: [
// //             // Drag handle
// //             Container(
// //               width: 40,
// //               height: 4,
// //               margin: const EdgeInsets.only(bottom: 16),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[300],
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //
// //             const Text(
// //               'Order Master Details',
// //               style: TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     _buildDetailRow('Order ID:', order['order_master_id']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('Shop:', order['shop_name']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('Address:', order['shop_address']?.toString() ?? 'N/A'),
// //                     // _buildDetailRow('City:', order['city']?.toString() ?? 'N/A'),
// //                     // _buildDetailRow('Owner:', order['owner_name']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('Booker:', order['booker_name']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('Brand:', order['brand']?.toString() ?? 'N/A'),
// //                     // _buildDetailRow('Date:', order['order_date']?.toString() ?? 'N/A'),
// //                     // _buildDetailRow('Time:', order['order_time']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('User ID:', order['user_id']?.toString() ?? 'N/A'),
// //                     // _buildDetailRow('Status:', order['posted']?.toString() == '1' ? '✅ Posted' : '⏳ Pending'),
// //                     _buildDetailRow('Latitude:', order['latitude']?.toString() ?? 'N/A'),
// //                     _buildDetailRow('Longitude:', order['longitude']?.toString() ?? 'N/A'),
// //
// //                     const SizedBox(height: 20),
// //
// //                     Container(
// //                       padding: const EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.blueGrey.shade50,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(color: Colors.blueGrey.shade200),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'Order Amount:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                           Text(
// //                             order['order_amount']?.toString() ?? '0.0',
// //                             style: const TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 20,
// //                               color: Colors.green,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     if (order.containsKey('_raw_data'))
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const SizedBox(height: 20),
// //                           const Text(
// //                             'Raw Data:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                           Container(
// //                             padding: const EdgeInsets.all(8),
// //                             margin: const EdgeInsets.only(top: 4),
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey[100],
// //                               borderRadius: BorderRadius.circular(4),
// //                             ),
// //                             child: Text(
// //                               order['_raw_data'].toString(),
// //                               style: const TextStyle(
// //                                 fontSize: 10,
// //                                 fontFamily: 'Monospace',
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             Center(
// //               child: TextButton(
// //                 onPressed: () => Get.back(),
// //                 child: const Text('Close'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       isScrollControlled: true,
// //     );
// //   }
// //
// //   Widget _buildDetailRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 10),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 80,
// //             child: Text(
// //               label,
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.grey,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: const TextStyle(fontSize: 15),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatCard(String title, String value, Color color, IconData icon) {
// //     return Card(
// //       elevation: 2,
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, size: 24, color: color),
// //             const SizedBox(height: 8),
// //             Text(
// //               value,
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               title,
// //               style: const TextStyle(
// //                 fontSize: 12,
// //                 color: Colors.grey,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           'Order Master Report',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         backgroundColor: Colors.blueGrey,
// //         centerTitle: true,
// //         iconTheme: const IconThemeData(
// //           color: Colors.white,
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.refresh, color: Colors.white),
// //             onPressed: fetchOrders,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // // Search bar
// //           // Container(
// //           //   padding: const EdgeInsets.all(12),
// //           //   color: Colors.grey[50],
// //           //   child: TextField(
// //           //     decoration: InputDecoration(
// //           //       hintText: 'Search by shop, owner, city, brand...',
// //           //       prefixIcon: const Icon(Icons.search),
// //           //       border: OutlineInputBorder(
// //           //         borderRadius: BorderRadius.circular(8),
// //           //       ),
// //           //       contentPadding: const EdgeInsets.symmetric(horizontal: 12),
// //           //     ),
// //           //     onChanged: (value) {
// //           //       setState(() {
// //           //         searchQuery = value;
// //           //       });
// //           //     },
// //           //   ),
// //           // ),
// //
// //
// //           // Main content
// //           Expanded(
// //             child: _buildContent(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildContent() {
// //     if (isLoading) {
// //       return const Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 16),
// //             Text('Loading order master reports...'),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     if (errorMessage.isNotEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.error, size: 64, color: Colors.red),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'Failed to load orders',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 32),
// //               child: Text(
// //                 errorMessage,
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: fetchOrders,
// //               child: const Text('Try Again'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     if (orders.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'No order master records found',
// //               style: TextStyle(fontSize: 16, color: Colors.grey),
// //             ),
// //             const SizedBox(height: 8),
// //             ElevatedButton(
// //               onPressed: fetchOrders,
// //               child: const Text('Refresh'),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     return SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.vertical,
// //         child: Padding(
// //           padding: const EdgeInsets.all(8.0),
// //           child: DataTable(
// //             headingRowColor: MaterialStateColor.resolveWith(
// //                   (states) => Colors.blueGrey.shade50,
// //             ),
// //             columnSpacing: 16,
// //             horizontalMargin: 8,
// //             columns: const [
// //               DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
// //               // DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
// //               // DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Shop', style: TextStyle(fontWeight: FontWeight.bold))),
// //               // DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
// //               // DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
// //               // DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
// //               DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.bold))),
// //             ],
// //             rows: filteredOrders.map((order) {
// //               final isPosted = order['posted']?.toString() == '1';
// //               final amount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
// //
// //               return DataRow(
// //                 cells: [
// //                   DataCell(
// //                     SizedBox(
// //                       width: 100,
// //                       child: Text(
// //                         order['order_master_id']?.toString() ?? 'N/A',
// //                         style: const TextStyle(fontSize: 11, fontFamily: 'Monospace'),
// //                       ),
// //                     ),
// //                   ),
// //                   // DataCell(Text(order['order_date']?.toString() ?? 'N/A')),
// //                   // DataCell(Text(order['order_time']?.toString() ?? 'N/A')),
// //                   DataCell(
// //                     SizedBox(
// //                       width: 100,
// //                       child: Text(
// //                         order['shop_name']?.toString() ?? 'N/A',
// //                         overflow: TextOverflow.ellipsis,
// //                       ),
// //                     ),
// //                   ),
// //                   // DataCell(
// //                   //   SizedBox(
// //                   //     width: 80,
// //                   //     child: Text(
// //                   //       order['owner_name']?.toString() ?? 'N/A',
// //                   //       overflow: TextOverflow.ellipsis,
// //                   //     ),
// //                   //   ),
// //                   // ),
// //                   // DataCell(Text(order['city']?.toString() ?? 'N/A')),
// //                   DataCell(Text(order['brand']?.toString() ?? 'N/A')),
// //                   DataCell(
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                       decoration: BoxDecoration(
// //                         color: Colors.green.shade50,
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: Text(
// //                         amount.toStringAsFixed(0),
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.green,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   // DataCell(
// //                   //   Container(
// //                   //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                   //     decoration: BoxDecoration(
// //                   //       color: isPosted ? Colors.green.shade50 : Colors.orange.shade50,
// //                   //       borderRadius: BorderRadius.circular(12),
// //                   //     ),
// //                   //     child: Row(
// //                   //       mainAxisSize: MainAxisSize.min,
// //                   //       children: [
// //                   //         Icon(
// //                   //           isPosted ? Icons.check_circle : Icons.pending,
// //                   //           size: 14,
// //                   //           color: isPosted ? Colors.green : Colors.orange,
// //                   //         ),
// //                   //         const SizedBox(width: 4),
// //                   //         Text(
// //                   //           isPosted ? 'Posted' : 'Pending',
// //                   //           style: TextStyle(
// //                   //             fontWeight: FontWeight.bold,
// //                   //             fontSize: 11,
// //                   //             color: isPosted ? Colors.green : Colors.orange,
// //                   //           ),
// //                   //         ),
// //                   //       ],
// //                   //     ),
// //                   //   ),
// //                   // ),
// //                   DataCell(
// //                     IconButton(
// //                       icon: const Icon(Icons.visibility, size: 18, color: Colors.blue),
// //                       onPressed: () => showOrderDetails(order),
// //                       tooltip: 'View Details',
// //                     ),
// //                   ),
// //                 ],
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../Databases/util.dart';
// import '../../Services/FirebaseServices/firebase_remote_config.dart';
//
// class OrderReportScreen extends StatefulWidget {
//   const OrderReportScreen({Key? key}) : super(key: key);
//
//   @override
//   _OrderReportScreenState createState() => _OrderReportScreenState();
// }
//
// class _OrderReportScreenState extends State<OrderReportScreen> {
//   List<Map<String, dynamic>> orders = [];
//   bool isLoading = true;
//   bool isLoadingDetails = false;
//   String errorMessage = '';
//   String searchQuery = '';
//   double totalAmount = 0.0;
//   int totalOrders = 0;
//   int postedOrders = 0;
//   int pendingOrders = 0;
//   List<Map<String, dynamic>> orderDetails = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }
//
//   Future<void> fetchOrders() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });
//
//       // Your API URL
//       final String baseUrl =  Config.getApiUrlOrderReport;
//       final String url = '$baseUrl/$user_id';
//       debugPrint('🔗 Fetching from: $url');
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//
//       debugPrint('📊 Order API Status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final dynamic responseData = json.decode(response.body);
//         debugPrint('📊 Response Type: ${responseData.runtimeType}');
//
//         List<Map<String, dynamic>> processedData = [];
//
//         if (responseData is List) {
//           // Direct list response
//           for (var item in responseData) {
//             if (item is Map) {
//               final Map<String, dynamic> convertedItem = {};
//               item.forEach((key, value) {
//                 convertedItem[key.toString()] = value;
//               });
//               processedData.add(_processOrderItem(convertedItem));
//             }
//           }
//         } else if (responseData is Map) {
//           final Map<String, dynamic> convertedResponse = {};
//           responseData.forEach((key, value) {
//             convertedResponse[key.toString()] = value;
//           });
//
//           // Try to find list in response - check common keys
//           List<String> possibleListKeys = [
//             'data',
//             'orders',
//             'order_masters',
//             'orderMasters',
//             'results',
//             'items',
//             'records',
//             'list'
//           ];
//
//           bool foundList = false;
//           for (var key in possibleListKeys) {
//             if (convertedResponse.containsKey(key) && convertedResponse[key] is List) {
//               debugPrint('✅ Found data in key: "$key"');
//               final dataList = convertedResponse[key] as List;
//               for (var item in dataList) {
//                 if (item is Map) {
//                   final Map<String, dynamic> convertedItem = {};
//                   item.forEach((k, v) {
//                     convertedItem[k.toString()] = v;
//                   });
//                   processedData.add(_processOrderItem(convertedItem));
//                 }
//               }
//               foundList = true;
//               break;
//             }
//           }
//
//           // If no standard list keys found, look for ANY list
//           if (!foundList) {
//             convertedResponse.forEach((key, value) {
//               if (value is List && !foundList) {
//                 debugPrint('✅ Found list in key: "$key"');
//                 for (var item in value) {
//                   if (item is Map) {
//                     final Map<String, dynamic> convertedItem = {};
//                     item.forEach((k, v) {
//                       convertedItem[k.toString()] = v;
//                     });
//                     processedData.add(_processOrderItem(convertedItem));
//                   }
//                 }
//                 foundList = true;
//               }
//             });
//           }
//         }
//
//         // Calculate statistics
//         double amount = 0.0;
//         int posted = 0;
//         int pending = 0;
//
//         for (var order in processedData) {
//           final orderAmount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
//           amount += orderAmount;
//
//           if (order['posted']?.toString() == '1') {
//             posted++;
//           } else {
//             pending++;
//           }
//         }
//
//         setState(() {
//           orders = processedData;
//           totalAmount = amount;
//           totalOrders = processedData.length;
//           postedOrders = posted;
//           pendingOrders = pending;
//           isLoading = false;
//         });
//
//         debugPrint('✅ Successfully loaded ${orders.length} orders');
//         if (orders.isNotEmpty) {
//           debugPrint('📋 First order keys: ${orders[0].keys}');
//         }
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('❌ Order API Error: $e');
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Failed to load orders: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> fetchOrderDetails(String orderId) async {
//     try {
//       setState(() {
//         isLoadingDetails = true;
//       });
//
//       final url = 'https://cloud.metaxperts.net:8443/erp/valor_trading/orderdetailget/get/$orderId';
//       debugPrint('🔗 Fetching order details from: $url');
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//
//       debugPrint('📊 Order Details API Status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final dynamic responseData = json.decode(response.body);
//         debugPrint('📊 Order Details Response Type: ${responseData.runtimeType}');
//
//         List<Map<String, dynamic>> processedDetails = [];
//
//         // Process the response data
//         if (responseData is List) {
//           for (var item in responseData) {
//             if (item is Map) {
//               final Map<String, dynamic> convertedItem = {};
//               item.forEach((key, value) {
//                 convertedItem[key.toString()] = value;
//               });
//               processedDetails.add(_processOrderDetailItem(convertedItem));
//             }
//           }
//         } else if (responseData is Map) {
//           final Map<String, dynamic> convertedResponse = {};
//           responseData.forEach((key, value) {
//             convertedResponse[key.toString()] = value;
//           });
//
//           // Check for nested list
//           List<String> possibleListKeys = [
//             'data',
//             'order_details',
//             'orderDetails',
//             'details',
//             'items',
//             'results',
//             'list'
//           ];
//
//           bool foundList = false;
//           for (var key in possibleListKeys) {
//             if (convertedResponse.containsKey(key) && convertedResponse[key] is List) {
//               debugPrint('✅ Found order details in key: "$key"');
//               final dataList = convertedResponse[key] as List;
//               for (var item in dataList) {
//                 if (item is Map) {
//                   final Map<String, dynamic> convertedItem = {};
//                   item.forEach((k, v) {
//                     convertedItem[k.toString()] = v;
//                   });
//                   processedDetails.add(_processOrderDetailItem(convertedItem));
//                 }
//               }
//               foundList = true;
//               break;
//             }
//           }
//
//           // If no standard list keys found, look for ANY list
//           if (!foundList) {
//             convertedResponse.forEach((key, value) {
//               if (value is List && !foundList) {
//                 debugPrint('✅ Found list in key: "$key"');
//                 for (var item in value) {
//                   if (item is Map) {
//                     final Map<String, dynamic> convertedItem = {};
//                     item.forEach((k, v) {
//                       convertedItem[k.toString()] = v;
//                     });
//                     processedDetails.add(_processOrderDetailItem(convertedItem));
//                   }
//                 }
//                 foundList = true;
//               }
//             });
//           }
//
//           // If still no list found, treat the entire map as a single item
//           if (!foundList && convertedResponse.isNotEmpty) {
//             processedDetails.add(_processOrderDetailItem(convertedResponse));
//           }
//         }
//
//         setState(() {
//           orderDetails = processedDetails;
//           isLoadingDetails = false;
//         });
//
//         debugPrint('✅ Successfully loaded ${orderDetails.length} order details');
//         if (orderDetails.isNotEmpty) {
//           debugPrint('📋 First detail keys: ${orderDetails[0].keys}');
//         }
//       } else {
//         throw Exception('HTTP ${response.statusCode}: ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('❌ Order Details API Error: $e');
//       setState(() {
//         isLoadingDetails = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Failed to load order details: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Map<String, dynamic> _processOrderItem(Map<String, dynamic> item) {
//     debugPrint('📋 Processing order with keys: ${item.keys}');
//
//     return {
//       'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? item['id'] ?? 'N/A',
//       'shop_name': item['shop_name'] ?? item['Shop_Name'] ?? item['shopName'] ?? item['shop'] ?? 'N/A',
//       'shop_address': item['shop_address'] ?? item['Shop_Address'] ?? item['shopAddress'] ?? 'N/A',
//       'owner_name': item['owner_name'] ?? item['Owner_Name'] ?? item['ownerName'] ?? 'N/A',
//       'booker_name': item['booker_name'] ?? item['Booker_Name'] ?? item['bookerName'] ?? 'N/A',
//       'order_amount': item['order_amount'] ?? item['Order_Amount'] ?? item['orderAmount'] ?? item['amount'] ?? '0.0',
//       'order_date': item['order_date'] ?? item['Order_Date'] ?? item['orderDate'] ?? item['date'] ?? 'N/A',
//       'order_time': item['order_time'] ?? item['Order_Time'] ?? item['orderTime'] ?? item['time'] ?? 'N/A',
//       'user_id': item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? 'N/A',
//       'posted': item['posted'] ?? item['Posted'] ?? '0',
//       'city': item['city'] ?? item['City'] ?? 'N/A',
//       'brand': item['brand'] ?? item['Brand'] ?? 'N/A',
//       'latitude': item['latitude'] ?? item['Latitude'] ?? 'N/A',
//       'longitude': item['longitude'] ?? item['Longitude'] ?? 'N/A',
//       'address': item['address'] ?? item['Address'] ?? 'N/A',
//       '_raw_data': item,
//     };
//   }
//
//   Map<String, dynamic> _processOrderDetailItem(Map<String, dynamic> item) {
//     debugPrint('📋 Processing order detail with keys: ${item.keys}');
//
//     return {
//       'order_detail_id': item['order_detail_id'] ?? item['Order_Detail_Id'] ?? item['orderDetailId'] ?? item['id'] ?? 'N/A',
//       'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? 'N/A',
//       'product_id': item['product_id'] ?? item['Product_Id'] ?? item['productId'] ?? 'N/A',
//       'product_name': item['product_name'] ?? item['Product_Name'] ?? item['productName'] ?? item['product'] ?? 'N/A',
//       'product_code': item['product_code'] ?? item['Product_Code'] ?? item['productCode'] ?? item['code'] ?? 'N/A',
//       'quantity': item['quantity'] ?? item['Quantity'] ?? item['qty'] ?? '0',
//       'unit_price': item['unit_price'] ?? item['Unit_Price'] ?? item['unitPrice'] ?? item['price'] ?? '0.0',
//       'total_price': item['total_price'] ?? item['Total_Price'] ?? item['totalPrice'] ?? item['amount'] ?? '0.0',
//       'discount': item['discount'] ?? item['Discount'] ?? '0.0',
//       'net_price': item['net_price'] ?? item['Net_Price'] ?? item['netPrice'] ?? '0.0',
//       'batch_number': item['batch_number'] ?? item['Batch_Number'] ?? item['batchNo'] ?? 'N/A',
//       'expiry_date': item['expiry_date'] ?? item['Expiry_Date'] ?? item['expiryDate'] ?? 'N/A',
//       'manufacturer': item['manufacturer'] ?? item['Manufacturer'] ?? item['maker'] ?? 'N/A',
//       'category': item['category'] ?? item['Category'] ?? item['cat'] ?? 'N/A',
//       'uom': item['uom'] ?? item['UOM'] ?? item['unit'] ?? 'N/A',
//       'remarks': item['remarks'] ?? item['Remarks'] ?? item['note'] ?? '',
//       '_raw_data': item,
//     };
//   }
//
//   void showOrderDetailsDialog(Map<String, dynamic> order) async {
//     final orderId = order['order_master_id']?.toString();
//     if (orderId == null || orderId == 'N/A') {
//       Get.snackbar(
//         'Error',
//         'Invalid Order ID',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     // Show loading dialog while fetching details
//     Get.dialog(
//       const Center(
//         child: CircularProgressIndicator(),
//       ),
//       barrierDismissible: false,
//     );
//
//     await fetchOrderDetails(orderId);
//
//     // Close loading dialog
//     Get.back();
//
//     // Show details bottom sheet
//     Get.bottomSheet(
//       Container(
//         height: MediaQuery.of(context).size.height * 0.9,
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Drag handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Order Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueGrey[800],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Get.back(),
//                 ),
//               ],
//             ),
//
//             // Order Master Summary
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Order #${order['order_master_id']}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Shop: ${order['shop_name']}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               // Text(
//                               //   'Date: ${order['order_date']}',
//                               //   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                               // ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade50,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             '${double.tryParse(order['order_amount']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Order Details Section
//             Expanded(
//               child: _buildOrderDetailsContent(orderId),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }
//
//   Widget _buildOrderDetailsContent(String orderId) {
//     if (isLoadingDetails) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading order details...'),
//           ],
//         ),
//       );
//     }
//
//     if (orderDetails.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.inventory, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'No order details found',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             TextButton(
//               onPressed: () => fetchOrderDetails(orderId),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         // Summary Card
//         Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           color: Colors.blueGrey[50],
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total Items:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//                 Text(
//                   orderDetails.length.toString(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         // Items List
//         Expanded(
//           child: ListView.builder(
//             itemCount: orderDetails.length,
//             itemBuilder: (context, index) {
//               final detail = orderDetails[index];
//               final quantity = int.tryParse(detail['quantity']?.toString() ?? '0') ?? 0;
//               // final unitPrice = double.tryParse(detail['unit_price']?.toString() ?? '0') ?? 0.0;
//               final totalPrice = double.tryParse(detail['total_price']?.toString() ?? '0') ?? 0.0;
//
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               detail['product_name']?.toString() ?? 'Unknown Product',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               detail['product_code']?.toString() ?? '',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue[800],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           _buildDetailItem('Qty:', '$quantity ${detail['uom'] ?? 'Pcs'}'),
//                           // _buildDetailItem('Price:', 'Rs: ${unitPrice.toStringAsFixed(0)}'),
//                           _buildDetailItem('Total:', 'Rs: ${totalPrice.toStringAsFixed(0)}'),
//                         ],
//                       ),
//                       if (detail['batch_number']?.toString().isNotEmpty == true &&
//                           detail['batch_number'] != 'N/A')
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             'Batch: ${detail['batch_number']}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ),
//                       if (detail['manufacturer']?.toString().isNotEmpty == true &&
//                           detail['manufacturer'] != 'N/A')
//                         Padding(
//                           padding: const EdgeInsets.only(top: 2),
//                           child: Text(
//                             'Manufacturer: ${detail['manufacturer']}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ),
//                       if (detail['remarks']?.toString().isNotEmpty == true)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             'Note: ${detail['remarks']}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.orange[700],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // Grand Total
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.green[50],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Grand Total:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               Text(
//                 'Rs: ${orderDetails.fold<double>(0, (sum, item) => sum + (double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0)).toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDetailItem(String label, String value) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ... (rest of your existing methods: get filteredOrders, _buildStatCard, build, _buildContent)
//
//   List<Map<String, dynamic>> get filteredOrders {
//     if (searchQuery.isEmpty) return orders;
//
//     return orders.where((order) {
//       final shopName = order['shop_name']?.toString().toLowerCase();
//       final orderId = order['order_master_id']?.toString().toLowerCase();
//       final ownerName = order['owner_name']?.toString().toLowerCase();
//       final brand = order['brand']?.toString().toLowerCase();
//       final query = searchQuery.toLowerCase();
//
//       return (shopName != null && shopName.contains(query)) ||
//           (orderId != null && orderId.contains(query)) ||
//           (ownerName != null && ownerName.contains(query)) ||
//           (brand != null && brand.contains(query));
//     }).toList();
//   }
//
//   Widget _buildStatCard(String title, String value, Color color, IconData icon) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 24, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Order Master Report',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.blueGrey,
//         centerTitle: true,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: fetchOrders,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _buildContent(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     if (isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading order master reports...'),
//           ],
//         ),
//       );
//     }
//
//     if (errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             const Text(
//               'Failed to load orders',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 errorMessage,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: fetchOrders,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'No order master records found',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: fetchOrders,
//               child: const Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DataTable(
//             headingRowColor: MaterialStateColor.resolveWith(
//                   (states) => Colors.blueGrey.shade50,
//             ),
//             columnSpacing: 16,
//             horizontalMargin: 8,
//             columns: const [
//               DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Shop', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
//               DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.bold))),
//             ],
//             rows: filteredOrders.map((order) {
//               final amount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
//
//               return DataRow(
//                 cells: [
//                   DataCell(
//                     SizedBox(
//                       width: 100,
//                       child: Text(
//                         order['order_master_id']?.toString() ?? 'N/A',
//                         style: const TextStyle(fontSize: 11, fontFamily: 'Monospace'),
//                       ),
//                     ),
//                   ),
//                   DataCell(
//                     SizedBox(
//                       width: 100,
//                       child: Text(
//                         order['shop_name']?.toString() ?? 'N/A',
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   DataCell(Text(order['brand']?.toString() ?? 'N/A')),
//                   DataCell(
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade50,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         amount.toStringAsFixed(0),
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey,
//                         ),
//                       ),
//                     ),
//                   ),
//                   DataCell(
//                     IconButton(
//                       icon: const Icon(Icons.visibility, size: 18, color: Colors.blueGrey),
//                       onPressed: () => showOrderDetailsDialog(order),
//                       tooltip: 'View Details',
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../Databases/util.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class OrderReportScreen extends StatefulWidget {
  const OrderReportScreen({Key? key}) : super(key: key);

  @override
  _OrderReportScreenState createState() => _OrderReportScreenState();
}

class _OrderReportScreenState extends State<OrderReportScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  bool isLoadingDetails = false;
  String errorMessage = '';
  double totalAmount = 0.0;
  int totalOrders = 0;
  int postedOrders = 0;
  int pendingOrders = 0;
  List<Map<String, dynamic>> orderDetails = [];

  // Filter Controllers & Variables
  final TextEditingController shopNameFilterController = TextEditingController();
  final TextEditingController brandFilterController = TextEditingController();
  final TextEditingController cityFilterController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    shopNameFilterController.dispose();
    brandFilterController.dispose();
    cityFilterController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String baseUrl = Config.getApiUrlOrderReport;
      final String url = '$baseUrl/$user_id';
      debugPrint('🔗 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Order API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic rawResponse = json.decode(response.body);
        debugPrint('📊 Response Type: ${rawResponse.runtimeType}');

        List<Map<String, dynamic>> processedData = [];

        if (rawResponse is List) {
          for (var item in rawResponse) {
            if (item is Map) {
              processedData.add(_processOrderItem(item));
            }
          }
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);

          List<String> possibleListKeys = [
            'data',
            'orders',
            'order_masters',
            'orderMasters',
            'results',
            'items',
            'records',
            'list'
          ];

          bool foundList = false;
          for (var key in possibleListKeys) {
            if (mapResponse.containsKey(key) && mapResponse[key] is List) {
              debugPrint('✅ Found data in key: "$key"');
              final dataList = mapResponse[key] as List;
              for (var item in dataList) {
                if (item is Map) {
                  processedData.add(_processOrderItem(item));
                }
              }
              foundList = true;
              break;
            }
          }

          if (!foundList) {
            mapResponse.forEach((key, value) {
              if (value is List && !foundList) {
                debugPrint('✅ Found list in key: "$key"');
                for (var item in value) {
                  if (item is Map) {
                    processedData.add(_processOrderItem(item));
                  }
                }
                foundList = true;
              }
            });
          }
        }

        // Calculate statistics
        double amount = 0.0;
        int posted = 0;
        int pending = 0;

        for (var order in processedData) {
          final orderAmount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
          amount += orderAmount;

          if (order['posted']?.toString() == '1') {
            posted++;
          } else {
            pending++;
          }
        }

        setState(() {
          orders = processedData;
          totalAmount = amount;
          totalOrders = processedData.length;
          postedOrders = posted;
          pendingOrders = pending;
          isLoading = false;
        });

        debugPrint('✅ Successfully loaded ${orders.length} orders');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Order API Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load orders: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      setState(() {
        isLoadingDetails = true;
      });

      final url = 'https://cloud.metaxperts.net:8443/erp/valor_trading/orderdetailget/get/$orderId';
      debugPrint('🔗 Fetching order details from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic rawResponse = json.decode(response.body);

        List<Map<String, dynamic>> processedDetails = [];

        if (rawResponse is List) {
          for (var item in rawResponse) {
            if (item is Map) {
              processedDetails.add(_processOrderDetailItem(item));
            }
          }
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);

          List<String> possibleListKeys = [
            'data',
            'order_details',
            'orderDetails',
            'details',
            'items',
            'results',
            'list'
          ];

          bool foundList = false;
          for (var key in possibleListKeys) {
            if (mapResponse.containsKey(key) && mapResponse[key] is List) {
              final dataList = mapResponse[key] as List;
              for (var item in dataList) {
                if (item is Map) {
                  processedDetails.add(_processOrderDetailItem(item));
                }
              }
              foundList = true;
              break;
            }
          }

          if (!foundList) {
            mapResponse.forEach((key, value) {
              if (value is List && !foundList) {
                for (var item in value) {
                  if (item is Map) {
                    processedDetails.add(_processOrderDetailItem(item));
                  }
                }
                foundList = true;
              }
            });
          }

          if (!foundList && mapResponse.isNotEmpty) {
            processedDetails.add(_processOrderDetailItem(mapResponse));
          }
        }

        setState(() {
          orderDetails = processedDetails;
          isLoadingDetails = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Order Details API Error: $e');
      setState(() {
        isLoadingDetails = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load order details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fixed: Accept dynamic and safely convert to Map<String, dynamic>
  Map<String, dynamic> _processOrderItem(dynamic rawItem) {
    final item = Map<String, dynamic>.from(rawItem ?? {});

    return {
      'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? item['id'] ?? 'N/A',
      'shop_name': item['shop_name'] ?? item['Shop_Name'] ?? item['shopName'] ?? item['shop'] ?? 'N/A',
      'shop_address': item['shop_address'] ?? item['Shop_Address'] ?? item['shopAddress'] ?? 'N/A',
      'owner_name': item['owner_name'] ?? item['Owner_Name'] ?? item['ownerName'] ?? 'N/A',
      'booker_name': item['booker_name'] ?? item['Booker_Name'] ?? item['bookerName'] ?? 'N/A',
      'order_amount': item['order_amount'] ?? item['Order_Amount'] ?? item['orderAmount'] ?? item['amount'] ?? '0.0',
      'order_date': item['order_date'] ?? item['Order_Date'] ?? item['orderDate'] ?? item['date'] ?? 'N/A',
      'order_time': item['order_time'] ?? item['Order_Time'] ?? item['orderTime'] ?? item['time'] ?? 'N/A',
      'user_id': item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? 'N/A',
      'posted': item['posted'] ?? item['Posted'] ?? '0',
      'city': item['city'] ?? item['City'] ?? 'N/A',
      'brand': item['brand'] ?? item['Brand'] ?? 'N/A',
      'latitude': item['latitude'] ?? item['Latitude'] ?? 'N/A',
      'longitude': item['longitude'] ?? item['Longitude'] ?? 'N/A',
      'address': item['address'] ?? item['Address'] ?? 'N/A',
      '_raw_data': item,
    };
  }

  // Fixed: Accept dynamic and safely convert to Map<String, dynamic>
  Map<String, dynamic> _processOrderDetailItem(dynamic rawItem) {
    final item = Map<String, dynamic>.from(rawItem ?? {});

    return {
      'order_detail_id': item['order_detail_id'] ?? item['Order_Detail_Id'] ?? item['orderDetailId'] ?? item['id'] ?? 'N/A',
      'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? 'N/A',
      'product_id': item['product_id'] ?? item['Product_Id'] ?? item['productId'] ?? 'N/A',
      'product_name': item['product_name'] ?? item['Product_Name'] ?? item['productName'] ?? item['product'] ?? 'N/A',
      'product_code': item['product_code'] ?? item['Product_Code'] ?? item['productCode'] ?? item['code'] ?? 'N/A',
      'quantity': item['quantity'] ?? item['Quantity'] ?? item['qty'] ?? '0',
      'unit_price': item['unit_price'] ?? item['Unit_Price'] ?? item['unitPrice'] ?? item['price'] ?? '0.0',
      'total_price': item['total_price'] ?? item['Total_Price'] ?? item['totalPrice'] ?? item['amount'] ?? '0.0',
      'discount': item['discount'] ?? item['Discount'] ?? '0.0',
      'net_price': item['net_price'] ?? item['Net_Price'] ?? item['netPrice'] ?? '0.0',
      'batch_number': item['batch_number'] ?? item['Batch_Number'] ?? item['batchNo'] ?? 'N/A',
      'expiry_date': item['expiry_date'] ?? item['Expiry_Date'] ?? item['expiryDate'] ?? 'N/A',
      'manufacturer': item['manufacturer'] ?? item['Manufacturer'] ?? item['maker'] ?? 'N/A',
      'category': item['category'] ?? item['Category'] ?? item['cat'] ?? 'N/A',
      'uom': item['uom'] ?? item['UOM'] ?? item['unit'] ?? 'N/A',
      'remarks': item['remarks'] ?? item['Remarks'] ?? item['note'] ?? '',
      '_raw_data': item,
    };
  }

  // ====================== FILTER LOGIC ======================
  List<Map<String, dynamic>> get filteredOrders {
    List<Map<String, dynamic>> result = orders;

    // Shop Name
    final shopQuery = shopNameFilterController.text.trim().toLowerCase();
    if (shopQuery.isNotEmpty) {
      result = result.where((order) {
        final shop = order['shop_name']?.toString().toLowerCase() ?? '';
        return shop.contains(shopQuery);
      }).toList();
    }

    // Brand
    final brandQuery = brandFilterController.text.trim().toLowerCase();
    if (brandQuery.isNotEmpty) {
      result = result.where((order) {
        final brand = order['brand']?.toString().toLowerCase() ?? '';
        return brand.contains(brandQuery);
      }).toList();
    }

    // City
    final cityQuery = cityFilterController.text.trim().toLowerCase();
    if (cityQuery.isNotEmpty) {
      result = result.where((order) {
        final city = order['city']?.toString().toLowerCase() ?? '';
        return city.contains(cityQuery);
      }).toList();
    }

    // Date Range
    if (fromDate != null || toDate != null) {
      result = result.where((order) {
        final orderDateStr = order['order_date']?.toString() ?? '';
        if (orderDateStr.isEmpty || orderDateStr == 'N/A') return false;

        try {
          final orderDate = DateFormat('yyyy-MM-dd').parse(orderDateStr);

          if (fromDate != null && orderDate.isBefore(fromDate!)) return false;
          if (toDate != null) {
            final endOfDay = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
            if (orderDate.isAfter(endOfDay)) return false;
          }
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return result;
  }

  void resetFilters() {
    shopNameFilterController.clear();
    brandFilterController.clear();
    cityFilterController.clear();
    setState(() {
      fromDate = null;
      toDate = null;
    });
  }

  // ====================== FILTER UI WIDGETS ======================
  Widget _buildCompactFilterField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    double width = 150,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          prefixIcon: Icon(icon, size: 18, color: Colors.grey[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildDateFilterField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    double width = 150,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blueGrey, width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          child: Text(
            selectedDate != null
                ? DateFormat('dd MMM yy').format(selectedDate!)
                : 'Any',
            style: TextStyle(
              fontSize: 13,
              color: selectedDate != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: const [
                Icon(Icons.filter_list_rounded, color: Colors.blueGrey, size: 20),
                SizedBox(width: 6),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCompactFilterField(
                controller: shopNameFilterController,
                label: 'Shop Name',
                icon: Icons.store_rounded,
              ),
              _buildCompactFilterField(
                controller: brandFilterController,
                label: 'Brand',
                icon: Icons.branding_watermark_rounded,
              ),
              _buildCompactFilterField(
                controller: cityFilterController,
                label: 'City',
                icon: Icons.location_city_rounded,
              ),
              _buildDateFilterField(
                label: 'From Date',
                selectedDate: fromDate,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: fromDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => fromDate = picked);
                  }
                },
              ),
              _buildDateFilterField(
                label: 'To Date',
                selectedDate: toDate,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: toDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => toDate = picked);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: resetFilters,
                child: const Text('Reset', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Apply', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showOrderDetailsDialog(Map<String, dynamic> order) async {
    final orderId = order['order_master_id']?.toString();
    if (orderId == null || orderId == 'N/A') {
      Get.snackbar('Error', 'Invalid Order ID');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await fetchOrderDetails(orderId);
    Get.back();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order['order_master_id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shop: ${order['shop_name']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${double.tryParse(order['order_amount']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildOrderDetailsContent(orderId)),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOrderDetailsContent(String orderId) {
    if (isLoadingDetails) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading order details...'),
          ],
        ),
      );
    }

    if (orderDetails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No order details found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => fetchOrderDetails(orderId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.blueGrey[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                Text(
                  orderDetails.length.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
              final detail = orderDetails[index];
              final quantity = int.tryParse(detail['quantity']?.toString() ?? '0') ?? 0;
              final totalPrice = double.tryParse(detail['total_price']?.toString() ?? '0') ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              detail['product_name']?.toString() ?? 'Unknown Product',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              detail['product_code']?.toString() ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDetailItem('Qty:', '$quantity ${detail['uom'] ?? 'Pcs'}'),
                          _buildDetailItem('Total:', 'Rs: ${totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                      if (detail['batch_number']?.toString().isNotEmpty == true && detail['batch_number'] != 'N/A')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Batch: ${detail['batch_number']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ),
                      if (detail['manufacturer']?.toString().isNotEmpty == true && detail['manufacturer'] != 'N/A')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('Manufacturer: ${detail['manufacturer']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ),
                      if (detail['remarks']?.toString().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Note: ${detail['remarks']}',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.orange[700]),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                'Rs: ${orderDetails.fold<double>(0, (sum, item) => sum + (double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0)).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Master Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Panel
          _buildFilterPanel(),

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading order master reports...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchOrders, child: const Text('Try Again')),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No order master records found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: fetchOrders, child: const Text('Refresh')),
          ],
        ),
      );
    }

    final displayOrders = filteredOrders;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade50),
            columnSpacing: 16,
            horizontalMargin: 8,
            columns: const [
              DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Shop', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: displayOrders.map((order) {
              final amount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        order['order_master_id']?.toString() ?? 'N/A',
                        style: const TextStyle(fontSize: 11, fontFamily: 'Monospace'),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        order['shop_name']?.toString() ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(order['brand']?.toString() ?? 'N/A')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        amount.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18, color: Colors.blueGrey),
                      onPressed: () => showOrderDetailsDialog(order),
                      tooltip: 'View Details',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}