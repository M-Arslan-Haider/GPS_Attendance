// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// // import '../ViewModels/location_view_model.dart';
// // import '../ViewModels/shop_visit_details_view_model.dart';
// // import '../ViewModels/shop_visit_view_model.dart';
// // import 'Components/custom_button.dart';
// // import 'Components/custom_dropdown.dart';
// // import 'Components/custom_editable_menu_option.dart' hide IconPosition;
// // import 'Components/custom_switch.dart';
// // import 'ShopVisitScreenComponents/check_list_section.dart';
// // import 'ShopVisitScreenComponents/feedback_section.dart';
// // import 'ShopVisitScreenComponents/photo_picker.dart';
// // import 'ShopVisitScreenComponents/product_search_card.dart';
// //
// // class ShopVisitScreen extends StatefulWidget {
// //   const ShopVisitScreen({super.key});
// //
// //   @override
// //   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// // }
// //
// // class _StateShopVisitScreen extends State<ShopVisitScreen> {
// //   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
// //   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
// //   Get.put(ShopVisitDetailsViewModel());
// //   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //   final feedBackController = TextEditingController();
// //
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     feedBackController.text = shopVisitViewModel.feedBack.value;
// //     shopVisitViewModel.selectedShop.value = "";
// //     shopVisitViewModel.selectedBrand.value = "";
// //     // These methods are now restored in the ViewModel
// //     shopVisitViewModel.fetchBrands();
// //     shopVisitViewModel.fetchShops();
// //     // Trigger initial validation
// //     shopVisitViewModel.updateButtonReadiness();
// //
// //     // Listen to changes in feedback
// //     ever(shopVisitViewModel.feedBack, (value) {
// //       feedBackController.text = value;
// //       feedBackController.selection = TextSelection.fromPosition(
// //         TextPosition(offset: feedBackController.text.length),
// //       );
// //     });
// //   }
// //
// //   String? requiredDropdownValidator(String? value, String placeholder) {
// //     if (value == null || value.isEmpty || value == placeholder) {
// //       return null;
// //     }
// //     return null;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //     final width = size.width;
// //     final isTablet = width > 600;
// //
// //     final double fontSize = isTablet ? 18 : 14;
// //     final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
// //     final double buttonHeight = isTablet ? 55 : 45;
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: Colors.white,
// //         appBar: _buildAppBar(),
// //         body: SingleChildScrollView(
// //           physics: const BouncingScrollPhysics(),
// //           child: Padding(
// //             padding: EdgeInsets.only(
// //               left: 20,
// //               right: 20,
// //               top: 30,
// //               bottom: MediaQuery.of(context).padding.bottom + 40,
// //             ),
// //             child: Form(
// //               key: shopVisitViewModel.formKey,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   Column(
// //                     children: [
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Brand",
// //                           icon: Icons.branding_watermark,
// //                           items: shopVisitViewModel.brands
// //                               .where((brand) => brand != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedBrand.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedBrand.value
// //                               : " Select a Brand",
// //                           onChanged: (value) async {
// //                             shopVisitDetailsViewModel.filteredRows.refresh();
// //                             shopVisitViewModel.setBrand(value!);
// //                             shopVisitDetailsViewModel
// //                                 .filterProductsByBrand(value);
// //                           },
// //                           useBoxShadow: false,
// //                           validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           iconSize: 22.0,
// //                           contentPadding:
// //                           MediaQuery.of(context).size.height * 0.005,
// //                           iconColor: Colors.blue,
// //                           textStyle: const TextStyle(
// //                               fontSize: 13,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black),
// //                         ),
// //                       ),
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Shop",
// //                           icon: Icons.store,
// //                           items: shopVisitViewModel.shops.value
// //                               .where((shop) => shop != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedShop.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedShop.value
// //                               : " Select a Shop",
// //                           onChanged: (value) {
// //                             shopVisitViewModel.setSelectedShop(value!);
// //                             debugPrint(shopVisitViewModel.shop_address.value);
// //                             debugPrint(shopVisitViewModel.city.value);
// //                           },
// //                           validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
// //                           useBoxShadow: false,
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           maxHeight: 50.0,
// //                           maxWidth: 385.0,
// //                           iconSize: 23.0,
// //                           contentPadding: 0.0,
// //                           iconColor: Colors.blue,
// //                         ),
// //                       ),
// //                       Obx(() => _buildTextField(
// //                         initialValue:
// //                         shopVisitViewModel.shop_address.value,
// //                         label: "Shop Address",
// //                         icon: Icons.location_on,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the shop address'
// //                             : null,
// //                         onChanged: (value) =>
// //                             shopVisitViewModel.setShopAddress(value),
// //                       )),
// //                       Obx(() => _buildTextField(
// //                         initialValue: shopVisitViewModel.owner_name.value,
// //                         label: "Owner Name",
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter owner name'
// //                             : null,
// //                         onChanged: (value) =>
// //                             shopVisitViewModel.setOwnerName(value),
// //                       )),
// //                       _buildTextField(
// //                         label: "Booker Name",
// //                         initialValue: shopVisitViewModel.booker_name.value,
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the booker name'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.booker_name.value = value,
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const SectionHeader(title: "Stock Check"),
// //                   const SizedBox(height: 10),
// //                   ProductSearchCard(
// //                     filterData: shopVisitDetailsViewModel.filterData,
// //                     rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
// //                     filteredRows: shopVisitDetailsViewModel.filteredRows,
// //                     shopVisitDetailsViewModel: shopVisitDetailsViewModel,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   ChecklistSection(
// //                     labels: shopVisitViewModel.checklistLabels,
// //                     checklistState: shopVisitViewModel.checklistState,
// //                     onStateChanged: (index, value) {
// //                       shopVisitViewModel.updateChecklistState(index, value);
// //                     },
// //                   ),
// //                   const SizedBox(height: 20),
// //                   PhotoPicker(
// //                     selectedImage: shopVisitViewModel.selectedImage,
// //                     onTakePicture: shopVisitViewModel.takePicture,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   FeedbackSection(
// //                     feedBackController: feedBackController,
// //                     onChanged: (value) =>
// //                         shopVisitViewModel.setFeedBack(value),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Obx(() => CustomSwitch(
// //                     label: "GPS Enabled",
// //                     value: locationViewModel.isGPSEnabled.value,
// //                     onChanged: (value) async {
// //                       locationViewModel.isGPSEnabled.value = value;
// //                       if (value) {
// //                         await locationViewModel.saveCurrentLocation();
// //                       }
// //                       shopVisitViewModel.updateButtonReadiness();
// //                     },
// //                   )),
// //                   SizedBox(height: MediaQuery.of(context).size.height * 0.03),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       // ===== Only Visit Button - MODIFIED for Validation =====
// //                       Obx(() {
// //                         bool isButtonDisabled = !shopVisitViewModel.isOnlyVisitButtonEnabled.value;
// //                         bool isLoading = shopVisitViewModel.isOnlyVisitLoading.value;
// //
// //                         return CustomButton(
// //                           textSize: fontSize,
// //                           iconSize: isTablet ? 22 : 18,
// //                           height: buttonHeight,
// //                           width: buttonWidth,
// //                           icon: Icons.arrow_back_ios_new_rounded,
// //                           iconColor: Colors.white,
// //                           iconPosition: IconPosition.left,
// //                           spacing: 4,
// //                           buttonText: isLoading
// //                               ? "Processing..."
// //                               : "Only Visit",
// //                           // Use disabled state for color
// //                           gradientColors: isButtonDisabled || isLoading
// //                               ? [Colors.grey, Colors.grey]
// //                               : [Colors.red, Colors.red],
// //                           // Logic to disable or show snackbar
// //                           onTap: isButtonDisabled
// //                               ? () {
// //                             // Show snackbar with detailed error message for Only Visit
// //                             String? errorMessage = shopVisitViewModel.getOnlyVisitErrorMessage();
// //                             if (errorMessage != null) {
// //                               Get.snackbar("Action Required", errorMessage,
// //                                   snackPosition: SnackPosition.BOTTOM,
// //                                   backgroundColor: Colors.red.shade700,
// //                                   colorText: Colors.white);
// //                             }
// //                           }
// //                               : () {
// //                             if (!isLoading) {
// //                               debugPrint("Only Visit tapped ✅ (Proceeding)");
// //                               shopVisitViewModel.saveFormNoOrder(); // Proceed to save and navigate
// //                             }
// //                           },
// //                         );
// //                       }),
// //
// //                       // ===== Order Form Button =====
// //                       Obx(() {
// //                         bool isButtonDisabled = !shopVisitViewModel.isOrderButtonEnabled.value;
// //                         bool isLoading = shopVisitViewModel.isOrderFormLoading.value;
// //
// //                         return CustomButton(
// //                           textSize: fontSize,
// //                           iconSize: isTablet ? 22 : 18,
// //                           height: buttonHeight,
// //                           width: buttonWidth,
// //                           buttonText: isLoading
// //                               ? "Processing..."
// //                               : "Order Form",
// //                           icon: Icons.arrow_forward_ios_outlined,
// //                           iconColor: Colors.white,
// //                           iconPosition: IconPosition.right,
// //                           gradientColors: isButtonDisabled || isLoading
// //                               ? [Colors.grey, Colors.grey]
// //                               : [Colors.blue.shade900, Colors.blue],
// //                           onTap: isButtonDisabled
// //                               ? () {
// //                             String? errorMessage = shopVisitViewModel.getOrderFormErrorMessage();
// //                             if (errorMessage != null) {
// //                               Get.snackbar("Action Required", errorMessage,
// //                                   snackPosition: SnackPosition.BOTTOM,
// //                                   backgroundColor: Colors.red.shade400,
// //                                   colorText: Colors.white);
// //                             }
// //                           }
// //                               : () {
// //                             if (!isLoading) {
// //                               debugPrint("Order Form tapped ✅ (Proceeding)");
// //                               shopVisitViewModel.saveForm();
// //                             }
// //                           },
// //                         );
// //                       }),
// //                     ],
// //                   )
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   AppBar _buildAppBar() {
// //     return AppBar(
// //       title: const Text(
// //         'Shop Visit',
// //         style: TextStyle(color: Colors.white, fontSize: 24),
// //       ),
// //       centerTitle: true,
// //       leading: IconButton(
// //         icon: const Icon(Icons.arrow_back, color: Colors.white),
// //         onPressed: () {
// //           Get.offAllNamed("/home");
// //         },
// //       ),
// //       actions: [
// //         IconButton(
// //           icon: const Icon(Icons.refresh, color: Colors.white),
// //           onPressed: () {
// //             // These methods are now restored in the ViewModel
// //             shopVisitViewModel.fetchAllShopVisit();
// //             productsViewModel.fetchAllProductsModel();
// //           },
// //         ),
// //       ],
// //       backgroundColor: Colors.blue,
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required String label,
// //     required IconData icon,
// //     required String initialValue,
// //     required String? Function(String?) validator,
// //     required Function(String) onChanged,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool obscureText = false,
// //   }) {
// //     return CustomEditableMenuOption(
// //       readOnly: true,
// //       label: label,
// //       initialValue: initialValue,
// //       onChanged: onChanged,
// //       inputBorder: const UnderlineInputBorder(
// //         borderSide: BorderSide(color: Colors.blue, width: 1.0),
// //       ),
// //       iconColor: Colors.blue,
// //       useBoxShadow: false,
// //       icon: icon,
// //       validator: validator,
// //       keyboardType: keyboardType,
// //       obscureText: obscureText,
// //     );
// //   }
// // }
// //
// // class SectionHeader extends StatelessWidget {
// //   final String title;
// //
// //   const SectionHeader({required this.title, Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Align(
// //       alignment: Alignment.centerLeft,
// //       child: Text(
// //         title,
// //         style: Theme.of(context)
// //             .textTheme
// //             .titleLarge
// //             ?.copyWith(fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// import '../ViewModels/location_view_model.dart';
// import '../ViewModels/shop_visit_details_view_model.dart';
// import '../ViewModels/shop_visit_view_model.dart';
// import 'Components/custom_button.dart';
// import 'Components/custom_dropdown.dart';
// import 'Components/custom_editable_menu_option.dart' hide IconPosition;
// import 'Components/custom_switch.dart';
// import 'ShopVisitScreenComponents/check_list_section.dart';
// import 'ShopVisitScreenComponents/feedback_section.dart';
// import 'ShopVisitScreenComponents/photo_picker.dart';
// import 'ShopVisitScreenComponents/product_search_card.dart';
//
// class ShopVisitScreen extends StatefulWidget {
//   const ShopVisitScreen({super.key});
//
//   @override
//   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// }
//
// class _StateShopVisitScreen extends State<ShopVisitScreen> {
//   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
//   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
//   Get.put(ShopVisitDetailsViewModel());
//   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   final feedBackController = TextEditingController();
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     feedBackController.text = shopVisitViewModel.feedBack.value;
//     shopVisitViewModel.selectedShop.value = "";
//     shopVisitViewModel.selectedBrand.value = "";
//     // These methods are now restored in the ViewModel
//     shopVisitViewModel.fetchBrands();
//     shopVisitViewModel.fetchShops();
//     // Trigger initial validation
//     shopVisitViewModel.updateButtonReadiness();
//
//     // Listen to changes in feedback
//     ever(shopVisitViewModel.feedBack, (value) {
//       feedBackController.text = value;
//       feedBackController.selection = TextSelection.fromPosition(
//         TextPosition(offset: feedBackController.text.length),
//       );
//     });
//   }
//
//   String? requiredDropdownValidator(String? value, String placeholder) {
//     if (value == null || value.isEmpty || value == placeholder) {
//       return null;
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final isTablet = width > 600;
//
//     final double fontSize = isTablet ? 18 : 14;
//     final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
//     final double buttonHeight = isTablet ? 55 : 45;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: _buildAppBar(),
//         body: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.only(
//               left: 20,
//               right: 20,
//               top: 30,
//               bottom: MediaQuery.of(context).padding.bottom + 40,
//             ),
//             child: Form(
//               key: shopVisitViewModel.formKey, // Using the key from the ViewModel
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Column(
//                     // children: [
//                     //   Obx(
//                     //         () => CustomDropdown(
//                     //       label: "Brand",
//                     //       icon: Icons.branding_watermark,
//                     //       items: shopVisitViewModel.brands
//                     //           .where((brand) => brand != null)
//                     //           .cast<String>()
//                     //           .toList(),
//                     //       selectedValue: shopVisitViewModel
//                     //           .selectedBrand.value.isNotEmpty
//                     //           ? shopVisitViewModel.selectedBrand.value
//                     //           : " Select a Brand",
//                     //       onChanged: (value) async {
//                     //         shopVisitDetailsViewModel.filteredRows.refresh();
//                     //         shopVisitViewModel.setBrand(value!);
//                     //         shopVisitDetailsViewModel
//                     //             .filterProductsByBrand(value);
//                     //       },
//                     //       useBoxShadow: false,
//                     //       validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
//                     //       inputBorder: const UnderlineInputBorder(
//                     //         borderSide:
//                     //         BorderSide(color: Colors.blue, width: 1.0),
//                     //       ),
//                     //       iconSize: 22.0,
//                     //       contentPadding:
//                     //       MediaQuery.of(context).size.height * 0.005,
//                     //       iconColor: Colors.blue,
//                     //       textStyle: const TextStyle(
//                     //           fontSize: 13,
//                     //           fontWeight: FontWeight.bold,
//                     //           color: Colors.black),
//                     //     ),
//                     //   ),
//                     //   Obx(
//                     //         () => CustomDropdown(
//                     //       label: "Shop",
//                     //       icon: Icons.store,
//                     //       items: shopVisitViewModel.shops.value
//                     //           .where((shop) => shop != null)
//                     //           .cast<String>()
//                     //           .toList(),
//                     //       selectedValue: shopVisitViewModel
//                     //           .selectedShop.value.isNotEmpty
//                     //           ? shopVisitViewModel.selectedShop.value
//                     //           : " Select a Shop",
//                     //       onChanged: (value) {
//                     //         shopVisitViewModel.setSelectedShop(value!);
//                     //         debugPrint(shopVisitViewModel.shop_address.value);
//                     //         debugPrint(shopVisitViewModel.city.value);
//                     //       },
//                     //       validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
//                     //       useBoxShadow: false,
//                     //       inputBorder: const UnderlineInputBorder(
//                     //         borderSide:
//                     //         BorderSide(color: Colors.blue, width: 1.0),
//                     //       ),
//                     //       maxHeight: 50.0,
//                     //       maxWidth: 385.0,
//                     //       iconSize: 23.0,
//                     //       contentPadding: 0.0,
//                     //       iconColor: Colors.blue,
//                     //     ),
//                     //   ),
//                     //   Obx(() => _buildTextField(
//                     //     initialValue:
//                     //     shopVisitViewModel.shop_address.value,
//                     //     label: "Shop Address",
//                     //     icon: Icons.location_on,
//                     //     validator: (value) =>
//                     //     value == null || value.isEmpty
//                     //         ? 'Please enter the shop address'
//                     //         : null,
//                     //     onChanged: (value) =>
//                     //         shopVisitViewModel.setShopAddress(value),
//                     //   )),
//                     //   Obx(() => _buildTextField(
//                     //     initialValue: shopVisitViewModel.owner_name.value,
//                     //     label: "Owner Name",
//                     //     icon: Icons.person,
//                     //     validator: (value) =>
//                     //     value == null || value.isEmpty
//                     //         ? 'Please enter owner name'
//                     //         : null,
//                     //     onChanged: (value) =>
//                     //         shopVisitViewModel.setOwnerName(value),
//                     //   )),
//                     //   _buildTextField(
//                     //     label: "Booker Name",
//                     //     initialValue: shopVisitViewModel.booker_name.value,
//                     //     icon: Icons.person,
//                     //     validator: (value) =>
//                     //     value == null || value.isEmpty
//                     //         ? 'Please enter the booker name'
//                     //         : null,
//                     //     onChanged: (value) =>
//                     //     shopVisitViewModel.booker_name.value = value,
//                     //   ),
//                     // ],
//                     children: [
//                       Obx(
//                             () => CustomDropdown(
//                           label: "Brand",
//                           icon: Icons.branding_watermark,
//                           items: shopVisitViewModel.brands
//                               .where((brand) => brand != null)
//                               .cast<String>()
//                               .toList(),
//                           selectedValue: shopVisitViewModel
//                               .selectedBrand.value.isNotEmpty
//                               ? shopVisitViewModel.selectedBrand.value
//                               : " Select a Brand",
//                           onChanged: (value) async {
//                             shopVisitDetailsViewModel.filteredRows.refresh();
//                             shopVisitViewModel.setBrand(value!);
//                             shopVisitDetailsViewModel
//                                 .filterProductsByBrand(value);
//                           },
//                           useBoxShadow: false,
//                           validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
//                           inputBorder: const UnderlineInputBorder(
//                             borderSide:
//                             BorderSide(color: Colors.blue, width: 1.0),
//                           ),
//                           iconSize: 22.0,
//                           contentPadding:
//                           MediaQuery.of(context).size.height * 0.005,
//                           iconColor: Colors.blue,
//                           textStyle: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                         ),),
//                       Obx(
//                             () => CustomDropdown(
//                           label: "Shop",
//                           icon: Icons.store,
//                           items: shopVisitViewModel.shops.value
//                               .where((shop) => shop != null)
//                               .cast<String>()
//                               .toList(),
//                           selectedValue: shopVisitViewModel
//                               .selectedShop.value.isNotEmpty
//                               ? shopVisitViewModel.selectedShop.value
//                               : " Select a Shop",
//                           onChanged: (value) {
//                             shopVisitViewModel.setSelectedShop(value!);
//                             debugPrint(shopVisitViewModel.shop_address.value);
//                             debugPrint(shopVisitViewModel.city.value);
//                           },
//                           validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
//                           useBoxShadow: false,
//                           inputBorder: const UnderlineInputBorder(
//                             borderSide:
//                             BorderSide(color: Colors.blue, width: 1.0),
//                           ),
//                           maxHeight: 50.0,
//                           maxWidth: 385.0,
//                           iconSize: 23.0,
//                           contentPadding: 0.0,
//                           iconColor: Colors.blue,
//                         ),
//                       ),
//                       Obx(() => _buildTextField(
//                         initialValue:
//                         shopVisitViewModel.shop_address.value,
//                         label: "Shop Address",
//                         icon: Icons.location_on,
//                         validator: (value) =>
//                         value == null || value.isEmpty
//                             ? 'Please enter the shop address'
//                             : null,
//                         onChanged: (value) =>
//                             shopVisitViewModel.setShopAddress(value),
//                       )),
//                       Obx(() => _buildTextField(
//                         initialValue: shopVisitViewModel.owner_name.value,
//                         label: "Owner Name",
//                         icon: Icons.person,
//                         validator: (value) =>
//                         value == null || value.isEmpty
//                             ? 'Please enter owner name'
//                             : null,
//                         onChanged: (value) =>
//                             shopVisitViewModel.setOwnerName(value),
//                       )),
//                       _buildTextField(
//                         label: "Booker Name",
//                         initialValue: shopVisitViewModel.booker_name.value,
//                         icon: Icons.person,
//                         validator: (value) =>
//                         value == null || value.isEmpty
//                             ? 'Please enter the booker name'
//                             : null,
//                         onChanged: (value) =>
//                         shopVisitViewModel.booker_name.value = value,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   const SectionHeader(title: "Stock Check"),
//                   const SizedBox(height: 10),
//                   ProductSearchCard(
//                     filterData: shopVisitDetailsViewModel.filterData,
//                     rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
//                     filteredRows: shopVisitDetailsViewModel.filteredRows,
//                     shopVisitDetailsViewModel: shopVisitDetailsViewModel,
//                   ),
//                   const SizedBox(height: 20),
//                   ChecklistSection(
//                     labels: shopVisitViewModel.checklistLabels,
//                     checklistState: shopVisitViewModel.checklistState,
//                     onStateChanged: (index, value) {
//                       shopVisitViewModel.updateChecklistState(index, value);
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   PhotoPicker(
//                     selectedImage: shopVisitViewModel.selectedImage,
//                     onTakePicture: shopVisitViewModel.takePicture,
//                   ),
//                   const SizedBox(height: 20),
//                   // FeedbackSection(
//                   //   feedBackController: feedBackController,
//                   //   onChanged: (value) =>
//                   //       shopVisitViewModel.setFeedBack(value),
//                   // ),
//                   FeedbackSection(
//                     feedBackController: feedBackController,
//                     onChanged: (value) =>
//                         shopVisitViewModel.setFeedBack(value),
//                   ),
//                   const SizedBox(height: 20),
//                   Obx(() => CustomSwitch(
//                     label: "GPS Enabled",
//                     value: locationViewModel.isGPSEnabled.value,
//                     onChanged: (value) async {
//                       locationViewModel.isGPSEnabled.value = value;
//                       if (value) {
//                         await locationViewModel.saveCurrentLocation();
//                       }
//                       shopVisitViewModel.updateButtonReadiness();
//                     },
//                   )),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // ===== Only Visit Button - MODIFIED for Validation =====
//                       Obx(() {
//                         bool isButtonDisabled = !shopVisitViewModel.isOnlyVisitButtonEnabled.value;
//                         bool isLoading = shopVisitViewModel.isOnlyVisitLoading.value;
//
//                         return CustomButton(
//                           textSize: fontSize,
//                           iconSize: isTablet ? 22 : 18,
//                           height: buttonHeight,
//                           width: buttonWidth,
//                           icon: Icons.arrow_back_ios_new_rounded,
//                           iconColor: Colors.white,
//                           iconPosition: IconPosition.left,
//                           spacing: 4,
//                           buttonText: isLoading
//                               ? "Processing..."
//                               : "Only Visit",
//                           // Use disabled state for color
//                           gradientColors: isButtonDisabled || isLoading
//                               ? [Colors.grey, Colors.grey]
//                               : [Colors.red, Colors.red],
//                           // Logic to disable or show snackbar
//                           onTap: isButtonDisabled
//                               ? () {
//                             // Show snackbar with detailed error message for Only Visit
//                             String? errorMessage = shopVisitViewModel.getOnlyVisitErrorMessage();
//                             if (errorMessage != null) {
//                               Get.snackbar("Action Required", errorMessage,
//                                   snackPosition: SnackPosition.BOTTOM,
//                                   backgroundColor: Colors.red.shade700,
//                                   colorText: Colors.white);
//                             }
//                           }
//                               : () {
//                             if (!isLoading) {
//                               debugPrint("Only Visit tapped ✅ (Proceeding)");
//                               shopVisitViewModel.saveFormNoOrder(); // Proceed to save and navigate
//                             }
//                           },
//                         );
//                       }),
//
//                       // ===== Order Form Button =====
//                       Obx(() {
//                         bool isButtonDisabled = !shopVisitViewModel.isOrderButtonEnabled.value;
//                         bool isLoading = shopVisitViewModel.isOrderFormLoading.value;
//
//                         return CustomButton(
//                           textSize: fontSize,
//                           iconSize: isTablet ? 22 : 18,
//                           height: buttonHeight,
//                           width: buttonWidth,
//                           buttonText: isLoading
//                               ? "Processing..."
//                               : "Order Form",
//                           icon: Icons.arrow_forward_ios_outlined,
//                           iconColor: Colors.white,
//                           iconPosition: IconPosition.right,
//                           gradientColors: isButtonDisabled || isLoading
//                               ? [Colors.grey, Colors.grey]
//                               : [Colors.blue.shade900, Colors.blue],
//                           onTap: isButtonDisabled
//                               ? () {
//                             String? errorMessage = shopVisitViewModel.getOrderFormErrorMessage();
//                             if (errorMessage != null) {
//                               Get.snackbar("Action Required", errorMessage,
//                                   snackPosition: SnackPosition.BOTTOM,
//                                   backgroundColor: Colors.red.shade400,
//                                   colorText: Colors.white);
//                             }
//                           }
//                               : () {
//                             if (!isLoading) {
//                               debugPrint("Order Form tapped ✅ (Proceeding)");
//                               shopVisitViewModel.saveForm();
//                             }
//                           },
//                         );
//                       }),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   AppBar _buildAppBar() {
//     return AppBar(
//       title: const Text(
//         'Shop Visit',
//         style: TextStyle(color: Colors.white, fontSize: 24),
//       ),
//       centerTitle: true,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () {
//           Get.offAllNamed("/home");
//         },
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh, color: Colors.white),
//           onPressed: () {
//             // These methods are now restored in the ViewModel
//             shopVisitViewModel.fetchAllShopVisit();
//             productsViewModel.fetchAllProductsModel();
//           },
//         ),
//       ],
//       backgroundColor: Colors.blue,
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required IconData icon,
//     required String initialValue,
//     required String? Function(String?) validator,
//     required Function(String) onChanged,
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//   }) {
//     return CustomEditableMenuOption(
//       readOnly: true,
//       label: label,
//       initialValue: initialValue,
//       onChanged: onChanged,
//       inputBorder: const UnderlineInputBorder(
//         borderSide: BorderSide(color: Colors.blue, width: 1.0),
//       ),
//       iconColor: Colors.blue,
//       useBoxShadow: false,
//       icon: icon,
//       validator: validator,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//     );
//   }
// }
//
// class SectionHeader extends StatelessWidget {
//   final String title;
//
//   const SectionHeader({required this.title, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: Theme.of(context)
//             .textTheme
//             .titleLarge
//             ?.copyWith(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
//
//
//
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// // // import '../ViewModels/location_view_model.dart';
// // // import '../ViewModels/shop_visit_details_view_model.dart';
// // // import '../ViewModels/shop_visit_view_model.dart';
// // // import 'Components/custom_button.dart';
// // // import 'Components/custom_dropdown.dart';
// // // import 'Components/custom_editable_menu_option.dart' hide IconPosition;
// // // import 'Components/custom_switch.dart';
// // // import 'ShopVisitScreenComponents/check_list_section.dart';
// // // import 'ShopVisitScreenComponents/feedback_section.dart';
// // // import 'ShopVisitScreenComponents/photo_picker.dart';
// // // import 'ShopVisitScreenComponents/product_search_card.dart';
// // //
// // // class ShopVisitScreen extends StatefulWidget {
// // //   const ShopVisitScreen({super.key});
// // //
// // //   @override
// // //   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// // // }
// // //
// // // class _StateShopVisitScreen extends State<ShopVisitScreen> {
// // //   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
// // //   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
// // //   Get.put(ShopVisitDetailsViewModel());
// // //   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
// // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // //   final feedBackController = TextEditingController();
// // //
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     feedBackController.text = shopVisitViewModel.feedBack.value;
// // //     shopVisitViewModel.selectedShop.value = "";
// // //     shopVisitViewModel.selectedBrand.value = "";
// // //     shopVisitViewModel.fetchBrands();
// // //     shopVisitViewModel.fetchShops();
// // //     ever(shopVisitViewModel.feedBack, (value) {
// // //       feedBackController.text = value;
// // //       feedBackController.selection = TextSelection.fromPosition(
// // //         TextPosition(offset: feedBackController.text.length),
// // //       );
// // //     });
// // //   }
// // //
// // //   // FIX: Helper function to satisfy the CustomDropdown's required validator
// // //   String? requiredDropdownValidator(String? value, String placeholder) {
// // //     // We rely on the ViewModel for the actual error message,
// // //     // but the validator must be present. Returning null here lets the VM handle the submission block.
// // //     if (value == null || value.isEmpty || value == placeholder) {
// // //       return null;
// // //     }
// // //     return null;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final size = MediaQuery.of(context).size;
// // //     final height = size.height;
// // //     final width = size.width;
// // //     final isTablet = width > 600;
// // //
// // //     final double padding = width * 0.05;
// // //     final double fontSize = isTablet ? 18 : 14;
// // //     final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
// // //     final double buttonHeight = isTablet ? 55 : 45;
// // //     return SafeArea(
// // //       child: Scaffold(
// // //         backgroundColor: Colors.white,
// // //         appBar: _buildAppBar(),
// // //         body: SingleChildScrollView(
// // //           physics: const BouncingScrollPhysics(),
// // //           child: Padding(
// // //             padding: EdgeInsets.only(
// // //               left: 20,
// // //               right: 20,
// // //               top: 30,
// // //               bottom: MediaQuery.of(context).padding.bottom + 40,
// // //             ),
// // //             child: Form(
// // //               key: shopVisitViewModel.formKey,
// // //               child: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 crossAxisAlignment: CrossAxisAlignment.center,
// // //                 children: [
// // //                   Column(
// // //                     children: [
// // //                       Obx(
// // //                             () => CustomDropdown(
// // //                           label: "Brand",
// // //                           icon: Icons.branding_watermark,
// // //                           items: shopVisitViewModel.brands
// // //                               .where((brand) => brand != null)
// // //                               .cast<String>()
// // //                               .toList(),
// // //                           selectedValue: shopVisitViewModel
// // //                               .selectedBrand.value.isNotEmpty
// // //                               ? shopVisitViewModel.selectedBrand.value
// // //                               : " Select a Brand",
// // //                           onChanged: (value) async {
// // //                             shopVisitDetailsViewModel.filteredRows.refresh();
// // //                             shopVisitViewModel.selectedBrand.value = value!;
// // //                             shopVisitDetailsViewModel
// // //                                 .filterProductsByBrand(value);
// // //                           },
// // //                           useBoxShadow: false,
// // //                           // FIX 1: Pass validator argument
// // //                           validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
// // //                           inputBorder: const UnderlineInputBorder(
// // //                             borderSide:
// // //                             BorderSide(color: Colors.blue, width: 1.0),
// // //                           ),
// // //                           iconSize: 22.0,
// // //                           contentPadding:
// // //                           MediaQuery.of(context).size.height * 0.005,
// // //                           iconColor: Colors.blue,
// // //                           textStyle: const TextStyle(
// // //                               fontSize: 13,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.black),
// // //                         ),
// // //                       ),
// // //                       Obx(
// // //                             () => CustomDropdown(
// // //                           label: "Shop",
// // //                           icon: Icons.store,
// // //                           items: shopVisitViewModel.shops.value
// // //                               .where((shop) => shop != null)
// // //                               .cast<String>()
// // //                               .toList(),
// // //                           selectedValue: shopVisitViewModel
// // //                               .selectedShop.value.isNotEmpty
// // //                               ? shopVisitViewModel.selectedShop.value
// // //                               : " Select a Shop",
// // //                           onChanged: (value) {
// // //                             shopVisitViewModel.selectedShop.value = value!;
// // //                             shopVisitViewModel.updateShopDetails(value);
// // //                             shopVisitViewModel.selectedShop.value = value;
// // //                             debugPrint(shopVisitViewModel.shop_address.value);
// // //                             debugPrint(shopVisitViewModel.city.value);
// // //                           },
// // //                           // FIX 2: Pass validator argument
// // //                           validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
// // //                           useBoxShadow: false,
// // //                           inputBorder: const UnderlineInputBorder(
// // //                             borderSide:
// // //                             BorderSide(color: Colors.blue, width: 1.0),
// // //                           ),
// // //                           maxHeight: 50.0,
// // //                           maxWidth: 385.0,
// // //                           iconSize: 23.0,
// // //                           contentPadding: 0.0,
// // //                           iconColor: Colors.blue,
// // //                         ),
// // //                       ),
// // //                       Obx(() => _buildTextField(
// // //                         initialValue:
// // //                         shopVisitViewModel.shop_address.value,
// // //                         label: "Shop Address",
// // //                         icon: Icons.location_on,
// // //                         validator: (value) =>
// // //                         value == null || value.isEmpty
// // //                             ? 'Please enter the shop address'
// // //                             : null,
// // //                         onChanged: (value) =>
// // //                         shopVisitViewModel.shop_address.value = value,
// // //                       )),
// // //                       Obx(() => _buildTextField(
// // //                         initialValue: shopVisitViewModel.owner_name.value,
// // //                         label: "Owner Name",
// // //                         icon: Icons.person,
// // //                         validator: (value) =>
// // //                         value == null || value.isEmpty
// // //                             ? 'Please enter owner name'
// // //                             : null,
// // //                         onChanged: (value) =>
// // //                         shopVisitViewModel.owner_name.value = value,
// // //                       )),
// // //                       _buildTextField(
// // //                         label: "Booker Name",
// // //                         initialValue: shopVisitViewModel.booker_name.value,
// // //                         icon: Icons.person,
// // //                         validator: (value) =>
// // //                         value == null || value.isEmpty
// // //                             ? 'Please enter the booker name'
// // //                             : null,
// // //                         onChanged: (value) =>
// // //                         shopVisitViewModel.booker_name.value = value,
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   const SectionHeader(title: "Stock Check"),
// // //                   const SizedBox(height: 10),
// // //                   ProductSearchCard(
// // //                     filterData: shopVisitDetailsViewModel.filterData,
// // //                     rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
// // //                     filteredRows: shopVisitDetailsViewModel.filteredRows,
// // //                     shopVisitDetailsViewModel: shopVisitDetailsViewModel,
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   ChecklistSection(
// // //                     labels: shopVisitViewModel.checklistLabels,
// // //                     checklistState: shopVisitViewModel.checklistState,
// // //                     onStateChanged: (index, value) {
// // //                       shopVisitViewModel.checklistState[index] = value;
// // //                     },
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   PhotoPicker(
// // //                     selectedImage: shopVisitViewModel.selectedImage,
// // //                     onTakePicture: shopVisitViewModel.takePicture,
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   FeedbackSection(
// // //                     feedBackController: TextEditingController(
// // //                         text: shopVisitViewModel.feedBack.value),
// // //                     onChanged: (value) =>
// // //                     shopVisitViewModel.feedBack.value = value,
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   Obx(() => CustomSwitch(
// // //                     label: "GPS Enabled",
// // //                     value: locationViewModel.isGPSEnabled.value,
// // //                     onChanged: (value) async {
// // //                       locationViewModel.isGPSEnabled.value = value;
// // //                       if (value) {
// // //                         await locationViewModel.saveCurrentLocation();
// // //                       }
// // //                     },
// // //                   )),
// // //                   SizedBox(height: height * 0.03),
// // //                   Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                     children: [
// // //                       // ===== Only Visit Button - Dynamic State =====
// // //                       Obx(() => CustomButton(
// // //                         textSize: fontSize,
// // //                         iconSize: isTablet ? 22 : 18,
// // //                         height: buttonHeight,
// // //                         width: buttonWidth,
// // //                         icon: Icons.arrow_back_ios_new_rounded,
// // //                         iconColor: Colors.white,
// // //                         iconPosition: IconPosition.left,
// // //                         spacing: 4,
// // //                         // MODIFIED: Use isOnlyVisitLoading for text
// // //                         buttonText: shopVisitViewModel.isOnlyVisitLoading.value
// // //                             ? "Processing..."
// // //                             : "Only Visit",
// // //                         // MODIFIED: Use isOnlyVisitLoading for color
// // //                         gradientColors: shopVisitViewModel.isOnlyVisitLoading.value
// // //                             ? [Colors.grey, Colors.grey]
// // //                             : [Colors.red, Colors.red],
// // //                         onTap: () {
// // //                           // MODIFIED: Check isOnlyVisitLoading
// // //                           if (!shopVisitViewModel.isOnlyVisitLoading.value) {
// // //                             debugPrint("Only Visit tapped ✅");
// // //                             shopVisitViewModel.saveFormNoOrder();
// // //                           }
// // //                         },
// // //                       )),
// // //
// // //                       // ===== Order Form Button - Dynamic State (Fix for double-tap/disable) =====
// // //                       Obx(() => CustomButton(
// // //                         textSize: fontSize,
// // //                         iconSize: isTablet ? 22 : 18,
// // //                         height: buttonHeight,
// // //                         width: buttonWidth,
// // //                         // MODIFIED: Use isOrderFormLoading for text
// // //                         buttonText: shopVisitViewModel.isOrderFormLoading.value
// // //                             ? "Processing..."
// // //                             : "Order Form",
// // //                         icon: Icons.arrow_forward_ios_outlined,
// // //                         iconColor: Colors.white,
// // //                         iconPosition: IconPosition.right,
// // //                         // MODIFIED: Use isOrderFormLoading for color
// // //                         gradientColors: shopVisitViewModel.isOrderFormLoading.value
// // //                             ? [Colors.grey, Colors.grey]
// // //                             : [Colors.blue.shade900, Colors.blue],
// // //                         onTap: () {
// // //                           // MODIFIED: Check isOrderFormLoading
// // //                           if (!shopVisitViewModel.isOrderFormLoading.value) {
// // //                             debugPrint("Order Form tapped ✅");
// // //                             shopVisitViewModel.saveForm();
// // //                           }
// // //                         },
// // //                       )),
// // //                     ],
// // //                   )
// // //
// // //
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   AppBar _buildAppBar() {
// // //     return AppBar(
// // //       title: const Text(
// // //         'Shop Visit',
// // //         style: TextStyle(color: Colors.white, fontSize: 24),
// // //       ),
// // //       centerTitle: true,
// // //       leading: IconButton(
// // //         icon: const Icon(Icons.arrow_back, color: Colors.white),
// // //         onPressed: () {
// // //           Get.offAllNamed("/home");
// // //         },
// // //       ),
// // //       actions: [
// // //         IconButton(
// // //           icon: const Icon(Icons.refresh, color: Colors.white),
// // //           onPressed: () {
// // //             shopVisitViewModel.fetchAllShopVisit();
// // //             productsViewModel.fetchAllProductsModel();
// // //           },
// // //         ),
// // //       ],
// // //       backgroundColor: Colors.blue,
// // //     );
// // //   }
// // //
// // //   Widget _buildTextField({
// // //     required String label,
// // //     required IconData icon,
// // //     required String initialValue,
// // //     required String? Function(String?) validator,
// // //     required Function(String) onChanged,
// // //     TextInputType keyboardType = TextInputType.text,
// // //     bool obscureText = false,
// // //   }) {
// // //     return CustomEditableMenuOption(
// // //       readOnly: true,
// // //       label: label,
// // //       initialValue: initialValue,
// // //       onChanged: onChanged,
// // //       inputBorder: const UnderlineInputBorder(
// // //         borderSide: BorderSide(color: Colors.blue, width: 1.0),
// // //       ),
// // //       iconColor: Colors.blue,
// // //       useBoxShadow: false,
// // //       icon: icon,
// // //       validator: validator,
// // //       keyboardType: keyboardType,
// // //       obscureText: obscureText,
// // //     );
// // //   }
// // // }
// // //
// // // class SectionHeader extends StatelessWidget {
// // //   final String title;
// // //
// // //   const SectionHeader({required this.title, Key? key}) : super(key: key);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Align(
// // //       alignment: Alignment.centerLeft,
// // //       child: Text(
// // //         title,
// // //         style: Theme.of(context)
// // //             .textTheme
// // //             .titleLarge
// // //             ?.copyWith(fontWeight: FontWeight.bold),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// //
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// // import '../ViewModels/location_view_model.dart';
// // import '../ViewModels/shop_visit_details_view_model.dart';
// // import '../ViewModels/shop_visit_view_model.dart';
// // import 'Components/custom_button.dart';
// // import 'Components/custom_dropdown.dart';
// // import 'Components/custom_editable_menu_option.dart' hide IconPosition;
// // import 'Components/custom_switch.dart';
// // import 'ShopVisitScreenComponents/check_list_section.dart';
// // import 'ShopVisitScreenComponents/feedback_section.dart';
// // import 'ShopVisitScreenComponents/photo_picker.dart';
// // import 'ShopVisitScreenComponents/product_search_card.dart';
// //
// // class ShopVisitScreen extends StatefulWidget {
// //   const ShopVisitScreen({super.key});
// //
// //   @override
// //   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// // }
// //
// // class _StateShopVisitScreen extends State<ShopVisitScreen> {
// //   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
// //   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
// //   Get.put(ShopVisitDetailsViewModel());
// //   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //   final feedBackController = TextEditingController();
// //
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     feedBackController.text = shopVisitViewModel.feedBack.value;
// //     shopVisitViewModel.selectedShop.value = "";
// //     shopVisitViewModel.selectedBrand.value = "";
// //     shopVisitViewModel.fetchBrands();
// //     shopVisitViewModel.fetchShops();
// //     ever(shopVisitViewModel.feedBack, (value) {
// //       feedBackController.text = value;
// //       feedBackController.selection = TextSelection.fromPosition(
// //         TextPosition(offset: feedBackController.text.length),
// //       );
// //     });
// //   }
// //
// //   // FIX: Helper function to satisfy the CustomDropdown's required validator
// //   String? requiredDropdownValidator(String? value, String placeholder) {
// //     // We rely on the ViewModel for the actual error message,
// //     // but the validator must be present. Returning null here lets the VM handle the submission block.
// //     if (value == null || value.isEmpty || value == placeholder) {
// //       return null;
// //     }
// //     return null;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //     final height = size.height;
// //     final width = size.width;
// //     final isTablet = width > 600;
// //
// //     final double padding = width * 0.05;
// //     final double fontSize = isTablet ? 18 : 14;
// //     final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
// //     final double buttonHeight = isTablet ? 55 : 45;
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: Colors.white,
// //         appBar: _buildAppBar(),
// //         body: SingleChildScrollView(
// //           physics: const BouncingScrollPhysics(),
// //           child: Padding(
// //             padding: EdgeInsets.only(
// //               left: 20,
// //               right: 20,
// //               top: 30,
// //               bottom: MediaQuery.of(context).padding.bottom + 40,
// //             ),
// //             child: Form(
// //               key: shopVisitViewModel.formKey,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   Column(
// //                     children: [
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Brand",
// //                           icon: Icons.branding_watermark,
// //                           items: shopVisitViewModel.brands
// //                               .where((brand) => brand != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedBrand.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedBrand.value
// //                               : " Select a Brand",
// //                           onChanged: (value) async {
// //                             shopVisitDetailsViewModel.filteredRows.refresh();
// //                             shopVisitViewModel.selectedBrand.value = value!;
// //                             shopVisitDetailsViewModel
// //                                 .filterProductsByBrand(value);
// //                           },
// //                           useBoxShadow: false,
// //                           // FIX 1: Pass validator argument
// //                           validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           iconSize: 22.0,
// //                           contentPadding:
// //                           MediaQuery.of(context).size.height * 0.005,
// //                           iconColor: Colors.blue,
// //                           textStyle: const TextStyle(
// //                               fontSize: 13,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black),
// //                         ),
// //                       ),
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Shop",
// //                           icon: Icons.store,
// //                           items: shopVisitViewModel.shops.value
// //                               .where((shop) => shop != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedShop.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedShop.value
// //                               : " Select a Shop",
// //                           onChanged: (value) {
// //                             shopVisitViewModel.selectedShop.value = value!;
// //                             shopVisitViewModel.updateShopDetails(value);
// //                             shopVisitViewModel.selectedShop.value = value;
// //                             debugPrint(shopVisitViewModel.shop_address.value);
// //                             debugPrint(shopVisitViewModel.city.value);
// //                           },
// //                           // FIX 2: Pass validator argument
// //                           validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
// //                           useBoxShadow: false,
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           maxHeight: 50.0,
// //                           maxWidth: 385.0,
// //                           iconSize: 23.0,
// //                           contentPadding: 0.0,
// //                           iconColor: Colors.blue,
// //                         ),
// //                       ),
// //                       Obx(() => _buildTextField(
// //                         initialValue:
// //                         shopVisitViewModel.shop_address.value,
// //                         label: "Shop Address",
// //                         icon: Icons.location_on,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the shop address'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.shop_address.value = value,
// //                       )),
// //                       Obx(() => _buildTextField(
// //                         initialValue: shopVisitViewModel.owner_name.value,
// //                         label: "Owner Name",
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter owner name'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.owner_name.value = value,
// //                       )),
// //                       _buildTextField(
// //                         label: "Booker Name",
// //                         initialValue: shopVisitViewModel.booker_name.value,
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the booker name'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.booker_name.value = value,
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const SectionHeader(title: "Stock Check"),
// //                   const SizedBox(height: 10),
// //                   ProductSearchCard(
// //                     filterData: shopVisitDetailsViewModel.filterData,
// //                     rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
// //                     filteredRows: shopVisitDetailsViewModel.filteredRows,
// //                     shopVisitDetailsViewModel: shopVisitDetailsViewModel,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   ChecklistSection(
// //                     labels: shopVisitViewModel.checklistLabels,
// //                     checklistState: shopVisitViewModel.checklistState,
// //                     onStateChanged: (index, value) {
// //                       shopVisitViewModel.checklistState[index] = value;
// //                     },
// //                   ),
// //                   const SizedBox(height: 20),
// //                   PhotoPicker(
// //                     selectedImage: shopVisitViewModel.selectedImage,
// //                     onTakePicture: shopVisitViewModel.takePicture,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   FeedbackSection(
// //                     feedBackController: TextEditingController(
// //                         text: shopVisitViewModel.feedBack.value),
// //                     onChanged: (value) =>
// //                     shopVisitViewModel.feedBack.value = value,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Obx(() => CustomSwitch(
// //                     label: "GPS Enabled",
// //                     value: locationViewModel.isGPSEnabled.value,
// //                     onChanged: (value) async {
// //                       locationViewModel.isGPSEnabled.value = value;
// //                       if (value) {
// //                         await locationViewModel.saveCurrentLocation();
// //                       }
// //                     },
// //                   )),
// //                   SizedBox(height: height * 0.03),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       // ===== Only Visit Button - Dynamic State =====
// //                       Obx(() => CustomButton(
// //                         textSize: fontSize,
// //                         iconSize: isTablet ? 22 : 18,
// //                         height: buttonHeight,
// //                         width: buttonWidth,
// //                         icon: Icons.arrow_back_ios_new_rounded,
// //                         iconColor: Colors.white,
// //                         iconPosition: IconPosition.left,
// //                         spacing: 4,
// //                         // MODIFIED: Use isOnlyVisitLoading for text
// //                         buttonText: shopVisitViewModel.isOnlyVisitLoading.value
// //                             ? "Processing..."
// //                             : "Only Visit",
// //                         // MODIFIED: Use isOnlyVisitLoading for color
// //                         gradientColors: shopVisitViewModel.isOnlyVisitLoading.value
// //                             ? [Colors.grey, Colors.grey]
// //                             : [Colors.red, Colors.red],
// //                         onTap: () {
// //                           // MODIFIED: Check isOnlyVisitLoading
// //                           if (!shopVisitViewModel.isOnlyVisitLoading.value) {
// //                             debugPrint("Only Visit tapped ✅");
// //                             shopVisitViewModel.saveFormNoOrder();
// //                           }
// //                         },
// //                       )),
// //
// //                       // ===== Order Form Button - Dynamic State (Fix for double-tap/disable) =====
// //                       Obx(() => CustomButton(
// //                         textSize: fontSize,
// //                         iconSize: isTablet ? 22 : 18,
// //                         height: buttonHeight,
// //                         width: buttonWidth,
// //                         // MODIFIED: Use isOrderFormLoading for text
// //                         buttonText: shopVisitViewModel.isOrderFormLoading.value
// //                             ? "Processing..."
// //                             : "Order Form",
// //                         icon: Icons.arrow_forward_ios_outlined,
// //                         iconColor: Colors.white,
// //                         iconPosition: IconPosition.right,
// //                         // MODIFIED: Use isOrderFormLoading for color
// //                         gradientColors: shopVisitViewModel.isOrderFormLoading.value
// //                             ? [Colors.grey, Colors.grey]
// //                             : [Colors.blue.shade900, Colors.blue],
// //                         onTap: () {
// //                           // MODIFIED: Check isOrderFormLoading
// //                           if (!shopVisitViewModel.isOrderFormLoading.value) {
// //                             debugPrint("Order Form tapped ✅");
// //                             shopVisitViewModel.saveForm();
// //                           }
// //                         },
// //                       )),
// //                     ],
// //                   )
// //
// //
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   AppBar _buildAppBar() {
// //     return AppBar(
// //       title: const Text(
// //         'Shop Visit',
// //         style: TextStyle(color: Colors.white, fontSize: 24),
// //       ),
// //       centerTitle: true,
// //       leading: IconButton(
// //         icon: const Icon(Icons.arrow_back, color: Colors.white),
// //         onPressed: () {
// //           Get.offAllNamed("/home");
// //         },
// //       ),
// //       actions: [
// //         IconButton(
// //           icon: const Icon(Icons.refresh, color: Colors.white),
// //           onPressed: () {
// //             shopVisitViewModel.fetchAllShopVisit();
// //             productsViewModel.fetchAllProductsModel();
// //           },
// //         ),
// //       ],
// //       backgroundColor: Colors.blue,
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required String label,
// //     required IconData icon,
// //     required String initialValue,
// //     required String? Function(String?) validator,
// //     required Function(String) onChanged,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool obscureText = false,
// //   }) {
// //     return CustomEditableMenuOption(
// //       readOnly: true,
// //       label: label,
// //       initialValue: initialValue,
// //       onChanged: onChanged,
// //       inputBorder: const UnderlineInputBorder(
// //         borderSide: BorderSide(color: Colors.blue, width: 1.0),
// //       ),
// //       iconColor: Colors.blue,
// //       useBoxShadow: false,
// //       icon: icon,
// //       validator: validator,
// //       keyboardType: keyboardType,
// //       obscureText: obscureText,
// //     );
// //   }
// // }
// //
// // class SectionHeader extends StatelessWidget {
// //   final String title;
// //
// //   const SectionHeader({required this.title, Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Align(
// //       alignment: Alignment.centerLeft,
// //       child: Text(
// //         title,
// //         style: Theme.of(context)
// //             .textTheme
// //             .titleLarge
// //             ?.copyWith(fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
//
// // ===============final code===================
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// // import '../ViewModels/location_view_model.dart';
// // import '../ViewModels/shop_visit_details_view_model.dart';
// // import '../ViewModels/shop_visit_view_model.dart';
// // import 'Components/custom_button.dart';
// // import 'Components/custom_dropdown.dart';
// // import 'Components/custom_editable_menu_option.dart' hide IconPosition;
// // import 'Components/custom_switch.dart';
// // import 'ShopVisitScreenComponents/check_list_section.dart';
// // import 'ShopVisitScreenComponents/feedback_section.dart';
// // import 'ShopVisitScreenComponents/photo_picker.dart';
// // import 'ShopVisitScreenComponents/product_search_card.dart';
// //
// // class ShopVisitScreen extends StatefulWidget {
// //   const ShopVisitScreen({super.key});
// //
// //   @override
// //   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// // }
// //
// // class _StateShopVisitScreen extends State<ShopVisitScreen> {
// //   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
// //   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
// //   Get.put(ShopVisitDetailsViewModel());
// //   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
// //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// //   final feedBackController = TextEditingController();
// //
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     feedBackController.text = shopVisitViewModel.feedBack.value;
// //     shopVisitViewModel.selectedShop.value = "";
// //     shopVisitViewModel.selectedBrand.value = "";
// //     shopVisitViewModel.fetchBrands();
// //     shopVisitViewModel.fetchShops();
// //     ever(shopVisitViewModel.feedBack, (value) {
// //       feedBackController.text = value;
// //       feedBackController.selection = TextSelection.fromPosition(
// //         TextPosition(offset: feedBackController.text.length),
// //       );
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //     final height = size.height;
// //     final width = size.width;
// //     final isTablet = width > 600;
// //
// //     final double padding = width * 0.05;
// //     final double fontSize = isTablet ? 18 : 14;
// //     final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
// //     final double buttonHeight = isTablet ? 55 : 45;
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: Colors.white,
// //         appBar: _buildAppBar(),
// //         body: SingleChildScrollView(
// //           physics: const BouncingScrollPhysics(),
// //           child: Padding(
// //             padding: EdgeInsets.only(
// //               left: 20,
// //               right: 20,
// //               top: 30,
// //               bottom: MediaQuery.of(context).padding.bottom + 40, // ✅ ensures bottom tap area
// //             ),
// //             child: Form(
// //               key: shopVisitViewModel.formKey,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min, // ✅ prevents overflow blocking tap
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   Column(
// //                     children: [
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Brand",
// //                           icon: Icons.branding_watermark,
// //                           items: shopVisitViewModel.brands
// //                               .where((brand) => brand != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedBrand.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedBrand.value
// //                               : " Select a Brand",
// //                           onChanged: (value) async {
// //                             shopVisitDetailsViewModel.filteredRows.refresh();
// //                             shopVisitViewModel.selectedBrand.value = value!;
// //                             shopVisitDetailsViewModel
// //                                 .filterProductsByBrand(value);
// //                           },
// //                           useBoxShadow: false,
// //                           validator: (value) => value == null || value.isEmpty
// //                               ? 'Please select a brand'
// //                               : null,
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           iconSize: 22.0,
// //                           contentPadding:
// //                           MediaQuery.of(context).size.height * 0.005,
// //                           iconColor: Colors.blue,
// //                           textStyle: const TextStyle(
// //                               fontSize: 13,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black),
// //                         ),
// //                       ),
// //                       Obx(
// //                             () => CustomDropdown(
// //                           label: "Shop",
// //                           icon: Icons.store,
// //                           items: shopVisitViewModel.shops.value
// //                               .where((shop) => shop != null)
// //                               .cast<String>()
// //                               .toList(),
// //                           selectedValue: shopVisitViewModel
// //                               .selectedShop.value.isNotEmpty
// //                               ? shopVisitViewModel.selectedShop.value
// //                               : " Select  a Shop",
// //                           onChanged: (value) {
// //                             shopVisitViewModel.selectedShop.value = value!;
// //                             shopVisitViewModel.updateShopDetails(value);
// //                             shopVisitViewModel.selectedShop.value = value;
// //                             debugPrint(shopVisitViewModel.shop_address.value);
// //                             debugPrint(shopVisitViewModel.city.value);
// //                           },
// //                           validator: (value) => value == null || value.isEmpty
// //                               ? 'Please select a shop'
// //                               : null,
// //                           useBoxShadow: false,
// //                           inputBorder: const UnderlineInputBorder(
// //                             borderSide:
// //                             BorderSide(color: Colors.blue, width: 1.0),
// //                           ),
// //                           maxHeight: 50.0,
// //                           maxWidth: 385.0,
// //                           iconSize: 23.0,
// //                           contentPadding: 0.0,
// //                           iconColor: Colors.blue,
// //                         ),
// //                       ),
// //                       Obx(() => _buildTextField(
// //                         initialValue:
// //                         shopVisitViewModel.shop_address.value,
// //                         label: "Shop Address",
// //                         icon: Icons.location_on,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the shop address'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.shop_address.value = value,
// //                       )),
// //                       Obx(() => _buildTextField(
// //                         initialValue: shopVisitViewModel.owner_name.value,
// //                         label: "Owner Name",
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter owner name'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.owner_name.value = value,
// //                       )),
// //                       _buildTextField(
// //                         label: "Booker Name",
// //                         initialValue: shopVisitViewModel.booker_name.value,
// //                         icon: Icons.person,
// //                         validator: (value) =>
// //                         value == null || value.isEmpty
// //                             ? 'Please enter the booker name'
// //                             : null,
// //                         onChanged: (value) =>
// //                         shopVisitViewModel.booker_name.value = value,
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const SectionHeader(title: "Stock Check"),
// //                   const SizedBox(height: 10),
// //                   ProductSearchCard(
// //                     filterData: shopVisitDetailsViewModel.filterData,
// //                     rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
// //                     filteredRows: shopVisitDetailsViewModel.filteredRows,
// //                     shopVisitDetailsViewModel: shopVisitDetailsViewModel,
// //                   ),
// //                   const SizedBox(height: 20),
// //                   ChecklistSection(
// //                     labels: shopVisitViewModel.checklistLabels,
// //                     checklistState: shopVisitViewModel.checklistState,
// //                     onStateChanged: (index, value) {
// //                       shopVisitViewModel.checklistState[index] = value;
// //                     },
// //                   ),
// //                   const SizedBox(height: 20),
// //                   PhotoPicker(
// //                     selectedImage: shopVisitViewModel.selectedImage,
// //                     onTakePicture: shopVisitViewModel.takePicture,
// //                   ),
// //                   const SizedBox(height: 20),
// //           // Obx(() {
// //           //   final controller = TextEditingController();
// //           //   WidgetsBinding.instance.addPostFrameCallback((_) {
// //           //     controller.text = shopVisitViewModel.feedBack.value;
// //           //   });
// //           //
// //           //   return FeedbackSection(
// //           //     feedBackController: controller,
// //           //     onChanged: (value) => shopVisitViewModel.feedBack.value = value,
// //           //   );
// //           // }),
// //
// //           FeedbackSection(
// //                     feedBackController: TextEditingController(
// //                         text: shopVisitViewModel.feedBack.value),
// //                     onChanged: (value) =>
// //                     shopVisitViewModel.feedBack.value = value,
// //                    ),
// //                     // Obx(() => FeedbackSection(
// //                   //
// //                   //
// //                   //   feedBackController: TextEditingController(
// //                   //       text: shopVisitViewModel.feedBack.value),
// //                   //   onChanged: (value) =>
// //                   //   shopVisitViewModel.feedBack.value = value,
// //                   // )),
// //                   const SizedBox(height: 20),
// //                   Obx(() => CustomSwitch(
// //                     label: "GPS Enabled",
// //                     value: locationViewModel.isGPSEnabled.value,
// //                     onChanged: (value) async {
// //                       locationViewModel.isGPSEnabled.value = value;
// //                       if (value) {
// //                         await locationViewModel.saveCurrentLocation();
// //                       }
// //                     },
// //                   )),
// //                   SizedBox(height: height * 0.03),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [
// //                       // ===== Only Visit Button =====
// //                       CustomButton(
// //                         textSize: fontSize,
// //                         iconSize: isTablet ? 22 : 18,
// //                         height: buttonHeight,
// //                         width: buttonWidth,
// //                         icon: Icons.arrow_back_ios_new_rounded,
// //                         iconColor: Colors.white,
// //                         iconPosition: IconPosition.left,
// //                         spacing: 4,
// //                         buttonText: "Only Visit",
// //                         gradientColors: [Colors.red, Colors.red],
// //                         onTap: () {
// //                           debugPrint("Only Visit tapped ✅");
// //
// //                           Get.snackbar(
// //                             "Success",
// //                             "Only Visit button clicked!",
// //                             snackPosition: SnackPosition.BOTTOM,
// //                             backgroundColor: Colors.green,
// //                             colorText: Colors.white,
// //                             duration: const Duration(seconds: 2),
// //                           );
// //
// //                           shopVisitViewModel.saveFormNoOrder();
// //                         },
// //                       ),
// //
// //                       // ===== Order Form Button =====
// //                       CustomButton(
// //                         textSize: fontSize,
// //                         iconSize: isTablet ? 22 : 18,
// //                         height: buttonHeight,
// //                         width: buttonWidth,
// //                         buttonText: "Order Form",
// //                         icon: Icons.arrow_forward_ios_outlined,
// //                         iconColor: Colors.white,
// //                         iconPosition: IconPosition.right,
// //                         gradientColors: [Colors.blue.shade900, Colors.blue],
// //                         onTap: () {
// //                           debugPrint("Order Form tapped ✅");
// //
// //                           Get.snackbar(
// //                             "",
// //                             "Order Form button clicked!",
// //                             snackPosition: SnackPosition.BOTTOM,
// //                             backgroundColor: Colors.orangeAccent,
// //                             colorText: Colors.black,
// //                             duration: const Duration(seconds: 2),
// //                           );
// //
// //                           shopVisitViewModel.saveForm();
// //                         },
// //                       ),
// //                     ],
// //                   )
// //
// //
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   AppBar _buildAppBar() {
// //     return AppBar(
// //       title: const Text(
// //         'Shop Visit',
// //         style: TextStyle(color: Colors.white, fontSize: 24),
// //       ),
// //       centerTitle: true,
// //       leading: IconButton(
// //         icon: const Icon(Icons.arrow_back, color: Colors.white),
// //         onPressed: () {
// //           Get.offAllNamed("/home");
// //         },
// //       ),
// //       actions: [
// //         IconButton(
// //           icon: const Icon(Icons.refresh, color: Colors.white),
// //           onPressed: () {
// //             shopVisitViewModel.fetchAllShopVisit();
// //             productsViewModel.fetchAllProductsModel();
// //           },
// //         ),
// //       ],
// //       backgroundColor: Colors.blue,
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required String label,
// //     required IconData icon,
// //     required String initialValue,
// //     required String? Function(String?) validator,
// //     required Function(String) onChanged,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool obscureText = false,
// //   }) {
// //     return CustomEditableMenuOption(
// //       readOnly: true,
// //       label: label,
// //       initialValue: initialValue,
// //       onChanged: onChanged,
// //       inputBorder: const UnderlineInputBorder(
// //         borderSide: BorderSide(color: Colors.blue, width: 1.0),
// //       ),
// //       iconColor: Colors.blue,
// //       useBoxShadow: false,
// //       icon: icon,
// //       validator: validator,
// //       keyboardType: keyboardType,
// //       obscureText: obscureText,
// //     );
// //   }
// // }
// //
// // class SectionHeader extends StatelessWidget {
// //   final String title;
// //
// //   const SectionHeader({required this.title, Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Align(
// //       alignment: Alignment.centerLeft,
// //       child: Text(
// //         title,
// //         style: Theme.of(context)
// //             .textTheme
// //             .titleLarge
// //             ?.copyWith(fontWeight: FontWeight.bold),
// //       ),
// //     );
// //   }
// // }
//
//
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// // // // import '../ViewModels/location_view_model.dart';
// // // // import '../ViewModels/shop_visit_details_view_model.dart';
// // // // import '../ViewModels/shop_visit_view_model.dart';
// // // // import 'Components/custom_button.dart';
// // // // import 'Components/custom_dropdown.dart';
// // // // import 'Components/custom_editable_menu_option.dart';
// // // // import 'Components/custom_switch.dart';
// // // // import 'ShopVisitScreenComponents/check_list_section.dart';
// // // // import 'ShopVisitScreenComponents/feedback_section.dart';
// // // // import 'ShopVisitScreenComponents/photo_picker.dart';
// // // // import 'ShopVisitScreenComponents/product_search_card.dart';
// // // //
// // // // class ShopVisitScreen extends StatefulWidget {
// // // //   const ShopVisitScreen({super.key});
// // // //
// // // //   @override
// // // //   _StateShopVisitScreen createState() => _StateShopVisitScreen();
// // // // }
// // // //
// // // // class _StateShopVisitScreen extends State<ShopVisitScreen> {
// // // //   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
// // // //   final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
// // // //   Get.put(ShopVisitDetailsViewModel());
// // // //   final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
// // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // //
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     shopVisitViewModel.selectedShop.value="";
// // // //     shopVisitViewModel.selectedBrand.value="";
// // // //     shopVisitViewModel.fetchBrands();
// // // //     shopVisitViewModel.fetchShops();
// // // //       // shopVisitDetailsViewModel.initializeProductData();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return SafeArea(
// // // //       child: Scaffold(
// // // //         backgroundColor: Colors.white,
// // // //         appBar: _buildAppBar(),
// // // //         body: SingleChildScrollView(
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
// // // //             child:  Form(
// // // //               key: shopVisitViewModel.formKey,  // Use the ViewModel's form key
// // // //               child:Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.center,
// // // //               children: [
// // // //                  // Obx(() {
// // // //                      Column(
// // // //                       children: [
// // // //                           Obx(() =>
// // // //                             CustomDropdown(
// // // //                               label: "Brand",
// // // //                               icon: Icons.branding_watermark,
// // // //                               items: shopVisitViewModel.brands
// // // //                                   .where((brand) => brand != null)
// // // //                                   .cast<String>()
// // // //                                   .toList(),
// // // //                               selectedValue: shopVisitViewModel.selectedBrand
// // // //                                   .value.isNotEmpty
// // // //                                   ? shopVisitViewModel.selectedBrand.value
// // // //                                   : " Select a Brand",
// // // //                               onChanged: (value) async {
// // // //                                 shopVisitDetailsViewModel.filteredRows
// // // //                                     .refresh();
// // // //                                 shopVisitViewModel.selectedBrand.value = value!;
// // // //                                 shopVisitDetailsViewModel.filterProductsByBrand(
// // // //                                     value);
// // // //                               },
// // // //                               useBoxShadow: false,
// // // //                               validator: (value) =>
// // // //                               value == null || value.isEmpty
// // // //                                   ? 'Please select a brand'
// // // //                                   : null,
// // // //                               inputBorder: const UnderlineInputBorder(
// // // //                                 borderSide: BorderSide(
// // // //                                     color: Colors.blue, width: 1.0),
// // // //                               ),
// // // //                               // maxWidth: fieldWidth,  // ✅ Same width as _buildTextField
// // // //                               // maxHeight: MediaQuery.of(context).size.height * 0.079,
// // // //                               iconSize: 22.0,
// // // //                               contentPadding: MediaQuery
// // // //                                   .of(context)
// // // //                                   .size
// // // //                                   .height * 0.005,
// // // //                               iconColor: Colors.blue,
// // // //                               textStyle: const TextStyle(fontSize: 13,
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Colors.black),
// // // //                             ),
// // // //                          ),
// // // //
// // // //                           Obx(() =>
// // // //                             CustomDropdown(
// // // //                               label: "Shop",
// // // //                               icon: Icons.store,
// // // //                               items: shopVisitViewModel.shops.value
// // // //                                   .where((
// // // //                                   shop) => shop != null)
// // // //                                   .cast<String>()
// // // //                                   .toList(),
// // // //                               selectedValue: shopVisitViewModel.selectedShop
// // // //                                   .value.isNotEmpty
// // // //                                   ?
// // // //                               shopVisitViewModel.selectedShop.value
// // // //                                   : " Select  a Shop",
// // // //                               onChanged: (value)  {
// // // //                                 shopVisitViewModel.selectedShop.value = value!;
// // // //                                  shopVisitViewModel.updateShopDetails(
// // // //                                     value);
// // // //                                 shopVisitViewModel.selectedShop.value =
// // // //                                     value;
// // // //                                 debugPrint(
// // // //                                     shopVisitViewModel.shop_address.value);
// // // //                                 debugPrint(
// // // //                                     shopVisitViewModel.city.value);
// // // //                               },
// // // //                               validator: (value) =>
// // // //                               value == null || value.isEmpty
// // // //                                   ? 'Please select a shop'
// // // //                                   : null,
// // // //                               useBoxShadow: false,
// // // //                               inputBorder: const UnderlineInputBorder(
// // // //                                 borderSide:
// // // //                                 BorderSide(color: Colors.blue, width: 1.0),
// // // //                               ),
// // // //                               maxHeight: 50.0,
// // // //                               maxWidth: 385.0,
// // // //                               // maxWidth: 355.0,
// // // //                               iconSize: 23.0,
// // // //                               // contentPadding: 6.0,
// // // //                               contentPadding: 0.0,
// // // //                               iconColor: Colors.blue,
// // // //                             ),
// // // //                           ),
// // // //                         Obx(() =>
// // // //                             _buildTextField(
// // // //                               initialValue: shopVisitViewModel.shop_address
// // // //                                   .value,
// // // //                               label: "Shop Address",
// // // //                               icon: Icons.location_on,
// // // //                               validator: (value) =>
// // // //                               value == null || value.isEmpty
// // // //                                   ? 'Please enter the shop address'
// // // //                                   : null,
// // // //                               onChanged: (value) =>
// // // //                               shopVisitViewModel.shop_address.value = value,
// // // //                             )
// // // //                         ),
// // // //                         Obx(() =>
// // // //                             _buildTextField(
// // // //                               initialValue: shopVisitViewModel.owner_name.value,
// // // //                               label: "Owner Name",
// // // //                               icon: Icons.location_on,
// // // //                               validator: (value) =>
// // // //                               value == null || value.isEmpty
// // // //                                   ? 'Please enter the shop address'
// // // //                                   : null,
// // // //                               onChanged: (value) =>
// // // //                               shopVisitViewModel.owner_name.value = value,
// // // //                             )),
// // // //                         _buildTextField(
// // // //                           label: "Booker Name",
// // // //
// // // //                           initialValue: shopVisitViewModel.booker_name.value,
// // // //                           icon: Icons.person,
// // // //                           validator: (value) =>
// // // //                           value == null || value.isEmpty
// // // //                               ? 'Please enter the booker name'
// // // //                               : null,
// // // //                           onChanged: (value) =>
// // // //                           shopVisitViewModel.booker_name.value = value,
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   // }),
// // // //
// // // //                 const SizedBox(height: 20),
// // // //                 const SectionHeader(title: "Stock Check"),
// // // //                 const SizedBox(height: 10),
// // // //                 ProductSearchCard(
// // // //                   filterData: shopVisitDetailsViewModel.filterData,
// // // //                   rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
// // // //                   filteredRows: shopVisitDetailsViewModel.filteredRows,
// // // //                   shopVisitDetailsViewModel: shopVisitDetailsViewModel,
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //                 ChecklistSection(
// // // //                   labels: shopVisitViewModel.checklistLabels,
// // // //                   checklistState: shopVisitViewModel.checklistState,
// // // //                   onStateChanged: (index, value) {
// // // //                     shopVisitViewModel.checklistState[index] = value;
// // // //                   },
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //                 PhotoPicker(
// // // //                   // onPickImage: shopVisitViewModel.pickImage,
// // // //                   selectedImage: shopVisitViewModel.selectedImage,
// // // //                   onTakePicture: shopVisitViewModel.takePicture,
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //                 Obx(() =>
// // // //                     FeedbackSection(
// // // //                       feedBackController: TextEditingController(
// // // //                           text: shopVisitViewModel.feedBack.value),
// // // //                       onChanged: (value) =>
// // // //                       shopVisitViewModel.feedBack.value = value,
// // // //                     )),
// // // //                 const SizedBox(height: 20),
// // // //                 // Use Obx to reactively update CustomSwitch
// // // //                 Obx(() => CustomSwitch(
// // // //                   label: "GPS Enabled",
// // // //                   value: locationViewModel.isGPSEnabled.value,
// // // //                   onChanged: (value) async {
// // // //                     locationViewModel.isGPSEnabled.value = value;
// // // //                     if (value) {
// // // //                       await locationViewModel
// // // //                           .saveCurrentLocation(); // Save location when switch is turned on
// // // //                     }
// // // //                   },
// // // //                 )),
// // // //                 const SizedBox(height: 20),
// // // //                 Row(children: [
// // // //                   CustomButton(
// // // //                     boxShadow: [
// // // //                       BoxShadow(
// // // //                         color: Colors.black.withOpacity(0.5),
// // // //                         offset: const Offset(0, 4),
// // // //                         blurRadius: 8,
// // // //                       ),
// // // //                     ],
// // // //                     textSize: 16,
// // // //                     iconSize: 18,
// // // //                     height: 45,
// // // //                     padding: const EdgeInsets.only(left: 3, right: 25),
// // // //                     icon: Icons.arrow_back_ios_new_rounded,
// // // //                     iconColor: Colors.white,
// // // //                     iconPosition: IconPosition.left,
// // // //                     spacing: 0,
// // // //                     //iconBackgroundColor: Colors.white,
// // // //                     width: 120,
// // // //                     buttonText: "Only Visit",
// // // //                     onTap: shopVisitViewModel.saveFormNoOrder,
// // // //                     gradientColors: [Colors.red, Colors.red],
// // // //                   ),
// // // //                   const SizedBox(width: 80),
// // // //                   CustomButton(
// // // //                     boxShadow: [
// // // //                       BoxShadow(
// // // //                         color: Colors.black.withOpacity(0.5),
// // // //                         offset: const Offset(0, 4),
// // // //                         blurRadius: 8,
// // // //                       ),
// // // //                     ],
// // // //                     textSize: 16,
// // // //                     iconSize: 18,
// // // //                     height: 45,
// // // //                     padding: EdgeInsets.only(left: 10, right: 5),
// // // //                     width: 120,
// // // //                     spacing: 0,
// // // //                     buttonText: "Order Form",
// // // //                     icon: Icons.arrow_forward_ios_outlined,
// // // //                     iconColor: Colors.white,
// // // //                     onTap: shopVisitViewModel.saveForm,
// // // //                     iconPosition: IconPosition.right,
// // // //                     gradientColors: [Colors.blue.shade900, Colors.blue],
// // // //                   ),
// // // //                 ]),
// // // //               ],
// // // //             ),
// // // //           )),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   AppBar _buildAppBar() {
// // // //     return AppBar(
// // // //       title: const Text(
// // // //         'Shop Visit',
// // // //         style: TextStyle(color: Colors.white, fontSize: 24),
// // // //       ),
// // // //       centerTitle: true,
// // // //       leading: IconButton(
// // // //         icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // //         onPressed: () {
// // // //           // Add your back navigation logic here
// // // //           // For example, you can pop the current screen
// // // //           Get.offAllNamed("/home");
// // // //           // Navigator.pop(context);
// // // //         },
// // // //       ),
// // // //       actions: [
// // // //         IconButton(
// // // //           icon: const Icon(Icons.refresh, color: Colors.white),
// // // //           onPressed: () {
// // // //             shopVisitViewModel.fetchAllShopVisit();
// // // //             //productsViewModel.fetchAndSaveProducts();
// // // //             productsViewModel.fetchAllProductsModel();
// // // //           },
// // // //         ),
// // // //       ],
// // // //       backgroundColor: Colors.blue,
// // // //     );
// // // //   }
// // // //
// // // //
// // // //   Widget _buildTextField({
// // // //     required String label,
// // // //     required IconData icon,
// // // //     required String initialValue,
// // // //     required String? Function(String?) validator,
// // // //     required Function(String) onChanged,
// // // //     TextInputType keyboardType = TextInputType.text,
// // // //     bool obscureText = false,
// // // //   }) {
// // // //     return CustomEditableMenuOption(
// // // //       readOnly: true,
// // // //       label: label,
// // // //       initialValue: initialValue,
// // // //       onChanged: onChanged,
// // // //       inputBorder: const UnderlineInputBorder(
// // // //         borderSide: BorderSide(color: Colors.blue, width: 1.0),
// // // //       ),
// // // //       iconColor: Colors.blue,
// // // //       useBoxShadow: false,
// // // //       icon: icon,
// // // //       validator: validator,
// // // //       keyboardType: keyboardType,
// // // //       obscureText: obscureText,
// // // //       //enableListener: true,
// // // //       //useTextField: true, // Ensure this is true to use TextField
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // class SectionHeader extends StatelessWidget {
// // // //   final String title;
// // // //
// // // //   const SectionHeader({required this.title, Key? key}) : super(key: key);
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Align(
// // // //       alignment: Alignment.centerLeft,
// // // //       child: Text(
// // // //         title,
// // // //         style: Theme
// // // //             .of(context)
// // // //             .textTheme
// // // //             .titleLarge
// // // //             ?.copyWith(fontWeight: FontWeight.bold),
// // // //       ),
// // // //     );
// // // //   }
// // // // }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
import '../LocatioPoints/ravelTimeViewModel.dart';
import '../ViewModels/location_view_model.dart';
import '../ViewModels/shop_visit_details_view_model.dart';
import '../ViewModels/shop_visit_view_model.dart';
// ✅✅ ABDULLAH: Added import for TravelTimeViewModel

import 'Components/custom_button.dart';
import 'Components/custom_dropdown.dart';
import 'Components/custom_editable_menu_option.dart' hide IconPosition;
import 'Components/custom_switch.dart';
import 'ShopVisitScreenComponents/check_list_section.dart';
import 'ShopVisitScreenComponents/feedback_section.dart';
import 'ShopVisitScreenComponents/photo_picker.dart';
import 'ShopVisitScreenComponents/product_search_card.dart';

class ShopVisitScreen extends StatefulWidget {
  const ShopVisitScreen({super.key});

  @override
  _StateShopVisitScreen createState() => _StateShopVisitScreen();
}

class _StateShopVisitScreen extends State<ShopVisitScreen> {
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  final ShopVisitDetailsViewModel shopVisitDetailsViewModel =
  Get.put(ShopVisitDetailsViewModel());
  final ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  final LocationViewModel locationViewModel = Get.find<LocationViewModel>(); // ✅ Use Find instead of Put
  final feedBackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅✅ ABDULLAH: Set working status when entering Shop Visit screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final travelTimeViewModel = Get.find<TravelTimeViewModel>();
      travelTimeViewModel.setWorkingScreenStatus(true);
      debugPrint("📍 [WORKING STATUS] Shop Visit Screen - Working time ACTIVE");
    });

    feedBackController.text = shopVisitViewModel.feedBack.value;
    shopVisitViewModel.selectedShop.value = "";
    shopVisitViewModel.selectedBrand.value = "";
    shopVisitViewModel.fetchBrands();
    shopVisitViewModel.fetchShops();
    shopVisitViewModel.updateButtonReadiness();

    ever(shopVisitViewModel.feedBack, (value) {
      feedBackController.text = value;
      feedBackController.selection = TextSelection.fromPosition(
        TextPosition(offset: feedBackController.text.length),
      );
    });
  }
  @override
  void dispose() {
    // ✅✅ ABDULLAH: Reset working status when leaving Shop Visit screen
    final travelTimeViewModel = Get.find<TravelTimeViewModel>();
    travelTimeViewModel.setWorkingScreenStatus(false);
    debugPrint("📍 [WORKING STATUS] Shop Visit Screen - Working time INACTIVE");

    super.dispose();
  }

  String? requiredDropdownValidator(String? value, String placeholder) {
    if (value == null || value.isEmpty || value == placeholder) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width > 600;

    final double fontSize = isTablet ? 18 : 14;
    final double buttonWidth = isTablet ? width * 0.3 : width * 0.4;
    final double buttonHeight = isTablet ? 55 : 45;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: MediaQuery.of(context).padding.bottom + 40,
            ),
            child: Form(
              key: shopVisitViewModel.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Obx(
                            () => CustomDropdown(
                          label: "Brand",
                          icon: Icons.branding_watermark,
                          items: shopVisitViewModel.brands
                              .where((brand) => brand != null)
                              .cast<String>()
                              .toList(),
                          selectedValue: shopVisitViewModel
                              .selectedBrand.value.isNotEmpty
                              ? shopVisitViewModel.selectedBrand.value
                              : " Select a Brand",
                          onChanged: (value) async {
                            shopVisitDetailsViewModel.filteredRows.refresh();
                            shopVisitViewModel.setBrand(value!);
                            shopVisitDetailsViewModel
                                .filterProductsByBrand(value);
                          },
                          useBoxShadow: false,
                          validator: (value) => requiredDropdownValidator(value, " Select a Brand"),
                          inputBorder: const UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.blue, width: 1.0),
                          ),
                          iconSize: 22.0,
                          contentPadding:
                          MediaQuery.of(context).size.height * 0.005,
                          iconColor: Colors.blue,
                          textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Obx(
                            () => CustomDropdown(
                          label: "Shop",
                          icon: Icons.store,
                          items: shopVisitViewModel.shops.value
                              .where((shop) => shop != null)
                              .cast<String>()
                              .toList(),
                          selectedValue: shopVisitViewModel
                              .selectedShop.value.isNotEmpty
                              ? shopVisitViewModel.selectedShop.value
                              : " Select a Shop",
                          onChanged: (value) {
                            shopVisitViewModel.setSelectedShop(value!);
                            debugPrint(shopVisitViewModel.shop_address.value);
                            debugPrint(shopVisitViewModel.city.value);
                          },
                          validator: (value) => requiredDropdownValidator(value, " Select a Shop"),
                          useBoxShadow: false,
                          inputBorder: const UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.blue, width: 1.0),
                          ),
                          maxHeight: 50.0,
                          maxWidth: 385.0,
                          iconSize: 23.0,
                          contentPadding: 0.0,
                          iconColor: Colors.blue,
                        ),
                      ),
                      Obx(() => _buildTextField(
                        initialValue:
                        shopVisitViewModel.shop_address.value,
                        label: "Shop Address",
                        icon: Icons.location_on,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter the shop address'
                            : null,
                        onChanged: (value) =>
                            shopVisitViewModel.setShopAddress(value),
                      )),
                      Obx(() => _buildTextField(
                        initialValue: shopVisitViewModel.owner_name.value,
                        label: "Owner Name",
                        icon: Icons.person,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter owner name'
                            : null,
                        onChanged: (value) =>
                            shopVisitViewModel.setOwnerName(value),
                      )),
                      _buildTextField(
                        label: "Booker Name",
                        initialValue: shopVisitViewModel.booker_name.value,
                        icon: Icons.person,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter the booker name'
                            : null,
                        onChanged: (value) =>
                        shopVisitViewModel.booker_name.value = value,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: "Stock Check"),
                  const SizedBox(height: 10),
                  ProductSearchCard(
                    filterData: shopVisitDetailsViewModel.filterData,
                    rowsNotifier: shopVisitDetailsViewModel.rowsNotifier,
                    filteredRows: shopVisitDetailsViewModel.filteredRows,
                    shopVisitDetailsViewModel: shopVisitDetailsViewModel,
                  ),
                  const SizedBox(height: 20),
                  ChecklistSection(
                    labels: shopVisitViewModel.checklistLabels,
                    checklistState: shopVisitViewModel.checklistState,
                    onStateChanged: (index, value) {
                      shopVisitViewModel.updateChecklistState(index, value);
                    },
                  ),
                  const SizedBox(height: 20),
                  PhotoPicker(
                    selectedImage: shopVisitViewModel.selectedImage,
                    onTakePicture: shopVisitViewModel.takePicture,
                  ),
                  const SizedBox(height: 20),
                  // FeedbackSection(
                  //   feedBackController: feedBackController,
                  //   onChanged: (value) =>
                  //       shopVisitViewModel.setFeedBack(value),
                  // ),
                  Obx(() => CustomSwitch(
                    label: "GPS Enabled",
                    value: locationViewModel.isGPSEnabled.value,
                    onChanged: (value) async {
                      locationViewModel.isGPSEnabled.value = value;
                      if (value) {
                        await locationViewModel.saveCurrentLocation();
                      }
                      shopVisitViewModel.updateButtonReadiness();
                    },
                  )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() {
                        bool isButtonDisabled = !shopVisitViewModel.isOnlyVisitButtonEnabled.value;
                        bool isLoading = shopVisitViewModel.isOnlyVisitLoading.value;

                        return CustomButton(
                          textSize: fontSize,
                          iconSize: isTablet ? 22 : 18,
                          height: buttonHeight,
                          width: buttonWidth,
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconColor: Colors.white,
                          iconPosition: IconPosition.left,
                          spacing: 4,
                          buttonText: isLoading
                              ? "Processing..."
                              : "Only Visit",
                          gradientColors: isButtonDisabled || isLoading
                              ? [Colors.grey, Colors.grey]
                              : [Colors.red, Colors.red],
                          onTap: isButtonDisabled
                              ? () {
                            String? errorMessage = shopVisitViewModel.getOnlyVisitErrorMessage();
                            if (errorMessage != null) {
                              Get.snackbar("Action Required", errorMessage,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade700,
                                  colorText: Colors.white);
                            }
                          }
                              : () {
                            if (!isLoading) {
                              debugPrint("Only Visit tapped ✅ (Proceeding)");
                              shopVisitViewModel.saveFormNoOrder();
                            }
                          },
                        );
                      }),

                      Obx(() {
                        bool isButtonDisabled = !shopVisitViewModel.isOrderButtonEnabled.value;
                        bool isLoading = shopVisitViewModel.isOrderFormLoading.value;

                        return CustomButton(
                          textSize: fontSize,
                          iconSize: isTablet ? 22 : 18,
                          height: buttonHeight,
                          width: buttonWidth,
                          buttonText: isLoading
                              ? "Processing..."
                              : "Order Form",
                          icon: Icons.arrow_forward_ios_outlined,
                          iconColor: Colors.white,
                          iconPosition: IconPosition.right,
                          gradientColors: isButtonDisabled || isLoading
                              ? [Colors.grey, Colors.grey]
                              : [Colors.blue.shade900, Colors.blue],
                          onTap: isButtonDisabled
                              ? () {
                            String? errorMessage = shopVisitViewModel.getOrderFormErrorMessage();
                            if (errorMessage != null) {
                              Get.snackbar("Action Required", errorMessage,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade400,
                                  colorText: Colors.white);
                            }
                          }
                              : () {
                            if (!isLoading) {
                              debugPrint("Order Form tapped ✅ (Proceeding)");
                              shopVisitViewModel.saveForm();
                            }
                          },
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Shop Visit',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Get.back(); // ✅ FIXED: Use Get.back() instead of Get.offAllNamed
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            shopVisitViewModel.fetchAllShopVisit();
            productsViewModel.fetchAllProductsModel();
          },
        ),
      ],
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomEditableMenuOption(
      readOnly: true,
      label: label,
      initialValue: initialValue,
      onChanged: onChanged,
      inputBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.0),
      ),
      iconColor: Colors.blue,
      useBoxShadow: false,
      icon: icon,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}