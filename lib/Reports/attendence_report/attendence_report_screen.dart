import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Databases/util.dart';
import 'package:intl/intl.dart';

import '../../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({Key? key}) : super(key: key);

  @override
  _AttendanceRecordScreenState createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  DateTime? selectedDate;
  String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());


  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  // Helper method to format date
  String formatDate(String dateString) {
    try {
      if (dateString.isEmpty || dateString == 'N/A' || dateString == 'null') {
        return 'N/A';
      }

      // Remove any extra spaces
      dateString = dateString.trim();

      // Try parsing different date formats
      try {
        // Format: 21-Jan-2026
        if (dateString.contains('-')) {
          final parts = dateString.split('-');
          if (parts.length >= 3) {
            final day = parts[0];
            final month = parts[1];
            final year = parts[2];

            // Map month abbreviation to number
            Map<String, String> monthMap = {
              'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
              'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
              'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
            };

            final monthNumber = monthMap[month] ?? '01';
            final formattedDate = DateTime.parse('$year-$monthNumber-${day.padLeft(2, '0')}');
            return DateFormat('dd-MMM-yyyy').format(formattedDate);
          }
        }

        // Try ISO format
        if (dateString.contains('T')) {
          final dateTime = DateTime.parse(dateString);
          return DateFormat('dd-MMM-yyyy').format(dateTime);
        }

        return dateString;
      } catch (e) {
        return dateString;
      }
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to format time
  String formatTime(String timeString) {
    try {
      if (timeString.isEmpty || timeString == 'N/A' || timeString == 'null') return 'N/A';

      // Clean the time string
      timeString = timeString.trim();

      // Handle time format like "10:15:29"
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        // Convert to 12-hour format
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour % 12;
        final hourDisplay = hour12 == 0 ? 12 : hour12;

        return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
      }

      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  Future<void> fetchAttendanceRecords() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
// Get URL from Remote Config
      final baseUrl = Config.getApiUrlAttendenceScreenReport;
      final url = '$baseUrl$user_id';
      debugPrint('🔗 Fetching attendance from: $url');

      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      debugPrint('📊 Attendance API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      debugPrint('📊 Response Type: ${responseData.runtimeType}');

      List<Map<String, dynamic>> processedData = [];

      if (responseData is List) {
      debugPrint('✅ Response is a List with ${responseData.length} items');

      // Direct list response
      for (var item in responseData) {
      if (item is Map) {
      final Map<String, dynamic> convertedItem = {};
      item.forEach((key, value) {
      convertedItem[key.toString()] = value;
      });
      processedData.add(_processAttendanceItem(convertedItem));
      }
      }
      } else if (responseData is Map) {
      debugPrint('✅ Response is a Map with keys: ${responseData.keys}');

      final Map<String, dynamic> convertedResponse = {};
      responseData.forEach((key, value) {
      convertedResponse[key.toString()] = value;
      });

      // Try to find list in response
      bool foundList = false;

      // Check ALL keys for lists
      convertedResponse.forEach((key, value) {
      if (value is List && !foundList) {
      debugPrint('✅ Found list in key: "$key" with ${value.length} items');
      final dataList = value;
      for (var item in dataList) {
      if (item is Map) {
      final Map<String, dynamic> convertedItem = {};
      item.forEach((k, v) {
      convertedItem[k.toString()] = v;
      });
      processedData.add(_processAttendanceItem(convertedItem));
      }
      }
      foundList = true;
      }
      });

      // If no list found, check if the entire response has the data we need
      if (!foundList && convertedResponse.isNotEmpty) {
      processedData.add(_processAttendanceItem(convertedResponse));
      }
      }

      // Sort by date (most recent first)
      if (processedData.isNotEmpty) {
      processedData.sort((a, b) {
      try {
      final dateA = _parseDate(a['attendance_date']?.toString() ?? '');
      final dateB = _parseDate(b['attendance_date']?.toString() ?? '');
      return dateB.compareTo(dateA); // Descending order
      } catch (e) {
      return 0;
      }
      });
      }

      setState(() {
      attendanceRecords = processedData;
      isLoading = false;
      });

      debugPrint('✅ Successfully loaded ${attendanceRecords.length} attendance records');
      } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      } catch (e) {
        debugPrint('❌ Attendance API Error: $e');
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to load attendance records: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    DateTime _parseDate(String dateString) {
      try {
        if (dateString.isEmpty || dateString == 'N/A' || dateString == 'null') {
          return DateTime.now();
        }

        // Handle format like "21-Jan-2026"
        if (dateString.contains('-') && dateString.length >= 9) {
          final parts = dateString.split('-');
          if (parts.length >= 3) {
            final day = parts[0];
            final month = parts[1];
            final year = parts[2];

            Map<String, String> monthMap = {
              'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
              'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
              'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
            };

            final monthNumber = monthMap[month] ?? '01';
            return DateTime.parse('$year-$monthNumber-${day.padLeft(2, '0')}');
          }
        }

        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }


    Map<String, dynamic> _processAttendanceItem(Map<String, dynamic> item) {
      debugPrint('📋 Processing attendance item: $item');


      Map<String, dynamic> processedItem = {};

      // Map attendance_in_id to attendance_id
      processedItem['attendance_id'] =
          item['attendance_in_id'] ??
              item['attendance_id'] ??
              item['Attendance_Id'] ??
              item['id'] ??
              'N/A';

      // Map attendance_in_date to attendance_date
      final dateValue = item['attendance_in_date'] ??
          item['attendance_date'] ??
          item['Attendance_Date'] ??
          item['date'] ??
          'N/A';

      processedItem['attendance_date'] = dateValue.toString();
      processedItem['formatted_date'] = formatDate(dateValue.toString());

      // Map attendance_in_time to check_in_time
      final checkInValue = item['attendance_in_time'] ??
          item['check_in_time'] ??
          item['Check_In_Time'] ??
          item['punch_in_time'] ??
          'N/A';

      processedItem['check_in_time'] = checkInValue.toString();
      processedItem['formatted_check_in'] = formatTime(checkInValue.toString());

      // For check-out time (might not be in your API yet)
      final checkOutValue = item['attendance_out_time'] ??
          item['check_out_time'] ??
          item['Check_Out_Time'] ??
          item['punch_out_time'] ??
          'N/A';

      processedItem['check_out_time'] = checkOutValue.toString();
      processedItem['formatted_check_out'] = formatTime(checkOutValue.toString());


      // Additional info from your API
      processedItem['booker_name'] = item['booker_name'] ?? 'N/A';
      processedItem['designation'] = item['designation'] ?? 'N/A';
      processedItem['city'] = item['city'] ?? 'N/A';
      processedItem['address'] = item['address'] ?? 'N/A';
      processedItem['remarks'] = item['remarks'] ?? '';

      processedItem['user_id'] = item['user_id'] ?? user_id;
      processedItem['_raw_data'] = item;

      debugPrint('📋 Processed item: $processedItem');
      return processedItem;
    }

    List<Map<String, dynamic>> get filteredRecords {
      if (searchQuery.isEmpty && selectedDate == null) return attendanceRecords;

      return attendanceRecords.where((record) {
        // Search by date
        final dateMatch = selectedDate != null
            ? record['attendance_date']?.toString().contains(
            DateFormat('dd-MMM-yyyy').format(selectedDate!)
        ) ?? false
            : true;

        // Search by status, booker name, city, etc.
        final searchMatch = searchQuery.isEmpty ? true : (
            (record['status']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (record['booker_name']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (record['city']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (record['designation']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (record['formatted_date']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
        );

        return dateMatch && searchMatch;
      }).toList();
    }



    Widget _buildStatCard(String title, String value, Color color, IconData icon) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    void _showAttendanceDetails(Map<String, dynamic> record) {
      Get.bottomSheet(
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
                    'Attendance Details',
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

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Card
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Attendance ID:', record['attendance_id']?.toString() ?? 'N/A'),
                              _buildDetailRow('Date:', record['formatted_date']?.toString() ?? 'N/A'),
                              // _buildDetailRow('Check-in Time:', record['formatted_check_in']?.toString() ?? 'N/A'),
                              // _buildDetailRow('Check-out Time:', record['formatted_check_out']?.toString() ?? 'N/A'),
                              // _buildDetailRow('Work Hours:', record['work_hours']?.toString() ?? 'N/A'),
                            ],
                          ),
                        ),
                      ),

                      // Employee Info Card
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Employee Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow('User ID:', record['user_id']?.toString() ?? 'N/A'),
                              _buildDetailRow('Booker Name:', record['booker_name']?.toString() ?? 'N/A'),
                              _buildDetailRow('Designation:', record['designation']?.toString() ?? 'N/A'),
                              if (record['remarks']?.toString().isNotEmpty == true)
                                _buildDetailRow('Remarks:', record['remarks']?.toString() ?? ''),
                            ],
                          ),
                        ),
                      ),

                      // Status Card
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    }


    Widget _buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance Records',
            style: TextStyle(
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
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchAttendanceRecords,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by date, name, city, designation...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            selectedDate != null
                                ? DateFormat('dd-MMM-yyyy').format(selectedDate!)
                                : 'Select Date',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueGrey,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                            });
                          },
                          tooltip: 'Clear date filter',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
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
              Text('Loading attendance records...'),
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
                'Failed to load attendance',
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
                onPressed: fetchAttendanceRecords,
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }

      if (attendanceRecords.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No attendance records found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: fetchAttendanceRecords,
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Records Count
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Showing ${filteredRecords.length} of ${attendanceRecords.length} records',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              // Attendance List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = filteredRecords[index];
                  final date = _parseDate(record['attendance_date']?.toString() ?? '');
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isToday
                          ? BorderSide(color: Colors.blue.shade100, width: 1.5)
                          : BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd').format(date),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.blue : Colors.grey[700],
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isToday ? Colors.blue : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record['formatted_date']?.toString() ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record['booker_name']?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.login,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record['formatted_check_in']?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record['city']?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showAttendanceDetails(record),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }