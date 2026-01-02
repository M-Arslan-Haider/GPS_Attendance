

// lib/screens/add_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/Components/custom_switch.dart';
// import 'package:order_booking_app/Screens/code_screen.dart';
// import 'package:order_booking_app/Screens/signup_screen.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import '../LocatioPoints/ravelTimeViewModel.dart';
import '../ViewModels/add_shop_view_model.dart';
import 'Components/custom_button.dart';
import 'Components/custom_dropdown_second.dart';
import 'Components/validators.dart';


// class AddShopScreen extends StatelessWidget {
//   final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   AddShopScreen({super.key});
class AddShopScreen extends StatefulWidget { // ✅ ABDULLAH: Changed to StatefulWidget
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final AddShopViewModel _viewModel = Get.put(AddShopViewModel());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());

  @override
  void initState() {
    super.initState();

    // ✅ ABDULLAH: Set working status when entering Add Shop screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final travelTimeViewModel = Get.find<TravelTimeViewModel>();
      travelTimeViewModel.setWorkingScreenStatus(true);
      debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time ACTIVE");
    });
  }

  @override
  void dispose() {
    // ✅ ABDULLAH: Reset working status when leaving Add Shop screen
    final travelTimeViewModel = Get.find<TravelTimeViewModel>();
    travelTimeViewModel.setWorkingScreenStatus(false);
    debugPrint("📍 [WORKING STATUS] Add Shop Screen - Working time INACTIVE");

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Add Shop',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: "Shop Name",
                    icon: Icons.store,
                    onChanged: (value) =>
                        _viewModel.setShopField('shop_name', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter shop name"
                        : null,
                  ),
                  Obx(() => CustomDropdownSecond(
                    borderColor: Colors.black,
                    iconColor: Colors.blue,
                    label: "City",
                    useBoxShadow: false,
                    icon: Icons.location_city,
                    items: _viewModel.cities.value,
                    selectedValue: _viewModel.selectedCity.value.isNotEmpty
                        ? _viewModel.selectedCity.value
                        : 'Select a City',
                    onChanged: (value) {
                      if (value != null && value != 'Select a City') {
                        String selectedCity = value.toString();
                        _viewModel.setShopField('city', selectedCity);
                      }
                    },

                    validator: (value) =>
                    value == null || value.isEmpty ? "Please select a City" : null,
                    textStyle: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                    showSerialNumbers: true, // یہاں serial numbers آن کریں
                  )),

                  // Obx(() => CustomDropdownSecond(
                  //   borderColor: Colors.black,
                  //   iconColor: Colors.blue,
                  //   label: "City",
                  //   useBoxShadow: false,
                  //   icon: Icons.location_city,
                  //   items: _viewModel.cities.value,
                  //   selectedValue: _viewModel.selectedCity.value.isNotEmpty
                  //       ? _viewModel.selectedCity.value
                  //       : 'Select a City',
                  //   onChanged: (value) {
                  //     String selectedCity = value?.toString() ?? '';
                  //     _viewModel.setShopField('city', selectedCity);
                  //   },
                  //   validator: (value) =>
                  //   value == null || value.isEmpty ? "Please select a City" : null,
                  //   textStyle: const TextStyle(
                  //       fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                  // )),

                  _buildTextField(
                    label: "Shop Address",
                    icon: Icons.place,
                    onChanged: (value) =>
                        _viewModel.setShopField('shop_address', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter shop address"
                        : null,
                  ),
                  _buildTextField(
                    label: "Owner Name",
                    icon: Icons.person,
                    onChanged: (value) =>
                        _viewModel.setShopField('owner_name', value),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter owner name"
                        : null,
                  ),

                  _buildTextField(
                    label: "CNIC",
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CNICInputFormatter()],
                    validator: Validators.validateCNIC,
                    onChanged: (value) {
                      _viewModel.setShopField('owner_cnic', value);
                    },
                  ),

                  _buildTextField(
                    label: "Phone Number",
                    icon: Icons.phone,
                    onChanged: (value) => _viewModel.setShopField('phone_no', value),
                    validator: Validators.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                  ),


                  _buildTextField(
                    label: "Alternative Phone Number",
                    icon: Icons.phone_android,
                    onChanged: (value) =>
                        _viewModel.setShopField('alternative_phone_no', value),
                    validator: Validators.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                  ),
                  const SizedBox(height: 10),
                  // Use Obx to reactively update CustomSwitch
                  Obx(() => CustomSwitch(
                    label: "GPS Enabled",
                    value: locationViewModel.isGPSEnabled.value,
                    onChanged: (value) async {
                      locationViewModel.isGPSEnabled.value = value;
                      if (value) {
                        await locationViewModel
                            .saveCurrentLocation(); // Save location when switch is turned on
                      }
                      // Update the save button state when GPS is toggled
                      _viewModel.updateSaveButtonState();
                    },
                  )),
                  const SizedBox(height: 10),
                  // Use Obx to control the button's enabled state
                  Obx(
                        () => CustomButton(
                      buttonText: "Save",
                      onTap: _viewModel.isFormReadyToSave.value
                          ? _viewModel.saveForm // Enabled: Call saveForm
                          : null, // Disabled: onTap is null
                      gradientColors: _viewModel.isFormReadyToSave.value
                          ? const [Colors.blue, Colors.blue] // Enabled color
                          : const [
                        Colors.grey,
                        Colors.grey
                      ], // Disabled color
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Get.to(() => CodeScreen()); // Replace with your destination screen
                  //   },
                  //   child: const Text("Go to Next Page", style: TextStyle(color: Colors.blue)),
                  // ),TextButton(
                  //   onPressed: () {
                  //     Get.to(() => SignUpScreen()); // Replace with your destination screen
                  //   },
                  //   child: const Text("Go to Next Page", style: TextStyle(color: Colors.blue)),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a custom text field with validation.
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}