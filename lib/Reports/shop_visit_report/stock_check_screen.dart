

// lib/Reports/shop_visit_report/stock_check_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockCheckScreen extends StatefulWidget {
  final String shopVisitMasterId;
  final String shopName;

  const StockCheckScreen({
    Key? key,
    required this.shopVisitMasterId,
    required this.shopName,
  }) : super(key: key);

  @override
  _StockCheckScreenState createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  List<Map<String, dynamic>> stockItems = [];
  bool isLoading = true;
  String errorMessage = '';
  String rawResponse = ''; // For debugging

  @override
  void initState() {
    super.initState();
    fetchStockCheckItems();
  }

  Future<void> fetchStockCheckItems() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
        rawResponse = '';
      });

      // CORRECTED API URL - Remove the typo and use the actual ID
      final url = 'https://cloud.metaxperts.net:8443/erp/valor_trading/stockcheckitemsget/get/${widget.shopVisitMasterId}';
      debugPrint('🔗 Fetching stock items from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Stock API Status: ${response.statusCode}');
      rawResponse = response.body;
      debugPrint('📊 Raw Response: $rawResponse');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        debugPrint('📊 Stock Response Type: ${responseData.runtimeType}');

        // Print all keys for debugging
        if (responseData is Map) {
          debugPrint('📊 Response Keys: ${responseData.keys}');
          // Print first few values to see structure
          responseData.forEach((key, value) {
            debugPrint('📊 Key: $key, Type: ${value.runtimeType}');
            if (value is List) {
              debugPrint('📊 List length: ${value.length}');
              if (value.isNotEmpty && value[0] is Map) {
                debugPrint('📊 First item keys: ${(value[0] as Map).keys}');
              }
            }
          });
        }

        List<Map<String, dynamic>> processedData = [];

        // Handle different response formats
        if (responseData is List) {
          // Direct list response
          debugPrint('✅ Response is a List with ${responseData.length} items');
          for (var item in responseData) {
            if (item is Map) {
              final Map<String, dynamic> convertedItem = {};
              item.forEach((key, value) {
                convertedItem[key.toString()] = value;
              });
              processedData.add(_processStockItem(convertedItem));
            }
          }
        } else if (responseData is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> convertedResponse = {};
          responseData.forEach((key, value) {
            convertedResponse[key.toString()] = value;
          });

          debugPrint('✅ Response is a Map with keys: ${convertedResponse.keys}');

          // Try ALL possible list keys
          final List<String> possibleListKeys = [
            'data',
            'items',
            'stock_items',
            'stockItems',
            'stockCheckItems',
            'products',
            'stock',
            'inventory',
            'list',
            'records',
            'results'
          ];

          bool foundList = false;

          for (var key in possibleListKeys) {
            if (convertedResponse.containsKey(key) && convertedResponse[key] is List) {
              debugPrint('✅ Found list in key: "$key"');
              final dataList = convertedResponse[key] as List;

              for (var item in dataList) {
                if (item is Map) {
                  final Map<String, dynamic> convertedItem = {};
                  item.forEach((k, v) {
                    convertedItem[k.toString()] = v;
                  });
                  processedData.add(_processStockItem(convertedItem));
                }
              }
              foundList = true;
              break;
            }
          }

          // If no standard list keys found, look for ANY list in the response
          if (!foundList) {
            debugPrint('🔍 Looking for any list in response...');
            convertedResponse.forEach((key, value) {
              if (value is List && !foundList) {
                debugPrint('✅ Found list in key: "$key" with ${value.length} items');
                for (var item in value) {
                  if (item is Map) {
                    final Map<String, dynamic> convertedItem = {};
                    item.forEach((k, v) {
                      convertedItem[k.toString()] = v;
                    });
                    processedData.add(_processStockItem(convertedItem));
                  }
                }
                foundList = true;
              }
            });
          }

          // If still no list found, maybe it's a single object
          if (!foundList) {
            debugPrint('ℹ️ No list found, treating as single object');
            processedData.add(_processStockItem(convertedResponse));
          }
        }

        setState(() {
          stockItems = processedData;
          isLoading = false;
        });

        debugPrint('✅ Successfully loaded ${stockItems.length} stock items');

        // Debug: Print first few items if available
        if (stockItems.isNotEmpty) {
          debugPrint('📋 First item: ${stockItems[0]}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Stock API Error: $e');
      debugPrint('📊 Raw error response: $rawResponse');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load stock items: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Map<String, dynamic> _processStockItem(Map<String, dynamic> item) {
    debugPrint('📋 Processing item with keys: ${item.keys}');

    // Try to find product-related fields with many variations
    String productName = 'N/A';
    List<String> productKeys = [
      'product_name', 'productName', 'Product_Name', 'product', 'Product',
      'item_name', 'itemName', 'Item_Name', 'item', 'Item',
      'name', 'Name', 'description', 'Description', 'desc', 'Desc'
    ];

    for (var key in productKeys) {
      if (item.containsKey(key) && item[key] != null) {
        productName = item[key].toString();
        debugPrint('✅ Found product name in key "$key": $productName');
        break;
      }
    }

    return {
      'product_name': productName,
      'brand': item['brand'] ?? item['Brand'] ?? item['brandName'] ?? 'N/A',
      'category': item['category'] ?? item['Category'] ?? item['type'] ?? item['Type'] ?? 'N/A',
      'quantity': item['quantity'] ?? item['Quantity'] ?? item['qty'] ?? item['Qty'] ?? item['stock'] ?? '0',
      'unit': item['unit'] ?? item['Unit'] ?? item['uom'] ?? item['UOM'] ?? 'pcs',
      'expiry_date': item['expiry_date'] ?? item['Expiry_Date'] ?? item['expiryDate'] ?? 'N/A',
      'batch_no': item['batch_no'] ?? item['Batch_No'] ?? item['batchNo'] ?? item['batch'] ?? 'N/A',
      'remarks': item['remarks'] ?? item['Remarks'] ?? item['note'] ?? item['Note'] ?? '',
      'checked_date': item['checked_date'] ?? item['Checked_Date'] ?? item['checkedDate'] ?? 'N/A',
      'checked_by': item['checked_by'] ?? item['Checked_By'] ?? item['checkedBy'] ?? 'N/A',
      // Add all original fields for debugging
      'raw_data': item,
    };
  }

  void _showDebugInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('API Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Shop Visit ID:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.shopVisitMasterId),
              const SizedBox(height: 16),
              const Text('API URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('https://cloud.metaxperts.net:8443/erp/valor_trading/stockcheckitemsget/get/${widget.shopVisitMasterId}'),
              const SizedBox(height: 16),
              const Text('Raw Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rawResponse.isNotEmpty ? rawResponse : 'No response yet',
                  style: const TextStyle(fontFamily: 'Monospace', fontSize: 10),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Processed Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${stockItems.length} items'),
              if (stockItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('First item keys:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(stockItems[0].keys.join(', ')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stock Check - ${widget.shopName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.bug_report, color: Colors.white),
          //   onPressed: _showDebugInfo,
          //   tooltip: 'Debug Info',
          // ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchStockCheckItems,
          ),
        ],
      ),
      body: _buildStockContent(),
    );
  }

  Widget _buildStockContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading stock check items...'),
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
            const Text(
              'Failed to load stock items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchStockCheckItems,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (stockItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No stock check items found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Shop Visit ID: ${widget.shopVisitMasterId}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: fetchStockCheckItems,
                  child: const Text('Refresh'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _showDebugInfo,
                  child: const Text('Show Debug Info'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary card
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Items: ${stockItems.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.shopName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                // IconButton(
                //   icon: const Icon(Icons.bug_report),
                //   onPressed: _showDebugInfo,
                //   tooltip: 'Debug',
                // ),
              ],
            ),
          ),
        ),

        // Data table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blueGrey.shade50,
                  ),
                  columnSpacing: 16,
                  horizontalMargin: 8,
                  columns: const [
                    DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                    // DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                    // DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                    // DataColumn(label: Text('Expiry', style: TextStyle(fontWeight: FontWeight.bold))),
                    // DataColumn(label: Text('Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: stockItems.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 250,
                            child: Text(
                              item['product_name']?.toString() ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // DataCell(
                        //   SizedBox(
                        //     width: 80,
                        //     child: Text(
                        //       item['brand']?.toString() ?? 'N/A',
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ),
                        // ),
                        // DataCell(
                        //   SizedBox(
                        //     width: 80,
                        //     child: Text(
                        //       item['category']?.toString() ?? 'N/A',
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ),
                        // ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['quantity']?.toString() ?? '0',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(Text(item['unit']?.toString() ?? 'pcs')),
                        // DataCell(
                        //   SizedBox(
                        //     width: 80,
                        //     child: Text(
                        //       item['expiry_date']?.toString() ?? 'N/A',
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ),
                        // ),
                        // DataCell(
                        //   SizedBox(
                        //     width: 80,
                        //     child: Text(
                        //       item['batch_no']?.toString() ?? 'N/A',
                        //       overflow: TextOverflow.ellipsis,
                        //       style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                        //     ),
                        //   ),
                        // ),
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