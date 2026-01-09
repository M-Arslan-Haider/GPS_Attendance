// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/foundation.dart';
// // import 'package:get/get.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../Databases/dp_helper.dart';
// // import '../Databases/util.dart';
// // import '../Models/attendanceOut_model.dart';
// // import '../Services/ApiServices/api_service.dart';
// // import '../Services/ApiServices/serial_number_genterator.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class AttendanceOutRepository extends GetxService {
// //   DBHelper dbHelper = DBHelper();
// //
// //   Future<List<AttendanceOutModel>> getAttendanceOut() async {
// //     var dbClient = await dbHelper.db;
// //     List<Map> maps = await dbClient.query(attendanceOutTableName, columns: [
// //       'attendance_out_id',
// //       'attendance_out_date',
// //       'attendance_out_time',
// //       'user_id',
// //       'total_time',
// //       'lat_out',
// //       'lng_out',
// //       'total_distance',
// //       'address',
// //       'posted'
// //     ]);
// //     List<AttendanceOutModel> attendanceout = [];
// //
// //     for (int i = 0; i < maps.length; i++) {
// //       attendanceout.add(AttendanceOutModel.fromMap(maps[i]));
// //     }
// //
// //     debugPrint('Raw data from AttendanceOut database:');
// //
// //     for (var map in maps) {
// //       debugPrint("$map");
// //     }
// //     return attendanceout;
// //   }
// //
// //   Future<void> fetchAndSaveAttendanceOut() async {
// //     debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOut}$user_id');
// //     List<dynamic> data =
// //         await ApiService.getData('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOut}$user_id');
// //     var dbClient = await dbHelper.db;
// //
// //     // Save data to database
// //     for (var item in data) {
// //       item['posted'] = 1; // Set posted to 1
// //       AttendanceOutModel model = AttendanceOutModel.fromMap(item);
// //       await dbClient.insert(attendanceOutTableName, model.toMap());
// //     }
// //   }
// //
// //   Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
// //     var dbClient = await dbHelper.db;
// //     List<Map> maps = await dbClient.query(
// //       attendanceOutTableName,
// //       where: 'posted = ?',
// //       whereArgs: [0], // Fetch machines that have not been posted
// //     );
// //
// //     List<AttendanceOutModel> attendanceOutModel =
// //         maps.map((map) => AttendanceOutModel.fromMap(map)).toList();
// //     return attendanceOutModel;
// //   }
// //
// //   Future<void> postDataFromDatabaseToAPI() async {
// //     try {
// //       var unPostedShops = await getUnPostedAttendanceOut();
// //
// //       if (await isNetworkAvailable()) {
// //         for (var shop in unPostedShops) {
// //           try {
// //             await postShopToAPI(shop);
// //             shop.posted = 1;
// //             await update(shop);
// //
// //             debugPrint(
// //                 'Shop with id ${shop.attendance_out_id} posted and updated in local database.');
// //           } catch (e) {
// //             debugPrint(
// //                 'Failed to post shop with id ${shop.attendance_out_id}: $e');
// //           }
// //         }
// //       } else {
// //         debugPrint('Network not available. Unposted shops will remain local.');
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching unposted shops: $e');
// //     }
// //   }
// // ///old code
// //   // Future<void> postShopToAPI(AttendanceOutModel shop) async {
// //   //   try {
// //   //     await Config.fetchLatestConfig();
// //   //
// //   //     debugPrint('Updated Shop Post API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceOut}');
// //   //
// //   //     var shopData = shop.toMap();
// //   //     final response = await http.post(
// //   //       Uri.parse(
// //   //           "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceOut}"
// //   //       ),
// //   //       headers: {
// //   //         "Content-Type": "application/json",
// //   //         "Accept": "application/json",
// //   //       },
// //   //       body: jsonEncode(shopData),
// //   //     );
// //   //
// //   //     if (response.statusCode == 200 || response.statusCode == 201) {
// //   //       debugPrint('attendance_out_id data posted successfully: $shopData');
// //   //       // Delete the shop visit data from the local database after successful post
// //   //       await delete(shop.attendance_out_id!);
// //   //
// //   //       debugPrint(
// //   //           'attendance_out_id with id ${shop.attendance_out_id} deleted from local database.');
// //   //     } else {
// //   //       throw Exception(
// //   //           'Server error: ${response.statusCode}, ${response.body}');
// //   //     }
// //   //   } catch (e) {
// //   //     debugPrint('Error posting shop data: $e');
// //   //     throw Exception('Failed to post data: $e');
// //   //   }
// //   // }
// //
// //   ///added code
// //   Future<void> postShopToAPI(AttendanceOutModel shop) async {
// //     try {
// //       await Config.fetchLatestConfig();
// //       String apiUrl = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceOut}';
// //       debugPrint('🔄 [REPO-OUT] Posting to: $apiUrl');
// //
// //       var shopData = shop.toMap();
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {
// //           "Content-Type": "application/json",
// //           "Accept": "application/json",
// //         },
// //         body: jsonEncode(shopData),
// //       );
// //
// //       debugPrint('📡 [REPO-OUT] Response status: ${response.statusCode}');
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         debugPrint('✅ [REPO-OUT] Data posted successfully: ${shop.attendance_out_id}');
// //
// //         // ✅ CORRECT: Just update posted status, DON'T DELETE!
// //         shop.posted = 1;
// //         await update(shop);
// //         debugPrint('✅ [REPO-OUT] Marked as posted: ${shop.attendance_out_id}');
// //
// //       } else {
// //         debugPrint('❌ [REPO-OUT] Server error: ${response.statusCode}, ${response.body}');
// //         // Don't throw - let it retry later
// //       }
// //     } catch (e) {
// //       debugPrint('❌ [REPO-OUT] Error posting data: $e');
// //       // Don't throw - let it retry later
// //     }
// //   }
// //   Future<void> saveFormAttendanceOut() async {
// //     debugPrint(
// //         "🎯 [ATTENDANCE-OUT] saveFormAttendanceOut() CALLED!"); // ADD THIS LINE
// //
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     // ... rest of your code
// //   }
// //
// //   Future<int> add(AttendanceOutModel attendanceoutModel) async {
// //     var dbClient = await dbHelper.db;
// //     return await dbClient.insert(
// //         attendanceOutTableName, attendanceoutModel.toMap());
// //   }
// //
// //   Future<int> update(AttendanceOutModel attendanceoutModel) async {
// //     var dbClient = await dbHelper.db;
// //     return await dbClient.update(
// //         attendanceOutTableName, attendanceoutModel.toMap(),
// //         where: 'attendance_out_id = ?',
// //         whereArgs: [attendanceoutModel.attendance_out_id]);
// //   }
// //
// //   Future<int> delete(String id) async {
// //     var dbClient = await dbHelper.db;
// //     return await dbClient.delete(attendanceOutTableName,
// //         where: 'attendance_out_id = ?', whereArgs: [id]);
// //   }
// //   Future<void> serialNumberGeneratorApi() async {
// //     await Config.fetchLatestConfig();
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     final orderDetailsGenerator = SerialNumberGenerator(
// //       apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOutSerial}$user_id',
// //       maxColumnName: 'max(attendance_out_id)',
// //       serialType: attendanceOutHighestSerial, // Unique identifier for shop visit serials
// //     );
// //      await orderDetailsGenerator.getAndIncrementSerialNumber();
// //      attendanceOutHighestSerial = orderDetailsGenerator.serialType;
// //      await prefs.setInt("attendanceOutHighestSerial", attendanceOutHighestSerial!);
// //   }
// // }
//
//
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class AttendanceOutRepository extends GetxService {
  DBHelper dbHelper = DBHelper();

  // ✅ ADD: Track posted IDs to prevent duplicate posting
  Set<String> _postedIds = {};

  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(attendanceOutTableName, columns: [
      'attendance_out_id',
      'attendance_out_date',
      'attendance_out_time',
      'user_id',
      'total_time',
      'lat_out',
      'lng_out',
      'total_distance',
      'address',
      'posted'
    ]);
    List<AttendanceOutModel> attendanceout = [];

    for (int i = 0; i < maps.length; i++) {
      attendanceout.add(AttendanceOutModel.fromMap(maps[i]));
    }

    debugPrint('📊 [REPO-OUT] Raw data from AttendanceOut database: ${maps.length} records');

    for (var map in maps) {
      debugPrint("   - ID: ${map['attendance_out_id']}, Posted: ${map['posted']}");
    }
    return attendanceout;
  }

  Future<void> fetchAndSaveAttendanceOut() async {
    try {
      debugPrint('🔍 [REPO-OUT] Fetching from API: ${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOut}$user_id');

      List<dynamic> data = await ApiService.getData(
          '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOut}$user_id'
      );

      var dbClient = await dbHelper.db;

      // Save data to database
      int savedCount = 0;
      for (var item in data) {
        try {
          item['posted'] = 1; // Set posted to 1 since it's from server
          AttendanceOutModel model = AttendanceOutModel.fromMap(item);

          // ✅ CHECK: Don't save duplicates
          List<Map> existing = await dbClient.query(
            attendanceOutTableName,
            where: 'attendance_out_id = ?',
            whereArgs: [model.attendance_out_id],
          );

          if (existing.isEmpty) {
            await dbClient.insert(attendanceOutTableName, model.toMap());
            savedCount++;
            debugPrint("✅ [REPO-OUT] Saved from API: ${model.attendance_out_id}");
          } else {
            debugPrint("⚠️ [REPO-OUT] Skipping duplicate from API: ${model.attendance_out_id}");
          }
        } catch (e) {
          debugPrint("❌ [REPO-OUT] Error saving item from API: $e");
        }
      }

      debugPrint("✅ [REPO-OUT] Fetched and saved $savedCount records from API");
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error fetching from API: $e');
    }
  }

  Future<List<AttendanceOutModel>> getUnPostedAttendanceOut() async {
    try {
      var dbClient = await dbHelper.db;
      List<Map> maps = await dbClient.query(
        attendanceOutTableName,
        where: 'posted = ?',
        whereArgs: [0], // Fetch records that have not been posted
      );

      List<AttendanceOutModel> attendanceOutModel =
      maps.map((map) => AttendanceOutModel.fromMap(map)).toList();

      debugPrint('📊 [REPO-OUT] Found ${attendanceOutModel.length} unposted records');

      return attendanceOutModel;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error getting unposted records: $e');
      return [];
    }
  }

  // ✅ UPDATED: Post data with STRICT duplicate prevention
  Future<void> postDataFromDatabaseToAPI() async {
    debugPrint('🔄 [REPO-OUT] ===== STARTING POST TO API =====');

    try {
      // Check network
      if (!await isNetworkAvailable()) {
        debugPrint('📴 [REPO-OUT] Network not available. Skipping post.');
        return;
      }

      var unPostedRecords = await getUnPostedAttendanceOut();

      if (unPostedRecords.isEmpty) {
        debugPrint('📭 [REPO-OUT] No unposted records to send');
        return;
      }

      debugPrint('📤 [REPO-OUT] Attempting to post ${unPostedRecords.length} records');

      // ✅ STRICT: Create a map to track which IDs we're processing
      Map<String, AttendanceOutModel> uniqueRecords = {};
      for (var record in unPostedRecords) {
        if (record.attendance_out_id != null) {
          uniqueRecords[record.attendance_out_id.toString()] = record;
        }
      }

      debugPrint('🔍 [REPO-OUT] After deduplication: ${uniqueRecords.length} unique records');

      int successCount = 0;
      int failCount = 0;

      for (var record in uniqueRecords.values) {
        try {
          // ✅ STRICT CHECK: Skip if already posted in this session
          if (_postedIds.contains(record.attendance_out_id.toString())) {
            debugPrint('⚠️ [REPO-OUT] Skipping already posted in this session: ${record.attendance_out_id}');
            continue;
          }

          // ✅ STRICT CHECK: Verify this is a valid record
          if (record.attendance_out_id == null || record.attendance_out_id.toString().isEmpty) {
            debugPrint('❌ [REPO-OUT] Invalid record ID, skipping');
            continue;
          }

          debugPrint('📤 [REPO-OUT] Posting: ${record.attendance_out_id}');

          bool posted = await _postSingleRecord(record);

          if (posted) {
            successCount++;
            // Mark as posted in local database
            record.posted = 1;
            await update(record);

            // Add to posted IDs to prevent duplicate posting in same session
            _postedIds.add(record.attendance_out_id.toString());

            debugPrint('✅ [REPO-OUT] Successfully posted: ${record.attendance_out_id}');
          } else {
            failCount++;
            debugPrint('❌ [REPO-OUT] Failed to post: ${record.attendance_out_id}');
          }

          // Small delay to avoid overwhelming server
          await Future.delayed(const Duration(milliseconds: 100));

        } catch (e) {
          failCount++;
          debugPrint('❌ [REPO-OUT] Error posting ${record.attendance_out_id}: $e');
        }
      }

      debugPrint('📊 [REPO-OUT] Posting results: $successCount success, $failCount failed');

      // ✅ Clean up any duplicate records after posting
      await _cleanDuplicateRecords();

    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error in postDataFromDatabaseToAPI: $e');
    }

    debugPrint('🔄 [REPO-OUT] ===== POST COMPLETED =====');
  }

  // ✅ UPDATED: Post single record with retry logic
  Future<bool> _postSingleRecord(AttendanceOutModel record) async {
    int maxRetries = 2; // Reduced retries to prevent duplicate attempts

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await Config.fetchLatestConfig();
        String apiUrl = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlAttendanceOut}';

        debugPrint('🌐 [REPO-OUT] Attempt $attempt: Posting to $apiUrl');

        var recordData = record.toMap();

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(recordData),
        ).timeout(const Duration(seconds: 15));

        debugPrint('📡 [REPO-OUT] Response: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ [REPO-OUT] Posted successfully: ${record.attendance_out_id}');
          return true;
        } else if (response.statusCode == 409) {
          // 409 Conflict - record already exists on server
          debugPrint('⚠️ [REPO-OUT] Record already exists on server: ${record.attendance_out_id}');
          return true; // Treat as success since record exists
        } else {
          debugPrint('❌ [REPO-OUT] Server error ${response.statusCode}');

          if (attempt < maxRetries) {
            debugPrint('🔄 [REPO-OUT] Retrying in 1 second...');
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      } catch (e) {
        debugPrint('❌ [REPO-OUT] Attempt $attempt failed: $e');

        if (attempt < maxRetries) {
          debugPrint('🔄 [REPO-OUT] Retrying in 1 second...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    return false; // All retries failed
  }

  // ✅ ADD: Check if record already exists before adding
  Future<bool> checkIfExists(String attendanceId) async {
    try {
      var dbClient = await dbHelper.db;
      List<Map> existing = await dbClient.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceId],
        limit: 1,
      );
      return existing.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error checking existence: $e');
      return false;
    }
  }

  // ✅ UPDATED: Add with strict duplicate check
  Future<int> add(AttendanceOutModel attendanceoutModel) async {
    try {
      var dbClient = await dbHelper.db;

      // ✅ STRICT CHECK: Check for duplicate before inserting
      bool exists = await checkIfExists(attendanceoutModel.attendance_out_id.toString());

      if (exists) {
        debugPrint('⚠️ [REPO-OUT] Duplicate record found, skipping: ${attendanceoutModel.attendance_out_id}');
        return 0; // Return 0 to indicate no insertion happened
      }

      debugPrint('✅ [REPO-OUT] Adding new record: ${attendanceoutModel.attendance_out_id}');
      return await dbClient.insert(
          attendanceOutTableName,
          attendanceoutModel.toMap()
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error adding record: $e');
      return -1; // Return -1 to indicate error
    }
  }

  Future<int> update(AttendanceOutModel attendanceoutModel) async {
    try {
      var dbClient = await dbHelper.db;
      debugPrint('✏️ [REPO-OUT] Updating record: ${attendanceoutModel.attendance_out_id}');

      return await dbClient.update(
          attendanceOutTableName,
          attendanceoutModel.toMap(),
          where: 'attendance_out_id = ?',
          whereArgs: [attendanceoutModel.attendance_out_id]
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error updating record: $e');
      rethrow;
    }
  }

  Future<int> delete(String id) async {
    try {
      var dbClient = await dbHelper.db;
      debugPrint('🗑️ [REPO-OUT] Deleting record: $id');

      return await dbClient.delete(
          attendanceOutTableName,
          where: 'attendance_out_id = ?',
          whereArgs: [id]
      );
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error deleting record: $e');
      rethrow;
    }
  }

  Future<void> serialNumberGeneratorApi() async {
    try {
      await Config.fetchLatestConfig();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final orderDetailsGenerator = SerialNumberGenerator(
        apiUrl: '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlAttendanceOutSerial}$user_id',
        maxColumnName: 'max(attendance_out_id)',
        serialType: attendanceOutHighestSerial,
      );

      await orderDetailsGenerator.getAndIncrementSerialNumber();
      attendanceOutHighestSerial = orderDetailsGenerator.serialType;

      await prefs.setInt("attendanceOutHighestSerial", attendanceOutHighestSerial!);

      debugPrint('🔢 [REPO-OUT] Generated serial: $attendanceOutHighestSerial');
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error in serialNumberGeneratorApi: $e');
    }
  }

  // ✅ FIXED: Clean duplicate records without id/createdAt
  Future<void> _cleanDuplicateRecords() async {
    try {
      var dbClient = await dbHelper.db;

      // Get all attendance_out_ids
      List<Map> allRecords = await dbClient.query(
        attendanceOutTableName,
        columns: ['attendance_out_id'],
      );

      Set<String> uniqueIds = {};
      List<String> duplicateIds = [];

      // Find duplicate IDs
      for (var record in allRecords) {
        String id = record['attendance_out_id'].toString();
        if (uniqueIds.contains(id)) {
          duplicateIds.add(id);
        } else {
          uniqueIds.add(id);
        }
      }

      // Remove duplicates
      for (String duplicateId in duplicateIds) {
        debugPrint('⚠️ [REPO-OUT] Found duplicates for ID: $duplicateId');

        // Get all records with this ID
        List<Map> duplicates = await dbClient.query(
          attendanceOutTableName,
          where: 'attendance_out_id = ?',
          whereArgs: [duplicateId],
        );

        if (duplicates.length > 1) {
          // Keep the first one, delete the rest
          for (int i = 1; i < duplicates.length; i++) {
            await dbClient.delete(
              attendanceOutTableName,
              where: 'rowid = ?', // Use SQLite's rowid
              whereArgs: [duplicates[i]['rowid']],
            );
          }
          debugPrint('✅ [REPO-OUT] Cleaned ${duplicates.length - 1} duplicates for ID: $duplicateId');
        }
      }

    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error cleaning duplicates: $e');
    }
  }

  // ✅ ADDED: Get record by ID
  Future<AttendanceOutModel?> getRecordById(String attendanceId) async {
    try {
      var dbClient = await dbHelper.db;
      List<Map> maps = await dbClient.query(
        attendanceOutTableName,
        where: 'attendance_out_id = ?',
        whereArgs: [attendanceId],
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

  // ✅ ADDED: Clear posted IDs cache
  void clearPostedCache() {
    _postedIds.clear();
    debugPrint('🧹 [REPO-OUT] Cleared posted IDs cache');
  }

  // ✅ ADDED: Force mark record as posted (for manual fixes)
  Future<void> markAsPosted(String attendanceId) async {
    try {
      var record = await getRecordById(attendanceId);
      if (record != null) {
        record.posted = 1;
        await update(record);
        debugPrint('✅ [REPO-OUT] Manually marked as posted: $attendanceId');
      }
    } catch (e) {
      debugPrint('❌ [REPO-OUT] Error marking as posted: $e');
    }
  }
}

