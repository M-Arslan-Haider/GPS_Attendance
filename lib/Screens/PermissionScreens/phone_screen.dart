// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../Components/WidgetsComponents/contect_widget.dart';
// import '../Components/WidgetsComponents/custom_button.dart';
// import '../Components/WidgetsComponents/header_widget.dart';
// import 'record_audio_screen.dart';
//
// class PhoneScreen extends StatelessWidget {
//   const PhoneScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     // Define dynamic content for the screen
//     const IconData icon = Icons.phone;
//     const String headerText = "Phone Permission";
//     const String descriptionText =
//         "Grant phone access to make calls directly from the app.";
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(color: Colors.white),
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
//           Positioned(
//             top: screenHeight * 0.4,
//             left: 0,
//             right: 0,
//             child: ContentWidget(
//               headerText: headerText,
//               descriptionText: descriptionText,
//               highlightedIndex: 4,
//             ),
//           ),
//           Positioned(
//             bottom: screenHeight * 0.05,
//             left: screenWidth * 0.1,
//             right: screenWidth * 0.1,
//             child: CustomButton(
//               buttonText: 'ALLOW',
//               onPressed: () async {
//                 // Request phone permission
//                 Get.to(() => const RecordAudioScreen());
//                 PermissionStatus phoneStatus = await Permission.phone.request();
//
//                 if (phoneStatus.isGranted) {
//                   // Navigate to RecordAudioScreen
//                   Get.to(() => const RecordAudioScreen());
//                 } else {
//                   // Show a snackbar if permission is denied
//                   Get.snackbar(
//                     'Permission Denied',
//                     'You need to allow phone permission to proceed.',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.redAccent,
//                     colorText: Colors.white,
//                   );
//                 }
//               },
//             ),
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
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';
import 'record_audio_screen.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({Key? key}) : super(key: key);

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
                  Icons.phone,
                  size: 70,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Phone Permission",
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
                "Grant phone access to make calls directly from the app.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    PermissionStatus phoneStatus = await Permission.phone.request();
                    if (phoneStatus.isGranted) {
                      Get.to(() => const RecordAudioScreen());
                    } else {
                      Get.snackbar('Permission Denied', 'You need to allow phone permission to proceed.',
                          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
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
                onTap: () => Get.to(() => const RecordAudioScreen()),
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