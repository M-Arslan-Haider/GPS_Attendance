// //
// //
// // import 'package:auto_route/annotations.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/physics.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// // import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// // import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// // import 'package:order_booking_app/screens/add_shop_screen.dart';
// // import 'package:order_booking_app/screens/return_form_screen.dart';
// // import 'package:rive/rive.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// // import '../ViewModels/add_shop_view_model.dart';
// // import '../ViewModels/location_view_model.dart';
// // import '../ViewModels/order_details_view_model.dart';
// // import '../ViewModels/return_form_view_model.dart';
// // import '../ViewModels/shop_visit_details_view_model.dart';
// // import '../screens/HomeScreenComponents/assets.dart';
// // import 'HomeScreenComponents/action_box.dart';
// //
// // import 'HomeScreenComponents/navbar.dart';
// // import 'HomeScreenComponents/overview_row.dart';
// // import 'HomeScreenComponents/profile_section.dart';
// // import 'HomeScreenComponents/theme.dart';
// // import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// // import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// // import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// // import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// // import 'HomeScreenComponents/timer_card.dart';
// // import 'package:order_booking_app/Screens/code_screen.dart';
// //
// // import 'order_booking_status_screen.dart';
// // // @RoutePage()
// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({super.key});
// //
// //   @override
// //   State<HomeScreen> createState() => _RiveAppHomeState();
// // }
// //
// // class _RiveAppHomeState extends State<HomeScreen>
// //     with TickerProviderStateMixin {
// //   late final addShopViewModel = Get.put(AddShopViewModel());
// //   late final shopVisitViewModel = Get.put(ShopVisitViewModel());
// //   late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
// //   late final orderMasterViewModel = Get.put(OrderMasterViewModel());
// //   late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
// //   late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
// //   late final returnFormViewModel = Get.put(ReturnFormViewModel());
// //   late final attendanceViewModel = Get.put(AttendanceViewModel());
// //   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
// //   late final  signUpController = Get.put(SignUpController());
// //
// //   late AnimationController? _animationController;
// //   late AnimationController? _onBoardingAnimController;
// //   late Animation<double> _onBoardingAnim;
// //   late Animation<double> _sidebarAnim;
// //   late SMIBool _menuBtn;
// //   final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
// //   // bool clocked= false;
// //   // bool clocked = false; // Ensure it's reactive
// //   // bool clockedIn = false; // Ensure it's reactive
// //
// //   final springDesc = const SpringDescription(
// //     mass: 0.1,
// //     stiffness: 40,
// //     damping: 5,
// //   );
// //   bool _showOnBoarding = false;
// //    // Ensure it's reactive
// //
// //
// //   void _onMenuIconInit(Artboard artboard) {
// //     final controller =
// //         StateMachineController.fromArtboard(artboard, "State Machine");
// //     artboard.addController(controller!);
// //     _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
// //     _menuBtn.value = true;
// //   }
// //
// //   void _presentOnBoarding(bool show) {
// //     if (show) {
// //       setState(() {
// //         _showOnBoarding = true;
// //       });
// //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// //       _onBoardingAnimController?.animateWith(springAnim);
// //     } else {
// //       _onBoardingAnimController?.reverse().whenComplete(() => {
// //             setState(() {
// //               _showOnBoarding = false;
// //             })
// //           });
// //     }
// //   }
// //
// //   void onMenuPress() {
// //     if (_menuBtn.value) {
// //       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
// //       _animationController?.animateWith(springAnim);
// //     } else {
// //       _animationController?.reverse();
// //     }
// //     _menuBtn.change(!_menuBtn.value);
// //
// //     SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
// //         ? SystemUiOverlayStyle.dark
// //         : SystemUiOverlayStyle.light);
// //   }
// //
// //   _retrieveSavedValues() async {
// //     // Get instance of SharedPreferences
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.reload();
// //
// //     // Update state with retrieved values
// //     setState(() {
// //       user_id = prefs.getString('userId') ?? '';
// //       userName = prefs.getString('userName') ?? '';
// //       userCity = prefs.getString('userCity') ?? '';
// //       userDesignation = prefs.getString('userDesignation') ?? '';
// //       userBrand = prefs.getString('userBrand') ?? '';
// //       userSM = prefs.getString('userSM') ?? '';
// //       userNSM = prefs.getString('userNSM') ?? '';
// //       userRSM = prefs.getString('userRSM') ?? '';
// //       userNameRSM = prefs.getString('userNameRSM') ?? '';
// //       userNameNSM = prefs.getString('userNameNSM') ?? '';
// //       userNameSM = prefs.getString('userNameSM') ?? '';
// //       companyName = prefs.getString('company_name') ?? '';
// //     });
// //     debugPrint(user_id);
// //   }
// //
// //   // final List<Widget> _screens = [
// //   //   const HomeTabView(),
// //   //   commonTabScene("User"),
// //   //   commonTabScene("User"),
// //   //   commonTabScene("User"),
// //   //
// //   // ];
// //   @override
// //   void initState() {
// //     _animationController = AnimationController(
// //       duration: const Duration(milliseconds: 200),
// //       upperBound: 1,
// //       vsync: this,
// //     );
// //     _onBoardingAnimController = AnimationController(
// //       duration: const Duration(milliseconds: 350),
// //       upperBound: 1,
// //       vsync: this,
// //     );
// //
// //     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// //       parent: _animationController!,
// //       curve: Curves.linear,
// //     ));
// //
// //     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// //       parent: _onBoardingAnimController!,
// //       curve: Curves.linear,
// //     ));
// //
// //     // _tabBody = _screens.first;
// //     super.initState();
// //     // productsViewModel.fetchAndSaveProducts();
// //     //
// //     _retrieveSavedValues();
// //     addShopViewModel.fetchAllAddShop();
// //     shopVisitViewModel.fetchAllShopVisit();
// //     shopVisitViewModel.fetchTotalShopVisit();
// //     // Future.microtask(() {
// //     //   shopVisitViewModel.clearFilters();
// //     // });
// //     shopVisitDetailsViewModel.initializeProductData();
// //     orderMasterViewModel.fetchAllOrderMaster();
// //     orderMasterViewModel.fetchTotalDispatched();
// //     recoveryFormViewModel.fetchAllRecoveryForm();
// //     returnFormViewModel.fetchAllReturnForm();
// //     attendanceViewModel.fetchAllAttendance();
// //     attendanceOutViewModel.fetchAllAttendanceOut();
// //     // orderMasterViewModel.orderMasterSerial();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _animationController?.dispose();
// //     _onBoardingAnimController?.dispose();
// //     super.dispose();
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //
// //     return WillPopScope(
// //       onWillPop: () async {
// //         // Return false to prevent the user from going back
// //         return false;
// //       },
// //       child: SafeArea(
// //         child: Scaffold(
// //           backgroundColor: Colors.white,
// //           body: SingleChildScrollView(
// //             child: Column(
// //               children: [
// //                 _buildHeader(),
// //                 const SizedBox(height: 1),
// //                 TimerCard(), // Add the TimerCard here
// //                 const SizedBox(height: 3),
// //                 _buildActionButtons(screenWidth),
// //                 const SizedBox(height: 20),
// //                 _buildOverviewSection(),
// //                 const SizedBox(height: 20),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //   // @override
// //   // Widget build(BuildContext context) {
// //   //   final double screenWidth = MediaQuery.of(context).size.width;
// //   //
// //   //   return WillPopScope(
// //   //     onWillPop: () async {
// //   //       final shouldPop = await showDialog<bool>(
// //   //         context: context,
// //   //         builder: (context) => AlertDialog(
// //   //           title: const Text('Are you sure?'),
// //   //           content: const Text('Do you want to Exit this App?'),
// //   //           actions: [
// //   //             TextButton(
// //   //               onPressed: () => Navigator.pop(context, false),
// //   //               child: const Text('No'),
// //   //             ),
// //   //             TextButton(
// //   //               onPressed: () =>  exit(0) ,
// //   //               child: const Text('Exit'),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //       );
// //   //
// //   //       return shouldPop ?? false;
// //   //     },
// //   //     child: SafeArea(
// //   //       child: Scaffold(
// //   //         backgroundColor: Colors.white,
// //   //         body: SingleChildScrollView(
// //   //           child: Column(
// //   //             children: [
// //   //               _buildHeader(),
// //   //               const SizedBox(height: 1),
// //   //               TimerCard(), // Add the TimerCard here
// //   //               const SizedBox(height: 3),
// //   //               _buildActionButtons(screenWidth),
// //   //               const SizedBox(height: 20),
// //   //               _buildOverviewSection(),
// //   //               const SizedBox(height: 20),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       ),
// //   //     ),
// //   //   );
// //   // }
// //   /// Builds the header, including navbar and profile section.
// //   Widget _buildHeader() {
// //     return Container(
// //       color: Colors.blue,
// //       child:  Column(
// //         children: [
// //           Navbar(),
// //           const SizedBox(height: 10),
// //           const ProfileSection(),
// //           const SizedBox(height: 10),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   /// Builds the section with action buttons.
// //   Widget _buildActionButtons(double screenWidth) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 15),
// //       child: Column(
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               ActionBox(
// //                 imagePath: add_shop,
// //                 label: 'Add Shop',
// //                 onTap: () async {
// //                   final locationVM = Get.find<LocationViewModel>();
// //                   if (locationVM.isClockedIn.value) {
// //                     Get.to(() => AddShopScreen());
// //                   } else {
// //                     Get.defaultDialog(
// //                       title: "Clock In Required",
// //                       middleText: "Please start the timer first.",
// //                       textConfirm: "OK",
// //                       confirmTextColor: Colors.white,
// //                       onConfirm: () {
// //                         Get.back();
// //                       },
// //                     );
// //                   }
// //                 },
// //               ),
// //               ActionBox(
// //                 imagePath: shop_visit,
// //                 label: 'Shop Visit',
// //                 onTap: () async {
// //                   final locationVM = Get.find<LocationViewModel>();
// //                   if (locationVM.isClockedIn.value) {
// //                     Get.to(() => const ShopVisitScreen());
// //                   } else {
// //                     Get.defaultDialog(
// //                       title: "Clock In Required",
// //                       middleText: "Please start the timer first.",
// //                       textConfirm: "OK",
// //                       confirmTextColor: Colors.white,
// //                       onConfirm: () {
// //                         Get.back();
// //                       },
// //                     );
// //                   }
// //                 },
// //               ),
// //               ActionBox(
// //                 imagePath: return_form,
// //                 label: 'Return Form',
// //                 onTap: () async {
// //                   final locationVM = Get.find<LocationViewModel>();
// //                   if (locationVM.isClockedIn.value) {
// //                     await orderMasterViewModel.fetchAllOrderMaster();
// //                     await orderDetailsViewModel.fetchAllReConfirmOrder();
// //                     Get.to(() => ReturnFormScreen());
// //                   } else {
// //                     Get.defaultDialog(
// //                       title: "Clock In Required",
// //                       middleText: "Please start the timer first.",
// //                       textConfirm: "OK",
// //                       confirmTextColor: Colors.white,
// //                       onConfirm: () {
// //                         Get.back();
// //                       },
// //                     );
// //                   }
// //                 },
// //               ),
// //               ActionBox(
// //                 imagePath: recovery2,
// //                 label: 'Recovery',
// //                 onTap: () async {
// //                   final locationVM = Get.find<LocationViewModel>();
// //                   if (locationVM.isClockedIn.value) {
// //                     await orderMasterViewModel.fetchAllOrderMaster();
// //                     await recoveryFormViewModel.initializeData();
// //                     Get.to(() => RecoveryFormScreen());
// //                   } else {
// //                     Get.defaultDialog(
// //                       title: "Clock In Required",
// //                       middleText: "Please start the timer first.",
// //                       textConfirm: "OK",
// //                       confirmTextColor: Colors.white,
// //                       onConfirm: () {
// //                         Get.back();
// //                       },
// //                     );
// //                   }
// //                 },
// //               ),
// //               ActionBox(
// //                 imagePath: order_booking_status,
// //                 label: 'Booking Status',
// //                 onTap: () async {
// //                   await orderMasterViewModel.fetchAllOrderMaster();
// //                   Get.to(() => OrderBookingStatusScreen());
// //                 },
// //               ),
// //             ],
// //           ),
// //
// //         ],
// //
// //
// //       ),
// //
// //     );
// //   }
// //
// //   /// Builds the overview section with summary boxes.
// //   Widget _buildOverviewSection() {
// //     // Access the AddShopViewModel
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "Overview",
// //             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 20),
// //           Obx(() {
// //             // Calculate the total number of shops
// //             final totalShops = addShopViewModel.allAddShop.length;
// //             //final totalShopsVisits = shopVisitViewModel.allShopVisit.length;
// //             final totalShopsVisits = shopVisitViewModel.apiShopVisitsCount.value;
// //             final totalOrders = orderMasterViewModel.allOrderMaster.length;
// //             final totalDispatchedOrders =
// //                 orderMasterViewModel.apiDispatchedCount.value;
// //             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
// //             final totalReturn = returnFormViewModel.allReturnForm.length;
// //
// //             final totalAttendanceIn = attendanceViewModel.allAttendance.length;
// //             return Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue.shade50,
// //                 borderRadius: BorderRadius.circular(20),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.blue.withOpacity(0.8),
// //                     spreadRadius: 3,
// //                     blurRadius: 9,
// //                     offset: const Offset(0, 3),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 children: [
// //                   OverviewRow(
// //                     numbers: [
// //                       totalShops.toString(), // Total Shops
// //                       totalShopsVisits.toString(), // Total Visits
// //                       totalOrders.toString(), // Total Orders
// //                       totalReturn.toString(), // Total Return
// //                     ],
// //                     labels: const [
// //                       "Total Shops",
// //                       "Visits",
// //                       "Orders",
// //                       "Returns"
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   OverviewRow(
// //                     numbers: [
// //                       totalAttendanceIn.toString(), // Total Attendance
// //                       totalOrders.toString(), // Total Orders
// //                       totalDispatchedOrders
// //                           .toString(), // Total Dispatched Orders
// //                       totalRecovery.toString(), // Total Recovery
// //                     ],
// //                     labels: const [
// //                       "Monthly Attendance",
// //                       "Daily Bookings",
// //                       "Dispatched",
// //                       "Recovery"
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                  // OverviewRow(
// //                  //    numbers: [
// //                  //      // totalDispatchedOrders.toString(),
// //                  //      "112",
// //                  //    ],
// //                  //    labels: ["Total Orders", "Dispatched"],
// //                  //  ),
// //                 ],
// //               ),
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:auto_route/annotations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/physics.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/recovery_form_screen.dart';
// import 'package:order_booking_app/Screens/shop_visit_screen.dart';
// import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
// import 'package:order_booking_app/screens/add_shop_screen.dart';
// import 'package:order_booking_app/screens/return_form_screen.dart';
// import 'package:rive/rive.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // ✅ added
//
// import '../ViewModels/ScreenViewModels/signup_view_model.dart';
// import '../ViewModels/add_shop_view_model.dart';
// import '../ViewModels/location_view_model.dart';
// import '../ViewModels/order_details_view_model.dart';
// import '../ViewModels/return_form_view_model.dart';
// import '../ViewModels/shop_visit_details_view_model.dart';
// import '../screens/HomeScreenComponents/assets.dart';
// import 'HomeScreenComponents/action_box.dart';
// import 'HomeScreenComponents/navbar.dart';
// import 'HomeScreenComponents/overview_row.dart';
// import 'HomeScreenComponents/profile_section.dart';
// import 'HomeScreenComponents/theme.dart';
// import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
// import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
// import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
// import 'HomeScreenComponents/timer_card.dart';
// import 'package:order_booking_app/Screens/code_screen.dart';
// import 'order_booking_status_screen.dart';
//
//
//
// // @RoutePage()
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _RiveAppHomeState();
// }
//
// class _RiveAppHomeState extends State<HomeScreen>
//     with TickerProviderStateMixin {
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
//
//   late AnimationController? _animationController;
//   late AnimationController? _onBoardingAnimController;
//   late Animation<double> _onBoardingAnim;
//   late Animation<double> _sidebarAnim;
//   late SMIBool _menuBtn;
//   final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
//   final springDesc = const SpringDescription(
//     mass: 0.1,
//     stiffness: 40,
//     damping: 5,
//   );
//   bool _showOnBoarding = false;
//
//   void _onMenuIconInit(Artboard artboard) {
//     final controller =
//     StateMachineController.fromArtboard(artboard, "State Machine");
//     artboard.addController(controller!);
//     _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
//     _menuBtn.value = true;
//   }
//
//   void _presentOnBoarding(bool show) {
//     if (show) {
//       setState(() {
//         _showOnBoarding = true;
//       });
//       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
//       _onBoardingAnimController?.animateWith(springAnim);
//     } else {
//       _onBoardingAnimController?.reverse().whenComplete(() => {
//         setState(() {
//           _showOnBoarding = false;
//         })
//       });
//     }
//   }
//
//   void onMenuPress() {
//     if (_menuBtn.value) {
//       final springAnim = SpringSimulation(springDesc, 0, 1, 0);
//       _animationController?.animateWith(springAnim);
//     } else {
//       _animationController?.reverse();
//     }
//     _menuBtn.change(!_menuBtn.value);
//
//     SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
//         ? SystemUiOverlayStyle.dark
//         : SystemUiOverlayStyle.light);
//   }
//
//   _retrieveSavedValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//
//     setState(() {
//       user_id = prefs.getString('userId') ?? '';
//       userName = prefs.getString('userName') ?? '';
//       userCity = prefs.getString('userCity') ?? '';
//       userDesignation = prefs.getString('userDesignation') ?? '';
//       userBrand = prefs.getString('userBrand') ?? '';
//       userSM = prefs.getString('userSM') ?? '';
//       userNSM = prefs.getString('userNSM') ?? '';
//       userRSM = prefs.getString('userRSM') ?? '';
//       userNameRSM = prefs.getString('userNameRSM') ?? '';
//       userNameNSM = prefs.getString('userNameNSM') ?? '';
//       userNameSM = prefs.getString('userNameSM') ?? '';
//       companyName = prefs.getString('company_name') ?? '';
//     });
//     debugPrint(user_id);
//   }
//
//   @override
//   void initState() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       upperBound: 1,
//       vsync: this,
//     );
//     _onBoardingAnimController = AnimationController(
//       duration: const Duration(milliseconds: 350),
//       upperBound: 1,
//       vsync: this,
//     );
//
//     _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.linear,
//     ));
//
//     _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _onBoardingAnimController!,
//       curve: Curves.linear,
//     ));
//
//     super.initState();
//     _retrieveSavedValues();
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
//     // ✅ Start foreground service here
//     FlutterForegroundTask.startService(
//       notificationTitle: 'Clock Running',
//       notificationText: 'Tracking time and location...',
//       callback: startCallback,
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController?.dispose();
//     _onBoardingAnimController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 1),
//                 TimerCard(),
//
//                 const SizedBox(height: 3),
//                 _buildActionButtons(screenWidth),
//                 const SizedBox(height: 20),
//                 _buildOverviewSection(),
//                 const SizedBox(height: 30),
//
//                 // ✅ Professional footer version text
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 15),
//                   child: Text(
//                     'v0.1.2',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                       fontStyle: FontStyle.italic,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       color: Colors.blue,
//       child: Column(
//         children: [
//           Navbar(),
//           const SizedBox(height: 10),
//           const ProfileSection(),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(double screenWidth) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               ActionBox(
//                 imagePath: add_shop,
//                 label: 'Add Shop',
//                 onTap: () async {
//                   final locationVM = Get.find<LocationViewModel>();
//                   if (locationVM.isClockedIn.value) {
//                     Get.to(() => AddShopScreen());
//                   } else {
//                     Get.defaultDialog(
//                       title: "Clock In Required",
//                       middleText: "Please start the timer first.",
//                       textConfirm: "OK",
//                       confirmTextColor: Colors.white,
//                       onConfirm: () {
//                         Get.back();
//                       },
//                     );
//                   }
//                 },
//               ),
//               ActionBox(
//                 imagePath: shop_visit,
//                 label: 'Shop Visit',
//                 onTap: () async {
//                   final locationVM = Get.find<LocationViewModel>();
//                   if (locationVM.isClockedIn.value) {
//                     Get.to(() => const ShopVisitScreen());
//                   } else {
//                     Get.defaultDialog(
//                       title: "Clock In Required",
//                       middleText: "Please start the timer first.",
//                       textConfirm: "OK",
//                       confirmTextColor: Colors.white,
//                       onConfirm: () {
//                         Get.back();
//                       },
//                     );
//                   }
//                 },
//               ),
//
//               ActionBox(
//                 imagePath: return_form,
//                 label: 'Return Form',
//                 onTap: () async {
//                   final locationVM = Get.find<LocationViewModel>();
//                   if (locationVM.isClockedIn.value) {
//                     await orderMasterViewModel.fetchAllOrderMaster();
//                     await orderDetailsViewModel.fetchAllReConfirmOrder();
//                     Get.to(() => ReturnFormScreen());
//                   } else {
//                     Get.defaultDialog(
//                       title: "Clock In Required",
//                       middleText: "Please start the timer first.",
//                       textConfirm: "OK",
//                       confirmTextColor: Colors.white,
//                       onConfirm: () {
//                         Get.back();
//                       },
//                     );
//                   }
//                 },
//               ),
//               ActionBox(
//                 imagePath: recovery2,
//                 label: 'Recovery',
//                 onTap: () async {
//                   final locationVM = Get.find<LocationViewModel>();
//                   if (locationVM.isClockedIn.value) {
//                     await orderMasterViewModel.fetchAllOrderMaster();
//                     await recoveryFormViewModel.initializeData();
//                     Get.to(() => RecoveryFormScreen());
//                   } else {
//                     Get.defaultDialog(
//                       title: "Clock In Required",
//                       middleText: "Please start the timer first.",
//                       textConfirm: "OK",
//                       confirmTextColor: Colors.white,
//                       onConfirm: () {
//                         Get.back();
//                       },
//                     );
//                   }
//                 },
//               ),
//               ActionBox(
//                 imagePath: order_booking_status,
//                 label: 'Booking Status',
//                 onTap: () async {
//                   await orderMasterViewModel.fetchAllOrderMaster();
//                   Get.to(() => OrderBookingStatusScreen());
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOverviewSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
// // HomeScreen.dart میں کہیں بھی ایک button شامل کریں
//           ElevatedButton(
//             onPressed: () {
//               Get.toNamed('/TravelTimeTestScreen');
//             },
//             child: Text('🚗 Travel Analytics'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//
//           const Text(
//             "Overview",
//             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           Obx(() {
//             final totalShops = addShopViewModel.allAddShop.length;
//             final totalShopsVisits =
//                 shopVisitViewModel.apiShopVisitsCount.value;
//             final totalOrders = orderMasterViewModel.allOrderMaster.length;
//             final totalDispatchedOrders =
//                 orderMasterViewModel.apiDispatchedCount.value;
//             final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
//             final totalReturn = returnFormViewModel.allReturnForm.length;
//             final totalAttendanceIn = attendanceViewModel.allAttendance.length;
//
//             return Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.8),
//                     spreadRadius: 3,
//                     blurRadius: 9,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   OverviewRow(
//                     numbers: [
//                       totalShops.toString(),
//                       totalShopsVisits.toString(),
//                       totalOrders.toString(),
//                       totalReturn.toString(),
//                     ],
//                     labels: const [
//                       "Total Shops",
//                       "total Shops Visits",
//                       "total Orders",
//                       "total\nReturn"
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   OverviewRow(
//                     numbers: [
//                       totalAttendanceIn.toString(),
//                       totalOrders.toString(),
//                       totalDispatchedOrders.toString(),
//                       totalRecovery.toString(),
//                     ],
//                     labels: const [
//                       "total Attendance",
//                       "total Bookings",
//                       "total Dispatched Orders",
//                       "total Recovery"
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// // ✅ required for foreground service
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }
//
// class MyTaskHandler extends TaskHandler {
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     // Start your timer or location logic here
//   }
//
//   @override
//   Future<void> onRepeatEvent(DateTime timestamp) async {
//     // Called periodically (if you set repeat interval)
//   }
//
//   @override
//   Future<void> onDestroy(DateTime timestamp, bool restart) async {
//     // Clean up resources here
//   }
// }



import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Screens/recovery_form_screen.dart';
import 'package:order_booking_app/Screens/shop_visit_screen.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:order_booking_app/screens/add_shop_screen.dart';
import 'package:order_booking_app/screens/return_form_screen.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // ✅ added

import '../GPX/screen.dart';
import '../LocatioPoints/ravelTimeViewModel.dart';
import '../ViewModels/ScreenViewModels/signup_view_model.dart';
import '../ViewModels/add_shop_view_model.dart';
import '../ViewModels/location_view_model.dart';
import '../ViewModels/order_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import '../ViewModels/shop_visit_details_view_model.dart';
import '../screens/HomeScreenComponents/assets.dart';
import 'HomeScreenComponents/action_box.dart';
import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/overview_row.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/theme.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
import 'HomeScreenComponents/timer_card.dart';
import 'package:order_booking_app/Screens/code_screen.dart';
import 'order_booking_status_screen.dart';
// ✅ ABDULLAH: Added import for TravelTimeViewModel




// @RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _RiveAppHomeState();
}

class _RiveAppHomeState extends State<HomeScreen>
    with TickerProviderStateMixin {
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
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;
  late SMIBool _menuBtn;
  final Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);
  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );
  bool _showOnBoarding = false;

  void _onMenuIconInit(Artboard artboard) {
    final controller =
    StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void _presentOnBoarding(bool show) {
    if (show) {
      setState(() {
        _showOnBoarding = true;
      });
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _onBoardingAnimController?.animateWith(springAnim);
    } else {
      _onBoardingAnimController?.reverse().whenComplete(() => {
        setState(() {
          _showOnBoarding = false;
        })
      });
    }
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }

  _retrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    setState(() {
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
      companyName = prefs.getString('company_name') ?? '';
    });
    debugPrint(user_id);
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _onBoardingAnimController!,
      curve: Curves.linear,
    ));

    super.initState();
    _retrieveSavedValues();
    addShopViewModel.fetchAllAddShop();
    shopVisitViewModel.fetchAllShopVisit();
    shopVisitViewModel.fetchTotalShopVisit();
    shopVisitDetailsViewModel.initializeProductData();
    orderMasterViewModel.fetchAllOrderMaster();
    orderMasterViewModel.fetchTotalDispatched();
    recoveryFormViewModel.fetchAllRecoveryForm();
    returnFormViewModel.fetchAllReturnForm();
    attendanceViewModel.fetchAllAttendance();
    attendanceOutViewModel.fetchAllAttendanceOut();

    // ✅ Start foreground service here
    FlutterForegroundTask.startService(
      notificationTitle: 'Clock Running',
      notificationText: 'Tracking time and location...',
      callback: startCallback,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }
// Kisi bhi screen se call karein
  void processGPXData() {
    LocationViewModel locationVM = Get.find<LocationViewModel>();
    locationVM.processGPXAndStoreCentralPoint();
  }
  @override
  Widget build(BuildContext context) {
    // ✅ ABDULLAH: Home screen par working status false karein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final travelTimeViewModel = Get.find<TravelTimeViewModel>();
      travelTimeViewModel.setWorkingScreenStatus(false);
      debugPrint("📍 [WORKING STATUS] Home Screen - Working time INACTIVE");
    });
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 1),
                TimerCard(),

                const SizedBox(height: 3),
                _buildActionButtons(screenWidth),
                const SizedBox(height: 20),
                _buildOverviewSection(),
                const SizedBox(height: 30),

                // ✅ Professional footer version text
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    ' v0.1.1',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          Navbar(),
          const SizedBox(height: 10),
          const ProfileSection(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionBox(
                imagePath: add_shop,
                label: 'Add Shop',
                onTap: () async {
                  final locationVM = Get.find<LocationViewModel>();
                  if (locationVM.isClockedIn.value) {
                    Get.to(() => AddShopScreen());
                  } else {
                    Get.defaultDialog(
                      title: "Clock In Required",
                      middleText: "Please start the timer first.",
                      textConfirm: "OK",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                      },
                    );
                  }
                },
              ),
              ActionBox(
                imagePath: shop_visit,
                label: 'Shop Visit',
                onTap: () async {
                  final locationVM = Get.find<LocationViewModel>();
                  if (locationVM.isClockedIn.value) {
                    Get.to(() => const ShopVisitScreen());
                  } else {
                    Get.defaultDialog(
                      title: "Clock In Required",
                      middleText: "Please start the timer first.",
                      textConfirm: "OK",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                      },
                    );
                  }
                },
              ),

              ActionBox(
                imagePath: return_form,
                label: 'Return Form',
                onTap: () async {
                  final locationVM = Get.find<LocationViewModel>();
                  if (locationVM.isClockedIn.value) {
                    await orderMasterViewModel.fetchAllOrderMaster();
                    await orderDetailsViewModel.fetchAllReConfirmOrder();
                    Get.to(() => ReturnFormScreen());
                  } else {
                    Get.defaultDialog(
                      title: "Clock In Required",
                      middleText: "Please start the timer first.",
                      textConfirm: "OK",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                      },
                    );
                  }
                },
              ),
              ActionBox(
                imagePath: recovery2,
                label: 'Recovery',
                onTap: () async {
                  final locationVM = Get.find<LocationViewModel>();
                  if (locationVM.isClockedIn.value) {
                    await orderMasterViewModel.fetchAllOrderMaster();
                    await recoveryFormViewModel.initializeData();
                    Get.to(() => RecoveryFormScreen());
                  } else {
                    Get.defaultDialog(
                      title: "Clock In Required",
                      middleText: "Please start the timer first.",
                      textConfirm: "OK",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                      },
                    );
                  }
                },
              ),
              ActionBox(
                imagePath: order_booking_status,
                label: 'Booking Status',
                onTap: () async {
                  await orderMasterViewModel.fetchAllOrderMaster();
                  Get.to(() => OrderBookingStatusScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Kisi bhi screen mein button ya menu item par
//           ElevatedButton(
//             onPressed: () {
//               Get.toNamed('/CentralPointsTestScreen');
//             },
//             child: Text('Open Central Points'),
//           ),

// Ya phir
//           ElevatedButton(
//             onPressed: () {
//               Get.toNamed('/GPXViewerScreen');
//             },
//             child: Text('View GPX Files'),
//           ),

          // ListTile(
          //   leading: Icon(Icons.analytics),
          //   title: Text('Central Points Testing'),
          //   subtitle: Text('Test clustering and API functionality'),
          //   onTap: () {
          //     Get.to(() => CentralPointsTestScreen());
          //   },
          //   trailing: Icon(Icons.arrow_forward_ios),
          // ),

          // ElevatedButton(
          //   onPressed: () {
          //     Get.toNamed('/TravelTimeTestScreen');
          //   },
          //   child: Text('🚗 Travel Analytics'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     foregroundColor: Colors.white,
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     locationVM.saveLocationWithCentralPoints();
          //   },
          //   child: Text('Save Location with Central Points'),
          // ),

          // Manual sync button
          // ElevatedButton(
          //   onPressed: () {
          //     locationVM.syncCentralPointsToAPI();
          //   },
          //   child: Text('Sync Central Points to API'),
          // ),
          const Text(
            "Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final totalShops = addShopViewModel.allAddShop.length;
            final totalShopsVisits =
                shopVisitViewModel.apiShopVisitsCount.value;
            final totalOrders = orderMasterViewModel.allOrderMaster.length;
            final totalDispatchedOrders =
                orderMasterViewModel.apiDispatchedCount.value;
            final totalRecovery = recoveryFormViewModel.allRecoveryForm.length;
            final totalReturn = returnFormViewModel.allReturnForm.length;
            final totalAttendanceIn = attendanceViewModel.allAttendance.length;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.8),
                    spreadRadius: 3,
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  OverviewRow(
                    numbers: [
                      totalShops.toString(),
                      totalShopsVisits.toString(),
                      totalOrders.toString(),
                      totalReturn.toString(),
                    ],
                    labels: const [
                      "Total Shops",
                      "total Shops Visits",
                      "total Orders",
                      "total\nReturn"
                    ],
                  ),
                  const SizedBox(height: 20),
                  OverviewRow(
                    numbers: [
                      totalAttendanceIn.toString(),
                      totalOrders.toString(),
                      totalDispatchedOrders.toString(),
                      totalRecovery.toString(),
                    ],
                    labels: const [
                      "total Attendance",
                      "total Bookings",
                      "total Dispatched Orders",
                      "total Recovery"
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ✅ required for foreground service
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Start your timer or location logic here
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Called periodically (if you set repeat interval)
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool restart) async {
    // Clean up resources here
  }
}
