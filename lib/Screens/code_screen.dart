// // // // // // // //
// // // // // // // // import 'dart:async';
// // // // // // // // import 'dart:convert';
// // // // // // // // import 'dart:io';
// // // // // // // //
// // // // // // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:get/get.dart';
// // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // // // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // //
// // // // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // // // //
// // // // // // // // class CodeScreen extends StatefulWidget {
// // // // // // // //   const CodeScreen({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CodeScreenState extends State<CodeScreen> {
// // // // // // // //   late final TextEditingController companyCodeController;
// // // // // // // //   final _formKey = GlobalKey<FormState>();
// // // // // // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // // // // // //   bool isLoading = false;
// // // // // // // //   bool isButtonDisabled = false;
// // // // // // // //
// // // // // // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // // // // // //   bool isOffline = false;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     companyCodeController = TextEditingController();
// // // // // // // //
// // // // // // // //     // Listen to internet connectivity changes
// // // // // // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // // // // // //
// // // // // // // //     connectivitySubscription =
// // // // // // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // // // // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // // // // // //
// // // // // // // //           if (result == ConnectivityResult.none) {
// // // // // // // //             setState(() => isOffline = true);
// // // // // // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // // // // // //           } else {
// // // // // // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // // // // // //             if (!hasNet) {
// // // // // // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // // // // // //             } else if (isOffline) {
// // // // // // // //               setState(() => isOffline = false);
// // // // // // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // // // // // //             }
// // // // // // // //           }
// // // // // // // //         });
// // // // // // // //
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void dispose() {
// // // // // // // //     companyCodeController.dispose();
// // // // // // // //     connectivitySubscription?.cancel();
// // // // // // // //     super.dispose();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// 🔹 Shows custom centered snackbar
// // // // // // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // // // // // //     final snackBar = SnackBar(
// // // // // // // //       content: Center(
// // // // // // // //         child: Text(
// // // // // // // //           message,
// // // // // // // //           style: const TextStyle(fontSize: 16),
// // // // // // // //           textAlign: TextAlign.center,
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // // // // // //       behavior: SnackBarBehavior.floating,
// // // // // // // //       shape: RoundedRectangleBorder(
// // // // // // // //         borderRadius: BorderRadius.circular(10),
// // // // // // // //       ),
// // // // // // // //       margin: EdgeInsets.only(
// // // // // // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // // // // // //         left: 20,
// // // // // // // //         right: 20,
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// 🔹 Check actual internet access — not just WiFi/mobile signal
// // // // // // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // // // // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // // // // // //
// // // // // // // //     // No connection at all
// // // // // // // //     if (connectivityResult == ConnectivityResult.none) {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // Check if actual connection works (ping)
// // // // // // // //     try {
// // // // // // // //       final result = await InternetAddress.lookup('google.com')
// // // // // // // //           .timeout(const Duration(seconds: 5));
// // // // // // // //
// // // // // // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // // // // // //         return true; // Internet is working
// // // // // // // //       } else {
// // // // // // // //         if (showSnack) {
// // // // // // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // // // // // //         }
// // // // // // // //         return false;
// // // // // // // //       }
// // // // // // // //     } on SocketException {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     } on TimeoutException {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     } catch (e) {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// 🔹 Save company details logic
// // // // // // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // // // // // //     _showCenteredSnackBar('Please wait...');
// // // // // // // //     setState(() {
// // // // // // // //       isLoading = true;
// // // // // // // //       isButtonDisabled = true;
// // // // // // // //     });
// // // // // // // //
// // // // // // // //     if (!await _hasInternet()) {
// // // // // // // //       setState(() {
// // // // // // // //         isLoading = false;
// // // // // // // //         isButtonDisabled = false;
// // // // // // // //       });
// // // // // // // //       return;
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     try {
// // // // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // // // //       await prefs.reload();
// // // // // // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // // // // // //
// // // // // // // //       await Config.fetchLatestConfig();
// // // // // // // //
// // // // // // // //       final response = await http
// // // // // // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // // // // // //           .timeout(const Duration(seconds: 30));
// // // // // // // //
// // // // // // // //       if (response.statusCode != 200) {
// // // // // // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // // // // // //         setState(() {
// // // // // // // //           isLoading = false;
// // // // // // // //           isButtonDisabled = false;
// // // // // // // //         });
// // // // // // // //         return;
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       final data = json.decode(response.body);
// // // // // // // //       final items = data['items'] as List;
// // // // // // // //       final company = items.firstWhere(
// // // // // // // //             (item) => item['company_code'] == companyCode,
// // // // // // // //         orElse: () => null,
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (company == null) {
// // // // // // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // // // // // //         setState(() {
// // // // // // // //           isLoading = false;
// // // // // // // //           isButtonDisabled = false;
// // // // // // // //         });
// // // // // // // //         return;
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       await prefs.setString('company_name', company['company_name']);
// // // // // // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // // // // // //       await prefs.setString('company_code', companyCode);
// // // // // // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // // // // // //
// // // // // // // //       if (!isAuthenticated) {
// // // // // // // //         try {
// // // // // // // //           _showCenteredSnackBar('Setting up your account...');
// // // // // // // //           await Config.fetchLatestConfig();
// // // // // // // //           await Config.getApiUrlERPCompanyName;
// // // // // // // //           companyName = await prefs.getString('company_name') ?? '';
// // // // // // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // // // // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // // // // // //         } catch (e) {
// // // // // // // //           debugPrint("Authentication error: $e");
// // // // // // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // // // // // //           setState(() {
// // // // // // // //             isLoading = false;
// // // // // // // //             isButtonDisabled = false;
// // // // // // // //           });
// // // // // // // //           return;
// // // // // // // //         }
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       _showCenteredSnackBar('Setup complete!');
// // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //         Get.offAll(() => const CameraScreen());
// // // // // // // //       });
// // // // // // // //     } on SocketException {
// // // // // // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // // // // // //     } on TimeoutException {
// // // // // // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // // // // // //     } on http.ClientException {
// // // // // // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // // // // // //     } catch (e) {
// // // // // // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // // // // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // // // // // //     } finally {
// // // // // // // //       setState(() {
// // // // // // // //         isLoading = false;
// // // // // // // //         isButtonDisabled = false;
// // // // // // // //       });
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// 🔹 UI build
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     final screenHeight = MediaQuery.of(context).size.height;
// // // // // // // //     final screenWidth = MediaQuery.of(context).size.width;
// // // // // // // //
// // // // // // // //     return Scaffold(
// // // // // // // //       backgroundColor: Colors.white,
// // // // // // // //       resizeToAvoidBottomInset: true,
// // // // // // // //       body: GestureDetector(
// // // // // // // //         onTap: () => FocusScope.of(context).unfocus(),
// // // // // // // //         child: SafeArea(
// // // // // // // //           child: Column(
// // // // // // // //             children: [
// // // // // // // //               Container(
// // // // // // // //                 height: screenHeight * 0.35,
// // // // // // // //                 width: double.infinity,
// // // // // // // //                 decoration: const BoxDecoration(
// // // // // // // //                   color: Colors.blueAccent,
// // // // // // // //                   borderRadius: BorderRadius.only(
// // // // // // // //                     bottomLeft: Radius.circular(30),
// // // // // // // //                     bottomRight: Radius.circular(30),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //                 child: const Column(
// // // // // // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // //                   children: [
// // // // // // // //                     Text(
// // // // // // // //                       'Welcome to',
// // // // // // // //                       style: TextStyle(
// // // // // // // //                         fontSize: 26,
// // // // // // // //                         color: Colors.white70,
// // // // // // // //                         fontWeight: FontWeight.w400,
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                     SizedBox(height: 8),
// // // // // // // //                     Text(
// // // // // // // //                       'BookIT!',
// // // // // // // //                       style: TextStyle(
// // // // // // // //                         fontSize: 36,
// // // // // // // //                         color: Colors.white,
// // // // // // // //                         fontWeight: FontWeight.bold,
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                   ],
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //               Expanded(
// // // // // // // //                 child: Padding(
// // // // // // // //                   padding: EdgeInsets.symmetric(
// // // // // // // //                     horizontal: screenWidth * 0.06,
// // // // // // // //                     vertical: 30,
// // // // // // // //                   ),
// // // // // // // //                   child: Form(
// // // // // // // //                     key: _formKey,
// // // // // // // //                     child: LayoutBuilder(
// // // // // // // //                       builder: (context, constraints) {
// // // // // // // //                         return SingleChildScrollView(
// // // // // // // //                           physics: const ClampingScrollPhysics(),
// // // // // // // //                           child: ConstrainedBox(
// // // // // // // //                             constraints: BoxConstraints(
// // // // // // // //                               minHeight: constraints.maxHeight,
// // // // // // // //                             ),
// // // // // // // //                             child: IntrinsicHeight(
// // // // // // // //                               child: Column(
// // // // // // // //                                 mainAxisSize: MainAxisSize.min,
// // // // // // // //                                 children: [
// // // // // // // //                                   const Text(
// // // // // // // //                                     'Please enter the company code to continue.\n',
// // // // // // // //                                     style: TextStyle(
// // // // // // // //                                       fontSize: 17,
// // // // // // // //                                       color: Colors.black87,
// // // // // // // //                                       height: 1.5,
// // // // // // // //                                     ),
// // // // // // // //                                     textAlign: TextAlign.center,
// // // // // // // //                                   ),
// // // // // // // //                                   const SizedBox(height: 20),
// // // // // // // //                                   const Align(
// // // // // // // //                                     alignment: Alignment.centerLeft,
// // // // // // // //                                     child: Text(
// // // // // // // //                                       'Company Code',
// // // // // // // //                                       style: TextStyle(
// // // // // // // //                                         fontSize: 16,
// // // // // // // //                                         fontWeight: FontWeight.w500,
// // // // // // // //                                         color: Colors.black87,
// // // // // // // //                                       ),
// // // // // // // //                                     ),
// // // // // // // //                                   ),
// // // // // // // //                                   const SizedBox(height: 10),
// // // // // // // //                                   TextFormField(
// // // // // // // //                                     controller: companyCodeController,
// // // // // // // //                                     decoration: InputDecoration(
// // // // // // // //                                       hintText: 'Enter your company code',
// // // // // // // //                                       filled: true,
// // // // // // // //                                       fillColor: Colors.grey[100],
// // // // // // // //                                       contentPadding: const EdgeInsets.symmetric(
// // // // // // // //                                         vertical: 16,
// // // // // // // //                                         horizontal: 16,
// // // // // // // //                                       ),
// // // // // // // //                                       border: OutlineInputBorder(
// // // // // // // //                                         borderRadius: BorderRadius.circular(12),
// // // // // // // //                                         borderSide: BorderSide.none,
// // // // // // // //                                       ),
// // // // // // // //                                     ),
// // // // // // // //                                     validator: (value) {
// // // // // // // //                                       if (value == null || value.isEmpty) {
// // // // // // // //                                         return 'Please enter company code';
// // // // // // // //                                       }
// // // // // // // //                                       return null;
// // // // // // // //                                     },
// // // // // // // //                                   ),
// // // // // // // //                                   const SizedBox(height: 55),
// // // // // // // //                                   SizedBox(
// // // // // // // //                                     width: double.infinity,
// // // // // // // //                                     child: ElevatedButton(
// // // // // // // //                                       onPressed: isButtonDisabled
// // // // // // // //                                           ? null
// // // // // // // //                                           : () {
// // // // // // // //                                         if (_formKey.currentState!.validate()) {
// // // // // // // //                                           _saveCompanyDetails(companyCodeController.text.trim());
// // // // // // // //                                         }
// // // // // // // //                                       },
// // // // // // // //                                       style: ElevatedButton.styleFrom(
// // // // // // // //                                         backgroundColor: Colors.blueAccent,
// // // // // // // //                                         foregroundColor: Colors.white,
// // // // // // // //                                         padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // //                                         shape: RoundedRectangleBorder(
// // // // // // // //                                           borderRadius: BorderRadius.circular(12),
// // // // // // // //                                         ),
// // // // // // // //                                       ),
// // // // // // // //                                       child: Text(
// // // // // // // //                                         isLoading ? 'Please wait...' : 'Continue',
// // // // // // // //                                         style: const TextStyle(fontSize: 16),
// // // // // // // //                                       ),
// // // // // // // //                                     ),
// // // // // // // //                                   ),
// // // // // // // //                                   SizedBox(
// // // // // // // //                                     height: MediaQuery.of(context).viewInsets.bottom > 0
// // // // // // // //                                         ? 20
// // // // // // // //                                         : screenHeight * 0.05,
// // // // // // // //                                   ),
// // // // // // // //                                 ],
// // // // // // // //                               ),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         );
// // // // // // // //                       },
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ],
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // // //
// // // // // // // //
// // // // // // // // import 'dart:async';
// // // // // // // // import 'dart:convert';
// // // // // // // // import 'dart:io';
// // // // // // // //
// // // // // // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:get/get.dart';
// // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // // // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // // //
// // // // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // // // //
// // // // // // // // class CodeScreen extends StatefulWidget {
// // // // // // // //   const CodeScreen({super.key});
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // // // // // }
// // // // // // // //
// // // // // // // // class _CodeScreenState extends State<CodeScreen> {
// // // // // // // //   late final TextEditingController companyCodeController;
// // // // // // // //   final _formKey = GlobalKey<FormState>();
// // // // // // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // // // // // //   bool isLoading = false;
// // // // // // // //   bool isButtonDisabled = false;
// // // // // // // //
// // // // // // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // // // // // //   bool isOffline = false;
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     companyCodeController = TextEditingController();
// // // // // // // //
// // // // // // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // // // // // //
// // // // // // // //     connectivitySubscription =
// // // // // // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // // // // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // // // // // //
// // // // // // // //           if (result == ConnectivityResult.none) {
// // // // // // // //             setState(() => isOffline = true);
// // // // // // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // // // // // //           } else {
// // // // // // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // // // // // //             if (!hasNet) {
// // // // // // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // // // // // //             } else if (isOffline) {
// // // // // // // //               setState(() => isOffline = false);
// // // // // // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // // // // // //             }
// // // // // // // //           }
// // // // // // // //         });
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   void dispose() {
// // // // // // // //     companyCodeController.dispose();
// // // // // // // //     connectivitySubscription?.cancel();
// // // // // // // //     super.dispose();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // // // // // //     final snackBar = SnackBar(
// // // // // // // //       content: Center(
// // // // // // // //         child: Text(
// // // // // // // //           message,
// // // // // // // //           style: const TextStyle(fontSize: 16),
// // // // // // // //           textAlign: TextAlign.center,
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // // // // // //       behavior: SnackBarBehavior.floating,
// // // // // // // //       shape: RoundedRectangleBorder(
// // // // // // // //         borderRadius: BorderRadius.circular(10),
// // // // // // // //       ),
// // // // // // // //       margin: EdgeInsets.only(
// // // // // // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // // // // // //         left: 20,
// // // // // // // //         right: 20,
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // // // // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // // // // // //
// // // // // // // //     if (connectivityResult == ConnectivityResult.none) {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     try {
// // // // // // // //       final result = await InternetAddress.lookup('google.com')
// // // // // // // //           .timeout(const Duration(seconds: 5));
// // // // // // // //
// // // // // // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // // // // // //         return true;
// // // // // // // //       } else {
// // // // // // // //         if (showSnack) {
// // // // // // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // // // // // //         }
// // // // // // // //         return false;
// // // // // // // //       }
// // // // // // // //     } on SocketException {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     } on TimeoutException {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     } catch (e) {
// // // // // // // //       if (showSnack) {
// // // // // // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // // // // // //       }
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //   }a
// // // // // // // //
// // // // // // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // // // // // //     _showCenteredSnackBar('Please wait...');
// // // // // // // //     setState(() {
// // // // // // // //       isLoading = true;
// // // // // // // //       isButtonDisabled = true;
// // // // // // // //     });
// // // // // // // //
// // // // // // // //     if (!await _hasInternet()) {
// // // // // // // //       setState(() {
// // // // // // // //         isLoading = false;
// // // // // // // //         isButtonDisabled = false;
// // // // // // // //       });
// // // // // // // //       return;
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     try {
// // // // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // // // //       await prefs.reload();
// // // // // // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // // // // // //
// // // // // // // //       await Config.fetchLatestConfig();
// // // // // // // //
// // // // // // // //       final response = await http
// // // // // // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // // // // // //           .timeout(const Duration(seconds: 30));
// // // // // // // //
// // // // // // // //       if (response.statusCode != 200) {
// // // // // // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // // // // // //         setState(() {
// // // // // // // //           isLoading = false;
// // // // // // // //           isButtonDisabled = false;
// // // // // // // //         });
// // // // // // // //         return;
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       final data = json.decode(response.body);
// // // // // // // //       final items = data['items'] as List;
// // // // // // // //       final company = items.firstWhere(
// // // // // // // //             (item) => item['company_code'] == companyCode,
// // // // // // // //         orElse: () => null,
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (company == null) {
// // // // // // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // // // // // //         setState(() {
// // // // // // // //           isLoading = false;
// // // // // // // //           isButtonDisabled = false;
// // // // // // // //         });
// // // // // // // //         return;
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       await prefs.setString('company_name', company['company_name']);
// // // // // // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // // // // // //       await prefs.setString('company_code', companyCode);
// // // // // // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // // // // // //
// // // // // // // //       if (!isAuthenticated) {
// // // // // // // //         try {
// // // // // // // //           _showCenteredSnackBar('Setting up your account...');
// // // // // // // //           await Config.fetchLatestConfig();
// // // // // // // //           await Config.getApiUrlERPCompanyName;
// // // // // // // //           companyName = await prefs.getString('company_name') ?? '';
// // // // // // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // // // // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // // // // // //         } catch (e) {
// // // // // // // //           debugPrint("Authentication error: $e");
// // // // // // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // // // // // //           setState(() {
// // // // // // // //             isLoading = false;
// // // // // // // //             isButtonDisabled = false;
// // // // // // // //           });
// // // // // // // //           return;
// // // // // // // //         }
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       _showCenteredSnackBar('Setup complete!');
// // // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // // //         Get.offAll(() => const CameraScreen());
// // // // // // // //       });
// // // // // // // //     } on SocketException {
// // // // // // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // // // // // //     } on TimeoutException {
// // // // // // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // // // // // //     } on http.ClientException {
// // // // // // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // // // // // //     } catch (e) {
// // // // // // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // // // // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // // // // // //     } finally {
// // // // // // // //       setState(() {
// // // // // // // //         isLoading = false;
// // // // // // // //         isButtonDisabled = false;
// // // // // // // //       });
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     final screenHeight = MediaQuery.of(context).size.height;
// // // // // // // //     final screenWidth = MediaQuery.of(context).size.width;
// // // // // // // //
// // // // // // // //     return Scaffold(
// // // // // // // //       backgroundColor: const Color(0xFFF5F7FA),
// // // // // // // //       resizeToAvoidBottomInset: true,
// // // // // // // //       body: GestureDetector(
// // // // // // // //         onTap: () => FocusScope.of(context).unfocus(),
// // // // // // // //         child: SafeArea(
// // // // // // // //           child: SingleChildScrollView(
// // // // // // // //             physics: const BouncingScrollPhysics(),
// // // // // // // //             child: Column(
// // // // // // // //               children: [
// // // // // // // //                 // Header Section with Gradient
// // // // // // // //                 Container(
// // // // // // // //                   width: double.infinity,
// // // // // // // //                   decoration: const BoxDecoration(
// // // // // // // //                     gradient: LinearGradient(
// // // // // // // //                       colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
// // // // // // // //                       begin: Alignment.topLeft,
// // // // // // // //                       end: Alignment.bottomRight,
// // // // // // // //                     ),
// // // // // // // //                     borderRadius: BorderRadius.only(
// // // // // // // //                       bottomLeft: Radius.circular(30),
// // // // // // // //                       bottomRight: Radius.circular(30),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 60),
// // // // // // // //                   child: Column(
// // // // // // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // //                     children: [
// // // // // // // //                       Container(
// // // // // // // //                         padding: const EdgeInsets.all(10),
// // // // // // // //                         // decoration: BoxDecoration(
// // // // // // // //                         //   color: Colors.white.withOpacity(0.2),
// // // // // // // //                         //   shape: BoxShape.circle,
// // // // // // // //                         // ),
// // // // // // // //                         // child: const Icon(
// // // // // // // //                         //   Icons.business_rounded,
// // // // // // // //                         //   size: 40,
// // // // // // // //                         //   color: Colors.white,
// // // // // // // //                         // ),
// // // // // // // //                       ),
// // // // // // // //                       const SizedBox(height: 20),
// // // // // // // //                       const Text(
// // // // // // // //                         'Welcome to',
// // // // // // // //                         style: TextStyle(
// // // // // // // //                           fontSize: 20,
// // // // // // // //                           color: Colors.white70,
// // // // // // // //                           fontWeight: FontWeight.w400,
// // // // // // // //                           letterSpacing: 0.5,
// // // // // // // //                         ),
// // // // // // // //                       ),
// // // // // // // //                       const SizedBox(height: 3),
// // // // // // // //                       const Text(
// // // // // // // //                         'BookIT!',
// // // // // // // //                         style: TextStyle(
// // // // // // // //                           fontSize: 36,
// // // // // // // //                           color: Colors.white,
// // // // // // // //                           fontWeight: FontWeight.bold,
// // // // // // // //                           letterSpacing: 1,
// // // // // // // //                         ),
// // // // // // // //                       ),
// // // // // // // //                     ],
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //
// // // // // // // //                 // Form Card Section
// // // // // // // //                 Container(
// // // // // // // //                   margin: const EdgeInsets.all(20),
// // // // // // // //                   decoration: BoxDecoration(
// // // // // // // //                     color: Colors.white,
// // // // // // // //                     borderRadius: BorderRadius.circular(16),
// // // // // // // //                     boxShadow: [
// // // // // // // //                       BoxShadow(
// // // // // // // //                         color: Colors.black.withOpacity(0.08),
// // // // // // // //                         blurRadius: 20,
// // // // // // // //                         offset: const Offset(0, 4),
// // // // // // // //                       ),
// // // // // // // //                     ],
// // // // // // // //                   ),
// // // // // // // //                   child: Padding(
// // // // // // // //                     padding: const EdgeInsets.all(24),
// // // // // // // //                     child: Form(
// // // // // // // //                       key: _formKey,
// // // // // // // //                       child: Column(
// // // // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                         children: [
// // // // // // // //                           // Info Section
// // // // // // // //                           Row(
// // // // // // // //                             children: [
// // // // // // // //                               Container(
// // // // // // // //                                 padding: const EdgeInsets.all(8),
// // // // // // // //                                 decoration: BoxDecoration(
// // // // // // // //                                   color: const Color(0xFF2196F3).withOpacity(0.1),
// // // // // // // //                                   borderRadius: BorderRadius.circular(8),
// // // // // // // //                                 ),
// // // // // // // //                                 child: const Icon(
// // // // // // // //                                   Icons.info_outline,
// // // // // // // //                                   size: 20,
// // // // // // // //                                   color: Color(0xFF2196F3),
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               const SizedBox(width: 12),
// // // // // // // //                               const Expanded(
// // // // // // // //                                 child: Text(
// // // // // // // //                                   'Enter Company Code',
// // // // // // // //                                   style: TextStyle(
// // // // // // // //                                     fontSize: 16,
// // // // // // // //                                     fontWeight: FontWeight.w600,
// // // // // // // //                                     color: Color(0xFF212121),
// // // // // // // //                                     letterSpacing: 0.3,
// // // // // // // //                                   ),
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                             ],
// // // // // // // //                           ),
// // // // // // // //                           const SizedBox(height: 16),
// // // // // // // //                           const Text(
// // // // // // // //                             'Please enter your company code to continue and access your account.',
// // // // // // // //                             style: TextStyle(
// // // // // // // //                               fontSize: 14,
// // // // // // // //                               color: Color(0xFF757575),
// // // // // // // //                               height: 1.5,
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                           const SizedBox(height: 32),
// // // // // // // //
// // // // // // // //                           // Company Code Label
// // // // // // // //                           const Text(
// // // // // // // //                             'Company Code',
// // // // // // // //                             style: TextStyle(
// // // // // // // //                               fontSize: 14,
// // // // // // // //                               fontWeight: FontWeight.w600,
// // // // // // // //                               color: Color(0xFF424242),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                           const SizedBox(height: 8),
// // // // // // // //
// // // // // // // //                           // Company Code Input Field
// // // // // // // //                           TextFormField(
// // // // // // // //                             controller: companyCodeController,
// // // // // // // //                             decoration: InputDecoration(
// // // // // // // //                               hintText: 'Enter your company code',
// // // // // // // //                               hintStyle: const TextStyle(
// // // // // // // //                                 color: Color(0xFF9E9E9E),
// // // // // // // //                                 fontSize: 14,
// // // // // // // //                               ),
// // // // // // // //                               prefixIcon: const Icon(
// // // // // // // //                                 Icons.vpn_key_rounded,
// // // // // // // //                                 color: Color(0xFF2196F3),
// // // // // // // //                                 size: 22,
// // // // // // // //                               ),
// // // // // // // //                               filled: true,
// // // // // // // //                               fillColor: const Color(0xFFF8F9FA),
// // // // // // // //                               contentPadding: const EdgeInsets.symmetric(
// // // // // // // //                                 vertical: 16,
// // // // // // // //                                 horizontal: 16,
// // // // // // // //                               ),
// // // // // // // //                               border: OutlineInputBorder(
// // // // // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 borderSide: const BorderSide(
// // // // // // // //                                   color: Color(0xFFE0E0E0),
// // // // // // // //                                   width: 1,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               enabledBorder: OutlineInputBorder(
// // // // // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 borderSide: const BorderSide(
// // // // // // // //                                   color: Color(0xFFE0E0E0),
// // // // // // // //                                   width: 1,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               focusedBorder: OutlineInputBorder(
// // // // // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 borderSide: const BorderSide(
// // // // // // // //                                   color: Color(0xFF2196F3),
// // // // // // // //                                   width: 2,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               errorBorder: OutlineInputBorder(
// // // // // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 borderSide: const BorderSide(
// // // // // // // //                                   color: Color(0xFFEF5350),
// // // // // // // //                                   width: 1,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               focusedErrorBorder: OutlineInputBorder(
// // // // // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 borderSide: const BorderSide(
// // // // // // // //                                   color: Color(0xFFEF5350),
// // // // // // // //                                   width: 2,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                             ),
// // // // // // // //                             style: const TextStyle(
// // // // // // // //                               fontSize: 16,
// // // // // // // //                               fontWeight: FontWeight.w500,
// // // // // // // //                               color: Color(0xFF212121),
// // // // // // // //                             ),
// // // // // // // //                             validator: (value) {
// // // // // // // //                               if (value == null || value.isEmpty) {
// // // // // // // //                                 return 'Please enter company code';
// // // // // // // //                               }
// // // // // // // //                               return null;
// // // // // // // //                             },
// // // // // // // //                           ),
// // // // // // // //
// // // // // // // //                           const SizedBox(height: 32),
// // // // // // // //
// // // // // // // //                           // Continue Button
// // // // // // // //                           SizedBox(
// // // // // // // //                             width: double.infinity,
// // // // // // // //                             height: 50,
// // // // // // // //                             child: ElevatedButton(
// // // // // // // //                               onPressed: isButtonDisabled
// // // // // // // //                                   ? null
// // // // // // // //                                   : () {
// // // // // // // //                                 if (_formKey.currentState!.validate()) {
// // // // // // // //                                   _saveCompanyDetails(
// // // // // // // //                                       companyCodeController.text.trim());
// // // // // // // //                                 }
// // // // // // // //                               },
// // // // // // // //                               style: ElevatedButton.styleFrom(
// // // // // // // //                                 backgroundColor: isButtonDisabled
// // // // // // // //                                     ? const Color(0xFFBDBDBD)
// // // // // // // //                                     : const Color(0xFF2196F3),
// // // // // // // //                                 foregroundColor: Colors.white,
// // // // // // // //                                 elevation: 0,
// // // // // // // //                                 shape: RoundedRectangleBorder(
// // // // // // // //                                   borderRadius: BorderRadius.circular(12),
// // // // // // // //                                 ),
// // // // // // // //                                 padding: const EdgeInsets.symmetric(vertical: 14),
// // // // // // // //                               ),
// // // // // // // //                               child: isLoading
// // // // // // // //                                   ? const SizedBox(
// // // // // // // //                                 height: 20,
// // // // // // // //                                 width: 20,
// // // // // // // //                                 child: CircularProgressIndicator(
// // // // // // // //                                   strokeWidth: 2,
// // // // // // // //                                   valueColor: AlwaysStoppedAnimation<Color>(
// // // // // // // //                                       Colors.white),
// // // // // // // //                                 ),
// // // // // // // //                               )
// // // // // // // //                                   : const Text(
// // // // // // // //                                 'Continue',
// // // // // // // //                                 style: TextStyle(
// // // // // // // //                                   fontSize: 16,
// // // // // // // //                                   fontWeight: FontWeight.w600,
// // // // // // // //                                   letterSpacing: 0.5,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //
// // // // // // // //                           const SizedBox(height: 16),
// // // // // // // //
// // // // // // // //                           // Help Text
// // // // // // // //                           // Center(
// // // // // // // //                           //   child: Text(
// // // // // // // //                           //     'Need help? Contact your administrator',
// // // // // // // //                           //     style: TextStyle(
// // // // // // // //                           //       fontSize: 12,
// // // // // // // //                           //       color: Colors.grey[600],
// // // // // // // //                           //     ),
// // // // // // // //                           //   ),
// // // // // // // //                           // ),
// // // // // // // //                         ],
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //
// // // // // // // //                 SizedBox(height: screenHeight * 0.05),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // //
// // // // // // // import 'dart:async';
// // // // // // // import 'dart:convert';
// // // // // // // import 'dart:io';
// // // // // // //
// // // // // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:get/get.dart';
// // // // // // // import 'package:http/http.dart' as http;
// // // // // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // // //
// // // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // // //
// // // // // // // class CodeScreen extends StatefulWidget {
// // // // // // //   const CodeScreen({super.key});
// // // // // // //
// // // // // // //   @override
// // // // // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // // // // }
// // // // // // //
// // // // // // // class _CodeScreenState extends State<CodeScreen> {
// // // // // // //   late final TextEditingController companyCodeController;
// // // // // // //   final _formKey = GlobalKey<FormState>();
// // // // // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // // // // //   bool isLoading = false;
// // // // // // //   bool isButtonDisabled = false;
// // // // // // //
// // // // // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // // // // //   bool isOffline = false;
// // // // // // //
// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     companyCodeController = TextEditingController();
// // // // // // //
// // // // // // //     // Listen to internet connectivity changes
// // // // // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // // // // //
// // // // // // //     connectivitySubscription =
// // // // // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // // // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // // // // //
// // // // // // //           if (result == ConnectivityResult.none) {
// // // // // // //             setState(() => isOffline = true);
// // // // // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // // // // //           } else {
// // // // // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // // // // //             if (!hasNet) {
// // // // // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // // // // //             } else if (isOffline) {
// // // // // // //               setState(() => isOffline = false);
// // // // // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // // // // //             }
// // // // // // //           }
// // // // // // //         });
// // // // // // //
// // // // // // //   }
// // // // // // //
// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     companyCodeController.dispose();
// // // // // // //     connectivitySubscription?.cancel();
// // // // // // //     super.dispose();
// // // // // // //   }
// // // // // // //
// // // // // // //   /// 🔹 Shows custom centered snackbar
// // // // // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // // // // //     final snackBar = SnackBar(
// // // // // // //       content: Center(
// // // // // // //         child: Text(
// // // // // // //           message,
// // // // // // //           style: const TextStyle(fontSize: 16),
// // // // // // //           textAlign: TextAlign.center,
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // // // // //       behavior: SnackBarBehavior.floating,
// // // // // // //       shape: RoundedRectangleBorder(
// // // // // // //         borderRadius: BorderRadius.circular(10),
// // // // // // //       ),
// // // // // // //       margin: EdgeInsets.only(
// // // // // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // // // // //         left: 20,
// // // // // // //         right: 20,
// // // // // // //       ),
// // // // // // //     );
// // // // // // //
// // // // // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // // // // //   }
// // // // // // //
// // // // // // //   /// 🔹 Check actual internet access — not just WiFi/mobile signal
// // // // // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // // // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // // // // //
// // // // // // //     // No connection at all
// // // // // // //     if (connectivityResult == ConnectivityResult.none) {
// // // // // // //       if (showSnack) {
// // // // // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // // // // //       }
// // // // // // //       return false;
// // // // // // //     }
// // // // // // //
// // // // // // //     // Check if actual connection works (ping)
// // // // // // //     try {
// // // // // // //       final result = await InternetAddress.lookup('google.com')
// // // // // // //           .timeout(const Duration(seconds: 5));
// // // // // // //
// // // // // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // // // // //         return true; // Internet is working
// // // // // // //       } else {
// // // // // // //         if (showSnack) {
// // // // // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // // // // //         }
// // // // // // //         return false;
// // // // // // //       }
// // // // // // //     } on SocketException {
// // // // // // //       if (showSnack) {
// // // // // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // // // // //       }
// // // // // // //       return false;
// // // // // // //     } on TimeoutException {
// // // // // // //       if (showSnack) {
// // // // // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // // // // //       }
// // // // // // //       return false;
// // // // // // //     } catch (e) {
// // // // // // //       if (showSnack) {
// // // // // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // // // // //       }
// // // // // // //       return false;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   /// 🔹 Save company details logic
// // // // // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // // // // //     _showCenteredSnackBar('Please wait...');
// // // // // // //     setState(() {
// // // // // // //       isLoading = true;
// // // // // // //       isButtonDisabled = true;
// // // // // // //     });
// // // // // // //
// // // // // // //     if (!await _hasInternet()) {
// // // // // // //       setState(() {
// // // // // // //         isLoading = false;
// // // // // // //         isButtonDisabled = false;
// // // // // // //       });
// // // // // // //       return;
// // // // // // //     }
// // // // // // //
// // // // // // //     try {
// // // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // // //       await prefs.reload();
// // // // // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // // // // //
// // // // // // //       await Config.fetchLatestConfig();
// // // // // // //
// // // // // // //       final response = await http
// // // // // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // // // // //           .timeout(const Duration(seconds: 30));
// // // // // // //
// // // // // // //       if (response.statusCode != 200) {
// // // // // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // // // // //         setState(() {
// // // // // // //           isLoading = false;
// // // // // // //           isButtonDisabled = false;
// // // // // // //         });
// // // // // // //         return;
// // // // // // //       }
// // // // // // //
// // // // // // //       final data = json.decode(response.body);
// // // // // // //       final items = data['items'] as List;
// // // // // // //       final company = items.firstWhere(
// // // // // // //             (item) => item['company_code'] == companyCode,
// // // // // // //         orElse: () => null,
// // // // // // //       );
// // // // // // //
// // // // // // //       if (company == null) {
// // // // // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // // // // //         setState(() {
// // // // // // //           isLoading = false;
// // // // // // //           isButtonDisabled = false;
// // // // // // //         });
// // // // // // //         return;
// // // // // // //       }
// // // // // // //
// // // // // // //       await prefs.setString('company_name', company['company_name']);
// // // // // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // // // // //       await prefs.setString('company_code', companyCode);
// // // // // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // // // // //
// // // // // // //       if (!isAuthenticated) {
// // // // // // //         try {
// // // // // // //           _showCenteredSnackBar('Setting up your account...');
// // // // // // //           await Config.fetchLatestConfig();
// // // // // // //           await Config.getApiUrlERPCompanyName;
// // // // // // //           companyName = await prefs.getString('company_name') ?? '';
// // // // // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // // // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // // // // //         } catch (e) {
// // // // // // //           debugPrint("Authentication error: $e");
// // // // // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // // // // //           setState(() {
// // // // // // //             isLoading = false;
// // // // // // //             isButtonDisabled = false;
// // // // // // //           });
// // // // // // //           return;
// // // // // // //         }
// // // // // // //       }
// // // // // // //
// // // // // // //       _showCenteredSnackBar('Setup complete!');
// // // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // // //         Get.offAll(() => const CameraScreen());
// // // // // // //       });
// // // // // // //     } on SocketException {
// // // // // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // // // // //     } on TimeoutException {
// // // // // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // // // // //     } on http.ClientException {
// // // // // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // // // // //     } catch (e) {
// // // // // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // // // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // // // // //     } finally {
// // // // // // //       setState(() {
// // // // // // //         isLoading = false;
// // // // // // //         isButtonDisabled = false;
// // // // // // //       });
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   /// 🔹 UI build
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       backgroundColor: Colors.white,
// // // // // // //       body: SafeArea(
// // // // // // //         child: Padding(
// // // // // // //           padding: const EdgeInsets.symmetric(horizontal: 32.0),
// // // // // // //           child: Column(
// // // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //             children: [
// // // // // // //               // Large centered icon with same style as CameraScreen
// // // // // // //               Container(
// // // // // // //                 padding: const EdgeInsets.all(32),
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.blue.withOpacity(0.08),
// // // // // // //                   shape: BoxShape.circle,
// // // // // // //                 ),
// // // // // // //                 child: const Icon(
// // // // // // //                   Icons.business_rounded,
// // // // // // //                   size: 50,
// // // // // // //                   color: Colors.blueAccent,
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //
// // // // // // //               const SizedBox(height: 25),
// // // // // // //
// // // // // // //               // Header
// // // // // // //               const Text(
// // // // // // //                 "BOOKIT",
// // // // // // //                 // "Enter Company Code",
// // // // // // //                 style: TextStyle(
// // // // // // //                   fontSize: 28,
// // // // // // //                   fontWeight: FontWeight.bold,
// // // // // // //                   color: Colors.black87,
// // // // // // //                 ),
// // // // // // //                 textAlign: TextAlign.center,
// // // // // // //               ),
// // // // // // //
// // // // // // //               const SizedBox(height: 16),
// // // // // // //
// // // // // // //               // Description
// // // // // // //               const Text(
// // // // // // //                 "Please enter your company code to continue and set up your account.",
// // // // // // //                 style: TextStyle(
// // // // // // //                   fontSize: 16,
// // // // // // //                   color: Colors.black54,
// // // // // // //                   height: 1.5,
// // // // // // //                 ),
// // // // // // //                 textAlign: TextAlign.center,
// // // // // // //               ),
// // // // // // //
// // // // // // //               const SizedBox(height: 32),
// // // // // // //
// // // // // // //               // Company Code Input Field
// // // // // // //               Form(
// // // // // // //                 key: _formKey,
// // // // // // //                 child: Column(
// // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                   children: [
// // // // // // //                     TextFormField(
// // // // // // //                       controller: companyCodeController,
// // // // // // //                       decoration: InputDecoration(
// // // // // // //                         hintText: 'Enter company code',
// // // // // // //                         filled: true,
// // // // // // //                         fillColor: Colors.grey.withOpacity(0.05),
// // // // // // //                         contentPadding: const EdgeInsets.symmetric(
// // // // // // //                           vertical: 18,
// // // // // // //                           horizontal: 20,
// // // // // // //                         ),
// // // // // // //                         border: OutlineInputBorder(
// // // // // // //                           borderRadius: BorderRadius.circular(16),
// // // // // // //                           borderSide: const BorderSide(
// // // // // // //                             color: Colors.blueAccent,
// // // // // // //                             width: 1.5,
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                         enabledBorder: OutlineInputBorder(
// // // // // // //                           borderRadius: BorderRadius.circular(16),
// // // // // // //                           borderSide: const BorderSide(
// // // // // // //                             color: Colors.blueAccent,
// // // // // // //                             width: 1.5,
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                         focusedBorder: OutlineInputBorder(
// // // // // // //                           borderRadius: BorderRadius.circular(16),
// // // // // // //                           borderSide: const BorderSide(
// // // // // // //                             color: Colors.blueAccent,
// // // // // // //                             width: 2,
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                         prefixIcon: const Icon(
// // // // // // //                           Icons.code_rounded,
// // // // // // //                           color: Colors.blueAccent,
// // // // // // //                         ),
// // // // // // //                       ),
// // // // // // //                       style: const TextStyle(
// // // // // // //                         fontSize: 16,
// // // // // // //                         color: Colors.black87,
// // // // // // //                       ),
// // // // // // //                       validator: (value) {
// // // // // // //                         if (value == null || value.isEmpty) {
// // // // // // //                           return 'Please enter company code';
// // // // // // //                         }
// // // // // // //                         return null;
// // // // // // //                       },
// // // // // // //                     ),
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //
// // // // // // //               const SizedBox(height: 64),
// // // // // // //
// // // // // // //               // Continue Button with same style as CameraScreen
// // // // // // //               SizedBox(
// // // // // // //                 width: double.infinity,
// // // // // // //                 height: 56,
// // // // // // //                 child: ElevatedButton(
// // // // // // //                   onPressed: isButtonDisabled
// // // // // // //                       ? null
// // // // // // //                       : () {
// // // // // // //                     if (_formKey.currentState!.validate()) {
// // // // // // //                       _saveCompanyDetails(companyCodeController.text.trim());
// // // // // // //                     }
// // // // // // //                   },
// // // // // // //                   style: ElevatedButton.styleFrom(
// // // // // // //                     backgroundColor: Colors.blueAccent,
// // // // // // //                     foregroundColor: Colors.white,
// // // // // // //                     disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
// // // // // // //                     shape: RoundedRectangleBorder(
// // // // // // //                       borderRadius: BorderRadius.circular(28),
// // // // // // //                     ),
// // // // // // //                     elevation: 2,
// // // // // // //                   ),
// // // // // // //                   child: isLoading
// // // // // // //                       ? const SizedBox(
// // // // // // //                     width: 24,
// // // // // // //                     height: 24,
// // // // // // //                     child: CircularProgressIndicator(
// // // // // // //                       color: Colors.white,
// // // // // // //                       strokeWidth: 3,
// // // // // // //                     ),
// // // // // // //                   )
// // // // // // //                       : const Text(
// // // // // // //                     "CONTINUE",
// // // // // // //                     style: TextStyle(
// // // // // // //                       fontSize: 18,
// // // // // // //                       fontWeight: FontWeight.w600,
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //
// // // // // // //               const SizedBox(height: 24),
// // // // // // //
// // // // // // //               // Help text
// // // // // // //               GestureDetector(
// // // // // // //                 onTap: () {
// // // // // // //                   Get.snackbar(
// // // // // // //                     "Help",
// // // // // // //                     "Contact your administrator for the company code",
// // // // // // //                     snackPosition: SnackPosition.BOTTOM,
// // // // // // //                     backgroundColor: Colors.blueAccent,
// // // // // // //                     colorText: Colors.white,
// // // // // // //                   );
// // // // // // //                 },
// // // // // // //                 child: const Text(
// // // // // // //                   "Need help?",
// // // // // // //                   style: TextStyle(
// // // // // // //                     fontSize: 16,
// // // // // // //                     color: Colors.blueAccent,
// // // // // // //                     fontWeight: FontWeight.w500,
// // // // // // //                     decoration: TextDecoration.underline,
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // // // // import 'dart:async';
// // // // // // import 'dart:convert';
// // // // // // import 'dart:io';
// // // // // //
// // // // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:get/get.dart';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // //
// // // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // // //
// // // // // // class CodeScreen extends StatefulWidget {
// // // // // //   const CodeScreen({super.key});
// // // // // //
// // // // // //   @override
// // // // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // // // }
// // // // // //
// // // // // // class _CodeScreenState extends State<CodeScreen> {
// // // // // //   late final TextEditingController companyCodeController;
// // // // // //   final _formKey = GlobalKey<FormState>();
// // // // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // // // //   bool isLoading = false;
// // // // // //   bool isButtonDisabled = false;
// // // // // //
// // // // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // // // //   bool isOffline = false;
// // // // // //
// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     companyCodeController = TextEditingController();
// // // // // //
// // // // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // // // //
// // // // // //     connectivitySubscription =
// // // // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // // // //
// // // // // //           if (result == ConnectivityResult.none) {
// // // // // //             setState(() => isOffline = true);
// // // // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // // // //           } else {
// // // // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // // // //             if (!hasNet) {
// // // // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // // // //             } else if (isOffline) {
// // // // // //               setState(() => isOffline = false);
// // // // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // // // //             }
// // // // // //           }
// // // // // //         });
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     companyCodeController.dispose();
// // // // // //     connectivitySubscription?.cancel();
// // // // // //     super.dispose();
// // // // // //   }
// // // // // //
// // // // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // // // //     final snackBar = SnackBar(
// // // // // //       content: Center(
// // // // // //         child: Text(
// // // // // //           message,
// // // // // //           style: const TextStyle(fontSize: 16),
// // // // // //           textAlign: TextAlign.center,
// // // // // //         ),
// // // // // //       ),
// // // // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // // // //       behavior: SnackBarBehavior.floating,
// // // // // //       shape: RoundedRectangleBorder(
// // // // // //         borderRadius: BorderRadius.circular(10),
// // // // // //       ),
// // // // // //       margin: EdgeInsets.only(
// // // // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // // // //         left: 20,
// // // // // //         right: 20,
// // // // // //       ),
// // // // // //     );
// // // // // //
// // // // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // // // //   }
// // // // // //
// // // // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // // // //
// // // // // //     if (connectivityResult == ConnectivityResult.none) {
// // // // // //       if (showSnack) {
// // // // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // // // //       }
// // // // // //       return false;
// // // // // //     }
// // // // // //
// // // // // //     try {
// // // // // //       final result = await InternetAddress.lookup('google.com')
// // // // // //           .timeout(const Duration(seconds: 5));
// // // // // //
// // // // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // // // //         return true;
// // // // // //       } else {
// // // // // //         if (showSnack) {
// // // // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // // // //         }
// // // // // //         return false;
// // // // // //       }
// // // // // //     } on SocketException {
// // // // // //       if (showSnack) {
// // // // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // // // //       }
// // // // // //       return false;
// // // // // //     } on TimeoutException {
// // // // // //       if (showSnack) {
// // // // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // // // //       }
// // // // // //       return false;
// // // // // //     } catch (e) {
// // // // // //       if (showSnack) {
// // // // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // // // //       }
// // // // // //       return false;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // // // //     _showCenteredSnackBar('Please wait...');
// // // // // //     setState(() {
// // // // // //       isLoading = true;
// // // // // //       isButtonDisabled = true;
// // // // // //     });
// // // // // //
// // // // // //     if (!await _hasInternet()) {
// // // // // //       setState(() {
// // // // // //         isLoading = false;
// // // // // //         isButtonDisabled = false;
// // // // // //       });
// // // // // //       return;
// // // // // //     }
// // // // // //
// // // // // //     try {
// // // // // //       final prefs = await SharedPreferences.getInstance();
// // // // // //       await prefs.reload();
// // // // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // // // //
// // // // // //       await Config.fetchLatestConfig();
// // // // // //
// // // // // //       final response = await http
// // // // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // // // //           .timeout(const Duration(seconds: 30));
// // // // // //
// // // // // //       if (response.statusCode != 200) {
// // // // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // // // //         setState(() {
// // // // // //           isLoading = false;
// // // // // //           isButtonDisabled = false;
// // // // // //         });
// // // // // //         return;
// // // // // //       }
// // // // // //
// // // // // //       final data = json.decode(response.body);
// // // // // //       final items = data['items'] as List;
// // // // // //       final company = items.firstWhere(
// // // // // //             (item) => item['company_code'] == companyCode,
// // // // // //         orElse: () => null,
// // // // // //       );
// // // // // //
// // // // // //       if (company == null) {
// // // // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // // // //         setState(() {
// // // // // //           isLoading = false;
// // // // // //           isButtonDisabled = false;
// // // // // //         });
// // // // // //         return;
// // // // // //       }
// // // // // //
// // // // // //       await prefs.setString('company_name', company['company_name']);
// // // // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // // // //       await prefs.setString('company_code', companyCode);
// // // // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // // // //
// // // // // //       if (!isAuthenticated) {
// // // // // //         try {
// // // // // //           _showCenteredSnackBar('Setting up your account...');
// // // // // //           await Config.fetchLatestConfig();
// // // // // //           await Config.getApiUrlERPCompanyName;
// // // // // //           companyName = await prefs.getString('company_name') ?? '';
// // // // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // // // //         } catch (e) {
// // // // // //           debugPrint("Authentication error: $e");
// // // // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // // // //           setState(() {
// // // // // //             isLoading = false;
// // // // // //             isButtonDisabled = false;
// // // // // //           });
// // // // // //           return;
// // // // // //         }
// // // // // //       }
// // // // // //
// // // // // //       _showCenteredSnackBar('Setup complete!');
// // // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //         Get.offAll(() => const CameraScreen());
// // // // // //       });
// // // // // //     } on SocketException {
// // // // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // // // //     } on TimeoutException {
// // // // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // // // //     } on http.ClientException {
// // // // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // // // //     } catch (e) {
// // // // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // // // //     } finally {
// // // // // //       setState(() {
// // // // // //         isLoading = false;
// // // // // //         isButtonDisabled = false;
// // // // // //       });
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     final Size size = MediaQuery.of(context).size;
// // // // // //
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: Colors.white,
// // // // // //       body: SafeArea(
// // // // // //         child: SingleChildScrollView(
// // // // // //           physics: const BouncingScrollPhysics(),
// // // // // //           child: Column(
// // // // // //             children: [
// // // // // //               // Top Decorative Section
// // // // // //               Container(
// // // // // //                 height: size.height * 0.35,
// // // // // //                 width: double.infinity,
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   gradient: LinearGradient(
// // // // // //                     colors: [
// // // // // //                       Colors.blueAccent.shade700,
// // // // // //                       Colors.blueAccent.shade400,
// // // // // //                       Colors.blueAccent.shade200,
// // // // // //                     ],
// // // // // //                     begin: Alignment.topCenter,
// // // // // //                     end: Alignment.bottomCenter,
// // // // // //                   ),
// // // // // //                   borderRadius: const BorderRadius.only(
// // // // // //                     bottomLeft: Radius.circular(40),
// // // // // //                     bottomRight: Radius.circular(40),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 child: Stack(
// // // // // //                   children: [
// // // // // //                     // Background Pattern
// // // // // //                     Positioned(
// // // // // //                       top: 30,
// // // // // //                       right: 30,
// // // // // //                       child: Icon(
// // // // // //                         Icons.circle,
// // // // // //                         size: 80,
// // // // // //                         color: Colors.white.withOpacity(0.1),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                     Positioned(
// // // // // //                       bottom: 50,
// // // // // //                       left: 40,
// // // // // //                       child: Icon(
// // // // // //                         Icons.square,
// // // // // //                         size: 60,
// // // // // //                         color: Colors.white.withOpacity(0.1),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //
// // // // // //                     // Main Content
// // // // // //                     Center(
// // // // // //                       child: Column(
// // // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                         children: [
// // // // // //                           // App Logo
// // // // // //                           Container(
// // // // // //                             padding: const EdgeInsets.all(20),
// // // // // //                             decoration: BoxDecoration(
// // // // // //                               color: Colors.white,
// // // // // //                               borderRadius: BorderRadius.circular(25),
// // // // // //                               boxShadow: [
// // // // // //                                 BoxShadow(
// // // // // //                                   color: Colors.blueAccent.withOpacity(0.3),
// // // // // //                                   blurRadius: 20,
// // // // // //                                   spreadRadius: 5,
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             ),
// // // // // //                             child: const Icon(
// // // // // //                               Icons.business_center_rounded,
// // // // // //                               size: 60,
// // // // // //                               color: Colors.blueAccent,
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                           const SizedBox(height: 25),
// // // // // //
// // // // // //                           // App Name
// // // // // //                           const Text(
// // // // // //                             'BOOKIT',
// // // // // //                             style: TextStyle(
// // // // // //                               fontSize: 42,
// // // // // //                               fontWeight: FontWeight.w900,
// // // // // //                               color: Colors.white,
// // // // // //                               letterSpacing: 2,
// // // // // //                               shadows: [
// // // // // //                                 Shadow(
// // // // // //                                   blurRadius: 10,
// // // // // //                                   color: Colors.black26,
// // // // // //                                   offset: Offset(2, 2),
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             ),
// // // // // //                           ),
// // // // // //
// // // // // //                           const SizedBox(height: 8),
// // // // // //
// // // // // //                           // Tagline
// // // // // //                           const Text(
// // // // // //                             'Enterprise Order Management',
// // // // // //                             style: TextStyle(
// // // // // //                               fontSize: 16,
// // // // // //                               color: Colors.white,
// // // // // //                               fontWeight: FontWeight.w500,
// // // // // //                               letterSpacing: 0.5,
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),
// // // // // //
// // // // // //               // Main Form Section
// // // // // //               Padding(
// // // // // //                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
// // // // // //                 child: Column(
// // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                   children: [
// // // // // //                     // Welcome Text
// // // // // //                     const Text(
// // // // // //                       'Welcome to BookIT',
// // // // // //                       style: TextStyle(
// // // // // //                         fontSize: 28,
// // // // // //                         fontWeight: FontWeight.w800,
// // // // // //                         color: Colors.black87,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //
// // // // // //                     const SizedBox(height: 8),
// // // // // //
// // // // // //                     // Instruction Text
// // // // // //                     Text(
// // // // // //                       'Enter your company code to access the platform and manage orders efficiently.',
// // // // // //                       style: TextStyle(
// // // // // //                         fontSize: 16,
// // // // // //                         color: Colors.grey.shade600,
// // // // // //                         height: 1.6,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //
// // // // // //                     const SizedBox(height: 40),
// // // // // //
// // // // // //                     // Company Code Input Card
// // // // // //                     Container(
// // // // // //                       decoration: BoxDecoration(
// // // // // //                         color: Colors.white,
// // // // // //                         borderRadius: BorderRadius.circular(20),
// // // // // //                         boxShadow: [
// // // // // //                           BoxShadow(
// // // // // //                             color: Colors.grey.withOpacity(0.15),
// // // // // //                             blurRadius: 25,
// // // // // //                             spreadRadius: 2,
// // // // // //                             offset: const Offset(0, 10),
// // // // // //                           ),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                       padding: const EdgeInsets.all(5),
// // // // // //                       child: Form(
// // // // // //                         key: _formKey,
// // // // // //                         child: Column(
// // // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                           children: [
// // // // // //                             // Input Label
// // // // // //                             Row(
// // // // // //                               children: [
// // // // // //                                 Text(
// // // // // //                                   'COMPANY ACCESS CODE',
// // // // // //                                   style: TextStyle(
// // // // // //                                     fontSize: 14,
// // // // // //                                     fontWeight: FontWeight.w700,
// // // // // //                                     color: Colors.grey.shade700,
// // // // // //                                     letterSpacing: 1.2,
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             ),
// // // // // //
// // // // // //                             const SizedBox(height: 20),
// // // // // //
// // // // // //                             // Input Field
// // // // // //                             TextFormField(
// // // // // //                               controller: companyCodeController,
// // // // // //                               decoration: InputDecoration(
// // // // // //                                 hintText: 'Enter Company Code',
// // // // // //                                 hintStyle: TextStyle(
// // // // // //                                   color: Colors.grey.shade400,
// // // // // //                                   fontSize: 16,
// // // // // //                                 ),
// // // // // //                                 filled: true,
// // // // // //                                 fillColor: Colors.grey.shade50,
// // // // // //                                 contentPadding: const EdgeInsets.symmetric(
// // // // // //                                   vertical: 22,
// // // // // //                                   horizontal: 20,
// // // // // //                                 ),
// // // // // //                                 border: OutlineInputBorder(
// // // // // //                                   borderRadius: BorderRadius.circular(15),
// // // // // //                                   borderSide: BorderSide.none,
// // // // // //                                 ),
// // // // // //                                 enabledBorder: OutlineInputBorder(
// // // // // //                                   borderRadius: BorderRadius.circular(15),
// // // // // //                                   borderSide: BorderSide(
// // // // // //                                     color: Colors.grey.shade200,
// // // // // //                                     width: 1.5,
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                                 focusedBorder: OutlineInputBorder(
// // // // // //                                   borderRadius: BorderRadius.circular(15),
// // // // // //                                   borderSide: const BorderSide(
// // // // // //                                     color: Colors.blueAccent,
// // // // // //                                     width: 2.0,
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                                 errorStyle: TextStyle(
// // // // // //                                   fontSize: 13,
// // // // // //                                   fontWeight: FontWeight.w500,
// // // // // //                                   color: Colors.red.shade600,
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               style: const TextStyle(
// // // // // //                                 fontSize: 17,
// // // // // //                                 fontWeight: FontWeight.w600,
// // // // // //                                 color: Colors.black87,
// // // // // //                                 letterSpacing: 1.2,
// // // // // //                               ),
// // // // // //                               textCapitalization: TextCapitalization.characters,
// // // // // //                               validator: (value) {
// // // // // //                                 if (value == null || value.isEmpty) {
// // // // // //                                   return 'Please enter your company code';
// // // // // //                                 }
// // // // // //                                 return null;
// // // // // //                               },
// // // // // //                             ),
// // // // // //
// // // // // //                             const SizedBox(height: 25),
// // // // // //                           ],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //
// // // // // //                     const SizedBox(height: 20),
// // // // // //
// // // // // //                     // Continue Button
// // // // // //                     SizedBox(
// // // // // //                       width: double.infinity,
// // // // // //                       height: 60,
// // // // // //                       child: ElevatedButton(
// // // // // //                         onPressed: isButtonDisabled
// // // // // //                             ? null
// // // // // //                             : () {
// // // // // //                           if (_formKey.currentState!.validate()) {
// // // // // //                             _saveCompanyDetails(companyCodeController.text.trim());
// // // // // //                           }
// // // // // //                         },
// // // // // //                         style: ElevatedButton.styleFrom(
// // // // // //                           backgroundColor: Colors.blueAccent,
// // // // // //                           foregroundColor: Colors.white,
// // // // // //                           disabledBackgroundColor: Colors.blueAccent.withOpacity(0.4),
// // // // // //                           shape: RoundedRectangleBorder(
// // // // // //                             borderRadius: BorderRadius.circular(15),
// // // // // //                           ),
// // // // // //                           elevation: 5,
// // // // // //                           shadowColor: Colors.blueAccent.withOpacity(0.4),
// // // // // //                           padding: const EdgeInsets.symmetric(vertical: 18),
// // // // // //                         ),
// // // // // //                         child: isLoading
// // // // // //                             ? Row(
// // // // // //                           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                           children: [
// // // // // //                             const SizedBox(
// // // // // //                               width: 22,
// // // // // //                               height: 22,
// // // // // //                               child: CircularProgressIndicator(
// // // // // //                                 color: Colors.white,
// // // // // //                                 strokeWidth: 3,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                             const SizedBox(width: 15),
// // // // // //                             Text(
// // // // // //                               'VERIFYING ACCESS...',
// // // // // //                               style: TextStyle(
// // // // // //                                 fontSize: 16,
// // // // // //                                 fontWeight: FontWeight.w700,
// // // // // //                                 letterSpacing: 0.8,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                           ],
// // // // // //                         )
// // // // // //                             : Row(
// // // // // //                           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                           children: [
// // // // // //                             Text(
// // // // // //                               'CONTINUE',
// // // // // //                               style: TextStyle(
// // // // // //                                 fontSize: 16,
// // // // // //                                 fontWeight: FontWeight.w700,
// // // // // //                                 letterSpacing: 1.0,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                             const SizedBox(width: 12),
// // // // // //                             const Icon(
// // // // // //                               Icons.arrow_forward_rounded,
// // // // // //                               size: 22,
// // // // // //                             ),
// // // // // //                           ],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //
// // // // // //                     const SizedBox(height: 25),
// // // // // //
// // // // // //                     // Footer Links
// // // // // //                     Row(
// // // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                       children: [
// // // // // //                         GestureDetector(
// // // // // //                           onTap: () {
// // // // // //                             Get.snackbar(
// // // // // //                               "Contact Support",
// // // // // //                               "Email: support@bookit.com\nPhone: +1-234-567-8900",
// // // // // //                               snackPosition: SnackPosition.BOTTOM,
// // // // // //                               backgroundColor: Colors.blueAccent,
// // // // // //                               colorText: Colors.white,
// // // // // //                               duration: const Duration(seconds: 4),
// // // // // //                             );
// // // // // //                           },
// // // // // //                           child: Container(
// // // // // //                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// // // // // //                             decoration: BoxDecoration(
// // // // // //                               color: Colors.grey.shade100,
// // // // // //                               borderRadius: BorderRadius.circular(10),
// // // // // //                             ),
// // // // // //                             child: Row(
// // // // // //                               children: [
// // // // // //                                 Icon(
// // // // // //                                   Icons.support_agent_rounded,
// // // // // //                                   color: Colors.blueAccent,
// // // // // //                                   size: 18,
// // // // // //                                 ),
// // // // // //                                 const SizedBox(width: 8),
// // // // // //                                 Text(
// // // // // //                                   "Get Help",
// // // // // //                                   style: TextStyle(
// // // // // //                                     fontSize: 14,
// // // // // //                                     fontWeight: FontWeight.w600,
// // // // // //                                     color: Colors.blueAccent,
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         const SizedBox(width: 15),
// // // // // //                         GestureDetector(
// // // // // //                           onTap: () {
// // // // // //                             Get.snackbar(
// // // // // //                               "About BookIT",
// // // // // //                               "Enterprise Order Management Platform\nVersion 2.1.0",
// // // // // //                               snackPosition: SnackPosition.BOTTOM,
// // // // // //                               backgroundColor: Colors.grey.shade800,
// // // // // //                               colorText: Colors.white,
// // // // // //                             );
// // // // // //                           },
// // // // // //                           child: Container(
// // // // // //                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// // // // // //                             decoration: BoxDecoration(
// // // // // //                               color: Colors.grey.shade100,
// // // // // //                               borderRadius: BorderRadius.circular(10),
// // // // // //                             ),
// // // // // //                             child: Row(
// // // // // //                               children: [
// // // // // //                                 Icon(
// // // // // //                                   Icons.info_outline_rounded,
// // // // // //                                   color: Colors.grey.shade700,
// // // // // //                                   size: 18,
// // // // // //                                 ),
// // // // // //                                 const SizedBox(width: 8),
// // // // // //                                 Text(
// // // // // //                                   "About",
// // // // // //                                   style: TextStyle(
// // // // // //                                     fontSize: 14,
// // // // // //                                     fontWeight: FontWeight.w600,
// // // // // //                                     color: Colors.grey.shade700,
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // //
// // // // // import 'dart:async';
// // // // // import 'dart:convert';
// // // // // import 'dart:io';
// // // // //
// // // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:get/get.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // //
// // // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // // //
// // // // // class CodeScreen extends StatefulWidget {
// // // // //   const CodeScreen({super.key});
// // // // //
// // // // //   @override
// // // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // // }
// // // // //
// // // // // class _CodeScreenState extends State<CodeScreen> {
// // // // //   late final TextEditingController companyCodeController;
// // // // //   final _formKey = GlobalKey<FormState>();
// // // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // // //   bool isLoading = false;
// // // // //   bool isButtonDisabled = false;
// // // // //
// // // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // // //   bool isOffline = false;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     companyCodeController = TextEditingController();
// // // // //
// // // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // // //
// // // // //     connectivitySubscription =
// // // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // // //
// // // // //           if (result == ConnectivityResult.none) {
// // // // //             setState(() => isOffline = true);
// // // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // // //           } else {
// // // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // // //             if (!hasNet) {
// // // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // // //             } else if (isOffline) {
// // // // //               setState(() => isOffline = false);
// // // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // // //             }
// // // // //           }
// // // // //         });
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   void dispose() {
// // // // //     companyCodeController.dispose();
// // // // //     connectivitySubscription?.cancel();
// // // // //     super.dispose();
// // // // //   }
// // // // //
// // // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // // //     final snackBar = SnackBar(
// // // // //       content: Center(
// // // // //         child: Text(
// // // // //           message,
// // // // //           style: const TextStyle(fontSize: 16),
// // // // //           textAlign: TextAlign.center,
// // // // //         ),
// // // // //       ),
// // // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // // //       behavior: SnackBarBehavior.floating,
// // // // //       shape: RoundedRectangleBorder(
// // // // //         borderRadius: BorderRadius.circular(10),
// // // // //       ),
// // // // //       margin: EdgeInsets.only(
// // // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // // //         left: 20,
// // // // //         right: 20,
// // // // //       ),
// // // // //     );
// // // // //
// // // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // // //   }
// // // // //
// // // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // // //
// // // // //     if (connectivityResult == ConnectivityResult.none) {
// // // // //       if (showSnack) {
// // // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // // //       }
// // // // //       return false;
// // // // //     }
// // // // //
// // // // //     try {
// // // // //       final result = await InternetAddress.lookup('google.com')
// // // // //           .timeout(const Duration(seconds: 5));
// // // // //
// // // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // // //         return true;
// // // // //       } else {
// // // // //         if (showSnack) {
// // // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // // //         }
// // // // //         return false;
// // // // //       }
// // // // //     } on SocketException {
// // // // //       if (showSnack) {
// // // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // // //       }
// // // // //       return false;
// // // // //     } on TimeoutException {
// // // // //       if (showSnack) {
// // // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // // //       }
// // // // //       return false;
// // // // //     } catch (e) {
// // // // //       if (showSnack) {
// // // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // // //       }
// // // // //       return false;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // // //     _showCenteredSnackBar('Please wait...');
// // // // //     setState(() {
// // // // //       isLoading = true;
// // // // //       isButtonDisabled = true;
// // // // //     });
// // // // //
// // // // //     if (!await _hasInternet()) {
// // // // //       setState(() {
// // // // //         isLoading = false;
// // // // //         isButtonDisabled = false;
// // // // //       });
// // // // //       return;
// // // // //     }
// // // // //
// // // // //     try {
// // // // //       final prefs = await SharedPreferences.getInstance();
// // // // //       await prefs.reload();
// // // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // // //
// // // // //       await Config.fetchLatestConfig();
// // // // //
// // // // //       final response = await http
// // // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // // //           .timeout(const Duration(seconds: 30));
// // // // //
// // // // //       if (response.statusCode != 200) {
// // // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // // //         setState(() {
// // // // //           isLoading = false;
// // // // //           isButtonDisabled = false;
// // // // //         });
// // // // //         return;
// // // // //       }
// // // // //
// // // // //       final data = json.decode(response.body);
// // // // //       final items = data['items'] as List;
// // // // //       final company = items.firstWhere(
// // // // //             (item) => item['company_code'] == companyCode,
// // // // //         orElse: () => null,
// // // // //       );
// // // // //
// // // // //       if (company == null) {
// // // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // // //         setState(() {
// // // // //           isLoading = false;
// // // // //           isButtonDisabled = false;
// // // // //         });
// // // // //         return;
// // // // //       }
// // // // //
// // // // //       await prefs.setString('company_name', company['company_name']);
// // // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // // //       await prefs.setString('company_code', companyCode);
// // // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // // //
// // // // //       if (!isAuthenticated) {
// // // // //         try {
// // // // //           _showCenteredSnackBar('Setting up your account...');
// // // // //           await Config.fetchLatestConfig();
// // // // //           await Config.getApiUrlERPCompanyName;
// // // // //           companyName = await prefs.getString('company_name') ?? '';
// // // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // // //         } catch (e) {
// // // // //           debugPrint("Authentication error: $e");
// // // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // // //           setState(() {
// // // // //             isLoading = false;
// // // // //             isButtonDisabled = false;
// // // // //           });
// // // // //           return;
// // // // //         }
// // // // //       }
// // // // //
// // // // //       _showCenteredSnackBar('Setup complete!');
// // // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //         Get.offAll(() => const CameraScreen());
// // // // //       });
// // // // //     } on SocketException {
// // // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // // //     } on TimeoutException {
// // // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // // //     } on http.ClientException {
// // // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // // //     } catch (e) {
// // // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // // //     } finally {
// // // // //       setState(() {
// // // // //         isLoading = false;
// // // // //         isButtonDisabled = false;
// // // // //       });
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final Size size = MediaQuery.of(context).size;
// // // // //
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.white,
// // // // //       body: SafeArea(
// // // // //         child: SingleChildScrollView(
// // // // //           physics: const BouncingScrollPhysics(),
// // // // //           child: ConstrainedBox(
// // // // //             constraints: BoxConstraints(
// // // // //               minHeight: size.height,
// // // // //             ),
// // // // //             child: Column(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //               children: [
// // // // //                 // Top Section
// // // // //                 Column(
// // // // //                   children: [
// // // // //                     Container(
// // // // //                       height: size.height * 0.28,
// // // // //                       width: double.infinity,
// // // // //                       decoration: BoxDecoration(
// // // // //                         gradient: LinearGradient(
// // // // //                           colors: [
// // // // //                             Colors.blueAccent.shade700,
// // // // //                             Colors.blueAccent.shade400,
// // // // //                           ],
// // // // //                           begin: Alignment.topCenter,
// // // // //                           end: Alignment.bottomCenter,
// // // // //                         ),
// // // // //                         borderRadius: const BorderRadius.only(
// // // // //                           bottomLeft: Radius.circular(30),
// // // // //                           bottomRight: Radius.circular(30),
// // // // //                         ),
// // // // //                       ),
// // // // //                       child: Column(
// // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // //                         children: [
// // // // //                           Container(
// // // // //                             padding: const EdgeInsets.all(18),
// // // // //                             decoration: BoxDecoration(
// // // // //                               color: Colors.white,
// // // // //                               borderRadius: BorderRadius.circular(22),
// // // // //                               boxShadow: [
// // // // //                                 BoxShadow(
// // // // //                                   color: Colors.blueAccent.withOpacity(0.2),
// // // // //                                   blurRadius: 15,
// // // // //                                   spreadRadius: 3,
// // // // //                                 ),
// // // // //                               ],
// // // // //                             ),
// // // // //                             child: const Icon(
// // // // //                               Icons.business_center_rounded,
// // // // //                               size: 50,
// // // // //                               color: Colors.blueAccent,
// // // // //                             ),
// // // // //                           ),
// // // // //                           const SizedBox(height: 20),
// // // // //                           const Text(
// // // // //                             'BOOKIT',
// // // // //                             style: TextStyle(
// // // // //                               fontSize: 36,
// // // // //                               fontWeight: FontWeight.w800,
// // // // //                               color: Colors.white,
// // // // //                               letterSpacing: 1.5,
// // // // //                             ),
// // // // //                           ),
// // // // //                           const SizedBox(height: 3),
// // // // //                           Text(
// // // // //                             'Order Management System',
// // // // //                             style: TextStyle(
// // // // //                               fontSize: 14,
// // // // //                               color: Colors.white.withOpacity(0.9),
// // // // //                               fontWeight: FontWeight.w500,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //
// // // // //                     const SizedBox(height: 30),
// // // // //
// // // // //                     // Welcome Text
// // // // //                     Padding(
// // // // //                       padding: const EdgeInsets.symmetric(horizontal: 30),
// // // // //                       child: Column(
// // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                         children: [
// // // // //                           Text(
// // // // //                             'Enter Company Code',
// // // // //                             style: TextStyle(
// // // // //                               fontSize: 22,
// // // // //                               fontWeight: FontWeight.w700,
// // // // //                               color: Colors.grey.shade800,
// // // // //                             ),
// // // // //                           ),
// // // // //                           const SizedBox(height: 8),
// // // // //                           Text(
// // // // //                             'Please enter your unique company access code to continue',
// // // // //                             style: TextStyle(
// // // // //                               fontSize: 15,
// // // // //                               color: Colors.grey.shade600,
// // // // //                               height: 1.4,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //
// // // // //                     const SizedBox(height: 30),
// // // // //
// // // // //                     // Input Field
// // // // //                     Padding(
// // // // //                       padding: const EdgeInsets.symmetric(horizontal: 30),
// // // // //                       child: Form(
// // // // //                         key: _formKey,
// // // // //                         child: Column(
// // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                           children: [
// // // // //                             Text(
// // // // //                               'Company Code',
// // // // //                               style: TextStyle(
// // // // //                                 fontSize: 14,
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 color: Colors.grey.shade700,
// // // // //                               ),
// // // // //                             ),
// // // // //                             const SizedBox(height: 10),
// // // // //                             Container(
// // // // //                               decoration: BoxDecoration(
// // // // //                                 borderRadius: BorderRadius.circular(12),
// // // // //                                 boxShadow: [
// // // // //                                   BoxShadow(
// // // // //                                     color: Colors.grey.withOpacity(0.1),
// // // // //                                     blurRadius: 10,
// // // // //                                     offset: const Offset(0, 4),
// // // // //                                   ),
// // // // //                                 ],
// // // // //                               ),
// // // // //                               child: TextFormField(
// // // // //                                 controller: companyCodeController,
// // // // //                                 decoration: InputDecoration(
// // // // //                                   hintText: 'Enter code here',
// // // // //                                   hintStyle: TextStyle(
// // // // //                                     color: Colors.grey.shade400,
// // // // //                                     fontSize: 16,
// // // // //                                   ),
// // // // //                                   filled: true,
// // // // //                                   fillColor: Colors.white,
// // // // //                                   contentPadding: const EdgeInsets.symmetric(
// // // // //                                     vertical: 18,
// // // // //                                     horizontal: 18,
// // // // //                                   ),
// // // // //                                   border: OutlineInputBorder(
// // // // //                                     borderRadius: BorderRadius.circular(12),
// // // // //                                     borderSide: BorderSide.none,
// // // // //                                   ),
// // // // //                                   enabledBorder: OutlineInputBorder(
// // // // //                                     borderRadius: BorderRadius.circular(12),
// // // // //                                     borderSide: BorderSide(
// // // // //                                       color: Colors.grey.shade300,
// // // // //                                       width: 1.5,
// // // // //                                     ),
// // // // //                                   ),
// // // // //                                   focusedBorder: OutlineInputBorder(
// // // // //                                     borderRadius: BorderRadius.circular(12),
// // // // //                                     borderSide: const BorderSide(
// // // // //                                       color: Colors.blueAccent,
// // // // //                                       width: 2.0,
// // // // //                                     ),
// // // // //                                   ),
// // // // //                                   // prefixIcon: Icon(
// // // // //                                   //   Icons.business_rounded,
// // // // //                                   //   color: Colors.blueAccent,
// // // // //                                   //   size: 22,
// // // // //                                   // ),
// // // // //                                   errorStyle: TextStyle(
// // // // //                                     fontSize: 13,
// // // // //                                     fontWeight: FontWeight.w500,
// // // // //                                     color: Colors.red.shade600,
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 style: const TextStyle(
// // // // //                                   fontSize: 16,
// // // // //                                   fontWeight: FontWeight.w500,
// // // // //                                   color: Colors.black87,
// // // // //                                 ),
// // // // //                                 textCapitalization: TextCapitalization.characters,
// // // // //                                 validator: (value) {
// // // // //                                   if (value == null || value.isEmpty) {
// // // // //                                     return 'Please enter company code';
// // // // //                                   }
// // // // //                                   return null;
// // // // //                                 },
// // // // //                               ),
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //
// // // // //                 // Bottom Section with Button
// // // // //                 Padding(
// // // // //                   padding: const EdgeInsets.only(
// // // // //                     left: 30,
// // // // //                     right: 30,
// // // // //                     bottom: 100,
// // // // //                     top: 30,
// // // // //                   ),
// // // // //                   child: Column(
// // // // //                     children: [
// // // // //                       // Continue Button
// // // // //                       SizedBox(
// // // // //                         width: double.infinity,
// // // // //                         height: 54,
// // // // //                         child: ElevatedButton(
// // // // //                           onPressed: isButtonDisabled
// // // // //                               ? null
// // // // //                               : () {
// // // // //                             if (_formKey.currentState!.validate()) {
// // // // //                               _saveCompanyDetails(
// // // // //                                   companyCodeController.text.trim());
// // // // //                             }
// // // // //                           },
// // // // //                           style: ElevatedButton.styleFrom(
// // // // //                             backgroundColor: Colors.blueAccent,
// // // // //                             foregroundColor: Colors.white,
// // // // //                             shape: RoundedRectangleBorder(
// // // // //                               borderRadius: BorderRadius.circular(28),
// // // // //                             ),
// // // // //                             elevation: 2,
// // // // //                           ),
// // // // //                           // style: ElevatedButton.styleFrom(
// // // // //                           //   backgroundColor: Colors.blueAccent,
// // // // //                           //   foregroundColor: Colors.white,
// // // // //                           //   disabledBackgroundColor:
// // // // //                           //   Colors.blueAccent.withOpacity(0.4),
// // // // //                           //   shape: RoundedRectangleBorder(
// // // // //                           //     borderRadius: BorderRadius.circular(12),
// // // // //                           //   ),
// // // // //                           //   elevation: 4,
// // // // //                           //   shadowColor: Colors.blueAccent.withOpacity(0.3),
// // // // //                           // ),
// // // // //                           child: isLoading
// // // // //                               ? Row(
// // // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // // //                             children: [
// // // // //                               const SizedBox(
// // // // //                                 width: 20,
// // // // //                                 height: 20,
// // // // //                                 child: CircularProgressIndicator(
// // // // //                                   color: Colors.white,
// // // // //                                   strokeWidth: 2.5,
// // // // //                                 ),
// // // // //                               ),
// // // // //                               const SizedBox(width: 12),
// // // // //                               Text(
// // // // //                                 'VERIFYING...',
// // // // //                                 style: TextStyle(
// // // // //                                   fontSize: 15,
// // // // //                                   fontWeight: FontWeight.w600,
// // // // //                                 ),
// // // // //                               ),
// // // // //                             ],
// // // // //                           )
// // // // //                               : Row(
// // // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // // //                             children: [
// // // // //                               Text(
// // // // //                                 'CONTINUE',
// // // // //                                 style: TextStyle(
// // // // //                                   fontSize: 15,
// // // // //                                   fontWeight: FontWeight.w600,
// // // // //                                 ),
// // // // //                               ),
// // // // //                               const SizedBox(width: 10),
// // // // //                               const Icon(
// // // // //                                 Icons.arrow_forward_rounded,
// // // // //                                 size: 20,
// // // // //                               ),
// // // // //                             ],
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //
// // // // //                       const SizedBox(height: 25),
// // // // //
// // // // //                       // Help Section
// // // // //                       Row(
// // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // //                         children: [
// // // // //                           GestureDetector(
// // // // //                             onTap: () {
// // // // //                               Get.snackbar(
// // // // //                                 "Need Help?",
// // // // //                                 "Contact your administrator for assistance",
// // // // //                                 snackPosition: SnackPosition.BOTTOM,
// // // // //                                 backgroundColor: Colors.blueAccent,
// // // // //                                 colorText: Colors.white,
// // // // //                                 duration: const Duration(seconds: 3),
// // // // //                               );
// // // // //                             },
// // // // //                             child: Row(
// // // // //                               children: [
// // // // //                                 Icon(
// // // // //                                   Icons.help_outline_rounded,
// // // // //                                   color: Colors.blueAccent,
// // // // //                                   size: 18,
// // // // //                                 ),
// // // // //                                 const SizedBox(width: 6),
// // // // //                                 Text(
// // // // //                                   "Need Help?",
// // // // //                                   style: TextStyle(
// // // // //                                     fontSize: 14,
// // // // //                                     color: Colors.blueAccent,
// // // // //                                     fontWeight: FontWeight.w500,
// // // // //                                   ),
// // // // //                                 ),
// // // // //                               ],
// // // // //                             ),
// // // // //                           ),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // //
// // // //
// // // // import 'dart:async';
// // // // import 'dart:convert';
// // // // import 'dart:io';
// // // //
// // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:order_booking_app/Databases/util.dart';
// // // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // //
// // // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // // //
// // // // class CodeScreen extends StatefulWidget {
// // // //   const CodeScreen({super.key});
// // // //
// // // //   @override
// // // //   State<CodeScreen> createState() => _CodeScreenState();
// // // // }
// // // //
// // // // class _CodeScreenState extends State<CodeScreen> {
// // // //   late final TextEditingController companyCodeController;
// // // //   final _formKey = GlobalKey<FormState>();
// // // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // // //   bool isLoading = false;
// // // //   bool isButtonDisabled = false;
// // // //
// // // //   StreamSubscription<ConnectivityResult>? connectivitySubscription;
// // // //   bool isOffline = false;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     companyCodeController = TextEditingController();
// // // //
// // // //     // Listen to internet connectivity changes
// // // //     StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
// // // //
// // // //     connectivitySubscription =
// // // //         Connectivity().onConnectivityChanged.listen((results) async {
// // // //           final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
// // // //
// // // //           if (result == ConnectivityResult.none) {
// // // //             setState(() => isOffline = true);
// // // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // // //           } else {
// // // //             bool hasNet = await _hasInternet(showSnack: false);
// // // //             if (!hasNet) {
// // // //               _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // // //             } else if (isOffline) {
// // // //               setState(() => isOffline = false);
// // // //               _showCenteredSnackBar('Back online! You can continue.');
// // // //             }
// // // //           }
// // // //         });
// // // //
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     companyCodeController.dispose();
// // // //     connectivitySubscription?.cancel();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   /// 🔹 Shows custom centered snackbar
// // // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // // //     final snackBar = SnackBar(
// // // //       content: Center(
// // // //         child: Text(
// // // //           message,
// // // //           style: const TextStyle(fontSize: 16),
// // // //           textAlign: TextAlign.center,
// // // //         ),
// // // //       ),
// // // //       backgroundColor: isError ? Colors.red : Colors.green,
// // // //       behavior: SnackBarBehavior.floating,
// // // //       shape: RoundedRectangleBorder(
// // // //         borderRadius: BorderRadius.circular(10),
// // // //       ),
// // // //       margin: EdgeInsets.only(
// // // //         bottom: MediaQuery.of(context).size.height * 0.4,
// // // //         left: 20,
// // // //         right: 20,
// // // //       ),
// // // //     );
// // // //
// // // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // // //   }
// // // //
// // // //   /// 🔹 Check actual internet access — not just WiFi/mobile signal
// // // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // // //     var connectivityResult = await Connectivity().checkConnectivity();
// // // //
// // // //     // No connection at all
// // // //     if (connectivityResult == ConnectivityResult.none) {
// // // //       if (showSnack) {
// // // //         _showCenteredSnackBar('No internet connection detected.', isError: true);
// // // //       }
// // // //       return false;
// // // //     }
// // // //
// // // //     // Check if actual connection works (ping)
// // // //     try {
// // // //       final result = await InternetAddress.lookup('google.com')
// // // //           .timeout(const Duration(seconds: 5));
// // // //
// // // //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
// // // //         return true; // Internet is working
// // // //       } else {
// // // //         if (showSnack) {
// // // //           _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
// // // //         }
// // // //         return false;
// // // //       }
// // // //     } on SocketException {
// // // //       if (showSnack) {
// // // //         _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
// // // //       }
// // // //       return false;
// // // //     } on TimeoutException {
// // // //       if (showSnack) {
// // // //         _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
// // // //       }
// // // //       return false;
// // // //     } catch (e) {
// // // //       if (showSnack) {
// // // //         _showCenteredSnackBar('Error checking internet: $e', isError: true);
// // // //       }
// // // //       return false;
// // // //     }
// // // //   }
// // // //
// // // //   /// 🔹 Save company details logic
// // // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // // //     _showCenteredSnackBar('Please wait...');
// // // //     setState(() {
// // // //       isLoading = true;
// // // //       isButtonDisabled = true;
// // // //     });
// // // //
// // // //     if (!await _hasInternet()) {
// // // //       setState(() {
// // // //         isLoading = false;
// // // //         isButtonDisabled = false;
// // // //       });
// // // //       return;
// // // //     }
// // // //
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       await prefs.reload();
// // // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // // //
// // // //       await Config.fetchLatestConfig();
// // // //
// // // //       final response = await http
// // // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // // //           .timeout(const Duration(seconds: 30));
// // // //
// // // //       if (response.statusCode != 200) {
// // // //         _showCenteredSnackBar('Failed to fetch company details', isError: true);
// // // //         setState(() {
// // // //           isLoading = false;
// // // //           isButtonDisabled = false;
// // // //         });
// // // //         return;
// // // //       }
// // // //
// // // //       final data = json.decode(response.body);
// // // //       final items = data['items'] as List;
// // // //       final company = items.firstWhere(
// // // //             (item) => item['company_code'] == companyCode,
// // // //         orElse: () => null,
// // // //       );
// // // //
// // // //       if (company == null) {
// // // //         _showCenteredSnackBar('Company code not found', isError: true);
// // // //         setState(() {
// // // //           isLoading = false;
// // // //           isButtonDisabled = false;
// // // //         });
// // // //         return;
// // // //       }
// // // //
// // // //       await prefs.setString('company_name', company['company_name']);
// // // //       await prefs.setString('workspace_name', company['workspace_name']);
// // // //       await prefs.setString('company_code', companyCode);
// // // //       erpWorkSpace = await prefs.getString('workspace_name') ?? '';
// // // //
// // // //       if (!isAuthenticated) {
// // // //         try {
// // // //           _showCenteredSnackBar('Setting up your account...');
// // // //           await Config.fetchLatestConfig();
// // // //           await Config.getApiUrlERPCompanyName;
// // // //           companyName = await prefs.getString('company_name') ?? '';
// // // //           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // // //           await loginViewModel.checkInternetBeforeNavigation();
// // // //         } catch (e) {
// // // //           debugPrint("Authentication error: $e");
// // // //           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
// // // //           setState(() {
// // // //             isLoading = false;
// // // //             isButtonDisabled = false;
// // // //           });
// // // //           return;
// // // //         }
// // // //       }
// // // //
// // // //       _showCenteredSnackBar('Setup complete!');
// // // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //         Get.offAll(() => const CameraScreen());
// // // //       });
// // // //     } on SocketException {
// // // //       _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
// // // //     } on TimeoutException {
// // // //       _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
// // // //     } on http.ClientException {
// // // //       _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
// // // //     } catch (e) {
// // // //       debugPrint('Error in _saveCompanyDetails: $e');
// // // //       _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
// // // //     } finally {
// // // //       setState(() {
// // // //         isLoading = false;
// // // //         isButtonDisabled = false;
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   /// 🔹 UI build
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final screenHeight = MediaQuery.of(context).size.height;
// // // //     final screenWidth = MediaQuery.of(context).size.width;
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.white,
// // // //       resizeToAvoidBottomInset: true,
// // // //       body: GestureDetector(
// // // //         onTap: () => FocusScope.of(context).unfocus(),
// // // //         child: SafeArea(
// // // //           child: Column(
// // // //             children: [
// // // //               Container(
// // // //                 height: screenHeight * 0.35,
// // // //                 width: double.infinity,
// // // //                 decoration: const BoxDecoration(
// // // //                   color: Colors.blueAccent,
// // // //                   borderRadius: BorderRadius.only(
// // // //                     bottomLeft: Radius.circular(30),
// // // //                     bottomRight: Radius.circular(30),
// // // //                   ),
// // // //                 ),
// // // //                 child: const Column(
// // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // //                   children: [
// // // //                     Text(
// // // //                       'Welcome to',
// // // //                       style: TextStyle(
// // // //                         fontSize: 26,
// // // //                         color: Colors.white70,
// // // //                         fontWeight: FontWeight.w400,
// // // //                       ),
// // // //                     ),
// // // //                     SizedBox(height: 8),
// // // //                     Text(
// // // //                       'BookIT!',
// // // //                       style: TextStyle(
// // // //                         fontSize: 36,
// // // //                         color: Colors.white,
// // // //                         fontWeight: FontWeight.bold,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               Expanded(
// // // //                 child: Padding(
// // // //                   padding: EdgeInsets.symmetric(
// // // //                     horizontal: screenWidth * 0.06,
// // // //                     vertical: 30,
// // // //                   ),
// // // //                   child: Form(
// // // //                     key: _formKey,
// // // //                     child: LayoutBuilder(
// // // //                       builder: (context, constraints) {
// // // //                         return SingleChildScrollView(
// // // //                           physics: const ClampingScrollPhysics(),
// // // //                           child: ConstrainedBox(
// // // //                             constraints: BoxConstraints(
// // // //                               minHeight: constraints.maxHeight,
// // // //                             ),
// // // //                             child: IntrinsicHeight(
// // // //                               child: Column(
// // // //                                 mainAxisSize: MainAxisSize.min,
// // // //                                 children: [
// // // //                                   const Text(
// // // //                                     'Please enter the company code to continue.\n',
// // // //                                     style: TextStyle(
// // // //                                       fontSize: 17,
// // // //                                       color: Colors.black87,
// // // //                                       height: 1.5,
// // // //                                     ),
// // // //                                     textAlign: TextAlign.center,
// // // //                                   ),
// // // //                                   const SizedBox(height: 20),
// // // //                                   const Align(
// // // //                                     alignment: Alignment.centerLeft,
// // // //                                     child: Text(
// // // //                                       'Company Code',
// // // //                                       style: TextStyle(
// // // //                                         fontSize: 16,
// // // //                                         fontWeight: FontWeight.w500,
// // // //                                         color: Colors.black87,
// // // //                                       ),
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(height: 10),
// // // //                                   TextFormField(
// // // //                                     controller: companyCodeController,
// // // //                                     decoration: InputDecoration(
// // // //                                       hintText: 'Enter your company code',
// // // //                                       filled: true,
// // // //                                       fillColor: Colors.grey[100],
// // // //                                       contentPadding: const EdgeInsets.symmetric(
// // // //                                         vertical: 16,
// // // //                                         horizontal: 16,
// // // //                                       ),
// // // //                                       border: OutlineInputBorder(
// // // //                                         borderRadius: BorderRadius.circular(12),
// // // //                                         borderSide: BorderSide.none,
// // // //                                       ),
// // // //                                     ),
// // // //                                     validator: (value) {
// // // //                                       if (value == null || value.isEmpty) {
// // // //                                         return 'Please enter company code';
// // // //                                       }
// // // //                                       return null;
// // // //                                     },
// // // //                                   ),
// // // //                                   const SizedBox(height: 55),
// // // //                                   SizedBox(
// // // //                                     width: double.infinity,
// // // //                                     child: ElevatedButton(
// // // //                                       onPressed: isButtonDisabled
// // // //                                           ? null
// // // //                                           : () {
// // // //                                         if (_formKey.currentState!.validate()) {
// // // //                                           _saveCompanyDetails(companyCodeController.text.trim());
// // // //                                         }
// // // //                                       },
// // // //                                       style: ElevatedButton.styleFrom(
// // // //                                         backgroundColor: Colors.blueAccent,
// // // //                                         foregroundColor: Colors.white,
// // // //                                         padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                                         shape: RoundedRectangleBorder(
// // // //                                           borderRadius: BorderRadius.circular(12),
// // // //                                         ),
// // // //                                       ),
// // // //                                       child: Text(
// // // //                                         isLoading ? 'Please wait...' : 'Continue',
// // // //                                         style: const TextStyle(fontSize: 16),
// // // //                                       ),
// // // //                                     ),
// // // //                                   ),
// // // //                                   SizedBox(
// // // //                                     height: MediaQuery.of(context).viewInsets.bottom > 0
// // // //                                         ? 20
// // // //                                         : screenHeight * 0.05,
// // // //                                   ),
// // // //                                 ],
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         );
// // // //                       },
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io';
// // //
// // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:order_booking_app/Databases/util.dart';
// // // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // //
// // // class CodeScreen extends StatefulWidget {
// // //   const CodeScreen({super.key});
// // //
// // //   @override
// // //   State<CodeScreen> createState() => _CodeScreenState();
// // // }
// // //
// // // class _CodeScreenState extends State<CodeScreen> {
// // //   late final TextEditingController companyCodeController;
// // //   final _formKey = GlobalKey<FormState>();
// // //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// // //
// // //   bool isLoading = false;
// // //   bool isButtonDisabled = false;
// // //   bool isOffline = false;
// // //
// // //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     companyCodeController = TextEditingController();
// // //
// // //     // Listen to connectivity changes (new API returns List<ConnectivityResult>)
// // //     _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
// // //           (List<ConnectivityResult> results) async {
// // //         final hasAnyConnection = results.any((r) => r != ConnectivityResult.none);
// // //
// // //         if (!hasAnyConnection) {
// // //           if (!isOffline) {
// // //             setState(() => isOffline = true);
// // //             _showCenteredSnackBar('No internet connection.', isError: true);
// // //           }
// // //         } else {
// // //           final hasRealInternet = await _hasInternet(showSnack: false);
// // //           if (!hasRealInternet) {
// // //             _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
// // //           } else if (isOffline) {
// // //             setState(() => isOffline = false);
// // //             _showCenteredSnackBar('Back online! You can continue.');
// // //           }
// // //         }
// // //       },
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     companyCodeController.dispose();
// // //     _connectivitySubscription?.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   // ────────────────────────────────────────────────
// // //   //                SnackBar Helper
// // //   // ────────────────────────────────────────────────
// // //   void _showCenteredSnackBar(String message, {bool isError = false}) {
// // //     final snackBar = SnackBar(
// // //       content: Center(
// // //         child: Text(
// // //           message,
// // //           style: const TextStyle(fontSize: 16, color: Colors.white),
// // //           textAlign: TextAlign.center,
// // //         ),
// // //       ),
// // //       backgroundColor: isError ? Colors.redAccent : Colors.green,
// // //       behavior: SnackBarBehavior.floating,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //       margin: EdgeInsets.only(
// // //         bottom: MediaQuery.of(context).size.height * 0.35,
// // //         left: 24,
// // //         right: 24,
// // //       ),
// // //       elevation: 6,
// // //       duration: const Duration(seconds: 4),
// // //     );
// // //
// // //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// // //   }
// // //
// // //   // ────────────────────────────────────────────────
// // //   //           Real Internet Reachability Check
// // //   // ────────────────────────────────────────────────
// // //   Future<bool> _hasInternet({bool showSnack = true}) async {
// // //     var connectivityResult = await Connectivity().checkConnectivity();
// // //
// // //     if (!connectivityResult.any((r) => r != ConnectivityResult.none)) {
// // //       if (showSnack) {
// // //         _showCenteredSnackBar('No network detected.', isError: true);
// // //       }
// // //       return false;
// // //     }
// // //
// // //     try {
// // //       final result = await InternetAddress.lookup('google.com')
// // //           .timeout(const Duration(seconds: 5));
// // //
// // //       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
// // //     } on SocketException {
// // //       if (showSnack) {
// // //         _showCenteredSnackBar('Internet not reachable.', isError: true);
// // //       }
// // //       return false;
// // //     } on TimeoutException {
// // //       if (showSnack) {
// // //         _showCenteredSnackBar('Connection timeout – internet may be slow.', isError: true);
// // //       }
// // //       return false;
// // //     } catch (e) {
// // //       if (showSnack) {
// // //         _showCenteredSnackBar('Error checking connection.', isError: true);
// // //       }
// // //       return false;
// // //     }
// // //   }
// // //
// // //   // ────────────────────────────────────────────────
// // //   //               Main Business Logic
// // //   // ────────────────────────────────────────────────
// // //   Future<void> _saveCompanyDetails(String companyCode) async {
// // //     _showCenteredSnackBar('Please wait...');
// // //     setState(() {
// // //       isLoading = true;
// // //       isButtonDisabled = true;
// // //     });
// // //
// // //     if (!await _hasInternet()) {
// // //       setState(() {
// // //         isLoading = false;
// // //         isButtonDisabled = false;
// // //       });
// // //       return;
// // //     }
// // //
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       await prefs.reload();
// // //
// // //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// // //
// // //       await Config.fetchLatestConfig();
// // //
// // //       final response = await http
// // //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// // //           .timeout(const Duration(seconds: 30));
// // //
// // //       if (response.statusCode != 200) {
// // //         _showCenteredSnackBar('Failed to fetch company list', isError: true);
// // //         return;
// // //       }
// // //
// // //       final data = json.decode(response.body);
// // //       final items = data['items'] as List<dynamic>? ?? [];
// // //
// // //       final company = items.firstWhere(
// // //             (item) => item['company_code'] == companyCode,
// // //         orElse: () => null,
// // //       );
// // //
// // //       if (company == null) {
// // //         _showCenteredSnackBar('Invalid company code', isError: true);
// // //         return;
// // //       }
// // //
// // //       await prefs.setString('company_name', company['company_name'] ?? '');
// // //       await prefs.setString('workspace_name', company['workspace_name'] ?? '');
// // //       await prefs.setString('company_code', companyCode);
// // //
// // //       erpWorkSpace = prefs.getString('workspace_name') ?? '';
// // //
// // //       if (!isAuthenticated) {
// // //         _showCenteredSnackBar('Setting up account...');
// // //         await Config.fetchLatestConfig();
// // //         companyName = prefs.getString('company_name') ?? '';
// // //         debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// // //         await loginViewModel.checkInternetBeforeNavigation();
// // //       }
// // //
// // //       _showCenteredSnackBar('Setup complete!', isError: false);
// // //
// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         Get.offAll(() => const CameraScreen());
// // //       });
// // //     } on SocketException {
// // //       _showCenteredSnackBar('No internet connection.', isError: true);
// // //     } on TimeoutException {
// // //       _showCenteredSnackBar('Request timed out.', isError: true);
// // //     } on http.ClientException {
// // //       _showCenteredSnackBar('Connection failed.', isError: true);
// // //     } catch (e) {
// // //       debugPrint('Setup error: $e');
// // //       _showCenteredSnackBar('Something went wrong. Try again.', isError: true);
// // //     } finally {
// // //       setState(() {
// // //         isLoading = false;
// // //         isButtonDisabled = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   // ────────────────────────────────────────────────
// // //   //                     UI
// // //   // ────────────────────────────────────────────────
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final screenHeight = MediaQuery.of(context).size.height;
// // //     final screenWidth = MediaQuery.of(context).size.width;
// // //
// // //     return Scaffold(
// // //       body: Container(
// // //         decoration: const BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topLeft,
// // //             end: Alignment.bottomRight,
// // //             colors: [
// // //               Color(0xFF1E3A8A),
// // //               Color(0xFF3B82F6),
// // //               Color(0xFF60A5FA),
// // //             ],
// // //           ),
// // //         ),
// // //         child: SafeArea(
// // //           child: Center(
// // //             child: ConstrainedBox(
// // //               constraints: const BoxConstraints(maxWidth: 460),
// // //               child: SingleChildScrollView(
// // //                 padding: EdgeInsets.symmetric(
// // //                   horizontal: screenWidth * 0.08,
// // //                   vertical: 24,
// // //                 ),
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     const SizedBox(height: 40),
// // //
// // //                     // App branding header
// // //                     Container(
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 28,
// // //                         vertical: 20,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white.withOpacity(0.14),
// // //                         borderRadius: BorderRadius.circular(28),
// // //                         border: Border.all(color: Colors.white.withOpacity(0.22)),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black.withOpacity(0.16),
// // //                             blurRadius: 24,
// // //                             offset: const Offset(0, 12),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       child: const Column(
// // //                         children: [
// // //                           Text(
// // //                             'BookIT!',
// // //                             style: TextStyle(
// // //                               fontSize: 52,
// // //                               fontWeight: FontWeight.w800,
// // //                               color: Colors.white,
// // //                               letterSpacing: 1.4,
// // //                               shadows: [
// // //                                 Shadow(
// // //                                   color: Colors.black38,
// // //                                   blurRadius: 12,
// // //                                   offset: Offset(0, 6),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                           SizedBox(height: 6),
// // //                           Text(
// // //                             'Smart Order & Field Management',
// // //                             style: TextStyle(
// // //                               fontSize: 16,
// // //                               // color: Colors.white80,
// // //                               fontWeight: FontWeight.w400,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //
// // //                     const SizedBox(height: 60),
// // //
// // //                     // Main input card
// // //                     Container(
// // //                       padding: const EdgeInsets.all(32),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white.withOpacity(0.96),
// // //                         borderRadius: BorderRadius.circular(32),
// // //                         border: Border.all(color: Colors.white.withOpacity(0.35)),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black.withOpacity(0.20),
// // //                             blurRadius: 40,
// // //                             spreadRadius: 4,
// // //                             offset: const Offset(0, 20),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       child: Form(
// // //                         key: _formKey,
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             const Text(
// // //                               'Company Code',
// // //                               style: TextStyle(
// // //                                 fontSize: 26,
// // //                                 fontWeight: FontWeight.w700,
// // //                                 color: Color(0xFF1E40AF),
// // //                               ),
// // //                             ),
// // //                             const SizedBox(height: 8),
// // //                             Text(
// // //                               'Enter your company code to access your workspace and start booking orders.',
// // //                               style: TextStyle(
// // //                                 fontSize: 15,
// // //                                 color: Colors.grey[700],
// // //                                 height: 1.45,
// // //                               ),
// // //                             ),
// // //                             const SizedBox(height: 32),
// // //
// // //                             TextFormField(
// // //                               controller: companyCodeController,
// // //                               textCapitalization: TextCapitalization.characters,
// // //                               textInputAction: TextInputAction.go,
// // //                               decoration: InputDecoration(
// // //                                 labelText: 'Enter code here',
// // //                                 labelStyle: const TextStyle(
// // //                                   color: Color(0xFF1E40AF),
// // //                                   fontWeight: FontWeight.w500,
// // //                                 ),
// // //                                 floatingLabelBehavior: FloatingLabelBehavior.auto,
// // //                                 filled: true,
// // //                                 fillColor: Colors.grey.shade50,
// // //                                 contentPadding: const EdgeInsets.symmetric(
// // //                                   vertical: 18,
// // //                                   horizontal: 20,
// // //                                 ),
// // //                                 border: OutlineInputBorder(
// // //                                   borderRadius: BorderRadius.circular(16),
// // //                                   borderSide: BorderSide.none,
// // //                                 ),
// // //                                 focusedBorder: OutlineInputBorder(
// // //                                   borderRadius: BorderRadius.circular(16),
// // //                                   borderSide: const BorderSide(
// // //                                     color: Color(0xFF3B82F6),
// // //                                     width: 2.2,
// // //                                   ),
// // //                                 ),
// // //                                 errorBorder: OutlineInputBorder(
// // //                                   borderRadius: BorderRadius.circular(16),
// // //                                   borderSide: const BorderSide(
// // //                                     color: Colors.redAccent,
// // //                                     width: 2,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                               validator: (value) {
// // //                                 if (value == null || value.trim().isEmpty) {
// // //                                   return 'Company code is required';
// // //                                 }
// // //                                 return null;
// // //                               },
// // //                               onFieldSubmitted: (_) {
// // //                                 if (_formKey.currentState!.validate() &&
// // //                                     !isButtonDisabled) {
// // //                                   _saveCompanyDetails(
// // //                                       companyCodeController.text.trim());
// // //                                 }
// // //                               },
// // //                             ),
// // //
// // //                             const SizedBox(height: 44),
// // //
// // //                             SizedBox(
// // //                               width: double.infinity,
// // //                               height: 58,
// // //                               child: ElevatedButton(
// // //                                 onPressed: isButtonDisabled
// // //                                     ? null
// // //                                     : () {
// // //                                   if (_formKey.currentState!.validate()) {
// // //                                     _saveCompanyDetails(
// // //                                         companyCodeController.text.trim());
// // //                                   }
// // //                                 },
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   backgroundColor: const Color(0xFF2563EB),
// // //                                   foregroundColor: Colors.white,
// // //                                   elevation: 8,
// // //                                   shadowColor:
// // //                                   const Color(0xFF3B82F6).withOpacity(0.5),
// // //                                   shape: RoundedRectangleBorder(
// // //                                     borderRadius: BorderRadius.circular(16),
// // //                                   ),
// // //                                 ),
// // //                                 child: isLoading
// // //                                     ? const SizedBox(
// // //                                   height: 26,
// // //                                   width: 26,
// // //                                   child: CircularProgressIndicator(
// // //                                     color: Colors.white,
// // //                                     strokeWidth: 3,
// // //                                   ),
// // //                                 )
// // //                                     : const Text(
// // //                                   'Continue',
// // //                                   style: TextStyle(
// // //                                     fontSize: 18,
// // //                                     fontWeight: FontWeight.w600,
// // //                                     letterSpacing: 0.4,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //
// // //                             const SizedBox(height: 24),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //
// // //                     const SizedBox(height: 60),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// // import 'package:order_booking_app/ViewModels/login_view_model.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class CodeScreen extends StatefulWidget {
// //   const CodeScreen({super.key});
// //
// //   @override
// //   State<CodeScreen> createState() => _CodeScreenState();
// // }
// //
// // class _CodeScreenState extends State<CodeScreen> with SingleTickerProviderStateMixin {
// //   late final TextEditingController companyCodeController;
// //   late AnimationController _animationController;
// //   late Animation<double> _fadeAnimation;
// //   late Animation<Offset> _slideAnimation;
// //
// //   final _formKey = GlobalKey<FormState>();
// //   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// //
// //   bool isLoading = false;
// //   bool isButtonDisabled = false;
// //   bool isOffline = false;
// //
// //   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     companyCodeController = TextEditingController();
// //
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1200),
// //     );
// //
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
// //     );
// //
// //     _slideAnimation = Tween<Offset>(
// //       begin: const Offset(0, 0.3),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
// //
// //     _animationController.forward();
// //
// //     _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
// //           (List<ConnectivityResult> results) async {
// //         final hasAnyConnection = results.any((r) => r != ConnectivityResult.none);
// //
// //         if (!hasAnyConnection) {
// //           if (!isOffline) {
// //             setState(() => isOffline = true);
// //             _showModernSnackBar('No internet connection', isError: true);
// //           }
// //         } else {
// //           final hasRealInternet = await _hasInternet(showSnack: false);
// //           if (!hasRealInternet) {
// //             _showModernSnackBar('Internet is slow or unstable', isError: true);
// //           } else if (isOffline) {
// //             setState(() => isOffline = false);
// //             _showModernSnackBar('Back online! You can continue', isError: false);
// //           }
// //         }
// //       },
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     companyCodeController.dispose();
// //     _connectivitySubscription?.cancel();
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _showModernSnackBar(String message, {bool isError = false}) {
// //     final snackBar = SnackBar(
// //       content: Row(
// //         children: [
// //           Icon(
// //             isError ? Icons.error_outline : Icons.check_circle_outline,
// //             color: Colors.white,
// //             size: 22,
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               message,
// //               style: const TextStyle(
// //                 fontSize: 15,
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// //       behavior: SnackBarBehavior.floating,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       margin: const EdgeInsets.all(16),
// //       elevation: 8,
// //       duration: const Duration(seconds: 3),
// //     );
// //
// //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
// //   }
// //
// //   Future<bool> _hasInternet({bool showSnack = true}) async {
// //     var connectivityResult = await Connectivity().checkConnectivity();
// //
// //     if (!connectivityResult.any((r) => r != ConnectivityResult.none)) {
// //       if (showSnack) {
// //         _showModernSnackBar('No network detected', isError: true);
// //       }
// //       return false;
// //     }
// //
// //     try {
// //       final result = await InternetAddress.lookup('google.com')
// //           .timeout(const Duration(seconds: 5));
// //
// //       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
// //     } on SocketException {
// //       if (showSnack) {
// //         _showModernSnackBar('Internet not reachable', isError: true);
// //       }
// //       return false;
// //     } on TimeoutException {
// //       if (showSnack) {
// //         _showModernSnackBar('Connection timeout – internet may be slow', isError: true);
// //       }
// //       return false;
// //     } catch (e) {
// //       if (showSnack) {
// //         _showModernSnackBar('Error checking connection', isError: true);
// //       }
// //       return false;
// //     }
// //   }
// //
// //   Future<void> _saveCompanyDetails(String companyCode) async {
// //     _showModernSnackBar('Verifying company code...');
// //     setState(() {
// //       isLoading = true;
// //       isButtonDisabled = true;
// //     });
// //
// //     if (!await _hasInternet()) {
// //       setState(() {
// //         isLoading = false;
// //         isButtonDisabled = false;
// //       });
// //       return;
// //     }
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.reload();
// //
// //       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// //
// //       await Config.fetchLatestConfig();
// //
// //       final response = await http
// //           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
// //           .timeout(const Duration(seconds: 30));
// //
// //       if (response.statusCode != 200) {
// //         _showModernSnackBar('Failed to fetch company list', isError: true);
// //         return;
// //       }
// //
// //       final data = json.decode(response.body);
// //       final items = data['items'] as List<dynamic>? ?? [];
// //
// //       final company = items.firstWhere(
// //             (item) => item['company_code'] == companyCode,
// //         orElse: () => null,
// //       );
// //
// //       if (company == null) {
// //         _showModernSnackBar('Invalid company code', isError: true);
// //         return;
// //       }
// //
// //       await prefs.setString('company_name', company['company_name'] ?? '');
// //       await prefs.setString('workspace_name', company['workspace_name'] ?? '');
// //       await prefs.setString('company_code', companyCode);
// //
// //       erpWorkSpace = prefs.getString('workspace_name') ?? '';
// //
// //       if (!isAuthenticated) {
// //         _showModernSnackBar('Setting up your workspace...');
// //         await Config.fetchLatestConfig();
// //         companyName = prefs.getString('company_name') ?? '';
// //         debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
// //         await loginViewModel.checkInternetBeforeNavigation();
// //       }
// //
// //       _showModernSnackBar('Setup complete!', isError: false);
// //
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         Get.offAll(() => const CameraScreen());
// //       });
// //     } on SocketException {
// //       _showModernSnackBar('No internet connection', isError: true);
// //     } on TimeoutException {
// //       _showModernSnackBar('Request timed out', isError: true);
// //     } on http.ClientException {
// //       _showModernSnackBar('Connection failed', isError: true);
// //     } catch (e) {
// //       debugPrint('Setup error: $e');
// //       _showModernSnackBar('Something went wrong. Try again', isError: true);
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //         isButtonDisabled = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final screenHeight = MediaQuery.of(context).size.height;
// //     final screenWidth = MediaQuery.of(context).size.width;
// //
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF0F172A),
// //               Color(0xFF1E293B),
// //               Color(0xFF334155),
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Stack(
// //             children: [
// //               // Animated background circles
// //               Positioned(
// //                 top: -100,
// //                 right: -100,
// //                 child: Container(
// //                   width: 300,
// //                   height: 300,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     gradient: RadialGradient(
// //                       colors: [
// //                         const Color(0xFF3B82F6).withOpacity(0.15),
// //                         Colors.transparent,
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               Positioned(
// //                 bottom: -150,
// //                 left: -150,
// //                 child: Container(
// //                   width: 400,
// //                   height: 400,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     gradient: RadialGradient(
// //                       colors: [
// //                         const Color(0xFF8B5CF6).withOpacity(0.1),
// //                         Colors.transparent,
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               // Main content
// //               Center(
// //                 child: ConstrainedBox(
// //                   constraints: const BoxConstraints(maxWidth: 480),
// //                   child: SingleChildScrollView(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: screenWidth * 0.06,
// //                       vertical: 24,
// //                     ),
// //                     child: FadeTransition(
// //                       opacity: _fadeAnimation,
// //                       child: SlideTransition(
// //                         position: _slideAnimation,
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             const SizedBox(height: 40),
// //
// //                             // Logo and branding
// //                             _buildLogo(),
// //
// //                             const SizedBox(height: 60),
// //
// //                             // Main card
// //                             _buildMainCard(),
// //
// //                             const SizedBox(height: 40),
// //
// //                             // Footer text
// //                             _buildFooter(),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLogo() {
// //     return Column(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF3B82F6).withOpacity(0.15),
// //             shape: BoxShape.circle,
// //             border: Border.all(
// //               color: const Color(0xFF3B82F6).withOpacity(0.3),
// //               width: 2,
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: const Color(0xFF3B82F6).withOpacity(0.2),
// //                 blurRadius: 30,
// //                 spreadRadius: 5,
// //               ),
// //             ],
// //           ),
// //           child: const Icon(
// //             Icons.business,
// //             size: 56,
// //             color: Color(0xFF60A5FA),
// //           ),
// //         ),
// //         const SizedBox(height: 24),
// //         const Text(
// //           'BookIT!',
// //           style: TextStyle(
// //             fontSize: 48,
// //             fontWeight: FontWeight.w900,
// //             color: Colors.white,
// //             letterSpacing: 1.2,
// //             shadows: [
// //               Shadow(
// //                 color: Colors.black26,
// //                 blurRadius: 8,
// //                 offset: Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Text(
// //           'Smart Order & Field Management',
// //           style: TextStyle(
// //             fontSize: 15,
// //             color: Colors.white.withOpacity(0.7),
// //             fontWeight: FontWeight.w400,
// //             letterSpacing: 0.5,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildMainCard() {
// //     return Container(
// //       padding: const EdgeInsets.all(36),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(24),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.15),
// //             blurRadius: 30,
// //             spreadRadius: 0,
// //             offset: const Offset(0, 15),
// //           ),
// //         ],
// //       ),
// //       child: Form(
// //         key: _formKey,
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFF3B82F6).withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: const Icon(
// //                     Icons.vpn_key_rounded,
// //                     color: Color(0xFF3B82F6),
// //                     size: 24,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 const Text(
// //                   'Access Code',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.w700,
// //                     color: Color(0xFF0F172A),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Text(
// //               'Enter your unique company code to access your workspace and begin managing orders.',
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: Colors.grey[600],
// //                 height: 1.5,
// //               ),
// //             ),
// //             const SizedBox(height: 32),
// //
// //             TextFormField(
// //               controller: companyCodeController,
// //               textCapitalization: TextCapitalization.characters,
// //               textInputAction: TextInputAction.go,
// //               style: const TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //                 letterSpacing: 2,
// //               ),
// //               decoration: InputDecoration(
// //                 labelText: 'Company Code',
// //                 hintText: 'e.g., COMP123',
// //                 hintStyle: TextStyle(
// //                   color: Colors.grey[400],
// //                   fontWeight: FontWeight.w500,
// //                   letterSpacing: 1,
// //                 ),
// //                 labelStyle: const TextStyle(
// //                   color: Color(0xFF64748B),
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //                 prefixIcon: const Icon(
// //                   Icons.tag_rounded,
// //                   color: Color(0xFF3B82F6),
// //                 ),
// //                 filled: true,
// //                 fillColor: const Color(0xFFF8FAFC),
// //                 contentPadding: const EdgeInsets.symmetric(
// //                   vertical: 20,
// //                   horizontal: 20,
// //                 ),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(14),
// //                   borderSide: BorderSide(color: Colors.grey[300]!),
// //                 ),
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(14),
// //                   borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(14),
// //                   borderSide: const BorderSide(
// //                     color: Color(0xFF3B82F6),
// //                     width: 2.5,
// //                   ),
// //                 ),
// //                 errorBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(14),
// //                   borderSide: const BorderSide(
// //                     color: Color(0xFFEF4444),
// //                     width: 2,
// //                   ),
// //                 ),
// //                 focusedErrorBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(14),
// //                   borderSide: const BorderSide(
// //                     color: Color(0xFFEF4444),
// //                     width: 2.5,
// //                   ),
// //                 ),
// //               ),
// //               validator: (value) {
// //                 if (value == null || value.trim().isEmpty) {
// //                   return 'Please enter your company code';
// //                 }
// //                 if (value.trim().length < 3) {
// //                   return 'Code must be at least 3 characters';
// //                 }
// //                 return null;
// //               },
// //               onFieldSubmitted: (_) {
// //                 if (_formKey.currentState!.validate() && !isButtonDisabled) {
// //                   _saveCompanyDetails(companyCodeController.text.trim());
// //                 }
// //               },
// //             ),
// //
// //             const SizedBox(height: 36),
// //
// //             SizedBox(
// //               width: double.infinity,
// //               height: 56,
// //               child: ElevatedButton(
// //                 onPressed: isButtonDisabled
// //                     ? null
// //                     : () {
// //                   if (_formKey.currentState!.validate()) {
// //                     _saveCompanyDetails(companyCodeController.text.trim());
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF3B82F6),
// //                   foregroundColor: Colors.white,
// //                   elevation: 0,
// //                   shadowColor: Colors.transparent,
// //                   disabledBackgroundColor: Colors.grey[300],
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(14),
// //                   ),
// //                 ),
// //                 child: isLoading
// //                     ? const SizedBox(
// //                   height: 24,
// //                   width: 24,
// //                   child: CircularProgressIndicator(
// //                     color: Colors.white,
// //                     strokeWidth: 2.5,
// //                   ),
// //                 )
// //                     : Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: const [
// //                     Text(
// //                       'Continue',
// //                       style: TextStyle(
// //                         fontSize: 17,
// //                         fontWeight: FontWeight.w600,
// //                         letterSpacing: 0.3,
// //                       ),
// //                     ),
// //                     SizedBox(width: 8),
// //                     Icon(Icons.arrow_forward_rounded, size: 20),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFooter() {
// //     return Column(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //           decoration: BoxDecoration(
// //             color: Colors.white.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.white.withOpacity(0.15)),
// //           ),
// //           child: Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Icon(
// //                 Icons.shield_rounded,
// //                 color: Colors.white.withOpacity(0.7),
// //                 size: 18,
// //               ),
// //               const SizedBox(width: 8),
// //               Text(
// //                 'Secure & Encrypted Connection',
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   color: Colors.white.withOpacity(0.7),
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         Text(
// //           '© 2024 BookIT! All rights reserved',
// //           style: TextStyle(
// //             fontSize: 12,
// //             color: Colors.white.withOpacity(0.5),
// //             fontWeight: FontWeight.w400,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// import 'package:order_booking_app/ViewModels/login_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class CodeScreen extends StatefulWidget {
//   const CodeScreen({super.key});
//
//   @override
//   State<CodeScreen> createState() => _CodeScreenState();
// }
//
// class _CodeScreenState extends State<CodeScreen> with SingleTickerProviderStateMixin {
//   late final TextEditingController companyCodeController;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   final _formKey = GlobalKey<FormState>();
//   final LoginViewModel loginViewModel = Get.put(LoginViewModel());
//
//   bool isLoading = false;
//   bool isButtonDisabled = false;
//   bool isOffline = false;
//
//   // Theme Colors
//   final Color primaryOrange = const Color(0xFFF59E0B); // Amber/Orange for appetite
//   final Color darkText = const Color(0xFF1F2937); // Deep Charcoal
//   final Color bgColor = const Color(0xFFFDFCFB); // Soft Cream
//
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     companyCodeController = TextEditingController();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
//
//     _animationController.forward();
//
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
//           (List<ConnectivityResult> results) async {
//         final hasAnyConnection = results.any((r) => r != ConnectivityResult.none);
//         if (!hasAnyConnection) {
//           setState(() => isOffline = true);
//           _showModernSnackBar('No internet connection', isError: true);
//         } else if (isOffline) {
//           setState(() => isOffline = false);
//           _showModernSnackBar('Back online!', isError: false);
//         }
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     companyCodeController.dispose();
//     _connectivitySubscription?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _showModernSnackBar(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Action Required' : 'Success',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: isError ? const Color(0xFFEF4444) : primaryOrange,
//       colorText: Colors.white,
//       margin: const EdgeInsets.all(15),
//       borderRadius: 15,
//       icon: Icon(isError ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: Colors.white),
//     );
//   }
//
//   Future<void> _saveCompanyDetails(String companyCode) async {
//     setState(() {
//       isLoading = true;
//       isButtonDisabled = true;
//     });
//
//     try {
//       final response = await http
//           .get(Uri.parse(Config.getApiUrlCompaniesCodes))
//           .timeout(const Duration(seconds: 15));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final items = data['items'] as List<dynamic>? ?? [];
//
//         final company = items.firstWhere(
//               (item) => item['company_code'] == companyCode,
//           orElse: () => null,
//         );
//
//         if (company != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('company_name', company['company_name']);
//           await prefs.setString('workspace_name', company['workspace_name']);
//           await prefs.setString('company_code', companyCode);
//
//           erpWorkSpace = company['workspace_name'];
//           Get.offAll(() => const CameraScreen());
//         } else {
//           _showModernSnackBar('Invalid code. Please check and try again.', isError: true);
//         }
//       }
//     } catch (e) {
//       _showModernSnackBar('Connection error. Try again.', isError: true);
//     } finally {
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: Stack(
//         children: [
//           // Elegant Top-Right Glow
//           // Positioned(
//           //   top: -100,
//           //   right: -100,
//           //   child: Container(
//           //     width: 300,
//           //     height: 300,
//           //     decoration: BoxDecoration(
//           //       shape: BoxShape.circle,
//           //       color: darkText.withOpacity(0.15),
//           //     ),
//           //   ),
//           // ),
//           // Positioned(
//           //   top: -50,
//           //   left: -100,
//           //   right: 50,
//           //   child: Container(
//           //     width: 900,
//           //     height: 300,
//           //     decoration: BoxDecoration(
//           //       shape: BoxShape.circle,
//           //       color: darkText.withOpacity(0.15),
//           //     ),
//           //   ),
//           // ),
//
//           Positioned(
//             top: -80,
//             right: -120,
//             child: Container(
//               width: 260,
//               height: 260,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: darkText.withOpacity(0.10), // more subtle
//               ),
//             ),
//           ),
//
//           Positioned(
//             top: -80,
//             left: -140,
//             child: Container(
//               width: 420,
//               height: 420,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: darkText.withOpacity(0.10), // layered depth
//               ),
//             ),
//           ),
//
//
//
//
//
//           SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _buildHeader(),
//                         const SizedBox(height: 40),
//                         _buildMainCard(),
//                         const SizedBox(height: 30),
//                         _buildFooter(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         // Container(
//         //   padding: const EdgeInsets.all(20),
//         //   decoration: BoxDecoration(
//         //     // color: Colors.white,
//         //     // shape: BoxShape.circle,
//         //     boxShadow: [
//         //       // BoxShadow(
//         //       //   color: primaryOrange.withOpacity(0.2),
//         //       //   blurRadius: 25,
//         //       //   offset: const Offset(0, 10),
//         //       // ),
//         //     ],
//         //   ),
//         //   // child: Icon(Icons.book, size: 50, color: primaryOrange),
//         // ),
//         // const SizedBox(height: 20),
//         Text(
//           'BOOKIT',
//           style: TextStyle(
//             fontSize: 40,
//             fontWeight: FontWeight.w900,
//             color: darkText,
//             letterSpacing: -1,
//           ),
//         ),
//         Text(
//           'ORDER MANAGEMENT SYSTEM',
//           style: TextStyle(
//             fontSize: 12,
//             letterSpacing: 2,
//             fontWeight: FontWeight.bold,
//             color: darkText.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMainCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: darkText.withOpacity(0.09),
//             blurRadius: 20,
//             offset: const Offset(0, 15),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Company Code',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Enter your unique company code to continue this application .',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
//             ),
//             const SizedBox(height: 30),
//             TextFormField(
//               controller: companyCodeController,
//               textCapitalization: TextCapitalization.characters,
//               style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0),
//               decoration: InputDecoration(
//                 hintText: 'Enter a code',
//                 // prefixIcon: Icon(Icons.vpn_key_outlined, color: primaryOrange),
//                 filled: true,
//                 fillColor: const Color(0xFFF9FAFB),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide(color: darkText, width: 2),
//                 ),
//               ),
//               validator: (v) => v!.isEmpty ? 'Please enter code' : null,
//             ),
//             const SizedBox(height: 25),
//             SizedBox(
//               width: double.infinity,
//               height: 58,
//               child: ElevatedButton(
//                 onPressed: isButtonDisabled
//                     ? null
//                     : () {
//                   if (_formKey.currentState!.validate()) {
//                     _saveCompanyDetails(companyCodeController.text.trim());
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: darkText,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 ),
//                 child: isLoading
//                     ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                     : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFooter() {
//     return Column(
//       children: [
//         TextButton(
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text('Please contact admin to reset your access code'),
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           },
//           child: Text(
//             'Forget your access code?',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
//             const SizedBox(width: 5),
//             Text(
//               'SECURED END-TO-END',
//               style: TextStyle(fontSize: 10, color: Colors.grey[400], letterSpacing: 1),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
import 'package:order_booking_app/ViewModels/login_view_model.dart';
import 'package:order_booking_app/constants.dart';
import 'package:order_booking_app/widgets/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController companyCodeController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final LoginViewModel loginViewModel = Get.put(LoginViewModel());

  bool isLoading = false;
  bool isButtonDisabled = false;
  bool isOffline = false;

  // // Theme Colors
  // final Color primaryOrange = const Color(0xFFF59E0B);
  // final Color darkText = const Color(0xFF1F2937);
  // final Color bgColor = const Color(0xFFFDFCFB);

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    companyCodeController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    // Listen to internet connectivity changes (from 2nd screen)
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        setState(() => isOffline = true);
        _showCenteredSnackBar('No internet connection.', isError: true);
      } else {
        bool hasNet = await _hasInternet(showSnack: false);
        if (!hasNet) {
          _showCenteredSnackBar('Internet is slow or unstable.', isError: true);
        } else if (isOffline) {
          setState(() => isOffline = false);
          _showCenteredSnackBar('Back online! You can continue.');
        }
      }
    });
  }

  @override
  void dispose() {
    companyCodeController.dispose();
    connectivitySubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// 🔹 Shows custom centered snackbar (from 2nd screen)
  void _showCenteredSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.4,
        left: 20,
        right: 20,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 🔹 Check actual internet access — not just WiFi/mobile signal (from 2nd screen)
  Future<bool> _hasInternet({bool showSnack = true}) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // No connection at all
    if (connectivityResult == ConnectivityResult.none) {
      if (showSnack) {
        _showCenteredSnackBar('No internet connection detected.', isError: true);
      }
      return false;
    }

    // Check if actual connection works (ping)
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Internet is working
      } else {
        if (showSnack) {
          _showCenteredSnackBar('Internet seems unavailable or very slow.', isError: true);
        }
        return false;
      }
    } on SocketException {
      if (showSnack) {
        _showCenteredSnackBar('Internet not reachable. Please check your connection.', isError: true);
      }
      return false;
    } on TimeoutException {
      if (showSnack) {
        _showCenteredSnackBar('Internet connection is very slow. Please try again.', isError: true);
      }
      return false;
    } catch (e) {
      if (showSnack) {
        _showCenteredSnackBar('Error checking internet: $e', isError: true);
      }
      return false;
    }
  }

  /// 🔹 Save company details logic (from 2nd screen with enhancements)
  Future<void> _saveCompanyDetails(String companyCode) async {
    _showCenteredSnackBar('Please wait...');
    setState(() {
      isLoading = true;
      isButtonDisabled = true;
    });

    if (!await _hasInternet()) {
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

      await Config.fetchLatestConfig();

      final response = await http
          .get(Uri.parse(Config.getApiUrlCompaniesCodes))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _showCenteredSnackBar('Failed to fetch company details', isError: true);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;
      final company = items.firstWhere(
            (item) => item['company_code'] == companyCode,
        orElse: () => null,
      );

      if (company == null) {
        _showCenteredSnackBar('Company code not found', isError: true);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }

      await prefs.setString('company_name', company['company_name']);
      await prefs.setString('workspace_name', company['workspace_name']);
      await prefs.setString('company_code', companyCode);
      erpWorkSpace = await prefs.getString('workspace_name') ?? '';

      if (!isAuthenticated) {
        try {
          _showCenteredSnackBar('Setting up your account...');
          await Config.fetchLatestConfig();
          await Config.getApiUrlERPCompanyName;
          companyName = await prefs.getString('company_name') ?? '';
          debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
          await loginViewModel.checkInternetBeforeNavigation();
        } catch (e) {
          debugPrint("Authentication error: $e");
          _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
          setState(() {
            isLoading = false;
            isButtonDisabled = false;
          });
          return;
        }
      }

      _showCenteredSnackBar('Setup complete!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const CameraScreen());
      });
    } on SocketException {
      _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
    } on TimeoutException {
      _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
    } on http.ClientException {
      _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
    } catch (e) {
      debugPrint('Error in _saveCompanyDetails: $e');
      _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
    } finally {
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Elegant background circles (from 1st screen)
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildMainCard(),
                          const SizedBox(height: 30),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'BOOKIT',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColor.darkText,
            letterSpacing: -1,
          ),
        ),
        Text(
          'ORDER MANAGEMENT SYSTEM',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: AppColor.subText,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkText.withOpacity(0.09),
            blurRadius: 20,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Code',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColor.darkText),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your unique company code to continue this application .',
              style: TextStyle(fontSize: 14, color: AppColor.subText, height: 1.4),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: companyCodeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0),
              decoration: InputDecoration(
                hintText: 'Enter your company code',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: darkText, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company code';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isButtonDisabled
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _saveCompanyDetails(companyCodeController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const Text('Please wait...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                    : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please contact admin to reset your access code'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: Text(
            'Forget your access code?',
            style: TextStyle(
              color: AppColor.subText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 5),
            Text(
              'SECURED END-TO-END',
              style: TextStyle(fontSize: 10, color: AppColor.subText, letterSpacing: 1),
            ),
          ],
        ),
      ],
    );
  }
}