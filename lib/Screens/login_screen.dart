//
//
// import 'dart:io';
// import 'package:auto_route/annotations.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
// import 'package:order_booking_app/ViewModels/add_shop_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:order_booking_app/ViewModels/login_view_model.dart';
// import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
// import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
// import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
// import 'package:order_booking_app/screens/Components/custom_button.dart';
// import 'package:order_booking_app/screens/signup_screen.dart';
// import 'package:order_booking_app/widgets/bookit_header.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/returnform_details_model.dart';
// import '../ViewModels/return_form_details_view_model.dart';
// import '../ViewModels/return_form_view_model.dart';
// import '../components/under_part.dart';
// import '../constants.dart';
// import '../widgets/rounded_button.dart';
// import '../widgets/rounded_icon.dart';
// import 'components/custom_editable_menu_option.dart';
// import 'package:order_booking_app/widgets/color.dart'; // AppColor used to match CodeScreen's palette
//
// @RoutePage()
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   late final addShopViewModel = Get.put(AddShopViewModel());
//   late final productsViewModel = Get.put(ProductsViewModel());
//   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
//   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
//   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
//   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
//   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
//   late final returnFormViewModel = Get.put(ReturnFormViewModel());
//   late final ReturnFormDetailsViewModel returnFormDetailsViewModel = Get.put(ReturnFormDetailsViewModel());
//
//   late final attendanceViewModel = Get.put(AttendanceViewModel());
//   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//   final LocationViewModel locationViewModel = Get.put(LocationViewModel());
//   late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
//   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
//
//   final _formKey = GlobalKey<FormState>();
//   bool isChecked = true;
//   bool isLoading = false;
//   bool isPasswordVisible = false;
//   bool isButtonDisabled = false;
//
//   // Add a ValueNotifier to track progress
//   final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       isLoading = true;
//       isButtonDisabled = true;
//       _progressNotifier.value = 0.0; // Reset progress
//     });
//
//     final prefs = await SharedPreferences.getInstance();
//
//     // --- 📍 Location Check Before Anything ---
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Check if location service is enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Get.snackbar(
//         'Location Required',
//         'Please enable location services to continue.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     // Check for location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Get.snackbar(
//           'Permission Denied',
//           'Location permission is required to continue.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         setState(() {
//           isLoading = false;
//           isButtonDisabled = false;
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       Get.snackbar(
//         'Permission Permanently Denied',
//         'Location permissions are permanently denied. Please enable them from settings.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     // --- 🌐 Internet Connectivity Check ---
//     final connectivityResult = await Connectivity().checkConnectivity();
//
//     if (connectivityResult == ConnectivityResult.none) {
//       Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isEmpty || result[0].rawAddress.isEmpty) {
//         Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
//         setState(() {
//           isLoading = false;
//           isButtonDisabled = false;
//         });
//         return;
//       }
//     } catch (_) {
//       Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     // --- 🧠 Login Process ---
//     final success = await loginViewModel.login(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );
//
//     if (!success) {
//       Get.snackbar('Error', 'Invalid user ID or password', snackPosition: SnackPosition.BOTTOM);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     await prefs.setString('userId', _emailController.text.trim());
//     await prefs.reload();
//     user_id = prefs.getString('userId')!;
//     debugPrint("User ID: $user_id");
//
//     try {
//       // same existing data sync code below ↓
//       final bool isManager = ['RSM', 'SM', 'NSM', 'DISPATCHER'].contains(userDesignation);
//       final int totalTasks = isManager ? 4 : 17;
//       int completedTasks = 0;
//
//       void updateProgress() {
//         completedTasks++;
//         _progressNotifier.value = completedTasks / totalTasks;
//       }
//
//       Future<void> trackedTask(Future<void> task) async {
//         await task;
//         updateProgress();
//       }
//
//       if (isManager) {
//         await trackedTask(addShopViewModel.fetchAndSaveHeadsShop());
//         await trackedTask(shopVisitViewModel.serialCounterGetHeads());
//         await trackedTask(attendanceViewModel.serialCounterGet());
//         await trackedTask(locationViewModel.serialCounterGet());
//       } else {
//         await trackedTask(addShopViewModel.fetchAndSaveShop());
//         await trackedTask(shopVisitViewModel.serialCounterGet());
//         await trackedTask(addShopViewModel.serialCounterGet());
//         await trackedTask(shopVisitDetailsViewModel.serialCounterGet());
//         await trackedTask(recoveryFormViewModel.serialCounterGet());
//         await trackedTask(returnFormViewModel.serialCounterGet());
//         await trackedTask(returnFormDetailsViewModel.serialCounterGet());
//         await trackedTask(attendanceViewModel.serialCounterGet());
//         await trackedTask(orderMasterViewModel.serialCounterGet());
//         await trackedTask(orderDetailsViewModel.serialCounterGet());
//         await trackedTask(locationViewModel.serialCounterGet());
//
//         await Future.wait([
//           trackedTask(productsViewModel.fetchAndSaveProducts()),
//           trackedTask(orderMasterViewModel.fetchAndSaveOrderMaster()),
//           trackedTask(orderDetailsViewModel.fetchAndSaveOrderDetails()),
//           trackedTask(shopVisitDetailsViewModel.initializeProductData()),
//           trackedTask(updateFunctionViewModel.checkAndSetInitializationDateTime()),
//         ]);
//       }
//
//       await loginViewModel.navigateToHomePage();
//     } catch (e) {
//       debugPrint('Data fetch error: $e');
//       Get.snackbar('Error', 'Data sync failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//     }
//   }
//
//   // --------------------------
//   // UI: redesigned to MATCH CodeScreen theme (minimal, single palette)
//   // - kept all functionality and method signatures intact
//   // - removed gradients and extra accent colors
//   // --------------------------
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//         backgroundColor: AppColor.bgColor, // single neutral background from CodeScreen theme
//         body: Stack(
//             children: [
//               // --- BACKGROUND DESIGN ---
//               // Large abstract shape at the top
//               Positioned(
//                 top: -100,
//                 right: -50,
//                 child: Transform.rotate(
//                   angle: -0.2, // Tilts the shape for that "pointed" look
//                   child: Container(
//                     width: 300,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(80),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blueGrey.withOpacity(0.4),
//                           Colors.blueGrey.withOpacity(0.1),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Secondary accent circle
//               Positioned(
//                 top: 50,
//                 left: -30,
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.blueGrey.withOpacity(0.05),
//                   ),
//                 ),
//               ),
//
//               SafeArea(
//                 child: Center(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
//                     physics: const BouncingScrollPhysics(),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(minHeight: size.height - 56),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           BookITHeader(),
//                           // Simple branding header (clean, no extra color)
//                           // Column(
//                           //   children: [
//                           //     Container(
//                           //     ),
//                           //     Text(
//                           //       'BOOKIT',
//                           //       style: TextStyle(
//                           //         fontSize: 36,
//                           //         fontWeight: FontWeight.w900,
//                           //         color: AppColor.darkText,
//                           //         letterSpacing: 1.2,
//                           //       ),
//                           //     ),
//                           //     const SizedBox(height: 6),
//                           //     Text(
//                           //       'ORDER MANAGEMENT SYSTEM',
//                           //       style: TextStyle(
//                           //         fontSize: 12,
//                           //         color: AppColor.subText,
//                           //         letterSpacing: 1.6,
//                           //         fontWeight: FontWeight.w600,
//                           //       ),
//                           //     ),
//                           const SizedBox(height: 26),
//                           //   ],
//                           // ),
//
//                           // Card container for the form (white, subtle shadow)
//                           Container(
//
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColor.darkText.withOpacity(0.04),
//                                   blurRadius: 24,
//                                   offset: const Offset(0, 12),
//                                 )
//                               ],
//                             ),
//                             child: Form(
//                               key: _formKey,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Sign in',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w800,
//                                       color: AppColor.darkText,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     'Enter your credentials to continue.',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: AppColor.subText,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 18),
//
//                                   // Employee ID
//                                   TextFormField(
//                                     controller: _emailController,
//                                     decoration: InputDecoration(
//                                       hintText: 'Employee ID',
//                                       filled: true,
//                                       fillColor: const Color(0xFFF7F8FA),
//                                       contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       prefixIcon: Icon(Icons.person_rounded, color: AppColor.darkText.withOpacity(0.6)),
//                                     ),
//                                     style: TextStyle(color: AppColor.darkText, fontSize: 15),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter employee ID';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   const SizedBox(height: 12),
//
//                                   // Password
//                                   TextFormField(
//                                     controller: _passwordController,
//                                     obscureText: !isPasswordVisible,
//                                     decoration: InputDecoration(
//                                       hintText: 'Password',
//                                       filled: true,
//                                       fillColor: const Color(0xFFF7F8FA),
//                                       contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       prefixIcon: Icon(Icons.lock_outline, color: AppColor.darkText.withOpacity(0.6)),
//                                       suffixIcon: GestureDetector(
//                                         onTap: () {
//                                           setState(() => isPasswordVisible = !isPasswordVisible);
//                                         },
//                                         child: Icon(
//                                           isPasswordVisible ? Icons.visibility_off : Icons.visibility,
//                                           color: AppColor.subText,
//                                         ),
//                                       ),
//                                     ),
//                                     style: TextStyle(color: AppColor.darkText, fontSize: 15),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) return 'Please enter password';
//                                       return null;
//                                     },
//                                   ),
//
//                                   const SizedBox(height: 12),
//
//                                   // Row remember + forgot
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Checkbox(
//                                             value: isChecked,
//                                             onChanged: (v) => setState(() => isChecked = v ?? true),
//                                           ),
//                                           Text(
//                                             'Remember me',
//                                             style: TextStyle(color: AppColor.subText,fontSize: 13, fontWeight: FontWeight.w500),
//                                           ),
//                                         ],
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           Get.snackbar(
//                                             'Forgot Password',
//                                             'Contact your administrator to reset password',
//                                             snackPosition: SnackPosition.BOTTOM,
//                                             backgroundColor: AppColor.darkText,
//                                             colorText: Colors.white,
//                                           );
//                                         },
//                                         child: Text('Forgot Password?', style: TextStyle(color: AppColor.darkText, fontSize: 13)),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 10),
//
//                                   // Login button (single color to match CodeScreen)
//                                   ValueListenableBuilder<double>(
//                                     valueListenable: _progressNotifier,
//                                     builder: (context, progress, _) {
//                                       return SizedBox(
//                                         width: double.infinity,
//                                         height: 52,
//                                         child: ElevatedButton(
//                                           onPressed: isButtonDisabled ? null : _login,
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: AppColor.darkText,
//                                             foregroundColor: Colors.white,
//                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                           ),
//                                           child: isLoading
//                                               ? Row(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               const SizedBox(
//                                                 width: 18,
//                                                 height: 18,
//                                                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Text('LOGGING IN ${ (progress*100).toStringAsFixed(0) }%', style: const TextStyle(fontWeight: FontWeight.w700)),
//                                             ],
//                                           )
//                                               : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w700)),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 18),
//
//                           // Footer small help text
//                           Column(
//                             children: [
//                               TextButton(
//                                 onPressed: () {
//                                   Get.snackbar(
//                                     "Help",
//                                     "Contact your administrator for support",
//                                     snackPosition: SnackPosition.BOTTOM,
//                                     backgroundColor: AppColor.darkText,
//                                     colorText: Colors.white,
//                                   );
//                                 },
//                                 child: Text(
//                                   'Need help?',
//                                   style: TextStyle(color: AppColor.subText, fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               // Text(
//                               //   'SECURED END-TO-END',
//                               //   style: TextStyle(fontSize: 11, color: AppColor.subText),
//                               // ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ]
//         )
//     );
//   }
// }

///remove firebase


import 'dart:io';
import 'package:auto_route/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
import 'package:order_booking_app/ViewModels/add_shop_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/ViewModels/login_view_model.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
import 'package:order_booking_app/screens/Components/custom_button.dart';
import 'package:order_booking_app/screens/signup_screen.dart';
import 'package:order_booking_app/widgets/bookit_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/returnform_details_model.dart';
import '../ViewModels/return_form_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import '../components/under_part.dart';
import '../constants.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_icon.dart';
import 'components/custom_editable_menu_option.dart';
import 'package:order_booking_app/widgets/color.dart'; // AppColor used to match CodeScreen's palette

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final productsViewModel = Get.put(ProductsViewModel());
  late final shopVisitViewModel = Get.put(ShopVisitViewModel());
  late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
  late final orderMasterViewModel = Get.put(OrderMasterViewModel());
  late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
  late final returnFormViewModel = Get.put(ReturnFormViewModel());
  late final ReturnFormDetailsViewModel returnFormDetailsViewModel = Get.put(ReturnFormDetailsViewModel());

  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());
  late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
  final LoginViewModel loginViewModel = Get.put(LoginViewModel());

  final _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isButtonDisabled = false;

  // Add a ValueNotifier to track progress
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      isButtonDisabled = true;
      _progressNotifier.value = 0.0; // Reset progress
    });

    final prefs = await SharedPreferences.getInstance();

    // --- 📍 Location Check Before Anything ---
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Required',
        'Please enable location services to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required to continue.',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Permanently Denied',
        'Location permissions are permanently denied. Please enable them from settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    // --- 🌐 Internet Connectivity Check ---
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }
    } catch (_) {
      Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    // --- 🧠 Login Process ---
    final success = await loginViewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success) {
      Get.snackbar('Error', 'Invalid user ID or password', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    await prefs.setString('userId', _emailController.text.trim());
    await prefs.reload();
    user_id = prefs.getString('userId')!;
    debugPrint("User ID: $user_id");

    try {
      // same existing data sync code below ↓
      final bool isManager = ['RSM', 'SM', 'NSM', 'DISPATCHER'].contains(userDesignation);
      final int totalTasks = isManager ? 4 : 17;
      int completedTasks = 0;

      void updateProgress() {
        completedTasks++;
        _progressNotifier.value = completedTasks / totalTasks;
      }

      Future<void> trackedTask(Future<void> task) async {
        await task;
        updateProgress();
      }

      if (isManager) {
        await trackedTask(addShopViewModel.fetchAndSaveHeadsShop());
        await trackedTask(shopVisitViewModel.serialCounterGetHeads());
        await trackedTask(attendanceViewModel.serialCounterGet());
        await trackedTask(locationViewModel.serialCounterGet());
      } else {
        await trackedTask(addShopViewModel.fetchAndSaveShop());
        await trackedTask(shopVisitViewModel.serialCounterGet());
        await trackedTask(addShopViewModel.serialCounterGet());
        await trackedTask(shopVisitDetailsViewModel.serialCounterGet());
        await trackedTask(recoveryFormViewModel.serialCounterGet());
        await trackedTask(returnFormViewModel.serialCounterGet());
        await trackedTask(returnFormDetailsViewModel.serialCounterGet());
        await trackedTask(attendanceViewModel.serialCounterGet());
        await trackedTask(orderMasterViewModel.serialCounterGet());
        await trackedTask(orderDetailsViewModel.serialCounterGet());
        await trackedTask(locationViewModel.serialCounterGet());

        await Future.wait([
          trackedTask(productsViewModel.fetchAndSaveProducts()),
          trackedTask(orderMasterViewModel.fetchAndSaveOrderMaster()),
          trackedTask(orderDetailsViewModel.fetchAndSaveOrderDetails()),
          trackedTask(shopVisitDetailsViewModel.initializeProductData()),
          trackedTask(updateFunctionViewModel.checkAndSetInitializationDateTime()),
        ]);
      }

      await loginViewModel.navigateToHomePage();
    } catch (e) {
      debugPrint('Data fetch error: $e');
      Get.snackbar('Error', 'Data sync failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
    }
  }

  // --------------------------
  // UI: redesigned to MATCH CodeScreen theme (minimal, single palette)
  // - kept all functionality and method signatures intact
  // - removed gradients and extra accent colors
  // --------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColor.bgColor, // single neutral background from CodeScreen theme
        body: Stack(
            children: [
              // --- BACKGROUND DESIGN ---
              // Large abstract shape at the top
              Positioned(
                top: -100,
                right: -50,
                child: Transform.rotate(
                  angle: -0.2, // Tilts the shape for that "pointed" look
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueGrey.withOpacity(0.4),
                          Colors.blueGrey.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // Secondary accent circle
              Positioned(
                top: 50,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueGrey.withOpacity(0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: size.height - 56),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BookITHeader(),
                          // Simple branding header (clean, no extra color)
                          // Column(
                          //   children: [
                          //     Container(
                          //     ),
                          //     Text(
                          //       'BOOKIT',
                          //       style: TextStyle(
                          //         fontSize: 36,
                          //         fontWeight: FontWeight.w900,
                          //         color: AppColor.darkText,
                          //         letterSpacing: 1.2,
                          //       ),
                          //     ),
                          //     const SizedBox(height: 6),
                          //     Text(
                          //       'ORDER MANAGEMENT SYSTEM',
                          //       style: TextStyle(
                          //         fontSize: 12,
                          //         color: AppColor.subText,
                          //         letterSpacing: 1.6,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          const SizedBox(height: 26),
                          //   ],
                          // ),

                          // Card container for the form (white, subtle shadow)
                          Container(

                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.darkText.withOpacity(0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                )
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Enter your credentials to continue.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.subText,
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Employee ID
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: 'Employee ID',
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8FA),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: Icon(Icons.person_rounded, color: AppColor.darkText.withOpacity(0.6)),
                                    ),
                                    style: TextStyle(color: AppColor.darkText, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter employee ID';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !isPasswordVisible,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8FA),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: Icon(Icons.lock_outline, color: AppColor.darkText.withOpacity(0.6)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() => isPasswordVisible = !isPasswordVisible);
                                        },
                                        child: Icon(
                                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                          color: AppColor.subText,
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(color: AppColor.darkText, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter password';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  // Row remember + forgot
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            onChanged: (v) => setState(() => isChecked = v ?? true),
                                          ),
                                          Text(
                                            'Remember me',
                                            style: TextStyle(color: AppColor.subText,fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.snackbar(
                                            'Forgot Password',
                                            'Contact your administrator to reset password',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppColor.darkText,
                                            colorText: Colors.white,
                                          );
                                        },
                                        child: Text('Forgot Password?', style: TextStyle(color: AppColor.darkText, fontSize: 13)),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Login button (single color to match CodeScreen)
                                  ValueListenableBuilder<double>(
                                    valueListenable: _progressNotifier,
                                    builder: (context, progress, _) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: isButtonDisabled ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColor.darkText,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: isLoading
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                              ),
                                              const SizedBox(width: 12),
                                              Text('LOGGING IN ${ (progress*100).toStringAsFixed(0) }%', style: const TextStyle(fontWeight: FontWeight.w700)),
                                            ],
                                          )
                                              : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w700)),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Footer small help text
                          Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.snackbar(
                                    "Help",
                                    "Contact your administrator for support",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColor.darkText,
                                    colorText: Colors.white,
                                  );
                                },
                                child: Text(
                                  'Need help?',
                                  style: TextStyle(color: AppColor.subText, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Text(
                              //   'SECURED END-TO-END',
                              //   style: TextStyle(fontSize: 11, color: AppColor.subText),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }
}