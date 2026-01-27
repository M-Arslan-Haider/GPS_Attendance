import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:order_booking_app/Databases/util.dart';
import 'dart:convert';

import '../../../Models/Bookers_RSM_SM_NSM_Models/nsm_bookers_order_model.dart';
import '../../../Models/Bookers_RSM_SM_NSM_Models/nsm_sm_order_details_model.dart';
import '../../../Services/FirebaseServices/firebase_remote_config.dart';



class NsmBookersBookingDetailsScreen extends StatefulWidget {
  final NsmBookersOrderModel booker;

  NsmBookersBookingDetailsScreen({required this.booker});

  @override
  _NSMBookerDetailsPageState createState() => _NSMBookerDetailsPageState();
}
class _NSMBookerDetailsPageState extends State<NsmBookersBookingDetailsScreen> {
  final List<String> _statusOptions = ["Pending", "Dispatched"];
  List<NsmSmOrderDetailsModel> _attendanceData = [];
  List<NsmSmOrderDetailsModel> _filteredData = [];

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
    _filteredData = _attendanceData;
  }

  Future<void> _fetchAttendanceData() async {
    await Config.fetchLatestConfig();
    final response = await http.get(
      Uri.parse(
          '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlNsmUserOrderDetails}$user_id/${widget.booker.booker_id}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['items'];

      // Parse and sort data
      final List<NsmSmOrderDetailsModel> parsedData = data.map((item) => NsmSmOrderDetailsModel.fromMap(item)).toList();

      // Sort data by date in descending order
      parsedData.sort((a, b) {
        final dateA = DateFormat('dd-MMM-yyyy').parse(a.order_master_date??'');
        final dateB = DateFormat('dd-MMM-yyyy').parse(b.order_master_date??'');
        return dateB.compareTo(dateA); // Descending order
      });

      setState(() {
        _attendanceData = parsedData;
        _filteredData = _attendanceData; // Initialize _filteredData
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
          _filterData();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _filteredData = _attendanceData;
    });
  }


// Create a DateFormat instance for your date format
  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');

  void _filterData() {


    setState(() {
      _filteredData = _attendanceData.where((entry) {
        DateTime? entryDate;
        try {
          entryDate = dateFormat.parse(entry.order_master_date!);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing date: ${entry.order_master_date!}');
          }
          return false; // Skip entries with invalid date formats
        }

        // Check if the date is within the selected range
        final isWithinDateRange = (_startDate == null || entryDate.isAtSameMomentAs(_startDate!) || entryDate.isAfter(_startDate!)) &&
            (_endDate == null || entryDate.isAtSameMomentAs(_endDate!) || entryDate.isBefore(_endDate!.add(const Duration(days: 1))));



        // Check if the status matches the selected status
        final matchesStatus = _selectedStatus == null ||
            (_selectedStatus == "Pending" && entry.order_status!.isNotEmpty) ||
            (_selectedStatus == "Dispatched" && entry.order_status!.isNotEmpty);
        // Sort data by date in descending order
        _filteredData.sort((a, b) {
          final dateA = dateFormat.parse(a.order_master_date!);
          final dateB = dateFormat.parse(b.order_master_date!);
          return dateB.compareTo(dateA); // Descending order
        });

        print('Matches Status: $matchesStatus');

        return isWithinDateRange && matchesStatus;
      }).toList();

    });
  }



  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: "avenir", fontSize: 14);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booker.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Text(
                        _startDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_startDate!)
                            : '',
                        style: TextStyle(
                          color: _startDate != null ? Colors.black : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "End Date",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Text(
                        _endDate != null
                            ? DateFormat('dd-MMM-yyyy').format(_endDate!)
                            : '',
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Status",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                              _filterData();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date', style: textStyle)),
                      DataColumn(label: Text('Order Id', style: textStyle)),
                      DataColumn(label: Text('Booker Id', style: textStyle)),
                      DataColumn(label: Text('Booker Name', style: textStyle)),
                      DataColumn(label: Text('Shop Name', style: textStyle)),
                      DataColumn(label: Text('Amount', style: textStyle)),
                      DataColumn(label: Text('Status', style: textStyle)),
                    ],
                    rows: _filteredData.map((entry) { // Use _filteredData here
                      return DataRow(
                        cells: [
                          DataCell(Text(entry.order_master_date??"", style: textStyle)),
                          DataCell(Text(entry.order_master_id??"", style: textStyle)),
                          DataCell(Text(entry.user_id??"", style: textStyle)),
                          DataCell(Text(entry.user_name??"", style: textStyle)),
                          DataCell(Text(entry.shop_name??"", style: textStyle)),
                          DataCell(Text(entry.total?.toString() ?? "", style: textStyle)), // Convert int? to String
                          DataCell(Text(entry.order_status??"", style: textStyle)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


