// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../login_screen.dart';
// import '../Components/WidgetsComponents/contect_widget.dart';
// import '../Components/WidgetsComponents/custom_button.dart';
// import '../Components/WidgetsComponents/header_widget.dart';
//
// class StorageScreen extends StatelessWidget {
//   const StorageScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     // Static content for the screen
//     const IconData icon = Icons.storage_rounded;
//     const String headerText = "Storage Permission";
//     const String descriptionText =
//         "Grant storage access to save and retrieve files during app usage.";
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(color: Colors.white),
//           // Header Widget
//           Positioned(
//             bottom: screenHeight * 0.6,
//             top: 0,
//             left: 0,
//             right: 0,
//             child: HeaderWidget(
//               icon: icon,
//               screenWidth: screenWidth,
//             ),
//           ),
//           // Content Widget
//           Positioned(
//             top: screenHeight * 0.4,
//             left: 0,
//             right: 0,
//             child: ContentWidget(
//               headerText: headerText,
//               descriptionText: descriptionText,
//               highlightedIndex: 6,
//             ),
//           ),
//           // Custom Button
//           Positioned(
//             bottom: screenHeight * 0.05,
//             left: screenWidth * 0.1,
//             right: screenWidth * 0.1,
//             child: CustomButton(
//               buttonText: 'ALLOW',
//               onPressed: () async {
//                 debugPrint("Requesting storage permission...");
//                 PermissionStatus storageStatus = await Permission.mediaLibrary.request();
//                 // PermissionStatus storageStatus = await Permission.manageExternalStorage.request();
//                 // PermissionStatus storageStatus = await Permission.storage.request();
//
//                 debugPrint("Permission status: $storageStatus");
//
//                 if (storageStatus.isGranted) {
//                   debugPrint("Permission granted, navigating to LoginScreen");
//                   Get.to(() => const LoginScreen());
//                 } else if (storageStatus.isDenied) {
//                   debugPrint("Permission permanently denied, opening app settings");
//                   Get.snackbar(
//                     'Permission Required',
//                     'Please enable storage permission in the app settings.',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.redAccent,
//                     colorText: Colors.white,
//                     mainButton: TextButton(
//                       onPressed: () async {
//                         await openAppSettings();
//                       },
//                       child: Text('Open Settings'),
//                     ),
//                   );
//                 } else {
//                   debugPrint("Permission denied, showing snackbar");
//                   Get.snackbar(
//                     'Permission Denied',
//                     'You need to allow storage permission to proceed.',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.redAccent,
//                     colorText: Colors.white,
//                   );
//                 }
//               },
//             )
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart' as AppColors;
import '../login_screen.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  Icons.stop_rounded,
                  size: 70,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Storage Permission",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "Grant storage access to save and retrieve files during app usage.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              // const Text(
              //   "Storage Permission",
              //   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   "Grant storage access to save and retrieve files during app usage.",
              //   style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.45),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    debugPrint("Requesting storage permission...");
                    PermissionStatus storageStatus = await Permission.mediaLibrary.request();

                    debugPrint("Permission status: $storageStatus");

                    if (storageStatus.isGranted) {
                      debugPrint("Permission granted, navigating to LoginScreen");
                      Get.to(() => const LoginScreen());
                    } else {
                      debugPrint("Permission denied, showing snackbar");
                      Get.snackbar(
                        'Permission Required',
                        'Please enable storage permission in settings.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        mainButton: TextButton(
                          onPressed: () async => await openAppSettings(),
                          child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
                        ),
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
                  child: const Text("ALLOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Get.to(() => const LoginScreen()),
                child: const Text("", style: TextStyle(fontSize: 16, color: Color(0xFF1976D2), fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
      ]
      )
    );
  }
}