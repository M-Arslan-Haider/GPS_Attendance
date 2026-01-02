///old code 22-10-25

// import 'dart:async';
// // import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_order_details_screen.dart';
// import 'package:order_booking_app/Screens/SM/sm_shopdetails.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:location/location.dart' as loc;
// import '../../Databases/dp_helper.dart';
// import '../../ViewModels/add_shop_view_model.dart';
// import '../../ViewModels/attendance_out_view_model.dart';
// import '../../ViewModels/attendance_view_model.dart';
// import '../../ViewModels/location_view_model.dart';
// import '../../ViewModels/update_function_view_model.dart';
// import '../HomeScreenComponents/timer_card.dart';
// import 'SM_bookerbookingdetails.dart';
// import 'sm_bookingstatus.dart';
// import 'SM LOCATION/sm_location_navigation.dart';
// import 'sm_shopvisit.dart';
//
// class SMHomepage extends StatefulWidget {
//   const SMHomepage({super.key});
//
//   @override
//   _SMHomepageState createState() => _SMHomepageState();
// }
//
// class _SMHomepageState extends State<SMHomepage> {
//   late final addShopViewModel = Get.put(AddShopViewModel());
//   late final attendanceViewModel = Get.put(AttendanceViewModel());
//   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//
//   late StreamSubscription<ServiceStatus> locationServiceStatusStream;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ✅ Register all required ViewModels before TimerCard is used
//     Get.put(UpdateFunctionViewModel());
//     Get.put(LocationViewModel());
//     Get.put(AttendanceViewModel());
//     Get.put(AttendanceOutViewModel());
//     addShopViewModel.fetchAllAddShop();
//     attendanceViewModel.fetchAllAttendance();
//     attendanceOutViewModel.fetchAllAttendanceOut();
//     _retrieveSavedValues();
//     checkForUpdate(); // Check for updates when the screen opens
//   }
//
//   @override
//   void dispose() {
//     locationServiceStatusStream.cancel();
//     super.dispose();
//   }
//
//   _retrieveSavedValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       user_id = prefs.getString('userId') ?? '';
//       userName = prefs.getString('userName') ?? '';
//       userCity= prefs.getString('userCity') ?? '';
//       userDesignation = prefs.getString('userDesignation') ?? '';
//       userBrand = prefs.getString('userBrand') ?? '';
//       userSM = prefs.getString('userSM') ?? '';
//       userNSM = prefs.getString('userNSM') ?? '';
//       userRSM= prefs.getString('userRSM') ?? '';
//       shopVisitHeadsHighestSerial = prefs.getInt('shopVisitHeadsHighestSerial') ?? 1;
//     });
//   }
//
//   void showLoadingIndicator(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false, // Prevent back button press
//           child: const AlertDialog(
//             content: Row(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 20),
//                 Text("Please Wait..."),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           // Return false to prevent going back
//           return false;
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             title:  Center(
//               child: Text(
//                 '$user_id $userName',
//                 style: const TextStyle(
//                   fontFamily: 'avenir next',
//                   fontSize: 17,
//                 ),
//               ),
//             ),
//             elevation: 1, // Add a subtle shadow
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh, color: Colors.blue),
//                 onPressed: () {
//                   // _handleRefresh();
//                   // Add reload functionality here
//                 },
//               ),
//             ],
//           ),
//           body:Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: GridView.builder(
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16.0,
//                       mainAxisSpacing: 16.0,
//                     ),
//                     itemCount: 5, // Updated item count
//                     itemBuilder: (context, index) {
//                       final cardInfo = [
//                         {'title': 'Shop Visit', 'icon': Icons.store},
//                         {'title': 'Booker Status', 'icon': Icons.person},
//                         {'title': 'Shop Details', 'icon': Icons.info},
//                         {'title': 'Booker Order Details', 'icon': Icons.book},
//                         {'title': 'Location', 'icon': Icons.location_on},
//                       ][index];
//
//                       return _buildCard(
//                         context,
//                         cardInfo['title'] as String,
//                         cardInfo['icon'] as IconData,
//                         Colors.blue,
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//
//                   children: [
//
//
//                     // const SizedBox(width: 50),
//                     TimerCard(), // Add the TimerCard here
//
//                   ],
//                 ),// Add the TimerCard here
//
//                 const SizedBox(height: 0),
//
//                // Timer display and Clock In/Clock Out button in a horizontal layout
//                 Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Text(
//                         version,
//                         style: const TextStyle(
//                           fontFamily: 'avenir next',
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ]
//                 ),
//               ],
//             ),
//           ),
//         )
//     );
//   }
//
//   Widget _buildCard(BuildContext context, String title, IconData icon, Color color) {
//     return Card(
//       elevation: 4, // Slightly reduced elevation for a smaller card
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0), // Slightly smaller border radius
//       ),
//       child: InkWell(
//         onTap: () {
//           _navigateToPage(context, title);
//         },
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [color.withOpacity(0.3), Colors.transparent],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                   borderRadius: BorderRadius.circular(10.0), // Match border radius
//                 ),
//               ),
//             ),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10.0), // Reduced padding
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [color, color.withOpacity(0.7)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       icon,
//                       size: 24, // Slightly smaller icon size
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 12), // Reduced space between icon and title
//                   Text(
//                     title,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontFamily: 'avenir next',
//                       fontSize: 12, // Slightly smaller font size
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//
//             ),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _navigateToPage(BuildContext context, String title) {
//     // Navigation logic based on the title
//     switch (title) {
//       case 'Shop Visit':
//         final locationVM = Get.find<LocationViewModel>();
//         if (locationVM.isClockedIn.value)
//         // if (newIsClockedIn==true)
//         {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const ShopVisitPage(),
//             ),
//           );
//         } else {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Clock In Required'),
//               content: const Text('Please clock in before visiting a shop.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//         }
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const ShopVisitPage()),
//         // );
//         break;
//       case 'Booker Status':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => BookingStatus()),
//         );
//         break;
//       case 'Shop Details':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SMShopDetailPage()),
//         );
//         break;
//       case 'Booker Order Details':
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SmOrderDetailsScreen()),
//           // MaterialPageRoute(builder: (context) => SMBookingBookPage()),
//         );
//         break;
//       case 'Location':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => smnavigation()),
//         );
//         break;
//     }
//   }
// }

///added code 23-10-25
// import 'dart:async';
// // import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_order_details_screen.dart';
// import 'package:order_booking_app/Screens/SM/sm_shopdetails.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:location/location.dart' as loc;
// import '../../Databases/dp_helper.dart';
// import '../../ViewModels/add_shop_view_model.dart';
// import '../../ViewModels/attendance_out_view_model.dart';
// import '../../ViewModels/attendance_view_model.dart';
// import '../../ViewModels/location_view_model.dart';
// import '../../ViewModels/update_function_view_model.dart';
// import '../HomeScreenComponents/profile_section.dart';
// import '../HomeScreenComponents/timer_card.dart';
// import 'SM_bookerbookingdetails.dart';
// import 'sm_bookingstatus.dart';
// import 'SM LOCATION/sm_location_navigation.dart';
// import 'sm_shopvisit.dart';
//
// class SMHomepage extends StatefulWidget {
//   const SMHomepage({super.key});
//
//   @override
//   _SMHomepageState createState() => _SMHomepageState();
// }
//
// class _SMHomepageState extends State<SMHomepage> {
//   late final addShopViewModel = Get.put(AddShopViewModel());
//   late final attendanceViewModel = Get.put(AttendanceViewModel());
//   late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//
//   late StreamSubscription<ServiceStatus> locationServiceStatusStream;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ✅ Register all required ViewModels before TimerCard is used
//     Get.put(UpdateFunctionViewModel());
//     Get.put(LocationViewModel());
//     Get.put(AttendanceViewModel());
//     Get.put(AttendanceOutViewModel());
//     addShopViewModel.fetchAllAddShop();
//     attendanceViewModel.fetchAllAttendance();
//     attendanceOutViewModel.fetchAllAttendanceOut();
//     _retrieveSavedValues();
//     checkForUpdate(); // Check for updates when the screen opens
//   }
//
//   @override
//   void dispose() {
//     locationServiceStatusStream.cancel();
//     super.dispose();
//   }
//
//   _retrieveSavedValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       user_id = prefs.getString('userId') ?? '';
//       userName = prefs.getString('userName') ?? '';
//       userCity= prefs.getString('userCity') ?? '';
//       userDesignation = prefs.getString('userDesignation') ?? '';
//       userBrand = prefs.getString('userBrand') ?? '';
//       userSM = prefs.getString('userSM') ?? '';
//       userNSM = prefs.getString('userNSM') ?? '';
//       userRSM = prefs.getString('userRSM') ?? '';
//       shopVisitHeadsHighestSerial = prefs.getInt('shopVisitHeadsHighestSerial') ?? 1;
//     });
//   }
//
//   void showLoadingIndicator(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false, // Prevent back button press
//           child: const AlertDialog(
//             content: Row(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(width: 20),
//                 Text("Please Wait..."),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Return false to prevent going back
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.blue.shade50,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
//             child: Column(
//               children: [
//                 // Header Section with ID and Name
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ProfileSection(),
//                   // const SizedBox(height: 4),
//                   // Text(
//                   //   userName,
//                   //   style: const TextStyle(
//                   //     fontSize: 20,
//                   //     fontWeight: FontWeight.w600,
//                   //     color: Colors.black87,
//                   //   ),
//                   // ),
//                   // Text(
//                   //   "ID: $user_id",
//                   //   style: const TextStyle(
//                   //     fontSize: 14,
//                   //     fontWeight: FontWeight.bold,
//                   //     color: Colors.grey,
//                   //   ),
//                   // ),
//                   // Text(
//                   //   "Designation: $userDesignation",
//                   //   style: const TextStyle(
//                   //     fontSize: 14,
//                   //     fontWeight: FontWeight.bold,
//                   //     color: Colors.grey,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//
//                   //     Text(
//                   //       userName,
//                   //       style: const TextStyle(
//                   //         fontSize: 20,
//                   //         fontWeight: FontWeight.w600,
//                   //         color: Colors.black87,
//                   //       ),
//                   //     ),
//                   //     const SizedBox(height: 4),
//                   //     Text(
//                   //       "ID: $user_id",
//                   //       style: const TextStyle(
//                   //         fontSize: 14,
//                   //         fontWeight: FontWeight.bold,
//                   //         color: Colors.grey,
//                   //       ),
//                   //     ),
//                   //     Text(
//                   //       "Designation: $userDesignation",
//                   //       style: const TextStyle(
//                   //         fontSize: 14,
//                   //         fontWeight: FontWeight.bold,
//                   //         color: Colors.grey,
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                 const SizedBox(height: 5),
//
//                 // Timer Card
//                 Container(
//                   width: double.infinity,
//                   constraints: const BoxConstraints(minHeight: 0),
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: TimerCard(),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 5),
//
//                 // Grid Menu
//                 Expanded(
//                   child: GridView.count(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 14,
//                     mainAxisSpacing: 15,
//                     children: [
//                       _buildModernCard(
//                         context,
//                         "SHOP VISIT",
//                         Icons.store_mall_directory_rounded,
//                         Colors.blueAccent,
//                       ),
//                       _buildModernCard(
//                         context,
//                         "BOOKERS STATUS",
//                         Icons.people_alt_rounded,
//                         Colors.indigo,
//                       ),
//                       _buildModernCard(
//                         context,
//                         "SHOPS DETAILS",
//                         Icons.info_outline_rounded,
//                         Colors.teal,
//                       ),
//                       _buildModernCard(
//                         context,
//                         "BOOKERS ORDER DETAILS",
//                         Icons.receipt_long_rounded,
//                         Colors.deepPurple,
//                       ),
//                       _buildModernCard(
//                         context,
//                         "LOCATION",
//                         Icons.location_on_rounded,
//                         Colors.orange,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 5),
//                 Text(
//                   "$version",
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black54,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildModernCard(
//       BuildContext context,
//       String title,
//       IconData icon,
//       Color color,
//       ) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () => _navigateToPage(context, title),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 36,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//                 color: Colors.black87,
//               ),
//
//             ),
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _navigateToPage(BuildContext context, String title) {
//     // Navigation logic based on the title
//     switch (title) {
//       case 'SHOP VISIT':
//         final locationVM = Get.find<LocationViewModel>();
//         if (locationVM.isClockedIn.value) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const ShopVisitPage(),
//             ),
//           );
//         } else {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Clock In Required'),
//               content: const Text('Please clock in before visiting a shop.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//         }
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const ShopVisitPage()),
//         // );
//         break;
//       case 'Booker Status':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => BookingStatus()),
//         );
//         break;
//       case 'SHOPS DETAILS':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SMShopDetailPage()),
//         );
//         break;
//       case 'BOOKERS ORDER DETAILS':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SmOrderDetailsScreen()),
//         );
//         break;
//       case 'LOCATION':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => smnavigation()),
//         );
//         break;
//     }
//   }
// }


/// 25/10/2025
///

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_order_details_screen.dart';
import 'package:order_booking_app/Screens/SM/sm_shopdetails.dart';
import 'package:order_booking_app/Screens/leave_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import '../../Databases/dp_helper.dart';
import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../../ViewModels/location_view_model.dart';
import '../../ViewModels/update_function_view_model.dart';
import '../HomeScreenComponents/profile_section.dart';
import '../HomeScreenComponents/timer_card.dart';
import 'SM_bookerbookingdetails.dart';
import 'sm_bookingstatus.dart';
import 'SM LOCATION/sm_location_navigation.dart';
import 'sm_shopvisit.dart';

class SMHomepage extends StatefulWidget {
  const SMHomepage({super.key});

  @override
  _SMHomepageState createState() => _SMHomepageState();
}

class _SMHomepageState extends State<SMHomepage> {
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());

  late StreamSubscription<ServiceStatus> locationServiceStatusStream;

  @override
  void initState() {
    super.initState();
    Get.put(UpdateFunctionViewModel());
    Get.put(LocationViewModel());
    Get.put(AttendanceViewModel());
    Get.put(AttendanceOutViewModel());
    addShopViewModel.fetchAllAddShop();
    attendanceViewModel.fetchAllAttendance();
    attendanceOutViewModel.fetchAllAttendanceOut();
    _retrieveSavedValues();
    checkForUpdate();
  }

  @override
  void dispose() {
    locationServiceStatusStream.cancel();
    super.dispose();
  }

  _retrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      userCity = prefs.getString('userCity') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userSM = prefs.getString('userSM') ?? '';
      userNSM = prefs.getString('userNSM') ?? '';
      userRSM = prefs.getString('userRSM') ?? '';
      shopVisitHeadsHighestSerial = prefs.getInt('shopVisitHeadsHighestSerial') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    final double padding = isTablet ? 24 : 16;
    final double fontSize = isTablet ? 18 : 14;
    final double iconSize = isTablet ? 48 : 36;
    final int gridCount = isTablet ? 3 : 2;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 1.5),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const ProfileSection(),
                ),

                SizedBox(height: padding / 1.5),

                // Timer Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                    child: FittedBox(fit: BoxFit.scaleDown, child: TimerCard()),
                  ),
                ),

                SizedBox(height: padding / 1.5),

                // Grid Menu
                Expanded(
                  child: GridView.count(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 15,
                    childAspectRatio: isTablet ? 1.2 : 1,
                    children: [
                      _buildModernCard(context, "SHOP VISIT", Icons.store_mall_directory_rounded, Colors.blueAccent, iconSize, fontSize),
                      _buildModernCard(context, "BOOKERS STATUS", Icons.people_alt_rounded, Colors.indigo, iconSize, fontSize),
                      _buildModernCard(context, "SHOPS DETAILS", Icons.info_outline_rounded, Colors.teal, iconSize, fontSize),
                      _buildModernCard(context, "BOOKERS ORDER DETAILS", Icons.receipt_long_rounded, Colors.deepPurple, iconSize, fontSize),
                      _buildModernCard(context, "LOCATION", Icons.location_on_rounded, Colors.orange, iconSize, fontSize),
                      _buildModernCard(context, "LEAVE", Icons.event_busy, Colors.blueGrey, iconSize, fontSize),
                    ],
                  ),
                ),

                SizedBox(height: padding / 2),
                Text(
                  "$version",
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      double iconSize,
      double fontSize) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _navigateToPage(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) {
    switch (title) {
      case 'SHOP VISIT':
        final locationVM = Get.find<LocationViewModel>();
        if (locationVM.isClockedIn.value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopVisitPage()));
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('Clock In Required'),
              content: Text('Please clock in before visiting a shop.'),
            ),
          );
        }
        break;
      case 'BOOKERS STATUS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingStatus()));
        break;
      case 'SHOPS DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => SMShopDetailPage()));
        break;
      case 'BOOKERS ORDER DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => SmOrderDetailsScreen()));
        break;
      case 'LOCATION':
        Navigator.push(context, MaterialPageRoute(builder: (context) => smnavigation()));
        break;
      case 'LEAVE':
        Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveFormScreen()));
        break;
    }
  }
}
