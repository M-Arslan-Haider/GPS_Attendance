import 'dart:async';
import 'dart:convert';
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
  // CentralPointsRepository.dart mein yeh method confirm karein:

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
  // POST ALL PENDING CENTRAL POINTS (OPTIMIZED)
  // --------------------------------------------------------
  Future<void> postCentralPointsToAPI() async {
    if (_isPosting) {
      debugPrint("⏳ Already posting central points, skipping...");
      return;
    }

    _isPosting = true;

    try {
      // Fetch config with throttling
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
          // if (success) {
          //   point.posted = 1;
          //   await updateCentralPoint(point);
          //   successCount++;
          //   debugPrint("✅ (${i + 1}/${unPosted.length}) Successfully posted: ${point.centralPointId}");
          // } else {
          //   failedCount++;
          //   debugPrint("❌ (${i + 1}/${unPosted.length}) Failed to post: ${point.centralPointId}");
          // }

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
  // POST A SINGLE CENTRAL POINT TO API (OPTIMIZED)
  // --------------------------------------------------------
  Future<bool> postCentralPointToAPI(CentralPointsModel cp) async {
    try {
      if (user_id.isEmpty) {
        debugPrint("❌ user_id is empty! Cannot POST.");
        return false;
      }

      // Use config without frequent fetching
      final apiUrl = Config.postApiUrlcenterpoint;

      if (apiUrl.isEmpty) {
        debugPrint("❌ API URL is empty!");
        return false;
      }

      final payload = cp.toApiMap();

      debugPrint("🚀 Posting to: $apiUrl");
      if (kDebugMode) {
        debugPrint("📦 Payload keys: ${payload.keys.toList()}");
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 30));

      debugPrint("📥 Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ API Success for ID: ${cp.centralPointId}');
        return true;
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          debugPrint('❌ Response Body: ${response.body}');
        }
        return false;
      }

    } on http.ClientException catch (e) {
      debugPrint('❌ Network error: $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('❌ Request timeout: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error in postCentralPointToAPI: $e');
      return false;
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

      // Process in smaller batches
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
          // point.posted = 1;
          await updateCentralPoint(point);
          debugPrint("✅ Posted: ${point.centralPointId}");
        }
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        debugPrint("❌ Failed: ${point.centralPointId} - $e");
      }
    }
  }

  // --------------------------------------------------------
  // ID GENERATOR
  // --------------------------------------------------------
  // --------------------------------------------------------
// ID GENERATOR (ENHANCED FOR UNIQUENESS)
// --------------------------------------------------------
//   String generateCentralPointId() {
//     final now = DateTime.now();
//     // Add milliseconds to ensure uniqueness
//     return "CP-$user_id-${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}-${now.millisecondsSinceEpoch}";
//   }
//   String generateCentralPointId() {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     final now = DateTime.now();
//     String currentDayNumber = DateFormat('dd').format(now);
//     return  "CD-$user_id-$currentDayNumber-$currentMonth-${centralPointSerialCounter.toString().padLeft(3, '0')}";
//     // return  "CP-$user_id-$currentMonth-${centralPointSerialCounter.toString().padLeft(3, '0')}";
//     // return "CP-$user_id-${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}";
//   }


  String generateCentralPointId() {
    final now = DateTime.now();

    String day = DateFormat('dd').format(now);       // 22
    String month = DateFormat('MMM').format(now);    // Nov

    return "CD-$user_id-$day-$month-${centralPointSerialCounter.toString().padLeft(3, '0')}";
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
}