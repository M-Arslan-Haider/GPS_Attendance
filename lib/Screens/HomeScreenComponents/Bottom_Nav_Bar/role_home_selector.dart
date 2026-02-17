// import 'package:flutter/material.dart';
// import '../../Dispatcher/dispatcher_homepage.dart';
// import '../../NSM/nsm_homepage.dart';
// import '../../RSMS_Views/RSM_HomePage.dart';
// import '../../SM/sm_homepage.dart';
// import '../../home_screen.dart';
//
// class RoleHomeSelector extends StatelessWidget {
//   final String role;   // NSM, RSM, SM
//
//   const RoleHomeSelector({super.key, required this.role});
//
//   @override
//   Widget build(BuildContext context) {
//     if (role == "NSM") {
//       return NSMHomepage();
//     } else if (role == "RSM") {
//       return RSMHomepage();
//     } else if (role == "SM") {
//       return SMHomepage();
//     } else if (role == "DISPATCHER") {
//       return DispatcherHomepage();
//     } else {
//       return HomeScreen();
//     }
//   }
// }