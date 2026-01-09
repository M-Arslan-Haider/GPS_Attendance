// // OFFLINE-FIRST STORAGE MANAGER (Add at top of TimerCard.dart or create new file)
// import 'dart:convert';
// import 'dart:typed_data';
// // Add this import at the TOP of the AttendanceStorageManager class
// import 'package:intl/intl.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AttendanceStorageManager {
//   // Keys for SharedPreferences
//   static const String _pendingAttendanceKey = 'pending_attendance_queue_v2';
//   static const String _attendanceSyncStatusKey = 'attendance_sync_status';
//   static const String _gpxDataKey = 'pending_gpx_data';
//   static const String _distanceDataKey = 'pending_distance_data';
//   static const String _syncLockKey = 'attendance_sync_lock';
//   static const String _lastSyncTimeKey = 'last_successful_sync';
//   static const String _failedAttemptsKey = 'failed_sync_attempts';
//
//   // Save ANY attendance action to SharedPreferences FIRST
//   static Future<void> saveAttendanceAction({
//     required String type, // 'clock_in' or 'clock_out'
//     required DateTime timestamp,
//     required Map<String, dynamic> data,
//     String? gpxFilePath,
//     Uint8List? gpxBytes,
//     double? distance,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Create comprehensive action data
//       Map<String, dynamic> actionData = {
//         'id': '${type}_${timestamp.millisecondsSinceEpoch}',
//         'type': type,
//         'timestamp': timestamp.toIso8601String(),
//         'data': data,
//         'createdAt': DateTime.now().toIso8601String(),
//         'attemptCount': 0,
//         'lastAttempt': null,
//         'status': 'pending',
//         'isSynced': false,
//         'retryCount': 0,
//         'maxRetries': 5, // Will retry 5 times before giving up
//       };
//
//       // Save GPX data if provided
//       if (gpxFilePath != null) {
//         actionData['gpxFilePath'] = gpxFilePath;
//       }
//
//       if (gpxBytes != null) {
//         actionData['gpxSize'] = gpxBytes.length;
//         // Save small GPX metadata, not the entire file
//         actionData['gpxMetadata'] = {
//           'hasGpx': true,
//           'size': gpxBytes.length,
//           'timestamp': timestamp.toIso8601String(),
//         };
//       }
//
//       if (distance != null) {
//         actionData['distance'] = distance;
//       }
//
//       // Get existing queue
//       List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//       // Add new action to queue
//       pendingQueue.add(json.encode(actionData));
//
//       // Save queue
//       await prefs.setStringList(_pendingAttendanceKey, pendingQueue);
//
//       // Save individual data for quick access
//       if (type == 'clock_in') {
//         await prefs.setString('last_clock_in_data', json.encode(data));
//         await prefs.setString('last_clock_in_time', timestamp.toIso8601String());
//       } else if (type == 'clock_out') {
//         await prefs.setString('last_clock_out_data', json.encode(data));
//         await prefs.setString('last_clock_out_time', timestamp.toIso8601String());
//       }
//
//       debugPrint("💾 [SHARED_PREFS] Saved $type action to local storage");
//       debugPrint("   - Queue size: ${pendingQueue.length}");
//       debugPrint("   - Time: ${DateFormat('HH:mm:ss').format(timestamp)}");
//
//     } catch (e) {
//       debugPrint("❌ [SHARED_PREFS] Error saving attendance: $e");
//     }
//   }
//
//   // Get all pending actions
//   static Future<List<Map<String, dynamic>>> getPendingActions() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//       return pendingQueue.map((jsonStr) {
//         return json.decode(jsonStr) as Map<String, dynamic>;
//       }).toList();
//     } catch (e) {
//       debugPrint("❌ Error getting pending actions: $e");
//       return [];
//     }
//   }
//
//   // Get unsynced actions
//   static Future<List<Map<String, dynamic>>> getUnsyncedActions() async {
//     final allActions = await getPendingActions();
//     return allActions.where((action) => action['isSynced'] != true).toList();
//   }
//
//   // Mark action as synced
//   static Future<void> markAsSynced(String actionId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//       List<String> updatedQueue = [];
//
//       for (String jsonStr in pendingQueue) {
//         final action = json.decode(jsonStr) as Map<String, dynamic>;
//
//         if (action['id'] == actionId) {
//           // Update action
//           action['isSynced'] = true;
//           action['syncedAt'] = DateTime.now().toIso8601String();
//           action['status'] = 'synced';
//           updatedQueue.add(json.encode(action));
//           debugPrint("✅ [SHARED_PREFS] Marked $actionId as synced");
//         } else {
//           updatedQueue.add(jsonStr);
//         }
//       }
//
//       await prefs.setStringList(_pendingAttendanceKey, updatedQueue);
//
//       // Update last sync time
//       await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
//
//     } catch (e) {
//       debugPrint("❌ Error marking as synced: $e");
//     }
//   }
//
//   // Update attempt count
//   static Future<void> updateAttemptCount(String actionId, bool success) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//       List<String> updatedQueue = [];
//
//       for (String jsonStr in pendingQueue) {
//         final action = json.decode(jsonStr) as Map<String, dynamic>;
//
//         if (action['id'] == actionId) {
//           if (success) {
//             action['isSynced'] = true;
//             action['syncedAt'] = DateTime.now().toIso8601String();
//             action['status'] = 'synced';
//           } else {
//             int attemptCount = (action['attemptCount'] ?? 0) + 1;
//             action['attemptCount'] = attemptCount;
//             action['lastAttempt'] = DateTime.now().toIso8601String();
//
//             if (attemptCount >= (action['maxRetries'] ?? 5)) {
//               action['status'] = 'failed';
//               debugPrint("⚠️ [SHARED_PREFS] Action $actionId failed after max retries");
//             }
//           }
//           updatedQueue.add(json.encode(action));
//         } else {
//           updatedQueue.add(jsonStr);
//         }
//       }
//
//       await prefs.setStringList(_pendingAttendanceKey, updatedQueue);
//
//     } catch (e) {
//       debugPrint("❌ Error updating attempt count: $e");
//     }
//   }
//
//   // Remove old synced actions (cleanup)
//   static Future<void> cleanupOldActions() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//       final now = DateTime.now();
//       List<String> updatedQueue = [];
//
//       for (String jsonStr in pendingQueue) {
//         final action = json.decode(jsonStr) as Map<String, dynamic>;
//
//         // Keep if:
//         // 1. Not synced yet
//         // 2. Synced within last 7 days
//         // 3. Created within last 30 days
//
//         final createdAt = DateTime.parse(action['createdAt']);
//         final isSynced = action['isSynced'] == true;
//         final syncedAt = action['syncedAt'] != null
//             ? DateTime.parse(action['syncedAt'])
//             : null;
//
//         bool shouldKeep = true;
//
//         if (!isSynced) {
//           // Keep unsynced items for up to 30 days
//           shouldKeep = now.difference(createdAt).inDays < 30;
//         } else if (syncedAt != null) {
//           // Keep synced items for 7 days
//           shouldKeep = now.difference(syncedAt).inDays < 7;
//         }
//
//         if (shouldKeep) {
//           updatedQueue.add(jsonStr);
//         }
//       }
//
//       if (updatedQueue.length != pendingQueue.length) {
//         await prefs.setStringList(_pendingAttendanceKey, updatedQueue);
//         debugPrint("🧹 [SHARED_PREFS] Cleaned up ${pendingQueue.length - updatedQueue.length} old actions");
//       }
//
//     } catch (e) {
//       debugPrint("❌ Error cleaning up old actions: $e");
//     }
//   }
//
//   // Check if sync is in progress
//   static Future<bool> isSyncInProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_syncLockKey) ?? false;
//   }
//
//   // Set sync lock
//   static Future<void> setSyncLock(bool locked) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_syncLockKey, locked);
//   }
//
//   // Get sync statistics
//   static Future<Map<String, dynamic>> getSyncStats() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> pendingQueue = prefs.getStringList(_pendingAttendanceKey) ?? [];
//
//     int pending = 0;
//     int synced = 0;
//     int failed = 0;
//
//     for (String jsonStr in pendingQueue) {
//       final action = json.decode(jsonStr) as Map<String, dynamic>;
//       if (action['isSynced'] == true) {
//         synced++;
//       } else if (action['status'] == 'failed') {
//         failed++;
//       } else {
//         pending++;
//       }
//     }
//
//     return {
//       'total': pendingQueue.length,
//       'pending': pending,
//       'synced': synced,
//       'failed': failed,
//       'lastSync': prefs.getString(_lastSyncTimeKey),
//     };
//   }
//
//   // Emergency save - for when app is closing
//   static Future<void> emergencySave(Map<String, dynamic> data) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('emergency_attendance_data', json.encode(data));
//       await prefs.setString('emergency_save_time', DateTime.now().toIso8601String());
//       debugPrint("🚨 [SHARED_PREFS] Emergency save completed");
//     } catch (e) {
//       debugPrint("❌ Emergency save failed: $e");
//     }
//   }
//
//   // Check for emergency data on app start
//   static Future<Map<String, dynamic>?> getEmergencyData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? emergencyData = prefs.getString('emergency_attendance_data');
//
//       if (emergencyData != null) {
//         debugPrint("🚨 [SHARED_PREFS] Found emergency data from last session");
//         final data = json.decode(emergencyData) as Map<String, dynamic>;
//
//         // Clear emergency data after reading
//         await prefs.remove('emergency_attendance_data');
//
//         return data;
//       }
//     } catch (e) {
//       debugPrint("❌ Error reading emergency data: $e");
//     }
//     return null;
//   }
// }