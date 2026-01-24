import 'package:flutter/material.dart';

// Option 1: Header as a separate widget class
class BookITHeader extends StatelessWidget {
  const BookITHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
          children: [
            // Logo
            Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text(
                'B',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Text Column (BookIT + Tagline)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Added this
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 0.0),
                  child: Text(
                    'BooKiT',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: Colors.black,
                    ),
                  ),
                ),

                // SizedBox(height: 2), // Reduced spacing

                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Book once. Anywhere.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 0.7,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}