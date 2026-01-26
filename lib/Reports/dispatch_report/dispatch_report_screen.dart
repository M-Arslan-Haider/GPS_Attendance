import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Services/FirebaseServices/firebase_remote_config.dart';

import '../../Databases/util.dart';

class DispatchOrdersDashboard extends StatefulWidget {
  const DispatchOrdersDashboard({Key? key}) : super(key: key);

  @override
  _DispatchOrdersDashboardState createState() => _DispatchOrdersDashboardState();
}

class _DispatchOrdersDashboardState extends State<DispatchOrdersDashboard> {
  List<Map<String, dynamic>> dispatchOrders = [];
  bool isLoading = true;
  bool isLoadingDetails = false;
  String errorMessage = '';

  // Filter Controllers & Variables
  final TextEditingController shopNameFilterController = TextEditingController();
  final TextEditingController brandFilterController = TextEditingController();
  final TextEditingController userIdFilterController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fetchDispatchOrders();
  }

  @override
  void dispose() {
    shopNameFilterController.dispose();
    brandFilterController.dispose();
    userIdFilterController.dispose();
    super.dispose();
  }

  Future<void> fetchDispatchOrders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String baseUrl = Config.getApiUrlDispatchReport;
      debugPrint("🌐 BASE URL: $baseUrl");
      debugPrint("👤 USER ID: $user_id");

      if (!baseUrl.startsWith("http")) {
        throw Exception("Base URL is invalid: $baseUrl");
      }

      final uri = Uri.parse(baseUrl).replace(
        path: "${Uri.parse(baseUrl).path}/$user_id",
      );

      debugPrint("🔗 FINAL URL: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("📡 STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final rawResponse = json.decode(response.body);

        List<Map<String, dynamic>> processedData = [];

        if (rawResponse is List) {
          for (var item in rawResponse) {
            if (item is Map) processedData.add(_processOrderItem(item));
          }
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);

          for (var value in mapResponse.values) {
            if (value is List) {
              for (var item in value) {
                if (item is Map) processedData.add(_processOrderItem(item));
              }
              break;
            }
          }
        }

        final dispatchData = processedData.where((order) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          return status.contains('dispatch');
        }).toList();

        setState(() {
          dispatchOrders = dispatchData;
          isLoading = false;
        });
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  Map<String, dynamic> _processOrderItem(dynamic rawItem) {
    final item = Map<String, dynamic>.from(rawItem ?? {});

    return {
      'user_id': item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? item['user'] ?? 'N/A',
      'shop_name': item['shop_name'] ?? item['Shop_Name'] ?? item['shopName'] ?? item['shop'] ?? 'N/A',
      'brand': item['brand'] ?? item['Brand'] ?? item['product_brand'] ?? item['productBrand'] ?? 'N/A',
      'status': item['status'] ?? item['Status'] ?? item['order_status'] ?? item['Order_Status'] ?? 'N/A',
      'order_master_id': item['order_master_id'] ?? item['Order_Master_Id'] ?? item['orderMasterId'] ?? item['id'] ?? 'N/A',
      'order_date': item['order_date'] ?? item['Order_Date'] ?? item['orderDate'] ?? item['date'] ?? 'N/A',
      'order_time': item['order_time'] ?? item['Order_Time'] ?? item['orderTime'] ?? item['time'] ?? 'N/A',
      'total_amount': item['total_amount'] ?? item['Total_Amount'] ?? item['orderAmount'] ?? item['amount'] ?? '0.0',
      'payment_status': item['payment_status'] ?? item['Payment_Status'] ?? item['paymentStatus'] ?? 'N/A',
      'delivery_address': item['delivery_address'] ?? item['Delivery_Address'] ?? item['deliveryAddress'] ?? 'N/A',
      'customer_name': item['customer_name'] ?? item['Customer_Name'] ?? item['customerName'] ?? 'N/A',
      'phone': item['phone'] ?? item['Phone'] ?? item['mobile'] ?? item['contact_number'] ?? 'N/A',
      '_raw_data': item,
    };
  }

  // ====================== FILTER LOGIC ======================
  List<Map<String, dynamic>> get filteredOrders {
    List<Map<String, dynamic>> result = dispatchOrders;

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

    // User ID
    final userQuery = userIdFilterController.text.trim().toLowerCase();
    if (userQuery.isNotEmpty) {
      result = result.where((order) {
        final userId = order['user_id']?.toString().toLowerCase() ?? '';
        return userId.contains(userQuery);
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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("dispatch") || s.contains("delivered")) return Colors.green;
    if (s.contains("pending")) return Colors.orange;
    if (s.contains("cancel") || s.contains("reject")) return Colors.red;
    if (s.contains("process")) return Colors.blue;
    return Colors.grey;
  }

  void showOrderDetailsDialog(Map<String, dynamic> order) {
    final allData = order['_raw_data'] ?? {};

    // Group fields by category
    Map<String, List<MapEntry<String, dynamic>>> groupedData = {
      'Order Information': [],
      'Customer Details': [],
      'Shop & Brand': [],
      'Payment Information': [],
      'Other Details': [],
    };

    // Define field categories
    final orderInfoFields = ['order_master_id', 'order_date', 'order_time', 'status', 'user_id'];
    final customerFields = ['customer_name', 'phone', 'delivery_address'];
    final shopFields = ['shop_name', 'brand'];
    final paymentFields = ['total_amount', 'payment_status', 'payment_method'];

    // Group the data
    allData.entries.forEach((entry) {
      final key = entry.key.toString();

      if (orderInfoFields.contains(key)) {
        groupedData['Order Information']!.add(entry);
      } else if (customerFields.contains(key)) {
        groupedData['Customer Details']!.add(entry);
      } else if (shopFields.contains(key)) {
        groupedData['Shop & Brand']!.add(entry);
      } else if (paymentFields.contains(key)) {
        groupedData['Payment Information']!.add(entry);
      } else {
        groupedData['Other Details']!.add(entry);
      }
    });

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
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
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

            // Order Summary Card
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
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${order['status']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getStatusColor(order['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display grouped data
                    ...groupedData.entries.where((group) => group.value.isNotEmpty).map<Widget>((group) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  group.key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Divider(color: Colors.blueGrey.shade300),
                                ),
                              ],
                            ),
                          ),

                          // Section Content
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                ...group.value.map<Widget>((entry) {
                                  final key = entry.key.toString();
                                  final value = entry.value?.toString() ?? '';

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: group.value.last == entry
                                            ? BorderSide.none
                                            : BorderSide(color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _formatKey(key),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Close button
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatKey(String key) {
    // Convert snake_case or camelCase to Title Case with spaces
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dispatch Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchDispatchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Text('Loading dispatch orders...'),
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
            const Text('Failed to load data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchDispatchOrders, child: const Text('Try Again')),
          ],
        ),
      );
    }

    if (dispatchOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No dispatch orders found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: fetchDispatchOrders, child: const Text('Refresh')),
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
              DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: displayOrders.map((order) {
              final userId = order['user_id']?.toString() ?? 'N/A';
              final shopName = order['shop_name']?.toString() ?? 'N/A';
              final brand = order['brand']?.toString() ?? 'N/A';
              final status = order['status']?.toString() ?? 'N/A';

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        userId,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        shopName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      brand,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
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