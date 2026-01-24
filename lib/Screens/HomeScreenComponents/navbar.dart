// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';
// // // import '../../ViewModels/update_function_view_model.dart';
// // //
// // // class Navbar extends StatelessWidget {
// // //   Navbar({super.key});
// // //   late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
// // //       decoration: BoxDecoration(
// // //         color: Colors.blue,
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.blue[900]!.withOpacity(0.8),
// // //             spreadRadius: 3,
// // //             blurRadius: 7,
// // //             offset: const Offset(0, 4),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           const Row(
// // //             children: [
// // //               SizedBox(width: 150),
// // //               Text(
// // //                 "BookIT",
// // //                 style: TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 24,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           Row(
// // //             children: [
// // //               const SizedBox(width: 20),
// // //               GestureDetector(
// // //                 onTap: () async {
// // //                   // Show "refreshing" Snackbar
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text('Refreshing data...'),
// // //                       duration: Duration(seconds: 2),
// // //                       backgroundColor: Colors.blueAccent,
// // //                     ),
// // //                   );
// // //
// // //                   debugPrint('Refresh icon tapped');
// // //                   debugPrint('🔄 Manual sync triggered from navbar');
// // //
// // //                   // Fetch latest data from server
// // //                   await updateFunctionViewModel.fetchAndSaveUpdatedCities();
// // //                   await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
// // //                   await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();
// // //
// // //                   // ✅ NOW THIS WILL WORK - Sync all local data to server
// // //                   await updateFunctionViewModel.syncAllLocalDataToServer();
// // //
// // //                   await updateFunctionViewModel.checkAndSetInitializationDateTime();
// // //
// // //                   // Show "done" Snackbar
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text('Data refreshed and synced successfully!'),
// // //                       duration: Duration(seconds: 2),
// // //                       backgroundColor: Colors.green,
// // //                     ),
// // //                   );
// // //                 },
// // //                 child: const Icon(Icons.refresh_sharp, color: Colors.white, size: 28),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';
// // import '../../ViewModels/update_function_view_model.dart';
// //
// // class Navbar extends StatelessWidget {
// //   Navbar({super.key});
// //   final updateFunctionViewModel = Get.put(UpdateFunctionViewModel()); // ✅ CHANGED TO PUT
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
// //       decoration: BoxDecoration(
// //         color: Colors.blue,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.blue[900]!.withOpacity(0.8),
// //             spreadRadius: 3,
// //             blurRadius: 7,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           const Row(
// //             children: [
// //               SizedBox(width: 150),
// //               Text(
// //                 "BookIT",
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           Row(
// //             children: [
// //               const SizedBox(width: 20),
// //               GestureDetector(
// //                 onTap: () async {
// //                   // Show "syncing" Snackbar
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text('Syncing data...'),
// //                       duration: Duration(seconds: 2),
// //                       backgroundColor: Colors.blueAccent,
// //                     ),
// //                   );
// //
// //                   debugPrint('🔄 Manual sync triggered from navbar');
// //
// //                   // Fetch latest data from server
// //                   await updateFunctionViewModel.fetchAndSaveUpdatedCities();
// //                   await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
// //                   await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();
// //
// //                   // Sync all local data to server
// //                   await updateFunctionViewModel.syncAllLocalDataToServer();
// //
// //                   await updateFunctionViewModel.checkAndSetInitializationDateTime();
// //
// //                   // Show "done" Snackbar
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text('Data synced successfully!'),
// //                       duration: Duration(seconds: 2),
// //                       backgroundColor: Colors.green,
// //                     ),
// //                   );
// //                 },
// //                 child: const Icon(Icons.restart_alt_outlined, color: Colors.white, size: 31), // ✅ SYNC ICON
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
//
// class Navbar extends StatelessWidget {
//   Navbar({super.key});
//   final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//
//             Colors.blue.shade800,
//             Colors.blue.shade600,
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.shade800.withOpacity(0.3),
//             spreadRadius: 2,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left side - App Logo/Name with icon
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 // child: const Icon(
//                 //   Icons.book_online,
//                 //   color: Colors.blue,
//                 //   size: 28,
//                 // ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "BOOKIT",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Text(
//                     "Sales Management",
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 10,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           // Right side - Sync button with badge
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.white.withOpacity(0.2),
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     onPressed: () async {
//                       // Show sync indicator
//                       Get.showSnackbar(
//                         GetSnackBar(
//                           message: 'Syncing data...',
//                           duration: const Duration(seconds: 2),
//                           backgroundColor: Colors.blue,
//                           icon: const Icon(Icons.sync, color: Colors.white),
//                           borderRadius: 8,
//                           margin: const EdgeInsets.all(10),
//                         ),
//                       );
//
//                       debugPrint('🔄 Manual sync triggered from navbar');
//
//                       // Fetch latest data from server
//                       await updateFunctionViewModel.fetchAndSaveUpdatedCities();
//                       await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
//                       await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();
//
//                       // Sync all local data to server
//                       await updateFunctionViewModel.syncAllLocalDataToServer();
//                       await updateFunctionViewModel.checkAndSetInitializationDateTime();
//
//                       // Show success message
//                       Get.showSnackbar(
//                         const GetSnackBar(
//                           message: 'Data synced successfully!',
//                           duration: Duration(seconds: 2),
//                           backgroundColor: Colors.green,
//                           icon: Icon(Icons.check_circle, color: Colors.white),
//                           borderRadius: 8,
//                           margin: EdgeInsets.all(10),
//                         ),
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.sync_rounded,
//                       color: Colors.blue,
//                       size: 24,
//                     ),
//                     style: IconButton.styleFrom(
//                       backgroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 // Sync badge
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade400,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//newdesign
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
//
// class Navbar extends StatelessWidget {
//   Navbar({super.key});
//
//   final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.blueAccent.shade700,
//             Colors.blueAccent.shade400,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         // borderRadius: const BorderRadius.only(
//         //   bottomLeft: Radius.circular(30),
//         //   bottomRight: Radius.circular(30),
//         // ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left side - App Logo/Name
//           Row(
//             children: [
//               // Optional: small logo/icon container (muted)
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.business_center_rounded, // or your preferred icon
//                   color: Colors.white,
//                   size: 26,
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "BOOKIT",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   Text(
//                     "Order Management System",
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.80),
//                       fontSize: 11,
//                       fontWeight: FontWeight.w400,
//                       letterSpacing: 0.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           // Right side - Sync button (cleaner version)
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () async {
//                 // ───────────────────────────────────────
//                 //   Sync logic (kept same as original)
//                 // ───────────────────────────────────────
//                 Get.showSnackbar(
//                   GetSnackBar(
//                     message: 'Syncing data...',
//                     duration: const Duration(seconds: 2),
//                     backgroundColor: const Color(0xFF3B82F6),
//                     icon: const Icon(Icons.sync, color: Colors.white),
//                     borderRadius: 10,
//                     margin: const EdgeInsets.all(12),
//                   ),
//                 );
//
//                 debugPrint('🔄 Manual sync triggered from navbar');
//
//                 await updateFunctionViewModel.fetchAndSaveUpdatedCities();
//                 await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
//                 await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();
//
//                 await updateFunctionViewModel.syncAllLocalDataToServer();
//                 await updateFunctionViewModel.checkAndSetInitializationDateTime();
//
//                 Get.showSnackbar(
//                   const GetSnackBar(
//                     message: 'Data synced successfully',
//                     duration: Duration(seconds: 2),
//                     backgroundColor: Color(0xFF10B981), // emerald-500 (calmer green)
//                     icon: Icon(Icons.check_circle_outline_rounded, color: Colors.white),
//                     borderRadius: 10,
//                     margin: EdgeInsets.all(12),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.sync_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/update_function_view_model.dart';

class Navbar extends StatelessWidget {
  Navbar({super.key});

  final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey,
            Colors.blueGrey,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // borderRadius: const BorderRadius.only(
        //   bottomLeft: Radius.circular(30),
        //   bottomRight: Radius.circular(30),
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - App Logo/Name
          Row(
            children: [
              // Optional: small logo/icon container (muted)
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.18),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: const Icon(
              //     Icons.business_center_rounded, // or your preferred icon
              //     color: Colors.white,
              //     size: 26,
              //   ),
              // ),
              // const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BOOKIT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Book once. Anywhere.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right side - Sync button (cleaner version)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                // ───────────────────────────────────────
                //   Sync logic (kept same as original)
                // ───────────────────────────────────────
                Get.showSnackbar(
                  GetSnackBar(
                    message: 'Syncing data...',
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF3B82F6),
                    icon: const Icon(Icons.sync, color: Colors.white),
                    borderRadius: 10,
                    margin: const EdgeInsets.all(12),
                  ),
                );

                debugPrint('🔄 Manual sync triggered from navbar');

                await updateFunctionViewModel.fetchAndSaveUpdatedCities();
                await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
                await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();

                await updateFunctionViewModel.syncAllLocalDataToServer();
                await updateFunctionViewModel.checkAndSetInitializationDateTime();

                Get.showSnackbar(
                  const GetSnackBar(
                    message: 'Data synced successfully',
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF10B981), // emerald-500 (calmer green)
                    icon: Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    borderRadius: 10,
                    margin: EdgeInsets.all(12),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}