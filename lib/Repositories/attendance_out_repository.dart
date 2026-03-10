// // //
// // // import 'dart:convert';
// // // import 'package:http/http.dart' as http;
// // // import 'package:flutter/foundation.dart';
// // // import 'package:intl/intl.dart';
// // // import '../Database/db_helper.dart';
// // // import '../Database/util.dart';
// // // import '../Models/attendanceOut_model.dart';
// // // import '../../constants.dart';
// // //
// // // class AttendanceOutRepository {
// // //   final DBHelper dbHelper = DBHelper();
// // //
// // //   // ✅ Track posted IDs in session to prevent duplicate posting
// // //   final Set<String> _postedIds = {};
// // //
// // //   // ✅ Correct API endpoint for attendance OUT
// // //   static const String _attendanceOutApi = 'http://oracle.metaxperts.net/ords/production/attendanceout/post/';
// // //
// // //   // Get all attendance out records
// // //   Future<List<AttendanceOutModel>> getAttendanceOut() async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       final List<Map<String, dynamic>> maps = await db.query(
// // //         attendanceOutTableName,
// // //         orderBy: 'attendance_out_date DESC',
// // //       );
// // //
// // //       debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');
// // //       for (var map in maps) {
// // //         debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
// // //       }
// // //
// // //       return List.generate(maps.length, (i) {
// // //         return AttendanceOutModel.fromMap(maps[i]);
// // //       });
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error getting attendance out: $e');
// // //       return [];
// // //     }
// // //   }
// // //
// // //   // Fetch from API and save locally
// // //   Future<void> fetchAndSaveAttendanceOut() async {
// // //     try {
// // //       debugPrint('🔍 [REPO-OUT] Fetching attendance out from API...');
// // //       final response = await http.get(
// // //         Uri.parse('http://oracle.metaxperts.net/ords/production/attendanceout/get/$emp_id'),
// // //         headers: {'Content-Type': 'application/json'},
// // //       ).timeout(const Duration(seconds: 15));
// // //
// // //       if (response.statusCode == 200) {
// // //         final List<dynamic> data = jsonDecode(response.body);
// // //         final db = await dbHelper.db;
// // //
// // //         int savedCount = 0;
// // //         for (var item in data) {
// // //           try {
// // //             item['posted'] = 1;
// // //             AttendanceOutModel model = AttendanceOutModel.fromMap(item);
// // //
// // //             final existing = await db.query(
// // //               attendanceOutTableName,
// // //               where: 'attendance_out_id = ?',
// // //               whereArgs: [model.attendance_out_id],
// // //             );
// // //
// // //             if (existing.isEmpty) {
// // //               await db.insert(attendanceOutTableName, model.toMap());
// // //               savedCount++;
// // //               debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
// // //             } else {
// // //               debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
// // //             }
// // //           } catch (e) {
// // //             debugPrint("❌ [REPO-OUT] Error saving item: $e");
// // //           }
// // //         }
// // //         debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
// // //       } else {
// // //         debugPrint('❌ [REPO-OUT] API fetch failed with status: ${response.statusCode}');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
// // //     }
// // //   }
// // //
// // //   // Get unposted attendance out records
// // //   Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       final List<Map<String, dynamic>> maps = await db.query(
// // //         attendanceOutTableName,
// // //         where: 'posted = ?',
// // //         whereArgs: [0],
// // //       );
// // //
// // //       debugPrint('📊 [REPO-OUT] Found ${maps.length} unposted records');
// // //
// // //       return List.generate(maps.length, (i) {
// // //         return AttendanceOutModel.fromMap(maps[i]);
// // //       });
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
// // //       return [];
// // //     }
// // //   }
// // //
// // //   // ✅ ENHANCED: Add attendance out record with database health check
// // //   Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
// // //     try {
// // //       // Ensure database is writable
// // //       if (!await ensureDatabaseWritable()) {
// // //         debugPrint('❌ [REPO-OUT] Database not writable, cannot add record');
// // //         return -1;
// // //       }
// // //
// // //       final db = await dbHelper.db;
// // //       attendanceOut.posted = 0;
// // //
// // //       // Check if already exists
// // //       final existing = await db.query(
// // //         attendanceOutTableName,
// // //         where: 'attendance_out_id = ?',
// // //         whereArgs: [attendanceOut.attendance_out_id],
// // //       );
// // //
// // //       if (existing.isNotEmpty) {
// // //         debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceOut.attendance_out_id}');
// // //         return 0;
// // //       }
// // //
// // //       debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceOut.attendance_out_id}');
// // //       final result = await db.insert(attendanceOutTableName, attendanceOut.toMap());
// // //       debugPrint('✅ [REPO-OUT] Insert successful with result: $result');
// // //       return result;
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error adding record: $e');
// // //       return -1;
// // //     }
// // //   }
// // //
// // //   // Update attendance out record
// // //   Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceOut.attendance_out_id}');
// // //       return await db.update(
// // //         attendanceOutTableName,
// // //         attendanceOut.toMap(),
// // //         where: 'attendance_out_id = ?',
// // //         whereArgs: [attendanceOut.attendance_out_id],
// // //       );
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error updating record: $e');
// // //       rethrow;
// // //     }
// // //   }
// // //
// // //   // Mark as posted
// // //   Future<void> markAsPosted(String id) async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       await db.update(
// // //         attendanceOutTableName,
// // //         {'posted': 1},
// // //         where: 'attendance_out_id = ?',
// // //         whereArgs: [id],
// // //       );
// // //       _postedIds.add(id);
// // //       debugPrint('✅ [REPO-OUT] Marked as posted: $id');
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
// // //     }
// // //   }
// // //
// // //   // Post single record to API with retry logic
// // //   Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
// // //     const int maxRetries = 2;
// // //
// // //     for (int attempt = 1; attempt <= maxRetries; attempt++) {
// // //       try {
// // //         debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting ${attendanceOut.attendance_out_id} to $_attendanceOutApi');
// // //
// // //         var recordData = attendanceOut.toJson();
// // //         recordData['reason'] = attendanceOut.reason ?? 'manual';
// // //
// // //         final response = await http.post(
// // //           Uri.parse(_attendanceOutApi),
// // //           headers: {
// // //             'Content-Type': 'application/json',
// // //             'Accept': 'application/json',
// // //           },
// // //           body: jsonEncode(recordData),
// // //         ).timeout(const Duration(seconds: 15));
// // //
// // //         debugPrint('📡 [REPO-OUT] Response: ${response.statusCode}');
// // //         debugPrint('📡 [REPO-OUT] Response body: ${response.body}');
// // //
// // //         if (response.statusCode == 200 || response.statusCode == 201) {
// // //           await markAsPosted(attendanceOut.attendance_out_id!);
// // //           return true;
// // //         } else {
// // //           debugPrint('❌ Server error ${response.statusCode}: ${response.body}');
// // //         }
// // //       } catch (e) {
// // //         debugPrint('❌ Attempt $attempt failed: $e');
// // //       }
// // //     }
// // //
// // //     return false;
// // //   }
// // //
// // //   // Sync all unposted records
// // //   Future<void> syncUnposted() async {
// // //     debugPrint('🔄 [REPO-OUT] ===== STARTING SYNC =====');
// // //
// // //     if (!await isNetworkAvailable()) {
// // //       debugPrint('📴 [REPO-OUT] No internet connection. Skipping sync.');
// // //       return;
// // //     }
// // //
// // //     final unposted = await getUnPostedAttendanceOut();
// // //
// // //     if (unposted.isEmpty) {
// // //       debugPrint('📭 [REPO-OUT] No unposted attendance out records');
// // //       return;
// // //     }
// // //
// // //     debugPrint('🔄 [REPO-OUT] Syncing ${unposted.length} records');
// // //
// // //     // Deduplicate before posting
// // //     final Map<String, AttendanceOutModel> uniqueRecords = {};
// // //     for (var record in unposted) {
// // //       if (record.attendance_out_id != null) {
// // //         uniqueRecords[record.attendance_out_id.toString()] = record;
// // //       }
// // //     }
// // //
// // //     int successCount = 0;
// // //     int failCount = 0;
// // //
// // //     for (var record in uniqueRecords.values) {
// // //       // Skip if already posted in this session
// // //       if (_postedIds.contains(record.attendance_out_id.toString())) {
// // //         debugPrint('⚠️ [REPO-OUT] Skipping already posted in session: ${record.attendance_out_id}');
// // //         continue;
// // //       }
// // //
// // //       final posted = await postToAPI(record);
// // //       if (posted) {
// // //         successCount++;
// // //         _postedIds.add(record.attendance_out_id.toString());
// // //       } else {
// // //         failCount++;
// // //       }
// // //
// // //       await Future.delayed(const Duration(milliseconds: 500));
// // //     }
// // //
// // //     debugPrint('📊 [REPO-OUT] Sync results: $successCount success, $failCount failed');
// // //
// // //     // Clean duplicate records after sync
// // //     await _cleanDuplicateRecords();
// // //
// // //     debugPrint('🔄 [REPO-OUT] ===== SYNC COMPLETED =====');
// // //   }
// // //
// // //   // Delete record
// // //   Future<int> delete(String id) async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       debugPrint('🗑️ [REPO-OUT] Deleting record: $id');
// // //       return await db.delete(
// // //         attendanceOutTableName,
// // //         where: 'attendance_out_id = ?',
// // //         whereArgs: [id],
// // //       );
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error deleting record: $e');
// // //       return -1;
// // //     }
// // //   }
// // //
// // //   // Clean duplicate records from local DB
// // //   Future<void> _cleanDuplicateRecords() async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //
// // //       final List<Map> allRecords = await db.query(
// // //         attendanceOutTableName,
// // //         columns: ['attendance_out_id'],
// // //       );
// // //
// // //       final Set<String> uniqueIds = {};
// // //       final List<String> duplicateIds = [];
// // //
// // //       for (var record in allRecords) {
// // //         String id = record['attendance_out_id'].toString();
// // //         if (uniqueIds.contains(id)) {
// // //           duplicateIds.add(id);
// // //         } else {
// // //           uniqueIds.add(id);
// // //         }
// // //       }
// // //
// // //       for (String duplicateId in duplicateIds) {
// // //         debugPrint('⚠️ [REPO-OUT] Found duplicates for ID: $duplicateId');
// // //
// // //         final List<Map> duplicates = await db.query(
// // //           attendanceOutTableName,
// // //           where: 'attendance_out_id = ?',
// // //           whereArgs: [duplicateId],
// // //         );
// // //
// // //         if (duplicates.length > 1) {
// // //           for (int i = 1; i < duplicates.length; i++) {
// // //             await db.delete(
// // //               attendanceOutTableName,
// // //               where: 'rowid = ?',
// // //               whereArgs: [duplicates[i]['rowid']],
// // //             );
// // //           }
// // //           debugPrint('✅ [REPO-OUT] Cleaned ${duplicates.length - 1} duplicates for ID: $duplicateId');
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
// // //     }
// // //   }
// // //
// // //   // Get record by ID
// // //   Future<AttendanceOutModel?> getRecordById(String id) async {
// // //     try {
// // //       final db = await dbHelper.db;
// // //       final List<Map<String, dynamic>> maps = await db.query(
// // //         attendanceOutTableName,
// // //         where: 'attendance_out_id = ?',
// // //         whereArgs: [id],
// // //       );
// // //
// // //       if (maps.isNotEmpty) {
// // //         return AttendanceOutModel.fromMap(maps.first);
// // //       }
// // //       return null;
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Error getting record by ID: $e');
// // //       return null;
// // //     }
// // //   }
// // //
// // //   // Clear posted cache
// // //   void clearPostedCache() {
// // //     _postedIds.clear();
// // //     debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
// // //   }
// // //
// // //   // Generate unique attendance out ID
// // //   Future<String> generateAttendanceOutId() async {
// // //     final now = DateTime.now();
// // //     final formattedDate = DateFormat('ddMMMyyyyHHmmss').format(now);
// // //     String id = "ATD-OUT-$emp_id-$formattedDate";
// // //     debugPrint('🔢 [REPO-OUT] Generated ID: $id');
// // //     return id;
// // //   }
// // //
// // //   // ✅ Database health check method
// // //   Future<bool> ensureDatabaseWritable() async {
// // //     try {
// // //       final isHealthy = await dbHelper.isDatabaseHealthy();
// // //       if (!isHealthy) {
// // //         debugPrint('⚠️ [REPO-OUT] Database unhealthy, attempting repair...');
// // //         final repaired = await dbHelper.repairDatabase();
// // //         if (!repaired) {
// // //           debugPrint('❌ [REPO-OUT] Database repair failed');
// // //           return false;
// // //         }
// // //       }
// // //       return true;
// // //     } catch (e) {
// // //       debugPrint('❌ [REPO-OUT] Database check failed: $e');
// // //       return false;
// // //     }
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:intl/intl.dart';
// // import '../Database/db_helper.dart';
// // import '../Database/util.dart';
// // import '../Models/attendanceOut_model.dart';
// // import '../../constants.dart';
// //
// // class AttendanceOutRepository {
// //   final DBHelper dbHelper = DBHelper();
// //
// //   // ✅ Track posted IDs in session to prevent duplicate posting
// //   final Set<String> _postedIds = {};
// //
// //   // ✅ FIX: Removed trailing space - verify this endpoint with your backend
// //   static const String _attendanceOutApi = 'http://oracle.metaxperts.net/ords/production/attendanceout/post';
// //
// //   // Get all attendance out records
// //   Future<List<AttendanceOutModel>> getAttendanceOut() async {
// //     try {
// //       final db = await dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         attendanceOutTableName,
// //         orderBy: 'attendance_out_date DESC',
// //       );
// //
// //       debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');
// //       for (var map in maps) {
// //         debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
// //       }
// //
// //       return List.generate(maps.length, (i) {
// //         return AttendanceOutModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error getting attendance out: $e');
// //       return [];
// //     }
// //   }
// //
// //   // Fetch from API and save locally
// //   Future<void> fetchAndSaveAttendanceOut() async {
// //     try {
// //       debugPrint('🔍 [REPO-OUT] Fetching attendance out from API...');
// //       // ✅ FIX: Removed trailing space
// //       final url = 'http://oracle.metaxperts.net/ords/production/attendanceout/get/$emp_id';
// //       final response = await http.get(
// //         Uri.parse(url),
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
// //             AttendanceOutModel model = AttendanceOutModel.fromMap(item);
// //
// //             final existing = await db.query(
// //               attendanceOutTableName,
// //               where: 'attendance_out_id = ?',
// //               whereArgs: [model.attendance_out_id],
// //             );
// //
// //             if (existing.isEmpty) {
// //               await db.insert(attendanceOutTableName, model.toMap());
// //               savedCount++;
// //               debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
// //             } else {
// //               debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
// //             }
// //           } catch (e) {
// //             debugPrint("❌ [REPO-OUT] Error saving item: $e");
// //           }
// //         }
// //         debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
// //       } else {
// //         debugPrint('❌ [REPO-OUT] API fetch failed with status: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
// //     }
// //   }
// //
// //   // Get unposted attendance out records
// //   Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
// //     try {
// //       final db = await dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         attendanceOutTableName,
// //         where: 'posted = ?',
// //         whereArgs: [0],
// //       );
// //
// //       debugPrint('📊 [REPO-OUT] Found ${maps.length} unposted records');
// //
// //       return List.generate(maps.length, (i) {
// //         return AttendanceOutModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
// //       return [];
// //     }
// //   }
// //
// //   // ✅ ENHANCED: Add attendance out record with database health check
// //   Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
// //     try {
// //       // Ensure database is writable
// //       if (!await ensureDatabaseWritable()) {
// //         debugPrint('❌ [REPO-OUT] Database not writable, cannot add record');
// //         return -1;
// //       }
// //
// //       final db = await dbHelper.db;
// //       attendanceOut.posted = 0;
// //
// //       // Check if already exists
// //       final existing = await db.query(
// //         attendanceOutTableName,
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [attendanceOut.attendance_out_id],
// //       );
// //
// //       if (existing.isNotEmpty) {
// //         debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceOut.attendance_out_id}');
// //         return 0;
// //       }
// //
// //       debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceOut.attendance_out_id}');
// //       final result = await db.insert(attendanceOutTableName, attendanceOut.toMap());
// //       debugPrint('✅ [REPO-OUT] Insert successful with result: $result');
// //       return result;
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error adding record: $e');
// //       return -1;
// //     }
// //   }
// //
// //   // Update attendance out record
// //   Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
// //     try {
// //       final db = await dbHelper.db;
// //       debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceOut.attendance_out_id}');
// //       return await db.update(
// //         attendanceOutTableName,
// //         attendanceOut.toMap(),
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [attendanceOut.attendance_out_id],
// //       );
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error updating record: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // Mark as posted
// //   Future<void> markAsPosted(String id) async {
// //     try {
// //       final db = await dbHelper.db;
// //       await db.update(
// //         attendanceOutTableName,
// //         {'posted': 1},
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [id],
// //       );
// //       _postedIds.add(id);
// //       debugPrint('✅ [REPO-OUT] Marked as posted: $id');
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
// //     }
// //   }
// //
// //   // Post single record to API with retry logic
// //   Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
// //     const int maxRetries = 2;
// //
// //     for (int attempt = 1; attempt <= maxRetries; attempt++) {
// //       try {
// //         debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting ${attendanceOut.attendance_out_id} to $_attendanceOutApi');
// //
// //         // ✅ FIX: Proper JSON serialization with reason field
// //         var recordData = attendanceOut.toJson();
// //         recordData['reason'] = attendanceOut.reason ?? 'manual';
// //
// //         final jsonBody = jsonEncode(recordData);
// //         debugPrint('📤 [REPO-OUT] Request body: $jsonBody');
// //
// //         final response = await http.post(
// //           Uri.parse(_attendanceOutApi),
// //           headers: {
// //             'Content-Type': 'application/json',
// //             'Accept': 'application/json',
// //           },
// //           body: jsonBody,
// //         ).timeout(const Duration(seconds: 15));
// //
// //         debugPrint('📡 [REPO-OUT] Response: ${response.statusCode}');
// //         debugPrint('📡 [REPO-OUT] Response body: ${response.body}');
// //
// //         if (response.statusCode == 200 || response.statusCode == 201) {
// //           await markAsPosted(attendanceOut.attendance_out_id!);
// //           return true;
// //         } else if (response.statusCode == 405) {
// //           debugPrint('❌ [REPO-OUT] HTTP 405: Method Not Allowed - Check API endpoint URL');
// //           debugPrint('❌ [REPO-OUT] Current endpoint: $_attendanceOutApi');
// //           // Don't retry on 405, it's a configuration error
// //           return false;
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
// //     debugPrint('🔄 [REPO-OUT] ===== STARTING SYNC =====');
// //
// //     if (!await isNetworkAvailable()) {
// //       debugPrint('📴 [REPO-OUT] No internet connection. Skipping sync.');
// //       return;
// //     }
// //
// //     final unposted = await getUnPostedAttendanceOut();
// //
// //     if (unposted.isEmpty) {
// //       debugPrint('📭 [REPO-OUT] No unposted attendance out records');
// //       return;
// //     }
// //
// //     debugPrint('🔄 [REPO-OUT] Syncing ${unposted.length} records');
// //
// //     // Deduplicate before posting
// //     final Map<String, AttendanceOutModel> uniqueRecords = {};
// //     for (var record in unposted) {
// //       if (record.attendance_out_id != null) {
// //         uniqueRecords[record.attendance_out_id.toString()] = record;
// //       }
// //     }
// //
// //     int successCount = 0;
// //     int failCount = 0;
// //
// //     for (var record in uniqueRecords.values) {
// //       // Skip if already posted in this session
// //       if (_postedIds.contains(record.attendance_out_id.toString())) {
// //         debugPrint('⚠️ [REPO-OUT] Skipping already posted in session: ${record.attendance_out_id}');
// //         continue;
// //       }
// //
// //       final posted = await postToAPI(record);
// //       if (posted) {
// //         successCount++;
// //         _postedIds.add(record.attendance_out_id.toString());
// //       } else {
// //         failCount++;
// //       }
// //
// //       await Future.delayed(const Duration(milliseconds: 500));
// //     }
// //
// //     debugPrint('📊 [REPO-OUT] Sync results: $successCount success, $failCount failed');
// //
// //     // Clean duplicate records after sync
// //     await _cleanDuplicateRecords();
// //
// //     debugPrint('🔄 [REPO-OUT] ===== SYNC COMPLETED =====');
// //   }
// //
// //   // Delete record
// //   Future<int> delete(String id) async {
// //     try {
// //       final db = await dbHelper.db;
// //       debugPrint('🗑️ [REPO-OUT] Deleting record: $id');
// //       return await db.delete(
// //         attendanceOutTableName,
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [id],
// //       );
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error deleting record: $e');
// //       return -1;
// //     }
// //   }
// //
// //   // Clean duplicate records from local DB
// //   Future<void> _cleanDuplicateRecords() async {
// //     try {
// //       final db = await dbHelper.db;
// //
// //       final List<Map> allRecords = await db.query(
// //         attendanceOutTableName,
// //         columns: ['attendance_out_id', 'rowid'],
// //       );
// //
// //       final Set<String> uniqueIds = {};
// //       final List<int> duplicateRowIds = [];
// //
// //       for (var record in allRecords) {
// //         String id = record['attendance_out_id'].toString();
// //         int rowId = record['rowid'] as int;
// //         if (uniqueIds.contains(id)) {
// //           duplicateRowIds.add(rowId);
// //         } else {
// //           uniqueIds.add(id);
// //         }
// //       }
// //
// //       for (int rowId in duplicateRowIds) {
// //         await db.delete(
// //           attendanceOutTableName,
// //           where: 'rowid = ?',
// //           whereArgs: [rowId],
// //         );
// //       }
// //
// //       if (duplicateRowIds.isNotEmpty) {
// //         debugPrint('✅ [REPO-OUT] Cleaned ${duplicateRowIds.length} duplicate records');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
// //     }
// //   }
// //
// //   // Get record by ID
// //   Future<AttendanceOutModel?> getRecordById(String id) async {
// //     try {
// //       final db = await dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         attendanceOutTableName,
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [id],
// //       );
// //
// //       if (maps.isNotEmpty) {
// //         return AttendanceOutModel.fromMap(maps.first);
// //       }
// //       return null;
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error getting record by ID: $e');
// //       return null;
// //     }
// //   }
// //
// //   // Clear posted cache
// //   void clearPostedCache() {
// //     _postedIds.clear();
// //     debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
// //   }
// //
// //   // Generate unique attendance out ID
// //   Future<String> generateAttendanceOutId() async {
// //     final now = DateTime.now();
// //     final formattedDate = DateFormat('ddMMMyyyyHHmmss').format(now);
// //     String id = "ATD-OUT-$emp_id-$formattedDate";
// //     debugPrint('🔢 [REPO-OUT] Generated ID: $id');
// //     return id;
// //   }
// //
// //   // ✅ Database health check method
// //   Future<bool> ensureDatabaseWritable() async {
// //     try {
// //       final isHealthy = await dbHelper.isDatabaseHealthy();
// //       if (!isHealthy) {
// //         debugPrint('⚠️ [REPO-OUT] Database unhealthy, attempting repair...');
// //         final repaired = await dbHelper.repairDatabase();
// //         if (!repaired) {
// //           debugPrint('❌ [REPO-OUT] Database repair failed');
// //           return false;
// //         }
// //       }
// //       return true;
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Database check failed: $e');
// //       return false;
// //     }
// //   }
// // }
//
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import '../Database/db_helper.dart';
// import '../Database/util.dart';
// import '../Models/attendanceOut_model.dart';
// import '../../constants.dart';
//
// class AttendanceOutRepository {
//   final DBHelper dbHelper = DBHelper();
//
//   // ✅ Track posted IDs in session to prevent duplicate posting
//   final Set<String> _postedIds = {};
//
//   // ✅ FIX: Removed trailing space - verify this endpoint with your backend
//   static const String _attendanceOutApi = 'http://oracle.metaxperts.net/ords/production/attendanceout/post';
//
//   // Get all attendance out records
//   Future<List<AttendanceOutModel>> getAttendanceOut() async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceOutTableName,
//         orderBy: 'attendance_out_date DESC',
//       );
//
//       debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');
//       for (var map in maps) {
//         debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
//       }
//
//       return List.generate(maps.length, (i) {
//         return AttendanceOutModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error getting attendance out: $e');
//       return [];
//     }
//   }
//
//   // Fetch from API and save locally
//   Future<void> fetchAndSaveAttendanceOut() async {
//     try {
//       debugPrint('🔍 [REPO-OUT] Fetching attendance out from API...');
//       // ✅ FIX: Removed trailing space
//       final url = 'http://oracle.metaxperts.net/ords/production/attendanceout/get/$emp_id';
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
//             AttendanceOutModel model = AttendanceOutModel.fromMap(item);
//
//             final existing = await db.query(
//               attendanceOutTableName,
//               where: 'attendance_out_id = ?',
//               whereArgs: [model.attendance_out_id],
//             );
//
//             if (existing.isEmpty) {
//               await db.insert(attendanceOutTableName, model.toMap());
//               savedCount++;
//               debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
//             } else {
//               debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
//             }
//           } catch (e) {
//             debugPrint("❌ [REPO-OUT] Error saving item: $e");
//           }
//         }
//         debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
//       } else {
//         debugPrint('❌ [REPO-OUT] API fetch failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
//     }
//   }
//
//   // Get unposted attendance out records
//   Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceOutTableName,
//         where: 'posted = ?',
//         whereArgs: [0],
//       );
//
//       debugPrint('📊 [REPO-OUT] Found ${maps.length} unposted records');
//
//       return List.generate(maps.length, (i) {
//         return AttendanceOutModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
//       return [];
//     }
//   }
//
//   // ✅ ENHANCED: Add attendance out record with database health check
//   Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
//     try {
//       // Ensure database is writable
//       if (!await ensureDatabaseWritable()) {
//         debugPrint('❌ [REPO-OUT] Database not writable, cannot add record');
//         return -1;
//       }
//
//       final db = await dbHelper.db;
//       attendanceOut.posted = 0;
//
//       // Check if already exists
//       final existing = await db.query(
//         attendanceOutTableName,
//         where: 'attendance_out_id = ?',
//         whereArgs: [attendanceOut.attendance_out_id],
//       );
//
//       if (existing.isNotEmpty) {
//         debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceOut.attendance_out_id}');
//         return 0;
//       }
//
//       debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceOut.attendance_out_id}');
//       final result = await db.insert(attendanceOutTableName, attendanceOut.toMap());
//       debugPrint('✅ [REPO-OUT] Insert successful with result: $result');
//       return result;
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error adding record: $e');
//       return -1;
//     }
//   }
//
//   // Update attendance out record
//   Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
//     try {
//       final db = await dbHelper.db;
//       debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceOut.attendance_out_id}');
//       return await db.update(
//         attendanceOutTableName,
//         attendanceOut.toMap(),
//         where: 'attendance_out_id = ?',
//         whereArgs: [attendanceOut.attendance_out_id],
//       );
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error updating record: $e');
//       rethrow;
//     }
//   }
//
//   // Mark as posted
//   Future<void> markAsPosted(String id) async {
//     try {
//       final db = await dbHelper.db;
//       await db.update(
//         attendanceOutTableName,
//         {'posted': 1},
//         where: 'attendance_out_id = ?',
//         whereArgs: [id],
//       );
//       _postedIds.add(id);
//       debugPrint('✅ [REPO-OUT] Marked as posted: $id');
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
//     }
//   }
//
//   // Post single record to API with retry logic
//   Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
//     const int maxRetries = 2;
//
//     for (int attempt = 1; attempt <= maxRetries; attempt++) {
//       try {
//         debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting ${attendanceOut.attendance_out_id} to $_attendanceOutApi');
//
//         // ✅ FIX: Proper JSON serialization with reason field
//         var recordData = attendanceOut.toJson();
//         recordData['reason'] = attendanceOut.reason ?? 'manual';
//
//         final jsonBody = jsonEncode(recordData);
//         debugPrint('📤 [REPO-OUT] Request body: $jsonBody');
//
//         final response = await http.post(
//           Uri.parse(_attendanceOutApi),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonBody,
//         ).timeout(const Duration(seconds: 15));
//
//         debugPrint('📡 [REPO-OUT] Response: ${response.statusCode}');
//         debugPrint('📡 [REPO-OUT] Response body: ${response.body}');
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           await markAsPosted(attendanceOut.attendance_out_id!);
//           return true;
//         } else if (response.statusCode == 405) {
//           debugPrint('❌ [REPO-OUT] HTTP 405: Method Not Allowed - Check API endpoint URL');
//           debugPrint('❌ [REPO-OUT] Current endpoint: $_attendanceOutApi');
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
//     debugPrint('🔄 [REPO-OUT] ===== STARTING SYNC =====');
//
//     if (!await isNetworkAvailable()) {
//       debugPrint('📴 [REPO-OUT] No internet connection. Skipping sync.');
//       return;
//     }
//
//     final unposted = await getUnPostedAttendanceOut();
//
//     if (unposted.isEmpty) {
//       debugPrint('📭 [REPO-OUT] No unposted attendance out records');
//       return;
//     }
//
//     debugPrint('🔄 [REPO-OUT] Syncing ${unposted.length} records');
//
//     // Deduplicate before posting
//     final Map<String, AttendanceOutModel> uniqueRecords = {};
//     for (var record in unposted) {
//       if (record.attendance_out_id != null) {
//         uniqueRecords[record.attendance_out_id.toString()] = record;
//       }
//     }
//
//     int successCount = 0;
//     int failCount = 0;
//
//     for (var record in uniqueRecords.values) {
//       // Skip if already posted in this session
//       if (_postedIds.contains(record.attendance_out_id.toString())) {
//         debugPrint('⚠️ [REPO-OUT] Skipping already posted in session: ${record.attendance_out_id}');
//         continue;
//       }
//
//       final posted = await postToAPI(record);
//       if (posted) {
//         successCount++;
//         _postedIds.add(record.attendance_out_id.toString());
//       } else {
//         failCount++;
//       }
//
//       await Future.delayed(const Duration(milliseconds: 500));
//     }
//
//     debugPrint('📊 [REPO-OUT] Sync results: $successCount success, $failCount failed');
//
//     // Clean duplicate records after sync
//     await _cleanDuplicateRecords();
//
//     debugPrint('🔄 [REPO-OUT] ===== SYNC COMPLETED =====');
//   }
//
//   // Delete record
//   Future<int> delete(String id) async {
//     try {
//       final db = await dbHelper.db;
//       debugPrint('🗑️ [REPO-OUT] Deleting record: $id');
//       return await db.delete(
//         attendanceOutTableName,
//         where: 'attendance_out_id = ?',
//         whereArgs: [id],
//       );
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error deleting record: $e');
//       return -1;
//     }
//   }
//
//   // Clean duplicate records from local DB
//   Future<void> _cleanDuplicateRecords() async {
//     try {
//       final db = await dbHelper.db;
//
//       final List<Map> allRecords = await db.query(
//         attendanceOutTableName,
//         columns: ['attendance_out_id', 'rowid'],
//       );
//
//       final Set<String> uniqueIds = {};
//       final List<int> duplicateRowIds = [];
//
//       for (var record in allRecords) {
//         String id = record['attendance_out_id'].toString();
//         int rowId = record['rowid'] as int;
//         if (uniqueIds.contains(id)) {
//           duplicateRowIds.add(rowId);
//         } else {
//           uniqueIds.add(id);
//         }
//       }
//
//       for (int rowId in duplicateRowIds) {
//         await db.delete(
//           attendanceOutTableName,
//           where: 'rowid = ?',
//           whereArgs: [rowId],
//         );
//       }
//
//       if (duplicateRowIds.isNotEmpty) {
//         debugPrint('✅ [REPO-OUT] Cleaned ${duplicateRowIds.length} duplicate records');
//       }
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
//     }
//   }
//
//   // Get record by ID
//   Future<AttendanceOutModel?> getRecordById(String id) async {
//     try {
//       final db = await dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         attendanceOutTableName,
//         where: 'attendance_out_id = ?',
//         whereArgs: [id],
//       );
//
//       if (maps.isNotEmpty) {
//         return AttendanceOutModel.fromMap(maps.first);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Error getting record by ID: $e');
//       return null;
//     }
//   }
//
//   // Clear posted cache
//   void clearPostedCache() {
//     _postedIds.clear();
//     debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
//   }
//
//   // Generate unique attendance out ID
//   Future<String> generateAttendanceOutId() async {
//     final now = DateTime.now();
//     final formattedDate = DateFormat('ddMMMyyyyHHmmss').format(now);
//     String id = "ATD-OUT-$emp_id-$formattedDate";
//     debugPrint('🔢 [REPO-OUT] Generated ID: $id');
//     return id;
//   }
//
//   // ✅ Database health check method
//   Future<bool> ensureDatabaseWritable() async {
//     try {
//       final isHealthy = await dbHelper.isDatabaseHealthy();
//       if (!isHealthy) {
//         debugPrint('⚠️ [REPO-OUT] Database unhealthy, attempting repair...');
//         final repaired = await dbHelper.repairDatabase();
//         if (!repaired) {
//           debugPrint('❌ [REPO-OUT] Database repair failed');
//           return false;
//         }
//       }
//       return true;
//     } catch (e) {
//       debugPrint('❌ [REPO-OUT] Database check failed: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../Models/attendanceOut_model.dart';
import '../../constants.dart';

class AttendanceOutRepository {
  final DBHelper dbHelper = DBHelper();

  // ✅ Track posted IDs in session to prevent duplicate posting
  final Set<String> _postedIds = {};

  // ✅ FIX: Standard ORDS REST endpoint pattern
  static const String _attendanceOutApi = 'http://oracle.metaxperts.net/ords/production/attendanceout/post/';

  // Get all attendance out records
  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceOutTableName,
        orderBy: 'attendance_out_date DESC',
      );

      debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');
      for (var map in maps) {
        debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
      }

      return List.generate(maps.length, (i) {
        return AttendanceOutModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting attendance out: $e');
      return [];
    }
  }

  // Fetch from API and save locally
  Future<void> fetchAndSaveAttendanceOut() async {
    try {
      debugPrint('🔍 [REPO-OUT] Fetching attendance out from API...');
      final url = '$_attendanceOutApi/$emp_id';

      debugPrint('🌐 [REPO-OUT] GET URL: $url');

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
            AttendanceOutModel model = AttendanceOutModel.fromMap(item);

            final existing = await db.query(
              attendanceOutTableName,
              where: 'attendance_out_id = ?',
              whereArgs: [model.attendance_out_id],
            );

            if (existing.isEmpty) {
              await db.insert(attendanceOutTableName, model.toMap());
              savedCount++;
              debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
            } else {
              debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
            }
          } catch (e) {
            debugPrint("❌ [REPO-OUT] Error saving item: $e");
          }
        }
        debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
      } else {
        debugPrint('❌ [REPO-OUT] API fetch failed with status: ${response.statusCode}');
        debugPrint('❌ [REPO-OUT] Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
    }
  }

  // Get unposted attendance out records
  Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceOutTableName,
        where: 'posted = ?',
        whereArgs: [0],
      );

      debugPrint('📊 [REPO-OUT] Found ${maps.length} unposted records');

      return List.generate(maps.length, (i) {
        return AttendanceOutModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
      return [];
    }
  }

  // ✅ ENHANCED: Add attendance out record with database health check
  Future<int> addAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      // Ensure database is writable
      if (!await ensureDatabaseWritable()) {
        debugPrint('❌ [REPO-OUT] Database not writable, cannot add record');
        return -1;
      }

      final db = await dbHelper.db;
      attendanceOut.posted = 0;

      // Check if already exists
      final existing = await db.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceOut.attendance_out_id],
      );

      if (existing.isNotEmpty) {
        debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceOut.attendance_out_id}');
        return 0;
      }

      debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceOut.attendance_out_id}');
      final result = await db.insert(attendanceOutTableName, attendanceOut.toMap());
      debugPrint('✅ [REPO-OUT] Insert successful with result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error adding record: $e');
      return -1;
    }
  }

  // Update attendance out record
  Future<int> updateAttendanceOut(AttendanceOutModel attendanceOut) async {
    try {
      final db = await dbHelper.db;
      debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceOut.attendance_out_id}');
      return await db.update(
        attendanceOutTableName,
        attendanceOut.toMap(),
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceOut.attendance_out_id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error updating record: $e');
      rethrow;
    }
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    try {
      final db = await dbHelper.db;
      await db.update(
        attendanceOutTableName,
        {'posted': 1},
        where: 'attendance_out_id = ?',
        whereArgs: [id],
      );
      _postedIds.add(id);
      debugPrint('✅ [REPO-OUT] Marked as posted: $id');
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
    }
  }

  // ✅ FIX: Post single record to API with CORRECT field mapping
  Future<bool> postToAPI(AttendanceOutModel attendanceOut) async {
    const int maxRetries = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting ${attendanceOut.attendance_out_id}');
        debugPrint('🌐 [REPO-OUT] URL: $_attendanceOutApi');

        // ✅ Build JSON payload matching server-side PL/SQL parameter names
        final Map<String, dynamic> apiPayload = attendanceOut.toJson();

        final jsonBody = jsonEncode(apiPayload);
        debugPrint('📤 [REPO-OUT] Request body: $jsonBody');

        final response = await http.post(
          Uri.parse(_attendanceOutApi),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonBody,
        ).timeout(const Duration(seconds: 15));

        debugPrint('📡 [REPO-OUT] Response Status: ${response.statusCode}');
        debugPrint('📡 [REPO-OUT] Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          await markAsPosted(attendanceOut.attendance_out_id!);
          debugPrint('✅ [REPO-OUT] Successfully posted to API');
          return true;
        } else if (response.statusCode == 404) {
          debugPrint('❌ [REPO-OUT] HTTP 404: Endpoint not found');

          // Try with trailing slash
          final response2 = await http.post(
            Uri.parse('$_attendanceOutApi/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonBody,
          ).timeout(const Duration(seconds: 15));

          if (response2.statusCode == 200 || response2.statusCode == 201) {
            await markAsPosted(attendanceOut.attendance_out_id!);
            debugPrint('✅ [REPO-OUT] Success with trailing slash!');
            return true;
          }
          return false;
        } else if (response.statusCode == 400) {
          debugPrint('❌ [REPO-OUT] HTTP 400: Bad Request - Check field names');
          return false;
        } else {
          debugPrint('❌ [REPO-OUT] Server error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('❌ [REPO-OUT] Attempt $attempt failed: $e');
      }
    }

    return false;
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    debugPrint('🔄 [REPO-OUT] ===== STARTING SYNC =====');

    if (!await isNetworkAvailable()) {
      debugPrint('📴 [REPO-OUT] No internet connection. Skipping sync.');
      return;
    }

    final unposted = await getUnPostedAttendanceOut();

    if (unposted.isEmpty) {
      debugPrint('📭 [REPO-OUT] No unposted attendance out records');
      return;
    }

    debugPrint('🔄 [REPO-OUT] Syncing ${unposted.length} records');

    // Deduplicate before posting
    final Map<String, AttendanceOutModel> uniqueRecords = {};
    for (var record in unposted) {
      if (record.attendance_out_id != null) {
        uniqueRecords[record.attendance_out_id.toString()] = record;
      }
    }

    int successCount = 0;
    int failCount = 0;

    for (var record in uniqueRecords.values) {
      // Skip if already posted in this session
      if (_postedIds.contains(record.attendance_out_id.toString())) {
        debugPrint('⚠️ [REPO-OUT] Skipping already posted in session: ${record.attendance_out_id}');
        continue;
      }

      final posted = await postToAPI(record);
      if (posted) {
        successCount++;
        _postedIds.add(record.attendance_out_id.toString());
      } else {
        failCount++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint('📊 [REPO-OUT] Sync results: $successCount success, $failCount failed');

    // Clean duplicate records after sync
    await _cleanDuplicateRecords();

    debugPrint('🔄 [REPO-OUT] ===== SYNC COMPLETED =====');
  }

  // Delete record
  Future<int> delete(String id) async {
    try {
      final db = await dbHelper.db;
      debugPrint('🗑️ [REPO-OUT] Deleting record: $id');
      return await db.delete(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error deleting record: $e');
      return -1;
    }
  }

  // Clean duplicate records from local DB
  Future<void> _cleanDuplicateRecords() async {
    try {
      final db = await dbHelper.db;

      final List<Map> allRecords = await db.query(
        attendanceOutTableName,
        columns: ['attendance_out_id', 'rowid'],
      );

      final Set<String> uniqueIds = {};
      final List<int> duplicateRowIds = [];

      for (var record in allRecords) {
        String id = record['attendance_out_id'].toString();
        int rowId = record['rowid'] as int;
        if (uniqueIds.contains(id)) {
          duplicateRowIds.add(rowId);
        } else {
          uniqueIds.add(id);
        }
      }

      for (int rowId in duplicateRowIds) {
        await db.delete(
          attendanceOutTableName,
          where: 'rowid = ?',
          whereArgs: [rowId],
        );
      }

      if (duplicateRowIds.isNotEmpty) {
        debugPrint('✅ [REPO-OUT] Cleaned ${duplicateRowIds.length} duplicate records');
      }
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
    }
  }

  // Get record by ID
  Future<AttendanceOutModel?> getRecordById(String id) async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return AttendanceOutModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting record by ID: $e');
      return null;
    }
  }

  // Clear posted cache
  void clearPostedCache() {
    _postedIds.clear();
    debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
  }

  // Generate unique attendance out ID
  Future<String> generateAttendanceOutId() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('ddMMMyyyyHHmmss').format(now);
    String id = "ATD-OUT-$emp_id-$formattedDate";
    debugPrint('🔢 [REPO-OUT] Generated ID: $id');
    return id;
  }

  // ✅ Database health check method
  Future<bool> ensureDatabaseWritable() async {
    try {
      final isHealthy = await dbHelper.isDatabaseHealthy();
      if (!isHealthy) {
        debugPrint('⚠️ [REPO-OUT] Database unhealthy, attempting repair...');
        final repaired = await dbHelper.repairDatabase();
        if (!repaired) {
          debugPrint('❌ [REPO-OUT] Database repair failed');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Database check failed: $e');
      return false;
    }
  }
}