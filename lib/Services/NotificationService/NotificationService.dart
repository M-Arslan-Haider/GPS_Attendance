// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// class UrgentNotificationService {
//   static final UrgentNotificationService _instance = UrgentNotificationService._internal();
//   factory UrgentNotificationService() => _instance;
//   UrgentNotificationService._internal();
//
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static int _notificationId = 0;
//
//   // Initialize notifications with URGENT settings
//   static Future<void> initialize() async {
//     // Android URGENT channel for auto clockout
//     const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
//       'urgent_auto_clockout_channel',
//       'URGENT Auto Clockout',
//       description: 'High-priority channel for urgent auto clockout notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//       enableLights: true,
//       ledColor: Colors.red,
//     );
//
//     // Android settings
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS settings
//     const DarwinInitializationSettings iosSettings =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//     );
//
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notificationsPlugin.initialize(initSettings);
//
//     // Create URGENT notification channel for Android
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(urgentChannel);
//   }
//
//   // Show URGENT notification with sound and vibration
//   static Future<void> showUrgentNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     _notificationId++;
//
//     // Android URGENT notification details
//     final AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'urgent_auto_clockout_channel',
//       'URGENT Auto Clockout',
//       channelDescription: 'High-priority channel for urgent auto clockout notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//       timeoutAfter: 5000,
//       category: AndroidNotificationCategory.alarm,
//       visibility: NotificationVisibility.public,
//       color: Colors.red,
//       ledColor: Colors.red,
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       fullScreenIntent: true,
//       ongoing: false,
//       autoCancel: true,
//       styleInformation: BigTextStyleInformation(body),
//     );
//
//     // iOS URGENT notification details
//     const DarwinNotificationDetails iosDetails =
//     DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: 'default',
//       interruptionLevel: InterruptionLevel.timeSensitive,
//     );
//
//     final NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     // Show notification
//     await _notificationsPlugin.show(
//       _notificationId,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//
//     debugPrint("🔔 [URGENT NOTIFICATION] Sent: $title");
//   }
//
//   // Show in-app alert with bell
//   static void showInAppAlert({
//     required String title,
//     required String message,
//     Color? backgroundColor,
//   }) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: backgroundColor ?? Colors.red.shade700,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 5),
//       icon: const Icon(Icons.notifications_active, color: Colors.white),
//       shouldIconPulse: true,
//       barBlur: 10,
//       isDismissible: true,
//       margin: const EdgeInsets.all(10),
//       borderRadius: 10,
//       mainButton: TextButton(
//         onPressed: () {
//           if (Get.isSnackbarOpen) {
//             Get.closeCurrentSnackbar();
//           }
//         },
//         child: const Text('OK', style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
//
//   // Cancel all notifications
//   static Future<void> cancelAll() async {
//     await _notificationsPlugin.cancelAll();
//   }
// }
//
// // Notification Bell Widget
// class NotificationBell extends StatelessWidget {
//   final Color? color;
//   final double size;
//   final VoidCallback? onTap;
//
//   const NotificationBell({
//     Key? key,
//     this.color,
//     this.size = 24,
//     this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(
//         Icons.notifications_active,
//         color: color ?? Colors.orange,
//         size: size,
//       ),
//       onPressed: onTap ?? () {
//         // Show recent notifications info
//         Get.snackbar(
//           'Notifications Active',
//           'Urgent notifications are enabled',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.blue,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//           icon: const Icon(Icons.info, color: Colors.white),
//         );
//       },
//     );
//   }
// }