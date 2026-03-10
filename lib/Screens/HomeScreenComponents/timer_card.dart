import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Database/util.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../../ViewModels/location_view_model.dart';
import '../../constants.dart';


class TimerCard extends StatelessWidget {
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;

  const TimerCard({
    super.key,
    required this.onClockIn,
    required this.onClockOut,
  });

  @override
  Widget build(BuildContext context) {
    // Use Get.find with a try-catch to handle if ViewModel isn't ready yet
    AttendanceViewModel? attendanceVM;
    LocationViewModel? locationVM;

    try {
      attendanceVM = Get.find<AttendanceViewModel>();
      locationVM = Get.find<LocationViewModel>();
    } catch (e) {
      // Return loading indicator if ViewModels aren't ready
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Obx(() {
      // Safe access with null checks
      final bool isClockedIn = attendanceVM?.isClockedIn.value ?? false;
      final String elapsedTime = attendanceVM?.elapsedTime.value ?? '00:00:00';
      final String currentAddress = locationVM?.currentAddress.value ?? 'Getting location...';

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isClockedIn
                  ? [Colors.green.shade50, Colors.green.shade100]
                  : [Colors.blueGrey.shade50, Colors.blueGrey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Employee Info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isClockedIn ? Colors.green : Colors.blueGrey,
                    child: Text(
                      emp_name.isNotEmpty ? emp_name[0].toUpperCase() : 'E',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp_name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          emp_job,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClockedIn ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isClockedIn ? 'ACTIVE' : 'INACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Timer Display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: isClockedIn ? Colors.green : Colors.blueGrey,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      elapsedTime,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isClockedIn ? Colors.green.shade700 : Colors.blueGrey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Info (if clocked in)
              if (isClockedIn) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: Colors.blueGrey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentAddress,
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Clock In/Out Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      onPressed: isClockedIn ? null : onClockIn,
                      label: 'CLOCK IN',
                      icon: LucideIcons.logIn,
                      color: Colors.green,
                      isEnabled: !isClockedIn,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildButton(
                      onPressed: isClockedIn ? onClockOut : null,
                      label: 'CLOCK OUT',
                      icon: LucideIcons.logOut,
                      color: Colors.red,
                      isEnabled: isClockedIn,
                    ),
                  ),
                ],
              ),

              if (isClockedIn) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tracking active',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required bool isEnabled,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey.shade300,
        foregroundColor: isEnabled ? Colors.white : Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isEnabled ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}