import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../Databases/util.dart';
import 'dispatch_order_detail.dart';


class DispatchMasterScreen extends StatefulWidget {
  const DispatchMasterScreen({Key? key}) : super(key: key);

  @override
  _DispatchMasterScreenState createState() => _DispatchMasterScreenState();
}

class _DispatchMasterScreenState extends State<DispatchMasterScreen> {
  List<Map<String, dynamic>> dispatches = [];
  List<Map<String, dynamic>> pendingDispatches = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDispatches();
  }

  Future<void> fetchDispatches() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final String baseUrl = 'https://cloud.metaxperts.net:8443/erp/valor_trading';
      final String url = '$baseUrl/dispatchmasterget/get/$user_id';
      debugPrint('🔗 Fetching from: $url');

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

        if (rawResponse is List) {
          for (var item in rawResponse) {
            if (item is Map) {
              processedData.add(_processDispatchItem(item));
            }
          }
        } else if (rawResponse is Map) {
          final mapResponse = Map<String, dynamic>.from(rawResponse);

          List<String> possibleListKeys = [
            'data',
            'dispatches',
            'dispatch_masters',
            'dispatchMasters',
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
                  processedData.add(_processDispatchItem(item));
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
                    processedData.add(_processDispatchItem(item));
                  }
                }
                foundList = true;
              }
            });
          }
        }

        // Filter only records where approval_status is PENDING AND dispatch_status is NULL/empty
        List<Map<String, dynamic>> onlyPendingData = processedData
            .where((dispatch) {
          final approvalStatus = dispatch['approvel_status']?.toString().toLowerCase() ?? '';
          final dispatchStatus = dispatch['dispatch_status']?.toString().trim() ?? '';

          // Show only if approval is pending AND dispatch_status is null/empty
          return approvalStatus == 'pending' && (dispatchStatus.isEmpty || dispatchStatus.toLowerCase() == 'null');
        })
            .toList();

        debugPrint('📊 Total records: ${processedData.length}, Pending & Unprocessed: ${onlyPendingData.length}');

        setState(() {
          dispatches = onlyPendingData;
          pendingDispatches = onlyPendingData;
          isLoading = false;
        });

        debugPrint('✅ Successfully loaded ${dispatches.length} PENDING & UNPROCESSED dispatch records');
      } else {
        // Handle different error codes
        String errorMsg = 'Server error';
        if (response.statusCode == 555) {
          try {
            final errorData = json.decode(response.body);
            if (errorData['message'] != null) {
              errorMsg = 'Database error: ${errorData['message']}';
            }
          } catch (e) {
            errorMsg = 'Server configuration error (Code: 555)';
          }
        }
        throw Exception('HTTP ${response.statusCode}: $errorMsg');
      }
    } catch (e) {
      debugPrint('❌ Dispatch API Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Server Error',
        'Backend API error. Please contact the administrator.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Map<String, dynamic> _processDispatchItem(Map<dynamic, dynamic> item) {
    return Map<String, dynamic>.from(item);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
        return Colors.green;
      case 'not dispatched':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Dispatch Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: fetchDispatches,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchDispatches,
        color: Colors.blueGrey,
        child: _buildDispatchList(),
      ),
    );
  }

  Widget _buildDispatchList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading dispatches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchDispatches,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (dispatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Pending Dispatches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All dispatches have been processed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dispatches.length,
      itemBuilder: (context, index) {
        final dispatch = dispatches[index];
        return _buildDispatchCard(dispatch);
      },
    );
  }

  Widget _buildDispatchCard(Map<String, dynamic> dispatch) {
    final dispatchStatus = dispatch['dispatch_status']?.toString() ?? 'N/A';
    final approvalStatus = dispatch['approvel_status']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to detail screen with only this order
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DispatchDetailScreen(dispatch: dispatch),
            ),
          );

          // If result is true, refresh the list
          if (result == true) {
            fetchDispatches();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispatch #${dispatch['dispatch_no'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dispatch['shop_name']?.toString() ?? 'Unknown Shop',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(dispatchStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(dispatchStatus),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          dispatchStatus,
                          style: TextStyle(
                            color: _getStatusColor(dispatchStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          approvalStatus,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_city_outlined,
                      'City',
                      dispatch['city']?.toString() ?? 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person_outline,
                      'Owner',
                      dispatch['owner_name']?.toString() ?? 'N/A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone_outlined,
                      'Phone',
                      dispatch['phone_no']?.toString() ?? 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.branding_watermark_outlined,
                      'Brand',
                      dispatch['brand']?.toString() ?? 'N/A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Dispatch Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${(double.tryParse(dispatch['dispatch_amount']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DispatchDetailScreen(dispatch: dispatch),
                        ),
                      );

                      // If result is true, refresh the list
                      if (result == true) {
                        fetchDispatches();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// NEW SEPARATE DETAIL SCREEN - Shows only ONE order
class DispatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> dispatch;

  const DispatchDetailScreen({Key? key, required this.dispatch}) : super(key: key);

  @override
  _DispatchDetailScreenState createState() => _DispatchDetailScreenState();
}

class _DispatchDetailScreenState extends State<DispatchDetailScreen> {
  bool isUpdatingStatus = false;

  Future<void> updateDispatchStatus(String dispatchNo, String newStatus, {String? reason}) async {
    try {
      setState(() {
        isUpdatingStatus = true;
      });

      final String baseUrl = 'https://cloud.metaxperts.net:8443/erp/valor_trading';
      final String url = '$baseUrl/dispatchput/put/$dispatchNo';

      debugPrint('🔗 Updating dispatch status at: $url');
      debugPrint('📊 Dispatch No: $dispatchNo, New Status: $newStatus');

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'dispatch_status': newStatus,
      };

      // Always add current date for both statuses
      final currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      requestBody['dispatch_date'] = currentDate;
      debugPrint('📅 Dispatch Date: $currentDate');

      // If status is "Not Dispatched" and reason is provided, add reason
      if (newStatus.toLowerCase() == 'not dispatched' || newStatus.toLowerCase() == 'not-dispatched') {
        if (reason != null && reason.isNotEmpty) {
          requestBody['reason'] = reason;
          debugPrint('📝 Reason: $reason');
        }
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('📊 Update API Status: ${response.statusCode}');
      debugPrint('📊 Update API Response: ${response.body}');

      setState(() {
        isUpdatingStatus = false;
      });

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Dispatch status updated to: $newStatus',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Go back to list screen after successful update
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Update Status Error: $e');
      setState(() {
        isUpdatingStatus = false;
      });
      Get.snackbar(
        'Error',
        'Failed to update dispatch status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to show reason dialog for "Not Dispatched"
  // Future<void> showReasonDialog(String dispatchNo) async {
  //   TextEditingController reasonController = TextEditingController();
  //
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.edit_note, color: Colors.orange[800]),
  //             const SizedBox(width: 8),
  //             const Text(
  //               'Reason Required',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Please provide a reason for not dispatching:',
  //               style: TextStyle(fontSize: 14, color: Colors.black87),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: reasonController,
  //               maxLines: 3,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter reason...',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                   borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(color: Colors.grey[600]),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (reasonController.text.trim().isEmpty) {
  //                 Get.snackbar(
  //                   'Required',
  //                   'Please enter a reason',
  //                   snackPosition: SnackPosition.BOTTOM,
  //                   backgroundColor: Colors.orange,
  //                   colorText: Colors.white,
  //                 );
  //                 return;
  //               }
  //               Navigator.of(context).pop();
  //               updateDispatchStatus(dispatchNo, 'NOT-DISPATCHED', reason: reasonController.text.trim());
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             child: const Text('Submit'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> showReasonDialog(String dispatchNo) async {
    TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Icon(Icons.edit_note, color: Colors.orange[800]),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Reason Required',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please provide a reason for not dispatching this order.',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter reason...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Required',
                            'Please enter a reason',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Navigator.of(context).pop();
                        updateDispatchStatus(
                          dispatchNo,
                          'NOT-DISPATCHED',
                          reason: reasonController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submit', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
        return Colors.green;
      case 'not dispatched':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dispatch = widget.dispatch;
    final dispatchStatus = dispatch['dispatch_status']?.toString() ?? 'N/A';
    final approvalStatus = dispatch['approvel_status']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dispatch Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '#${dispatch['dispatch_no'] ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade700,
                    Colors.blueGrey.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusBadge('Dispatch Status', dispatchStatus, _getStatusColor(dispatchStatus)),
                      _buildStatusBadge('Approval Status', approvalStatus, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            // Details Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailSection(
                    'Dispatch Information',
                    Icons.local_shipping_outlined,
                    [
                      _buildInfoRow('Dispatch No', dispatch['dispatch_no']),
                      _buildInfoRow('Dispatch Status', dispatch['dispatch_status']),
                      _buildInfoRow('Approval Status', dispatch['approvel_status']),
                      _buildInfoRow('Approved Date', dispatch['approved_date']),
                      _buildInfoRow('Dispatch Amount', 'Rs. ${(double.tryParse(dispatch['dispatch_amount']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Customer Information',
                    Icons.store_outlined,
                    [
                      _buildInfoRow('Shop Name', dispatch['shop_name']),
                      _buildInfoRow('Owner Name', dispatch['owner_name']),
                      _buildInfoRow('Phone No', dispatch['phone_no']),
                      _buildInfoRow('City', dispatch['city']),
                      _buildInfoRow('Brand', dispatch['brand']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Order Information',
                    Icons.receipt_long_outlined,
                    [
                      _buildInfoRow('User ID', dispatch['user_id']),
                      _buildInfoRow('User Name', dispatch['user_name']),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(
                                  dispatch_no: dispatch['dispatch_no'],
                                  shopName: dispatch['shop_name'] ?? 'N/A',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: const Text(
                            'View Order Details',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildActionButtons(dispatch),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButtons(Map<String, dynamic> dispatch) {
  //   return Container(
  //     height: 200,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 20,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Header
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [
  //                 Colors.blueGrey.shade600,
  //                 Colors.blueGrey.shade700,
  //               ],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //           ),
  //           child: Row(
  //             children: [
  //               const SizedBox(width: 12),
  //               const Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Update dispatch status',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         // Buttons Section
  //         Padding(
  //           padding: const EdgeInsets.all(10),
  //           child: Column(
  //             children: [
  //               // Dispatched Button
  //               Container(
  //                 width: double.infinity,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       Colors.green.shade400,
  //                       Colors.green.shade600,
  //                     ],
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                   ),
  //                   borderRadius: BorderRadius.circular(10),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.green.withOpacity(0.3),
  //                       blurRadius: 8,
  //                       offset: const Offset(0, 4),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     borderRadius: BorderRadius.circular(12),
  //                     onTap: isUpdatingStatus
  //                         ? null
  //                         : () {
  //                       updateDispatchStatus(
  //                         dispatch['dispatch_no'],
  //                         'Dispatched',
  //                       );
  //                     },
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const SizedBox(width: 8),
  //                           const Text(
  //                             'DISPATCHED',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                               letterSpacing: 1,
  //                             ),
  //                           ),
  //                           const Spacer(),
  //                           const Icon(
  //                             Icons.arrow_forward_rounded,
  //                             color: Colors.white,
  //                             size: 20,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 10),
  //
  //               // Not Dispatched Button
  //               Container(
  //                 width: double.infinity,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       Colors.red.shade400,
  //                       Colors.red.shade600,
  //                     ],
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                   ),
  //                   borderRadius: BorderRadius.circular(10),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.red.withOpacity(0.3),
  //                       blurRadius: 8,
  //                       offset: const Offset(0, 4),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     borderRadius: BorderRadius.circular(12),
  //                     onTap: isUpdatingStatus
  //                         ? null
  //                         : () {
  //                       showReasonDialog(dispatch['dispatch_no']);
  //                     },
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const SizedBox(width: 8),
  //                           const Text(
  //                             'NOT DISPATCHED',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                               letterSpacing: 1,
  //                             ),
  //                           ),
  //                           const Spacer(),
  //                           const Icon(
  //                             Icons.arrow_forward_rounded,
  //                             color: Colors.white,
  //                             size: 20,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               // Loading Indicator
  //               if (isUpdatingStatus)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 20),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue.shade50,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(color: Colors.blue.shade200),
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         SizedBox(
  //                           width: 20,
  //                           height: 20,
  //                           child: CircularProgressIndicator(
  //                             strokeWidth: 2.5,
  //                             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Text(
  //                           'Updating status...',
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.blue.shade700,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButtons(Map<String, dynamic> dispatch) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.local_shipping_rounded,
                  color: Colors.blueGrey.shade700),
              const SizedBox(width: 10),
              Text(
                "Update Dispatch Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  label: "DISPATCHED",
                  color: Colors.green,
                  icon: Icons.check_circle_rounded,
                  isDisabled: isUpdatingStatus,
                  onTap: () {
                    updateDispatchStatus(
                      dispatch['dispatch_no'],
                      'DISPATCHED',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  label: "NOT DISPATCHED",
                  color: Colors.red,
                  icon: Icons.cancel_rounded,
                  isDisabled: isUpdatingStatus,
                  onTap: () {
                    showReasonDialog(dispatch['dispatch_no']);
                  },
                ),
              ),
            ],
          ),

          // Loading Indicator
          if (isUpdatingStatus)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blueGrey.shade700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Updating status...",
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.6 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isDisabled ? null : onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}