import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Databases/util.dart';

class RecoveryDispatchReportScreen extends StatefulWidget {
  const RecoveryDispatchReportScreen({Key? key}) : super(key: key);

  @override
  _RecoveryDispatchReportScreenState createState() =>
      _RecoveryDispatchReportScreenState();
}

class _RecoveryDispatchReportScreenState
    extends State<RecoveryDispatchReportScreen> {
  List<Map<String, dynamic>> records = [];
  List<String> allColumns = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  // ====================== API FETCH ======================
  Future<void> fetchRecords() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String url =
          'https://cloud.metaxperts.net:8443/erp/valor_trading/recoveryformget/get/$user_id';
      debugPrint('🔗 Fetching recovery dispatch from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Recovery API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic rawResponse = json.decode(response.body);
        debugPrint('📊 Response Type: ${rawResponse.runtimeType}');

        List<dynamic> rawList = [];

        if (rawResponse is List) {
          rawList = rawResponse;
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);
          const possibleListKeys = [
            'items', 'data', 'orders', 'order_masters',
            'orderMasters', 'results', 'records', 'list'
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

        // Process all rows
        final List<Map<String, dynamic>> processedData = [];
        for (var item in rawList) {
          if (item is Map) {
            processedData.add(Map<String, dynamic>.from(item));
          }
        }

        // Columns to exclude
        const excludedColumns = {
          'user_id',           'USER_ID',           'userId',
          'recovery_id',       'RECOVERY_ID',       'recoveryId',
          'current_balance',   'CURRENT_BALANCE',   'currentBalance',  'current_bal', 'CURRENT_BAL',
          'net_balance',       'NET_BALANCE',       'netBalance',      'net_bal',     'NET_BAL',
        };

        // Build ordered column list — priority columns first, excluding unwanted
        const priorityColumns = [
          'order_master_id',   'ORDER_MASTER_ID',
          'order_no',          'ORDER_NO',
          'shop_name',         'SHOP_NAME',
          'order_date',        'ORDER_DATE',
          'order_status',      'ORDER_STATUS',
          'dispatch_status',   'DISPATCH_STATUS',
          'total_amount',      'TOTAL_AMOUNT',
          'order_amount',      'ORDER_AMOUNT',
          'recovery_amount',   'RECOVERY_AMOUNT',
          'city',              'CITY',
          'owner_name',        'OWNER_NAME',
          'phone_no',          'PHONE_NO',
        ];

        final ordered = <String>[];
        for (var p in priorityColumns) {
          if (columnSet.contains(p) && !excludedColumns.contains(p)) {
            ordered.add(p);
          }
        }
        for (var col in columnSet) {
          if (!ordered.contains(col) && !excludedColumns.contains(col)) {
            ordered.add(col);
          }
        }

        setState(() {
          records = processedData;
          allColumns = ordered;
          isLoading = false;
        });

        debugPrint('✅ Loaded ${records.length} recovery records');
        debugPrint('📋 Columns: $allColumns');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Recovery API Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load records: $e',
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
      case 'RECOVERED':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  bool _isStatusColumn(String col) =>
      col.toLowerCase().contains('status');

  bool _isAmountColumn(String col) {
    final c = col.toLowerCase();
    return c.contains('amount') || c.contains('total');
  }

  // ====================== MAIN BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recovery Dispatch Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchRecords,
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
            Text('Loading recovery dispatch records...'),
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
            const Text('Failed to load records',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchRecords,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No recovery records found',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchRecords,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    if (allColumns.isEmpty) {
      return const Center(child: Text('No columns detected from API.'));
    }

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
            // ── Dynamic columns from API (NO action column) ──
            columns: allColumns.map(
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
            ).toList(),
            // ── Dynamic rows (NO action cell) ──
            rows: records.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isEven = index % 2 == 0;

              return DataRow(
                color: MaterialStateColor.resolveWith(
                      (states) =>
                  isEven ? Colors.white : Colors.blueGrey.shade50,
                ),
                cells: allColumns.map((col) {
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
                        color: _statusColor(value).withOpacity(0.15),
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
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}