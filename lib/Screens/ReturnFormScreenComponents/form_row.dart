import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatter
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
import '../../Models/ScreenModels/return_form_model.dart';

class FormRow extends StatelessWidget {
  final Size size;

  // final ReturnFormViewModel viewModel;
  final ReturnFormDetailsViewModel returnFormDetailsViewModel;
  final ReturnForm row;
  final int index;

  const FormRow({
    required this.size,
    required this.returnFormDetailsViewModel,
    required this.row,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Dropdown
          SizedBox(
            width: size.width * 0.84,
            height: 60,
            child: Obx(() {
              return // In FormRow.dart - modified item dropdown
                DropdownButtonFormField<Item>(
                  decoration: const InputDecoration(
                    labelText: "Item",
                    labelStyle: TextStyle(fontSize: 15),
                    border: UnderlineInputBorder(),
                  ),
                  value: row.selectedItem,
                  items: returnFormDetailsViewModel.items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    row.selectedItem = value;
                    if (value != null) {
                      row.rate = value.rate;
                      row.maxQuantity = value.maxQuantity;
                    }
                  },
                );
            }),
          ),

          // Qty and Reason Row
          Row(
            children: [
              // Modified Qty TextField
              // _buildTextField(
              //   label: "Qty *",
              //   keyboardType: TextInputType.number,
              //   initialValue: row.quantity,
              //   onChanged: (value) {
              //     if (value.isNotEmpty) {
              //       // Validate against max quantity
              //       double enteredQty = double.tryParse(value) ?? 0;
              //       if (row.maxQuantity != null &&
              //           enteredQty > row.maxQuantity!) {
              //         Get.snackbar(
              //           "Quantity cannot exceed ${row.maxQuantity}",
              //           "Please Enter a valid quantity.",
              //           snackPosition: SnackPosition.BOTTOM,
              //           backgroundColor: Colors.red,
              //           colorText: Colors.white,
              //         );
              //         return;
              //       }
              //       row.quantity = value;
              //
              //       // Calculate amount if rate is available
              //       if (row.rate != null) {
              //         double amount = enteredQty * row.rate!;
              //         debugPrint("Calculated Amount: $amount");
              //       }
              //     } else {
              //       row.quantity = value;
              //     }
              //   },
              //   width: size.width * 0.3,
              //   height: 40,
              //   fontSize: 18.0,
              // ),
              _buildTextField(
                label: "Qty *",
                initialValue: row.quantity,
                onChanged: (value) => row.quantity = value,
                width: size.width * 0.3,
                height: 40,
                fontSize: 18.0,
                keyboardType: TextInputType.number,
                maxQuantity: row.maxQuantity,
                rate: row.rate,
              ),
              const SizedBox(width: 15),
              SizedBox(
                width: size.width * 0.5,
                height: 40,
                child: Obx(() {
                  // Add null/empty check
                  if (returnFormDetailsViewModel.reasons.isEmpty) {
                    return const Text("No reasons available");
                  }

                  return Obx(() {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: "Reason *",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: UnderlineInputBorder(),
                      ),
                      value: row.reason.isEmpty ? null : row.reason,
                      items: returnFormDetailsViewModel.reasons.map((reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      onChanged: (reason) {
                        if (reason != null) {
                          row.reason = reason;
                        }
                      },
                    );
                  });
                }),
              ),
            ],
          ),

          // Delete Button
          Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.blueGrey),
              onPressed: () => returnFormDetailsViewModel.removeRow(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required double width,
    required double height,
    double fontSize = 16.0,
    TextInputType keyboardType = TextInputType.text,
    double? maxQuantity, // Add maxQuantity parameter
    double? rate, // Add rate parameter for amount calculation
  }) {
    final controller = TextEditingController(text: initialValue);

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        // Use controller instead of initialValue
        style: TextStyle(fontSize: fontSize),
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : null,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: const UnderlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Validate against max quantity if provided
            if (maxQuantity != null) {
              double enteredQty = double.tryParse(value) ?? 0;
              if (enteredQty > maxQuantity) {
                // Show error message
                Get.snackbar(
                  "Quantity cannot exceed ${row.maxQuantity}",
                  "Please Enter a valid quantity.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );

                // Clear the field
                controller.clear();
                onChanged(''); // Notify parent of cleared value
                return;
              }
            }

            // Calculate amount if rate is available
            if (rate != null && keyboardType == TextInputType.number) {
              double enteredQty = double.tryParse(value) ?? 0;
              double amount = enteredQty * rate;
              debugPrint("Calculated Amount: $amount");
            }
          }

          onChanged(value); // Always notify parent of change
        },
      ),
    );
  }
}
