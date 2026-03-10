// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../Databases/util.dart';
//
//
// import '../HomeScreenComponents/navbar.dart';
// import '../HomeScreenComponents/profile_section.dart';
// import '../HomeScreenComponents/timer_card.dart';
//
//
// class DispatcherHomepage extends StatefulWidget {
//   const DispatcherHomepage({super.key});
//
//   @override
//   State<DispatcherHomepage> createState() => _DispatcherHomepageState();
// }
//
// class _DispatcherHomepageState extends State<DispatcherHomepage> {
//   // Initialize all required ViewModels (same as HomeScreen)
//   // late final attendanceViewModel = Get.put(AttendanceViewModel());
//   // late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
//   // // late final signUpController = Get.put(SignUpController());
//   // final LocationViewModel locationVM = Get.find<LocationViewModel>();
//
//   // State variables for counters
//   int dispatchedCount = 24;
//   int cancelledCount = 3;
//   int recordDialCount = 156;
//   int recoveryCount = 42;  // Added recovery count
//   int returnCount = 18;    // Added return count
//
//   @override
//   void initState() {
//     super.initState();
//
//     // // Initialize data (optional for dispatcher, but keeps consistency)
//     // attendanceViewModel.fetchAllAttendance();
//     // attendanceOutViewModel.fetchAllAttendanceOut();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false, // Prevent going back
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.grey.shade50,
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header with Navbar, Profile and Timer
//                 _buildHeaderSection(),
//                 const SizedBox(height: 15),
//
//                 // TimerCard wrapped in a container
//                 // TimerCard(),
//                 // const SizedBox(height: 24,),
//
//                 // Quick Actions - Only Dispatcher
//                 _buildQuickActionsSection(),
//                 const SizedBox(height: 24),
//
//                 // Version/Footer
//                 _buildFooter(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection() {
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
//           Positioned(
//             top: -100,
//             right: -50,
//             child: Transform.rotate(
//               angle: -0.2,
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
//           Column(
//             children: [
//               // Reuse Navbar from home page
//               Navbar(),
//               const SizedBox(height: 16),
//
//               // Reuse ProfileSection from home page
//               ProfileSection(),
//               const SizedBox(height: 16),
//               // // TimerCard wrapped in a container
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(horizontal: 20),
//               //     child: TimerCard(),
//               //   ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget _buildQuickActionsSection() {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 20),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Row(
//   //           children: [
//   //             Text(
//   //               "Quick Actions",
//   //               style: TextStyle(
//   //                 fontSize: 17,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: Colors.blueGrey.shade800,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //         const SizedBox(height: 10),
//   //
//   //         // Dispatcher Action Card
//   //         _actionCard(
//   //           title: "Dispatch",
//   //           description: "Manage orders and handle dispatches",
//   //           icon: Icons.arrow_forward_ios_rounded,
//   //           iconColor: Colors.black,
//   //           bgColor: Colors.white,
//   //           cardColor: Colors.blueGrey.shade100,
//   //           onTap: () {
//   //             // SIMPLE: Just open the screen with a test user ID
//   //             Get.to(() => DispatchMasterScreen());
//   //           },
//   //         ),
//   //         const SizedBox(height: 16),
//   //
//   //         // Recovery Action Card
//   //         _actionCard(
//   //           title: "Recovery",
//   //           description: "Manage recovery forms and payments",
//   //           icon: Icons.arrow_forward_ios_rounded,
//   //           iconColor: Colors.black,
//   //           bgColor: Colors.white,
//   //           cardColor: Colors.blueGrey.shade100,
//   //           onTap: () {
//   //             Get.to(() =>  RecoveryDispatchScreen ()); // ✅ CORRECT
//   //           },
//   //         ),
//   //         const SizedBox(height: 16),
//   //
//   //         // Return Action Card
//   //         _actionCard(
//   //           title: "Return",
//   //           description: "Handle return forms and product returns",
//   //           icon: Icons.arrow_forward_ios_rounded,
//   //           iconColor: Colors.black,
//   //           bgColor: Colors.white,
//   //           cardColor: Colors.blueGrey.shade100,
//   //           onTap: () {
//   //             Get.snackbar(
//   //               "Return",
//   //               "Return function tapped",
//   //               snackPosition: SnackPosition.BOTTOM,
//   //             );
//   //           },
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _buildQuickActionsSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 "Quick Actions",
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blueGrey.shade800,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
//
//   // Add this helper method to check clock-in status
//   // void _checkClockInBeforeAction({required VoidCallback action, required String actionName}) {
//   //   // Check if user is clocked in
//   //   // bool isClockedIn = attendanceViewModel.isClockedIn.value;
//   //
//   //   if (!isClockedIn) {
//   //     // Show warning dialog if not clocked in
//   //     Get.dialog(
//   //       AlertDialog(
//   //         title: Row(
//   //           children: [
//   //             Icon(Icons.access_time_filled, color: Colors.blueGrey[700]),
//   //             const SizedBox(width: 10),
//   //             const Text(
//   //               'Clock In Required',
//   //               style: TextStyle(fontWeight: FontWeight.bold),
//   //             ),
//   //           ],
//   //         ),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               'You need to clock in before accessing the $actionName section.',
//   //               style: const TextStyle(fontSize: 15),
//   //             ),
//   //           ],
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Get.back(),
//   //             child: Text(
//   //               'Cancel',
//   //               style: TextStyle(color: Colors.grey[600]),
//   //             ),
//   //           ),
//   //           ElevatedButton(
//   //             onPressed: () {
//   //               Get.back(); // Close dialog
//   //               Get.snackbar(
//   //                 'Clock In',
//   //                 'Please click the play button on the timer card to clock in',
//   //                 snackPosition: SnackPosition.TOP,
//   //                 backgroundColor: Colors.blueGrey,
//   //                 colorText: Colors.white,
//   //                 duration: const Duration(seconds: 3),
//   //                 icon: const Icon(Icons.timer, color: Colors.white),
//   //               );
//   //             },
//   //             style: ElevatedButton.styleFrom(
//   //               backgroundColor: Colors.blueGrey,
//   //               foregroundColor: Colors.white,
//   //             ),
//   //             child: const Text('OK'),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //
//   //   // If clocked in, proceed with the action
//   //   action();
//   // }
//
//   Widget _actionCard({
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color iconColor,
//     required Color bgColor,
//     required Color cardColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blueGrey.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.blueGrey.shade800,
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.blueGrey.shade600,
//                         height: 1.4,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: iconColor.withOpacity(0.2),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 20,
//                   color: iconColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFooter() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24),
//       child: Column(
//         children: [
//           Text(
//             "$version",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.blueGrey.shade400,
//               fontWeight: FontWeight.w500,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
