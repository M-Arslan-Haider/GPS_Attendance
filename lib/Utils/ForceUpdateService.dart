import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  static Future<void> check(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final newVersion = NewVersionPlus(
      androidId: "com.metaxperts.order_booking_app",
    );

    try {
      final status = await newVersion.getVersionStatus();

      if (status != null && status.canUpdate) {
        _showDialog(context, status.appStoreLink);
      }
    } catch (e) {
      debugPrint("Version check failed: $e");
    }
  }

  static void _showDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false, // ❌ can't close
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // ❌ back button blocked
        child: AlertDialog(
          title: const Text("Update Required"),
          content: const Text(
            "A new version is available. You must update to continue using this app.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text("UPDATE"),
            ),
          ],
        ),
      ),
    );
  }
}
