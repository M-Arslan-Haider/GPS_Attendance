// // // //
// // // //
// // // // import 'package:auto_route/annotations.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/physics.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/Databases/util.dart';
// // // // // import 'package:order_booking_app/Screens/HomeScreenComponents/assets.dart';
// // // // import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// // // // import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// // // // import 'package:order_booking_app/Screens/HomeScreenComponents/assets.dart';
// // // //
// // // // import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// // // // import 'package:order_booking_app/screens/add_shop_screen.dart';
// // // // import 'package:order_booking_app/screens/return_form_screen.dart';
// // // // import 'package:rive/rive.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // ✅ added
// // // //
// // // // import '../GPX/screen.dart';
// // // // import '../LocatioPoints/ravelTimeViewModel.dart';
// // // // import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// // // // import '../ViewModels/add_shop_view_model.dart';
// // // // import '../ViewModels/location_view_model.dart';
// // // // import '../ViewModels/order_details_view_model.dart';
// // // // import '../ViewModels/return_form_view_model.dart';
// // // // import '../ViewModels/shop_visit_details_view_model.dart';
// // // //
// // // // import 'HomeScreenComponents/action_box.dart';
// // // // import 'HomeScreenComponents/navbar.dart';
// // // // import 'HomeScreenComponents/overview_row.dart';
// // // // import 'HomeScreenComponents/profile_section.dart';
// // // // import 'HomeScreenComponents/theme.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// // // // import 'HomeScreenComponents/timer_card.dart';
// // // // import 'package:order_booking_app/Screens/code_screen.dart';
// // // // import 'leave_form_screen.dart';
// // // // import 'order_booking_status_screen.dart';
// // // // // ✅ ABDULLAH: Added import for TravelTimeViewModel
// // // //
// // // //
// // // //
// // // //
// // // // // @RoutePage()
// // // // class HomeScreen extends StatefulWidget {
// // // //   const HomeScreen({super.key});
// // // //
// // // //   @override
// // // //   State<HomeScreen> createState() => _RiveAppHomeState();
// // // // }
// // // //
// // // // class _RiveAppHomeState extends State<HomeScreen>
// // // //     with TickerProviderStateMixin {
// // // //   late final addShopViewModel = Get.put(AddShopViewModel());
// // // //   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
// // // //   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
// // // //   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
// // // //   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
// // // //   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
// // // //   late final returnFormViewModel = Get.put(ReturnFormViewModel());
// // // //   late final attendanceViewModel = Get.put(AttendanceViewModel());
// // // //   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // //   late final signUpController = Get.put(SignUpController());
// // // //   final LocationViewModel locationVM = Get.find<LocationViewModel>();
// // // //   late AnimationController? _animationController;
// // // //   late AnimationController? _onBoardingAnimController;
// // // //   late Animation<double> _onBoardingAnim;
// // // //   late Animation<double> _sidebarAnim;
// // // //   late SMIBool _menuBtn;
// // // //   final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
// // // //   final springDesc = const SpringDescription(
// // // //     mass: 0.1,
// // // //     stiffness: 40,
// // // //     damping: 5,
// // // //   );
// // // //   bool _showOnBoarding = false;
// // // //
// // // //   void _onMenuIconInit(Artboard artboard) {
// // // //     final controller =
// // // //     StateMachineController.fromArtboard(artboard, "State Machine");
// // // //     artboard.addController(controller!);
// // // //     _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
// // // //     _menuBtn.value = true;
// // // //   }
// // // //
// // // //   void _presentOnBoarding(bool show) {
// // // //     if (show) {
// // // //       setState(() {
// // // //         _showOnBoarding = true;
// // // //       });
// // // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // // //       _onBoardingAnimController?.animateWith(springAnim);
// // // //     } else {
// // // //       _onBoardingAnimController?.reverse().whenComplete(() => {
// // // //         setState(() {
// // // //           _showOnBoarding = false;
// // // //         })
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   void onMenuPress() {
// // // //     if (_menuBtn.value) {
// // // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // // //       _animationController?.animateWith(springAnim);
// // // //     } else {
// // // //       _animationController?.reverse();
// // // //     }
// // // //     _menuBtn.change(!_menuBtn.value);
// // // //
// // // //     SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
// // // //         ? SystemUiOverlayStyle.dark
// // // //         : SystemUiOverlayStyle.light);
// // // //   }
// // // //
// // // //   _retrieveSavedValues() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     await prefs.reload();
// // // //
// // // //     setState(() {
// // // //       user_id = prefs.getString('userId') ?? '';
// // // //       userName = prefs.getString('userName') ?? '';
// // // //       userCity = prefs.getString('userCity') ?? '';
// // // //       userDesignation = prefs.getString('userDesignation') ?? '';
// // // //       userBrand = prefs.getString('userBrand') ?? '';
// // // //       userSM = prefs.getString('userSM') ?? '';
// // // //       userNSM = prefs.getString('userNSM') ?? '';
// // // //       userRSM = prefs.getString('userRSM') ?? '';
// // // //       userNameRSM = prefs.getString('userNameRSM') ?? '';
// // // //       userNameNSM = prefs.getString('userNameNSM') ?? '';
// // // //       userNameSM = prefs.getString('userNameSM') ?? '';
// // // //       companyName = prefs.getString('company_name') ?? '';
// // // //     });
// // // //     debugPrint(user_id);
// // // //   }
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     _animationController = AnimationController(
// // // //       duration: const Duration(milliseconds: 200),
// // // //       upperBound: 1,
// // // //       vsync: this,
// // // //     );
// // // //     _onBoardingAnimController = AnimationController(
// // // //       duration: const Duration(milliseconds: 350),
// // // //       upperBound: 1,
// // // //       vsync: this,
// // // //     );
// // // //
// // // //     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // // //       parent: _animationController!,
// // // //       curve: Curves.linear,
// // // //     ));
// // // //
// // // //     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // // //       parent: _onBoardingAnimController!,
// // // //       curve: Curves.linear,
// // // //     ));
// // // //
// // // //     super.initState();
// // // //     _retrieveSavedValues();
// // // //     addShopViewModel.fetchAllAddShop();
// // // //     shopVisitViewModel.fetchAllShopVisit();
// // // //     shopVisitViewModel.fetchTotalShopVisit();
// // // //     shopVisitDetailsViewModel.initializeProductData();
// // // //     orderMasterViewModel.fetchAllOrderMaster();
// // // //     orderMasterViewModel.fetchTotalDispatched();
// // // //     recoveryFormViewModel.fetchAllRecoveryForm();
// // // //     returnFormViewModel.fetchAllReturnForm();
// // // //     attendanceViewModel.fetchAllAttendance();
// // // //     attendanceOutViewModel.fetchAllAttendanceOut();
// // // //
// // // //     // ✅ Start foreground service here
// // // //     FlutterForegroundTask.startService(
// // // //       notificationTitle: 'Clock Running',
// // // //       notificationText: 'Tracking time and location...',
// // // //       callback: startCallback,
// // // //     );
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _animationController?.dispose();
// // // //     _onBoardingAnimController?.dispose();
// // // //     super.dispose();
// // // //   }
// // // // // Kisi bhi screen se call karein
// // // //   void processGPXData() {
// // // //     LocationViewModel locationVM = Get.find<LocationViewModel>();
// // // //     locationVM.processGPXAndStoreCentralPoint();
// // // //   }
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     // ✅ ABDULLAH: Home screen par working status false karein
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // // //       travelTimeViewModel.setWorkingScreenStatus(false);
// // // //       debugPrint("📍 [WORKING STATUS] Home Screen - Working time INACTIVE");
// // // //     });
// // // //     final double screenWidth = MediaQuery.of(context).size.width;
// // // //
// // // //     return WillPopScope(
// // // //       onWillPop: () async {
// // // //         return false;
// // // //       },
// // // //       child: SafeArea(
// // // //         child: Scaffold(
// // // //           backgroundColor: Colors.white,
// // // //           body: SingleChildScrollView(
// // // //             child: Column(
// // // //               children: [
// // // //                 _buildHeader(),
// // // //                 const SizedBox(height: 1),
// // // //                 TimerCard(),
// // // //                 // Padding(
// // // //                 //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
// // // //                 //   child: Text(
// // // //                 //     'مہربانی: کلاک آؤٹ کے بعد لوڈنگ ختم ہونے کا انتظار کریں. اگر آپ نے انتظار نہ کیا تو آپ غیر حاضر تصور کیے جائیں گیں',
// // // //                 //     style: TextStyle(
// // // //                 //       color: Colors.redAccent,
// // // //                 //       fontSize: 14,
// // // //                 //       fontStyle: FontStyle.italic,
// // // //                 //       fontWeight: FontWeight.bold,
// // // //                 //     ),
// // // //                 //     textAlign: TextAlign.center,
// // // //                 //   ),
// // // //                 // ),
// // // //                 const SizedBox(height: 3),
// // // //
// // // //                 const SizedBox(height: 6),
// // // //                 _buildActionButtons(screenWidth),
// // // //                 const SizedBox(height: 20),
// // // //                 _buildOverviewSection(),
// // // //                 const SizedBox(height: 30),
// // // //
// // // //                 // ✅ Professional footer version text
// // // //                 Padding(
// // // //                   padding: const EdgeInsets.only(bottom: 15),
// // // //                   child: Text(
// // // //                     ' v0.1.1',
// // // //                     style: TextStyle(
// // // //                       color: Colors.grey.shade600,
// // // //                       fontSize: 14,
// // // //                       fontStyle: FontStyle.italic,
// // // //                       letterSpacing: 0.5,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildHeader() {
// // // //     return Container(
// // // //       color: Colors.blue,
// // // //       child: Column(
// // // //         children: [
// // // //           Navbar(),
// // // //           const SizedBox(height: 10),
// // // //           const ProfileSection(),
// // // //           const SizedBox(height: 10),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildActionButtons(double screenWidth) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 15),
// // // //       child: Column(
// // // //         children: [
// // // //           // First Row - 3 buttons
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: add_shop,
// // // //                   label: 'Add Shop',
// // // //                   onTap: () async {
// // // //                     final locationVM = Get.find<LocationViewModel>();
// // // //                     if (locationVM.isClockedIn.value) {
// // // //                       Get.to(() => AddShopScreen());
// // // //                     } else {
// // // //                       Get.defaultDialog(
// // // //                         title: "Clock In Required",
// // // //                         middleText: "Please start the timer first.",
// // // //                         textConfirm: "OK",
// // // //                         confirmTextColor: Colors.white,
// // // //                         onConfirm: () {
// // // //                           Get.back();
// // // //                         },
// // // //                       );
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: shop_visit,
// // // //                   label: 'Shop Visit',
// // // //                   onTap: () async {
// // // //                     final locationVM = Get.find<LocationViewModel>();
// // // //                     if (locationVM.isClockedIn.value) {
// // // //                       Get.to(() => const ShopVisitScreen());
// // // //                     } else {
// // // //                       Get.defaultDialog(
// // // //                         title: "Clock In Required",
// // // //                         middleText: "Please start the timer first.",
// // // //                         textConfirm: "OK",
// // // //                         confirmTextColor: Colors.white,
// // // //                         onConfirm: () {
// // // //                           Get.back();
// // // //                         },
// // // //                       );
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: return_form,
// // // //                   label: 'Return Form',
// // // //                   onTap: () async {
// // // //                     final locationVM = Get.find<LocationViewModel>();
// // // //                     if (locationVM.isClockedIn.value) {
// // // //                       await orderMasterViewModel.fetchAllOrderMaster();
// // // //                       await orderDetailsViewModel.fetchAllReConfirmOrder();
// // // //                       Get.to(() => ReturnFormScreen());
// // // //                     } else {
// // // //                       Get.defaultDialog(
// // // //                         title: "Clock In Required",
// // // //                         middleText: "Please start the timer first.",
// // // //                         textConfirm: "OK",
// // // //                         confirmTextColor: Colors.white,
// // // //                         onConfirm: () {
// // // //                           Get.back();
// // // //                         },
// // // //                       );
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 15),
// // // //           // Second Row - 3 buttons
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: recovery2,
// // // //                   label: 'Recovery',
// // // //                   onTap: () async {
// // // //                     final locationVM = Get.find<LocationViewModel>();
// // // //                     if (locationVM.isClockedIn.value) {
// // // //                       await orderMasterViewModel.fetchAllOrderMaster();
// // // //                       await recoveryFormViewModel.initializeData();
// // // //                       Get.to(() => RecoveryFormScreen());
// // // //                     } else {
// // // //                       Get.defaultDialog(
// // // //                         title: "Clock In Required",
// // // //                         middleText: "Please start the timer first.",
// // // //                         textConfirm: "OK",
// // // //                         confirmTextColor: Colors.white,
// // // //                         onConfirm: () {
// // // //                           Get.back();
// // // //                         },
// // // //                       );
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: order_booking_status,
// // // //                   label: 'Booking Status',
// // // //                   onTap: () async {
// // // //                     await orderMasterViewModel.fetchAllOrderMaster();
// // // //                     Get.to(() => OrderBookingStatusScreen());
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: ActionBox(
// // // //                   imagePath: leave,
// // // //                   label: 'Leave',
// // // //                   onTap: () {
// // // //                     Get.to(() => LeaveFormScreen());
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildOverviewSection() {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 20),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //
// // //
// // //
// // // //
// // // //           // ListTile(
// // // //           //   leading: Icon(Icons.analytics),
// // // //           //   title: Text('Central Points Testing'),
// // // //           //   subtitle: Text('Test clustering and API functionality'),
// // // //           //   onTap: () {
// // // //           //     Get.to(() => CentralPointsTestScreen());
// // // //           //   },
// // // //           //   trailing: Icon(Icons.arrow_forward_ios),
// // // //           // ),
// // // //
// // // //           // ElevatedButton(
// // // //           //   onPressed: () {
// // // //           //     Get.toNamed('/TravelTimeTestScreen');
// // // //           //   },
// // // //           //   child: Text('🚗 Travel Analytics'),
// // // //           //   style: ElevatedButton.styleFrom(
// // // //           //     backgroundColor: Colors.blue,
// // // //           //     foregroundColor: Colors.white,
// // // //           //   ),
// // // //           // ),
// // // //           // ElevatedButton(
// // // //           //   onPressed: () {
// // // //           //     locationVM.saveLocationWithCentralPoints();
// // // //           //   },
// // // //           //   child: Text('Save Location with Central Points'),
// // // //           // ),
// // // //
// // // //           // Manual sync button
// // // //           // ElevatedButton(
// // // //           //   onPressed: () {
// // // //           //     locationVM.syncCentralPointsToAPI();
// // // //           //   },
// // // //           //   child: Text('Sync Central Points to API'),
// // // //           // ),
// // // //           const Text(
// // // //             "Overview",
// // // //             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
// // // //           ),
// // // //           const SizedBox(height: 20),
// // // //           Obx(() {
// // // //             final totalShops = addShopViewModel.allAddShop.length;
// // // //             final totalShopsVisits =
// // // //                 shopVisitViewModel.apiShopVisitsCount.value;
// // // //             final totalOrders = orderMasterViewModel.allOrderMaster.length;
// // // //             final totalDispatchedOrders =
// // // //                 orderMasterViewModel.apiDispatchedCount.value;
// // // //             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// // // //             final totalReturn = returnFormViewModel.allReturnForm.length;
// // // //             final totalAttendanceIn = attendanceViewModel.allAttendance.length;
// // // //
// // // //             return Container(
// // // //               padding: const EdgeInsets.all(20),
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.blue.shade50,
// // // //                 borderRadius: BorderRadius.circular(20),
// // // //                 boxShadow: [
// // // //                   BoxShadow(
// // // //                     color: Colors.blue.withOpacity(0.8),
// // // //                     spreadRadius: 3,
// // // //                     blurRadius: 9,
// // // //                     offset: const Offset(0, 3),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               child: Column(
// // // //                 children: [
// // // //                   OverviewRow(
// // // //                     numbers: [
// // // //                       totalShops.toString(),
// // // //                       totalShopsVisits.toString(),
// // // //                       totalOrders.toString(),
// // // //                       totalReturn.toString(),
// // // //                     ],
// // // //                     labels: const [
// // // //                       "Total Shops",
// // // //                       "total Shops Visits",
// // // //                       "total Orders",
// // // //                       "total\nReturn"
// // // //                     ],
// //
// //
// // // //                   ),
// // // //                   const SizedBox(height: 20),
// // // //                   OverviewRow(
// // // //                     numbers: [
// // // //                       totalAttendanceIn.toString(),
// // // //                       totalOrders.toString(),
// // // //                       totalDispatchedOrders.toString(),
// // // //                       totalRecovery.toString(),
// // // //                     ],
// // // //                     labels: const [
// // // //                       "total Attendance",
// // // //                       "total Bookings",
// // // //                       "total Dispatched Orders",
// // // //                       "total Recovery"
// // // //                     ],
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             );
// // // //           }),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // ✅ required for foreground service
// // // // void startCallback() {
// // // //   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// // // // }
// // // //
// // // // class MyTaskHandler extends TaskHandler {
// // // //   @override
// // // //   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
// // // //     // Start your timer or location logic here
// // // //   }
// // // //
// // // //   @override
// // // //   Future<void> onRepeatEvent(DateTime timestamp) async {
// // // //     // Called periodically (if you set repeat interval)
// // // //   }
// // // //
// // // //   @override
// // // //   Future<void> onDestroy(DateTime timestamp, bool restart) async {
// // // //     // Clean up resources here
// // // //   }
// // // // }
// // // //
// // // //
// // // //
// // // //
// // // //
// // // // import 'package:auto_route/annotations.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/physics.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:get/get.dart';
// // // // import 'package:order_booking_app/Databases/util.dart';
// // // // import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// // // // import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// // // // import 'package:order_booking_app/Screens/HomeScreenComponents/assets.dart';
// // // // import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// // // // import 'package:order_booking_app/screens/add_shop_screen.dart';
// // // // import 'package:order_booking_app/screens/return_form_screen.dart';
// // // // import 'package:rive/rive.dart' hide LinearGradient;
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// // // //
// // // // import '../GPX/screen.dart';
// // // // import '../LocatioPoints/ravelTimeViewModel.dart';
// // // // import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// // // // import '../ViewModels/add_shop_view_model.dart';
// // // // import '../ViewModels/location_view_model.dart';
// // // // import '../ViewModels/order_details_view_model.dart';
// // // // import '../ViewModels/return_form_view_model.dart';
// // // // import '../ViewModels/shop_visit_details_view_model.dart';
// // // // import 'HomeScreenComponents/action_box.dart';
// // // // import 'HomeScreenComponents/navbar.dart';
// // // // import 'HomeScreenComponents/overview_row.dart';
// // // // import 'HomeScreenComponents/profile_section.dart';
// // // // import 'HomeScreenComponents/theme.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// // // // import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// // // // import 'HomeScreenComponents/timer_card.dart';
// // // // import 'package:order_booking_app/Screens/code_screen.dart';
// // // // import 'leave_form_screen.dart';
// // // // import 'order_booking_status_screen.dart';
// // // //
// // // // // @RoutePage()
// // // // class HomeScreen extends StatefulWidget {
// // // //   const HomeScreen({super.key});
// // // //
// // // //   @override
// // // //   State<HomeScreen> createState() => _RiveAppHomeState();
// // // // }
// // // //
// // // // class _RiveAppHomeState extends State<HomeScreen>
// // // //     with TickerProviderStateMixin {
// // // //   late final addShopViewModel = Get.put(AddShopViewModel());
// // // //   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
// // // //   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
// // // //   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
// // // //   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
// // // //   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
// // // //   late final returnFormViewModel = Get.put(ReturnFormViewModel());
// // // //   late final attendanceViewModel = Get.put(AttendanceViewModel());
// // // //   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // // //   late final signUpController = Get.put(SignUpController());
// // // //   final LocationViewModel locationVM = Get.find<LocationViewModel>();
// // // //   late AnimationController? _animationController;
// // // //   late AnimationController? _onBoardingAnimController;
// // // //   late Animation<double> _onBoardingAnim;
// // // //   late Animation<double> _sidebarAnim;
// // // //   late SMIBool _menuBtn;
// // // //   final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
// // // //   final springDesc = const SpringDescription(
// // // //     mass: 0.1,
// // // //     stiffness: 40,
// // // //     damping: 5,
// // // //   );
// // // //   bool _showOnBoarding = false;
// // // //
// // // //   void _onMenuIconInit(Artboard artboard) {
// // // //     final controller =
// // // //     StateMachineController.fromArtboard(artboard, "State Machine");
// // // //     artboard.addController(controller!);
// // // //     _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
// // // //     _menuBtn.value = true;
// // // //   }
// // // //
// // // //   void _presentOnBoarding(bool show) {
// // // //     if (show) {
// // // //       setState(() {
// // // //         _showOnBoarding = true;
// // // //       });
// // // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // // //       _onBoardingAnimController?.animateWith(springAnim);
// // // //     } else {
// // // //       _onBoardingAnimController?.reverse().whenComplete(() => {
// // // //         setState(() {
// // // //           _showOnBoarding = false;
// // // //         })
// // // //       });
// // // //     }
// // // //   }
// // // //
// // // //   void onMenuPress() {
// // // //     if (_menuBtn.value) {
// // // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // // //       _animationController?.animateWith(springAnim);
// // // //     } else {
// // // //       _animationController?.reverse();
// // // //     }
// // // //     _menuBtn.change(!_menuBtn.value);
// // // //
// // // //     SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
// // // //         ? SystemUiOverlayStyle.dark
// // // //         : SystemUiOverlayStyle.light);
// // // //   }
// // // //
// // // //   _retrieveSavedValues() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     await prefs.reload();
// // // //
// // // //     setState(() {
// // // //       user_id = prefs.getString('userId') ?? '';
// // // //       userName = prefs.getString('userName') ?? '';
// // // //       userCity = prefs.getString('userCity') ?? '';
// // // //       userDesignation = prefs.getString('userDesignation') ?? '';
// // // //       userBrand = prefs.getString('userBrand') ?? '';
// // // //       userSM = prefs.getString('userSM') ?? '';
// // // //       userNSM = prefs.getString('userNSM') ?? '';
// // // //       userRSM = prefs.getString('userRSM') ?? '';
// // // //       userNameRSM = prefs.getString('userNameRSM') ?? '';
// // // //       userNameNSM = prefs.getString('userNameNSM') ?? '';
// // // //       userNameSM = prefs.getString('userNameSM') ?? '';
// // // //       companyName = prefs.getString('company_name') ?? '';
// // // //     });
// // // //     debugPrint(user_id);
// // // //   }
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     _animationController = AnimationController(
// // // //       duration: const Duration(milliseconds: 200),
// // // //       upperBound: 1,
// // // //       vsync: this,
// // // //     );
// // // //     _onBoardingAnimController = AnimationController(
// // // //       duration: const Duration(milliseconds: 350),
// // // //       upperBound: 1,
// // // //       vsync: this,
// // // //     );
// // // //
// // // //     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // // //       parent: _animationController!,
// // // //       curve: Curves.linear,
// // // //     ));
// // // //
// // // //     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // // //       parent: _onBoardingAnimController!,
// // // //       curve: Curves.linear,
// // // //     ));
// // // //
// // // //     super.initState();
// // // //     _retrieveSavedValues();
// // // //     addShopViewModel.fetchAllAddShop();
// // // //     shopVisitViewModel.fetchAllShopVisit();
// // // //     shopVisitViewModel.fetchTotalShopVisit();
// // // //     shopVisitDetailsViewModel.initializeProductData();
// // // //     orderMasterViewModel.fetchAllOrderMaster();
// // // //     orderMasterViewModel.fetchTotalDispatched();
// // // //     recoveryFormViewModel.fetchAllRecoveryForm();
// // // //     returnFormViewModel.fetchAllReturnForm();
// // // //     attendanceViewModel.fetchAllAttendance();
// // // //     attendanceOutViewModel.fetchAllAttendanceOut();
// // // //
// // // //     // ✅ Start foreground service here
// // // //     FlutterForegroundTask.startService(
// // // //       notificationTitle: 'Clock Running',
// // // //       notificationText: 'Tracking time and location...',
// // // //       callback: startCallback,
// // // //     );
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _animationController?.dispose();
// // // //     _onBoardingAnimController?.dispose();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   void processGPXData() {
// // // //     LocationViewModel locationVM = Get.find<LocationViewModel>();
// // // //     locationVM.processGPXAndStoreCentralPoint();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     // ✅ ABDULLAH: Home screen par working status false karein
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // // //       travelTimeViewModel.setWorkingScreenStatus(false);
// // // //       debugPrint("📍 [WORKING STATUS] Home Screen - Working time INACTIVE");
// // // //     });
// // // //
// // // //     return WillPopScope(
// // // //       onWillPop: () async => false,
// // // //       child: SafeArea(
// // // //         child: Scaffold(
// // // //           backgroundColor: Colors.grey.shade50,
// // // //           body: SingleChildScrollView(
// // // //             child: Column(
// // // //               children: [
// // // //                 _buildHeader(),
// // // //                 const SizedBox(height: 10),
// // // //
// // // //                 // Timer Card Section
// // // //                 Padding(
// // // //                   padding: const EdgeInsets.symmetric(horizontal: 20),
// // // //                   child: TimerCard(),
// // // //                 ),
// // // //                 const SizedBox(height: 10),
// // // //
// // // //                 // Quick Actions Section
// // // //                 _buildActionButtons(MediaQuery.of(context).size.width),
// // // //                 const SizedBox(height: 15),
// // // //
// // // //                 // Overview Section
// // // //                 _buildOverviewSection(),
// // // //                 const SizedBox(height: 15),
// // // //
// // // //                 // Footer
// // // //                 Padding(
// // // //                   padding: const EdgeInsets.only(bottom: 20),
// // // //                   child: Column(
// // // //                     children: [
// // // //                       Divider(
// // // //                         color: Colors.grey.shade300,
// // // //                         height: 1,
// // // //                         indent: 40,
// // // //                         endIndent: 40,
// // // //                       ),
// // // //                       const SizedBox(height: 15),
// // // //                       const Text(
// // // //                         '• Version v0.1.2',
// // // //                         style: TextStyle(
// // // //                           color: Colors.grey,
// // // //                           fontSize: 13,
// // // //                           fontWeight: FontWeight.w500,
// // // //                           letterSpacing: 0.5,
// // // //                           fontStyle: FontStyle.italic, // ✅ FIX
// // // //                         ),
// // // //                       ),
// // // //
// // // //                       const SizedBox(height: 4),
// // // //                       Text(
// // // //                         '© 2026 BookIT (Sales Management)',
// // // //                         style: TextStyle(
// // // //                           color: Colors.grey.shade400,
// // // //                           fontSize: 11,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildHeader() {
// // // //     return Container(
// // // //       decoration: BoxDecoration(
// // // //         gradient: LinearGradient(
// // // //           begin: Alignment.topCenter,
// // // //           end: Alignment.bottomCenter,
// // // //           colors: [
// // // //             Colors.blue.shade800,
// // // //             Colors.blue.shade600,
// // // //           ],
// // // //         ),
// // // //         borderRadius: const BorderRadius.only(
// // // //           bottomLeft: Radius.circular(25),
// // // //           bottomRight: Radius.circular(25),
// // // //         ),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.blue.shade800.withOpacity(0.3),
// // // //             spreadRadius: 2,
// // // //             blurRadius: 15,
// // // //             offset: const Offset(0, 5),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: SafeArea(
// // // //         bottom: false,
// // // //         child: Column(
// // // //           children: [
// // // //             Navbar(),
// // // //             const SizedBox(height: 10),
// // // //             const ProfileSection(),
// // // //             const SizedBox(height: 20),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // Widget _buildActionButtons(double screenWidth) {
// // // //   //   return Padding(
// // // //   //     padding: const EdgeInsets.symmetric(horizontal: 20),
// // // //   //     child: Column(
// // // //   //       children: [
// // // //   //         // Section Title
// // // //   //         const Padding(
// // // //   //           padding: EdgeInsets.symmetric(vertical: 10),
// // // //   //           child: Row(
// // // //   //             children: [
// // // //   //               Icon(
// // // //   //                 Icons.dashboard_rounded,
// // // //   //                 color: Colors.blue,
// // // //   //                 size: 24,
// // // //   //               ),
// // // //   //               SizedBox(width: 10),
// // // //   //               Text(
// // // //   //                 "Quick Actions",
// // // //   //                 style: TextStyle(
// // // //   //                   fontSize: 20,
// // // //   //                   fontWeight: FontWeight.bold,
// // // //   //                   color: Colors.blue,
// // // //   //                 ),
// // // //   //               ),
// // // //   //             ],
// // // //   //           ),
// // // //   //         ),
// // // //   //
// // // //   //         // First Row - 3 buttons
// // // //   //         Row(
// // // //   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //   //           children: [
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.add_business_rounded,
// // // //   //               label: 'Add Shop',
// // // //   //               color: Colors.blue,
// // // //   //               onTap: () async {
// // // //   //                 final locationVM = Get.find<LocationViewModel>();
// // // //   //                 if (locationVM.isClockedIn.value) {
// // // //   //                   Get.to(() => AddShopScreen());
// // // //   //                 } else {
// // // //   //                   _showClockInRequiredDialog();
// // // //   //                 }
// // // //   //               },
// // // //   //             ),
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.storefront_rounded,
// // // //   //               label: 'Shop Visit',
// // // //   //               color: Colors.green,
// // // //   //               onTap: () async {
// // // //   //                 final locationVM = Get.find<LocationViewModel>();
// // // //   //                 if (locationVM.isClockedIn.value) {
// // // //   //                   Get.to(() => const ShopVisitScreen());
// // // //   //                 } else {
// // // //   //                   _showClockInRequiredDialog();
// // // //   //                 }
// // // //   //               },
// // // //   //             ),
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.assignment_return_rounded,
// // // //   //               label: 'Return Form',
// // // //   //               color: Colors.orange,
// // // //   //               onTap: () async {
// // // //   //                 final locationVM = Get.find<LocationViewModel>();
// // // //   //                 if (locationVM.isClockedIn.value) {
// // // //   //                   await orderMasterViewModel.fetchAllOrderMaster();
// // // //   //                   await orderDetailsViewModel.fetchAllReConfirmOrder();
// // // //   //                   Get.to(() => ReturnFormScreen());
// // // //   //                 } else {
// // // //   //                   _showClockInRequiredDialog();
// // // //   //                 }
// // // //   //               },
// // // //   //             ),
// // // //   //           ],
// // // //   //         ),
// // // //   //         const SizedBox(height: 15),
// // // //   //
// // // //   //         // Second Row - 3 buttons
// // // //   //         Row(
// // // //   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //   //           children: [
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.monetization_on_rounded,
// // // //   //               label: 'Recovery',
// // // //   //               color: Colors.purple,
// // // //   //               onTap: () async {
// // // //   //                 final locationVM = Get.find<LocationViewModel>();
// // // //   //                 if (locationVM.isClockedIn.value) {
// // // //   //                   await orderMasterViewModel.fetchAllOrderMaster();
// // // //   //                   await recoveryFormViewModel.initializeData();
// // // //   //                   Get.to(() => RecoveryFormScreen());
// // // //   //                 } else {
// // // //   //                   _showClockInRequiredDialog();
// // // //   //                 }
// // // //   //               },
// // // //   //             ),
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.shopping_cart_checkout_rounded,
// // // //   //               label: 'Booking Status',
// // // //   //               color: Colors.teal,
// // // //   //               onTap: () async {
// // // //   //                 await orderMasterViewModel.fetchAllOrderMaster();
// // // //   //                 Get.to(() => OrderBookingStatusScreen());
// // // //   //               },
// // // //   //             ),
// // // //   //             _buildModernActionBox(
// // // //   //               icon: Icons.beach_access_rounded,
// // // //   //               label: 'Leave',
// // // //   //               color: Colors.red,
// // // //   //               onTap: () {
// // // //   //                 Get.to(() => LeaveFormScreen());
// // // //   //               },
// // // //   //             ),
// // // //   //           ],
// // // //   //         ),
// // // //   //       ],
// // // //   //     ),
// // // //   //   );
// // // //   // }
// // // //   //
// // // //   // Widget _buildModernActionBox({
// // // //   //   required IconData icon,
// // // //   //   required String label,
// // // //   //   required Color color,
// // // //   //   required VoidCallback onTap,
// // // //   // }) {
// // // //   //   return Expanded(
// // // //   //     child: Padding(
// // // //   //       padding: const EdgeInsets.symmetric(horizontal: 4),
// // // //   //       child: Card(
// // // //   //         elevation: 3,
// // // //   //         shape: RoundedRectangleBorder(
// // // //   //           borderRadius: BorderRadius.circular(16),
// // // //   //         ),
// // // //   //         child: InkWell(
// // // //   //           onTap: onTap,
// // // //   //           borderRadius: BorderRadius.circular(16),
// // // //   //           child: Container(
// // // //   //             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
// // // //   //             decoration: BoxDecoration(
// // // //   //               borderRadius: BorderRadius.circular(16),
// // // //   //               gradient: LinearGradient(
// // // //   //                 begin: Alignment.topLeft,
// // // //   //                 end: Alignment.bottomRight,
// // // //   //                 colors: [
// // // //   //                   color.withOpacity(0.1),
// // // //   //                   color.withOpacity(0.05),
// // // //   //                 ],
// // // //   //               ),
// // // //   //             ),
// // // //   //             child: Column(
// // // //   //               mainAxisAlignment: MainAxisAlignment.center,
// // // //   //               children: [
// // // //   //                 Container(
// // // //   //                   padding: const EdgeInsets.all(14),
// // // //   //                   decoration: BoxDecoration(
// // // //   //                     color: color.withOpacity(0.15),
// // // //   //                     shape: BoxShape.circle,
// // // //   //                   ),
// // // //   //                   child: Icon(
// // // //   //                     icon,
// // // //   //                     color: color,
// // // //   //                     size: 28,
// // // //   //                   ),
// // // //   //                 ),
// // // //   //                 const SizedBox(height: 12),
// // // //   //                 Text(
// // // //   //                   label,
// // // //   //                   textAlign: TextAlign.center,
// // // //   //                   style: TextStyle(
// // // //   //                     fontSize: 13,
// // // //   //                     fontWeight: FontWeight.w600,
// // // //   //                     color: Colors.grey.shade800,
// // // //   //                   ),
// // // //   //                 ),
// // // //   //               ],
// // // //   //             ),
// // // //   //           ),
// // // //   //         ),
// // // //   //       ),
// // // //   //     ),
// // // //   //   );
// // // //   // }
// // // //
// // // //   // Widget _buildOverviewSection() {
// // // //   //   return Padding(
// // // //   //     padding: const EdgeInsets.symmetric(horizontal: 20),
// // // //   //     child: Column(
// // // //   //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //   //       children: [
// // // //   //         // Section Header with Refresh Button
// // // //   //         const Row(
// // // //   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //   //           children: [
// // // //   //             Row(
// // // //   //               children: [
// // // //   //                 Icon(
// // // //   //                   Icons.analytics_rounded,
// // // //   //                   color: Colors.blue,
// // // //   //                   size: 28,
// // // //   //                 ),
// // // //   //                 SizedBox(width: 10),
// // // //   //                 Text(
// // // //   //                   "Performance Overview",
// // // //   //                   style: TextStyle(
// // // //   //                     fontSize: 22,
// // // //   //                     fontWeight: FontWeight.bold,
// // // //   //                     color: Colors.blue,
// // // //   //                   ),
// // // //   //                 ),
// // // //   //               ],
// // // //   //             ),
// // // //   //           ],
// // // //   //         ),
// // // //   //         const SizedBox(height: 10),
// // // //   //         Text(
// // // //   //           "Today's performance metrics",
// // // //   //           style: TextStyle(
// // // //   //             fontSize: 14,
// // // //   //             color: Colors.grey.shade600,
// // // //   //             fontWeight: FontWeight.w500,
// // // //   //           ),
// // // //   //         ),
// // // //   //         const SizedBox(height: 20),
// // // //   //
// // // //   //         Obx(() {
// // // //   //           final totalShops = addShopViewModel.allAddShop.length;
// // // //   //           final totalShopsVisits = shopVisitViewModel.apiShopVisitsCount.value;
// // // //   //           final totalOrders = orderMasterViewModel.allOrderMaster.length;
// // // //   //           final totalDispatchedOrders = orderMasterViewModel.apiDispatchedCount.value;
// // // //   //           final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// // // //   //           final totalReturn = returnFormViewModel.allReturnForm.length;
// // // //   //           final totalAttendanceIn = attendanceViewModel.allAttendance.length;
// // // //   //
// // // //   //           return Container(
// // // //   //             padding: const EdgeInsets.all(24),
// // // //   //             decoration: BoxDecoration(
// // // //   //               gradient: LinearGradient(
// // // //   //                 begin: Alignment.topLeft,
// // // //   //                 end: Alignment.bottomRight,
// // // //   //                 colors: [
// // // //   //                   Colors.white,
// // // //   //                   Colors.blue.shade50,
// // // //   //                 ],
// // // //   //               ),
// // // //   //               borderRadius: BorderRadius.circular(20),
// // // //   //               boxShadow: [
// // // //   //                 BoxShadow(
// // // //   //                   color: Colors.blue.shade100.withOpacity(0.2),
// // // //   //                   spreadRadius: 2,
// // // //   //                   blurRadius: 12,
// // // //   //                   offset: const Offset(0, 4),
// // // //   //                 ),
// // // //   //               ],
// // // //   //               border: Border.all(
// // // //   //                 color: Colors.blue.shade100,
// // // //   //                 width: 1,
// // // //   //               ),
// // // //   //             ),
// // // //   //             child: Column(
// // // //   //               children: [
// // // //   //                 // First Row - 4 Stats
// // // //   //                 Row(
// // // //   //                   children: [
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalShops.toString(),
// // // //   //                       label: "Total Shops",
// // // //   //                       icon: Icons.store_rounded,
// // // //   //                       color: Colors.blue,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalShopsVisits.toString(),
// // // //   //                       label: "Shop Visits",
// // // //   //                       icon: Icons.store,
// // // //   //                       color: Colors.green,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalOrders.toString(),
// // // //   //                       label: "Total Orders",
// // // //   //                       icon: Icons.shopping_cart_rounded,
// // // //   //                       color: Colors.orange,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalReturn.toString(),
// // // //   //                       label: "Returns",
// // // //   //                       icon: Icons.assignment_return_rounded,
// // // //   //                       color: Colors.red,
// // // //   //                     ),
// // // //   //                   ],
// // // //   //                 ),
// // // //   //                 const SizedBox(height: 20),
// // // //   //
// // // //   //                 // Second Row - 4 Stats
// // // //   //                 Row(
// // // //   //                   children: [
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalAttendanceIn.toString(),
// // // //   //                       label: "Attendance",
// // // //   //                       icon: Icons.punch_clock_rounded,
// // // //   //                       color: Colors.purple,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalOrders.toString(),
// // // //   //                       label: "Bookings",
// // // //   //                       icon: Icons.book_online_rounded,
// // // //   //                       color: Colors.teal,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalDispatchedOrders.toString(),
// // // //   //                       label: "Dispatched",
// // // //   //                       icon: Icons.local_shipping_rounded,
// // // //   //                       color: Colors.indigo,
// // // //   //                     ),
// // // //   //                     _buildStatCard(
// // // //   //                       value: totalRecovery.toString(),
// // // //   //                       label: "Recovery",
// // // //   //                       icon: Icons.monetization_on_rounded,
// // // //   //                       color: Colors.green,
// // // //   //                     ),
// // // //   //                   ],
// // // //   //                 ),
// // // //   //               ],
// // // //   //             ),
// // // //   //           );
// // // //   //         }),
// // // //   //       ],
// // // //   //     ),
// // // //   //   );
// // // //   // }
// // // //   //
// // // //   // Widget _buildStatCard({
// // // //   //   required String value,
// // // //   //   required String label,
// // // //   //   required IconData icon,
// // // //   //   required Color color,
// // // //   // }) {
// // // //   //   return Expanded(
// // // //   //     child: Container(
// // // //   //       margin: const EdgeInsets.symmetric(horizontal: 4),
// // // //   //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
// // // //   //       decoration: BoxDecoration(
// // // //   //         color: color.withOpacity(0.08),
// // // //   //         borderRadius: BorderRadius.circular(12),
// // // //   //         border: Border.all(color: color.withOpacity(0.2)),
// // // //   //       ),
// // // //   //       child: Column(
// // // //   //         children: [
// // // //   //           Container(
// // // //   //             padding: const EdgeInsets.all(8),
// // // //   //             decoration: BoxDecoration(
// // // //   //               color: color.withOpacity(0.15),
// // // //   //               shape: BoxShape.circle,
// // // //   //             ),
// // // //   //             child: Icon(
// // // //   //               icon,
// // // //   //               color: color,
// // // //   //               size: 20,
// // // //   //             ),
// // // //   //           ),
// // // //   //           const SizedBox(height: 10),
// // // //   //           Text(
// // // //   //             value,
// // // //   //             style: TextStyle(
// // // //   //               fontSize: 20,
// // // //   //               fontWeight: FontWeight.bold,
// // // //   //               color: color,
// // // //   //             ),
// // // //   //           ),
// // // //   //           const SizedBox(height: 4),
// // // //   //           Text(
// // // //   //             label,
// // // //   //             textAlign: TextAlign.center,
// // // //   //             style: TextStyle(
// // // //   //               fontSize: 11,
// // // //   //               fontWeight: FontWeight.w500,
// // // //   //               color: Colors.grey.shade700,
// // // //   //             ),
// // // //   //           ),
// // // //   //         ],
// // // //   //       ),
// // // //   //     ),
// // // //   //   );
// // // //   // }
// // // //
// // // //   Widget _buildActionButtons(double screenWidth) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 20),
// // // //       child: Column(
// // // //         children: [
// // // //           // Section Title
// // // //           const Padding(
// // // //             padding: EdgeInsets.symmetric(vertical: 10),
// // // //             child: Row(
// // // //               children: [
// // // //                 Icon(
// // // //                   Icons.dashboard_rounded,
// // // //                   color: Colors.blue,
// // // //                   size: 22,
// // // //                 ),
// // // //                 SizedBox(width: 8),
// // // //                 Text(
// // // //                   "Quick Actions",
// // // //                   style: TextStyle(
// // // //                     fontSize: 18,
// // // //                     fontWeight: FontWeight.bold,
// // // //                     color: Colors.blue,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //
// // // //           // First Row - 3 buttons
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.add_business_rounded,
// // // //                 label: 'Add Shop',
// // // //                 color: Colors.blue,
// // // //                 onTap: () async {
// // // //                   final locationVM = Get.find<LocationViewModel>();
// // // //                   if (locationVM.isClockedIn.value) {
// // // //                     Get.to(() => AddShopScreen());
// // // //                   } else {
// // // //                     _showClockInRequiredDialog();
// // // //                   }
// // // //                 },
// // // //               ),
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.storefront_rounded,
// // // //                 label: 'Shop Visit',
// // // //                 color: Colors.green,
// // // //                 onTap: () async {
// // // //                   final locationVM = Get.find<LocationViewModel>();
// // // //                   if (locationVM.isClockedIn.value) {
// // // //                     Get.to(() => const ShopVisitScreen());
// // // //                   } else {
// // // //                     _showClockInRequiredDialog();
// // // //                   }
// // // //                 },
// // // //               ),
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.assignment_return_rounded,
// // // //                 label: 'Return Form',
// // // //                 color: Colors.orange,
// // // //                 onTap: () async {
// // // //                   final locationVM = Get.find<LocationViewModel>();
// // // //                   if (locationVM.isClockedIn.value) {
// // // //                     await orderMasterViewModel.fetchAllOrderMaster();
// // // //                     await orderDetailsViewModel.fetchAllReConfirmOrder();
// // // //                     Get.to(() => ReturnFormScreen());
// // // //                   } else {
// // // //                     _showClockInRequiredDialog();
// // // //                   }
// // // //                 },
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 2),
// // // //
// // // //           // Second Row - 3 buttons
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.monetization_on_rounded,
// // // //                 label: 'Recovery',
// // // //                 color: Colors.purple,
// // // //                 onTap: () async {
// // // //                   final locationVM = Get.find<LocationViewModel>();
// // // //                   if (locationVM.isClockedIn.value) {
// // // //                     await orderMasterViewModel.fetchAllOrderMaster();
// // // //                     await recoveryFormViewModel.initializeData();
// // // //                     Get.to(() => RecoveryFormScreen());
// // // //                   } else {
// // // //                     _showClockInRequiredDialog();
// // // //                   }
// // // //                 },
// // // //               ),
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.shopping_cart_checkout_rounded,
// // // //                 label: 'Booking Status',
// // // //                 color: Colors.teal,
// // // //                 onTap: () async {
// // // //                   await orderMasterViewModel.fetchAllOrderMaster();
// // // //                   Get.to(() => OrderBookingStatusScreen());
// // // //                 },
// // // //               ),
// // // //               _buildModernActionBox(
// // // //                 icon: Icons.beach_access_rounded,
// // // //                 label: 'Leave',
// // // //                 color: Colors.red,
// // // //                 onTap: () {
// // // //                   Get.to(() => LeaveFormScreen());
// // // //                 },
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildModernActionBox({
// // // //     required IconData icon,
// // // //     required String label,
// // // //     required Color color,
// // // //     required VoidCallback onTap,
// // // //   }) {
// // // //     return Expanded(
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // // //         child: Card(
// // // //           elevation: 2,
// // // //           shape: RoundedRectangleBorder(
// // // //             borderRadius: BorderRadius.circular(12),
// // // //           ),
// // // //           child: InkWell(
// // // //             onTap: onTap,
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             child: Container(
// // // //               constraints: const BoxConstraints(
// // // //                 minHeight: 100, // Smaller height
// // // //                 maxHeight: 110,
// // // //               ),
// // // //               padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
// // // //               decoration: BoxDecoration(
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 gradient: LinearGradient(
// // // //                   begin: Alignment.topLeft,
// // // //                   end: Alignment.bottomRight,
// // // //                   colors: [
// // // //                     color.withOpacity(0.08),
// // // //                     color.withOpacity(0.03),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //               child: Column(
// // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // //                 children: [
// // // //                   Container(
// // // //                     padding: const EdgeInsets.all(10), // Smaller icon container
// // // //                     decoration: BoxDecoration(
// // // //                       color: color.withOpacity(0.12),
// // // //                       shape: BoxShape.circle,
// // // //                     ),
// // // //                     child: Icon(
// // // //                       icon,
// // // //                       color: color,
// // // //                       size: 22, // Smaller icon
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 8),
// // // //                   Padding(
// // // //                     padding: const EdgeInsets.symmetric(horizontal: 4),
// // // //                     child: Text(
// // // //                       label,
// // // //                       textAlign: TextAlign.center,
// // // //                       maxLines: 2,
// // // //                       overflow: TextOverflow.ellipsis,
// // // //                       style: TextStyle(
// // // //                         fontSize: 12, // Smaller text
// // // //                         fontWeight: FontWeight.w600,
// // // //                         color: Colors.grey.shade800,
// // // //                         height: 1.2,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //
// // // //   Widget _buildOverviewSection() {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           // Section Header
// // // //           const Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(
// // // //                 children: [
// // // //                   Icon(
// // // //                     Icons.analytics_rounded,
// // // //                     color: Colors.blue,
// // // //                     size: 22,
// // // //                   ),
// // // //                   SizedBox(width: 6),
// // // //                   Text(
// // // //                     "Performance Overview",
// // // //                     style: TextStyle(
// // // //                       fontSize: 18,
// // // //                       fontWeight: FontWeight.bold,
// // // //                       color: Colors.blue,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           // const SizedBox(height: 4),
// // // //           // Text(
// // // //           //   "Today's performance metrics",
// // // //           //   style: TextStyle(
// // // //           //     fontSize: 11,
// // // //           //     color: Colors.grey.shade600,
// // // //           //     fontWeight: FontWeight.w500,
// // // //           //   ),
// // // //           // ),
// // // //           const SizedBox(height: 10),
// // // //
// // // //           Obx(() {
// // // //             final totalShops = addShopViewModel.allAddShop.length;
// // // //             final totalShopsVisits = shopVisitViewModel.apiShopVisitsCount.value;
// // // //             final totalOrders = orderMasterViewModel.allOrderMaster.length;
// // // //             final totalDispatchedOrders = orderMasterViewModel.apiDispatchedCount.value;
// // // //             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// // // //             final totalReturn = returnFormViewModel.allReturnForm.length;
// // // //             final totalAttendanceIn = attendanceViewModel.allAttendance.length;
// // // //
// // // //             return Container(
// // // //               padding: const EdgeInsets.all(10),
// // // //               decoration: BoxDecoration(
// // // //                 color: Colors.white,
// // // //                 borderRadius: BorderRadius.circular(14),
// // // //                 boxShadow: [
// // // //                   BoxShadow(
// // // //                     color: Colors.grey.shade200,
// // // //                     blurRadius: 6,
// // // //                     spreadRadius: 1,
// // // //                     offset: const Offset(0, 2),
// // // //                   ),
// // // //                 ],
// // // //                 border: Border.all(
// // // //                   color: Colors.grey.shade100,
// // // //                   width: 1,
// // // //                 ),
// // // //               ),
// // // //               child: Column(
// // // //                 children: [
// // // //                   // First Row - 4 Stats
// // // //                   Row(
// // // //                     children: [
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.store_rounded,
// // // //                           label: "Shops",
// // // //                           value: totalShops.toString(),
// // // //                           color: Colors.blue,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.store_mall_directory_rounded,
// // // //                           label: "Visits",
// // // //                           value: totalShopsVisits.toString(),
// // // //                           color: Colors.green,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.shopping_cart_rounded,
// // // //                           label: "Orders",
// // // //                           value: totalOrders.toString(),
// // // //                           color: Colors.orange,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.book_online_rounded,
// // // //                           label: "Bookings",
// // // //                           value: totalOrders.toString(),
// // // //                           color: Colors.teal,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                   const SizedBox(height: 8),
// // // //
// // // //                   // Second Row - 4 Stats
// // // //                   Row(
// // // //                     children: [
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.local_shipping_rounded,
// // // //                           label: "Dispatched",
// // // //                           value: totalDispatchedOrders.toString(),
// // // //                           color: Colors.indigo,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.assignment_return_rounded,
// // // //                           label: "Returns",
// // // //                           value: totalReturn.toString(),
// // // //                           color: Colors.red,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.monetization_on_rounded,
// // // //                           label: "Recovery",
// // // //                           value: totalRecovery.toString(),
// // // //                           color: Colors.purple,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                         child: _buildTinyStatCard(
// // // //                           icon: Icons.punch_clock_rounded,
// // // //                           label: "Attendance",
// // // //                           value: totalAttendanceIn.toString(),
// // // //                           color: Colors.blueAccent,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             );
// // // //           }),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildTinyStatCard({
// // // //     required IconData icon,
// // // //     required String label,
// // // //     required String value,
// // // //     required Color color,
// // // //   }) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
// // // //       decoration: BoxDecoration(
// // // //         color: color.withOpacity(0.04),
// // // //         borderRadius: BorderRadius.circular(10),
// // // //         border: Border.all(
// // // //           color: color.withOpacity(0.1),
// // // //           width: 0.5,
// // // //         ),
// // // //       ),
// // // //       child: Column(
// // // //         mainAxisAlignment: MainAxisAlignment.center,
// // // //         children: [
// // // //           Container(
// // // //             width: 30,
// // // //             height: 30,
// // // //             decoration: BoxDecoration(
// // // //               color: color.withOpacity(0.1),
// // // //               borderRadius: BorderRadius.circular(8),
// // // //             ),
// // // //             child: Icon(
// // // //               icon,
// // // //               color: color,
// // // //               size: 16,
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 4),
// // // //           Text(
// // // //             value,
// // // //             style: TextStyle(
// // // //               fontSize: 14,
// // // //               fontWeight: FontWeight.bold,
// // // //               color: color,
// // // //             ),
// // // //           ),
// // // //           Text(
// // // //             label,
// // // //             textAlign: TextAlign.center,
// // // //             style: TextStyle(
// // // //               fontSize: 10,
// // // //               fontWeight: FontWeight.w500,
// // // //               color: Colors.grey.shade700,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildOverviewRow({
// // // //     required IconData icon,
// // // //     required String label,
// // // //     required String value,
// // // //     required Color color,
// // // //     bool isFirst = false,
// // // //     bool isLast = false,
// // // //   }) {
// // // //     return Container(
// // // //       decoration: BoxDecoration(
// // // //         border: isLast
// // // //             ? null
// // // //             : Border(
// // // //           bottom: BorderSide(
// // // //             color: Colors.grey.shade200,
// // // //             width: 1.5,
// // // //           ),
// // // //         ),
// // // //       ),
// // // //       child: Padding(
// // // //         padding: EdgeInsets.only(
// // // //           top: isFirst ? 0 : 15,
// // // //           bottom: isLast ? 0 : 15,
// // // //         ),
// // // //         child: Row(
// // // //           children: [
// // // //             // Icon Container
// // // //             Container(
// // // //               width: 50,
// // // //               height: 50,
// // // //               decoration: BoxDecoration(
// // // //                 color: color.withOpacity(0.1),
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 border: Border.all(
// // // //                   color: color.withOpacity(0.3),
// // // //                   width: 1.5,
// // // //                 ),
// // // //               ),
// // // //               child: Icon(
// // // //                 icon,
// // // //                 color: color,
// // // //                 size: 26,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(width: 15),
// // // //
// // // //             // Label and Value
// // // //             Expanded(
// // // //               child: Column(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   Text(
// // // //                     label,
// // // //                     style: TextStyle(
// // // //                       fontSize: 16,
// // // //                       fontWeight: FontWeight.w600,
// // // //                       color: Colors.grey.shade800,
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 4),
// // // //                   Text(
// // // //                     "Today's count",
// // // //                     style: TextStyle(
// // // //                       fontSize: 12,
// // // //                       color: Colors.grey.shade500,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //             // Value with badge
// // // //             Container(
// // // //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //               decoration: BoxDecoration(
// // // //                 color: color.withOpacity(0.1),
// // // //                 borderRadius: BorderRadius.circular(20),
// // // //                 border: Border.all(
// // // //                   color: color.withOpacity(0.3),
// // // //                   width: 1,
// // // //                 ),
// // // //               ),
// // // //               child: Text(
// // // //                 value,
// // // //                 style: TextStyle(
// // // //                   fontSize: 18,
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: color,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   void _showClockInRequiredDialog() {
// // // //     Get.defaultDialog(
// // // //       title: "⏰ Clock In Required",
// // // //       titleStyle: const TextStyle(
// // // //         fontWeight: FontWeight.bold,
// // // //         color: Colors.blue,
// // // //       ),
// // // //       middleText: "Please start the timer first to access this feature.",
// // // //       middleTextStyle: const TextStyle(color: Colors.grey),
// // // //       textConfirm: "OK",
// // // //       confirmTextColor: Colors.white,
// // // //       buttonColor: Colors.blue,
// // // //       onConfirm: () {
// // // //         Get.back();
// // // //       },
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // ✅ required for foreground service
// // // // void startCallback() {
// // // //   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// // // // }
// // // //
// // // // class MyTaskHandler extends TaskHandler {
// // // //   @override
// // // //   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
// // // //     // Start your timer or location logic here
// // // //   }
// // // //
// // // //   @override
// // // //   Future<void> onRepeatEvent(DateTime timestamp) async {
// // // //     // Called periodically (if you set repeat interval)
// // // //   }
// // // //
// // // //   @override
// // // //   Future<void> onDestroy(DateTime timestamp, bool restart) async {
// // // //     // Clean up resources here
// // // //   }
// // // // }
// // //
// // //
// // // import 'package:auto_route/annotations.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/physics.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/Databases/util.dart';
// // // import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// // // import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// // // import 'package:order_booking_app/Screens/HomeScreenComponents/assets.dart';
// // // import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// // // import 'package:order_booking_app/screens/add_shop_screen.dart';
// // // import 'package:order_booking_app/screens/return_form_screen.dart';
// // // import 'package:rive/rive.dart' hide LinearGradient;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// // //
// // // import '../GPX/screen.dart';
// // // import '../LocatioPoints/ravelTimeViewModel.dart';
// // // import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// // // import '../ViewModels/add_shop_view_model.dart';
// // // import '../ViewModels/location_view_model.dart';
// // // import '../ViewModels/order_details_view_model.dart';
// // // import '../ViewModels/return_form_view_model.dart';
// // // import '../ViewModels/shop_visit_details_view_model.dart';
// // // import 'HomeScreenComponents/action_box.dart';
// // // import 'HomeScreenComponents/navbar.dart';
// // // import 'HomeScreenComponents/overview_row.dart';
// // // import 'HomeScreenComponents/profile_section.dart';
// // // import 'HomeScreenComponents/theme.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// // // import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// // // import 'HomeScreenComponents/timer_card.dart';
// // // import 'package:order_booking_app/Screens/code_screen.dart';
// // // import 'leave_form_screen.dart';
// // // import 'order_booking_status_screen.dart';
// // //
// // // // @RoutePage()
// // // class HomeScreen extends StatefulWidget {
// // //   const HomeScreen({super.key});
// // //
// // //   @override
// // //   State<HomeScreen> createState() => _RiveAppHomeState();
// // // }
// // //
// // // class _RiveAppHomeState extends State<HomeScreen>
// // //     with TickerProviderStateMixin {
// // //   late final addShopViewModel = Get.put(AddShopViewModel());
// // //   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
// // //   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
// // //   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
// // //   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
// // //   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
// // //   late final returnFormViewModel = Get.put(ReturnFormViewModel());
// // //   late final attendanceViewModel = Get.put(AttendanceViewModel());
// // //   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// // //   late final signUpController = Get.put(SignUpController());
// // //   final LocationViewModel locationVM = Get.find<LocationViewModel>();
// // //   late AnimationController? _animationController;
// // //   late AnimationController? _onBoardingAnimController;
// // //   late Animation<double> _onBoardingAnim;
// // //   late Animation<double> _sidebarAnim;
// // //   late SMIBool _menuBtn;
// // //   final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
// // //   final springDesc = const SpringDescription(
// // //     mass: 0.1,
// // //     stiffness: 40,
// // //     damping: 5,
// // //   );
// // //   bool _showOnBoarding = false;
// // //
// // //   void _onMenuIconInit(Artboard artboard) {
// // //     final controller =
// // //     StateMachineController.fromArtboard(artboard, "State Machine");
// // //     artboard.addController(controller!);
// // //     _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
// // //     _menuBtn.value = true;
// // //   }
// // //
// // //   void _presentOnBoarding(bool show) {
// // //     if (show) {
// // //       setState(() {
// // //         _showOnBoarding = true;
// // //       });
// // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // //       _onBoardingAnimController?.animateWith(springAnim);
// // //     } else {
// // //       _onBoardingAnimController?.reverse().whenComplete(() => {
// // //         setState(() {
// // //           _showOnBoarding = false;
// // //         })
// // //       });
// // //     }
// // //   }
// // //
// // //   void onMenuPress() {
// // //     if (_menuBtn.value) {
// // //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// // //       _animationController?.animateWith(springAnim);
// // //     } else {
// // //       _animationController?.reverse();
// // //     }
// // //     _menuBtn.change(!_menuBtn.value);
// // //
// // //     SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
// // //         ? SystemUiOverlayStyle.dark
// // //         : SystemUiOverlayStyle.light);
// // //   }
// // //
// // //   _retrieveSavedValues() async {
// // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // //     await prefs.reload();
// // //
// // //     setState(() {
// // //       user_id = prefs.getString('userId') ?? '';
// // //       userName = prefs.getString('userName') ?? '';
// // //       userCity = prefs.getString('userCity') ?? '';
// // //       userDesignation = prefs.getString('userDesignation') ?? '';
// // //       userBrand = prefs.getString('userBrand') ?? '';
// // //       userSM = prefs.getString('userSM') ?? '';
// // //       userNSM = prefs.getString('userNSM') ?? '';
// // //       userRSM = prefs.getString('userRSM') ?? '';
// // //       userNameRSM = prefs.getString('userNameRSM') ?? '';
// // //       userNameNSM = prefs.getString('userNameNSM') ?? '';
// // //       userNameSM = prefs.getString('userNameSM') ?? '';
// // //       companyName = prefs.getString('company_name') ?? '';
// // //     });
// // //     debugPrint(user_id);
// // //   }
// // //
// // //   @override
// // //   void initState() {
// // //     _animationController = AnimationController(
// // //       duration: const Duration(milliseconds: 200),
// // //       upperBound: 1,
// // //       vsync: this,
// // //     );
// // //     _onBoardingAnimController = AnimationController(
// // //       duration: const Duration(milliseconds: 350),
// // //       upperBound: 1,
// // //       vsync: this,
// // //     );
// // //
// // //     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // //       parent: _animationController!,
// // //       curve: Curves.linear,
// // //     ));
// // //
// // //     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// // //       parent: _onBoardingAnimController!,
// // //       curve: Curves.linear,
// // //     ));
// // //
// // //     super.initState();
// // //     _retrieveSavedValues();
// // //     addShopViewModel.fetchAllAddShop();
// // //     shopVisitViewModel.fetchAllShopVisit();
// // //     shopVisitViewModel.fetchTotalShopVisit();
// // //     shopVisitDetailsViewModel.initializeProductData();
// // //     orderMasterViewModel.fetchAllOrderMaster();
// // //     orderMasterViewModel.fetchTotalDispatched();
// // //     recoveryFormViewModel.fetchAllRecoveryForm();
// // //     returnFormViewModel.fetchAllReturnForm();
// // //     attendanceViewModel.fetchAllAttendance();
// // //     attendanceOutViewModel.fetchAllAttendanceOut();
// // //
// // //     // ✅ Start foreground service here
// // //     FlutterForegroundTask.startService(
// // //       notificationTitle: 'Clock Running',
// // //       notificationText: 'Tracking time and location...',
// // //       callback: startCallback,
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _animationController?.dispose();
// // //     _onBoardingAnimController?.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   void processGPXData() {
// // //     LocationViewModel locationVM = Get.find<LocationViewModel>();
// // //     locationVM.processGPXAndStoreCentralPoint();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // ✅ ABDULLAH: Home screen par working status false karein
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       final travelTimeViewModel = Get.find<TravelTimeViewModel>();
// // //       travelTimeViewModel.setWorkingScreenStatus(false);
// // //       debugPrint("📍 [WORKING STATUS] Home Screen - Working time INACTIVE");
// // //     });
// // //
// // //     return WillPopScope(
// // //       onWillPop: () async => false,
// // //       child: SafeArea(
// // //         child: Scaffold(
// // //           backgroundColor: Colors.grey.shade50,
// // //           body: SingleChildScrollView(
// // //             child: Column(
// // //               children: [
// // //                 _buildHeader(),
// // //                 const SizedBox(height: 10),
// // //
// // //                 // Timer Card Section
// // //                 Padding(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 20),
// // //                   child: TimerCard(),
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //
// // //                 // Quick Actions Section
// // //                 _buildActionButtons(MediaQuery.of(context).size.width),
// // //                 const SizedBox(height: 15),
// // //
// // //                 // Overview Section
// // //                 _buildOverviewSection(),
// // //                 const SizedBox(height: 15),
// // //
// // //                 // Footer
// // //                 Padding(
// // //                   padding: const EdgeInsets.only(bottom: 20),
// // //                   child: Column(
// // //                     children: [
// // //                       Divider(
// // //                         color: Colors.grey.shade300,
// // //                         height: 1,
// // //                         indent: 40,
// // //                         endIndent: 40,
// // //                       ),
// // //                       const SizedBox(height: 15),
// // //                       const Text(
// // //                         '• Version v0.1.2',
// // //                         style: TextStyle(
// // //                           color: Colors.grey,
// // //                           fontSize: 13,
// // //                           fontWeight: FontWeight.w500,
// // //                           letterSpacing: 0.5,
// // //                           fontStyle: FontStyle.italic,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       Text(
// // //                         '© 2026 BookIT (Sales Management)',
// // //                         style: TextStyle(
// // //                           color: Colors.grey.shade400,
// // //                           fontSize: 11,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildHeader() {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topCenter,
// // //           end: Alignment.bottomCenter,
// // //           colors: [
// // //             Colors.blue.shade800,
// // //             Colors.blue.shade600,
// // //           ],
// // //         ),
// // //         borderRadius: const BorderRadius.only(
// // //           bottomLeft: Radius.circular(25),
// // //           bottomRight: Radius.circular(25),
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.blue.shade800.withOpacity(0.3),
// // //             spreadRadius: 2,
// // //             blurRadius: 15,
// // //             offset: const Offset(0, 5),
// // //           ),
// // //         ],
// // //       ),
// // //       child: SafeArea(
// // //         bottom: false,
// // //         child: Column(
// // //           children: [
// // //             Navbar(),
// // //             const SizedBox(height: 10),
// // //             const ProfileSection(),
// // //             const SizedBox(height: 20),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildActionButtons(double screenWidth) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 20),
// // //       child: Column(
// // //         children: [
// // //           // Section Title
// // //           const Padding(
// // //             padding: EdgeInsets.symmetric(vertical: 10),
// // //             child: Row(
// // //               children: [
// // //                 Icon(
// // //                   Icons.dashboard_outlined,
// // //                   color: Colors.blue,
// // //                   size: 22,
// // //                 ),
// // //                 SizedBox(width: 8),
// // //                 Text(
// // //                   "Quick Actions",
// // //                   style: TextStyle(
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Colors.blue,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           // First Row - 3 buttons
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               _buildModernActionBox(
// // //                 icon: Icons.add_business_outlined, // More specific for "Add Shop"
// // //                 label: 'Add Shop',
// // //                 color: Colors.blue,
// // //                 onTap: () async {
// // //                   final locationVM = Get.find<LocationViewModel>();
// // //                   if (locationVM.isClockedIn.value) {
// // //                     Get.to(() => AddShopScreen());
// // //                   } else {
// // //                     _showClockInRequiredDialog();
// // //                   }
// // //                 },
// // //               ),
// // //               _buildModernActionBox(
// // //                 icon: Icons.storefront_outlined, // Better for shop visit/entry
// // //                 label: 'Shop Visit',
// // //                 color: Colors.green,
// // //                 onTap: () async {
// // //                   final locationVM = Get.find<LocationViewModel>();
// // //                   if (locationVM.isClockedIn.value) {
// // //                     Get.to(() => const ShopVisitScreen());
// // //                   } else {
// // //                     _showClockInRequiredDialog();
// // //                   }
// // //                 },
// // //               ),
// // //               _buildModernActionBox(
// // //                 icon: Icons.keyboard_return_outlined, // More clear for returns
// // //                 label: 'Return Form',
// // //                 color: Colors.orange,
// // //                 onTap: () async {
// // //                   final locationVM = Get.find<LocationViewModel>();
// // //                   if (locationVM.isClockedIn.value) {
// // //                     await orderMasterViewModel.fetchAllOrderMaster();
// // //                     await orderDetailsViewModel.fetchAllReConfirmOrder();
// // //                     Get.to(() => ReturnFormScreen());
// // //                   } else {
// // //                     _showClockInRequiredDialog();
// // //                   }
// // //                 },
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 2),
// // //
// // // // Second Row - 3 buttons
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               _buildModernActionBox(
// // //                 icon: Icons.request_quote_outlined, // More professional for recovery/payments
// // //                 label: 'Recovery',
// // //                 color: Colors.purple,
// // //                 onTap: () async {
// // //                   final locationVM = Get.find<LocationViewModel>();
// // //                   if (locationVM.isClockedIn.value) {
// // //                     await orderMasterViewModel.fetchAllOrderMaster();
// // //                     await recoveryFormViewModel.initializeData();
// // //                     Get.to(() => RecoveryFormScreen());
// // //                   } else {
// // //                     _showClockInRequiredDialog();
// // //                   }
// // //                 },
// // //               ),
// // //               _buildModernActionBox(
// // //                 icon: Icons.inventory_outlined, // Better for order/booking status
// // //                 label: 'Booking Status',
// // //                 color: Colors.teal,
// // //                 onTap: () async {
// // //                   await orderMasterViewModel.fetchAllOrderMaster();
// // //                   Get.to(() => OrderBookingStatusScreen());
// // //                 },
// // //               ),
// // //               _buildModernActionBox(
// // //                 icon: Icons.leave_bags_at_home_outlined, // More specific for leave/absence
// // //                 label: 'Leave',
// // //                 color: Colors.red,
// // //                 onTap: () {
// // //                   Get.to(() => LeaveFormScreen());
// // //                 },
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildModernActionBox({
// // //     required IconData icon,
// // //     required String label,
// // //     required Color color,
// // //     required VoidCallback onTap,
// // //   }) {
// // //     return Expanded(
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // //         child: Card(
// // //           elevation: 2,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(12),
// // //           ),
// // //           child: InkWell(
// // //             onTap: onTap,
// // //             borderRadius: BorderRadius.circular(12),
// // //             child: Container(
// // //               constraints: const BoxConstraints(
// // //                 minHeight: 100,
// // //                 maxHeight: 110,
// // //               ),
// // //               padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 gradient: LinearGradient(
// // //                   begin: Alignment.topLeft,
// // //                   end: Alignment.bottomRight,
// // //                   colors: [
// // //                     color.withOpacity(0.08),
// // //                     color.withOpacity(0.03),
// // //                   ],
// // //                 ),
// // //               ),
// // //               child: Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   Container(
// // //                     padding: const EdgeInsets.all(10),
// // //                     decoration: BoxDecoration(
// // //                       color: color.withOpacity(0.12),
// // //                       shape: BoxShape.circle,
// // //                     ),
// // //                     child: Icon(
// // //                       icon,
// // //                       color: color,
// // //                       size: 22,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 8),
// // //                   Padding(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 4),
// // //                     child: Text(
// // //                       label,
// // //                       textAlign: TextAlign.center,
// // //                       maxLines: 2,
// // //                       overflow: TextOverflow.ellipsis,
// // //                       style: TextStyle(
// // //                         fontSize: 12,
// // //                         fontWeight: FontWeight.w600,
// // //                         color: Colors.grey.shade800,
// // //                         height: 1.2,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildOverviewSection() {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // Section Header
// // //           const Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Row(
// // //                 children: [
// // //                   Icon(
// // //                     Icons.analytics_outlined,
// // //                     color: Colors.blue,
// // //                     size: 22,
// // //                   ),
// // //                   SizedBox(width: 6),
// // //                   Text(
// // //                     "Performance Overview",
// // //                     style: TextStyle(
// // //                       fontSize: 18,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Colors.blue,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 10),
// // //
// // //           Obx(() {
// // //             final totalShops = addShopViewModel.allAddShop.length;
// // //             final totalShopsVisits = shopVisitViewModel.apiShopVisitsCount.value;
// // //             final totalOrders = orderMasterViewModel.allOrderMaster.length;
// // //             final totalDispatchedOrders = orderMasterViewModel.apiDispatchedCount.value;
// // //             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// // //             final totalReturn = returnFormViewModel.allReturnForm.length;
// // //             final totalAttendanceIn = attendanceViewModel.allAttendance.length;
// // //
// // //             return Container(
// // //               padding: const EdgeInsets.all(10),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(14),
// // //                 boxShadow: [
// // //                   BoxShadow(
// // //                     color: Colors.grey.shade200,
// // //                     blurRadius: 6,
// // //                     spreadRadius: 1,
// // //                     offset: const Offset(0, 2),
// // //                   ),
// // //                 ],
// // //                 border: Border.all(
// // //                   color: Colors.grey.shade100,
// // //                   width: 1,
// // //                 ),
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   // First Row - 4 Stats
// // //                   Row(
// // //                     children: [
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.store_outlined,
// // //                           label: "Shops",
// // //                           value: totalShops.toString(),
// // //                           color: Colors.blue,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.store_mall_directory_outlined,
// // //                           label: "Visits",
// // //                           value: totalShopsVisits.toString(),
// // //                           color: Colors.green,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.shopping_cart_outlined,
// // //                           label: "Orders",
// // //                           value: totalOrders.toString(),
// // //                           color: Colors.orange,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.book_online_outlined,
// // //                           label: "Bookings",
// // //
// // //                           color: Colors.teal,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   const SizedBox(height: 8),
// // //
// // //                   // Second Row - 4 Stats
// // //                   Row(
// // //                     children: [
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.local_shipping_outlined,
// // //                           label: "Dispatched",
// // //                           value: totalDispatchedOrders.toString(),
// // //                           color: Colors.indigo,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.assignment_return_outlined,
// // //                           label: "Returns",
// // //                           value: totalReturn.toString(),
// // //                           color: Colors.red,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.attach_money_outlined,
// // //                           label: "Recovery",
// // //                           value: totalRecovery.toString(),
// // //                           color: Colors.purple,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         child: _buildTinyStatCard(
// // //                           icon: Icons.punch_clock_outlined,
// // //                           label: "Attendance",
// // //                           value: totalAttendanceIn.toString(),
// // //                           color: Colors.blueAccent,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             );
// // //           }),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildTinyStatCard({
// // //     required IconData icon,
// // //     required String label,
// // //     required String value,
// // //     required Color color,
// // //   }) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
// // //       decoration: BoxDecoration(
// // //         color: color.withOpacity(0.04),
// // //         borderRadius: BorderRadius.circular(10),
// // //         border: Border.all(
// // //           color: color.withOpacity(0.1),
// // //           width: 0.5,
// // //         ),
// // //       ),
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Container(
// // //             width: 30,
// // //             height: 30,
// // //             decoration: BoxDecoration(
// // //               color: color.withOpacity(0.1),
// // //               borderRadius: BorderRadius.circular(8),
// // //             ),
// // //             child: Icon(
// // //               icon,
// // //               color: color,
// // //               size: 16,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 4),
// // //           Text(
// // //             value,
// // //             style: TextStyle(
// // //               fontSize: 14,
// // //               fontWeight: FontWeight.bold,
// // //               color: color,
// // //             ),
// // //           ),
// // //           Text(
// // //             label,
// // //             textAlign: TextAlign.center,
// // //             style: TextStyle(
// // //               fontSize: 10,
// // //               fontWeight: FontWeight.w500,
// // //               color: Colors.grey.shade700,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildOverviewRow({
// // //     required IconData icon,
// // //     required String label,
// // //     required String value,
// // //     required Color color,
// // //     bool isFirst = false,
// // //     bool isLast = false,
// // //   }) {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         border: isLast
// // //             ? null
// // //             : Border(
// // //           bottom: BorderSide(
// // //             color: Colors.grey.shade200,
// // //             width: 1.5,
// // //           ),
// // //         ),
// // //       ),
// // //       child: Padding(
// // //         padding: EdgeInsets.only(
// // //           top: isFirst ? 0 : 15,
// // //           bottom: isLast ? 0 : 15,
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             // Icon Container
// // //             Container(
// // //               width: 50,
// // //               height: 50,
// // //               decoration: BoxDecoration(
// // //                 color: color.withOpacity(0.1),
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 border: Border.all(
// // //                   color: color.withOpacity(0.3),
// // //                   width: 1.5,
// // //                 ),
// // //               ),
// // //               child: Icon(
// // //                 icon,
// // //                 color: color,
// // //                 size: 26,
// // //               ),
// // //             ),
// // //             const SizedBox(width: 15),
// // //
// // //             // Label and Value
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     label,
// // //                     style: TextStyle(
// // //                       fontSize: 16,
// // //                       fontWeight: FontWeight.w600,
// // //                       color: Colors.grey.shade800,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 4),
// // //                   Text(
// // //                     "Today's count",
// // //                     style: TextStyle(
// // //                       fontSize: 12,
// // //                       color: Colors.grey.shade500,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             // Value with badge
// // //             Container(
// // //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //               decoration: BoxDecoration(
// // //                 color: color.withOpacity(0.1),
// // //                 borderRadius: BorderRadius.circular(20),
// // //                 border: Border.all(
// // //                   color: color.withOpacity(0.3),
// // //                   width: 1,
// // //                 ),
// // //               ),
// // //               child: Text(
// // //                 value,
// // //                 style: TextStyle(
// // //                   fontSize: 18,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: color,
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _showClockInRequiredDialog() {
// // //     Get.defaultDialog(
// // //       title: "⏰ Clock In Required",
// // //       titleStyle: const TextStyle(
// // //         fontWeight: FontWeight.bold,
// // //         color: Colors.blue,
// // //       ),
// // //       middleText: "Please start the timer first to access this feature.",
// // //       middleTextStyle: const TextStyle(color: Colors.grey),
// // //       textConfirm: "OK",
// // //       confirmTextColor: Colors.white,
// // //       buttonColor: Colors.blue,
// // //       onConfirm: () {
// // //         Get.back();
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // // ✅ required for foreground service
// // // void startCallback() {
// // //   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// // // }
// // //
// // // class MyTaskHandler extends TaskHandler {
// // //   @override
// // //   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
// // //     // Start your timer or location logic here
// // //   }
// // //
// // //   @override
// // //   Future<void> onRepeatEvent(DateTime timestamp) async {
// // //     // Called periodically (if you set repeat interval)
// // //   }
// // //
// // //   @override
// // //   Future<void> onDestroy(DateTime timestamp, bool restart) async {
// // //     // Clean up resources here
// // //   }
// // // }
// //
// // import 'package:auto_route/annotations.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// // import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// // import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// // import 'package:order_booking_app/screens/add_shop_screen.dart';
// // import 'package:order_booking_app/screens/return_form_screen.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// //
// // import '../GPX/screen.dart';
// // import '../LocatioPoints/ravelTimeViewModel.dart';
// // import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// // import '../ViewModels/add_shop_view_model.dart';
// // import '../ViewModels/location_view_model.dart';
// // import '../ViewModels/order_details_view_model.dart';
// // import '../ViewModels/return_form_view_model.dart';
// // import '../ViewModels/shop_visit_details_view_model.dart';
// // import 'HomeScreenComponents/navbar.dart';
// // import 'HomeScreenComponents/profile_section.dart';
// // import 'HomeScreenComponents/timer_card.dart';
// // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// // import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// // import 'leave_form_screen.dart';
// // import 'order_booking_status_screen.dart';
// // import 'package:lucide_icons/lucide_icons.dart';
// //
// // // ────────────────────────────────────────────────
// // //   Professional / Minimal Home Screen (2026 style)
// // // ────────────────────────────────────────────────
// //
// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});
// //
// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
// // }
// //
// // class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
// //   // ViewModels (unchanged)
// //   late final addShopViewModel = Get.put(AddShopViewModel());
// //   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
// //   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
// //   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
// //   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
// //   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
// //   late final returnFormViewModel = Get.put(ReturnFormViewModel());
// //   late final attendanceViewModel = Get.put(AttendanceViewModel());
// //   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// //   late final signUpController = Get.put(SignUpController());
// //   final LocationViewModel locationVM = Get.find<LocationViewModel>();
// //
// //   String user_id = '';
// //   String userName = '';
// //   // ... other user fields ...
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _retrieveSavedValues();
// //
// //     // Fetch data
// //     addShopViewModel.fetchAllAddShop();
// //     shopVisitViewModel.fetchAllShopVisit();
// //     shopVisitViewModel.fetchTotalShopVisit();
// //     shopVisitDetailsViewModel.initializeProductData();
// //     orderMasterViewModel.fetchAllOrderMaster();
// //     orderMasterViewModel.fetchTotalDispatched();
// //     recoveryFormViewModel.fetchAllRecoveryForm();
// //     returnFormViewModel.fetchAllReturnForm();
// //     attendanceViewModel.fetchAllAttendance();
// //     attendanceOutViewModel.fetchAllAttendanceOut();
// //
// //     // Foreground service
// //     FlutterForegroundTask.startService(
// //       notificationTitle: 'Clock Running',
// //       notificationText: 'Tracking time and location...',
// //       callback: startCallback,
// //     );
// //   }
// //
// //   Future<void> _retrieveSavedValues() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.reload();
// //
// //     setState(() {
// //       user_id = prefs.getString('userId') ?? '';
// //       userName = prefs.getString('userName') ?? '';
// //       // ... other fields ...
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Set working status false on home screen
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final travelTimeVM = Get.find<TravelTimeViewModel>();
// //       travelTimeVM.setWorkingScreenStatus(false);
// //     });
// //
// //     return WillPopScope(
// //       onWillPop: () async => false,
// //       child: SafeArea(
// //         child: Scaffold(
// //           backgroundColor: const Color(0xFFFAFAFC), // very light cool gray
// //           body: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 _buildHeader(),
// //                 const SizedBox(height: 10),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 20),
// //                   child: TimerCard(),
// //                 ),
// //                 const SizedBox(height: 15),
// //                 _buildQuickActions(),
// //                 const SizedBox(height: 15),
// //                 _buildPerformanceOverview(),
// //                 const SizedBox(height: 20),
// //                 _buildFooter(),
// //                 const SizedBox(height: 24),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeader() {
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [
// //             Colors.white,
// //             Colors.blueGrey.shade500,
// //           ],
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //         ),
// //         borderRadius: const BorderRadius.only(
// //           bottomLeft: Radius.circular(30),
// //           bottomRight: Radius.circular(30),
// //         ),
// //       ),
// //       child: Stack(
// //         children: [
// //           // --- BACKGROUND DESIGN ---
// //           // Large abstract shape at the top
// //           Positioned(
// //             top: -100,
// //             right: -50,
// //             child: Transform.rotate(
// //               angle: -0.2, // Tilts the shape for that "pointed" look
// //               child: Container(
// //                 width: 300,
// //                 height: 300,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(80),
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       Colors.blueGrey.withOpacity(0.4),
// //                       Colors.blueGrey.withOpacity(0.1),
// //                     ],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           //
// //           // // Secondary accent circle
// //           // Positioned(
// //           //   top: 50,
// //           //   left: -30,
// //           //   child: Container(
// //           //     width: 100,
// //           //     height: 180,
// //           //     decoration: BoxDecoration(
// //           //       shape: BoxShape.circle,
// //           //       color: Colors.white.withOpacity(0.50),
// //           //     ),
// //           //   ),
// //           // ),
// //
// //           // Your existing content
// //           Column(
// //             children: [
// //               Navbar(),
// //               const SizedBox(height: 20),
// //               const ProfileSection(),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Widget _buildQuickActions() {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 20),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         const Text(
// //   //           "Quick Actions",
// //   //           style: TextStyle(
// //   //             fontSize: 17,
// //   //             fontWeight: FontWeight.w600,
// //   //             color: Color(0xFF1F2937),
// //   //           ),
// //   //         ),
// //   //         const SizedBox(height: 16),
// //   //         Row(
// //   //           children: [
// //   //             _actionTile(
// //   //               icon: Icons.add_business_outlined,
// //   //               label: 'Add Shop',
// //   //               onTap: () {
// //   //                 if (locationVM.isClockedIn.value) {
// //   //                   Get.to(() => AddShopScreen());
// //   //                 } else {
// //   //                   _showClockInRequiredDialog();
// //   //                 }
// //   //               },
// //   //             ),
// //   //             const SizedBox(width: 12),
// //   //             _actionTile(
// //   //               icon: Icons.storefront_outlined,
// //   //               label: 'Shop Visit',
// //   //               onTap: () {
// //   //                 if (locationVM.isClockedIn.value) {
// //   //                   Get.to(() => const ShopVisitScreen());
// //   //                 } else {
// //   //                   _showClockInRequiredDialog();
// //   //                 }
// //   //               },
// //   //             ),
// //   //             const SizedBox(width: 12),
// //   //             _actionTile(
// //   //               icon: Icons.keyboard_return_outlined,
// //   //               label: 'Return',
// //   //               onTap: () async {
// //   //                 if (locationVM.isClockedIn.value) {
// //   //                   await orderMasterViewModel.fetchAllOrderMaster();
// //   //                   await orderDetailsViewModel.fetchAllReConfirmOrder();
// //   //                   Get.to(() => ReturnFormScreen());
// //   //                 } else {
// //   //                   _showClockInRequiredDialog();
// //   //                 }
// //   //               },
// //   //             ),
// //   //           ],
// //   //         ),
// //   //         const SizedBox(height: 12),
// //   //         Row(
// //   //           children: [
// //   //             _actionTile(
// //   //               icon: Icons.request_quote_outlined,
// //   //               label: 'Recovery',
// //   //               onTap: () async {
// //   //                 if (locationVM.isClockedIn.value) {
// //   //                   await orderMasterViewModel.fetchAllOrderMaster();
// //   //                   await recoveryFormViewModel.initializeData();
// //   //                   Get.to(() => RecoveryFormScreen());
// //   //                 } else {
// //   //                   _showClockInRequiredDialog();
// //   //                 }
// //   //               },
// //   //             ),
// //   //             const SizedBox(width: 12),
// //   //             _actionTile(
// //   //               icon: Icons.inventory_outlined,
// //   //               label: 'Booking Status',
// //   //               onTap: () async {
// //   //                 await orderMasterViewModel.fetchAllOrderMaster();
// //   //                 Get.to(() => OrderBookingStatusScreen());
// //   //               },
// //   //             ),
// //   //             const SizedBox(width: 12),
// //   //             _actionTile(
// //   //               icon: Icons.leave_bags_at_home_outlined,
// //   //               label: 'Leave',
// //   //               onTap: () => Get.to(() => LeaveFormScreen()),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //   //
// //   // Widget _actionTile({
// //   //   required IconData icon,
// //   //   required String label,
// //   //   required VoidCallback onTap,
// //   // }) {
// //   //   return Expanded(
// //   //     child: Material(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(12),
// //   //       elevation: 0,
// //   //       clipBehavior: Clip.hardEdge,
// //   //       child: InkWell(
// //   //         onTap: onTap,
// //   //         child: Container(
// //   //           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
// //   //           decoration: BoxDecoration(
// //   //             border: Border.all(color: const Color(0xFFE5E7EB)),
// //   //             borderRadius: BorderRadius.circular(12),
// //   //           ),
// //   //           child: Column(
// //   //             mainAxisSize: MainAxisSize.min,
// //   //             children: [
// //   //               Icon(icon, size: 26, color: const Color(0xFF3B82F6)),
// //   //               const SizedBox(height: 10),
// //   //               Text(
// //   //                 label,
// //   //                 textAlign: TextAlign.center,
// //   //                 maxLines: 2,
// //   //                 overflow: TextOverflow.ellipsis,
// //   //                 style: const TextStyle(
// //   //                   fontSize: 13,
// //   //                   fontWeight: FontWeight.w500,
// //   //                   color: Color(0xFF374151),
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       ),
// //   //     ),
// //   //   );
// //   // }
// //      Widget _buildQuickActions() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             "Quick Actions",
// //             style: TextStyle(
// //               fontSize: 17,
// //               fontWeight: FontWeight.w600,
// //               color: Color(0xFF1F2937),
// //             ),
// //           ),
// //           SizedBox(height: 10),
// //           Row(
// //             children: [
// //               _actionTile(
// //                 icon: LucideIcons.store,
// //                 label: 'Add Shop',
// //                 onTap: () {
// //                   if (locationVM.isClockedIn.value) {
// //                     Get.to(() => AddShopScreen());
// //                   } else {
// //                     _showClockInRequiredDialog();
// //                   }
// //                 },
// //               ),
// //               SizedBox(width: 12),
// //               _actionTile(
// //                 icon: LucideIcons.building,
// //                 label: 'Shop Visit',
// //                 onTap: () {
// //                   if (locationVM.isClockedIn.value) {
// //                     Get.to(() => const ShopVisitScreen());
// //                   } else {
// //                     _showClockInRequiredDialog();
// //                   }
// //                 },
// //               ),
// //               SizedBox(width: 12),
// //               _actionTile(
// //                 icon: LucideIcons.refreshCcw,
// //                 label: 'Return',
// //                 onTap: () async {
// //                   if (locationVM.isClockedIn.value) {
// //                     await orderMasterViewModel.fetchAllOrderMaster();
// //                     await orderDetailsViewModel.fetchAllReConfirmOrder();
// //                     Get.to(() => ReturnFormScreen());
// //                   } else {
// //                     _showClockInRequiredDialog();
// //                   }
// //                 },
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 10),
// //           Row(
// //             children: [
// //               _actionTile(
// //                 icon: LucideIcons.wallet,
// //                 label: 'Recovery',
// //                 onTap: () async {
// //                   if (locationVM.isClockedIn.value) {
// //                     await orderMasterViewModel.fetchAllOrderMaster();
// //                     await recoveryFormViewModel.initializeData();
// //                     Get.to(() => RecoveryFormScreen());
// //                   } else {
// //                     _showClockInRequiredDialog();
// //                   }
// //                 },
// //               ),
// //               SizedBox(width: 12),
// //               _actionTile(
// //                 icon: LucideIcons.clipboardCheck,
// //                 label: 'Booking Status',
// //                 onTap: () async {
// //                   await orderMasterViewModel.fetchAllOrderMaster();
// //                   Get.to(() => OrderBookingStatusScreen());
// //                 },
// //               ),
// //               SizedBox(width: 12),
// //               _actionTile(
// //                 icon: LucideIcons.calendarDays,
// //                 label: 'Leave',
// //                 onTap: () => Get.to(() => LeaveFormScreen()),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// // // Updated _actionTile widget with modern styling
// //   Widget _actionTile({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //   }) {
// //     return Expanded(
// //       child: GestureDetector(
// //         onTap: onTap,
// //         child: Container(
// //           height: 100,
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.blueAccent.withOpacity(0.2),
// //                 blurRadius: 10,
// //                 offset: Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Container(
// //                 width: 48,
// //                 height: 48,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: Colors.blueAccent,
// //                 ),
// //                 child: Icon(
// //                   icon,
// //                   size: 24,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               SizedBox(height: 8),
// //               Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w500,
// //                   color: Color(0xFF374151),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //
// //
// //   // Widget _buildPerformanceOverview() {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 20),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         const Text(
// //   //           "Today's Summary",
// //   //           style: TextStyle(
// //   //             fontSize: 17,
// //   //             fontWeight: FontWeight.w600,
// //   //             color: Color(0xFF1F2937),
// //   //           ),
// //   //         ),
// //   //         const SizedBox(height: 10),
// //   //         Obx(() {
// //   //           final totalShops = addShopViewModel.allAddShop.length;
// //   //           final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
// //   //           final totalOrders = orderMasterViewModel.allOrderMaster.length;
// //   //           final dispatched = orderMasterViewModel.apiDispatchedCount.value;
// //   //           final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// //   //           final totalReturns = returnFormViewModel.allReturnForm.length;
// //   //           final attendanceIn = attendanceViewModel.allAttendance.length;
// //   //
// //   //           return Container(
// //   //             decoration: BoxDecoration(
// //   //               color: Colors.white,
// //   //               borderRadius: BorderRadius.circular(12),
// //   //               border: Border.all(color: const Color(0xFFE5E7EB)),
// //   //               boxShadow: [
// //   //                 BoxShadow(
// //   //                   color: Colors.blueAccent.withOpacity(0.06),     // very subtle
// //   //                   blurRadius: 10,
// //   //                   offset: const Offset(0, 4),                // slight downward lift
// //   //                   spreadRadius: 0,
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //             child: Column(
// //   //               children: [
// //   //                 _statRow("Shops", totalShops, Icons.store_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Visits", totalVisits, Icons.directions_walk_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Orders", totalOrders, Icons.shopping_cart_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Dispatched", dispatched, Icons.local_shipping_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Returns", totalReturns, Icons.assignment_return_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Recovery", totalRecovery, Icons.attach_money_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Attendance", attendanceIn, Icons.punch_clock_outlined),
// //   //                 const Divider(height: 1, color: Color(0xFFE5E7EB)),
// //   //                 _statRow("Bookings", attendanceIn, Icons.book),
// //   //               ],
// //   //             ),
// //   //           );
// //   //         }),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //   // Widget _buildPerformanceOverview() {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 20),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         const Text(
// //   //           "Today's Summary",
// //   //           style: TextStyle(
// //   //             fontSize: 17,
// //   //             fontWeight: FontWeight.w600,
// //   //             color: Color(0xFF1F2937),
// //   //           ),
// //   //         ),
// //   //         const SizedBox(height: 10),
// //   //
// //   //         Obx(() {
// //   //           final totalShops = addShopViewModel.allAddShop.length;
// //   //           final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
// //   //           final totalOrders = orderMasterViewModel.allOrderMaster.length;
// //   //           final dispatched = orderMasterViewModel.apiDispatchedCount.value;
// //   //           final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// //   //           final totalReturns = returnFormViewModel.allReturnForm.length;
// //   //           final attendanceIn = attendanceViewModel.allAttendance.length;
// //   //
// //   //           return Container(
// //   //               height: 220,
// //   //             padding: const EdgeInsets.all(14),
// //   //             decoration: BoxDecoration(
// //   //               color: Colors.white,
// //   //               borderRadius: BorderRadius.circular(12),
// //   //               border: Border.all(color: const Color(0xFFE5E7EB)),
// //   //               boxShadow: [
// //   //                 BoxShadow(
// //   //                   color: Colors.blueAccent.withOpacity(0.06),
// //   //                   blurRadius: 10,
// //   //                   offset: const Offset(0, 4),
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //             child: GridView(
// //   //               shrinkWrap: true,
// //   //               physics: const NeverScrollableScrollPhysics(),
// //   //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //   //                 crossAxisCount: 4,      // 4 items per row
// //   //                 crossAxisSpacing: 2,
// //   //                 mainAxisSpacing: 30,
// //   //                 childAspectRatio: 1.25,
// //   //               ),
// //   //               children: [
// //   //                 _statGridItem("Shops", totalShops, Icons.store_outlined),
// //   //                 _statGridItem("Visits", totalVisits, Icons.directions_walk_outlined),
// //   //                 _statGridItem("Orders", totalOrders, Icons.shopping_cart_outlined),
// //   //                 _statGridItem("Dispatched", dispatched, Icons.local_shipping_outlined),
// //   //
// //   //                 _statGridItem("Returns", totalReturns, Icons.assignment_return_outlined),
// //   //                 _statGridItem("Recovery", totalRecovery, Icons.attach_money_outlined),
// //   //                 _statGridItem("Attendance", attendanceIn, Icons.punch_clock_outlined),
// //   //                 _statGridItem("Bookings", attendanceIn, Icons.book),
// //   //               ],
// //   //             ),
// //   //           );
// //   //         }),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //
// //
// //   // Widget _statRow(String label, int value, IconData icon) {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
// //   //     child: Row(
// //   //       children: [
// //   //         Icon(icon, size: 20, color: const Color(0xFF6B7280)),
// //   //         const SizedBox(width: 16),
// //   //         Expanded(
// //   //           child: Text(
// //   //             label,
// //   //             style: const TextStyle(
// //   //               fontSize: 15,
// //   //               color: Color(0xFF374151),
// //   //             ),
// //   //           ),
// //   //         ),
// //   //         Text(
// //   //           "$value",
// //   //           style: const TextStyle(
// //   //             fontSize: 16,
// //   //             fontWeight: FontWeight.w600,
// //   //             color: Color(0xFF1F2937),
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   // Widget _statGridItem(String label, int value, IconData icon) {
// //   //   return Container(
// //   //     decoration: BoxDecoration(
// //   //       color: const Color(0xFFF9FAFB),
// //   //       borderRadius: BorderRadius.circular(10),
// //   //       border: Border.all(color: const Color(0xFFE5E7EB)),
// //   //     ),
// //   //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
// //   //     child: Column(
// //   //       mainAxisAlignment: MainAxisAlignment.center,
// //   //       children: [
// //   //         Icon(icon, size: 20, color: Colors.blueAccent),
// //   //         const SizedBox(height: 6),
// //   //         Text(
// //   //           value.toString(),
// //   //           style: const TextStyle(
// //   //             fontSize: 16,
// //   //             fontWeight: FontWeight.w700,
// //   //             color: Color(0xFF111827),
// //   //           ),
// //   //         ),
// //   //         const SizedBox(height: 2),
// //   //         Text(
// //   //           label,
// //   //           textAlign: TextAlign.center,
// //   //           style: const TextStyle(
// //   //             fontSize: 11,
// //   //             color: Color(0xFF6B7280),
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   // Widget _statGridItem(String label, int value, IconData icon) {
// //   //   return Container(
// //   //     decoration: BoxDecoration(
// //   //       color: const Color(0xFFF9FAFB),
// //   //       borderRadius: BorderRadius.circular(10),
// //   //       border: Border.all(color: const Color(0xFFE5E7EB)),
// //   //     ),
// //   //     padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
// //   //     child: Column(
// //   //       mainAxisAlignment: MainAxisAlignment.center,
// //   //       children: [
// //   //         Stack(
// //   //           alignment: Alignment.center,
// //   //           children: [
// //   //             Container(
// //   //               height: 42,
// //   //               width: 42,
// //   //               decoration: BoxDecoration(
// //   //                 color: Colors.blueAccent.withOpacity(0.12),
// //   //                 shape: BoxShape.circle,
// //   //               ),
// //   //               child: Icon(
// //   //                 icon,
// //   //                 size: 22,
// //   //                 color: Colors.blueAccent,
// //   //               ),
// //   //             ),
// //   //
// //   //             // 🔢 Number inside icon
// //   //             Positioned(
// //   //               bottom: 2,
// //   //               right: 2,
// //   //               child: Container(
// //   //                 padding: const EdgeInsets.all(4),
// //   //                 decoration: const BoxDecoration(
// //   //                   color: Colors.blueAccent,
// //   //                   shape: BoxShape.circle,
// //   //                 ),
// //   //                 child: Text(
// //   //                   value.toString(),
// //   //                   style: const TextStyle(
// //   //                     fontSize: 10,
// //   //                     fontWeight: FontWeight.w700,
// //   //                     color: Colors.white,
// //   //                   ),
// //   //                 ),
// //   //               ),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //
// //   //         const SizedBox(height: 6),
// //   //
// //   //         Text(
// //   //           label,
// //   //           textAlign: TextAlign.center,
// //   //           style: const TextStyle(
// //   //             fontSize: 11,
// //   //             color: Color(0xFF6B7280),
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   Widget _buildPerformanceOverview() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "Today's Summary",
// //             style: TextStyle(
// //               fontSize: 17,
// //               fontWeight: FontWeight.w600,
// //               color: Color(0xFF1F2937),
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //
// //           Obx(() {
// //             final totalShops = addShopViewModel.allAddShop.length;
// //             final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
// //             final totalOrders = orderMasterViewModel.allOrderMaster.length;
// //             final dispatched = orderMasterViewModel.apiDispatchedCount.value;
// //             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// //             final totalReturns = returnFormViewModel.allReturnForm.length;
// //             final attendanceIn = attendanceViewModel.allAttendance.length;
// //
// //             return SizedBox( // Wrap with SizedBox to control height
// //               height: 180, // Reduced height
// //               child: Container(
// //                 padding: const EdgeInsets.all(14),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(color: const Color(0xFFE5E7EB)),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.blueAccent.withOpacity(0.06),
// //                       blurRadius: 10,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: GridView(
// //                   shrinkWrap: true,
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 4,
// //                     crossAxisSpacing: 2,
// //                     mainAxisSpacing: 8, // Reduced spacing
// //                     childAspectRatio: 1.0, // Adjusted aspect ratio
// //                   ),
// //                   children: [
// //                     _statGridItem("Shops", totalShops, Icons.store_outlined),
// //                     _statGridItem("Visits", totalVisits, Icons.directions_walk_outlined),
// //                     _statGridItem("Orders", totalOrders, Icons.shopping_cart_outlined),
// //                     _statGridItem("Dispatched", dispatched, Icons.local_shipping_outlined),
// //                     _statGridItem("Returns", totalReturns, Icons.assignment_return_outlined),
// //                     _statGridItem("Recovery", totalRecovery, Icons.attach_money_outlined),
// //                     _statGridItem("Attendance", attendanceIn, Icons.punch_clock_outlined),
// //                     _statGridItem("Bookings", attendanceIn, Icons.book),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //
// //   Widget _statGridItem(String label, int value, IconData icon) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFF9FAFB),
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: const Color(0xFFE5E7EB)),
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min, // Use min to fit content
// //         mainAxisAlignment: MainAxisAlignment.center, // Center everything
// //         children: [
// //           Stack(
// //             alignment: Alignment.center,
// //             children: [
// //               Container(
// //                 height: 34,
// //                 width: 34,
// //                 decoration: BoxDecoration(
// //                   color: Colors.blueAccent.withOpacity(0.12),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Icon(
// //                   icon,
// //                   size: 20, // Slightly smaller icon
// //                   color: Colors.blueAccent,
// //                 ),
// //               ),
// //
// //               Positioned(
// //                 bottom: 0,
// //                 right: 0,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(3),
// //                   decoration: const BoxDecoration(
// //                     color: Colors.blueAccent,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Text(
// //                     value.toString(),
// //                     style: const TextStyle(
// //                       fontSize: 8, // Smaller font
// //                       fontWeight: FontWeight.w700,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 4), // Reduced from 25
// //
// //           Flexible( // Use Flexible instead of FittedBox
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 2),
// //               child: Text(
// //                 label,
// //                 textAlign: TextAlign.center,
// //                 maxLines: 2, // Allow text to wrap if needed
// //                 overflow: TextOverflow.ellipsis,
// //                 style: const TextStyle(
// //                   fontSize: 10,
// //                   color: Color(0xFF6B7280),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //
// //   Widget _buildFooter() {
// //     return const Column(
// //       children: [
// //         // Divider(color: Color(0xFFE5E7EB), height: 1, indent: 40, endIndent: 40),
// //         // SizedBox(height: 20),
// //         Text(
// //           'Version 0.1.2',
// //           style: TextStyle(
// //             fontStyle: FontStyle.italic,
// //             fontSize: 13,
// //             color: Color(0xFF9CA3AF),
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         // SizedBox(height: 4),
// //         // Text(
// //         //   '© 2026 BookIT • Sales Management',
// //         //   style: TextStyle(
// //         //     fontSize: 12,
// //         //     color: Color(0xFFD1D5DB),
// //         //   ),
// //         // ),
// //       ],
// //     );
// //   }
// //
// //   void _showClockInRequiredDialog() {
// //     Get.defaultDialog(
// //       title: "Clock In Required",
// //       titleStyle: const TextStyle(fontWeight: FontWeight.w600),
// //       middleText: "Please start your work timer first.",
// //       middleTextStyle: const TextStyle(color: Color(0xFF6B7280)),
// //       textConfirm: "OK",
// //       confirmTextColor: Colors.white,
// //       buttonColor: const Color(0xFF3B82F6),
// //       radius: 12,
// //       onConfirm: Get.back,
// //     );
// //   }
// // }
// //
// // // Foreground task handler remains unchanged
// // void startCallback() {
// //   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// // }
// //
// // class MyTaskHandler extends TaskHandler {
// //   @override
// //   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}
// //   @override
// //   Future<void> onRepeatEvent(DateTime timestamp) async {}
// //   @override
// //   Future<void> onDestroy(DateTime timestamp, bool restart) async {}
// // }
//
// import 'package:auto_route/annotations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// import 'package:order_booking_app/screens/add_shop_screen.dart';
// import 'package:order_booking_app/screens/return_form_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
//
// import '../LocatioPoints/ravelTimeViewModel.dart';
// import '../Reports/order_detail_report/OrderReportScreen.dart';
// import '../Reports/shop_visit_report/shop_visit_report_screen.dart';
// import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// import '../ViewModels/add_shop_view_model.dart';
// import '../ViewModels/location_view_model.dart';
// import '../ViewModels/order_details_view_model.dart';
// import '../ViewModels/return_form_view_model.dart';
// import '../ViewModels/shop_visit_details_view_model.dart';
// import 'HomeScreenComponents/navbar.dart';
// import 'HomeScreenComponents/profile_section.dart';
// import 'HomeScreenComponents/timer_card.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// import 'leave_form_screen.dart';
// import 'order_booking_status_screen.dart';
// import 'package:lucide_icons/lucide_icons.dart';
//
// // ────────────────────────────────────────────────
// //   Professional / Minimal Home Screen (2026 style)
// // ────────────────────────────────────────────────
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   // ViewModels (unchanged)
//   late final addShopViewModel = Get.put(AddShopViewModel());
//   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
//   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
//   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
//   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
//   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
//   late final returnFormViewModel = Get.put(ReturnFormViewModel());
//   late final attendanceViewModel = Get.put(AttendanceViewModel());
//   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//   late final signUpController = Get.put(SignUpController());
//   final LocationViewModel locationVM = Get.find<LocationViewModel>();
//
//   String user_id = '';
//   String userName = '';
//
//   // ... other user fields ...
//
//   @override
//   void initState() {
//     super.initState();
//     _retrieveSavedValues();
//
//     // Fetch data
//     addShopViewModel.fetchAllAddShop();
//     shopVisitViewModel.fetchAllShopVisit();
//     shopVisitViewModel.fetchTotalShopVisit();
//     shopVisitDetailsViewModel.initializeProductData();
//     orderMasterViewModel.fetchAllOrderMaster();
//     orderMasterViewModel.fetchTotalDispatched();
//     recoveryFormViewModel.fetchAllRecoveryForm();
//     returnFormViewModel.fetchAllReturnForm();
//     attendanceViewModel.fetchAllAttendance();
//     attendanceOutViewModel.fetchAllAttendanceOut();
//
//     // Foreground service
//     FlutterForegroundTask.startService(
//       notificationTitle: 'Clock Running',
//       notificationText: 'Tracking time and location...',
//       callback: startCallback,
//     );
//   }
//
//   Future<void> _retrieveSavedValues() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     setState(() {
//       user_id = prefs.getString('userId') ?? '';
//       userName = prefs.getString('userName') ?? '';
//       // ... other fields ...
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Set working status false on home screen
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final travelTimeVM = Get.find<TravelTimeViewModel>();
//       travelTimeVM.setWorkingScreenStatus(false);
//     });
//
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.blueGrey.shade50, // Updated to match theme
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TimerCard(),
//                 ),
//                 const SizedBox(height: 15),
//                 _buildQuickActions(),
//                 const SizedBox(height: 15),
//                 _buildPerformanceOverview(),
//                 const SizedBox(height: 20),
//                 _buildFooter(),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white,
//             Colors.blueGrey.shade500,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Stack(
//         children: [
//           // --- BACKGROUND DESIGN ---
//           // Large abstract shape at the top
//           Positioned(
//             top: -100,
//             right: -50,
//             child: Transform.rotate(
//               angle: -0.2, // Tilts the shape for that "pointed" look
//               child: Container(
//                 width: 300,
//                 height: 300,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(80),
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.blueGrey.withOpacity(0.4),
//                       Colors.blueGrey.withOpacity(0.1),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Your existing content
//           Column(
//             children: [
//               Navbar(),
//               const SizedBox(height: 20),
//               const ProfileSection(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickActions() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Quick Actions",
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//               color: Colors.blueGrey.shade800, // Updated
//             ),
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               _actionTile(
//                 icon: LucideIcons.store,
//                 label: 'Add Shop',
//                 onTap: () {
//                   if (locationVM.isClockedIn.value) {
//                     Get.to(() => AddShopScreen());
//                   } else {
//                     _showClockInRequiredDialog();
//                   }
//                 },
//               ),
//               SizedBox(width: 12),
//               _actionTile(
//                 icon: LucideIcons.building,
//                 label: 'Shop Visit',
//                 onTap: () {
//                   if (locationVM.isClockedIn.value) {
//                     Get.to(() => const ShopVisitScreen());
//                   } else {
//                     _showClockInRequiredDialog();
//                   }
//                 },
//               ),
//               SizedBox(width: 12),
//               _actionTile(
//                 icon: LucideIcons.refreshCcw,
//                 label: 'Return',
//                 onTap: () async {
//                   if (locationVM.isClockedIn.value) {
//                     await orderMasterViewModel.fetchAllOrderMaster();
//                     await orderDetailsViewModel.fetchAllReConfirmOrder();
//                     Get.to(() => ReturnFormScreen());
//                   } else {
//                     _showClockInRequiredDialog();
//                   }
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               _actionTile(
//                 icon: LucideIcons.wallet,
//                 label: 'Recovery',
//                 onTap: () async {
//                   if (locationVM.isClockedIn.value) {
//                     await orderMasterViewModel.fetchAllOrderMaster();
//                     await recoveryFormViewModel.initializeData();
//                     Get.to(() => RecoveryFormScreen());
//                   } else {
//                     _showClockInRequiredDialog();
//                   }
//                 },
//               ),
//               SizedBox(width: 12),
//               _actionTile(
//                 icon: LucideIcons.clipboardCheck,
//                 label: 'Booking Status',
//                 onTap: () async {
//                   await orderMasterViewModel.fetchAllOrderMaster();
//                   Get.to(() => OrderBookingStatusScreen());
//                 },
//               ),
//               SizedBox(width: 12),
//               _actionTile(
//                 icon: LucideIcons.calendarDays,
//                 label: 'Leave',
//                 onTap: () => Get.to(() => LeaveFormScreen()),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
// // Updated _actionTile widget with modern styling
//   Widget _actionTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           height: 100,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blueGrey.withOpacity(0.2), // Updated
//                 blurRadius: 10,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.blueGrey, // Updated
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 24,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.blueGrey.shade800, // Updated
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPerformanceOverview() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Today's Summary",
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//               color: Colors.blueGrey.shade800, // Updated
//             ),
//           ),
//           const SizedBox(height: 10),
//           Obx(() {
//             final totalShops = addShopViewModel.allAddShop.length;
//             final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
//             final totalOrders = orderMasterViewModel.allOrderMaster.length;
//             final dispatched = orderMasterViewModel.apiDispatchedCount.value;
//             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
//             final totalReturns = returnFormViewModel.allReturnForm.length;
//             final attendanceIn = attendanceViewModel.allAttendance.length;
//
//             return SizedBox(
//               height: 180,
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blueGrey.shade200),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blueGrey.withOpacity(0.06),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: GridView(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 2,
//                     mainAxisSpacing: 8,
//                     childAspectRatio: 1.0,
//                   ),
//                   children: [
//                     _statGridItem("Shops", totalShops, Icons.store_outlined),
//                     // _statGridItem("Visits", totalVisits, Icons.directions_walk_outlined),
//                     _statGridItem(
//                       "Visits",
//                       totalVisits,
//                       Icons.directions_walk_outlined,
//                       onTap: () {
//                         Get.to(() => ShopVisitReportDashboard());
//                       },
//                     ),
//
//                     _statGridItem(
//                         "Orders", totalOrders, Icons.shopping_cart_outlined,
//                         onTap: () {
//                       Get.to(() => OrderReportScreen());
//                     }),
//                     _statGridItem("Dispatched", dispatched,
//                         Icons.local_shipping_outlined),
//                     _statGridItem("Returns", totalReturns,
//                         Icons.assignment_return_outlined),
//                     _statGridItem(
//                         "Recovery", totalRecovery, Icons.attach_money_outlined),
//                     _statGridItem(
//                         "Attendance", attendanceIn, Icons.punch_clock_outlined),
//                     _statGridItem("Bookings", attendanceIn, Icons.book),
//                   ],
//                 ),
//               ),
//             );
//           }),
//           // Obx(() {
//           //   final totalShops = addShopViewModel.allAddShop.length;
//           //   final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
//           //   final totalOrders = orderMasterViewModel.allOrderMaster.length;
//           //   final dispatched = orderMasterViewModel.apiDispatchedCount.value;
//           //   final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
//           //   final totalReturns = returnFormViewModel.allReturnForm.length;
//           //   final attendanceIn = attendanceViewModel.allAttendance.length;
//           //
//           //   return SizedBox( // Wrap with SizedBox to control height
//           //     height: 180, // Reduced height
//           //     child: Container(
//           //       padding: const EdgeInsets.all(14),
//           //       decoration: BoxDecoration(
//           //         color: Colors.white,
//           //         borderRadius: BorderRadius.circular(12),
//           //         border: Border.all(color: Colors.blueGrey.shade200), // Updated
//           //         boxShadow: [
//           //           BoxShadow(
//           //             color: Colors.blueGrey.withOpacity(0.06), // Updated
//           //             blurRadius: 10,
//           //             offset: const Offset(0, 4),
//           //           ),
//           //         ],
//           //       ),
//           //       child: GridView(
//           //         shrinkWrap: true,
//           //         physics: const NeverScrollableScrollPhysics(),
//           //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           //           crossAxisCount: 4,
//           //           crossAxisSpacing: 2,
//           //           mainAxisSpacing: 8, // Reduced spacing
//           //           childAspectRatio: 1.0, // Adjusted aspect ratio
//           //         ),
//           //         children: [
//           //           _statGridItem("Shops", totalShops, Icons.store_outlined),
//           //           _statGridItem("Visits", totalVisits, Icons.directions_walk_outlined),
//           //           _statGridItem("Orders", totalOrders, Icons.shopping_cart_outlined),
//           //           _statGridItem("Dispatched", dispatched, Icons.local_shipping_outlined),
//           //           _statGridItem("Returns", totalReturns, Icons.assignment_return_outlined),
//           //           _statGridItem("Recovery", totalRecovery, Icons.attach_money_outlined),
//           //           _statGridItem("Attendance", attendanceIn, Icons.punch_clock_outlined),
//           //           _statGridItem("Bookings", attendanceIn, Icons.book),
//           //         ],
//           //       ),
//           //     ),
//           //   );
//           // }),
//         ],
//       ),
//     );
//   }
//
//   // Widget _statGridItem(String label, int value, IconData icon) {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       color: Colors.blueGrey.shade50, // Updated
//   //       borderRadius: BorderRadius.circular(10),
//   //       border: Border.all(color: Colors.blueGrey.shade200), // Updated
//   //     ),
//   //     child: Column(
//   //       mainAxisSize: MainAxisSize.min, // Use min to fit content
//   //       mainAxisAlignment: MainAxisAlignment.center, // Center everything
//   //       children: [
//   //         Stack(
//   //           alignment: Alignment.center,
//   //           children: [
//   //             Container(
//   //               height: 34,
//   //               width: 34,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.blueGrey.withOpacity(0.12), // Updated
//   //                 shape: BoxShape.circle,
//   //               ),
//   //               child: Icon(
//   //                 icon,
//   //                 size: 20, // Slightly smaller icon
//   //                 color: Colors.blueGrey, // Updated
//   //               ),
//   //             ),
//   //
//   //             Positioned(
//   //               bottom: 0,
//   //               right: 0,
//   //               child: Container(
//   //                 padding: const EdgeInsets.all(3),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.blueGrey, // Updated
//   //                   shape: BoxShape.circle,
//   //                 ),
//   //                 child: Text(
//   //                   value.toString(),
//   //                   style: const TextStyle(
//   //                     fontSize: 8, // Smaller font)
//   //                     fontWeight: FontWeight.w700,
//   //                     color: Colors.white,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //
//   //         const SizedBox(height: 4), // Reduced from 25
//   //
//   //         Flexible( // Use Flexible instead of FittedBox
//   //           child: Padding(
//   //             padding: const EdgeInsets.symmetric(horizontal: 2),
//   //             child: Text(
//   //               label,
//   //               textAlign: TextAlign.center,
//   //               maxLines: 2, // Allow text to wrap if needed
//   //               overflow: TextOverflow.ellipsis,
//   //               style: TextStyle(
//   //                 fontSize: 10,
//   //                 color: Colors.blueGrey.shade700, // Updated
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _statGridItem(String label, int value, IconData icon,
//       {VoidCallback? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blueGrey.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.blueGrey.shade200),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   height: 34,
//                   width: 34,
//                   decoration: BoxDecoration(
//                     color: Colors.blueGrey.withOpacity(0.12),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 20,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(3),
//                     decoration: BoxDecoration(
//                       color: Colors.blueGrey,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       value.toString(),
//                       style: const TextStyle(
//                         fontSize: 8,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.blueGrey.shade800,
//                 fontWeight: FontWeight.w500,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFooter() {
//     return const Column(
//       children: [
//         Text(
//           'Version 0.1.2',
//           style: TextStyle(
//             fontStyle: FontStyle.italic,
//             fontSize: 13,
//             color: Colors.blueGrey, // Updated
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showClockInRequiredDialog() {
//     Get.defaultDialog(
//       title: "Clock In Required",
//       titleStyle:
//           const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
//       middleText: "Please start your work timer first.",
//       middleTextStyle: TextStyle(color: Colors.blueGrey.shade600),
//       textConfirm: "OK",
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.blueGrey,
//       // Updated
//       radius: 12,
//       onConfirm: Get.back,
//     );
//   }
// }
//
// // Foreground task handler remains unchanged
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }
//
// class MyTaskHandler extends TaskHandler {
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}
//
//   @override
//   Future<void> onRepeatEvent(DateTime timestamp) async {}
//
//   @override
//   Future<void> onDestroy(DateTime timestamp, bool restart) async {}
// }

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Screens/recovery_form_screen.dart';
import 'package:order_booking_app/Screens/shop_visit_screen.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:order_booking_app/screens/add_shop_screen.dart';
import 'package:order_booking_app/screens/return_form_screen.dart';
import 'package:order_booking_app/widgets/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../LocatioPoints/ravelTimeViewModel.dart';
import '../Reports/add_shop_screen/add_screen_report.dart';
import '../Reports/attendence_report/attendence_report_screen.dart';

import '../Reports/dispatch_report/dispatch_report_screen.dart';
import '../Reports/order_detail_report/OrderReportScreen.dart';
import '../Reports/recovery_report/recovery_report_screen.dart';
import '../Reports/shop_visit_report/shop_visit_report_screen.dart';
import '../Utils/ForceUpdateService.dart';
import '../ViewModels/ScreenViewModels/signup_view_model.dart';
import '../ViewModels/add_shop_view_model.dart';
import '../ViewModels/location_view_model.dart';
import '../ViewModels/order_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import '../ViewModels/shop_visit_details_view_model.dart';

import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/timer_card.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
import 'HomeScreenComponents/Today Stats/today_stats_record.dart';
import 'HomeScreenComponents/work_time_progress_card.dart';
import 'leave_form_screen.dart';
import 'order_booking_status_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ViewModels
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final shopVisitViewModel = Get.put(ShopVisitViewModel());
  late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
  late final orderMasterViewModel = Get.put(OrderMasterViewModel());
  late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
  late final returnFormViewModel = Get.put(ReturnFormViewModel());
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  late final signUpController = Get.put(SignUpController());
  final LocationViewModel locationVM = Get.find<LocationViewModel>();

  String user_id = '';
  String userName = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService.check(context);
    });

    _retrieveSavedValues();

    addShopViewModel.fetchAllAddShop(); // → Shops
    shopVisitViewModel.fetchAllShopVisit(); // → Visit list
    shopVisitViewModel.fetchTotalShopVisit(); // → Visit COUNT (dashboard)
    shopVisitDetailsViewModel.initializeProductData();

    orderMasterViewModel.fetchAllOrderMaster(); // → Orders
    orderMasterViewModel.fetchTotalDispatched(); // → Dispatched

    recoveryFormViewModel.fetchAllRecoveryForm(); // → Recovery
    returnFormViewModel.fetchAllReturnForm(); // → Returns

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
    // Set working status false on home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final travelTimeVM = Get.find<TravelTimeViewModel>();
      travelTimeVM.setWorkingScreenStatus(false);
    });

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
                    SizedBox(height: spacingBetweenRows),
                    _buildQuickActions(horizontalPadding: horizontalPadding),
                    SizedBox(height: 20),
                    TodayStatsCard(),
                    SizedBox(
                      height: 20,
                    ),
                    _buildPerformanceOverview(
                        horizontalPadding: horizontalPadding),
                    const SizedBox(height: 20),
                    DailyTimeCircularCard(),
                    SizedBox(
                      height: 20,
                    ),
                    _buildFooter(),
                    const SizedBox(height: 24),
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

  Widget _buildQuickActions({required double horizontalPadding}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionTile(
                icon: LucideIcons.store,
                label: 'Add Shop',
                onTap: () {
                  if (locationVM.isClockedIn.value) {
                    Get.to(() => AddShopScreen());
                  } else {
                    _showClockInRequiredDialog();
                  }
                },
              ),
              SizedBox(width: 10),
              _actionTile(
                icon: LucideIcons.building,
                label: 'Shop Visit',
                onTap: () {
                  if (locationVM.isClockedIn.value) {
                    Get.to(() => const ShopVisitScreen());
                  } else {
                    _showClockInRequiredDialog();
                  }
                },
              ),
              SizedBox(width: 10),
              _actionTile(
                icon: LucideIcons.refreshCcw,
                label: 'Return',
                onTap: () async {
                  if (locationVM.isClockedIn.value) {
                    await orderMasterViewModel.fetchAllOrderMaster();
                    await orderDetailsViewModel.fetchAllReConfirmOrder();
                    Get.to(() => ReturnFormScreen());
                  } else {
                    _showClockInRequiredDialog();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionTile(
                icon: LucideIcons.wallet,
                label: 'Recovery',
                onTap: () async {
                  if (locationVM.isClockedIn.value) {
                    await orderMasterViewModel.fetchAllOrderMaster();
                    await recoveryFormViewModel.initializeData();
                    Get.to(() => RecoveryFormScreen());
                  } else {
                    _showClockInRequiredDialog();
                  }
                },
              ),
              SizedBox(width: 10),
              _actionTile(
                icon: LucideIcons.clipboardCheck,
                label: 'Booking Status',
                onTap: () async {
                  await orderMasterViewModel.fetchAllOrderMaster();
                  Get.to(() => OrderBookingStatusScreen());
                },
              ),
              SizedBox(width: 10),
              _actionTile(
                icon: LucideIcons.calendarDays,
                label: 'Leave',
                onTap: () => Get.to(() => LeaveFormScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100, // FIXED HEIGHT as requested
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview({required double horizontalPadding}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Summary",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            // final totalShops = addShopViewModel.allAddShop.length;
            // final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
            // final totalOrders = orderMasterViewModel.allOrderMaster.length;
            // final dispatched = orderMasterViewModel.apiDispatchedCount.value;
            // final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
            // final totalReturns = returnFormViewModel.allReturnForm.length;
            // final attendanceIn = attendanceViewModel.allAttendance.length;
            final totalShops = addShopViewModel.allAddShop.length;
            final totalVisits = shopVisitViewModel.apiShopVisitsCount.value;
            final totalOrders = orderMasterViewModel.allOrderMaster.length;
            final dispatched = orderMasterViewModel.apiDispatchedCount.value;
            final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
            final totalReturns = returnFormViewModel.allReturnForm.length;
            final attendanceIn = attendanceViewModel.allAttendance.length;
            // final totalBookings  = bookingViewModel.allBookings.length; // agar booking module hai

            return SizedBox(
              height: 180, // FIXED HEIGHT as requested
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  children: [
                    // _statGridItem(
                    //   "Shops",
                    //   totalVisits,
                    //   Icons.store_outlined,
                    //   onTap: () => Get.to(() => AddShopReportScreen()),
                    // ),
                    // _statGridItem(
                    //   "Visits",
                    //   totalVisits,
                    //   Icons.directions_walk_outlined,
                    //   onTap: () => Get.to(() => ShopVisitReportDashboard()),
                    // ),
                    // _statGridItem(
                    //   "Orders",
                    //   totalOrders,
                    //   Icons.shopping_cart_outlined,
                    //   onTap: () => Get.to(() => OrderReportScreen()),
                    // ),
                    // _statGridItem("Dispatched", dispatched, Icons.local_shipping_outlined),
                    // _statGridItem("Returns", totalReturns, Icons.assignment_return_outlined),
                    // _statGridItem("Recovery", totalRecovery, Icons.attach_money_outlined),
                    // _statGridItem(
                    //   "Attendance",
                    //   totalOrders,
                    //   Icons.punch_clock_outlined,
                    //   onTap: () => Get.to(() => AttendanceRecordScreen()),
                    // ),
                    // _statGridItem("Bookings", attendanceIn, Icons.book),

                    _statGridItem(
                      "Shops",
                      totalShops,
                      Icons.store_outlined,
                      onTap: () => Get.to(() => AddShopReportScreen()),
                    ),

                    _statGridItem(
                      "Visits",
                      totalVisits,
                      Icons.directions_walk_outlined,
                      onTap: () => Get.to(() => ShopVisitReportDashboard()),
                    ),

                    _statGridItem(
                      "Orders",
                      totalOrders,
                      Icons.shopping_cart_outlined,
                      onTap: () => Get.to(() => OrderReportScreen()),
                    ),

                    _statGridItem("Dispatched", dispatched,
                        Icons.local_shipping_outlined,
                      onTap: () => Get.to(() => DispatchOrdersDashboard()),
                    ),

                    _statGridItem("Returns", totalReturns,
                        Icons.assignment_return_outlined),

                    _statGridItem(
                        "Recovery", totalRecovery, Icons.attach_money_outlined,
                        onTap: () => Get.to(() => RecoveryFormDashboard()),
                    ),

                    _statGridItem(
                      "Attendance",
                      attendanceIn,
                      Icons.punch_clock_outlined,
                      onTap: () => Get.to(() => AttendanceRecordScreen()),
                    ),

                    _statGridItem(
                      "Bookings",
                      totalOrders,
                      Icons.book,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statGridItem(String label, int value, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.blueGrey.shade800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "$version",
          style: const TextStyle(
            // fontSize: fontSize - 1,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

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
