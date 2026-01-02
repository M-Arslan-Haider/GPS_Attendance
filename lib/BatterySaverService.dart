// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/location_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BatterySaverService {
//   static const MethodChannel _channel = MethodChannel('battery_saver_channel');
//   static Timer? _monitoringTimer;
//   static bool _isMonitoring = false;
//   static bool _wasBatterySaverOn = false;
//
//   /// Check if battery saver is ON
//   static Future<bool> isBatterySaverOn() async {
//     try {
//       final bool result = await _channel.invokeMethod('isBatterySaverOn');
//       return result;
//     } catch (e) {
//       debugPrint('Error checking battery saver: $e');
//       return false;
//     }
//   }
//
//   /// Open Battery Saver settings
//   static Future<void> openBatterySaverSettings() async {
//     try {
//       await _channel.invokeMethod('openBatterySaverSettings');
//     } catch (e) {
//       debugPrint('Error opening battery saver settings: $e');
//     }
//   }
//
//   /// Show strict battery saver dialog (like location dialog)
//   static Future<bool> showStrictBatterySaverDialog(BuildContext context) async {
//     try {
//       bool? result = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.9,
//               maxHeight: MediaQuery.of(context).size.height * 0.8,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.battery_alert, color: Colors.orange, size: 28),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'Battery Saver Detected',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange.shade800,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Content
//                   Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Warning message
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.red.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.error_outline, color: Colors.red, size: 24),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   'Battery Saver is ON',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 20),
//
//                         // Instructions
//                         Text(
//                           'For accurate GPS tracking and best performance:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//
//                         SizedBox(height: 12),
//
//                         _buildCompactStep('1. Go to Settings', Icons.settings),
//                         _buildCompactStep('2. Find "Battery"', Icons.battery_std),
//                         _buildCompactStep('3. Turn OFF Power Saving', Icons.power_settings_new),
//
//                         SizedBox(height: 20),
//
//                         // Note
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                               SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Clock-In is not allowed while Battery Saver is active.',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Actions
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: Text('CANCEL', style: TextStyle(color: Colors.grey.shade700)),
//                         ),
//                         SizedBox(width: 12),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             openBatterySaverSettings();
//                             Navigator.pop(context, true);
//                           },
//                           icon: Icon(Icons.settings, size: 18),
//                           label: Text('SETTINGS'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//
//       return result ?? false;
//     } catch (e) {
//       debugPrint('Error showing battery saver dialog: $e');
//       return false;
//     }
//   }
//
//   /// Show battery saver dialog specifically for clock-in blocking
//   static Future<bool> showBatterySaverClockInDialog(BuildContext context) async {
//     try {
//       bool? result = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.9,
//               maxHeight: MediaQuery.of(context).size.height * 0.8,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade100,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.battery_alert, color: Colors.orange, size: 24),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Clock-In Blocked',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange.shade900,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Battery Saver is ON',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.orange.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Content
//                   Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Warning
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.red.shade200),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.block, color: Colors.red, size: 20),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'CLOCK-IN NOT ALLOWED',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'GPS tracking requires full battery optimization for accurate attendance marking.',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 20),
//
//                         // Steps to fix
//                         Text(
//                           'To enable Clock-In:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                             color: Colors.grey.shade800,
//                           ),
//                         ),
//
//                         SizedBox(height: 12),
//
//                         _buildSimpleStep(1, 'Open Battery Settings'),
//                         _buildSimpleStep(2, 'Turn OFF Power Saving Mode'),
//                         _buildSimpleStep(3, 'Return to this app'),
//
//                         SizedBox(height: 20),
//
//                         // Important note
//                         Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue.shade100),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(Icons.warning_amber, color: Colors.blue, size: 18),
//                               SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Note: Keeping Battery Saver ON may cause automatic clock-out and inaccurate location tracking.',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.blue.shade800,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Actions
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(16),
//                         bottomRight: Radius.circular(16),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () => Navigator.pop(context, false),
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                             ),
//                             child: Text(
//                               'LATER',
//                               style: TextStyle(
//                                 color: Colors.grey.shade700,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               openBatterySaverSettings();
//                               Navigator.pop(context, true);
//                             },
//                             icon: Icon(Icons.settings, size: 18),
//                             label: Text('FIX NOW'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange,
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//
//       return result ?? false;
//     } catch (e) {
//       debugPrint('Error showing battery saver clock-in dialog: $e');
//       return false;
//     }
//   }
//
//   static Widget _buildCompactStep(String text, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.blue.shade700),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildSimpleStep(int number, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 '$number',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Start periodic monitoring WITH AUTO CLOCK-OUT
//   static void startMonitoring() {
//     if (_isMonitoring) {
//       _monitoringTimer?.cancel();
//     }
//
//     _isMonitoring = true;
//     _wasBatterySaverOn = false;
//
//     _monitoringTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//       try {
//         bool currentStatus = await isBatterySaverOn();
//         bool isClockedIn = await _isUserClockedIn();
//
//         debugPrint('🔋 [BATTERY] Status: $currentStatus | Clocked In: $isClockedIn | Was: $_wasBatterySaverOn');
//
//         // ✅ AUTO CLOCK-OUT LOGIC
//         if (isClockedIn && currentStatus && !_wasBatterySaverOn) {
//           debugPrint('🚨 [BATTERY] Auto Clock-Out triggered!');
//           await _performAutoClockOut();
//         }
//
//         _wasBatterySaverOn = currentStatus;
//       } catch (e) {
//         debugPrint('Error in battery monitoring: $e');
//       }
//     });
//   }
//
//   /// Check if user is clocked in
//   static Future<bool> _isUserClockedIn() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       return prefs.getBool('isClockedIn') ?? false;
//     } catch (e) {
//       debugPrint('Error checking clock-in status: $e');
//       return false;
//     }
//   }
//
//   /// Perform auto clock-out
//   static Future<void> _performAutoClockOut() async {
//     try {
//       debugPrint('🔄 [BATTERY] Starting auto clock-out process...');
//
//       // 1. Get ViewModels
//       final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
//       final LocationViewModel locationViewModel = Get.find<LocationViewModel>();
//
//       // 2. Check if still clocked in
//       if (!attendanceViewModel.isClockedIn.value) {
//         debugPrint('⚠️ [BATTERY] User already clocked out');
//         return;
//       }
//
//       // 3. Update ViewModels
//       attendanceViewModel.isClockedIn.value = false;
//       locationViewModel.isClockedIn.value = false;
//
//       // 4. Update SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isClockedIn', false);
//       await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
//       await prefs.setString('clockOutReason', 'battery_saver_auto');
//
//       // 5. Show notification
//       Get.snackbar(
//         '⚠️ Auto Clock-Out',
//         'Battery Saver detected. Automatically clocked out.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: Duration(seconds: 5),
//         icon: Icon(Icons.battery_alert, color: Colors.white),
//       );
//
//       debugPrint('✅ [BATTERY] Auto clock-out completed successfully');
//
//     } catch (e) {
//       debugPrint('❌ [BATTERY] Error in auto clock-out: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to auto clock-out',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   /// Stop monitoring
//   static void stopMonitoring() {
//     _monitoringTimer?.cancel();
//     _monitoringTimer = null;
//     _isMonitoring = false;
//   }
//
//   /// Check battery saver for clock-in
//   static Future<bool> checkBatterySaverForClockIn(BuildContext context) async {
//     try {
//       bool batterySaverStatus = await isBatterySaverOn();
//
//       if (batterySaverStatus) {
//         await showStrictBatterySaverDialog(context);
//         return false;
//       }
//
//       return true;
//     } catch (e) {
//       debugPrint('Error in checkBatterySaverForClockIn: $e');
//       return false;
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatterySaverService {
  static const MethodChannel _channel = MethodChannel('battery_saver_channel');
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  static bool _wasBatterySaverOn = false;

  /// Check if battery saver is ON
  static Future<bool> isBatterySaverOn() async {
    try {
      final bool result = await _channel.invokeMethod('isBatterySaverOn');
      return result;
    } catch (e) {
      debugPrint('Error checking battery saver: $e');
      return false;
    }
  }

  /// Open Battery Saver settings
  static Future<void> openBatterySaverSettings() async {
    try {
      await _channel.invokeMethod('openBatterySaverSettings');
    } catch (e) {
      debugPrint('Error opening battery saver settings: $e');
    }
  }

  /// Show strict battery saver dialog (like location dialog)
  static Future<bool> showStrictBatterySaverDialog(BuildContext context) async {
    try {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.battery_alert, color: Colors.orange, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Battery Saver Detected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery Saver is currently ON.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 12),
                Text(
                  'For accurate GPS tracking and best app performance, please turn OFF Battery Saver.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Clock-In is not allowed while Battery Saver is ON.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Steps to disable:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildStep('1. Go to Settings', Icons.settings),
                _buildStep('2. Tap on "Battery"', Icons.battery_std),
                _buildStep('3. Turn OFF "Power Saving Mode"', Icons.power_settings_new),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                openBatterySaverSettings();
                Navigator.pop(context, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );

      return result ?? false;
    } catch (e) {
      debugPrint('Error showing battery saver dialog: $e');
      return false;
    }
  }

  static Widget _buildStep(String text, IconData icon) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        )
    );
  }

  /// Start periodic monitoring WITH AUTO CLOCK-OUT
  static void startMonitoring() {
    if (_isMonitoring) {
      _monitoringTimer?.cancel();
    }

    _isMonitoring = true;
    _wasBatterySaverOn = false;

    _monitoringTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        bool currentStatus = await isBatterySaverOn();
        bool isClockedIn = await _isUserClockedIn();

        debugPrint('🔋 [BATTERY] Status: $currentStatus | Clocked In: $isClockedIn | Was: $_wasBatterySaverOn');

        // ✅ AUTO CLOCK-OUT LOGIC
        if (isClockedIn && currentStatus && !_wasBatterySaverOn) {
          debugPrint('🚨 [BATTERY] Auto Clock-Out triggered!');
          await _performAutoClockOut();
        }

        _wasBatterySaverOn = currentStatus;
      } catch (e) {
        debugPrint('Error in battery monitoring: $e');
      }
    });
  }

  /// Check if user is clocked in
  static Future<bool> _isUserClockedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isClockedIn') ?? false;
    } catch (e) {
      debugPrint('Error checking clock-in status: $e');
      return false;
    }
  }

  /// Perform auto clock-out
  static Future<void> _performAutoClockOut() async {
    try {
      debugPrint('🔄 [BATTERY] Starting auto clock-out process...');

      // 1. Get ViewModels
      final AttendanceViewModel attendanceViewModel = Get.find<AttendanceViewModel>();
      final LocationViewModel locationViewModel = Get.find<LocationViewModel>();

      // 2. Check if still clocked in
      if (!attendanceViewModel.isClockedIn.value) {
        debugPrint('⚠️ [BATTERY] User already clocked out');
        return;
      }

      // 3. Update ViewModels
      attendanceViewModel.isClockedIn.value = false;
      locationViewModel.isClockedIn.value = false;

      // 4. Update SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isClockedIn', false);
      await prefs.setString('lastClockOutTime', DateTime.now().toIso8601String());
      await prefs.setString('clockOutReason', 'battery_saver_auto');

      // 5. Show notification
      Get.snackbar(
        '⚠️ Auto Clock-Out',
        'Battery Saver detected. Automatically clocked out.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.battery_alert, color: Colors.white),
      );

      debugPrint('✅ [BATTERY] Auto clock-out completed successfully');

    } catch (e) {
      debugPrint('❌ [BATTERY] Error in auto clock-out: $e');
      Get.snackbar(
        'Error',
        'Failed to auto clock-out',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Stop monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }

  /// Check battery saver for clock-in
  static Future<bool> checkBatterySaverForClockIn(BuildContext context) async {
    try {
      bool batterySaverStatus = await isBatterySaverOn();

      if (batterySaverStatus) {
        await showStrictBatterySaverDialog(context);
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error in checkBatterySaverForClockIn: $e');
      return false;
    }
  }
}
