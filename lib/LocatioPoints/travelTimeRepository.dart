// // // import 'dart:convert';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:get/get.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
// // // import 'package:sqflite/sqflite.dart';
// // // import '../Databases/dp_helper.dart';
// // // import '../Services/ApiServices/api_service.dart';
// // // import '../Services/FirebaseServices/firebase_remote_config.dart';
// // //
// // // class TravelTimeRepository extends GetxService {
// // //   DBHelper dbHelper = Get.put(DBHelper());
// // //
// // //   @override
// // //   Future<void> onInit() async {
// // //     super.onInit();
// // //     await _ensureTableCreated(); // 🔥 ٹیبل بنانے کی تصدیق کریں
// // //   }
// // //   Future<void> _ensureTableCreated() async {
// // //     try {
// // //       var dbClient = await dbHelper.db;
// // //       await dbClient.execute(createTableQuery);
// // //       print('✅ Travelllllllllllllllllll time table created successfully');
// // //     } catch (e) {
// // //       print('❌ Error creating travel time table: $e');
// // //     }
// // //   }
// // //   // ڈیٹا بیس میں ٹیبل بنانے کا query
// // //   String get createTableQuery => """
// // //     CREATE TABLE IF NOT EXISTS travel_time_data (
// // //       id TEXT PRIMARY KEY,
// // //       user_id TEXT,
// // //       travel_date TEXT,
// // //       start_time TEXT,
// // //       end_time TEXT,
// // //       travel_distance TEXT,
// // //       travel_time TEXT,
// // //       average_speed TEXT,
// // //       working_time TEXT,
// // //       stationary_time TEXT,
// // //       travel_type TEXT,
// // //       latitude TEXT,
// // //       longitude TEXT,
// // //       address TEXT,
// // //       posted INTEGER DEFAULT 0
// // //     )
// // //   """;
// // //
// // //   Future<List<TravelTimeModel>> getTravelTimeData() async {
// // //     var dbClient = await dbHelper.db;
// // //     List<Map> maps = await dbClient.query('travel_time_data');
// // //     return maps.map((map) => TravelTimeModel.fromMap(map)).toList();
// // //   }
// // //
// // //   Future<int> addTravelTimeData(TravelTimeModel model) async {
// // //     var dbClient = await dbHelper.db;
// // //     return await dbClient.insert('travel_time_data', model.toMap());
// // //   }
// // //
// // //   Future<int> updateTravelTimeData(TravelTimeModel model) async {
// // //     var dbClient = await dbHelper.db;
// // //     return await dbClient.update(
// // //         'travel_time_data',
// // //         model.toMap(),
// // //         where: 'id = ?',
// // //         whereArgs: [model.id]
// // //     );
// // //   }
// // //
// // //   // API کے لیے ڈیٹا پوسٹ کرنا
// // //   Future<void> postTravelTimeToAPI(TravelTimeModel model) async {
// // //     try {
// // //       await Config.fetchLatestConfig();
// // //       final response = await http.post(
// // //         Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}/api/travel-time"),
// // //         headers: {
// // //           "Content-Type": "application/json",
// // //           "Accept": "application/json",
// // //         },
// // //         body: jsonEncode(model.toMap()),
// // //       );
// // //
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         debugPrint('Travel time data posted successfully');
// // //       } else {
// // //         throw Exception('Server error: ${response.statusCode}');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error posting travel time data: $e');
// // //       throw Exception('Failed to post travel time data: $e');
// // //     }
// // //   }
// // //
// // //   // Unposted ڈیٹا حاصل کرنا
// // //   Future<List<TravelTimeModel>> getUnpostedTravelTimeData() async {
// // //     var dbClient = await dbHelper.db;
// // //     List<Map> maps = await dbClient.query(
// // //       'travel_time_data',
// // //       where: 'posted = ?',
// // //       whereArgs: [0],
// // //     );
// // //     return maps.map((map) => TravelTimeModel.fromMap(map)).toList();
// // //   }
// // //
// // //   // تمام unposted ڈیٹا کو API پر سینک کرنا
// // //   Future<void> syncTravelTimeData() async {
// // //     var unpostedData = await getUnpostedTravelTimeData();
// // //
// // //     for (var data in unpostedData) {
// // //       try {
// // //         await postTravelTimeToAPI(data);
// // //         data.posted = 1;
// // //         await updateTravelTimeData(data);
// // //       } catch (e) {
// // //         debugPrint('Failed to sync travel time data: $e');
// // //       }
// // //     }
// // //   }
// // // }
// //
// //
// //
// // // TravelTimeRepository.dart
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:sqflite/sqflite.dart';
// //
// // import '../Databases/dp_helper.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// // class TravelTimeRepository extends GetxController {
// //   final DBHelper _dbHelper = Get.find<DBHelper>();
// //
// //   // ڈیٹا بیس میں ڈیٹا شامل کریں
// //   Future<void> addTravelTimeData(TravelTimeModel model) async {
// //     try {
// //       final db = await _dbHelper.db;
// //       await db.insert(
// //         travelTimeData,
// //         model.toMap(),
// //         conflictAlgorithm: ConflictAlgorithm.replace,
// //       );
// //       debugPrint('✅ Travel time data saved to database: ${model.id}');
// //     } catch (e) {
// //       debugPrint('❌ Error saving travel time data: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // ڈیٹا بیس سے ڈیٹا حاصل کریں
// //   Future<List<TravelTimeModel>> getTravelTimeData() async {
// //     try {
// //       final db = await _dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         travelTimeData,
// //         orderBy: 'travel_date DESC, start_time DESC',
// //       );
// //
// //       return List.generate(maps.length, (i) {
// //         return TravelTimeModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ Error fetching travel time data: $e');
// //       return [];
// //     }
// //   }
// //   // API کے لیے ڈیٹا پوسٹ کرنا
// //   Future<void> postTravelTimeToAPI(TravelTimeModel model) async {
// //     try {
// //       await Config.fetchLatestConfig();
// //       final response = await http.post(
// //         Uri.parse("${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}/api/travel-time"),
// //         headers: {
// //           "Content-Type": "application/json",
// //           "Accept": "application/json",
// //         },
// //         body: jsonEncode(model.toMap()),
// //       );
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         debugPrint('Travel time data posted successfully');
// //       } else {
// //         throw Exception('Server error: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       debugPrint('Error posting travel time data: $e');
// //       throw Exception('Failed to post travel time data: $e');
// //     }
// //   }
// //   // غیر posted ڈیٹا حاصل کریں
// //   Future<List<TravelTimeModel>> getUnpostedTravelTimeData() async {
// //     try {
// //       final db = await _dbHelper.db;
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         travelTimeData,
// //         where: 'posted = ?',
// //         whereArgs: [0],
// //         orderBy: 'travel_date DESC, start_time DESC',
// //       );
// //
// //       return List.generate(maps.length, (i) {
// //         return TravelTimeModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ Error fetching unposted travel time data: $e');
// //       return [];
// //     }
// //   }
// //
// //   // ڈیٹا کو posted mark کریں
// //   Future<void> markAsPosted(String id) async {
// //     try {
// //       final db = await _dbHelper.db;
// //       await db.update(
// //         travelTimeData,
// //         {'posted': 1},
// //         where: 'id = ?',
// //         whereArgs: [id],
// //       );
// //       debugPrint('✅ Travel time data marked as posted: $id');
// //     } catch (e) {
// //       debugPrint('❌ Error marking travel time data as posted: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // API پر ڈیٹا sync کریں
// //   Future<void> syncTravelTimeData() async {
// //     try {
// //       final unpostedData = await getUnpostedTravelTimeData();
// //
// //       for (var data in unpostedData) {
// //         // یہاں API call کریں
// //         bool syncSuccess =  postTravelTimeToAPI;
// //
// //         if (syncSuccess) {
// //           await markAsPosted(data.id!);
// //           debugPrint('✅ Synced to API: ${data.id}');
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error syncing travel time data: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // API synchronization method (آپ کو اپنے API کے مطابق customize کرنا ہوگا)
// //   // Future<bool> _syncToAPI(TravelTimeModel data) async {
// //   //   try {
// //   //     // یہاں آپ کا API integration code ہوگا
// //   //     // Example:
// //   //     // final response = await http.post(
// //   //     //   Uri.parse('your-api-url'),
// //   //     //   headers: {'Content-Type': 'application/json'},
// //   //     //   body: jsonEncode(data.toMap()),
// //   //     // );
// //   //
// //   //     // return response.statusCode == 200;
// //   //
// //   //     // فی الحال کے لیے ہم simulate کر رہے ہیں
// //   //     await Future.delayed( const Duration(milliseconds: 100));
// //   //     return true;
// //   //   } catch (e) {
// //   //     debugPrint('❌ API sync error: $e');
// //   //     return false;
// //   //   }
// //   // }
// //
// //   // ڈیٹا ڈیلیٹ کریں
// //   Future<void> deleteTravelTimeData(String id) async {
// //     try {
// //       final db = await _dbHelper.db;
// //       await db.delete(
// //         travelTimeData,
// //         where: 'id = ?',
// //         whereArgs: [id],
// //       );
// //       debugPrint('✅ Travel time data deleted: $id');
// //     } catch (e) {
// //       debugPrint('❌ Error deleting travel time data: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // آج کا ڈیٹا حاصل کریں
// //   Future<List<TravelTimeModel>> getTodayData() async {
// //     try {
// //       final db = await _dbHelper.db;
// //       final String today = '${DateTime.now().day}-${_getMonthAbbreviation(DateTime.now().month)}-${DateTime.now().year}';
// //
// //       final List<Map<String, dynamic>> maps = await db.query(
// //         travelTimeData,
// //         where: 'travel_date = ?',
// //         whereArgs: [today],
// //         orderBy: 'start_time DESC',
// //       );
// //
// //       return List.generate(maps.length, (i) {
// //         return TravelTimeModel.fromMap(maps[i]);
// //       });
// //     } catch (e) {
// //       debugPrint('❌ Error fetching today\'s data: $e');
// //       return [];
// //     }
// //   }
// //
// //   String _getMonthAbbreviation(int month) {
// //     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
// //     return months[month - 1];
// //   }
// // }
//
// // TravelTimeRepository.dart
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../Databases/dp_helper.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class TravelTimeRepository extends GetxController {
//   final DBHelper _dbHelper = Get.find<DBHelper>();
//
//   // ڈیٹا بیس میں ڈیٹا شامل کریں
//   Future<void> addTravelTimeData(TravelTimeModel model) async {
//     try {
//       final db = await _dbHelper.db;
//       await db.insert(
//         travelTimeData,
//         model.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//       debugPrint('✅ Travel time data saved to database: ${model.id}');
//     } catch (e) {
//       debugPrint('❌ Error saving travel time data: $e');
//       rethrow;
//     }
//   }
//
//   // ڈیٹا بیس سے ڈیٹا حاصل کریں
//   Future<List<TravelTimeModel>> getTravelTimeData() async {
//     try {
//       final db = await _dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         travelTimeData,
//         orderBy: 'travel_date DESC, start_time DESC',
//       );
//
//       return List.generate(maps.length, (i) {
//         return TravelTimeModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ Error fetching travel time data: $e');
//       return [];
//     }
//   }
//
//   // API کے لیے ڈیٹا پوسٹ کرنا
//   Future<bool> postTravelTimeToAPI(TravelTimeModel model) async {
//     try {
//       // 🔹 Step 1: Fetch latest Firebase Remote Config
//       await Config.fetchLatestConfig();
//
//       // 🔹 Step 2: Safely build API URL (null safety + debugging)
//       final apiUrl =
//           '${Config.postApiUrlTravelData ?? ""}';
//       debugPrint('🌐 Final TravelData API URL => $apiUrl');
//
//       // 🔹 Step 3: Prepare JSON body (apiData)
//       final Map<String, dynamic> apiData = {
//         "id": model.id,
//         "user_id": model.userId,
//         "travel_date": model.travel_date,
//         "start_time": model.startTime,
//         "end_time": model.endTime,
//         "travel_distance": model.travelDistance?.toString() ?? "0.0",
//         "travel_time": model.travelTime?.toString() ?? "0.0",
//         "average_speed": model.averageSpeed?.toString() ?? "0.0",
//         "working_time": model.workingTime?.toString() ?? "0.0",
//         "stationary_time": model.stationaryTime?.toString() ?? "0.0",
//         "travel_type": model.travelType,
//         "latitude": model.latitude?.toString() ?? "0.0",
//         "longitude": model.longitude?.toString() ?? "0.0",
//         "address": model.address ?? "Not available",
//         "posted": model.posted,
//       };
//
//       debugPrint('📦 Posting travel data for ID: ${model.id}');
//       debugPrint('📤 JSON Body: $apiData');
//
//       // 🔹 Step 4: Send HTTP POST request
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(apiData),
//       );
//
//       // 🔹 Step 5: Debug the response
//       debugPrint('📡 API Response Status: ${response.statusCode}');
//       debugPrint('📡 API Response Body: ${response.body}');
//
//       // 🔹 Step 6: Return based on response status
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint('✅ Travel time data posted successfully: ${model.id}');
//         return true;
//       } else {
//         debugPrint('❌ Server error: ${response.statusCode} - ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('❌ Exception while posting travel time: $e');
//       return false;
//     }
//   }
//
//
//   // غیر posted ڈیٹا حاصل کریں
//   Future<List<TravelTimeModel>> getUnpostedTravelTimeData() async {
//     try {
//       final db = await _dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         travelTimeData,
//         where: 'posted = ?',
//         whereArgs: [0],
//         orderBy: 'travel_date DESC, start_time DESC',
//       );
//
//       return List.generate(maps.length, (i) {
//         return TravelTimeModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ Error fetching unposted travel time data: $e');
//       return [];
//     }
//   }
//
//   // ڈیٹا کو posted mark کریں
//   Future<void> markAsPosted(String id) async {
//     try {
//       final db = await _dbHelper.db;
//       await db.update(
//         travelTimeData,
//         {'posted': 1},
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       debugPrint('✅ Travel time data marked as posted: $id');
//     } catch (e) {
//       debugPrint('❌ Error marking travel time data as posted: $e');
//       rethrow;
//     }
//   }
//
//   // API پر ڈیٹا sync کریں
//   Future<Map<String, dynamic>> syncTravelTimeData() async {
//     try {
//       final unpostedData = await getUnpostedTravelTimeData();
//       debugPrint('🔄 Starting sync for ${unpostedData.length} unposted records');
//
//       if (unpostedData.isEmpty) {
//         return {
//           'success': true,
//           'message': 'No data to sync',
//           'syncedCount': 0,
//           'failedCount': 0
//         };
//       }
//
//       int successCount = 0;
//       int failedCount = 0;
//       List<String> failedIds = [];
//
//       for (var data in unpostedData) {
//         try {
//           bool syncSuccess = await postTravelTimeToAPI(data);
//
//           if (syncSuccess) {
//             await markAsPosted(data.id!);
//             successCount++;
//             debugPrint('✅ Successfully synced: ${data.id}');
//           } else {
//             failedCount++;
//             failedIds.add(data.id!);
//             debugPrint('❌ Failed to sync: ${data.id}');
//           }
//
//           // Throttle API calls to avoid overwhelming the server
//           await Future.delayed(const Duration(milliseconds: 500));
//         } catch (e) {
//           failedCount++;
//           failedIds.add(data.id!);
//           debugPrint('❌ Error syncing ${data.id}: $e');
//         }
//       }
//
//       final result = {
//         'success': failedCount == 0,
//         'message': 'Synced $successCount out of ${unpostedData.length} records',
//         'syncedCount': successCount,
//         'failedCount': failedCount,
//         'failedIds': failedIds,
//       };
//
//       debugPrint('📊 Sync Result: $result');
//       return result;
//
//     } catch (e) {
//       debugPrint('❌ Error in syncTravelTimeData: $e');
//       return {
//         'success': false,
//         'message': 'Sync failed: $e',
//         'syncedCount': 0,
//         'failedCount': 0,
//         'failedIds': [],
//       };
//     }
//   }
//
//   // Batch sync - تمام ڈیٹا ایک ساتھ بھیجنا
//   Future<Map<String, dynamic>> syncTravelTimeDataBatch() async {
//     try {
//       final unpostedData = await getUnpostedTravelTimeData();
//
//       if (unpostedData.isEmpty) {
//         return {
//           'success': true,
//           'message': 'No data to sync',
//           'syncedCount': 0
//         };
//       }
//
//       await Config.fetchLatestConfig();
//
//       List<Map<String, dynamic>> batchData = [];
//       for (var data in unpostedData) {
//         batchData.add({
//           "id": data.id,
//           "user_id": data.userId,
//           "travel_date": data.travel_date,
//           "start_time": data.startTime,
//           "end_time": data.endTime,
//           "travel_distance": data.travelDistance?.toString() ?? "0.0",
//           "travel_time": data.travelTime?.toString() ?? "0.0",
//           "average_speed": data.averageSpeed?.toString() ?? "0.0",
//           "working_time": data.workingTime?.toString() ?? "0.0",
//           "stationary_time": data.stationaryTime?.toString() ?? "0.0",
//           "travel_type": data.travelType,
//           "latitude": data.latitude?.toString() ?? "0.0",
//           "longitude": data.longitude?.toString() ?? "0.0",
//           "address": data.address ?? "Not available",
//           "posted": data.posted,
//         });
//       }
//
//       debugPrint('🌐 Posting batch data to API: ${batchData.length} records');
//
//       final response = await http.post(
//         Uri.parse("${Config.postApiUrlTravelData}"),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode({"data": batchData}),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // Mark all as posted
//         for (var data in unpostedData) {
//           await markAsPosted(data.id!);
//         }
//
//         debugPrint('✅ Batch sync successful: ${batchData.length} records');
//         return {
//           'success': true,
//           'message': 'Successfully synced ${batchData.length} records',
//           'syncedCount': batchData.length,
//         };
//       } else {
//         debugPrint('❌ Batch sync failed: ${response.statusCode}');
//         return {
//           'success': false,
//           'message': 'Server error: ${response.statusCode}',
//           'syncedCount': 0,
//         };
//       }
//     } catch (e) {
//       debugPrint('❌ Error in batch sync: $e');
//       return {
//         'success': false,
//         'message': 'Batch sync failed: $e',
//         'syncedCount': 0,
//       };
//     }
//   }
//
//   // ڈیٹا ڈیلیٹ کریں
//   Future<void> deleteTravelTimeData(String id) async {
//     try {
//       final db = await _dbHelper.db;
//       await db.delete(
//         travelTimeData,
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       debugPrint('✅ Travel time data deleted: $id');
//     } catch (e) {
//       debugPrint('❌ Error deleting travel time data: $e');
//       rethrow;
//     }
//   }
//
//   // تمام ڈیٹا ڈیلیٹ کریں (صرف development کے لیے)
//   Future<void> deleteAllTravelTimeData() async {
//     try {
//       final db = await _dbHelper.db;
//       await db.delete(travelTimeData);
//       debugPrint('✅ All travel time data deleted');
//     } catch (e) {
//       debugPrint('❌ Error deleting all travel time data: $e');
//       rethrow;
//     }
//   }
//
//   // آج کا ڈیٹا حاصل کریں
//   Future<List<TravelTimeModel>> getTodayData() async {
//     try {
//       final db = await _dbHelper.db;
//       final String today = '${DateTime.now().day}-${_getMonthAbbreviation(DateTime.now().month)}-${DateTime.now().year}';
//
//       final List<Map<String, dynamic>> maps = await db.query(
//         travelTimeData,
//         where: 'travel_date = ?',
//         whereArgs: [today],
//         orderBy: 'start_time DESC',
//       );
//
//       return List.generate(maps.length, (i) {
//         return TravelTimeModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ Error fetching today\'s data: $e');
//       return [];
//     }
//   }
//
//   // مخصوص تاریخ کا ڈیٹا حاصل کریں
//   Future<List<TravelTimeModel>> getDataByDate(String date) async {
//     try {
//       final db = await _dbHelper.db;
//       final List<Map<String, dynamic>> maps = await db.query(
//         travelTimeData,
//         where: 'travel_date = ?',
//         whereArgs: [date],
//         orderBy: 'start_time DESC',
//       );
//
//       return List.generate(maps.length, (i) {
//         return TravelTimeModel.fromMap(maps[i]);
//       });
//     } catch (e) {
//       debugPrint('❌ Error fetching data for date $date: $e');
//       return [];
//     }
//   }
//
//   // ڈیٹا کی تعداد حاصل کریں
//   Future<int> getTravelTimeDataCount() async {
//     try {
//       final db = await _dbHelper.db;
//       final count = Sqflite.firstIntValue(
//           await db.rawQuery('SELECT COUNT(*) FROM $travelTimeData')
//       );
//       return count ?? 0;
//     } catch (e) {
//       debugPrint('❌ Error getting travel time data count: $e');
//       return 0;
//     }
//   }
//
//   // Unposted ڈیٹا کی تعداد حاصل کریں
//   Future<int> getUnpostedDataCount() async {
//     try {
//       final db = await _dbHelper.db;
//       final count = Sqflite.firstIntValue(
//           await db.rawQuery('SELECT COUNT(*) FROM $travelTimeData WHERE posted = 0')
//       );
//       return count ?? 0;
//     } catch (e) {
//       debugPrint('❌ Error getting unposted data count: $e');
//       return 0;
//     }
//   }
//
//   String _getMonthAbbreviation(int month) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[month - 1];
//   }
//
//   // Network connectivity چیک کرنے کا method
//   Future<bool> checkNetworkConnectivity() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://www.google.com'),
//         headers: {'Content-Type': 'application/json'},
//       );
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('❌ Network connectivity check failed: $e');
//       return false;
//     }
//   }
// }




// TravelTimeRepository.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
import 'package:sqflite/sqflite.dart';

import '../Databases/dp_helper.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class TravelTimeRepository extends GetxController {
  final DBHelper _dbHelper = Get.find<DBHelper>();

  // ڈیٹا بیس میں ڈیٹا شامل کریں
  Future<void> addTravelTimeData(TravelTimeModel model) async {
    try {
      final db = await _dbHelper.db;
      await db.insert(
        travelTimeData,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Travel time data saved to database: ${model.id}');
    } catch (e) {
      debugPrint('❌ Error saving travel time data: $e');
      rethrow;
    }
  }

  // ڈیٹا بیس سے ڈیٹا حاصل کریں
  Future<List<TravelTimeModel>> getTravelTimeData() async {
    try {
      final db = await _dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        travelTimeData,
        orderBy: 'travel_date DESC, start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return TravelTimeModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ Error fetching travel time data: $e');
      return [];
    }
  }

  // API کے لیے ڈیٹا پوسٹ کرنا
  Future<bool> postTravelTimeToAPI(TravelTimeModel model) async {
    try {
      // 🔹 Step 1: Fetch latest Firebase Remote Config
      await Config.fetchLatestConfig();

      // 🔹 Step 2: Safely build API URL (null safety + debugging)
      final apiUrl =
          '${Config.postApiUrlTravelData}';
      debugPrint('🌐 Final TravelData API URL => $apiUrl');

      // 🔹 Step 3: Prepare JSON body (apiData)
      final Map<String, dynamic> apiData = {
        "id": model.id,
        "user_id": model.userId,
        "travel_date": model.travel_date,
        "start_time": model.startTime,
        "end_time": model.endTime,
        "travel_distance": model.travelDistance?.toString() ?? "0.0",
        "travel_time": model.travelTime?.toString() ?? "0.0",
        "average_speed": model.averageSpeed?.toString() ?? "0.0",
        "working_time": model.workingTime?.toString() ?? "0.0",
        "idle_time": model.idleTime?.toString() ?? "0.0",
        "travel_type": model.travelType,
        "latitude": model.latitude?.toString() ?? "0.0",
        "longitude": model.longitude?.toString() ?? "0.0",
        "address": model.address ?? "Not available",
        "posted": model.posted,
      };

      debugPrint('📦 Posting travel data for ID: ${model.id}');
      debugPrint('📤 JSON Body: $apiData');

      // 🔹 Step 4: Send HTTP POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(apiData),
      );

      // 🔹 Step 5: Debug the response
      debugPrint('📡 API Response Status: ${response.statusCode}');
      debugPrint('📡 API Response Body: ${response.body}');

      // 🔹 Step 6: Return based on response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Travel time data posted successfully: ${model.id}');
        return true;
      } else {
        debugPrint('❌ Server error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception while posting travel time: $e');
      return false;
    }
  }


  // غیر posted ڈیٹا حاصل کریں
  Future<List<TravelTimeModel>> getUnpostedTravelTimeData() async {
    try {
      final db = await _dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        travelTimeData,
        where: 'posted = ?',
        whereArgs: [0],
        orderBy: 'travel_date DESC, start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return TravelTimeModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ Error fetching unposted travel time data: $e');
      return [];
    }
  }

  // ڈیٹا کو posted mark کریں
  Future<void> markAsPosted(String id) async {
    try {
      final db = await _dbHelper.db;
      await db.update(
        travelTimeData,
        {'posted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Travel time data marked as posted: $id');
    } catch (e) {
      debugPrint('❌ Error marking travel time data as posted: $e');
      rethrow;
    }
  }

  // API پر ڈیٹا sync کریں
  Future<Map<String, dynamic>> syncTravelTimeData() async {
    try {
      final unpostedData = await getUnpostedTravelTimeData();
      debugPrint('🔄 Starting sync for ${unpostedData.length} unposted records');

      if (unpostedData.isEmpty) {
        return {
          'success': true,
          'message': 'No data to sync',
          'syncedCount': 0,
          'failedCount': 0
        };
      }

      int successCount = 0;
      int failedCount = 0;
      List<String> failedIds = [];

      for (var data in unpostedData) {
        try {
          bool syncSuccess = await postTravelTimeToAPI(data);

          if (syncSuccess) {
            await markAsPosted(data.id!);
            successCount++;
            debugPrint('✅ Successfully synced: ${data.id}');
          } else {
            failedCount++;
            failedIds.add(data.id!);
            debugPrint('❌ Failed to sync: ${data.id}');
          }

          // Throttle API calls to avoid overwhelming the server
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          failedCount++;
          failedIds.add(data.id!);
          debugPrint('❌ Error syncing ${data.id}: $e');
        }
      }

      final result = {
        'success': failedCount == 0,
        'message': 'Synced $successCount out of ${unpostedData.length} records',
        'syncedCount': successCount,
        'failedCount': failedCount,
        'failedIds': failedIds,
      };

      debugPrint('📊 Sync Result: $result');
      return result;

    } catch (e) {
      debugPrint('❌ Error in syncTravelTimeData: $e');
      return {
        'success': false,
        'message': 'Sync failed: $e',
        'syncedCount': 0,
        'failedCount': 0,
        'failedIds': [],
      };
    }
  }

  // Batch sync - تمام ڈیٹا ایک ساتھ بھیجنا
  Future<Map<String, dynamic>> syncTravelTimeDataBatch() async {
    try {
      final unpostedData = await getUnpostedTravelTimeData();

      if (unpostedData.isEmpty) {
        return {
          'success': true,
          'message': 'No data to sync',
          'syncedCount': 0
        };
      }

      await Config.fetchLatestConfig();

      List<Map<String, dynamic>> batchData = [];
      for (var data in unpostedData) {
        batchData.add({
          "id": data.id,
          "user_id": data.userId,
          "travel_date": data.travel_date,
          "start_time": data.startTime,
          "end_time": data.endTime,
          "travel_distance": data.travelDistance?.toString() ?? "0.0",
          "travel_time": data.travelTime?.toString() ?? "0.0",
          "average_speed": data.averageSpeed?.toString() ?? "0.0",
          "working_time": data.workingTime?.toString() ?? "0.0",
          "idle_time": data.idleTime?.toString() ?? "0.0",
          "travel_type": data.travelType,
          "latitude": data.latitude?.toString() ?? "0.0",
          "longitude": data.longitude?.toString() ?? "0.0",
          "address": data.address ?? "Not available",
          "posted": data.posted,
        });
      }

      debugPrint('🌐 Posting batch data to API: ${batchData.length} records');

      final response = await http.post(
        Uri.parse("${Config.postApiUrlTravelData}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"data": batchData}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark all as posted
        for (var data in unpostedData) {
          await markAsPosted(data.id!);
        }

        debugPrint('✅ Batch sync successful: ${batchData.length} records');
        return {
          'success': true,
          'message': 'Successfully synced ${batchData.length} records',
          'syncedCount': batchData.length,
        };
      } else {
        debugPrint('❌ Batch sync failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'syncedCount': 0,
        };
      }
    } catch (e) {
      debugPrint('❌ Error in batch sync: $e');
      return {
        'success': false,
        'message': 'Batch sync failed: $e',
        'syncedCount': 0,
      };
    }
  }

  // ڈیٹا ڈیلیٹ کریں
  Future<void> deleteTravelTimeData(String id) async {
    try {
      final db = await _dbHelper.db;
      await db.delete(
        travelTimeData,
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Travel time data deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting travel time data: $e');
      rethrow;
    }
  }

  // تمام ڈیٹا ڈیلیٹ کریں (صرف development کے لیے)
  Future<void> deleteAllTravelTimeData() async {
    try {
      final db = await _dbHelper.db;
      await db.delete(travelTimeData);
      debugPrint('✅ All travel time data deleted');
    } catch (e) {
      debugPrint('❌ Error deleting all travel time data: $e');
      rethrow;
    }
  }

  // آج کا ڈیٹا حاصل کریں
  Future<List<TravelTimeModel>> getTodayData() async {
    try {
      final db = await _dbHelper.db;
      final String today = '${DateTime.now().day}-${_getMonthAbbreviation(DateTime.now().month)}-${DateTime.now().year}';

      final List<Map<String, dynamic>> maps = await db.query(
        travelTimeData,
        where: 'travel_date = ?',
        whereArgs: [today],
        orderBy: 'start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return TravelTimeModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ Error fetching today\'s data: $e');
      return [];
    }
  }

  // مخصوص تاریخ کا ڈیٹا حاصل کریں
  Future<List<TravelTimeModel>> getDataByDate(String date) async {
    try {
      final db = await _dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        travelTimeData,
        where: 'travel_date = ?',
        whereArgs: [date],
        orderBy: 'start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return TravelTimeModel.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('❌ Error fetching data for date $date: $e');
      return [];
    }
  }

  // ڈیٹا کی تعداد حاصل کریں
  Future<int> getTravelTimeDataCount() async {
    try {
      final db = await _dbHelper.db;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $travelTimeData')
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting travel time data count: $e');
      return 0;
    }
  }


  // Unposted ڈیٹا کی تعداد حاصل کریں
  Future<int> getUnpostedDataCount() async {
    try {
      final db = await _dbHelper.db;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $travelTimeData WHERE posted = 0')
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting unposted data count: $e');
      return 0;
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  // آخر میں add کریں
  Future<int> getLastSerialForMonth(String userId, String month) async {
    try {
      final db = await _dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT id FROM $travelTimeData WHERE user_id = ? AND travel_date LIKE ? ORDER BY id DESC LIMIT 1',
        [userId, '%-$month-%'],
      );

      if (maps.isNotEmpty) {
        String lastId = maps.first['id'];
        final parts = lastId.split('-'); // ID کے last part کو extract کرے گا
        return int.tryParse(parts.last) ?? 0;
      }
    } catch (e) {
      debugPrint('❌ Error fetching last serial: $e');
    }
    return 0;
  }


  // Network connectivity چیک کرنے کا method
  Future<bool> checkNetworkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Network connectivity check failed: $e');
      return false;
    }
  }
}
