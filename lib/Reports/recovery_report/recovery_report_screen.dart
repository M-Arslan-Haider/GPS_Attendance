import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../Databases/util.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class RecoveryFormDashboard extends StatefulWidget {
  const RecoveryFormDashboard({Key? key}) : super(key: key);

  @override
  _RecoveryFormDashboardState createState() => _RecoveryFormDashboardState();
}

class _RecoveryFormDashboardState extends State<RecoveryFormDashboard> {
  List<Map<String, dynamic>> recoveryForms = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRecoveryForms();
  }

  Future<void> fetchRecoveryForms() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String baseUrl = Config.getApiUrlRecoveryFormReport;
      final String url = '$baseUrl/$user_id';
      debugPrint('🔗 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      debugPrint('📊 Response Status: ${response.statusCode}');
      debugPrint('📊 Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> rawData = [];

        // Handle different response formats
        if (responseData is List) {
          rawData = responseData;
        } else if (responseData is Map) {
          // Try common response keys
          if (responseData.containsKey('data') && responseData['data'] is List) {
            rawData = responseData['data'];
          } else if (responseData.containsKey('recoveryForms') && responseData['recoveryForms'] is List) {
            rawData = responseData['recoveryForms'];
          } else if (responseData.containsKey('results') && responseData['results'] is List) {
            rawData = responseData['results'];
          } else if (responseData.containsKey('records') && responseData['records'] is List) {
            rawData = responseData['records'];
          } else if (responseData.containsKey('items') && responseData['items'] is List) {
            rawData = responseData['items'];
          } else {
            // If no known structure, check if it's a single record
            if (responseData.containsKey('shop_name') || responseData.containsKey('cash_recovery')) {
              rawData = [responseData];
            }
          }
        }

        List<Map<String, dynamic>> processedData = [];
        for (var item in rawData) {
          if (item is Map) {
            Map<String, dynamic> processedItem = {};

            // Extract fields based on your API response
            processedItem['shop_name'] =
                item['shop_name'] ??
                    item['Shop_Name'] ??
                    item['shopName'] ??
                    item['shop'] ??
                    'N/A';
            processedItem['date'] =
                item['recovery_date'] ??
                    item['recoveryDate'] ??
                    item['date'] ??
                    item['Date'] ??
                    'N/A';
            processedItem['cash_recovery'] =
                item['cash_recovery'] ??
                    item['Cash_Recovery'] ??
                    item['cashRecovery'] ??
                    item['collected_amount'] ??
                    item['Collected_Amount'] ??
                    '0';

            processedData.add(processedItem);
          }
        }

        setState(() {
          recoveryForms = processedData;
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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Forms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchRecoveryForms,
          ),
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
          Text('Loading recovery forms...'),
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
          ElevatedButton(onPressed: fetchRecoveryForms, child: const Text('Try Again')),
        ]),
      );
    }

    if (recoveryForms.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No recovery forms found', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: fetchRecoveryForms, child: const Text('Refresh')),
        ]),
      );
    }

    return Column(
      children: [
        // Summary Card

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade50),
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    DataColumn(label: Text('Cash Recovery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                  rows: recoveryForms.map((form) {
                    final cashRecovery = double.tryParse(form['cash_recovery'].toString()) ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              form['shop_name']?.toString() ?? 'N/A',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              form['date']?.toString() ?? 'N/A',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cashRecovery > 0 ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: cashRecovery > 0 ? Colors.green.shade200 : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              'Rs ${cashRecovery.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: cashRecovery > 0 ? Colors.green.shade800 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
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