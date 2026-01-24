// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../ViewModels/ScreenViewModels/recovery_form_view_model.dart';
// import '../ViewModels/recovery_form_view_model.dart';
// import 'RecoveryFormScreenComponents/recovery_payment_history_card.dart';
//
// class RecoveryFormScreen extends StatelessWidget {
//   final RecoveryFormViewModel viewModel = Get.put(RecoveryFormViewModel());
//
//   RecoveryFormScreen({super.key});
//
//   Widget _buildTextField({
//     required String label,
//     required TextInputType keyboardType,//
//     TextEditingController? controller,
//     double width = 200,
//     double height = 30,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     ValueChanged<String>? onChanged,
//     bool enabled = true,
//   }) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         readOnly: readOnly,
//         onTap: onTap,
//         onChanged: onChanged,
//         enabled: enabled,
//         style: const TextStyle(fontSize: 16),
//         decoration: InputDecoration(
//           hintText: label,
//           hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
//           border: const UnderlineInputBorder(),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     viewModel.initializeData();
//     final TextEditingController cash_recoveryController = TextEditingController();
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text(
//             'Recovery Form',
//             style: TextStyle(color: Colors.white, fontSize: 24),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blueGrey,
//         ),
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             final Size size = MediaQuery.of(context).size;
//             return Container(
//               width: size.width,
//               height: size.height,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Obx(() {
//                       // Debug: Print the contents of viewModel.shops
//                       debugPrint("Shops in ViewModel: ${viewModel.shops}");
//                       return DropdownButtonFormField<String>(
//                         decoration: const InputDecoration(
//                           labelText: "Shop Name",
//                           labelStyle: TextStyle(fontSize: 15),
//                           border: UnderlineInputBorder(),
//                         ),
//                         value: viewModel.selectedShop.value.isEmpty
//                             ? null
//                             : viewModel.selectedShop.value,
//                         items: viewModel.shops.map((shop) {
//                           // Debug: Print each shop name being added to the dropdown
//                           debugPrint("Adding Shop to Dropdown: ${shop.name}");
//                           return DropdownMenuItem(
//                             value: shop.name,
//                             child: Text(shop.name),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           viewModel.selectedShop.value = value!;
//                           viewModel.fetchAndSaveCurrentBalance(value);
//                           viewModel.updatecurrent_balance(value);
//                         },
//                       );
//                     }),
//                     const SizedBox(height: 15),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         const Text(
//                           'Current Balance:',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Obx(() => _buildTextField(
//                           readOnly: true,
//                           label: viewModel.current_balance.value.toString(),
//                           keyboardType: TextInputType.text,
//                           width: size.width * 0.36,
//                           height: 50,
//                           enabled: viewModel.areFieldsEnabled.value,
//                         )),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "----- Previous Payment History -----",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     RecoveryPaymentHistoryCard(
//                       filterData: viewModel.filterData,
//                       rowsNotifier: ValueNotifier(viewModel.paymentHistoryAsMapList),
//                       viewModel: viewModel,
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         const Text(
//                           "Cash Recovery:",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Obx(() =>
//                             _buildTextField(
//                               controller: cash_recoveryController,
//                               label: "Enter Amount",
//                               keyboardType: TextInputType.number,
//                               width: size.width * 0.5,
//                               height: 40,
//                               onChanged: viewModel.updatecash_recovery,
//                               enabled: viewModel.areFieldsEnabled.value,
//                             )
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Text(
//                           "New Balance:",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Obx(() => _buildTextField(
//                           readOnly: true,
//                           label: viewModel.net_balance.value.toString(),
//                           keyboardType: TextInputType.text,
//                           width: size.width * 0.5,
//                           height: 40,
//                           enabled: viewModel.areFieldsEnabled.value,
//                         )),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                     Obx(
//                           () => ElevatedButton(
//                         onPressed: viewModel.areFieldsEnabled.value
//                             ? () {
//                           viewModel.submitForm();
//                         }
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: viewModel.areFieldsEnabled.value
//                               ? Colors.blueGrey
//                               : Colors.grey,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 15, horizontal: 70),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           "Submit",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ViewModels/ScreenViewModels/recovery_form_view_model.dart';
import '../ViewModels/recovery_form_view_model.dart';
import 'RecoveryFormScreenComponents/recovery_payment_history_card.dart';

class RecoveryFormScreen extends StatelessWidget {
  final RecoveryFormViewModel viewModel = Get.put(RecoveryFormViewModel());

  RecoveryFormScreen({super.key});

  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    TextEditingController? controller,
    double width = 200,
    double height = 30,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        enabled: enabled,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    viewModel.initializeData();
    final TextEditingController cash_recoveryController =
    TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Recovery Form',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,

          // 🔹 Back arrow color set to white
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final Size size = MediaQuery.of(context).size;
            return Container(
              width: size.width,
              height: size.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Obx(() {
                      debugPrint("Shops in ViewModel: ${viewModel.shops}");
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Shop Name",
                          labelStyle: TextStyle(fontSize: 15),
                          border: UnderlineInputBorder(),
                        ),
                        value: viewModel.selectedShop.value.isEmpty
                            ? null
                            : viewModel.selectedShop.value,
                        items: viewModel.shops.map((shop) {
                          return DropdownMenuItem(
                            value: shop.name,
                            child: Text(shop.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          viewModel.selectedShop.value = value!;
                          viewModel.fetchAndSaveCurrentBalance(value);
                          viewModel.updatecurrent_balance(value);
                        },
                      );
                    }),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Current Balance:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => _buildTextField(
                          readOnly: true,
                          label:
                          viewModel.current_balance.value.toString(),
                          keyboardType: TextInputType.text,
                          width: size.width * 0.36,
                          height: 50,
                          enabled:
                          viewModel.areFieldsEnabled.value,
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "----- Previous Payment History -----",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RecoveryPaymentHistoryCard(
                      filterData: viewModel.filterData,
                      rowsNotifier:
                      ValueNotifier(viewModel.paymentHistoryAsMapList),
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Cash Recovery:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => _buildTextField(
                          controller: cash_recoveryController,
                          label: "Enter Amount",
                          keyboardType: TextInputType.number,
                          width: size.width * 0.5,
                          height: 40,
                          onChanged:
                          viewModel.updatecash_recovery,
                          enabled:
                          viewModel.areFieldsEnabled.value,
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "New Balance:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => _buildTextField(
                          readOnly: true,
                          label:
                          viewModel.net_balance.value.toString(),
                          keyboardType: TextInputType.text,
                          width: size.width * 0.5,
                          height: 40,
                          enabled:
                          viewModel.areFieldsEnabled.value,
                        )),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Obx(
                          () => ElevatedButton(
                        onPressed: viewModel.areFieldsEnabled.value
                            ? () => viewModel.submitForm()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          viewModel.areFieldsEnabled.value
                              ? Colors.blueGrey
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

