// import 'package:flutter/material.dart';
//
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const CustomAppBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: const Text(
//         'Return Form',
//         style: TextStyle(color: Colors.white, fontSize: 24),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.blueGrey,
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Return Form',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,

      // 🔹 Back arrow color white
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
