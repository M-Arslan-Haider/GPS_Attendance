//
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Reports/shop_visit_report/stock_check_screen.dart';
//
// import '../../Databases/util.dart';
// import '../../Services/FirebaseServices/firebase_remote_config.dart';
//
// class ShopVisitReportDashboard extends StatefulWidget {
//   const ShopVisitReportDashboard({Key? key}) : super(key: key);
//
//   @override
//   _ShopVisitReportDashboardState createState() => _ShopVisitReportDashboardState();
// }
//
// class _ShopVisitReportDashboardState extends State<ShopVisitReportDashboard> {
//   List<Map<String, dynamic>> shopVisits = [];
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchShopVisits();
//   }
//
//   Future<void> fetchShopVisits() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });
//
//       // Your API URL
//       final String baseUrl =  Config.getApiUrlShopVisitReport;
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
//       debugPrint('📊 Response Status: ${response.statusCode}');
//       debugPrint('📊 Response Body length: ${response.body.length}');
//
//       if (response.statusCode == 200) {
//         final dynamic responseData = json.decode(response.body);
//
//         // Debug: Print the actual response
//         debugPrint('📊 Response Type: ${responseData.runtimeType}');
//         if (responseData is Map) {
//           debugPrint('📊 Response Keys: ${responseData.keys}');
//         }
//
//         // Process the response based on its format
//         List<dynamic> rawData = [];
//
//         if (responseData is List) {
//           // Direct list response
//           rawData = responseData;
//           debugPrint('✅ Direct list response with ${rawData.length} items');
//         } else if (responseData is Map) {
//           // Check for common keys that might contain the list
//           if (responseData.containsKey('data') && responseData['data'] is List) {
//             rawData = responseData['data'];
//             debugPrint('✅ Found data in "data" key with ${rawData.length} items');
//           } else if (responseData.containsKey('shopVisits') && responseData['shopVisits'] is List) {
//             rawData = responseData['shopVisits'];
//             debugPrint('✅ Found data in "shopVisits" key with ${rawData.length} items');
//           } else if (responseData.containsKey('results') && responseData['results'] is List) {
//             rawData = responseData['results'];
//             debugPrint('✅ Found data in "results" key with ${rawData.length} items');
//           } else if (responseData.containsKey('records') && responseData['records'] is List) {
//             rawData = responseData['records'];
//             debugPrint('✅ Found data in "records" key with ${rawData.length} items');
//           } else if (responseData.containsKey('items') && responseData['items'] is List) {
//             rawData = responseData['items'];
//             debugPrint('✅ Found data in "items" key with ${rawData.length} items');
//           } else {
//             // Try to find any list in the response
//             responseData.forEach((key, value) {
//               if (value is List && rawData.isEmpty) {
//                 rawData = value;
//                 debugPrint('✅ Found list in key "$key" with ${rawData.length} items');
//               }
//             });
//
//             if (rawData.isEmpty) {
//               // If it's a single object, wrap it in a list
//               if (responseData.containsKey('shop_visit_master_id') ||
//                   responseData.containsKey('shop_name')) {
//                 rawData = [responseData];
//                 debugPrint('✅ Single object wrapped in list');
//               }
//             }
//           }
//         }
//
//         // Convert to proper format
//         List<Map<String, dynamic>> processedData = [];
//
//         for (var item in rawData) {
//           if (item is Map) {
//             // Handle different field name formats
//             Map<String, dynamic> processedItem = {};
//
//             // Map fields with alternative names
//             processedItem['shop_visit_master_id'] =
//                 item['shop_visit_master_id'] ??
//                     item['Shop_Visit_Master_Id'] ??
//                     item['shopVisitMasterId'] ??
//                     item['id'] ??
//                     'N/A';
//
//             processedItem['shop_visit_date'] =
//                 item['shop_visit_date'] ??
//                     item['Shop_Visit_Date'] ??
//                     item['shopVisitDate'] ??
//                     item['date'] ??
//                     'N/A';
//
//             processedItem['shop_visit_time'] =
//                 item['shop_visit_time'] ??
//                     item['Shop_Visit_Time'] ??
//                     item['shopVisitTime'] ??
//                     item['time'] ??
//                     'N/A';
//
//             processedItem['shop_name'] =
//                 item['shop_name'] ??
//                     item['Shop_Name'] ??
//                     item['shopName'] ??
//                     item['shop'] ??
//                     'N/A';
//
//             processedItem['city'] =
//                 item['city'] ??
//                     item['City'] ??
//                     'N/A';
//
//             processedItem['user_id'] =
//                 item['user_id'] ??
//                     item['User_Id'] ??
//                     item['userId'] ??
//                     'N/A';
//
//             processedItem['booker_name'] =
//                 item['booker_name'] ??
//                     item['Booker_Name'] ??
//                     item['bookerName'] ??
//                     item['booker'] ??
//                     'N/A';
//
//             processedItem['brand'] =
//                 item['brand'] ??
//                     item['Brand'] ??
//                     'N/A';
//
//             processedItem['feedback'] =
//                 item['feedback'] ??
//                     item['Feedback'] ??
//                     '';
//
//             processedItem['latitude'] =
//                 item['latitude'] ??
//                     item['Latitude'] ??
//                     'N/A';
//
//             processedItem['longitude'] =
//                 item['longitude'] ??
//                     item['Longitude'] ??
//                     'N/A';
//
//             processedItem['address'] =
//                 item['address'] ??
//                     item['Address'] ??
//                     item['shop_address'] ??
//                     item['shopAddress'] ??
//                     'N/A';
//
//             processedItem['body'] =
//                 item['body'] ??
//                     item['Body'] ??
//                     item['image'] ??
//                     item['imageUrl'] ??
//                     '';
//
//             processedItem['owner_name'] =
//                 item['owner_name'] ??
//                     item['Owner_Name'] ??
//                     item['ownerName'] ??
//                     'N/A';
//
//             processedData.add(processedItem);
//
//             // Debug log for first item
//             if (processedData.length == 1) {
//               debugPrint('📋 First item keys: ${processedItem.keys}');
//               debugPrint('📋 First item shop_name: ${processedItem['shop_name']}');
//               debugPrint('📋 First item date: ${processedItem['shop_visit_date']}');
//             }
//           }
//         }
//
//         setState(() {
//           shopVisits = processedData;
//           isLoading = false;
//         });
//
//         debugPrint('✅ Successfully processed ${shopVisits.length} shop visits');
//       } else {
//         throw Exception('Failed to load: HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('❌ Error: $e');
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Failed to load data: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void showImage(String? imageBase64) {
//     if (imageBase64 == null || imageBase64.isEmpty) {
//       Get.snackbar('Info', 'No image available');
//       return;
//     }
//
//     try {
//       Get.dialog(
//         Dialog(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppBar(
//                 title: const Text(
//                   'Shop Image',
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//                 backgroundColor: Colors.blueGrey,
//                 iconTheme: const IconThemeData(
//                   color: Colors.white,
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                     ),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//
//               Container(
//                 width: 400,
//                 height: 400,
//                 color: Colors.black,
//                 child: Image.memory(
//                   base64Decode(imageBase64),
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.broken_image, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text('Failed to load image'),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     } catch (e) {
//       Get.snackbar('Error', 'Invalid image data');
//     }
//   }
//
//   // Function to open stock check screen
//   void openStockCheckScreen(String shopVisitMasterId, String shopName) {
//     Get.to(() => StockCheckScreen(
//       shopVisitMasterId: shopVisitMasterId,
//       shopName: shopName,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Shop Visit Dashboard',
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
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.white,
//             ),
//             onPressed: fetchShopVisits,
//           ),
//         ],
//       ),
//
//       body: _buildBody(),
//     );
//   }
//
//   Widget _buildBody() {
//     if (isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading shop visits...'),
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
//               'Failed to load data',
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
//               onPressed: fetchShopVisits,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (shopVisits.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.assignment, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'No shop visits found',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: fetchShopVisits,
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
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DataTable(
//             headingRowColor: MaterialStateColor.resolveWith(
//                   (states) => Colors.blueGrey.shade50,
//             ),
//             columnSpacing: 16,
//             horizontalMargin: 8,
//             columns: const [
//               DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
//               DataColumn(label: Text('Stocks', style: TextStyle(fontWeight: FontWeight.bold))),
//             ],
//             rows: shopVisits.map((visit) {
//               final shopVisitMasterId = visit['shop_visit_master_id']?.toString() ?? '';
//               final shopName = visit['shop_name']?.toString() ?? '';
//
//               return DataRow(
//                 cells: [
//                   // Date cell - corresponds to 1st column
//                   DataCell(
//                     SizedBox(
//                       width: 80,
//                       child: Text(
//                         visit['shop_visit_date']?.toString() ?? 'N/A',
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//
//                   // Time cell - corresponds to 2nd column
//                   DataCell(
//                     SizedBox(
//                       width: 60,
//                       child: Text(
//                         visit['shop_visit_time']?.toString() ?? 'N/A',
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//
//                   // Shop Name cell - corresponds to 3rd column
//                   DataCell(
//                     SizedBox(
//                       width: 100,
//                       child: Text(
//                         shopName,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//
//                   // Owner cell - corresponds to 4th column
//                   DataCell(
//                     SizedBox(
//                       width: 80,
//                       child: Text(
//                         visit['owner_name']?.toString() ?? 'N/A',
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//
//                   // Brand cell - corresponds to 5th column
//                   DataCell(
//                     SizedBox(
//                       width: 60,
//                       child: Text(
//                         visit['brand']?.toString() ?? 'N/A',
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//
//                   // Address cell - corresponds to 6th column
//                   DataCell(
//                     SizedBox(
//                       width: 120,
//                       child: Tooltip(
//                         message: visit['address']?.toString() ?? 'N/A',
//                         child: Text(
//                           visit['address']?.toString() ?? 'N/A',
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Image cell - corresponds to 7th column
//                   DataCell(
//                     Center(
//                       child: IconButton(
//                         icon: Icon(
//                           (visit['body']?.toString() ?? '').isNotEmpty
//                               ? Icons.image
//                               : Icons.image_not_supported,
//                           color: (visit['body']?.toString() ?? '').isNotEmpty
//                               ? Colors.blueGrey
//                               : Colors.grey,
//                           size: 20,
//                         ),
//                         onPressed: () => showImage(visit['body']?.toString()),
//                       ),
//                     ),
//                   ),
//
//                   // Stocks cell - corresponds to 8th column
//                   DataCell(
//                     Center(
//                       child: InkWell(
//                         onTap: () {
//                           if (shopVisitMasterId.isNotEmpty && shopVisitMasterId != 'N/A') {
//                             openStockCheckScreen(shopVisitMasterId, shopName);
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.blueGrey.shade600,
//                             borderRadius: BorderRadius.circular(6),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 2,
//                                 offset: const Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.inventory, size: 16, color: Colors.white),
//                               SizedBox(width: 4),
//                               Text(
//                                 'View',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
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


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Reports/shop_visit_report/stock_check_screen.dart';

import '../../Databases/util.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class ShopVisitReportDashboard extends StatefulWidget {
  const ShopVisitReportDashboard({Key? key}) : super(key: key);

  @override
  _ShopVisitReportDashboardState createState() => _ShopVisitReportDashboardState();
}

class _ShopVisitReportDashboardState extends State<ShopVisitReportDashboard> {
  List<Map<String, dynamic>> shopVisits = [];
  bool isLoading = true;
  String errorMessage = '';

  // Filter controllers
  TextEditingController shopNameFilterController = TextEditingController();
  TextEditingController cityFilterController = TextEditingController();
  TextEditingController brandFilterController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchShopVisits();
  }

  Future<void> fetchShopVisits() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String baseUrl = Config.getApiUrlShopVisitReport;
      final String url = '$baseUrl/$user_id';
      debugPrint('🔗 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      debugPrint('📊 Response Status: ${response.statusCode}');
      debugPrint('📊 Response Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];

        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            rawData = responseData['data'];
          } else if (responseData.containsKey('shopVisits') && responseData['shopVisits'] is List) {
            rawData = responseData['shopVisits'];
          } else if (responseData.containsKey('results') && responseData['results'] is List) {
            rawData = responseData['results'];
          } else if (responseData.containsKey('records') && responseData['records'] is List) {
            rawData = responseData['records'];
          } else if (responseData.containsKey('items') && responseData['items'] is List) {
            rawData = responseData['items'];
          } else {
            responseData.forEach((key, value) {
              if (value is List && rawData.isEmpty) {
                rawData = value;
              }
            });
            if (rawData.isEmpty) {
              if (responseData.containsKey('shop_visit_master_id') ||
                  responseData.containsKey('shop_name')) {
                rawData = [responseData];
              }
            }
          }
        }

        List<Map<String, dynamic>> processedData = [];
        for (var item in rawData) {
          if (item is Map) {
            Map<String, dynamic> processedItem = {};
            processedItem['shop_visit_master_id'] =
                item['shop_visit_master_id'] ??
                    item['Shop_Visit_Master_Id'] ??
                    item['shopVisitMasterId'] ??
                    item['id'] ??
                    'N/A';
            processedItem['shop_visit_date'] =
                item['shop_visit_date'] ??
                    item['Shop_Visit_Date'] ??
                    item['shopVisitDate'] ??
                    item['date'] ??
                    'N/A';
            processedItem['shop_visit_time'] =
                item['shop_visit_time'] ??
                    item['Shop_Visit_Time'] ??
                    item['shopVisitTime'] ??
                    item['time'] ??
                    'N/A';
            processedItem['shop_name'] =
                item['shop_name'] ??
                    item['Shop_Name'] ??
                    item['shopName'] ??
                    item['shop'] ??
                    'N/A';
            processedItem['city'] = item['city'] ?? item['City'] ?? 'N/A';
            processedItem['user_id'] =
                item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? 'N/A';
            processedItem['booker_name'] =
                item['booker_name'] ?? item['Booker_Name'] ?? item['bookerName'] ?? item['booker'] ?? 'N/A';
            processedItem['brand'] = item['brand'] ?? item['Brand'] ?? 'N/A';
            processedItem['feedback'] = item['feedback'] ?? item['Feedback'] ?? '';
            processedItem['latitude'] = item['latitude'] ?? item['Latitude'] ?? 'N/A';
            processedItem['longitude'] = item['longitude'] ?? item['Longitude'] ?? 'N/A';
            processedItem['address'] =
                item['address'] ?? item['Address'] ?? item['shop_address'] ?? item['shopAddress'] ?? 'N/A';
            processedItem['body'] =
                item['body'] ?? item['Body'] ?? item['image'] ?? item['imageUrl'] ?? '';
            processedItem['owner_name'] = item['owner_name'] ?? item['Owner_Name'] ?? item['ownerName'] ?? 'N/A';

            processedData.add(processedItem);
          }
        }

        setState(() {
          shopVisits = processedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void showImage(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      Get.snackbar('Info', 'No image available');
      return;
    }
    try {
      Get.dialog(
        Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Shop Image', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueGrey,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back()),
                ],
              ),
              Container(
                width: 400,
                height: 400,
                color: Colors.black,
                child: Image.memory(
                  base64Decode(imageBase64),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Failed to load image'),
                          ],
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Invalid image data');
    }
  }

  void openStockCheckScreen(String shopVisitMasterId, String shopName) {
    Get.to(() => StockCheckScreen(shopVisitMasterId: shopVisitMasterId, shopName: shopName));
  }

  // Filter panel
  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(12.0),
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
          // Compact title
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: const [
                Icon(Icons.filter_list_rounded, color: Colors.indigo, size: 20),
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
              // Shop Name
              _buildCompactFilterField(
                controller: shopNameFilterController,
                label: 'Shop Name',
                icon: Icons.store_rounded,
                width: 160,
              ),

              // City
              _buildCompactFilterField(
                controller: cityFilterController,
                label: 'City',
                icon: Icons.location_city_rounded,
                width: 140,
              ),

              // Brand
              _buildCompactFilterField(
                controller: brandFilterController,
                label: 'Brand',
                icon: Icons.branding_watermark_rounded,
                width: 140,
              ),

              // Date Picker - smaller
              SizedBox(
                width: 160,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
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
                        borderSide: const BorderSide(color: Colors.indigo, width: 1.8),
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
                        fontSize: 14,
                        color: selectedDate != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Buttons - compact
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  shopNameFilterController.clear();
                  cityFilterController.clear();
                  brandFilterController.clear();
                  setState(() => selectedDate = null);
                },
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

// Compact reusable field
  Widget _buildCompactFilterField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    double width = 160,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Visit Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchShopVisits),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading shop visits...'),
        ]),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: fetchShopVisits, child: const Text('Try Again')),
        ]),
      );
    }

    if (shopVisits.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.assignment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No shop visits found', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: fetchShopVisits, child: const Text('Refresh')),
        ]),
      );
    }

    // Apply filters
    List<Map<String, dynamic>> filteredVisits = shopVisits.where((visit) {
      final shopName = visit['shop_name']?.toString().toLowerCase() ?? '';
      final city = visit['city']?.toString().toLowerCase() ?? '';
      final brand = visit['brand']?.toString().toLowerCase() ?? '';
      final date = visit['shop_visit_date']?.toString() ?? '';

      bool matchesShop = shopName.contains(shopNameFilterController.text.toLowerCase());
      bool matchesCity = city.contains(cityFilterController.text.toLowerCase());
      bool matchesBrand = brand.contains(brandFilterController.text.toLowerCase());
      bool matchesDate = selectedDate == null || date.startsWith(DateFormat('yyyy-MM-dd').format(selectedDate!));

      return matchesShop && matchesCity && matchesBrand && matchesDate;
    }).toList();

    return Column(
      children: [
        _buildFilterPanel(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade50),
                  columnSpacing: 16,
                  horizontalMargin: 8,
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Stocks', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredVisits.map((visit) {
                    final shopVisitMasterId = visit['shop_visit_master_id']?.toString() ?? '';
                    final shopName = visit['shop_name']?.toString() ?? '';

                    return DataRow(cells: [
                      DataCell(SizedBox(width: 80, child: Text(visit['shop_visit_date']?.toString() ?? 'N/A', overflow: TextOverflow.ellipsis))),
                      DataCell(SizedBox(width: 60, child: Text(visit['shop_visit_time']?.toString() ?? 'N/A', overflow: TextOverflow.ellipsis))),
                      DataCell(SizedBox(width: 100, child: Text(shopName, overflow: TextOverflow.ellipsis))),
                      DataCell(SizedBox(width: 80, child: Text(visit['owner_name']?.toString() ?? 'N/A', overflow: TextOverflow.ellipsis))),
                      DataCell(SizedBox(width: 60, child: Text(visit['brand']?.toString() ?? 'N/A', overflow: TextOverflow.ellipsis))),
                      DataCell(SizedBox(
                        width: 120,
                        child: Tooltip(message: visit['address']?.toString() ?? 'N/A', child: Text(visit['address']?.toString() ?? 'N/A', overflow: TextOverflow.ellipsis, maxLines: 2)),
                      )),
                      DataCell(Center(
                        child: IconButton(
                          icon: Icon(
                            (visit['body']?.toString() ?? '').isNotEmpty ? Icons.image : Icons.image_not_supported,
                            color: (visit['body']?.toString() ?? '').isNotEmpty ? Colors.blueGrey : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => showImage(visit['body']?.toString()),
                        ),
                      )),
                      DataCell(Center(
                        child: InkWell(
                          onTap: () {
                            if (shopVisitMasterId.isNotEmpty && shopVisitMasterId != 'N/A') {
                              openStockCheckScreen(shopVisitMasterId, shopName);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade600,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text('View', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
