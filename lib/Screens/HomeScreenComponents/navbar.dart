// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';
// import '../../ViewModels/update_function_view_model.dart';
//
// class Navbar extends StatelessWidget {
//   Navbar({super.key});
//   late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
//       decoration: BoxDecoration(
//         color: Colors.blue,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue[900]!.withOpacity(0.8),
//             spreadRadius: 3,
//             blurRadius: 7,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Row(
//             children: [
//               SizedBox(width: 150),
//               Text(
//                 "BookIT",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const SizedBox(width: 20),
//               GestureDetector(
//                 onTap: () async {
//                   // Show "refreshing" Snackbar
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Refreshing data...'),
//                       duration: Duration(seconds: 2),
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                   );
//
//                   debugPrint('Refresh icon tapped');
//                   debugPrint('🔄 Manual sync triggered from navbar');
//
//                   // Fetch latest data from server
//                   await updateFunctionViewModel.fetchAndSaveUpdatedCities();
//                   await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
//                   await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();
//
//                   // ✅ NOW THIS WILL WORK - Sync all local data to server
//                   await updateFunctionViewModel.syncAllLocalDataToServer();
//
//                   await updateFunctionViewModel.checkAndSetInitializationDateTime();
//
//                   // Show "done" Snackbar
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Data refreshed and synced successfully!'),
//                       duration: Duration(seconds: 2),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 },
//                 child: const Icon(Icons.refresh_sharp, color: Colors.white, size: 28),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/side_menu.dart';
import '../../ViewModels/update_function_view_model.dart';

class Navbar extends StatelessWidget {
  Navbar({super.key});
  final updateFunctionViewModel = Get.put(UpdateFunctionViewModel()); // ✅ CHANGED TO PUT

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.8),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              SizedBox(width: 150),
              Text(
                "BookIT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // Show "syncing" Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Syncing data...'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );

                  debugPrint('🔄 Manual sync triggered from navbar');

                  // Fetch latest data from server
                  await updateFunctionViewModel.fetchAndSaveUpdatedCities();
                  await updateFunctionViewModel.fetchAndSaveUpdatedProducts();
                  await updateFunctionViewModel.fetchAndSaveUpdatedOrderMaster();

                  // Sync all local data to server
                  await updateFunctionViewModel.syncAllLocalDataToServer();

                  await updateFunctionViewModel.checkAndSetInitializationDateTime();

                  // Show "done" Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data synced successfully!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Icon(Icons.restart_alt_outlined, color: Colors.white, size: 31), // ✅ SYNC ICON
              ),
            ],
          ),
        ],
      ),
    );
  }
}