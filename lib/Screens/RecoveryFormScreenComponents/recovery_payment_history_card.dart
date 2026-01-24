import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unused_import
import 'package:order_booking_app/ViewModels/ScreenViewModels/recovery_form_view_model.dart';

import '../../ViewModels/recovery_form_view_model.dart';

class RecoveryPaymentHistoryCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final RecoveryFormViewModel viewModel;

  const RecoveryPaymentHistoryCard({
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
          height: 300,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
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
                ),
                const Divider(color: Colors.grey, height: 1),
                Expanded(
                  child: Obx(() {
                    final rowsToShow = viewModel.filteredRows;

                    if (rowsToShow.isEmpty) {
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

                    return SingleChildScrollView(
                      scrollDirection: isSmallScreen ? Axis.vertical : Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.blueGrey.shade100,
                          ),
                          dataRowColor: MaterialStateProperty.resolveWith(
                                (states) => states.contains(MaterialState.selected)
                                ? Colors.blueGrey.shade50
                                : Colors.grey.shade50,
                          ),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(
                              label: SizedBox(
                                width: 100, // Adjusted the width to reduce extra space
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Shop',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Amount',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: rowsToShow.map((row) {
                            final amountController = TextEditingController(
                              text: (row.amount).toString(),
                            );

                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 100),
                                    child: Text(
                                      row.date ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row.shop ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                DataCell(
                                  TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 1,
                                        horizontal: 8,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

          ),
        );
      },
    );
  }
}
