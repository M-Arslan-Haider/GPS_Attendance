import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ViewModels/order_details_view_model.dart';
class OrderMasterProductSearchCard extends StatelessWidget {
  final Function(String) filterData;
  final ValueListenable<List<Map<String, dynamic>>> rowsNotifier;
  final RxList<Map<String, dynamic>> filteredRows;
  final OrderDetailsViewModel orderDetailsViewModel;

  const OrderMasterProductSearchCard({
    required this.filterData,
    required this.rowsNotifier,
    required this.filteredRows,
    required this.orderDetailsViewModel,
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
      height: 400,
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
            Expanded(child: _buildDataTable(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
          ),
        ),
        onChanged: filterData,
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Obx(() {
      final rowsToShow =
          filteredRows.isNotEmpty ? filteredRows : rowsNotifier.value;

      if (rowsToShow.isEmpty) {
        return const _NoDataFound();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.blueGrey.shade100),
            dataRowColor: MaterialStateProperty.resolveWith((states) =>
                states.contains(MaterialState.selected)
                    ? Colors.blueGrey.shade50
                    : Colors.grey.shade50),
            border: TableBorder.all(color: Colors.grey.shade300),
            columnSpacing: 10,
            columns: _buildDataColumns(),
            rows: rowsToShow.map((row) => _buildDataRow(row)).toList(),
          ),
        ),
      );
    });
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(
        label: SizedBox(
          width: 150,
          child: Text(
            'Product',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 100,
          child: Center(
            child: Text(
              'Enter Qty',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 100,
          child: Center(
            child: Text(
              'In Stock',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: 100,
          child: Center(
            child: Text(
              'Rate',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    ];
  }

  DataRow _buildDataRow(Map<String, dynamic> row) {
    final quantityController = TextEditingController(text: row['Enter Qty']?.toString() ?? '');
    final amountController = TextEditingController(text: row['Amount']?.toString() ?? '');

    return DataRow(cells: [
      DataCell(
        Text(row['Product'] ?? '', overflow: TextOverflow.ellipsis),
      ),
      DataCell(
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          onTap: () {
            // Clear the text field and place the cursor at the end
            //quantityController.clear();
            Future.delayed(Duration.zero, () {
              quantityController.selection = TextSelection.fromPosition(
                TextPosition(offset: quantityController.text.length),
              );
            });
          },
          onChanged: (value) {
            // Update the row data and refresh the UI
            row['Enter Qty'] = value.isEmpty ? 0 : int.tryParse(value) ?? 0;
            _updateAmount(row, amountController);
            orderDetailsViewModel.updateTotalAmount();
            //filteredRows.refresh(); // Ensure the UI is updated
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      DataCell(
        Center(
          child: Text(
            row['In Stock']?.toString() ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
      DataCell(
        Center(
          child: Text(
            row['Rate']?.toString() ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
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
            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ]);
  }

  void _updateAmount(
      Map<String, dynamic> row, TextEditingController amountController) {
    final quantity = row['Enter Qty'] ?? 0;
    final rate = row['Rate'] ?? 0.0;
    final amount = quantity * rate;
    row['Amount'] = amount;
    amountController.text = amount.toString();
    //filteredRows.refresh();
  }
}

class _NoDataFound extends StatelessWidget {
  const _NoDataFound();

  @override
  Widget build(BuildContext context) {
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
