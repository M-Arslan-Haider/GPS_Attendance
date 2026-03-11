//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// class Navbar extends StatelessWidget {
//   Navbar({super.key});
//
//   // final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.blueGrey,
//             Colors.blueGrey,
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
//               // Container(
//               //   padding: const EdgeInsets.all(8),
//               //   decoration: BoxDecoration(
//               //     color: Colors.white.withOpacity(0.18),
//               //     borderRadius: BorderRadius.circular(10),
//               //   ),
//               //   child: const Icon(
//               //     Icons.business_center_rounded, // or your preferred icon
//               //     color: Colors.white,
//               //     size: 26,
//               //   ),
//               // ),
//               // const SizedBox(width: 12),
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
//                     "Book once. Anywhere.",
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

class Navbar extends StatelessWidget {
  Navbar({super.key});

  static const Color _accentBlue  = Color(0xFF4354E8);
  static const Color _accentLight = Color(0xFFEBEEFD);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _accentBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left: App icon + Name ────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: _accentBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS Attendance',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    'GPS-Based Attendance System',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Right: Sync button ───────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                Get.showSnackbar(
                  GetSnackBar(
                    message: 'Syncing data...',
                    duration: const Duration(seconds: 2),
                    backgroundColor: _accentBlue,
                    icon: const Icon(Icons.sync, color: Colors.white),
                    borderRadius: 10,
                    margin: const EdgeInsets.all(12),
                  ),
                );

                debugPrint('🔄 Manual sync triggered from navbar');

                Get.showSnackbar(
                  const GetSnackBar(
                    message: 'Data synced successfully',
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF10B981),
                    icon: Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white),
                    borderRadius: 10,
                    margin: EdgeInsets.all(12),
                  ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: _accentBlue,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}