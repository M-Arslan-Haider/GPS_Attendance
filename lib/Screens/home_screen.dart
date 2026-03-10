
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../ViewModels/attendance_out_view_model.dart';
import '../ViewModels/attendance_view_model.dart';

import '../ViewModels/location_view_model.dart';
import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/timer_card.dart' hide LocationViewModel;
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ViewModels
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());

  final LocationViewModel locationVM = Get.put(LocationViewModel());

  String user_id = '';
  String userName = '';

  @override
  void initState() {
    super.initState();


    _retrieveSavedValues();

    attendanceViewModel.fetchAllAttendance(); // → Attendance IN
    attendanceOutViewModel.fetchAllAttendanceOut(); // (optional OUT)

    FlutterForegroundTask.startService(
      notificationTitle: 'Clock Running',
      notificationText: 'Tracking time and location...',
      callback: startCallback,
    );
  }

  Future<void> _retrieveSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    setState(() {
      user_id = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.blueGrey.shade50,
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive horizontal padding
              final horizontalPadding =
              constraints.maxWidth < 400 ? 12.0 : 20.0;
              final spacingBetweenRows =
              constraints.maxWidth < 400 ? 12.0 : 15.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: TimerCard(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blueGrey.shade500,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
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
          Column(
            children: [
              Navbar(),
              const SizedBox(height: 20),
              const ProfileSection(),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildFooter() {
  //   return Column(
  //     children: [
  //       Text(
  //         "$version",
  //         style: const TextStyle(
  //           // fontSize: fontSize - 1,
  //           color: Colors.black54,
  //           fontWeight: FontWeight.w500,
  //           fontStyle: FontStyle.italic,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _showClockInRequiredDialog() {
    Get.defaultDialog(
      title: "Clock In Required",
      titleStyle:
      const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
      middleText: "Please start your work timer first.",
      middleTextStyle: TextStyle(color: Colors.blueGrey.shade600),
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueGrey,
      radius: 12,
      onConfirm: Get.back,
    );
  }
}

// Foreground task handler
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool restart) async {}
}
