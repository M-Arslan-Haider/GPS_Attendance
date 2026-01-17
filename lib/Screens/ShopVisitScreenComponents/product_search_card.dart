// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
//
// class ProductSearchCard extends StatelessWidget {
//   final Function(String) filterData;
//   final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
//   final RxList<Map<String, dynamic>> filteredRows;
//   final ShopVisitDetailsViewModel shopVisitDetailsViewModel;
//
//   const ProductSearchCard({
//     required this.filterData,
//     required this.rowsNotifier,
//     required this.filteredRows,
//     required this.shopVisitDetailsViewModel,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController searchController = TextEditingController();
//     searchController.addListener(() {
//       filterData(searchController.text);
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       filterData('');
//     });
//
//     return SizedBox(
//       height: 450, // Adjust this height as needed
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSearchBar(searchController),
//             const Divider(color: Colors.grey, height: 1),
//             Expanded(child: _buildDataTable(context)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchBar(TextEditingController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           prefixIcon: const Icon(Icons.search, color: Colors.blue),
//           hintText: 'Search products...',
//           hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.grey, width: 1.5),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.blue, width: 2),
//           ),
//         ),
//         onChanged: filterData,
//       ),
//     );
//   }
//
//   Widget _buildDataTable(BuildContext context) {
//     return Obx(() {
//       final rowsToShow =
//       filteredRows.isNotEmpty ? filteredRows : rowsNotifier.value;
//
//       if (rowsToShow.isEmpty) {
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.search_off, size: 50, color: Colors.grey),
//               SizedBox(height: 10),
//               Text(
//                 'No matching products found.',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.resolveWith(
//                     (states) => Colors.blue.shade100),
//             dataRowColor: MaterialStateProperty.resolveWith((states) =>
//             states.contains(MaterialState.selected)
//                 ? Colors.blue.shade50
//                 : Colors.grey.shade50),
//             border: TableBorder.all(color: Colors.grey.shade300),
//             columnSpacing: 10,
//             columns: _buildDataColumns(),
//             rows: rowsToShow.map((row) => _buildDataRow(row)).toList(),
//           ),
//         ),
//       );
//     });
//   }
//
//   List<DataColumn> _buildDataColumns() {
//     return const [
//       DataColumn(
//         label: SizedBox(
//           width: 200,
//           child: Text(
//             'Product',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: 100,
//           child: Center(
//             child: Text(
//               'Quantity',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//           ),
//         ),
//       ),
//     ];
//   }
//
//   DataRow _buildDataRow(Map<String, dynamic> row) {
//     final quantityController = TextEditingController(
//       text: row['Quantity']?.toString() ?? '',
//     );
//
//     return DataRow(
//       cells: [
//         DataCell(
//           Text(row['Product'] ?? '', overflow: TextOverflow.ellipsis),
//         ),
//         DataCell(
//           TextField(
//             controller: quantityController,
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//             ],
//             onChanged: (value) {
//               row['Quantity'] = int.tryParse(value) ?? 0;
//             },
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               isDense: true,
//               contentPadding: EdgeInsets.symmetric(
//                 vertical: 1,
//                 horizontal: 8,
//               ),
//             ),
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';

class ProductSearchCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final RxList<Map<String, dynamic>> filteredRows;
  final ShopVisitDetailsViewModel shopVisitDetailsViewModel;

  const ProductSearchCard({
    required this.filterData,
    required this.rowsNotifier,
    required this.filteredRows,
    required this.shopVisitDetailsViewModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    searchController.addListener(() {
      filterData(searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterData('');
    });

    return SizedBox(
      height: 460,
      child: Card(
        elevation: 6,
        shadowColor: Colors.blueGrey.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildSearchHeader(searchController),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            Expanded(child: _buildDataTable(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.7)],
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.blue.shade700,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: Colors.blue.shade700),
          hintText: 'Search product name...',
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Obx(() {
      final rowsToShow = filteredRows.isNotEmpty ? filteredRows : rowsNotifier.value;

      // Calculate total quantity (only from visible rows)
      final totalQuantity = rowsToShow.fold<int>(
        0,
            (sum, row) => sum + (row['Quantity'] as int? ?? 0),
      );

      if (rowsToShow.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(fontSize: 17, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different search term',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  horizontalMargin: 12,
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    return states.contains(MaterialState.selected)
                        ? Colors.blue.shade50.withOpacity(0.7)
                        : null;
                  }),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade200),
                    verticalInside: BorderSide.none,
                    top: BorderSide.none,
                    bottom: BorderSide.none, // removed bottom border so footer blends better
                  ),
                  columns: _buildDataColumns(),
                  rows: rowsToShow.map((row) => _buildDataRow(row, context)).toList(),
                ),
              ),
            ),
          ),
          // ── Fixed Total Row ───────────────────────────────────────────────────
          Container(
            color: Colors.blueGrey.shade50.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Total Quantity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '$totalQuantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  List<DataColumn> _buildDataColumns() {
    return [
      DataColumn(
        label: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'Product Name',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.blueGrey.shade800),
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Qty',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.blueGrey.shade800),
        ),
      ),
    ];
  }

  DataRow _buildDataRow(Map<String, dynamic> row, BuildContext context) {
    final quantityController = TextEditingController(text: row['Quantity']?.toString() ?? '');
    final focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        quantityController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: quantityController.text.length,
        );
      }
    });

    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              row['Product'] ?? '',
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              focusNode.requestFocus();
            },
            child: SizedBox(
              width: 80,
              child: TextField(
                focusNode: focusNode,
                controller: quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  row['Quantity'] = int.tryParse(value) ?? 0;
                  // Note: Obx will automatically rebuild total when rows change
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}