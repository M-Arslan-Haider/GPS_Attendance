// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../constants.dart';
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
//   bool isLoading = false;
//   bool isButtonDisabled = false;
//   String? errorMessage;
//
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
//   bool isOffline = false;
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
//     _loadSavedCompanyCode();
//
//     connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
//       final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
//       setState(() => isOffline = result == ConnectivityResult.none);
//     });
//   }
//
//   Future<void> _loadSavedCompanyCode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCode = prefs.getString(prefCompanyCode);
//     if (savedCode != null && savedCode.isNotEmpty) {
//       companyCodeController.text = savedCode;
//     }
//   }
//
//   @override
//   void dispose() {
//     companyCodeController.dispose();
//     connectivitySubscription?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<bool> _hasInternet() async {
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 5));
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade400 : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(20),
//       ),
//     );
//   }
//
//   Future<void> _validateCompanyCode() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       isLoading = true;
//       isButtonDisabled = true;
//       errorMessage = null;
//     });
//
//     if (!await _hasInternet()) {
//       _showSnackBar('No internet connection. Please try again.', isError: true);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//       return;
//     }
//
//     try {
//       final companyCode = companyCodeController.text.trim().toUpperCase();
//
//       if (companyCode.isEmpty) {
//         throw Exception('Please enter a valid company code');
//       }
//
//       debugPrint('📡 Fetching companies from: $companyApiEndpoint');
//
//       final response = await http
//           .get(Uri.parse(companyApiEndpoint))
//           .timeout(const Duration(seconds: 30));
//
//       if (response.statusCode != 200) {
//         throw Exception('Failed to fetch company data');
//       }
//
//       final Map<String, dynamic> data = json.decode(response.body);
//       List<dynamic> companies = data['items'] ?? [];
//
//       if (companies.isEmpty) {
//         throw Exception('No companies found');
//       }
//
//       // Find matching company
//       final company = companies.firstWhere(
//             (c) {
//           final code = c['company_code']?.toString().toUpperCase() ?? '';
//           return code == companyCode;
//         },
//         orElse: () => null,
//       );
//
//       if (company == null) {
//         throw Exception('Company code not found');
//       }
//
//       final prefs = await SharedPreferences.getInstance();
//
//       String companyName = company['company_name'] ?? 'Unknown';
//       String workspaceName = company['workspace_name'] ?? 'production';
//
//       await prefs.setString(prefCompanyCode, companyCode);
//       await prefs.setString(prefCompanyName, companyName);
//       await prefs.setString(prefWorkspaceName, workspaceName);
//
//       _showSnackBar('Company verified successfully!');
//
//       await Future.delayed(const Duration(milliseconds: 800));
//
//       if (mounted) {
//         // Navigate to permissions screen
//         Get.toNamed('/permissions');
//       }
//
//     } catch (e) {
//       String errorMsg = e.toString().replaceAll('Exception: ', '');
//       setState(() {
//         errorMessage = errorMsg;
//       });
//       _showSnackBar(errorMsg, isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isButtonDisabled = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Stack(
//           children: [
//             // Background design
//             Positioned(
//               top: -100,
//               right: -50,
//               child: Transform.rotate(
//                 angle: -0.2,
//                 child: Container(
//                   width: 300,
//                   height: 300,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(80),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blueGrey.withOpacity(0.4),
//                         Colors.blueGrey.withOpacity(0.1),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 50,
//               left: -30,
//               child: Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.blueGrey.withOpacity(0.05),
//                 ),
//               ),
//             ),
//
//             SafeArea(
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'BOOK IT',
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1F2937),
//                             ),
//                           ),
//                           const SizedBox(height: 40),
//                           _buildMainCard(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             if (isOffline)
//               Positioned(
//                 top: 10,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   color: Colors.amber.shade700,
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.wifi_off, color: Colors.white, size: 18),
//                       SizedBox(width: 8),
//                       Text(
//                         'Offline Mode',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
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
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: darkText,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Enter your unique company code to continue.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: subText,
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextFormField(
//               controller: companyCodeController,
//               textCapitalization: TextCapitalization.characters,
//               decoration: InputDecoration(
//                 hintText: 'e.g., PRODUCTION',
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
//                 errorText: errorMessage,
//                 prefixIcon: const Icon(Icons.business_center, color: Colors.blueGrey),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter company code';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 25),
//             SizedBox(
//               width: double.infinity,
//               height: 58,
//               child: ElevatedButton(
//                 onPressed: (isButtonDisabled || isOffline) ? null : _validateCompanyCode,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isOffline ? Colors.grey : darkText,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15)
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text(isOffline ? 'Offline' : 'Continue'),
//               ),
//             ),
//           ],
//         ),
//       ),
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
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

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
  bool isLoading = false;
  bool isButtonDisabled = false;
  String? errorMessage;

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  bool isOffline = false;

  // ── White & Blue Theme ─────────────────────────────────────────────────────
  static const Color _bg             = Color(0xFFF0F4FF);
  static const Color _surface        = Color(0xFFFFFFFF);
  static const Color _accentBlue     = Color(0xFF1A5CFF);
  static const Color _accentBlueDark = Color(0xFF0F3DBF);
  static const Color _accentLight    = Color(0xFFE6EDFF);
  static const Color _textPrimary    = Color(0xFF0A1931);
  static const Color _textSecondary  = Color(0xFF6B7FA8);
  static const Color _border         = Color(0xFFD0DBEE);
  static const Color _errorRed       = Color(0xFFD93025);
  // ──────────────────────────────────────────────────────────────────────────

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
    _loadSavedCompanyCode();

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      setState(() => isOffline = result == ConnectivityResult.none);
    });
  }

  Future<void> _loadSavedCompanyCode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(prefCompanyCode);
    if (savedCode != null && savedCode.isNotEmpty) {
      companyCodeController.text = savedCode;
    }
  }

  @override
  void dispose() {
    companyCodeController.dispose();
    connectivitySubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? _errorRed : _accentBlueDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _validateCompanyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      isButtonDisabled = true;
      errorMessage = null;
    });

    if (!await _hasInternet()) {
      _showSnackBar('No internet connection. Please try again.', isError: true);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    try {
      final companyCode = companyCodeController.text.trim().toUpperCase();

      if (companyCode.isEmpty) {
        throw Exception('Please enter a valid company code');
      }

      debugPrint('📡 Fetching companies from: $companyApiEndpoint');

      final response = await http
          .get(Uri.parse(companyApiEndpoint))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch company data');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> companies = data['items'] ?? [];

      if (companies.isEmpty) {
        throw Exception('No companies found');
      }

      final company = companies.firstWhere(
            (c) {
          final code = c['company_code']?.toString().toUpperCase() ?? '';
          return code == companyCode;
        },
        orElse: () => null,
      );

      if (company == null) {
        throw Exception('Company code not found');
      }

      final prefs = await SharedPreferences.getInstance();

      String companyName = company['company_name'] ?? 'Unknown';
      String workspaceName = company['workspace_name'] ?? 'production';

      await prefs.setString(prefCompanyCode, companyCode);
      await prefs.setString(prefCompanyName, companyName);
      await prefs.setString(prefWorkspaceName, workspaceName);

      _showSnackBar('Company verified successfully!');

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Get.toNamed('/permissions');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        errorMessage = errorMsg;
      });
      _showSnackBar(errorMsg, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ── Decorative background blobs ──────────────────────────────
            Positioned(
              top: -60,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentBlue.withOpacity(0.12),
                      _accentBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentBlueDark.withOpacity(0.10),
                      _accentBlueDark.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Dot grid overlay ─────────────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _DotGridPainter()),
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
                          // ── App icon ───────────────────────────────
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _accentBlue,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentBlue.withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.how_to_reg_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Title ──────────────────────────────────
                          const Text(
                            'Attendance System',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Track. Manage. Simplify.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 36),

                          _buildMainCard(),
                          const SizedBox(height: 28),

                          // ── Footer ─────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 13, color: _textSecondary.withOpacity(0.7)),
                              const SizedBox(width: 5),
                              Text(
                                'Secured & Encrypted Connection',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary.withOpacity(0.7),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Offline banner ────────────────────────────────────────────
            if (isOffline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  color: const Color(0xFFF59E0B),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _accentBlue.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.corporate_fare_rounded,
                    color: _accentBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Company Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Provided by your administrator',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),
            Divider(color: _border, height: 1),
            const SizedBox(height: 22),

            // ── Input label ─────────────────────────────────────────────
            const Text(
              'COMPANY CODE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _textSecondary,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // ── Text field ──────────────────────────────────────────────
            TextFormField(
              controller: companyCodeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 2.5,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Code',
                hintStyle: TextStyle(
                  color: _textSecondary.withOpacity(0.45),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F9FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accentBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _errorRed, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _errorRed, width: 2),
                ),
                errorText: errorMessage,
                errorStyle: const TextStyle(color: _errorRed, fontSize: 12),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a company code';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            // ── Submit button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (isButtonDisabled || isOffline) ? null : _validateCompanyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOffline ? const Color(0xFFCBD5E1) : _accentBlue,
                  foregroundColor: isOffline ? _textSecondary : Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: isOffline ? 0 : 6,
                  shadowColor: _accentBlue.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOffline ? 'Offline' : 'Verify & Continue',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (!isOffline) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subtle dot-grid background painter ────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A5CFF).withOpacity(0.055)
      ..strokeCap = StrokeCap.round;

    const spacing = 28.0;
    const radius = 1.4;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}