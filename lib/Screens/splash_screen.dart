import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'code_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
          () {
         Get.offNamed("/cameraScreen");
           // Get.to(() => const CodeScreen());
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue, // Blue background
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.4), // 40% from the top
                child: const Text(
                  "BOOK IT",
                  style: TextStyle(
                    color: Colors.white, // White text color for contrast
                    fontSize: 40, // Font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Copyright Text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.4), // Responsive padding
                child: const Text(
                  "© Powered by MetaXperts",
                  style: TextStyle(
                    color: Colors.white, // White text color for contrast
                    fontSize: 20, // Responsive font size
                    fontWeight: FontWeight.bold,
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