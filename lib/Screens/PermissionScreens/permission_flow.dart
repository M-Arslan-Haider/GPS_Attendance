import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'camera_screen.dart';
import 'location_screen.dart';
import 'notification_screen.dart';

class PermissionsFlow extends StatefulWidget {
  const PermissionsFlow({super.key});

  @override
  State<PermissionsFlow> createState() => _PermissionsFlowState();
}

class _PermissionsFlowState extends State<PermissionsFlow> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const LocationScreen(),
    const CameraScreen(),
    const NotificationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All permissions done, go to login
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens.map((screen) {
          if (screen is LocationScreen) {
            return LocationScreen(onNext: _nextPage);
          } else if (screen is CameraScreen) {
            return CameraScreen(onNext: _nextPage);
          } else if (screen is NotificationScreen) {
            return NotificationScreen(onNext: _nextPage);
          }
          return screen;
        }).toList(),
      ),
    );
  }
}