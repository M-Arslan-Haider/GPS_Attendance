// import 'dart:async';
// import 'dart:io';
// import 'dart:io' show Directory, InternetAddress, Platform, SocketException;
// import 'dart:ui';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// import 'package:order_booking_app/Screens/code_screen.dart';
// import 'package:order_booking_app/Screens/home_screen.dart';
// import 'package:order_booking_app/Screens/login_screen.dart';
// import 'package:order_booking_app/Screens/order_booking_screen.dart';
// import 'package:order_booking_app/Screens/order_booking_status_screen.dart';
// import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// import 'package:order_booking_app/Screens/return_form_screen.dart';
// import 'package:order_booking_app/screens/splash_screen.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';
// import 'Cluster_Data/cluster_data_screen.dart';
// import 'Databases/dp_helper.dart';
// import 'Databases/util.dart';
// import 'GPX/advance_gpx_analysisScreen.dart';
// import 'GPX/gpx_viewer_screen.dart';
// import 'GPX/screen.dart';
// import 'LocatioPoints/ravelTimeViewModel.dart';
// import 'LocatioPoints/travel_time-screen.dart';
// import 'Screens/NSM/nsm_homepage.dart';
// import 'Screens/RSMS_Views/RSM_HomePage.dart';
// import 'Screens/SM/sm_homepage.dart';
// import 'Screens/shop_visit_screen.dart';
// import 'Services/FirebaseServices/firebase_remote_config.dart';
// import 'Services/FirebaseServices/firebase_options.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart'
//     show AndroidServiceInstance;
// import 'package:flutter_background_service/flutter_background_service.dart'
//     show
//     AndroidConfiguration,
//     FlutterBackgroundService,
//     IosConfiguration,
//     ServiceInstance;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'
//     show
//     AndroidFlutterLocalNotificationsPlugin,
//     AndroidInitializationSettings,
//     AndroidNotificationChannel,
//     AndroidNotificationDetails,
//     DarwinInitializationSettings,
//     FlutterLocalNotificationsPlugin,
//     Importance,
//     InitializationSettings,
//     NotificationDetails;
// import 'Tracker/location00.dart';
// import 'Tracker/trac.dart';
// import 'package:order_booking_app/ViewModels/login_view_model.dart';
// import 'package:android_intent_plus/android_intent.dart' as android_intent;
// import 'package:in_app_update/in_app_update.dart';
// import 'ViewModels/location_view_model.dart';
//
// // final LoginViewModel loginViewModel = Get.put(LoginViewModel());
// Future<void> main() async {
//   runZonedGuarded(() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     debugPrint("Initializing Firebase...");
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     debugPrint("Firebase initialized.");
//
//     debugPrint("Initializing Config...");
//     await Config.initialize();
//     debugPrint("Config initialized.");
//
//     debugPrint("Initializing SharedPreferences main...");
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
//     //bool isAuthenticated =  false;
//     pageName = prefs.getString('pageName') ?? '/cameraScreen';
//     newIsClockedIn = prefs.getBool('isClockedIn') ?? false;
//     user_id = prefs.getString('userId') ?? '';
//     userName = prefs.getString('userName') ?? '';
//     userCity = prefs.getString('userCity') ?? '';
//     userDesignation = prefs.getString('userDesignation') ?? '';
//     userBrand = prefs.getString('userBrand') ?? '';
//     userSM = prefs.getString('userSM') ?? '';
//     userNSM = prefs.getString('userNSM') ?? '';
//     userRSM = prefs.getString('userRSM') ?? '';
//     userNameRSM = prefs.getString('userNameRSM') ?? '';
//     userNameNSM = prefs.getString('userNameNSM') ?? '';
//     userNameSM = prefs.getString('userNameSM') ?? '';
//
//     debugPrint("Initializing Workmanager...");
//     Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
//     debugPrint("Workmanager initialized.");
//
//     // Initialize background service only if needed
//     if (isAuthenticated) {
//       debugPrint("Initializing Background Service...");
//       await initializeServiceLocation();
//       debugPrint("Background Service initialized.");
//     }
//
//     Get.put(DBHelper(), permanent: true);
//
//     Get.put(TravelTimeViewModel(), permanent: true);
//     Get.put(LocationViewModel());
//
//     debugPrint("Running the app...");
//     runApp(MyApp(isAuthenticated));
//     debugPrint("App is running.");
//   }, (error, stackTrace) {
//     debugPrint('Error: $error');
//     debugPrint('Stack Trace: $stackTrace');
//   });
// }
//
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     if (kDebugMode) {
//       debugPrint("WorkManager MMM ");
//     }
//     return Future.value(true);
//   });
// }
//
// class MyApp extends StatelessWidget {
//
//   final bool isAuthenticated;
//
//   MyApp(this.isAuthenticated);
//
//   @override
//   Widget build(BuildContext context) {
//
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: isAuthenticated ? pageName : '/CodeScreen',
//       // initialRoute: '/',
//       getPages: [
//         GetPage(name: '/', page: () => const SplashScreen()),
//         // GetPage(name: '/policy', page: () => PolicyDialog()),
//         GetPage(name: '/login', page: () => const LoginScreen()),
//         GetPage(name: '/home', page: () => const HomeScreen()),
//         GetPage(name: '/cameraScreen', page: () => const CameraScreen()),
//         GetPage(name: '/ShopVisitScreen', page: () => const ShopVisitScreen()),
//         GetPage(name: '/OrderBookingScreen', page: () => const OrderBookingScreen()),
//         GetPage(name: '/RecoveryFormScreen', page: () => RecoveryFormScreen()),
//         GetPage(name: '/ReturnFormScreen', page: () => ReturnFormScreen()),
//         GetPage(name: '/NSMHomepage', page: () => const NSMHomepage()),
//         GetPage(name: '/RSMHomepage', page: () => const RSMHomepage()),
//         GetPage(name: '/SMHomepage', page: () => const SMHomepage()),
//         GetPage(name: '/CodeScreen', page: () => const CodeScreen()),
//
//         GetPage(
//             name: '/OrderBookingStatusScreen',
//             page: () => OrderBookingStatusScreen()),
//
//
//         GetPage(name: '/TravelTimeTestScreen', page: () => TravelTimeTestScreen()),
//         GetPage(name: '/CentralPointsTestScreen', page: () => CentralPointsTestScreen()),
//         // GetPage(name: '/GPXViewerScreen', page: () => GPXViewerScreen()),
//         GetPage(name: '/GPXViewerScreen', page: () => GPXViewerScreen()),
//         GetPage(name: '/GPXViewerScreen', page: () => FixedGPXClusterViewer()),
//         // GetPage(name: '/ClusterDataScreen', page: () => const ClusterDataScreen()),
//
//       ],
//       // home: SplashScreen()
//       //home: const CodeScreen()
//     );
//   }
//
// }
//
//
//
// void requestIgnoreBatteryOptimizations() {
//   if (Platform.isAndroid) {
//     const android_intent.AndroidIntent intent = android_intent.AndroidIntent(
//       action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
//       data: 'package:com.metaxperts.order_booking_app',
//     );
//     intent.launch();
//   }
// }
// Future<void> initializeServiceLocation() async {
//   final service = FlutterBackgroundService();
//
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'my_foreground',
//     'MY FOREGROUND SERVICE',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.low,
//   );
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   if (Platform.isIOS || Platform.isAndroid) {
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(
//         iOS: DarwinInitializationSettings(),
//         android: AndroidInitializationSettings('ic_bg_service_small'),
//       ),
//     );
//   }
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: false,
//       autoStartOnBoot: false,
//       isForegroundMode: true,
//       notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onStart,
//     ),
//   );
//   // monitorInternetConnection(); // Add this line to monitor connectivity changes
// }
//
// @pragma('vm:entry-point')
// void onStart1(ServiceInstance service1) async {
//   DartPluginRegistrant.ensureInitialized();
//   Timer.periodic(const Duration(minutes: 10), (timer) async {
//     if (service1 is AndroidServiceInstance) {
//       if (await service1.isForegroundService()) {
//         // backgroundTask();
//       }
//     }
//     final deviceInfo = DeviceInfoPlugin();
//     String? device1;
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       device1 = androidInfo.model;
//     }
//     if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       device1 = iosInfo.model;
//     }
//     service1.invoke(
//       'update',
//       {
//         "current_date": DateTime.now().toIso8601String(),
//         "device": device1,
//       },
//     );
//   });
// }
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.setString("hello", "world");
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   LocationService locationService = LocationService();
//
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) async {
//     locationService.stopListening();
//     locationService.deleteDocument();
//     Workmanager().cancelAll();
//     service.stopSelf();
//     FlutterLocalNotificationsPlugin().cancelAll();
//   });
//
//   // Start location if clocked in
//   if (locationViewModel.isClockedIn.value == false) {
//     startTimer();
//     locationService.listenLocation();
//   }
//
//   /// ✅ Immediate + accurate background timer
//   int secondsPassed = 0;
//
//   // 🔹 Immediately show the first notification
//   if (service is AndroidServiceInstance &&
//       await service.isForegroundService()) {
//     service.setForegroundNotificationInfo(
//       title: "ClockIn",
//       content: "Timer ${_formatDuration(secondsPassed.toString())}",
//     );
//   }
//
//   // 🔹 Then update every second
//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     secondsPassed++;
//
//     if (service is AndroidServiceInstance &&
//         await service.isForegroundService()) {
//       service.setForegroundNotificationInfo(
//         title: "ClockIn",
//         content: "Timer ${_formatDuration(secondsPassed.toString())}",
//       );
//     }
//
//     final deviceInfo = DeviceInfoPlugin();
//     String? device;
//
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       device = androidInfo.model;
//     } else if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       device = iosInfo.model;
//     }
//
//     service.invoke(
//       'update',
//       {
//         "current_date": DateTime.now().toLocal().toIso8601String(),
//         "device": device,
//       },
//     );
//   });
// }
//
//
// String _formatDuration(String secondsString) {
//   int seconds = int.parse(secondsString);
//   Duration duration = Duration(seconds: seconds);
//   String twoDigits(int n) => n.toString().padLeft(2, '0');
//   String hours = twoDigits(duration.inHours);
//   String minutes = twoDigits(duration.inMinutes.remainder(60));
//   String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
//   return '$hours:$minutes:$secondsFormatted';
// }
//

import 'dart:async';
import 'dart:io';
import 'dart:io' show Directory, InternetAddress, Platform, SocketException;
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart' show DeviceInfoPlugin;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
import 'package:order_booking_app/Screens/code_screen.dart';
import 'package:order_booking_app/Screens/home_screen.dart';
import 'package:order_booking_app/Screens/login_screen.dart';
import 'package:order_booking_app/Screens/order_booking_screen.dart';
import 'package:order_booking_app/Screens/order_booking_status_screen.dart';
import 'package:order_booking_app/Screens/recovery_form_screen.dart';
import 'package:order_booking_app/Screens/return_form_screen.dart';
import 'package:order_booking_app/screens/splash_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'Cluster_Data/cluster_data_screen.dart';
import 'Databases/dp_helper.dart';
import 'Databases/util.dart';
import 'GPX/advance_gpx_analysisScreen.dart';
import 'GPX/gpx_viewer_screen.dart';
import 'GPX/screen.dart';
import 'LocatioPoints/ravelTimeViewModel.dart';
import 'LocatioPoints/travel_time-screen.dart';
import 'Screens/NSM/nsm_homepage.dart';
import 'Screens/RSMS_Views/RSM_HomePage.dart';
import 'Screens/SM/sm_homepage.dart';
import 'Screens/shop_visit_screen.dart';
import 'Services/FirebaseServices/firebase_remote_config.dart';
import 'Services/FirebaseServices/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart'
    show AndroidServiceInstance;
import 'package:flutter_background_service/flutter_background_service.dart'
    show
    AndroidConfiguration,
    FlutterBackgroundService,
    IosConfiguration,
    ServiceInstance;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
    AndroidFlutterLocalNotificationsPlugin,
    AndroidInitializationSettings,
    AndroidNotificationChannel,
    AndroidNotificationDetails,
    DarwinInitializationSettings,
    FlutterLocalNotificationsPlugin,
    Importance,
    InitializationSettings,
    NotificationDetails;
import 'Tracker/location00.dart';
import 'Tracker/trac.dart';
import 'package:order_booking_app/ViewModels/login_view_model.dart';
import 'package:android_intent_plus/android_intent.dart' as android_intent;

import 'package:in_app_update/in_app_update.dart';

import 'ViewModels/location_view_model.dart';

// ✅ ADD: Import Battery Saver Service
import 'package:order_booking_app/BatterySaverService.dart';

// Future<void> checkForUpdate() async {
//
//   try {
//     AppUpdateInfo info = await InAppUpdate.checkForUpdate();
//
//     if (info.updateAvailability == UpdateAvailability.updateAvailable) {
//       // agar update mil jaye to show karo
//       InAppUpdate.performImmediateUpdate(); // ya flexible update use karo
//     }
//   } catch (e) {
//     print("Error checking for update: $e");
//   }
// }

// final LoginViewModel loginViewModel = Get.put(LoginViewModel());
Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized.");

    debugPrint("Initializing Config...");
    await Config.initialize();
    debugPrint("Config initialized.");

    debugPrint("Initializing SharedPreferences main...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    //bool isAuthenticated =  false;
    pageName = prefs.getString('pageName') ?? '/cameraScreen';
    newIsClockedIn = prefs.getBool('isClockedIn') ?? false;
    user_id = prefs.getString('userId') ?? '';
    userName = prefs.getString('userName') ?? '';
    userCity = prefs.getString('userCity') ?? '';
    userDesignation = prefs.getString('userDesignation') ?? '';
    userBrand = prefs.getString('userBrand') ?? '';
    userSM = prefs.getString('userSM') ?? '';
    userNSM = prefs.getString('userNSM') ?? '';
    userRSM = prefs.getString('userRSM') ?? '';
    userNameRSM = prefs.getString('userNameRSM') ?? '';
    userNameNSM = prefs.getString('userNameNSM') ?? '';
    userNameSM = prefs.getString('userNameSM') ?? '';

    debugPrint("Initializing Workmanager...");
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    debugPrint("Workmanager initialized.");

    // Initialize background service only if needed
    if (isAuthenticated) {
      debugPrint("Initializing Background Service...");
      await initializeServiceLocation();
      debugPrint("Background Service initialized.");
    }

    Get.put(DBHelper(), permanent: true);

    Get.put(TravelTimeViewModel(), permanent: true);
    Get.put(LocationViewModel());

    debugPrint("Running the app...");
    runApp(MyApp(isAuthenticated));
    debugPrint("App is running.");
  }, (error, stackTrace) {
    debugPrint('Error: $error');
    debugPrint('Stack Trace: $stackTrace');
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      debugPrint("WorkManager MMM ");
    }
    return Future.value(true);
  });
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   if (kDebugMode) {
//     debugPrint("Handling a background message: ${message.messageId}");
//   }
// }

// class MyApp extends StatefulWidget {
//   final bool isAuthenticated;
//   const MyApp(this.isAuthenticated, {super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//
//
//   @override
//   void initState() {
//     super.initState();
//     checkVersion();
//   }
//
//   Future<void> checkVersion() async {
//     try {
//       // 🔹 Get local app version
//       final packageInfo = await PackageInfo.fromPlatform();
//       String currentVersion = packageInfo.version;
//       String packageName = packageInfo.packageName;
//
//       // 🔹 Fetch Play Store page HTML
//       final response = await http.get(Uri.parse(
//           "https://play.google.com/store/apps/details?id=$packageName&hl=en"));
//
//       if (response.statusCode == 200) {
//         final html = response.body;
//
//         // 🔹 Extract version number from Play Store HTML
//         final regExp = RegExp(r'\[\[\["([0-9]+\.[0-9]+\.[0-9]+)"\]\]');
//         final match = regExp.firstMatch(html);

//         if (match != null) {
//           String storeVersion = match.group(1) ?? '';

//           debugPrint("📱 Local version: $currentVersion");
//           debugPrint("🛒 Play Store version: $storeVersion");

//           if (storeVersion.isNotEmpty && storeVersion != currentVersion) {
//             Fluttertoast.showToast(
//               msg: "⚠️ New update available! Please update app from Play Store.",
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.BOTTOM,
//               backgroundColor: Colors.redAccent,
//               textColor: Colors.white,
//               fontSize: 16.0,
//             );
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Version check failed: $e");
//     }
//   }
//   // Future<void> checkForUpdate() async {
//   //   try {
//   //     AppUpdateInfo info = await InAppUpdate.checkForUpdate();
//   //     if (info.updateAvailability == UpdateAvailability.updateAvailable) {
//   //       await InAppUpdate.performImmediateUpdate();
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Update check failed: $e');
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: widget.isAuthenticated ? pageName : '/CodeScreen',
//       getPages: [
//         GetPage(name: '/', page: () => const SplashScreen()),
//         GetPage(name: '/login', page: () => const LoginScreen()),
//         GetPage(name: '/home', page: () => const HomeScreen()),
//         GetPage(name: '/cameraScreen', page: () => const CameraScreen()),
//         GetPage(name: '/ShopVisitScreen', page: () => const ShopVisitScreen()),
//         GetPage(name: '/OrderBookingScreen', page: () => const OrderBookingScreen()),
//         GetPage(name: '/RecoveryFormScreen', page: () => RecoveryFormScreen()),
//         GetPage(name: '/ReturnFormScreen', page: () => ReturnFormScreen()),
//         GetPage(name: '/NSMHomepage', page: () => const NSMHomepage()),
//         GetPage(name: '/RSMHomepage', page: () => const RSMHomepage()),
//         GetPage(name: '/SMHomepage', page: () => const SMHomepage()),
//         GetPage(name: '/CodeScreen', page: () => const CodeScreen()),
//         GetPage(
//           name: '/OrderBookingStatusScreen',
//           page: () => OrderBookingStatusScreen(),
//         ),
//       ],
//     );
//   }
// }

class MyApp extends StatefulWidget {
  final bool isAuthenticated;

  const MyApp(this.isAuthenticated, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeBatterySaverMonitoring();
  }

  void _initializeBatterySaverMonitoring() {
    // Start battery saver monitoring when user is authenticated
    if (widget.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          BatterySaverService.startMonitoring();
        }
      });
    }
  }

  @override
  void dispose() {
    BatterySaverService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: widget.isAuthenticated ? pageName : '/CodeScreen',
      // initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        // GetPage(name: '/policy', page: () => PolicyDialog()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/cameraScreen', page: () => const CameraScreen()),
        GetPage(name: '/ShopVisitScreen', page: () => const ShopVisitScreen()),
        GetPage(name: '/OrderBookingScreen', page: () => const OrderBookingScreen()),
        GetPage(name: '/RecoveryFormScreen', page: () => RecoveryFormScreen()),
        GetPage(name: '/ReturnFormScreen', page: () => ReturnFormScreen()),
        GetPage(name: '/NSMHomepage', page: () => const NSMHomepage()),
        GetPage(name: '/RSMHomepage', page: () => const RSMHomepage()),
        GetPage(name: '/SMHomepage', page: () => const SMHomepage()),
        GetPage(name: '/CodeScreen', page: () => const CodeScreen()),

        GetPage(
            name: '/OrderBookingStatusScreen',
            page: () => OrderBookingStatusScreen()),

        GetPage(name: '/TravelTimeTestScreen', page: () => TravelTimeTestScreen()),
        GetPage(name: '/CentralPointsTestScreen', page: () => CentralPointsTestScreen()),
        // GetPage(name: '/GPXViewerScreen', page: () => GPXViewerScreen()),
        GetPage(name: '/GPXViewerScreen', page: () => GPXViewerScreen()),
        GetPage(name: '/GPXViewerScreen', page: () => FixedGPXClusterViewer()),
        // GetPage(name: '/ClusterDataScreen', page: () => const ClusterDataScreen()),
      ],
      // home: SplashScreen()
      //home: const CodeScreen()
    );
  }
}

void requestIgnoreBatteryOptimizations() {
  if (Platform.isAndroid) {
    const android_intent.AndroidIntent intent = android_intent.AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:com.metaxperts.order_booking_app',
    );
    intent.launch();
  }
}

Future<void> initializeServiceLocation() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
  // monitorInternetConnection(); // Add this line to monitor connectivity changes
}

// void monitorInternetConnection() {
//   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//     if (result == ConnectivityResult.mobile ||
//         result == ConnectivityResult.wifi) {
//       // backgroundTask();
//     }
//   });
// }
@pragma('vm:entry-point')
void onStart1(ServiceInstance service1) async {
  DartPluginRegistrant.ensureInitialized();
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service1 is AndroidServiceInstance) {
      if (await service1.isForegroundService()) {
        // backgroundTask();
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device1;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device1 = androidInfo.model;
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device1 = iosInfo.model;
    }
    service1.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device1,
      },
    );
  });
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  LocationService locationService = LocationService();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    locationService.stopListening();
    locationService.deleteDocument();
    Workmanager().cancelAll();
    service.stopSelf();
    FlutterLocalNotificationsPlugin().cancelAll();
  });

  // Start location if clocked in
  if (locationViewModel.isClockedIn.value == false) {
    startTimer();
    locationService.listenLocation();
  }

  /// ✅ Immediate + accurate background timer
  int secondsPassed = 0;

  // 🔹 Immediately show the first notification
  if (service is AndroidServiceInstance && await service.isForegroundService()) {
    service.setForegroundNotificationInfo(
      title: "ClockIn",
      content: "Timer ${_formatDuration(secondsPassed.toString())}",
    );
  }

  // 🔹 Then update every second
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    secondsPassed++;

    if (service is AndroidServiceInstance && await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "ClockIn",
        content: "Timer ${_formatDuration(secondsPassed.toString())}",
      );
    }

    final deviceInfo = DeviceInfoPlugin();
    String? device;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toLocal().toIso8601String(),
        "device": device,
      },
    );
  });
}

String _formatDuration(String secondsString) {
  int seconds = int.parse(secondsString);
  Duration duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$secondsFormatted';
}