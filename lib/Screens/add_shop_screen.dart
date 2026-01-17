// // //
// // // //
// // // // // lib/screens/add_shop_screen.dart
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/Screens/Components/custom_switch.dart';
// // // // // import 'package:order_booking_app/Screens/code_screen.dart';
// // // // // import 'package:order_booking_app/Screens/signup_screen.dart';
// // // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // // import '../LocatioPoints/ravelTimeViewModel.dart';
// // // // import '../ViewModels/add_shop_view_model.dart';
// // // // import 'Components/custom_button.dart';
// // // // import 'Components/custom_dropdown_second.dart';
// // // // import 'Components/validators.dart';
// // // //
// // // //
// // // // // class AddShopScreen extends StatelessWidget {
// // // // //   final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
// // // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // // //   AddShopScreen({super.key});
// // // // class AddShopScreen extends StatefulWidget { // ✅ ABDULLAH: Changed to StatefulWidget
// // // //   const AddShopScreen({super.key});
// // // //
// // // //   @override
// // // //   State<AddShopScreen> createState() => _AddShopScreenState();
// // // // }
// // // //
// // // // class _AddShopScreenState extends State<AddShopScreen> {
// // // //   final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
// // // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //
// // // //     // ✅ ABDULLAH: Set working status when entering Add Shop screen
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // // //       travelTimeViewModel.setWorkingScreenStatus(true);
// // // //       debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time ACTIVE");
// // // //     });
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     // ✅ ABDULLAH: Reset working status when leaving Add Shop screen
// // // //     final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // // //     travelTimeViewModel.setWorkingScreenStatus(false);
// // // //     debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time INACTIVE");
// // // //
// // // //     super.dispose();
// // // //   }
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final size = MediaQuery.of(context).size;
// // // //
// // // //     return SafeArea(
// // // //       child: Scaffold(
// // // //         backgroundColor: Colors.white,
// // // //         appBar: AppBar(
// // // //           title: const Text(
// // // //             'Add Shop',
// // // //             style: TextStyle(
// // // //                 fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
// // // //           ),
// // // //           centerTitle: true,
// // // //           backgroundColor: Colors.blue,
// // // //         ),
// // // //         body: SingleChildScrollView(
// // // //           child: Container(
// // // //             width: size.width,
// // // //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
// // // //             child: Form(
// // // //               key: _viewModel.formKey,
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   _buildTextField(
// // // //                     label: "Shop Name",
// // // //                     icon: Icons.store,
// // // //                     onChanged: (value) =>
// // // //                         _viewModel.setShopField('shop_name', value),
// // // //                     validator: (value) => value == null || value.isEmpty
// // // //                         ? "Please enter shop name"
// // // //                         : null,
// // // //                   ),
// // // //                   Obx(() => CustomDropdownSecond(
// // // //                     borderColor: Colors.black,
// // // //                     iconColor: Colors.blue,
// // // //                     label: "City",
// // // //                     useBoxShadow: false,
// // // //                     icon: Icons.location_city,
// // // //                     items: _viewModel.cities.value,
// // // //                     selectedValue: _viewModel.selectedCity.value.isNotEmpty
// // // //                         ? _viewModel.selectedCity.value
// // // //                         : 'Select a City',
// // // //                     onChanged: (value) {
// // // //                       if (value != null && value != 'Select a City') {
// // // //                         String selectedCity = value.toString();
// // // //                         _viewModel.setShopField('city', selectedCity);
// // // //                       }
// // // //                     },
// // // //
// // // //                     validator: (value) =>
// // // //                     value == null || value.isEmpty ? "Please select a City" : null,
// // // //                     textStyle: const TextStyle(
// // // //                         fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
// // // //                     showSerialNumbers: true, // یہاں serial numbers آن کریں
// // // //                   )),
// // // //
// // // //                   // Obx(() => CustomDropdownSecond(
// // // //                   //   borderColor: Colors.black,
// // // //                   //   iconColor: Colors.blue,
// // // //                   //   label: "City",
// // // //                   //   useBoxShadow: false,
// // // //                   //   icon: Icons.location_city,
// // // //                   //   items: _viewModel.cities.value,
// // // //                   //   selectedValue: _viewModel.selectedCity.value.isNotEmpty
// // // //                   //       ? _viewModel.selectedCity.value
// // // //                   //       : 'Select a City',
// // // //                   //   onChanged: (value) {
// // // //                   //     String selectedCity = value?.toString() ?? '';
// // // //                   //     _viewModel.setShopField('city', selectedCity);
// // // //                   //   },
// // // //                   //   validator: (value) =>
// // // //                   //   value == null || value.isEmpty ? "Please select a City" : null,
// // // //                   //   textStyle: const TextStyle(
// // // //                   //       fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
// // // //                   // )),
// // // //
// // // //                   _buildTextField(
// // // //                     label: "Shop Address",
// // // //                     icon: Icons.place,
// // // //                     onChanged: (value) =>
// // // //                         _viewModel.setShopField('shop_address', value),
// // // //                     validator: (value) => value == null || value.isEmpty
// // // //                         ? "Please enter shop address"
// // // //                         : null,
// // // //                   ),
// // // //                   _buildTextField(
// // // //                     label: "Owner Name",
// // // //                     icon: Icons.person,
// // // //                     onChanged: (value) =>
// // // //                         _viewModel.setShopField('owner_name', value),
// // // //                     validator: (value) => value == null || value.isEmpty
// // // //                         ? "Please enter owner name"
// // // //                         : null,
// // // //                   ),
// // // //
// // // //                   _buildTextField(
// // // //                     label: "CNIC",
// // // //                     icon: Icons.badge,
// // // //                     keyboardType: TextInputType.number,
// // // //                     inputFormatters: [CNICInputFormatter()],
// // // //                     validator: Validators.validateCNIC,
// // // //                     onChanged: (value) {
// // // //                       _viewModel.setShopField('owner_cnic', value);
// // // //                     },
// // // //                   ),
// // // //
// // // //                   _buildTextField(
// // // //                     label: "Phone Number",
// // // //                     icon: Icons.phone,
// // // //                     onChanged: (value) => _viewModel.setShopField('phone_no', value),
// // // //                     validator: Validators.validatePhoneNumber,
// // // //                     keyboardType: TextInputType.phone,
// // // //                     inputFormatters: [PhoneNumberFormatter()],
// // // //                   ),
// // // //
// // // //
// // // //                   _buildTextField(
// // // //                     label: "Alternative Phone Number",
// // // //                     icon: Icons.phone_android,
// // // //                     onChanged: (value) =>
// // // //                         _viewModel.setShopField('alternative_phone_no', value),
// // // //                     validator: Validators.validatePhoneNumber,
// // // //                     keyboardType: TextInputType.phone,
// // // //                     inputFormatters: [PhoneNumberFormatter()],
// // // //                   ),
// // // //                   const SizedBox(height: 10),
// // // //                   // Use Obx to reactively update CustomSwitch
// // // //                   Obx(() => CustomSwitch(
// // // //                     label: "GPS Enabled",
// // // //                     value: locationViewModel.isGPSEnabled.value,
// // // //                     onChanged: (value) async {
// // // //                       locationViewModel.isGPSEnabled.value = value;
// // // //                       if (value) {
// // // //                         await locationViewModel
// // // //                             .saveCurrentLocation(); // Save location when switch is turned on
// // // //                       }
// // // //                       // Update the save button state when GPS is toggled
// // // //                       _viewModel.updateSaveButtonState();
// // // //                     },
// // // //                   )),
// // // //                   const SizedBox(height: 10),
// // // //                   // Use Obx to control the button's enabled state
// // // //                   Obx(
// // // //                         () => CustomButton(
// // // //                       buttonText: "Save",
// // // //                       onTap: _viewModel.isFormReadyToSave.value
// // // //                           ? _viewModel.saveForm // Enabled: Call saveForm
// // // //                           : null, // Disabled: onTap is null
// // // //                       gradientColors: _viewModel.isFormReadyToSave.value
// // // //                           ? const [Colors.blue, Colors.blue] // Enabled color
// // // //                           : const [
// // // //                         Colors.grey,
// // // //                         Colors.grey
// // // //                       ], // Disabled color
// // // //                     ),
// // // //                   ),
// // // //                   // TextButton(
// // // //                   //   onPressed: () {
// // // //                   //     Get.to(() => CodeScreen()); // Replace with your destination screen
// // // //                   //   },
// // // //                   //   child: const Text("Go to Next Page", style: TextStyle(color: Colors.blue)),
// // // //                   // ),TextButton(
// // // //                   //   onPressed: () {
// // // //                   //     Get.to(() => SignUpScreen()); // Replace with your destination screen
// // // //                   //   },
// // // //                   //   child: const Text("Go to Next Page", style: TextStyle(color: Colors.blue)),
// // // //                   // ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   /// Builds a custom text field with validation.
// // // //   Widget _buildTextField({
// // // //     required String label,
// // // //     required IconData icon,
// // // //     required ValueChanged<String> onChanged,
// // // //     required String? Function(String?) validator,
// // // //     TextInputType keyboardType = TextInputType.text,
// // // //     List<TextInputFormatter>? inputFormatters,
// // // //   }) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.only(bottom: 15),
// // // //       child: TextFormField(
// // // //         decoration: InputDecoration(
// // // //           labelText: label,
// // // //           prefixIcon: Icon(icon, color: Colors.blue),
// // // //           border: const OutlineInputBorder(),
// // // //         ),
// // // //         onChanged: onChanged,
// // // //         keyboardType: keyboardType,
// // // //         inputFormatters: inputFormatters,
// // // //         validator: validator,
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // // // lib/screens/add_shop_screen.dart
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/Screens/Components/custom_switch.dart';
// // // import 'package:order_booking_app/ViewModels/location_view_model.dart';
// // // import '../LocatioPoints/ravelTimeViewModel.dart';
// // // import '../ViewModels/add_shop_view_model.dart';
// // // import 'Components/custom_button.dart';
// // // import 'Components/custom_dropdown_second.dart';
// // // import 'Components/validators.dart';
// // //
// // // class AddShopScreen extends StatefulWidget {
// // //   const AddShopScreen({super.key});
// // //
// // //   @override
// // //   State<AddShopScreen> createState() => _AddShopScreenState();
// // // }
// // //
// // // class _AddShopScreenState extends State<AddShopScreen> {
// // //   final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
// // //   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // //       travelTimeViewModel.setWorkingScreenStatus(true);
// // //       debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time ACTIVE");
// // //     });
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // //     travelTimeViewModel.setWorkingScreenStatus(false);
// // //     debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time INACTIVE");
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[50],
// // //       appBar: _buildAppBar(),
// // //       body: _buildBody(),
// // //     );
// // //   }
// // //
// // //   AppBar _buildAppBar() {
// // //     return AppBar(
// // //       title: const Text(
// // //         'Add New Shop',
// // //         style: TextStyle(
// // //           fontSize: 20,
// // //           fontWeight: FontWeight.w600,
// // //           color: Colors.white,
// // //         ),
// // //       ),
// // //       centerTitle: true,
// // //       backgroundColor: const Color(0xFF2563EB),
// // //       elevation: 4,
// // //       shadowColor: Colors.black.withOpacity(0.1),
// // //       iconTheme: const IconThemeData(color: Colors.white),
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(
// // //           bottom: Radius.circular(16),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildBody() {
// // //     return SingleChildScrollView(
// // //       physics: const BouncingScrollPhysics(),
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
// // //         child: Form(
// // //           key: _viewModel.formKey,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _buildSectionTitle('Shop Information'),
// // //               const SizedBox(height: 8),
// // //               _buildShopInfoSection(),
// // //
// // //               const SizedBox(height: 24),
// // //               _buildSectionTitle('Owner Information'),
// // //               const SizedBox(height: 8),
// // //               _buildOwnerInfoSection(),
// // //
// // //               const SizedBox(height: 24),
// // //               _buildSectionTitle('Location Settings'),
// // //               const SizedBox(height: 8),
// // //               _buildLocationSection(),
// // //
// // //               const SizedBox(height: 32),
// // //               _buildSaveButton(),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSectionTitle(String title) {
// // //     return Text(
// // //       title,
// // //       style: const TextStyle(
// // //         fontSize: 18,
// // //         fontWeight: FontWeight.w600,
// // //         color: Color(0xFF1F2937),
// // //         letterSpacing: -0.3,
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildShopInfoSection() {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(12),
// // //       ),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           children: [
// // //             _buildTextFieldCard(
// // //               label: "Shop Name",
// // //               icon: Icons.store_mall_directory_outlined,
// // //               onChanged: (value) => _viewModel.setShopField('shop_name', value),
// // //               validator: (value) => value == null || value.isEmpty
// // //                   ? "Please enter shop name"
// // //                   : null,
// // //             ),
// // //             const SizedBox(height: 16),
// // //             _buildCityDropdown(),
// // //             const SizedBox(height: 16),
// // //             _buildTextFieldCard(
// // //               label: "Shop Address",
// // //               icon: Icons.place_outlined,
// // //               onChanged: (value) => _viewModel.setShopField('shop_address', value),
// // //               validator: (value) => value == null || value.isEmpty
// // //                   ? "Please enter shop address"
// // //                   : null,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildOwnerInfoSection() {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(12),
// // //       ),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           children: [
// // //             _buildTextFieldCard(
// // //               label: "Owner Name",
// // //               icon: Icons.person_outline,
// // //               onChanged: (value) => _viewModel.setShopField('owner_name', value),
// // //               validator: (value) => value == null || value.isEmpty
// // //                   ? "Please enter owner name"
// // //                   : null,
// // //             ),
// // //             const SizedBox(height: 16),
// // //             _buildTextFieldCard(
// // //               label: "CNIC",
// // //               icon: Icons.badge_outlined,
// // //               keyboardType: TextInputType.number,
// // //               inputFormatters: [CNICInputFormatter()],
// // //               validator: Validators.validateCNIC,
// // //               onChanged: (value) => _viewModel.setShopField('owner_cnic', value),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             _buildTextFieldCard(
// // //               label: "Phone Number",
// // //               icon: Icons.phone_outlined,
// // //               onChanged: (value) => _viewModel.setShopField('phone_no', value),
// // //               validator: Validators.validatePhoneNumber,
// // //               keyboardType: TextInputType.phone,
// // //               inputFormatters: [PhoneNumberFormatter()],
// // //             ),
// // //             const SizedBox(height: 16),
// // //             _buildTextFieldCard(
// // //               label: "Alternative Phone Number",
// // //               icon: Icons.phone_android_outlined,
// // //               onChanged: (value) => _viewModel.setShopField('alternative_phone_no', value),
// // //               validator: Validators.validatePhoneNumber,
// // //               keyboardType: TextInputType.phone,
// // //               inputFormatters: [PhoneNumberFormatter()],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildLocationSection() {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.circular(12),
// // //       ),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 Container(
// // //                   padding: const EdgeInsets.all(8),
// // //                   decoration: BoxDecoration(
// // //                     color: const Color(0xFFEFF6FF),
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                   child: const Icon(
// // //                     Icons.location_on_outlined,
// // //                     color: Color(0xFF2563EB),
// // //                     size: 24,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text(
// // //                         "GPS Location",
// // //                         style: TextStyle(
// // //                           fontSize: 16,
// // //                           fontWeight: FontWeight.w600,
// // //                           color: Colors.grey[800],
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 2),
// // //                       Text(
// // //                         "Enable to save current location",
// // //                         style: TextStyle(
// // //                           fontSize: 14,
// // //                           color: Colors.grey[600],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 Obx(() => Switch.adaptive(
// // //                   value: locationViewModel.isGPSEnabled.value,
// // //                   onChanged: (value) async {
// // //                     locationViewModel.isGPSEnabled.value = value;
// // //                     if (value) {
// // //                       await locationViewModel.saveCurrentLocation();
// // //                     }
// // //                     _viewModel.updateSaveButtonState();
// // //                   },
// // //                   activeColor: const Color(0xFF2563EB),
// // //                   activeTrackColor: const Color(0xFF93C5FD),
// // //                 )),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 12),
// // //             Obx(() => AnimatedContainer(
// // //               duration: const Duration(milliseconds: 300),
// // //               padding: const EdgeInsets.all(12),
// // //               decoration: BoxDecoration(
// // //                 color: locationViewModel.isGPSEnabled.value
// // //                     ? const Color(0xFFF0F9FF)
// // //                     : Colors.grey[50],
// // //                 borderRadius: BorderRadius.circular(8),
// // //                 border: Border.all(
// // //                   color: locationViewModel.isGPSEnabled.value
// // //                       ? const Color(0xFFBAE6FD)
// // //                       : Colors.grey[200]!,
// // //                   width: 1,
// // //                 ),
// // //               ),
// // //               child: Row(
// // //                 children: [
// // //                   Icon(
// // //                     locationViewModel.isGPSEnabled.value
// // //                         ? Icons.check_circle
// // //                         : Icons.info_outline,
// // //                     color: locationViewModel.isGPSEnabled.value
// // //                         ? const Color(0xFF059669)
// // //                         : Colors.grey[500],
// // //                     size: 18,
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   Expanded(
// // //                     child: Text(
// // //                       locationViewModel.isGPSEnabled.value
// // //                           ? "GPS is enabled. Current location will be saved."
// // //                           : "GPS is disabled. Enable to capture location.",
// // //                       style: TextStyle(
// // //                         fontSize: 13,
// // //                         color: locationViewModel.isGPSEnabled.value
// // //                             ? const Color(0xFF065F46)
// // //                             : Colors.grey[600],
// // //                         fontWeight: FontWeight.w500,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             )),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildTextFieldCard({
// // //     required String label,
// // //     required IconData icon,
// // //     required ValueChanged<String> onChanged,
// // //     required String? Function(String?) validator,
// // //     TextInputType keyboardType = TextInputType.text,
// // //     List<TextInputFormatter>? inputFormatters,
// // //   }) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           label,
// // //           style: TextStyle(
// // //             fontSize: 14,
// // //             fontWeight: FontWeight.w500,
// // //             color: Colors.grey[700],
// // //             letterSpacing: -0.2,
// // //           ),
// // //         ),
// // //         const SizedBox(height: 6),
// // //         Container(
// // //           decoration: BoxDecoration(
// // //             borderRadius: BorderRadius.circular(10),
// // //             border: Border.all(color: Colors.grey[300]!, width: 1.5),
// // //             color: Colors.white,
// // //           ),
// // //           child: TextFormField(
// // //             decoration: InputDecoration(
// // //               contentPadding: const EdgeInsets.symmetric(
// // //                 horizontal: 16,
// // //                 vertical: 16,
// // //               ),
// // //               prefixIcon: Icon(
// // //                 icon,
// // //                 color: const Color(0xFF6B7280),
// // //                 size: 20,
// // //               ),
// // //               border: InputBorder.none,
// // //               focusedBorder: InputBorder.none,
// // //               enabledBorder: InputBorder.none,
// // //               errorBorder: InputBorder.none,
// // //               disabledBorder: InputBorder.none,
// // //               filled: false,
// // //             ),
// // //             style: const TextStyle(
// // //               fontSize: 16,
// // //               fontWeight: FontWeight.w500,
// // //               color: Color(0xFF1F2937),
// // //             ),
// // //             onChanged: onChanged,
// // //             keyboardType: keyboardType,
// // //             inputFormatters: inputFormatters,
// // //             validator: validator,
// // //             cursorColor: const Color(0xFF2563EB),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildCityDropdown() {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           "City",
// // //           style: TextStyle(
// // //             fontSize: 14,
// // //             fontWeight: FontWeight.w500,
// // //             color: Colors.grey[700],
// // //             letterSpacing: -0.2,
// // //           ),
// // //         ),
// // //         const SizedBox(height: 6),
// // //         Obx(() => Container(
// // //           decoration: BoxDecoration(
// // //             borderRadius: BorderRadius.circular(10),
// // //             border: Border.all(color: Colors.grey[300]!, width: 1.5),
// // //             color: Colors.white,
// // //           ),
// // //           child: CustomDropdownSecond(
// // //             borderColor: Colors.transparent,
// // //             iconColor: const Color(0xFF6B7280),
// // //             label: "Select City",
// // //             useBoxShadow: false,
// // //             icon: Icons.location_city_outlined,
// // //             items: _viewModel.cities.value,
// // //             selectedValue: _viewModel.selectedCity.value.isNotEmpty
// // //                 ? _viewModel.selectedCity.value
// // //                 : 'Select a City',
// // //             onChanged: (value) {
// // //               if (value != null && value != 'Select a City') {
// // //                 String selectedCity = value.toString();
// // //                 _viewModel.setShopField('city', selectedCity);
// // //               }
// // //             },
// // //             validator: (value) =>
// // //             value == null || value.isEmpty ? "Please select a City" : null,
// // //             textStyle: const TextStyle(
// // //               fontSize: 16,
// // //               fontWeight: FontWeight.w500,
// // //               color: Color(0xFF1F2937),
// // //             ),
// // //             showSerialNumbers: true,
// // //           ),
// // //         )),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildSaveButton() {
// // //     return Obx(() => AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       decoration: BoxDecoration(
// // //         borderRadius: BorderRadius.circular(12),
// // //         boxShadow: _viewModel.isFormReadyToSave.value
// // //             ? [
// // //           BoxShadow(
// // //             color: const Color(0xFF2563EB).withOpacity(0.3),
// // //             blurRadius: 8,
// // //             offset: const Offset(0, 4),
// // //           ),
// // //         ]
// // //             : [],
// // //       ),
// // //       child: CustomButton(
// // //         buttonText: "Save Shop Details",
// // //         onTap: _viewModel.isFormReadyToSave.value
// // //             ? _viewModel.saveForm
// // //             : null,
// // //         gradientColors: _viewModel.isFormReadyToSave.value
// // //             ? const [Color(0xFF2563EB), Color(0xFF1D4ED8)]
// // //             : [Colors.grey[400]!, Colors.grey[400]!],
// // //         borderRadius: 12,
// // //         padding: const EdgeInsets.symmetric(vertical: 18),
// // //         textStyle: const TextStyle(
// // //           fontSize: 17,
// // //           fontWeight: FontWeight.w600,
// // //           letterSpacing: -0.2,
// // //         ),
// // //         // CORRECTED: Passing IconData instead of Icon widget
// // //         icon: _viewModel.isFormReadyToSave.value
// // //             ? Icons.save_alt  // IconData, not Icon widget
// // //             : Icons.lock,     // IconData, not Icon widget
// // //       ),
// // //     ));
// // //   }
// // // }
//
//
// // lib/screens/add_shop_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/Screens/Components/custom_switch.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import '../LocatioPoints/ravelTimeViewModel.dart';
// import '../ViewModels/add_shop_view_model.dart';
// import 'Components/custom_button.dart';
// import 'Components/custom_dropdown_second.dart';
// import 'Components/validators.dart';
//
// class AddShopScreen extends StatefulWidget {
//   const AddShopScreen({super.key});
//
//   @override
//   State<AddShopScreen> createState() => _AddShopScreenState();
// }
//
// class _AddShopScreenState extends State<AddShopScreen> {
//   final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
//       travelTimeViewModel.setWorkingScreenStatus(true);
//       debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time ACTIVE");
//     });
//   }
//
//   @override
//   void dispose() {
//     final travelTimeViewModel = Get.find<TravelTimeViewModel>();
//     travelTimeViewModel.setWorkingScreenStatus(false);
//     debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time INACTIVE");
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           'Add New Shop',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//             letterSpacing: 0.5,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF2196F3),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             // Header Card with Icon
//             Container(
//               width: size.width,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.store_mall_directory_rounded,
//                       size: 48,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Shop Information',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Form Card
//             Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 20,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Form(
//                 key: _viewModel.formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSectionHeader('Basic Details', Icons.info_outline),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         label: "Shop Name",
//                         icon: Icons.storefront_rounded,
//                         onChanged: (value) =>
//                             _viewModel.setShopField('shop_name', value),
//                         validator: (value) => value == null || value.isEmpty
//                             ? "Please enter shop name"
//                             : null,
//                       ),
//
//                       Obx(() => CustomDropdownSecond(
//                         borderColor: const Color(0xFFE0E0E0),
//                         iconColor: const Color(0xFF2196F3),
//                         label: "",
//                         useBoxShadow: false,
//                         icon: Icons.location_city_rounded,
//                         items: _viewModel.cities.value,
//                         selectedValue: _viewModel.selectedCity.value.isNotEmpty
//                             ? _viewModel.selectedCity.value
//                             : '',
//                         onChanged: (value) {
//                           if (value != null && value != '') {
//                             String selectedCity = value.toString();
//                             _viewModel.setShopField('city', selectedCity);
//                           }
//                         },
//                         validator: (value) =>
//                         value == null || value.isEmpty ? "Please select a City" : null,
//                         textStyle: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF424242)),
//                         showSerialNumbers: true,
//                       )),
//
//                       _buildTextField(
//                         label: "Shop Address",
//                         icon: Icons.place_rounded,
//                         onChanged: (value) =>
//                             _viewModel.setShopField('shop_address', value),
//                         validator: (value) => value == null || value.isEmpty
//                             ? "Please enter shop address"
//                             : null,
//                         maxLines: 2,
//                       ),
//
//                       const SizedBox(height: 24),
//                       _buildSectionHeader('Owner Details', Icons.person_outline),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         label: "Owner Name",
//                         icon: Icons.person_rounded,
//                         onChanged: (value) =>
//                             _viewModel.setShopField('owner_name', value),
//                         validator: (value) => value == null || value.isEmpty
//                             ? "Please enter owner name"
//                             : null,
//                       ),
//
//                       _buildTextField(
//                         label: "CNIC",
//                         icon: Icons.badge_rounded,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [CNICInputFormatter()],
//                         validator: Validators.validateCNIC,
//                         onChanged: (value) {
//                           _viewModel.setShopField('owner_cnic', value);
//                         },
//                       ),
//
//                       const SizedBox(height: 24),
//                       _buildSectionHeader('Contact Information', Icons.phone_rounded),
//                       const SizedBox(height: 16),
//
//                       _buildTextField(
//                         label: "Phone Number",
//                         icon: Icons.phone_rounded,
//                         onChanged: (value) => _viewModel.setShopField('phone_no', value),
//                         validator: Validators.validatePhoneNumber,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [PhoneNumberFormatter()],
//                       ),
//
//                       _buildTextField(
//                         label: "Alternative Phone Number",
//                         icon: Icons.phone_android_rounded,
//                         onChanged: (value) =>
//                             _viewModel.setShopField('alternative_phone_no', value),
//                         validator: Validators.validatePhoneNumber,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [PhoneNumberFormatter()],
//                       ),
//
//                       const SizedBox(height: 24),
//                       _buildSectionHeader('Location', Icons.location_on_rounded),
//                       const SizedBox(height: 16),
//
//                       Obx(() => CustomSwitch(
//                         label: "GPS Enabled",
//                         value: locationViewModel.isGPSEnabled.value,
//                         onChanged: (value) async {
//                           locationViewModel.isGPSEnabled.value = value;
//                           if (value) {
//                             await locationViewModel.saveCurrentLocation();
//                           }
//                           _viewModel.updateSaveButtonState();
//                         },
//                       )),
//
//                       const SizedBox(height: 32),
//
//                       Obx(
//                             () => CustomButton(
//                           buttonText: "Save Shop",
//                           onTap: _viewModel.isFormReadyToSave.value
//                               ? _viewModel.saveForm
//                               : null,
//                           gradientColors: _viewModel.isFormReadyToSave.value
//                               ? const [Color(0xFF2196F3), Color(0xFF1976D2)]
//                               : const [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2196F3).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 20,
//             color: const Color(0xFF2196F3),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF212121),
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required IconData icon,
//     required ValueChanged<String> onChanged,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(
//             color: Color(0xFF757575),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
//           filled: true,
//           fillColor: const Color(0xFFF8F9FA),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF212121),
//         ),
//         onChanged: onChanged,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         validator: validator,
//         maxLines: maxLines,
//       ),
//     );
//   }
// }

// lib/screens/add_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/Components/custom_switch.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import '../LocatioPoints/ravelTimeViewModel.dart';
import '../ViewModels/add_shop_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_dropdown_second.dart';
import 'Components/validators.dart';

class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  // For responsive design
  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1200;
  bool get isLargeScreen => MediaQuery.of(context).size.width >= 1200;
  double get responsivePadding => isSmallScreen ? 16 : 24;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final travelTimeViewModel = Get.find<TravelTimeViewModel>();
      travelTimeViewModel.setWorkingScreenStatus(true);
      debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time ACTIVE");
    });
  }

  @override
  void dispose() {
    final travelTimeViewModel = Get.find<TravelTimeViewModel>();
    travelTimeViewModel.setWorkingScreenStatus(false);
    debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time INACTIVE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Add New Shop',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Header Card with Icon
                  Container(
                    width: size.width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 20 : 28,
                      horizontal: responsivePadding,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.store_mall_directory_rounded,
                            size: isSmallScreen ? 42 : 52,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Shop Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 15 : 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Card
                  Container(
                    margin: EdgeInsets.all(responsivePadding),
                    constraints: BoxConstraints(
                      maxWidth: isLargeScreen ? 800 : double.infinity,
                    ),
                    width: double.infinity,
                    child: Center(
                      child: Container(
                        width: isLargeScreen ? 800 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _viewModel.formKey,
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Basic Details Section
                                _buildSectionHeader('Basic Details', Icons.info_outline),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  label: "Shop Name",
                                  icon: Icons.storefront_rounded,
                                  onChanged: (value) =>
                                      _viewModel.setShopField('shop_name', value),
                                  validator: (value) => value == null || value.isEmpty
                                      ? "Please enter shop name"
                                      : null,
                                ),

                                Obx(() => CustomDropdownSecond(
                                  borderColor: const Color(0xFFE0E0E0),
                                  iconColor: const Color(0xFF2196F3),
                                  label: "",
                                  useBoxShadow: false,
                                  icon: Icons.location_city_rounded,
                                  items: _viewModel.cities.value,
                                  selectedValue: _viewModel.selectedCity.value.isNotEmpty
                                      ? _viewModel.selectedCity.value
                                      : '',
                                  onChanged: (value) {
                                    if (value != null && value != '') {
                                      String selectedCity = value.toString();
                                      _viewModel.setShopField('city', selectedCity);
                                    }
                                  },
                                  validator: (value) =>
                                  value == null || value.isEmpty ? "Please select a City" : null,
                                  textStyle: TextStyle(
                                    fontSize: isSmallScreen ? 15 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF424242),
                                  ),
                                  showSerialNumbers: true,
                                )),

                                _buildTextField(
                                  label: "Shop Address",
                                  icon: Icons.place_rounded,
                                  onChanged: (value) =>
                                      _viewModel.setShopField('shop_address', value),
                                  validator: (value) => value == null || value.isEmpty
                                      ? "Please enter shop address"
                                      : null,
                                  maxLines: isSmallScreen ? 2 : 3,
                                ),

                                const SizedBox(height: 24),

                                // Owner Details Section
                                _buildSectionHeader('Owner Details', Icons.person_outline),
                                const SizedBox(height: 16),

                                if (isLargeScreen)
                                  _buildTwoColumnLayout(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label: "Owner Name",
                                          icon: Icons.person_rounded,
                                          onChanged: (value) =>
                                              _viewModel.setShopField('owner_name', value),
                                          validator: (value) => value == null || value.isEmpty
                                              ? "Please enter owner name"
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTextField(
                                          label: "CNIC",
                                          icon: Icons.badge_rounded,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [CNICInputFormatter()],
                                          validator: Validators.validateCNIC,
                                          onChanged: (value) {
                                            _viewModel.setShopField('owner_cnic', value);
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _buildTextField(
                                        label: "Owner Name",
                                        icon: Icons.person_rounded,
                                        onChanged: (value) =>
                                            _viewModel.setShopField('owner_name', value),
                                        validator: (value) => value == null || value.isEmpty
                                            ? "Please enter owner name"
                                            : null,
                                      ),
                                      _buildTextField(
                                        label: "CNIC",
                                        icon: Icons.badge_rounded,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [CNICInputFormatter()],
                                        validator: Validators.validateCNIC,
                                        onChanged: (value) {
                                          _viewModel.setShopField('owner_cnic', value);
                                        },
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 24),

                                // Contact Information Section
                                _buildSectionHeader('Contact Information', Icons.phone_rounded),
                                const SizedBox(height: 16),

                                if (isLargeScreen)
                                  _buildTwoColumnLayout(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label: "Phone Number",
                                          icon: Icons.phone_rounded,
                                          onChanged: (value) => _viewModel.setShopField('phone_no', value),
                                          validator: Validators.validatePhoneNumber,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [PhoneNumberFormatter()],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTextField(
                                          label: "Alternative Phone Number",
                                          icon: Icons.phone_android_rounded,
                                          onChanged: (value) =>
                                              _viewModel.setShopField('alternative_phone_no', value),
                                          validator: Validators.validatePhoneNumber,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [PhoneNumberFormatter()],
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _buildTextField(
                                        label: "Phone Number",
                                        icon: Icons.phone_rounded,
                                        onChanged: (value) => _viewModel.setShopField('phone_no', value),
                                        validator: Validators.validatePhoneNumber,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [PhoneNumberFormatter()],
                                      ),
                                      _buildTextField(
                                        label: "Alternative Phone Number",
                                        icon: Icons.phone_android_rounded,
                                        onChanged: (value) =>
                                            _viewModel.setShopField('alternative_phone_no', value),
                                        validator: Validators.validatePhoneNumber,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [PhoneNumberFormatter()],
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 24),

                                // Location Section
                                _buildSectionHeader('Location', Icons.location_on_rounded),
                                const SizedBox(height: 16),

                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 0 : 8,
                                  ),
                                  child: Obx(() => CustomSwitch(
                                    label: "GPS Enabled",
                                    value: locationViewModel.isGPSEnabled.value,
                                    onChanged: (value) async {
                                      locationViewModel.isGPSEnabled.value = value;
                                      if (value) {
                                        await locationViewModel.saveCurrentLocation();
                                      }
                                      _viewModel.updateSaveButtonState();
                                    },
                                  )),
                                ),

                                SizedBox(height: isSmallScreen ? 24 : 32),

                                // Save Button
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLargeScreen ? 100 : 0,
                                  ),
                                  child: Obx(
                                        () => CustomButton(
                                      buttonText: "Save Shop",
                                      onTap: _viewModel.isFormReadyToSave.value
                                          ? _viewModel.saveForm
                                          : null,
                                      gradientColors: _viewModel.isFormReadyToSave.value
                                          ? const [Color(0xFF2196F3), Color(0xFF1976D2)]
                                          : const [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: responsivePadding),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: const Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFF757575),
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
              icon,
              color: const Color(0xFF2196F3),
              size: isSmallScreen ? 20 : 22
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF212121),
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildTwoColumnLayout({required List<Widget> children}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}