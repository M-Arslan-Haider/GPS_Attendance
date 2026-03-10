// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:intl/intl.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Database/db_helper.dart';
// // import '../Database/util.dart';
// // import '../models/attendance_model.dart';
// // import '../../constants.dart';
// //
// // class AttendanceRepository {
// //   final DBHelper dbHelper = DBHelper();
// //
// //   // ✅ Track posted IDs in session to prevent duplicates
// //   final Set<String> _postedIds = {};
// //
// //   // Get all attendance records
// //   Future<List<AttendanceModel>> getAttendance() async {
// //     final db = await dbHelper.db;
// //     final List<Map<String, dynamic>> maps = await db.query(
// //       attendanceTableName,
// //       orderBy: 'attendance_in_date DESC',
// //     );
// //
// //     debugPrint('📊 [REPO-IN] Raw data from Attendance database: ${maps.length} records');
// //     for (var map in maps) {
// //       debugPrint("   - ID: ${map['attendance_in_id']}, Posted: ${map['posted']}");
// //     }
// //
// //     return List.generate(maps.length, (i) {
// //       return AttendanceModel.fromMap(maps[i]);
// //     });
// //   }
// //
// //   // Fetch from API and save locally
// //   Future<void> fetchAndSaveAttendance() async {
// //     try {
// //       debugPrint('🔍 [REPO-IN] Fetching attendance from API...');
// //       final response = await http.get(
// //         Uri.parse('$attendanceInApi$emp_id'),
// //         headers: {'Content-Type': 'application/json'},
// //       ).timeout(const Duration(seconds: 15));
// //
// //       if (response.statusCode == 200) {
// //         final List<dynamic> data = jsonDecode(response.body);
// //         final db = await dbHelper.db;
// //
// //         int savedCount = 0;
// //         for (var item in data) {
// //           try {
// //             item['posted'] = 1;
// //             AttendanceModel model = AttendanceModel.fromMap(item);
// //
// //             final existing = await db.query(
// //               attendanceTableName,
// //               where: 'attendance_in_id = ?',
// //               whereArgs: [model.attendance_in_id],
// //             );
// //
// //             if (existing.isEmpty) {
// //               await db.insert(attendanceTableName, model.toMap());
// //               savedCount++;
// //               debugPrint("✅ [REPO-IN] Saved from API: ${model.attendance_in_id}");
// //             } else {
// //               debugPrint("⚠️ [REPO-IN] Skipping duplicate from API: ${model.attendance_in_id}");
// //             }
// //           } catch (e) {
// //             debugPrint("❌ [REPO-IN] Error saving item: $e");
// //           }
// //         }
// //         debugPrint("✅ [REPO-IN] Fetched and saved $savedCount records from API");
// //       }
// //     } catch (e) {
// //       debugPrint('❌ [REPO-IN] Error fetching from API: $e');
// //     }
// //   }
// //
// //   // Get unposted attendance records
// //   Future<List<AttendanceModel>> getUnPostedAttendance() async {
// //     try {
// //       final db = await dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         attendanceTableName,
// //         where: 'posted = ?',
// //         whereArgs: [0],
// //       );
// //
// //       debugPrint('📊 [REPO-IN] Found ${maps.length} unposted records');
// //
// //       return List.generate(maps.length, (i) {
// //         return AttendanceModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ [REPO-IN] Error getting unposted records: $e');
// //       return [];
// //     }
// //   }
// //
// //   // Add attendance record
// //   Future<int> addAttendance(AttendanceModel attendance) async {
// //     try {
// //       final db = await dbHelper.db;
// //       attendance.posted = 0;
// //
// //       // Check if already exists
// //       final existing = await db.query(
// //         attendanceTableName,
// //         where: 'attendance_in_id = ?',
// //         whereArgs: [attendance.attendance_in_id],
// //       );
// //
// //       if (existing.isNotEmpty) {
// //         debugPrint('⚠️ [REPO-IN] Duplicate record found, skipping: ${attendance.attendance_in_id}');
// //         return 0;
// //       }
// //
// //       debugPrint('✅ [REPO-IN] Adding new record: ${attendance.attendance_in_id}');
// //       return await db.insert(attendanceTableName, attendance.toMap());
// //     } catch (e) {
// //       debugPrint('❌ [REPO-IN] Error adding record: $e');
// //       return -1;
// //     }
// //   }
// //
// //   // Update attendance record
// //   Future<int> updateAttendance(AttendanceModel attendance) async {
// //     try {
// //       final db = await dbHelper.db;
// //       debugPrint('✏️ [REPO-IN] Updating record: ${attendance.attendance_in_id}');
// //       return await db.update(
// //         attendanceTableName,
// //         attendance.toMap(),
// //         where: 'attendance_in_id = ?',
// //         whereArgs: [attendance.attendance_in_id],
// //       );
// //     } catch (e) {
// //       debugPrint('❌ [REPO-IN] Error updating record: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // Mark as posted
// //   Future<void> markAsPosted(String id) async {
// //     try {
// //       final db = await dbHelper.db;
// //       await db.update(
// //         attendanceTableName,
// //         {'posted': 1},
// //         where: 'attendance_in_id = ?',
// //         whereArgs: [id],
// //       );
// //       debugPrint('✅ [REPO-IN] Marked as posted: $id');
// //     } catch (e) {
// //       debugPrint('❌ [REPO-IN] Error marking as posted: $e');
// //     }
// //   }
// //
// //   // Post single record to API with retry logic
// //   Future<bool> postToAPI(AttendanceModel attendance) async {
// //     const int maxRetries = 2;
// //
// //     for (int attempt = 1; attempt <= maxRetries; attempt++) {
// //       try {
// //         debugPrint('🌐 [REPO-IN] Attempt $attempt: Posting ${attendance.attendance_in_id}');
// //
// //         final response = await http.post(
// //           Uri.parse('$attendanceInApi$emp_id'),
// //           headers: {
// //             'Content-Type': 'application/json',
// //             'Accept': 'application/json',
// //           },
// //           body: jsonEncode(attendance.toJson()),
// //         ).timeout(const Duration(seconds: 15));
// //
// //         debugPrint('📡 [REPO-IN] Response: ${response.statusCode}');
// //
// //         if (response.statusCode == 200 || response.statusCode == 201) {
// //           await markAsPosted(attendance.attendance_in_id!);
// //           return true;
// //         } else {
// //           debugPrint('❌ Server error ${response.statusCode}: ${response.body}');
// //         }
// //       } catch (e) {
// //         debugPrint('❌ Attempt $attempt failed: $e');
// //       }
// //     }
// //
// //     return false;
// //   }
// //
// //   // Sync all unposted records
// //   Future<void> syncUnposted() async {
// //     debugPrint('🔄 [REPO-IN] ===== STARTING SYNC =====');
// //
// //     if (!await isNetworkAvailable()) {
// //       debugPrint('📴 [REPO-IN] No internet connection. Skipping sync.');
// //       return;
// //     }
// //
// //     final unposted = await getUnPostedAttendance();
// //
// //     if (unposted.isEmpty) {
// //       debugPrint('📭 [REPO-IN] No unposted attendance records');
// //       return;
// //     }
// //
// //     debugPrint('🔄 [REPO-IN] Syncing ${unposted.length} attendance records');
// //
// //     // Deduplicate before posting
// //     final Map<String, AttendanceModel> uniqueRecords = {};
// //     for (var record in unposted) {
// //       if (record.attendance_in_id != null) {
// //         uniqueRecords[record.attendance_in_id.toString()] = record;
// //       }
// //     }
// //
// //     int successCount = 0;
// //     int failCount = 0;
// //
// //     for (var record in uniqueRecords.values) {
// //       // Skip if already posted in this session
// //       if (_postedIds.contains(record.attendance_in_id.toString())) {
// //         debugPrint('⚠️ [REPO-IN] Skipping already posted in session: ${record.attendance_in_id}');
// //         continue;
// //       }
// //
// //       final posted = await postToAPI(record);
// //       if (posted) {
// //         successCount++;
// //       } else {
// //         failCount++;
// //       }
// //
// //       await Future.delayed(const Duration(milliseconds: 500));
// //     }
// //
// //     debugPrint('📊 [REPO-IN] Sync results: $successCount success, $failCount failed');
// //     debugPrint('🔄 [REPO-IN] ===== SYNC COMPLETED =====');
// //   }
// //
// //   // Delete record
// //   Future<int> delete(String id) async {
// //     final db = await dbHelper.db;
// //     debugPrint('🗑️ [REPO-IN] Deleting record: $id');
// //     return await db.delete(
// //       attendanceTableName,
// //       where: 'attendance_in_id = ?',
// //       whereArgs: [id],
// //     );
// //   }
// //
// //   // Generate unique attendance ID
// //   Future<String> generateAttendanceId() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     int counter = prefs.getInt('attendanceInCounter') ?? 1;
// //
// //     final now = DateTime.now();
// //     final month = DateFormat('MMM').format(now);
// //     final day = DateFormat('dd').format(now);
// //
// //     String id = "ATD-$emp_id-$day-$month-${counter.toString().padLeft(3, '0')}";
// //
// //     await prefs.setInt('attendanceInCounter', counter + 1);
// //     debugPrint('🔢 [REPO-IN] Generated ID: $id');
// //     return id;
// //   }
// //
// //   // Clear posted cache
// //   void clearPostedCache() {
// //     _postedIds.clear();
// //     debugPrint('🧹 [REPO-IN] Cleared posted IDs cache');
// //   }
// // }
//
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Database/db_helper.dart';
// import '../Database/util.dart';
// import '../models/attendance_model.dart';
// import '../../constants.dart';
//
// class AttendanceRepository {
//   final DBHelper dbHelper = DBHelper();
//
//   // ✅ Track posted IDs in session to prevent duplicates
//   final Set<String> _postedIds = {};
//
//   // ✅ FIX: Removed trailing space - verify this endpoint with your backend
//   // Common ORDS patterns: /ords/{schema}/{object}/{method}
//   static const String _attendanceInApi = 'http://oracle.metaxperts.net/ords/production/attendanceinpost/post';
//
//   // Get all attendance records
//   Future<List<AttendanceModel>> getAttendance() async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceTableName,
//         orderBy: 'attendance_in_date DESC',
//       );
//
//       debugPrint('📊 [REPO-IN] Raw data from Attendance database: ${maps.length} records');
//       for (var map in maps) {
//         debugPrint("   - ID: ${map['attendance_in_id']}, Posted: ${map['posted']}");
//       }
//
//       return List.generate(maps.length, (i) {
//         return AttendanceModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error getting attendance: $e');
//       return [];
//     }
//   }
//
//   // Fetch from API and save locally
//   Future<void> fetchAndSaveAttendance() async {
//     try {
//       debugPrint('🔍 [REPO-IN] Fetching attendance from API...');
//       // ✅ FIX: Removed trailing space
//       final url = 'http://oracle.metaxperts.net/ords/production/attendancein/get/$emp_id';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         final db = await dbHelper.db;
//
//         int savedCount = 0;
//         for (var item in data) {
//           try {
//             item['posted'] = 1;
//             AttendanceModel model = AttendanceModel.fromMap(item);
//
//             final existing = await db.query(
//               attendanceTableName,
//               where: 'attendance_in_id = ?',
//               whereArgs: [model.attendance_in_id],
//             );
//
//             if (existing.isEmpty) {
//               await db.insert(attendanceTableName, model.toMap());
//               savedCount++;
//               debugPrint("✅ [REPO-IN] Saved from API: ${model.attendance_in_id}");
//             } else {
//               debugPrint("⚠️ [REPO-IN] Skipping duplicate from API: ${model.attendance_in_id}");
//             }
//           } catch (e) {
//             debugPrint("❌ [REPO-IN] Error saving item: $e");
//           }
//         }
//         debugPrint("✅ [REPO-IN] Fetched and saved $savedCount records from API");
//       } else {
//         debugPrint('❌ [REPO-IN] API fetch failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error fetching from API: $e');
//     }
//   }
//
//   // Get unposted attendance records
//   Future<List<AttendanceModel>> getUnPostedAttendance() async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceTableName,
//         where: 'posted = ?',
//         whereArgs: [0],
//       );
//
//       debugPrint('📊 [REPO-IN] Found ${maps.length} unposted records');
//
//       return List.generate(maps.length, (i) {
//         return AttendanceModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error getting unposted records: $e');
//       return [];
//     }
//   }
//
//   // ✅ ENHANCED: Add attendance record with database health check
//   Future<int> addAttendance(AttendanceModel attendance) async {
//     try {
//       // Ensure database is writable
//       if (!await ensureDatabaseWritable()) {
//         debugPrint('❌ [REPO-IN] Database not writable, cannot add record');
//         return -1;
//       }
//
//       final db = await dbHelper.db;
//       attendance.posted = 0;
//
//       // Check if already exists
//       final existing = await db.query(
//         attendanceTableName,
//         where: 'attendance_in_id = ?',
//         whereArgs: [attendance.attendance_in_id],
//       );
//
//       if (existing.isNotEmpty) {
//         debugPrint('⚠️ [REPO-IN] Duplicate record found, skipping: ${attendance.attendance_in_id}');
//         return 0;
//       }
//
//       debugPrint('✅ [REPO-IN] Adding new record: ${attendance.attendance_in_id}');
//       final result = await db.insert(attendanceTableName, attendance.toMap());
//       debugPrint('✅ [REPO-IN] Insert successful with result: $result');
//       return result;
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error adding record: $e');
//       return -1;
//     }
//   }
//
//   // Update attendance record
//   Future<int> updateAttendance(AttendanceModel attendance) async {
//     try {
//       final db = await dbHelper.db;
//       debugPrint('✏️ [REPO-IN] Updating record: ${attendance.attendance_in_id}');
//       return await db.update(
//         attendanceTableName,
//         attendance.toMap(),
//         where: 'attendance_in_id = ?',
//         whereArgs: [attendance.attendance_in_id],
//       );
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error updating record: $e');
//       rethrow;
//     }
//   }
//
//   // Mark as posted
//   Future<void> markAsPosted(String id) async {
//     try {
//       final db = await dbHelper.db;
//       await db.update(
//         attendanceTableName,
//         {'posted': 1},
//         where: 'attendance_in_id = ?',
//         whereArgs: [id],
//       );
//       _postedIds.add(id);
//       debugPrint('✅ [REPO-IN] Marked as posted: $id');
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error marking as posted: $e');
//     }
//   }
//
//   // Post single record to API with retry logic
//   Future<bool> postToAPI(AttendanceModel attendance) async {
//     const int maxRetries = 2;
//
//     for (int attempt = 1; attempt <= maxRetries; attempt++) {
//       try {
//         debugPrint('🌐 [REPO-IN] Attempt $attempt: Posting ${attendance.attendance_in_id} to $_attendanceInApi');
//
//         // ✅ FIX: Ensure proper JSON serialization
//         final jsonBody = jsonEncode(attendance.toJson());
//         debugPrint('📤 [REPO-IN] Request body: $jsonBody');
//
//         final response = await http.post(
//           Uri.parse(_attendanceInApi),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonBody,
//         ).timeout(const Duration(seconds: 15));
//
//         debugPrint('📡 [REPO-IN] Response: ${response.statusCode}');
//         debugPrint('📡 [REPO-IN] Response body: ${response.body}');
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           await markAsPosted(attendance.attendance_in_id!);
//           return true;
//         } else if (response.statusCode == 405) {
//           debugPrint('❌ [REPO-IN] HTTP 405: Method Not Allowed - Check API endpoint URL');
//           debugPrint('❌ [REPO-IN] Current endpoint: $_attendanceInApi');
//           // Don't retry on 405, it's a configuration error
//           return false;
//         } else {
//           debugPrint('❌ Server error ${response.statusCode}: ${response.body}');
//         }
//       } catch (e) {
//         debugPrint('❌ Attempt $attempt failed: $e');
//       }
//     }
//
//     return false;
//   }
//
//   // Sync all unposted records
//   Future<void> syncUnposted() async {
//     debugPrint('🔄 [REPO-IN] ===== STARTING SYNC =====');
//
//     if (!await isNetworkAvailable()) {
//       debugPrint('📴 [REPO-IN] No internet connection. Skipping sync.');
//       return;
//     }
//
//     final unposted = await getUnPostedAttendance();
//
//     if (unposted.isEmpty) {
//       debugPrint('📭 [REPO-IN] No unposted attendance records');
//       return;
//     }
//
//     debugPrint('🔄 [REPO-IN] Syncing ${unposted.length} attendance records');
//
//     // Deduplicate before posting
//     final Map<String, AttendanceModel> uniqueRecords = {};
//     for (var record in unposted) {
//       if (record.attendance_in_id != null) {
//         uniqueRecords[record.attendance_in_id.toString()] = record;
//       }
//     }
//
//     int successCount = 0;
//     int failCount = 0;
//
//     for (var record in uniqueRecords.values) {
//       // Skip if already posted in this session
//       if (_postedIds.contains(record.attendance_in_id.toString())) {
//         debugPrint('⚠️ [REPO-IN] Skipping already posted in session: ${record.attendance_in_id}');
//         continue;
//       }
//
//       final posted = await postToAPI(record);
//       if (posted) {
//         successCount++;
//         _postedIds.add(record.attendance_in_id.toString());
//       } else {
//         failCount++;
//       }
//
//       await Future.delayed(const Duration(milliseconds: 500));
//     }
//
//     debugPrint('📊 [REPO-IN] Sync results: $successCount success, $failCount failed');
//     debugPrint('🔄 [REPO-IN] ===== SYNC COMPLETED =====');
//   }
//
//   // Delete record
//   Future<int> delete(String id) async {
//     try {
//       final db = await dbHelper.db;
//       debugPrint('🗑️ [REPO-IN] Deleting record: $id');
//       return await db.delete(
//         attendanceTableName,
//         where: 'attendance_in_id = ?',
//         whereArgs: [id],
//       );
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error deleting record: $e');
//       return -1;
//     }
//   }
//
//   // Generate unique attendance ID
//   Future<String> generateAttendanceId() async {
//     final prefs = await SharedPreferences.getInstance();
//     int counter = prefs.getInt('attendanceInCounter') ?? 1;
//
//     final now = DateTime.now();
//     final month = DateFormat('MMM').format(now);
//     final day = DateFormat('dd').format(now);
//
//     String id = "ATD-$emp_id-$day-$month-${counter.toString().padLeft(3, '0')}";
//
//     await prefs.setInt('attendanceInCounter', counter + 1);
//     debugPrint('🔢 [REPO-IN] Generated ID: $id');
//     return id;
//   }
//
//   // Clear posted cache
//   void clearPostedCache() {
//     _postedIds.clear();
//     debugPrint('🧹 [REPO-IN] Cleared posted IDs cache');
//   }
//
//   // Get record by ID
//   Future<AttendanceModel?> getRecordById(String id) async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceTableName,
//         where: 'attendance_in_id = ?',
//         whereArgs: [id],
//       );
//
//       if (maps.isNotEmpty) {
//         return AttendanceModel.fromMap(maps.first);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Error getting record by ID: $e');
//       return null;
//     }
//   }
//
//   // ✅ Database health check method
//   Future<bool> ensureDatabaseWritable() async {
//     try {
//       final isHealthy = await dbHelper.isDatabaseHealthy();
//       if (!isHealthy) {
//         debugPrint('⚠️ [REPO-IN] Database unhealthy, attempting repair...');
//         final repaired = await dbHelper.repairDatabase();
//         if (!repaired) {
//           debugPrint('❌ [REPO-IN] Database repair failed');
//           return false;
//         }
//       }
//       return true;
//     } catch (e) {
//       debugPrint('❌ [REPO-IN] Database check failed: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../models/attendance_model.dart';
import '../../constants.dart';

class AttendanceRepository {
  final DBHelper dbHelper = DBHelper();

  // ✅ Track posted IDs in session to prevent duplicates
  final Set<String> _postedIds = {};

  // ✅ FIX: Standard ORDS REST endpoint pattern
  // Try these in order:
  // 1. 'http://oracle.metaxperts.net/ords/production/attendancein' (most common)
  // 2. 'http://oracle.metaxperts.net/ords/production/attendancein/'
  // 3. 'http://oracle.metaxperts.net/ords/production/attendance/in'
  static const String _attendanceInApi = 'http://oracle.metaxperts.net/ords/production/attendanceinpost/post/';

  // Get all attendance records
  Future<List<AttendanceModel>> getAttendance() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceTableName,
        orderBy: 'attendance_in_date DESC',
      );

      debugPrint('📊 [REPO-IN] Raw data from Attendance database: ${maps.length} records');
      for (var map in maps) {
        debugPrint("   - ID: ${map['attendance_in_id']}, Posted: ${map['posted']}");
      }

      return List.generate(maps.length, (i) {
        return AttendanceModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error getting attendance: $e');
      return [];
    }
  }

  // Fetch from API and save locally
  Future<void> fetchAndSaveAttendance() async {
    try {
      debugPrint('🔍 [REPO-IN] Fetching attendance from API...');
      final url = '$_attendanceInApi/$emp_id';

      debugPrint('🌐 [REPO-IN] GET URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await dbHelper.db;

        int savedCount = 0;
        for (var item in data) {
          try {
            item['posted'] = 1;
            AttendanceModel model = AttendanceModel.fromMap(item);

            final existing = await db.query(
              attendanceTableName,
              where: 'attendance_in_id = ?',
              whereArgs: [model.attendance_in_id],
            );

            if (existing.isEmpty) {
              await db.insert(attendanceTableName, model.toMap());
              savedCount++;
              debugPrint("✅ [REPO-IN] Saved from API: ${model.attendance_in_id}");
            } else {
              debugPrint("⚠️ [REPO-IN] Skipping duplicate from API: ${model.attendance_in_id}");
            }
          } catch (e) {
            debugPrint("❌ [REPO-IN] Error saving item: $e");
          }
        }
        debugPrint("✅ [REPO-IN] Fetched and saved $savedCount records from API");
      } else {
        debugPrint('❌ [REPO-IN] API fetch failed with status: ${response.statusCode}');
        debugPrint('❌ [REPO-IN] Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error fetching from API: $e');
    }
  }

  // Get unposted attendance records
  Future<List<AttendanceModel>> getUnPostedAttendance() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceTableName,
        where: 'posted = ?',
        whereArgs: [0],
      );

      debugPrint('📊 [REPO-IN] Found ${maps.length} unposted records');

      return List.generate(maps.length, (i) {
        return AttendanceModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error getting unposted records: $e');
      return [];
    }
  }

  // ✅ ENHANCED: Add attendance record with database health check
  Future<int> addAttendance(AttendanceModel attendance) async {
    try {
      // Ensure database is writable
      if (!await ensureDatabaseWritable()) {
        debugPrint('❌ [REPO-IN] Database not writable, cannot add record');
        return -1;
      }

      final db = await dbHelper.db;
      attendance.posted = 0;

      // Check if already exists
      final existing = await db.query(
        attendanceTableName,
        where: 'attendance_in_id = ?',
        whereArgs: [attendance.attendance_in_id],
      );

      if (existing.isNotEmpty) {
        debugPrint('⚠️ [REPO-IN] Duplicate record found, skipping: ${attendance.attendance_in_id}');
        return 0;
      }

      debugPrint('✅ [REPO-IN] Adding new record: ${attendance.attendance_in_id}');
      final result = await db.insert(attendanceTableName, attendance.toMap());
      debugPrint('✅ [REPO-IN] Insert successful with result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error adding record: $e');
      return -1;
    }
  }

  // Update attendance record
  Future<int> updateAttendance(AttendanceModel attendance) async {
    try {
      final db = await dbHelper.db;
      debugPrint('✏️ [REPO-IN] Updating record: ${attendance.attendance_in_id}');
      return await db.update(
        attendanceTableName,
        attendance.toMap(),
        where: 'attendance_in_id = ?',
        whereArgs: [attendance.attendance_in_id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error updating record: $e');
      rethrow;
    }
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    try {
      final db = await dbHelper.db;
      await db.update(
        attendanceTableName,
        {'posted': 1},
        where: 'attendance_in_id = ?',
        whereArgs: [id],
      );
      _postedIds.add(id);
      debugPrint('✅ [REPO-IN] Marked as posted: $id');
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error marking as posted: $e');
    }
  }

  // ✅ FIX: Post single record to API with CORRECT field mapping
  Future<bool> postToAPI(AttendanceModel attendance) async {
    const int maxRetries = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🌐 [REPO-IN] Attempt $attempt: Posting ${attendance.attendance_in_id}');
        debugPrint('🌐 [REPO-IN] URL: $_attendanceInApi');

        // ✅ Build JSON payload matching server-side PL/SQL parameter names
        final Map<String, dynamic> apiPayload = attendance.toJson();

        final jsonBody = jsonEncode(apiPayload);
        debugPrint('📤 [REPO-IN] Request body: $jsonBody');

        final response = await http.post(
          Uri.parse(_attendanceInApi),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonBody,
        ).timeout(const Duration(seconds: 15));

        debugPrint('📡 [REPO-IN] Response Status: ${response.statusCode}');
        debugPrint('📡 [REPO-IN] Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          await markAsPosted(attendance.attendance_in_id!);
          debugPrint('✅ [REPO-IN] Successfully posted to API');
          return true;
        } else if (response.statusCode == 404) {
          debugPrint('❌ [REPO-IN] HTTP 404: Endpoint not found');
          debugPrint('❌ [REPO-IN] Current URL: $_attendanceInApi');
          debugPrint('❌ [REPO-IN] Trying with trailing slash...');

          // Try with trailing slash
          final response2 = await http.post(
            Uri.parse('$_attendanceInApi/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonBody,
          ).timeout(const Duration(seconds: 15));

          if (response2.statusCode == 200 || response2.statusCode == 201) {
            await markAsPosted(attendance.attendance_in_id!);
            debugPrint('✅ [REPO-IN] Success with trailing slash!');
            return true;
          }
          return false;
        } else if (response.statusCode == 400) {
          debugPrint('❌ [REPO-IN] HTTP 400: Bad Request - Check field names match PL/SQL parameters');
          debugPrint('❌ [REPO-IN] Expected: id, date, timeIn, userId, latIn, lngIn, bookerName, city, designation');
          return false;
        } else if (response.statusCode == 405) {
          debugPrint('❌ [REPO-IN] HTTP 405: Method Not Allowed');
          return false;
        } else {
          debugPrint('❌ [REPO-IN] Server error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('❌ [REPO-IN] Attempt $attempt failed: $e');
      }
    }

    return false;
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    debugPrint('🔄 [REPO-IN] ===== STARTING SYNC =====');

    if (!await isNetworkAvailable()) {
      debugPrint('📴 [REPO-IN] No internet connection. Skipping sync.');
      return;
    }

    final unposted = await getUnPostedAttendance();

    if (unposted.isEmpty) {
      debugPrint('📭 [REPO-IN] No unposted attendance records');
      return;
    }

    debugPrint('🔄 [REPO-IN] Syncing ${unposted.length} attendance records');

    // Deduplicate before posting
    final Map<String, AttendanceModel> uniqueRecords = {};
    for (var record in unposted) {
      if (record.attendance_in_id != null) {
        uniqueRecords[record.attendance_in_id.toString()] = record;
      }
    }

    int successCount = 0;
    int failCount = 0;

    for (var record in uniqueRecords.values) {
      // Skip if already posted in this session
      if (_postedIds.contains(record.attendance_in_id.toString())) {
        debugPrint('⚠️ [REPO-IN] Skipping already posted in session: ${record.attendance_in_id}');
        continue;
      }

      final posted = await postToAPI(record);
      if (posted) {
        successCount++;
        _postedIds.add(record.attendance_in_id.toString());
      } else {
        failCount++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint('📊 [REPO-IN] Sync results: $successCount success, $failCount failed');
    debugPrint('🔄 [REPO-IN] ===== SYNC COMPLETED =====');
  }

  // Delete record
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.db;
      debugPrint('🗑️ [REPO-IN] Deleting record: $id');
      return await db.delete(
        attendanceTableName,
        where: 'attendance_in_id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error deleting record: $e');
      return -1;
    }
  }

  // Generate unique attendance ID
  Future<String> generateAttendanceId() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('attendanceInCounter') ?? 1;

    final now = DateTime.now();
    final month = DateFormat('MMM').format(now);
    final day = DateFormat('dd').format(now);

    String id = "ATD-$emp_id-$day-$month-${counter.toString().padLeft(3, '0')}";

    await prefs.setInt('attendanceInCounter', counter + 1);
    debugPrint('🔢 [REPO-IN] Generated ID: $id');
    return id;
  }

  // Clear posted cache
  void clearPostedCache() {
    _postedIds.clear();
    debugPrint('🧹 [REPO-IN] Cleared posted IDs cache');
  }

  // Get record by ID
  Future<AttendanceModel?> getRecordById(String id) async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceTableName,
        where: 'attendance_in_id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return AttendanceModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [REPO-IN] Error getting record by ID: $e');
      return null;
    }
  }

  // ✅ Database health check method
  Future<bool> ensureDatabaseWritable() async {
    try {
      final isHealthy = await dbHelper.isDatabaseHealthy();
      if (!isHealthy) {
        debugPrint('⚠️ [REPO-IN] Database unhealthy, attempting repair...');
        final repaired = await dbHelper.repairDatabase();
        if (!repaired) {
          debugPrint('❌ [REPO-IN] Database repair failed');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('❌ [REPO-IN] Database check failed: $e');
      return false;
    }
  }
}