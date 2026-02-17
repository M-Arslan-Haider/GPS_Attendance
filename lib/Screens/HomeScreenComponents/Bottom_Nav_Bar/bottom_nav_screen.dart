// // import 'package:flutter/material.dart';
// // import 'package:order_booking_app/Screens/HomeScreenComponents/timer_card.dart';
// // import 'role_home_selector.dart';
// //
// // class BottomNavScreen extends StatefulWidget {
// //   final String role;   // pass role from login
// //
// //   const BottomNavScreen({super.key, required this.role});
// //
// //   @override
// //   State<BottomNavScreen> createState() => _BottomNavScreenState();
// // }
// //
// // class _BottomNavScreenState extends State<BottomNavScreen> {
// //   int _currentIndex = 0;
// //
// //   late List<Widget> _screens;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _screens = [
// //       RoleHomeSelector(role: widget.role),   // 👈 Role based home
// //       TimerCard(),
// //     ];
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: _screens[_currentIndex],
// //
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: _currentIndex,
// //         onTap: (index) {
// //           setState(() {
// //             _currentIndex = index;
// //           });
// //         },
// //         items: const [
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.home),
// //             label: "Home",
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(Icons.route),
// //             label: "Route",
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:order_booking_app/Screens/HomeScreenComponents/timer_card.dart';
// import 'role_home_selector.dart';
//
// class BottomNavScreen extends StatefulWidget {
//   final String role;
//
//   const BottomNavScreen({super.key, required this.role});
//
//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }
//
// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _currentIndex = 0;
//
//   late final List<Widget> _screens;
//
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       RoleHomeSelector(role: widget.role),
//       TimerCard(),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       extendBody: true, // allow glass effect over body
//
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         child: _screens[_currentIndex],
//       ),
//
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//               child: Container(
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(.85),
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(.1),
//                       blurRadius: 25,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildItem(Icons.home_rounded, "Home", 0),
//                     _buildItem(Icons.route_rounded, "Route", 1),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildItem(IconData icon, String label, int index) {
//     final bool isActive = _currentIndex == index;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() => _currentIndex = index);
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.blue : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isActive ? Colors.white : Colors.grey.shade700,
//             ),
//             if (isActive) ...[
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
