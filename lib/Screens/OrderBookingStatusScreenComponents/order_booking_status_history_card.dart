import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../Databases/dp_helper.dart';
import '../../Models/ScreenModels/order_status_models.dart';
import '../../ViewModels/ScreenViewModels/order_booking_status_view_model.dart';

class OrderBookingStatusHistoryCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final OrderBookingStatusViewModel viewModel;

  const OrderBookingStatusHistoryCard({
    required this.filterData,
    required this.rowsNotifier,
    required this.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    searchController.addListener(() {
      filterData(searchController.text);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 300;

        return SizedBox(
          height: 500,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(searchController),
                const Divider(color: Colors.grey, height: 1),
                Expanded(
                  child: Obx(() {
                    final rowsToShow = viewModel.filteredRows;

                    if (rowsToShow.isEmpty) {
                      return _buildNoResultsFound();
                    }

                    return _buildDataTable(isSmallScreen, rowsToShow, context);
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build search bar
  Widget _buildSearchBar(TextEditingController searchController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
          ),
        ),
      ),
    );
  }

  // Build data table
  Widget _buildDataTable(bool isSmallScreen, RxList<OrderBookingStatusModel> rowsToShow, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: isSmallScreen ? Axis.vertical : Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.blueGrey.shade100),
          dataRowColor: MaterialStateProperty.resolveWith(
                (states) {
              return states.contains(MaterialState.selected)
                  ? Colors.blueGrey.shade50
                  : Colors.grey.shade50;
            },
          ),
          border: TableBorder.all(color: Colors.grey.shade300),
          columnSpacing: 30,
          columns: _buildDataColumns(),
          rows: rowsToShow.map((row) => _buildDataRow(row, context)).toList(),
        ),
      ),
    );
  }

  // Build data columns
  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(
        label: Center(
          child: Text(
            'Order No',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Order Date',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Shop',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Amount',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Status',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      DataColumn(
        label: Center(
          child: Text(
            'Details',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    ];
  }

  // Build data row
  DataRow _buildDataRow(OrderBookingStatusModel row, BuildContext context) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (row.status == 'Completed') {
            return Colors.green.withOpacity(0.3); // Highlight "Completed" rows in green
          }
          return null; // Use default color for other rows
        },
      ),
      cells: [
        DataCell(
          Center(
            child: Text(
              row.orderNo,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              row.date,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              row.shop,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              row.amount.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              row.status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Center(
            child: GestureDetector(
              onTap: () async {
                final Database? db = await DBHelper().db;
                List<Map<String, dynamic>> queryRows = await db!.query(
                    'orderDetails', where: 'order_master_id = ?',
                    whereArgs: [row.orderNo]);
                // Handle tap on "Order Details"
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Order Details'),
                      content: SizedBox(
                        height: 300,
                        width: 300,
                        child: Scrollbar(
                          thumbVisibility: true, // Show scrollbar for better UX
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: queryRows.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0), // Add spacing between items
                                child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      const TextSpan(text: 'Sr. No: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${index + 1}\n'),
                                      const TextSpan(text: 'Product Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${queryRows[index]['product']}\n'),
                                      const TextSpan(text: 'Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${queryRows[index]['quantity']}\n'),
                                      const TextSpan(text: 'Unit Price: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${queryRows[index]['rate']}\n'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },

                );
              },
              child: const Text(
                'Order Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build no results found view
  Widget _buildNoResultsFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No matching products found.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}