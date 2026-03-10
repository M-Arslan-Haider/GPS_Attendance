import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/util.dart';
import '../viewmodels/attendance_view_model.dart';
import '../viewmodels/attendance_out_view_model.dart';
import '../viewmodels/location_view_model.dart';
import '../../constants.dart';
import 'HomeScreenComponents/timer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Don't initialize here - do it in initState
  late final AttendanceViewModel attendanceVM;
  late final AttendanceOutViewModel attendanceOutVM;
  late final LocationViewModel locationVM;

  String employeeName = '';
  String employeeId = '';

  @override
  void initState() {
    super.initState();

    // ✅ Initialize ViewModels FIRST before any other operations
    _initializeViewModels();

    // Then load employee data
    _loadEmployeeData();
  }

  // ✅ Separate method to initialize ViewModels
  void _initializeViewModels() {
    // Check if already registered to avoid duplicates
    if (!Get.isRegistered<AttendanceViewModel>()) {
      attendanceVM = Get.put(AttendanceViewModel(), permanent: true);
    } else {
      attendanceVM = Get.find<AttendanceViewModel>();
    }

    if (!Get.isRegistered<AttendanceOutViewModel>()) {
      attendanceOutVM = Get.put(AttendanceOutViewModel(), permanent: true);
    } else {
      attendanceOutVM = Get.find<AttendanceOutViewModel>();
    }

    if (!Get.isRegistered<LocationViewModel>()) {
      locationVM = Get.put(LocationViewModel(), permanent: true);
    } else {
      locationVM = Get.find<LocationViewModel>();
    }
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString(prefUserName) ?? '';
      employeeId = prefs.getString(prefUserId) ?? '';
    });
  }

  // 🎯 Clock In - Just calls ViewModel
  Future<void> _handleClockIn() async {
    await attendanceVM.clockIn();
  }

  // 🎯 Clock Out - Just calls ViewModel
  Future<void> _handleClockOut() async {
    await attendanceVM.clockOut();
  }

  // 🎯 Manual Location Save
  Future<void> _handleSaveLocation() async {
    await locationVM.saveLocationWithGPX();
  }

  // 🎯 Manual Sync
  Future<void> _handleSync() async {
    if (!await isNetworkAvailable()) {
      Get.snackbar(
        'No Internet',
        'Please check your connection',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await attendanceVM.syncUnposted();
      await attendanceOutVM.syncUnposted();
      await locationVM.syncUnposted();

      Get.back();

      Get.snackbar(
        'Sync Complete',
        'All pending data synced',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Sync Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 20),

                // Timer Card with Clock In/Out
                TimerCard(
                  onClockIn: _handleClockIn,
                  onClockOut: _handleClockOut,
                ),

                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 20),

                // Sync Button
                _buildSyncButton(),

                const SizedBox(height: 20),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blueGrey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey,
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  employeeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: $employeeId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.location_on,
                  label: 'Save Location',
                  color: Colors.purple,
                  onTap: _handleSaveLocation,
                ),
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Refresh',
                  color: Colors.orange,
                  onTap: () {
                    attendanceVM.fetchAllAttendance();
                    attendanceOutVM.fetchAllAttendanceOut();
                    locationVM.fetchAllLocations();
                    Get.snackbar(
                      'Refreshed',
                      'Data refreshed',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return ElevatedButton.icon(
      onPressed: _handleSync,
      icon: const Icon(Icons.sync),
      label: const Text('Sync All Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Employee ID: $employeeId | v$appVersion',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
      ),
    );
  }
}