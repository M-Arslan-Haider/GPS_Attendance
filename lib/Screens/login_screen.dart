//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../ViewModels/login_view_model.dart';
// import '../../constants.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final LoginViewModel loginViewModel = Get.find<LoginViewModel>();
//
//   final _formKey = GlobalKey<FormState>();
//   bool isChecked = false;
//   bool isPasswordVisible = false;
//   bool isLoading = false;
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   // ── White & Blue Theme (matches CodeScreen) ────────────────────────────────
//   static const Color _bg             = Color(0xFFF0F4FF);
//   static const Color _surface        = Color(0xFFFFFFFF);
//   static const Color _accentBlue     = Color(0xFF1A5CFF);
//   static const Color _accentBlueDark = Color(0xFF0F3DBF);
//   static const Color _accentLight    = Color(0xFFE6EDFF);
//   static const Color _textPrimary    = Color(0xFF0A1931);
//   static const Color _textSecondary  = Color(0xFF6B7FA8);
//   static const Color _border         = Color(0xFFD0DBEE);
//   static const Color _errorRed       = Color(0xFFD93025);
//   // ──────────────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
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
//     _loadSavedCredentials();
//   }
//
//   Future<void> _loadSavedCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     final rememberMe = prefs.getBool(prefRememberMe) ?? false;
//     setState(() => isChecked = rememberMe);
//     if (rememberMe) {
//       final savedUserId = prefs.getString(prefSavedUserId);
//       if (savedUserId != null) _userIdController.text = savedUserId;
//     }
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => isLoading = true);
//
//     try {
//       final success = await loginViewModel.login(
//         _userIdController.text.trim(),
//         _passwordController.text.trim(),
//       );
//
//       if (success) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool(prefRememberMe, isChecked);
//         if (isChecked) {
//           await prefs.setString(prefSavedUserId, _userIdController.text.trim());
//         }
//         Get.snackbar('Success', 'Login successful!');
//         String route = loginViewModel.getHomeRoute();
//         await Future.delayed(const Duration(milliseconds: 500));
//         Get.offAllNamed(route);
//       } else {
//         Get.snackbar(
//           'Error',
//           loginViewModel.loginError.value,
//           backgroundColor: _errorRed,
//           colorText: Colors.white,
//         );
//       }
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _passwordController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Stack(
//           children: [
//             // ── Decorative background blobs ──────────────────────────────
//             Positioned(
//               top: -60,
//               right: -80,
//               child: Container(
//                 width: 280,
//                 height: 280,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       _accentBlue.withOpacity(0.12),
//                       _accentBlue.withOpacity(0.0),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: -80,
//               left: -60,
//               child: Container(
//                 width: 300,
//                 height: 300,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       _accentBlueDark.withOpacity(0.10),
//                       _accentBlueDark.withOpacity(0.0),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ── Dot grid overlay ─────────────────────────────────────────
//             Positioned.fill(
//               child: CustomPaint(painter: _DotGridPainter()),
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
//                           // ── App icon ───────────────────────────────
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: _accentBlue,
//                               borderRadius: BorderRadius.circular(24),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: _accentBlue.withOpacity(0.35),
//                                   blurRadius: 24,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.how_to_reg_rounded,
//                               color: Colors.white,
//                               size: 38,
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//
//                           // ── Title ──────────────────────────────────
//                           const Text(
//                             'Welcome Back',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w800,
//                               color: _textPrimary,
//                               letterSpacing: -0.5,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Sign in to your account to continue.',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: _textSecondary,
//                               letterSpacing: 0.2,
//                             ),
//                           ),
//                           const SizedBox(height: 25),
//
//                           // ── Main card ─────────────────────────────
//                           _buildLoginCard(),
//                           const SizedBox(height: 15),
//
//                           // ── Footer ─────────────────────────────────
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.lock_outline_rounded,
//                                   size: 13, color: _textSecondary.withOpacity(0.7)),
//                               const SizedBox(width: 5),
//                               Text(
//                                 'Secured & Encrypted Connection',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: _textSecondary.withOpacity(0.7),
//                                   letterSpacing: 0.2,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoginCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: _border, width: 1.2),
//         boxShadow: [
//           BoxShadow(
//             color: _accentBlue.withOpacity(0.08),
//             blurRadius: 40,
//             offset: const Offset(0, 16),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Card header ─────────────────────────────────────────────
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(9),
//                   decoration: BoxDecoration(
//                     color: _accentLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.badge_rounded,
//                     color: _accentBlue,
//                     size: 18,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Employee Login',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: _textPrimary,
//                       ),
//                     ),
//                     Text(
//                       'Use your credentials to sign in',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: _textSecondary.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//             Divider(color: _border, height: 1),
//             const SizedBox(height: 15),
//
//             // ── Employee ID ─────────────────────────────────────────────
//             const Text(
//               'EMPLOYEE ID',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: _textSecondary,
//                 letterSpacing: 1.4,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _userIdController,
//               style: const TextStyle(
//                 color: _textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Enter your employee ID',
//                 hintStyle: TextStyle(
//                   color: _textSecondary.withOpacity(0.45),
//                   fontWeight: FontWeight.w400,
//                   fontSize: 14,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF7F9FF),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _border, width: 1.2),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _border, width: 1.2),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _accentBlue, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _errorRed, width: 1.5),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _errorRed, width: 2),
//                 ),
//                 errorStyle: const TextStyle(color: _errorRed, fontSize: 12),
//                 prefixIcon: const Padding(
//                   padding: EdgeInsets.only(left: 14, right: 10),
//                   child: Icon(Icons.person_outline_rounded, color: _accentBlue, size: 20),
//                 ),
//                 prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) return 'Please enter employee ID';
//                 return null;
//               },
//             ),
//
//             const SizedBox(height: 20),
//
//             // ── Password ────────────────────────────────────────────────
//             const Text(
//               'PASSWORD',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: _textSecondary,
//                 letterSpacing: 1.4,
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !isPasswordVisible,
//               style: const TextStyle(
//                 color: _textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Enter your password',
//                 hintStyle: TextStyle(
//                   color: _textSecondary.withOpacity(0.45),
//                   fontWeight: FontWeight.w400,
//                   fontSize: 14,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF7F9FF),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _border, width: 1.2),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _border, width: 1.2),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _accentBlue, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _errorRed, width: 1.5),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: _errorRed, width: 2),
//                 ),
//                 errorStyle: const TextStyle(color: _errorRed, fontSize: 12),
//                 prefixIcon: const Padding(
//                   padding: EdgeInsets.only(left: 14, right: 10),
//                   child: Icon(Icons.lock_outline_rounded, color: _accentBlue, size: 20),
//                 ),
//                 prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     isPasswordVisible
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: _textSecondary,
//                     size: 20,
//                   ),
//                   onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) return 'Please enter password';
//                 return null;
//               },
//             ),
//
//             const SizedBox(height: 16),
//
//             // ── Remember me ─────────────────────────────────────────────
//             Row(
//               children: [
//                 SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: Checkbox(
//                     value: isChecked,
//                     onChanged: (v) => setState(() => isChecked = v ?? false),
//                     activeColor: _accentBlue,
//                     side: const BorderSide(color: _border, width: 1.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Remember me',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: _textSecondary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // ── Sign in button ──────────────────────────────────────────
//             SizedBox(
//               width: double.infinity,
//               height: 54,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _accentBlue,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: const Color(0xFFCBD5E1),
//                   elevation: 6,
//                   shadowColor: _accentBlue.withOpacity(0.4),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2.5,
//                   ),
//                 )
//                     : const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Sign In',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Icon(Icons.arrow_forward_rounded, size: 18),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Subtle dot-grid background painter ────────────────────────────────────────
// class _DotGridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF1A5CFF).withOpacity(0.055)
//       ..strokeCap = StrokeCap.round;
//
//     const spacing = 28.0;
//     const radius = 1.4;
//
//     for (double x = 0; x < size.width; x += spacing) {
//       for (double y = 0; y < size.height; y += spacing) {
//         canvas.drawCircle(Offset(x, y), radius, paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ViewModels/login_view_model.dart';
import '../../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel loginViewModel = Get.find<LoginViewModel>();

  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color _accentBlue    = Color(0xFF4354E8);
  static const Color _accentLight   = Color(0xFFEBEEFD);
  static const Color _textPrimary   = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border        = Color(0xFFE5E7EB);
  static const Color _errorRed      = Color(0xFFD93025);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(prefRememberMe) ?? false;
    setState(() => isChecked = rememberMe);
    if (rememberMe) {
      final savedUserId = prefs.getString(prefSavedUserId);
      if (savedUserId != null) _userIdController.text = savedUserId;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final success = await loginViewModel.login(
        _userIdController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(prefRememberMe, isChecked);
        if (isChecked) {
          await prefs.setString(
              prefSavedUserId, _userIdController.text.trim());
        }
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: _accentBlue,
          colorText: Colors.white,
        );
        String route = loginViewModel.getHomeRoute();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(route);
      } else {
        Get.snackbar(
          'Error',
          loginViewModel.loginError.value,
          backgroundColor: _errorRed,
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ── Background blobs (same as location/camera/notification) ───
            Positioned(
              top: -100,
              right: -50,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    gradient: LinearGradient(
                      colors: [
                        _accentBlue.withOpacity(0.18),
                        _accentBlue.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentBlue.withOpacity(0.05),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // ── Circle icon ───────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _accentLight,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _accentBlue.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.how_to_reg_rounded,
                            size: 70,
                            color: _accentBlue,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Title ─────────────────────────────────────────
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sign in to your account to continue.',
                          style: TextStyle(
                            fontSize: 16,
                            color: subText,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // ── Form ──────────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Employee ID
                              TextFormField(
                                controller: _userIdController,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Employee ID',
                                  hintStyle: TextStyle(
                                    color: _textSecondary.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F6FA),
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: _textSecondary,
                                    size: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _accentBlue, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _errorRed, width: 1.5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _errorRed, width: 2),
                                  ),
                                  errorStyle: const TextStyle(
                                      color: _errorRed, fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter employee ID';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !isPasswordVisible,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    color: _textSecondary.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F6FA),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: _textSecondary,
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                    isPasswordVisible = !isPasswordVisible),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _accentBlue, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _errorRed, width: 1.5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: _errorRed, width: 2),
                                  ),
                                  errorStyle: const TextStyle(
                                      color: _errorRed, fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Remember me
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: isChecked,
                                      onChanged: (v) =>
                                          setState(() => isChecked = v ?? false),
                                      activeColor: _accentBlue,
                                      side: const BorderSide(
                                          color: _border, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Sign In Button ────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                              const Color(0xFFCBD5E1),
                              elevation: 4,
                              shadowColor: _accentBlue.withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Footer ────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 13,
                                color: _textSecondary.withOpacity(0.6)),
                            const SizedBox(width: 5),
                            Text(
                              'Secured & Encrypted Connection',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
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
}