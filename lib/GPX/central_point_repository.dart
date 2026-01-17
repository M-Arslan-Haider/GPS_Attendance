// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
// import '../Databases/dp_helper.dart';
// import '../Databases/util.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
// import 'central_point_model.dart';
//
// class CentralPointsRepository {
//   DBHelper dbHelper = DBHelper();
//
//   // Throttling prevention flags
//   static bool _isPosting = false;
//   static DateTime? _lastConfigFetchTime;
//   static const Duration _minConfigFetchInterval = Duration(minutes: 5);
//   static const Duration _minApiCallInterval = Duration(seconds: 2);
//   int centralPointSerialCounter = 1;
//
//   // --------------------------------------------------------
//   // INSERT CENTRAL POINT
//   // --------------------------------------------------------
//   Future<int> addCentralPoint(CentralPointsModel centralPoint) async {
//     var dbClient = await dbHelper.db;
//
//     return await dbClient.insert(
//       centralPoints,
//       centralPoint.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   // --------------------------------------------------------
//   // SAVE MULTIPLE CLUSTERS AS SEPARATE RECORDS
//   // --------------------------------------------------------
// // ADD THIS METHOD TO CentralPointsRepository class
//   Future<void> saveIndividualClusters(List<CentralPointsModel> clusters) async {
//     var dbClient = await dbHelper.db;
//     var batch = dbClient.batch();
//
//     for (var cluster in clusters) {
//       batch.insert(
//         centralPoints,
//         cluster.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }
//
//     await batch.commit();
//     debugPrint("💾 Saved ${clusters.length} individual clusters to database");
//   }
//
//   // --------------------------------------------------------
//   // GET ALL CENTRAL POINTS
//   // --------------------------------------------------------
//   Future<List<CentralPointsModel>> getCentralPoints() async {
//     var dbClient = await dbHelper.db;
//
//     final maps = await dbClient.query(centralPoints);
//     return maps.map((e) => CentralPointsModel.fromMap(e)).toList();
//   }
//
//   // --------------------------------------------------------
//   // GET UNPOSTED CENTRAL POINTS
//   // --------------------------------------------------------
//   Future<List<CentralPointsModel>> getUnPostedCentralPoints() async {
//     var dbClient = await dbHelper.db;
//
//     final maps = await dbClient.query(
//       centralPoints,
//       where: "posted = ?",
//       whereArgs: [0],
//     );
//
//     return maps.map((e) => CentralPointsModel.fromMap(e)).toList();
//   }
//
//   // --------------------------------------------------------
//   // UPDATE CENTRAL POINT
//   // --------------------------------------------------------
//   Future<int> updateCentralPoint(CentralPointsModel centralPoint) async {
//     var dbClient = await dbHelper.db;
//
//     return await dbClient.update(
//       centralPoints,
//       centralPoint.toMap(),
//       where: "central_point_id = ?",
//       whereArgs: [centralPoint.centralPointId],
//     );
//   }
//
//   // --------------------------------------------------------
//   // DELETE CENTRAL POINT
//   // --------------------------------------------------------
//   Future<int> deleteCentralPoint(String centralPointId) async {
//     var dbClient = await dbHelper.db;
//
//     return await dbClient.delete(
//       centralPoints,
//       where: "central_point_id = ?",
//       whereArgs: [centralPointId],
//     );
//   }
//
//   // --------------------------------------------------------
//   // OPTIMIZED CONFIG FETCH WITH THROTTLING
//   // --------------------------------------------------------
//   Future<void> _fetchConfigIfNeeded() async {
//     // Check if we need to fetch config (rate limiting)
//     if (_lastConfigFetchTime != null &&
//         DateTime.now().difference(_lastConfigFetchTime!) < _minConfigFetchInterval) {
//       debugPrint('🕒 Using cached remote config - too soon since last fetch');
//       return;
//     }
//
//     try {
//       await Config.fetchLatestConfig();
//       _lastConfigFetchTime = DateTime.now();
//       debugPrint('✅ Remote config fetched successfully');
//     } catch (e) {
//       debugPrint('❌ Config fetch failed, using cached: $e');
//       // Continue with cached values
//     }
//   }
//
//   // --------------------------------------------------------
//   // TEST API CONNECTION
//   // --------------------------------------------------------
//   Future<void> testAPIConnection() async {
//     try {
//       debugPrint("""
//       🔬🔬🔬 API CONNECTION TEST STARTED 🔬🔬🔬
//       """);
//
//       await _fetchConfigIfNeeded();
//       final apiUrl = Config.postApiUrlcenterpoint;
//
//       debugPrint("✅ Config fetched");
//       debugPrint("   API URL: $apiUrl");
//       debugPrint("   User ID: $user_id");
//
//       if (apiUrl.isEmpty) {
//         debugPrint("❌ API URL is empty!");
//         return;
//       }
//
//       debugPrint("🔄 Making test request...");
//
//       final testPayload = {
//         'test': 'connection',
//         'timestamp': DateTime.now().toIso8601String(),
//         'user_id': user_id,
//       };
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode(testPayload),
//       ).timeout(Duration(seconds: 10));
//
//       debugPrint("""
//       ✅✅✅ TEST REQUEST COMPLETE ✅✅✅
//       Status Code: ${response.statusCode}
//       Response Body: ${response.body}
//       """);
//
//     } catch (e) {
//       debugPrint("""
//       ❌❌❌ TEST FAILED ❌❌❌
//       Error: $e
//       """);
//     }
//   }
//
//   // --------------------------------------------------------
//   // POST ALL PENDING CENTRAL POINTS (OPTIMIZED)
//   // --------------------------------------------------------
//   Future<void> postCentralPointsToAPI() async {
//     if (_isPosting) {
//       debugPrint("⏳ Already posting central points, skipping...");
//       return;
//     }
//
//     _isPosting = true;
//
//     try {
//       await _fetchConfigIfNeeded();
//
//       final unPosted = await getUnPostedCentralPoints();
//
//       if (unPosted.isEmpty) {
//         debugPrint("ℹ No unposted central points found");
//         return;
//       }
//
//       if (!(await isNetworkAvailable())) {
//         debugPrint("📱 No network available, skipping sync");
//         return;
//       }
//
//       debugPrint("🟨 Starting sync for ${unPosted.length} central points...");
//
//       int successCount = 0;
//       int failedCount = 0;
//
//       for (int i = 0; i < unPosted.length; i++) {
//         var point = unPosted[i];
//         try {
//           final success = await _postSinglePointWithRetry(point);
//           if (success) {
//             successCount++;
//             debugPrint("✅ (${i + 1}/${unPosted.length}) Successfully posted: ${point.centralPointId}");
//           } else {
//             failedCount++;
//             debugPrint("❌ (${i + 1}/${unPosted.length}) Failed to post: ${point.centralPointId}");
//           }
//
//           // Add delay between API calls to prevent throttling
//           if (i < unPosted.length - 1) {
//             await Future.delayed(_minApiCallInterval);
//           }
//
//         } catch (e) {
//           failedCount++;
//           debugPrint("❌ Error posting ${point.centralPointId}: $e");
//         }
//       }
//
//       debugPrint("🎉 Sync completed: $successCount success, $failedCount failed");
//
//     } catch (e) {
//       debugPrint("❌ Error in postCentralPointsToAPI: $e");
//     } finally {
//       _isPosting = false;
//     }
//   }
//
//   // --------------------------------------------------------
//   // POST SINGLE POINT WITH RETRY MECHANISM
//   // --------------------------------------------------------
//   Future<bool> _postSinglePointWithRetry(CentralPointsModel cp, {int maxRetries = 2}) async {
//     for (int attempt = 1; attempt <= maxRetries; attempt++) {
//       try {
//         final success = await postCentralPointToAPI(cp);
//         if (success) return true;
//
//         if (attempt < maxRetries) {
//           debugPrint("🔄 Attempt $attempt failed, retrying in 2 seconds...");
//           await Future.delayed(Duration(seconds: 2));
//         }
//       } catch (e) {
//         debugPrint("❌ Attempt $attempt failed: $e");
//         if (attempt < maxRetries) {
//           await Future.delayed(Duration(seconds: 2));
//         }
//       }
//     }
//     return false;
//   }
//
//   // --------------------------------------------------------
//   // POST A SINGLE CENTRAL POINT TO API (FIXED VERSION)
//   // --------------------------------------------------------
//   Future<bool> postCentralPointToAPI(CentralPointsModel cp) async {
//     Stopwatch stopwatch = Stopwatch()..start();
//
//     try {
//       debugPrint("""
//       🚀🚀🚀 API POST PROCESS STARTED 🚀🚀🚀
//       Time: ${DateTime.now().toString()}
//       Central Point ID: ${cp.centralPointId}
//       Record Type: Individual Cluster
//       """);
//
//       // STEP 1: BASIC CHECKS
//       debugPrint("\n📋 STEP 1: Basic Checks");
//
//       // 1.1 User ID
//       if (user_id.isEmpty) {
//         debugPrint("❌ FAIL: user_id is empty");
//         debugPrint("   Current user_id: '$user_id'");
//         return false;
//       }
//       debugPrint("✅ User ID: $user_id");
//
//       // 1.2 API URL
//       await _fetchConfigIfNeeded();
//       final apiUrl = Config.postApiUrlcenterpoint;
//
//       if (apiUrl.isEmpty) {
//         debugPrint("❌ FAIL: API URL is empty");
//         debugPrint("   Check Firebase Remote Config key: 'postApiUrlcenterpoint'");
//         return false;
//       }
//
//       if (!apiUrl.startsWith('http')) {
//         debugPrint("❌ FAIL: Invalid API URL format");
//         debugPrint("   URL: $apiUrl");
//         return false;
//       }
//       debugPrint("✅ API URL: $apiUrl");
//
//       // STEP 2: NETWORK CHECK
//       debugPrint("\n📶 STEP 2: Network Check");
//
//       bool networkAvailable = await isNetworkAvailable();
//       if (!networkAvailable) {
//         debugPrint("❌ FAIL: No network connection");
//         return false;
//       }
//       debugPrint("✅ Network is available");
//
//       // STEP 3: PAYLOAD PREPARATION
//       debugPrint("\n📦 STEP 3: Payload Preparation");
//
//       final payload = cp.toApiMap();
//       debugPrint("✅ Payload created with keys: ${payload.keys.toList()}");
//
//       // Check clusters in payload
//       if (payload['clusters'] == null || (payload['clusters'] as List).isEmpty) {
//         debugPrint("⚠️ WARNING: No clusters in payload");
//       } else {
//         debugPrint("✅ Clusters in payload: ${(payload['clusters'] as List).length}");
//
//         // Print individual cluster details
//         for (int i = 0; i < (payload['clusters'] as List).length; i++) {
//           var cluster = (payload['clusters'] as List)[i];
//           debugPrint("""
//           🔥 Cluster ${i + 1} Details:
//              ID: ${cluster['cluster_id']}
//              Address: ${cluster['cluster_address']}
//              Points: ${cluster['cluster_points_count']}
//              Stay Time: ${cluster['cluster_stay_time']} min
//              Area: ${cluster['cluster_area']} sq km
//           """);
//         }
//       }
//
//       // STEP 4: API REQUEST
//       debugPrint("\n🌐 STEP 4: Making API Request");
//
//       debugPrint("📤 Sending to: $apiUrl");
//
//       final client = http.Client();
//       http.Response? response;
//
//       try {
//         debugPrint("⏱️ Starting request...");
//
//         response = await client.post(
//           Uri.parse(apiUrl),
//           headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json",
//             "X-User-ID": user_id,
//           },
//           body: jsonEncode(payload),
//         ).timeout(Duration(seconds: 30));
//
//         debugPrint("⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms");
//
//       } catch (e) {
//         debugPrint("""
//         ❌❌❌ NETWORK ERROR ❌❌❌
//         Error Type: ${e.runtimeType}
//         Error Message: $e
//         """);
//         return false;
//       } finally {
//         client.close();
//       }
//
//       // STEP 5: RESPONSE HANDLING
//       debugPrint("\n📥 STEP 5: Response Handling");
//
//       if (response == null) {
//         debugPrint("❌ FAIL: No response received");
//         return false;
//       }
//
//       debugPrint("📊 Response Status: ${response.statusCode}");
//
//       if (response.body.isNotEmpty) {
//         debugPrint("📄 Response Body (first 200 chars):");
//         debugPrint(response.body.substring(0, min(200, response.body.length)));
//       }
//
//       // Check status codes
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint("""
//         ✅✅✅ SUCCESS ✅✅✅
//         Individual Cluster Posted Successfully!
//         ID: ${cp.centralPointId}
//         Address: ${cp.addressDistrict}
//         Total Time: ${stopwatch.elapsedMilliseconds}ms
//         """);
//         return true;
//
//       } else if (response.statusCode == 400) {
//         debugPrint("❌ FAIL: Bad Request (400)");
//         debugPrint("   Server rejected the request");
//
//       } else if (response.statusCode == 401) {
//         debugPrint("❌ FAIL: Unauthorized (401)");
//
//       } else if (response.statusCode == 404) {
//         debugPrint("❌ FAIL: Not Found (404)");
//         debugPrint("   API endpoint not found");
//         debugPrint("   Check URL: $apiUrl");
//
//       } else if (response.statusCode == 500) {
//         debugPrint("❌ FAIL: Server Error (500)");
//
//       } else {
//         debugPrint("❌ FAIL: Unexpected status: ${response.statusCode}");
//       }
//
//       return false;
//
//     } catch (e, stackTrace) {
//       debugPrint("""
//       ❌❌❌ UNEXPECTED ERROR ❌❌❌
//       Error: $e
//       Total Time: ${stopwatch.elapsedMilliseconds}ms
//       """);
//       return false;
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // --------------------------------------------------------
//   // BATCH POSTING FOR BETTER PERFORMANCE
//   // --------------------------------------------------------
//   Future<void> postCentralPointsInBatch() async {
//     if (_isPosting) {
//       debugPrint("⏳ Already posting, skipping batch...");
//       return;
//     }
//
//     _isPosting = true;
//
//     try {
//       await _fetchConfigIfNeeded();
//
//       final unPosted = await getUnPostedCentralPoints();
//       if (unPosted.isEmpty) return;
//
//       debugPrint("🟨 Starting batch sync for ${unPosted.length} points...");
//
//       const batchSize = 5;
//       for (int i = 0; i < unPosted.length; i += batchSize) {
//         final endIndex = (i + batchSize) < unPosted.length ? i + batchSize : unPosted.length;
//         final batch = unPosted.sublist(i, endIndex);
//
//         debugPrint("📦 Processing batch ${(i ~/ batchSize) + 1}: ${batch.length} points");
//
//         await _processBatch(batch);
//
//         // Delay between batches
//         if (endIndex < unPosted.length) {
//           await Future.delayed(Duration(seconds: 3));
//         }
//       }
//
//     } catch (e) {
//       debugPrint("❌ Error in batch posting: $e");
//     } finally {
//       _isPosting = false;
//     }
//   }
//
//   Future<void> _processBatch(List<CentralPointsModel> batch) async {
//     for (var point in batch) {
//       try {
//         final success = await postCentralPointToAPI(point);
//         if (success) {
//           debugPrint("✅ Posted: ${point.centralPointId}");
//         }
//         await Future.delayed(Duration(milliseconds: 500));
//       } catch (e) {
//         debugPrint("❌ Failed: ${point.centralPointId} - $e");
//       }
//     }
//   }
//
//   // --------------------------------------------------------
//   // ID GENERATOR - PUBLIC METHOD
//   // --------------------------------------------------------
//   String generateCentralPointId() {
//     final now = DateTime.now();
//     String day = DateFormat('dd').format(now);
//     String month = DateFormat('MMM').format(now);
//     String uniqueId = "CD-$user_id-$day-$month-${centralPointSerialCounter.toString().padLeft(3, '0')}";
//
//     // Increment for next call
//     centralPointSerialCounter++;
//     debugPrint("🆕 Generated Cluster ID: $uniqueId");
//
//     return uniqueId;
//   }
//
//   // --------------------------------------------------------
//   // GET POSTED CENTRAL POINTS COUNT
//   // --------------------------------------------------------
//   Future<int> getPostedCentralPointsCount() async {
//     var dbClient = await dbHelper.db;
//     final result = await dbClient.rawQuery(
//         'SELECT COUNT(*) as count FROM $centralPoints WHERE posted = 1'
//     );
//     return result.first['count'] as int;
//   }
//
//   // --------------------------------------------------------
//   // CLEAR ALL CENTRAL POINTS (FOR TESTING)
//   // --------------------------------------------------------
//   Future<void> clearAllCentralPoints() async {
//     var dbClient = await dbHelper.db;
//     await dbClient.delete(centralPoints);
//     debugPrint("🗑 All central points cleared");
//   }
//
//   // --------------------------------------------------------
//   // DIRECT API TEST
//   // --------------------------------------------------------
//   Future<void> directAPITest(String url, Map<String, dynamic> data) async {
//     try {
//       debugPrint("🔧 DIRECT API TEST");
//       debugPrint("URL: $url");
//       debugPrint("Data: $data");
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       ).timeout(Duration(seconds: 10));
//
//       debugPrint("Response: ${response.statusCode}");
//       debugPrint("Body: ${response.body}");
//     } catch (e) {
//       debugPrint("Error: $e");
//     }
//   }
// }
//
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'central_point_model.dart';

class CentralPointsRepository {
  DBHelper dbHelper = DBHelper();

  // Throttling prevention flags
  static bool _isPosting = false;
  static DateTime? _lastConfigFetchTime;
  static const Duration _minConfigFetchInterval = Duration(minutes: 5);
  static const Duration _minApiCallInterval = Duration(seconds: 2);
  int centralPointSerialCounter = 1;

  // --------------------------------------------------------
  // INSERT CENTRAL POINT
  // --------------------------------------------------------
  Future<int> addCentralPoint(CentralPointsModel centralPoint) async {
    var dbClient = await dbHelper.db;

    return await dbClient.insert(
      centralPoints,
      centralPoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --------------------------------------------------------
  // SAVE MULTIPLE CLUSTERS AS SEPARATE RECORDS
  // --------------------------------------------------------
// ADD THIS METHOD TO CentralPointsRepository class
  Future<void> saveIndividualClusters(List<CentralPointsModel> clusters) async {
    var dbClient = await dbHelper.db;
    var batch = dbClient.batch();

    for (var cluster in clusters) {
      batch.insert(
        centralPoints,
        cluster.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    debugPrint("💾 Saved ${clusters.length} individual clusters to database");
  }

  // --------------------------------------------------------
  // GET ALL CENTRAL POINTS
  // --------------------------------------------------------
  Future<List<CentralPointsModel>> getCentralPoints() async {
    var dbClient = await dbHelper.db;

    final maps = await dbClient.query(centralPoints);
    return maps.map((e) => CentralPointsModel.fromMap(e)).toList();
  }

  // --------------------------------------------------------
  // GET UNPOSTED CENTRAL POINTS
  // --------------------------------------------------------
  Future<List<CentralPointsModel>> getUnPostedCentralPoints() async {
    var dbClient = await dbHelper.db;

    final maps = await dbClient.query(
      centralPoints,
      where: "posted = ?",
      whereArgs: [0],
    );

    return maps.map((e) => CentralPointsModel.fromMap(e)).toList();
  }

  // --------------------------------------------------------
  // UPDATE CENTRAL POINT
  // --------------------------------------------------------
  Future<int> updateCentralPoint(CentralPointsModel centralPoint) async {
    var dbClient = await dbHelper.db;

    return await dbClient.update(
      centralPoints,
      centralPoint.toMap(),
      where: "central_point_id = ?",
      whereArgs: [centralPoint.centralPointId],
    );
  }

  // --------------------------------------------------------
  // DELETE CENTRAL POINT
  // --------------------------------------------------------
  Future<int> deleteCentralPoint(String centralPointId) async {
    var dbClient = await dbHelper.db;

    return await dbClient.delete(
      centralPoints,
      where: "central_point_id = ?",
      whereArgs: [centralPointId],
    );
  }

  // --------------------------------------------------------
  // OPTIMIZED CONFIG FETCH WITH THROTTLING
  // --------------------------------------------------------
  Future<void> _fetchConfigIfNeeded() async {
    // Check if we need to fetch config (rate limiting)
    if (_lastConfigFetchTime != null &&
        DateTime.now().difference(_lastConfigFetchTime!) < _minConfigFetchInterval) {
      debugPrint('🕒 Using cached remote config - too soon since last fetch');
      return;
    }

    try {
      await Config.fetchLatestConfig();
      _lastConfigFetchTime = DateTime.now();
      debugPrint('✅ Remote config fetched successfully');
    } catch (e) {
      debugPrint('❌ Config fetch failed, using cached: $e');
      // Continue with cached values
    }
  }

  // --------------------------------------------------------
  // TEST API CONNECTION
  // --------------------------------------------------------
  Future<void> testAPIConnection() async {
    try {
      debugPrint("""
      🔬🔬🔬 API CONNECTION TEST STARTED 🔬🔬🔬
      """);

      await _fetchConfigIfNeeded();
      final apiUrl = Config.postApiUrlcenterpoint;

      debugPrint("✅ Config fetched");
      debugPrint("   API URL: $apiUrl");
      debugPrint("   User ID: $user_id");

      if (apiUrl.isEmpty) {
        debugPrint("❌ API URL is empty!");
        return;
      }

      debugPrint("🔄 Making test request...");

      final testPayload = {
        'test': 'connection',
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': user_id,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(testPayload),
      ).timeout(Duration(seconds: 10));

      debugPrint("""
      ✅✅✅ TEST REQUEST COMPLETE ✅✅✅
      Status Code: ${response.statusCode}
      Response Body: ${response.body}
      """);

    } catch (e) {
      debugPrint("""
      ❌❌❌ TEST FAILED ❌❌❌
      Error: $e
      """);
    }
  }

  // --------------------------------------------------------
  // POST ALL PENDING CENTRAL POINTS (OPTIMIZED)
  // --------------------------------------------------------
  Future<void> postCentralPointsToAPI() async {
    if (_isPosting) {
      debugPrint("⏳ Already posting central points, skipping...");
      return;
    }

    _isPosting = true;

    try {
      await _fetchConfigIfNeeded();

      final unPosted = await getUnPostedCentralPoints();

      if (unPosted.isEmpty) {
        debugPrint("ℹ No unposted central points found");
        return;
      }

      if (!(await isNetworkAvailable())) {
        debugPrint("📱 No network available, skipping sync");
        return;
      }

      debugPrint("🟨 Starting sync for ${unPosted.length} central points...");

      int successCount = 0;
      int failedCount = 0;

      for (int i = 0; i < unPosted.length; i++) {
        var point = unPosted[i];
        try {
          final success = await _postSinglePointWithRetry(point);
          if (success) {
            successCount++;
            debugPrint("✅ (${i + 1}/${unPosted.length}) Successfully posted: ${point.centralPointId}");
          } else {
            failedCount++;
            debugPrint("❌ (${i + 1}/${unPosted.length}) Failed to post: ${point.centralPointId}");
          }

          // Add delay between API calls to prevent throttling
          if (i < unPosted.length - 1) {
            await Future.delayed(_minApiCallInterval);
          }

        } catch (e) {
          failedCount++;
          debugPrint("❌ Error posting ${point.centralPointId}: $e");
        }
      }

      debugPrint("🎉 Sync completed: $successCount success, $failedCount failed");

    } catch (e) {
      debugPrint("❌ Error in postCentralPointsToAPI: $e");
    } finally {
      _isPosting = false;
    }
  }

  // --------------------------------------------------------
  // POST SINGLE POINT WITH RETRY MECHANISM
  // --------------------------------------------------------
  Future<bool> _postSinglePointWithRetry(CentralPointsModel cp, {int maxRetries = 2}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final success = await postCentralPointToAPI(cp);
        if (success) return true;

        if (attempt < maxRetries) {
          debugPrint("🔄 Attempt $attempt failed, retrying in 2 seconds...");
          await Future.delayed(Duration(seconds: 2));
        }
      } catch (e) {
        debugPrint("❌ Attempt $attempt failed: $e");
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }
    return false;
  }

  // --------------------------------------------------------
  // POST A SINGLE CENTRAL POINT TO API (FIXED VERSION)
  // --------------------------------------------------------
  Future<bool> postCentralPointToAPI(CentralPointsModel cp) async {
    Stopwatch stopwatch = Stopwatch()..start();

    try {
      debugPrint("""
      🚀🚀🚀 API POST PROCESS STARTED 🚀🚀🚀
      Time: ${DateTime.now().toString()}
      Central Point ID: ${cp.centralPointId}
      Record Type: Individual Cluster
      """);

      // STEP 1: BASIC CHECKS
      debugPrint("\n📋 STEP 1: Basic Checks");

      // 1.1 User ID
      if (user_id.isEmpty) {
        debugPrint("❌ FAIL: user_id is empty");
        debugPrint("   Current user_id: '$user_id'");
        return false;
      }
      debugPrint("✅ User ID: $user_id");

      // 1.2 API URL
      await _fetchConfigIfNeeded();
      final apiUrl = Config.postApiUrlcenterpoint;

      if (apiUrl.isEmpty) {
        debugPrint("❌ FAIL: API URL is empty");
        debugPrint("   Check Firebase Remote Config key: 'postApiUrlcenterpoint'");
        return false;
      }

      if (!apiUrl.startsWith('http')) {
        debugPrint("❌ FAIL: Invalid API URL format");
        debugPrint("   URL: $apiUrl");
        return false;
      }
      debugPrint("✅ API URL: $apiUrl");

      // STEP 2: NETWORK CHECK
      debugPrint("\n📶 STEP 2: Network Check");

      bool networkAvailable = await isNetworkAvailable();
      if (!networkAvailable) {
        debugPrint("❌ FAIL: No network connection");
        return false;
      }
      debugPrint("✅ Network is available");

      // STEP 3: PAYLOAD PREPARATION
      debugPrint("\n📦 STEP 3: Payload Preparation");

      final payload = cp.toApiMap();
      debugPrint("✅ Payload created with keys: ${payload.keys.toList()}");

      // Check clusters in payload
      if (payload['clusters'] == null || (payload['clusters'] as List).isEmpty) {
        debugPrint("⚠️ WARNING: No clusters in payload");
      } else {
        debugPrint("✅ Clusters in payload: ${(payload['clusters'] as List).length}");

        // Print individual cluster details
        for (int i = 0; i < (payload['clusters'] as List).length; i++) {
          var cluster = (payload['clusters'] as List)[i];
          debugPrint("""
          🔥 Cluster ${i + 1} Details:
             ID: ${cluster['cluster_id']}
             Address: ${cluster['cluster_address']}
             Points: ${cluster['cluster_points_count']}
             Stay Time: ${cluster['cluster_stay_time']} min
             Area: ${cluster['cluster_area']} sq km
          """);
        }
      }

      // STEP 4: API REQUEST
      debugPrint("\n🌐 STEP 4: Making API Request");

      debugPrint("📤 Sending to: $apiUrl");

      final client = http.Client();
      http.Response? response;

      try {
        debugPrint("⏱️ Starting request...");

        response = await client.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-User-ID": user_id,
          },
          body: jsonEncode(payload),
        ).timeout(Duration(seconds: 30));

        debugPrint("⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms");

      } catch (e) {
        debugPrint("""
        ❌❌❌ NETWORK ERROR ❌❌❌
        Error Type: ${e.runtimeType}
        Error Message: $e
        """);
        return false;
      } finally {
        client.close();
      }

      // STEP 5: RESPONSE HANDLING
      debugPrint("\n📥 STEP 5: Response Handling");

      if (response == null) {
        debugPrint("❌ FAIL: No response received");
        return false;
      }

      debugPrint("📊 Response Status: ${response.statusCode}");

      if (response.body.isNotEmpty) {
        debugPrint("📄 Response Body (first 200 chars):");
        debugPrint(response.body.substring(0, min(200, response.body.length)));
      }

      // Check status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("""
        ✅✅✅ SUCCESS ✅✅✅
        Individual Cluster Posted Successfully!
        ID: ${cp.centralPointId}
        Address: ${cp.addressDistrict}
        Total Time: ${stopwatch.elapsedMilliseconds}ms
        """);
        return true;

      } else if (response.statusCode == 400) {
        debugPrint("❌ FAIL: Bad Request (400)");
        debugPrint("   Server rejected the request");

      } else if (response.statusCode == 401) {
        debugPrint("❌ FAIL: Unauthorized (401)");

      } else if (response.statusCode == 404) {
        debugPrint("❌ FAIL: Not Found (404)");
        debugPrint("   API endpoint not found");
        debugPrint("   Check URL: $apiUrl");

      } else if (response.statusCode == 500) {
        debugPrint("❌ FAIL: Server Error (500)");

      } else {
        debugPrint("❌ FAIL: Unexpected status: ${response.statusCode}");
      }

      return false;

    } catch (e, stackTrace) {
      debugPrint("""
      ❌❌❌ UNEXPECTED ERROR ❌❌❌
      Error: $e
      Total Time: ${stopwatch.elapsedMilliseconds}ms
      """);
      return false;
    } finally {
      stopwatch.stop();
    }
  }

  // --------------------------------------------------------
  // BATCH POSTING FOR BETTER PERFORMANCE
  // --------------------------------------------------------
  Future<void> postCentralPointsInBatch() async {
    if (_isPosting) {
      debugPrint("⏳ Already posting, skipping batch...");
      return;
    }

    _isPosting = true;

    try {
      await _fetchConfigIfNeeded();

      final unPosted = await getUnPostedCentralPoints();
      if (unPosted.isEmpty) return;

      debugPrint("🟨 Starting batch sync for ${unPosted.length} points...");

      const batchSize = 5;
      for (int i = 0; i < unPosted.length; i += batchSize) {
        final endIndex = (i + batchSize) < unPosted.length ? i + batchSize : unPosted.length;
        final batch = unPosted.sublist(i, endIndex);

        debugPrint("📦 Processing batch ${(i ~/ batchSize) + 1}: ${batch.length} points");

        await _processBatch(batch);

        // Delay between batches
        if (endIndex < unPosted.length) {
          await Future.delayed(Duration(seconds: 3));
        }
      }

    } catch (e) {
      debugPrint("❌ Error in batch posting: $e");
    } finally {
      _isPosting = false;
    }
  }

  Future<void> _processBatch(List<CentralPointsModel> batch) async {
    for (var point in batch) {
      try {
        final success = await postCentralPointToAPI(point);
        if (success) {
          debugPrint("✅ Posted: ${point.centralPointId}");
        }
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        debugPrint("❌ Failed: ${point.centralPointId} - $e");
      }
    }
  }

  // --------------------------------------------------------
  // ID GENERATOR - PUBLIC METHOD
  // --------------------------------------------------------
  String generateCentralPointId() {
    final now = DateTime.now();
    String day = DateFormat('dd').format(now);
    String month = DateFormat('MMM').format(now);
    String uniqueId = "CD-$user_id-$day-$month-${centralPointSerialCounter.toString().padLeft(3, '0')}";

    // Increment for next call
    centralPointSerialCounter++;
    debugPrint("🆕 Generated Cluster ID: $uniqueId");

    return uniqueId;
  }

  // --------------------------------------------------------
  // GET POSTED CENTRAL POINTS COUNT
  // --------------------------------------------------------
  Future<int> getPostedCentralPointsCount() async {
    var dbClient = await dbHelper.db;
    final result = await dbClient.rawQuery(
        'SELECT COUNT(*) as count FROM $centralPoints WHERE posted = 1'
    );
    return result.first['count'] as int;
  }

  // --------------------------------------------------------
  // CLEAR ALL CENTRAL POINTS (FOR TESTING)
  // --------------------------------------------------------
  Future<void> clearAllCentralPoints() async {
    var dbClient = await dbHelper.db;
    await dbClient.delete(centralPoints);
    debugPrint("🗑 All central points cleared");
  }

  // --------------------------------------------------------
  // DIRECT API TEST
  // --------------------------------------------------------
  Future<void> directAPITest(String url, Map<String, dynamic> data) async {
    try {
      debugPrint("🔧 DIRECT API TEST");
      debugPrint("URL: $url");
      debugPrint("Data: $data");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10));

      debugPrint("Response: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}