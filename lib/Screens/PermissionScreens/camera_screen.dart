// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:permission_handler/permission_handler.dart';
// // //
// // // import '../../ViewModels/login_view_model.dart';
// // // import 'location_screen.dart';
// // // import '../Components/WidgetsComponents/contect_widget.dart';
// // // import '../Components/WidgetsComponents/custom_button.dart';
// // // import '../Components/WidgetsComponents/header_widget.dart';
// // //
// // // class CameraScreen extends StatelessWidget {
// // //   const CameraScreen({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //
// // //     final screenHeight = MediaQuery.of(context).size.height;
// // //     final screenWidth = MediaQuery.of(context).size.width;
// // //
// // //     // Dynamic data for the widgets
// // //     const IconData icon = Icons.camera_alt_rounded;
// // //     const String headerText = "Camera Permission";
// // //     const String descriptionText = "Allow access to use the camera feature.";
// // //
// // //     return Scaffold(
// // //       body: Stack(
// // //         children: [
// // //           Container(color: Colors.white),
// // //           Positioned(
// // //             bottom: screenHeight * 0.6,
// // //             top: 0,
// // //             left: 0,
// // //             right: 0,
// // //             child: HeaderWidget(
// // //               icon: icon,
// // //               screenWidth: screenWidth,
// // //             ),
// // //           ),
// // //           Positioned(
// // //             top: screenHeight * 0.4,
// // //             left: 0,
// // //             right: 0,
// // //             child: ContentWidget(
// // //               headerText: headerText,
// // //               descriptionText: descriptionText,
// // //               highlightedIndex: 0,
// // //             ),
// // //           ),
// // //           Positioned(
// // //             bottom: screenHeight * 0.05,
// // //             left: screenWidth * 0.1,
// // //             right: screenWidth * 0.1,
// // //             child: CustomButton(
// // //               buttonText: 'ALLOW',
// // //               onPressed: () async {
// // //                 // Request camera permission
// // //                 PermissionStatus cameraStatus = await Permission.camera.request();
// // //
// // //                 if (cameraStatus.isGranted) {
// // //                   // Navigate to the LocationScreen
// // //                   Get.to(() => const LocationScreen());
// // //                 } else {
// // //                   // Show a snackbar if permission is denied
// // //                   Get.snackbar(
// // //                     'Permission Denied',
// // //                     'You need to allow camera permission to continue.',
// // //                     snackPosition: SnackPosition.BOTTOM,
// // //                     backgroundColor: Colors.redAccent,
// // //                     colorText: Colors.white,
// // //                   );
// // //                 }
// // //               },
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// //
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../ViewModels/login_view_model.dart';
// import 'location_screen.dart';
// import '../Components/WidgetsComponents/contect_widget.dart'; // ← you can remove if not needed
// import '../Components/WidgetsComponents/custom_button.dart';   // ← we'll replace CustomButton usage
// import '../Components/WidgetsComponents/header_widget.dart';  // ← can remove if not needed
//
// class CameraScreen extends StatelessWidget {
//   const CameraScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//           // Elegant background circles (from 1st screen)
//           Positioned(
//           top: -80,
//           right: -120,
//           child: Container(
//             width: 260,
//             height: 260,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.blueGrey.withOpacity(0.55),
//             ),
//           ),
//         ),
//         Positioned(
//           top: -80,
//           left: -140,
//           child: Container(
//             width: 420,
//             height: 420,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.blueGrey.withOpacity(0.45),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Large centered icon
//               Container(
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.08),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt_rounded,
//                   size: 80,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//
//               const SizedBox(height: 48),
//
//               // Header
//               const Text(
//                 "Camera Permission",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               const SizedBox(height: 16),
//
//               // Description
//               const Text(
//                 "Allow access to use the camera feature.\n"
//                     "This helps you capture photos and videos directly in the app.",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black54,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               const SizedBox(height: 64),
//
//               // Allow Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     PermissionStatus cameraStatus = await Permission.camera.request();
//
//                     if (cameraStatus.isGranted) {
//                       Get.to(() => const LocationScreen());
//                     } else {
//                       Get.snackbar(
//                         'Permission Denied',
//                         'You need to allow camera permission to continue.',
//                         snackPosition: SnackPosition.BOTTOM,
//                         backgroundColor: Colors.redAccent,
//                         colorText: Colors.white,
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   child: const Text(
//                     "ALLOW",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Maybe Later
//               GestureDetector(
//                 onTap: () {
//                   // Option A: exit app    →  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//                   // Option B: skip to next →  Get.to(() => const LocationScreen());
//                   // For now: just snackbar example
//                   Get.snackbar("Skipped", "You can enable later in settings");
//                 },
//                 child: const Text(
//                   "",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//   ]
//       )
//     )
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart' as AppColors;
import 'location_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light greyish white for better contrast
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

          // --- CONTENT ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container with Shadow
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 70,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Camera Permission",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Allow access to use the camera feature.\nThis helps you capture photos and videos.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () async {
                        PermissionStatus status = await Permission.camera.request();
                        if (status.isGranted) {
                          Get.to(() => const LocationScreen());
                        } else {
                          Get.snackbar(
                            'Access Required',
                            'Please enable camera access in settings.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(15),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3436), // Darker for "Attack" design feel
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "ALLOW",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TextButton(
                  //   onPressed: () => Get.back(),
                  //   child: const Text(
                  //     "Maybe Later",
                  //     style: TextStyle(
                  //       color: Colors.blueGrey,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}