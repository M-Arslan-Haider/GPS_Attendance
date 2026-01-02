// import 'package:flutter/material.dart';
//
// /// Action box widget with onTap functionality.
// class ActionBox extends StatelessWidget {
//   final String imagePath; // Path to the image (local or network)
//   final String label;
//   final VoidCallback onTap; // Callback for the tap event
//
//   const ActionBox({
//     super.key,
//     required this.imagePath,
//     required this.label,
//     required this.onTap, // Required parameter for tap functionality
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Adjust size based on content
//       children: [
//         GestureDetector(
//           onTap: onTap, // Calls the provided onTap function when tapped
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.4),
//                   spreadRadius: 2,
//                   blurRadius: 3,
//                 ),
//               ],
//             ),
//             child: imagePath.isNotEmpty
//                 ? Image.asset(  // Use Image.asset if you have a local image
//               imagePath,
//               width: 20,  // Set the desired size
//               height: 20,
//               fit: BoxFit.contain,
//             )
//                 : const Icon(Icons.image, color: Colors.black, size: 30),  // Fallback if no image is provided
//           ),
//         ),
//         const SizedBox(height: 8), // Space between the box and the label
//         Text(
//           label,
//           style: const TextStyle(color: Colors.black, fontSize: 10),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

/// Action box widget with onTap functionality.
class ActionBox extends StatelessWidget {
  final String imagePath; // Path to the image (local or network)
  final String label;
  final VoidCallback onTap; // Callback for the tap event

  const ActionBox({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap, // Required parameter for tap functionality
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Adjust size based on content
      children: [
        GestureDetector(
          onTap: onTap, // Calls the provided onTap function when tapped
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imagePath.isNotEmpty
                  ? Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain, // Fit image inside the box
              )
                  : const Icon(Icons.image, color: Colors.black, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8), // Space between the box and the label
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}