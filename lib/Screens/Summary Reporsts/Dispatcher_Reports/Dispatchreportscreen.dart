import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Databases/util.dart';

class DispatchReportScreen extends StatefulWidget {
  const DispatchReportScreen({Key? key}) : super(key: key);

  @override
  _DispatchReportScreenState createState() => _DispatchReportScreenState();
}

class _DispatchReportScreenState extends State<DispatchReportScreen> {
  List<Map<String, dynamic>> dispatches = [];
  List<String> allColumns = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDispatches();
  }

  // ====================== API FETCH ======================
  Future<void> fetchDispatches() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String url =
          'https://cloud.metaxperts.net:8443/erp/valor_trading/dispatchmasterd/get/$user_id';
      debugPrint('🔗 Fetching dispatch from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Dispatch API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic rawResponse = json.decode(response.body);
        debugPrint('📊 Response Type: ${rawResponse.runtimeType}');

        List<Map<String, dynamic>> processedData = [];

        List<dynamic> rawList = [];

        if (rawResponse is List) {
          rawList = rawResponse;
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);
          const possibleListKeys = [
            'items', 'data', 'dispatches', 'dispatch_masters',
            'dispatchMasters', 'results', 'records', 'list'
          ];
          bool found = false;
          for (var key in possibleListKeys) {
            if (mapResponse.containsKey(key) && mapResponse[key] is List) {
              debugPrint('✅ Found data in key: "$key"');
              rawList = mapResponse[key] as List;
              found = true;
              break;
            }
          }
          if (!found) {
            mapResponse.forEach((key, value) {
              if (value is List && !found) {
                debugPrint('✅ Found list in key: "$key"');
                rawList = value;
                found = true;
              }
            });
          }
        }

        // Collect ALL unique column keys from every row
        final Set<String> columnSet = {};
        for (var item in rawList) {
          if (item is Map) {
            columnSet.addAll(item.keys.map((k) => k.toString()));
          }
        }

        // Process rows — keep ALL raw data, also extract dispatch_status
        for (var item in rawList) {
          if (item is Map) {
            final row = Map<String, dynamic>.from(item);
            final status = (row['dispatch_status'] ??
                row['Dispatch_Status'] ??
                row['DISPATCH_STATUS'] ??
                row['dispatchStatus'] ??
                '')
                .toString()
                .toUpperCase();
            if (status == 'DISPATCHED') {
              processedData.add(row);
            }
          }
        }

        // Calculate total amount
        // Build ordered column list — put key columns first
        const priorityColumns = [
          'dispatch_master_id', 'DISPATCH_MASTER_ID',
          'shop_name', 'SHOP_NAME',
          'dispatch_date', 'DISPATCH_DATE',
          'dispatch_status', 'DISPATCH_STATUS',
          'total_amount', 'TOTAL_AMOUNT',
          'vehicle_number', 'VEHICLE_NUMBER',
          'driver_name', 'DRIVER_NAME',
          'city', 'CITY',
          'owner_name', 'OWNER_NAME',
          'shop_address', 'SHOP_ADDRESS',
          'dispatch_time', 'DISPATCH_TIME',
          'order_master_id', 'ORDER_MASTER_ID',
          'user_id', 'USER_ID',
        ];

        final ordered = <String>[];
        for (var p in priorityColumns) {
          if (columnSet.contains(p)) ordered.add(p);
        }
        for (var col in columnSet) {
          if (!ordered.contains(col)) ordered.add(col);
        }

        setState(() {
          dispatches = processedData;
          allColumns = ordered;
          isLoading = false;
        });

        debugPrint('✅ Loaded ${dispatches.length} dispatched records');
        debugPrint('📋 Columns: $allColumns');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Dispatch API Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load dispatches: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ====================== HELPERS ======================
  String _formatColumnHeader(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DISPATCHED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  bool _isStatusColumn(String col) {
    return col.toLowerCase().contains('status');
  }

  bool _isAmountColumn(String col) {
    return col.toLowerCase().contains('amount') ||
        col.toLowerCase().contains('total');
  }

  // ====================== DETAIL BOTTOM SHEET ======================
  void showDispatchDetailsDialog(Map<String, dynamic> row) {
    // Dispatch No (e.g. DIS-0042)
    final dispatchNo = (row['dispatch_no'] ??
        row['DISPATCH_NO'] ??
        row['dispatchNo'] ??
        row['dispatch_number'] ??
        row['DISPATCH_NUMBER'] ??
        'N/A')
        .toString();

    // Dispatch ID (numeric master id)
    final dispatchId = (row['dispatch_master_id'] ??
        row['DISPATCH_MASTER_ID'] ??
        row['id'] ??
        'N/A')
        .toString();

    final shopName = (row['shop_name'] ?? row['SHOP_NAME'] ?? 'N/A').toString();

    // Amount — try dispatch_amount first (what API actually returns), fallback to total_amount
    final amount = double.tryParse(
        (row['dispatch_amount'] ??
            row['DISPATCH_AMOUNT'] ??
            row['total_amount'] ??
            row['TOTAL_AMOUNT'] ??
            row['amount'] ??
            '0')
            .toString()) ??
        0.0;

    final status = (row['dispatch_status'] ??
        row['DISPATCH_STATUS'] ??
        row['dispatchStatus'] ??
        'N/A')
        .toString();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dispatch Details',
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
            const SizedBox(height: 4),
            // Summary Card
            Card(
              color: Colors.blueGrey.shade50,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispatch #$dispatchId',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(shopName,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                _statusColor(status).withOpacity(0.4)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _statusColor(status)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rs: ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ALL Fields
            const Text(
              'All Fields',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 14),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: row.entries.map((entry) {
                    final label = _formatColumnHeader(entry.key);
                    final value = entry.value?.toString() ?? 'N/A';
                    final isStatus = _isStatusColumn(entry.key);
                    final isAmt = _isAmountColumn(entry.key);
                    return _buildDetailRow(label, value,
                        isStatus: isStatus, isAmount: isAmt);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isStatus = false, bool isAmount = false}) {
    Widget valueWidget;

    if (isStatus) {
      valueWidget = Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _statusColor(value).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: _statusColor(value).withOpacity(0.4)),
        ),
        child: Text(
          value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _statusColor(value)),
        ),
      );
    } else if (isAmount) {
      valueWidget = Text(
        value,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.green),
      );
    } else {
      valueWidget = Text(value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  // ====================== MAIN BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dispatch Report',
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchDispatches,
          ),
        ],
      ),
      body: _buildContent(),
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
            Text('Loading dispatch reports...'),
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
            const Text('Failed to load dispatches',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: fetchDispatches,
                child: const Text('Try Again')),
          ],
        ),
      );
    }

    if (dispatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No dispatched records found',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: fetchDispatches,
                child: const Text('Refresh')),
          ],
        ),
      );
    }

    if (allColumns.isEmpty) {
      return const Center(child: Text('No columns detected from API.'));
    }

    final displayDispatches = dispatches;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blueGrey.shade700),
            dataRowColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blueGrey.shade50;
              }
              return Colors.white;
            }),
            columnSpacing: 20,
            horizontalMargin: 10,
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            // ── Dynamic columns from API + Action column ──
            columns: [
              ...allColumns.map(
                    (col) => DataColumn(
                  label: Text(
                    _formatColumnHeader(col),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  numeric: _isAmountColumn(col),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Action',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            // ── Dynamic rows ──
            rows: displayDispatches.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isEven = index % 2 == 0;

              return DataRow(
                color: MaterialStateColor.resolveWith(
                      (states) => isEven
                      ? Colors.white
                      : Colors.blueGrey.shade50,
                ),
                cells: [
                  ...allColumns.map((col) {
                    final raw = row[col];
                    final value = raw?.toString() ?? '-';
                    final isStatus = _isStatusColumn(col);
                    final isAmt = _isAmountColumn(col);

                    Widget cellChild;

                    if (isStatus && value != '-') {
                      cellChild = Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                          _statusColor(value).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(value),
                          ),
                        ),
                      );
                    } else if (isAmt && value != '-') {
                      cellChild = Text(
                        value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      );
                    } else {
                      cellChild = SizedBox(
                        width: 110,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }

                    return DataCell(cellChild);
                  }),
                  // Action cell
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility,
                          size: 18, color: Colors.blueGrey),
                      onPressed: () =>
                          showDispatchDetailsDialog(row),
                      tooltip: 'View All Details',
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