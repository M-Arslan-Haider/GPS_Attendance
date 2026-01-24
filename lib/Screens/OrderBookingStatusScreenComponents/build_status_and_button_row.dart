import 'package:flutter/material.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../Components/custom_button.dart';

Widget buildStatusAndButtonRow(OrderBookingStatusViewModel viewModel) {
  return Row(
    children: [
      Expanded(
        child: _buildLabeledDropdownSearch(
          label: "Status",
          hint: "Search status",
          items:
          viewModel.orders.map((order) => order.status).toSet().toList(),
          onChanged: (value) {
            viewModel.status.value = value ?? '';
            viewModel.filterData();
          },
          selectedItem: viewModel.status.value.isEmpty ? null : viewModel.status.value, // Correct parameter name
        ),
      ),

      CustomButton(
        buttonText: 'Clear Filters',
        width: 120,
        height: 45,
        textStyle:  const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        onTap: () {viewModel.clearFilters();},
        gradientColors: const [Colors.blueGrey, Colors.blueGrey], // Use the appropriate gradient colors
      ),
    ],
  );
}

Widget _buildLabeledDropdownSearch({
  required String label,
  required String hint,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  final String? selectedItem,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      DropdownSearch<String>(
        popupProps: const PopupProps.bottomSheet(
          showSearchBox: true,

        ),
        items: items,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: hint,
          ),
        ),
        onChanged: onChanged,
        selectedItem: selectedItem?? hint,
      ),
    ],
  );
}