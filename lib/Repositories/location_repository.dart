import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../models/location_model.dart';
import '../../constants.dart';

class LocationRepository {
  final DBHelper dbHelper = DBHelper();

  // Get all location records
  Future<List<LocationModel>> getLocations() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      locationTableName,
      orderBy: 'location_date DESC',
    );

    return List.generate(maps.length, (i) {
      return LocationModel.fromMap(maps[i]);
    });
  }

  // Get unposted location records
  Future<List<LocationModel>> getUnPostedLocations() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      locationTableName,
      where: 'posted = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return LocationModel.fromMap(maps[i]);
    });
  }

  // Add location record
  Future<int> addLocation(LocationModel location) async {
    final db = await dbHelper.db;
    location.posted = 0;
    return await db.insert(locationTableName, location.toMap());
  }

  // Update location record
  Future<int> updateLocation(LocationModel location) async {
    final db = await dbHelper.db;
    return await db.update(
      locationTableName,
      location.toMap(),
      where: 'location_id = ?',
      whereArgs: [location.location_id],
    );
  }

  // Mark as posted
  Future<void> markAsPosted(String id) async {
    final db = await dbHelper.db;
    await db.update(
      locationTableName,
      {'posted': 1},
      where: 'location_id = ?',
      whereArgs: [id],
    );
  }

  // Post to API with GPX file
  Future<bool> postToAPI(LocationModel location, Uint8List gpxBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(locationApi));

      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['location_id'] = location.location_id.toString();
      request.fields['emp_id'] = location.emp_id ?? '';
      request.fields['file_name'] = location.file_name ?? '';
      request.fields['booker_name'] = location.booker_name?.toString() ?? '';
      request.fields['total_distance'] = location.total_distance?.toString() ?? '0';
      request.fields['location_date'] = location.location_date != null
          ? DateFormat('dd-MMM-yyyy').format(location.location_date!)
          : DateFormat('dd-MMM-yyyy').format(DateTime.now());
      request.fields['location_time'] = location.location_time != null
          ? DateFormat('HH:mm:ss').format(location.location_time!)
          : DateFormat('HH:mm:ss').format(DateTime.now());

      // Add GPX file
      if (gpxBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body',
            gpxBytes,
            filename: location.file_name ?? 'track.gpx',
            contentType: MediaType('application', 'gpx+xml'),
          ),
        );
      }

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Location posted: ${location.location_id}');
        await markAsPosted(location.location_id!);
        return true;
      } else {
        debugPrint('❌ API error: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network error: $e');
      return false;
    }
  }

  // Sync all unposted records
  Future<void> syncUnposted() async {
    if (!await isNetworkAvailable()) {
      debugPrint('📴 No internet connection');
      return;
    }

    final unposted = await getUnPostedLocations();
    if (unposted.isEmpty) {
      debugPrint('📭 No unposted location records');
      return;
    }

    debugPrint('🔄 Syncing ${unposted.length} location records');
    for (var location in unposted) {
      if (location.body != null) {
        await postToAPI(location, location.body!);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // Generate location ID
  Future<String> generateLocationId() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('locationCounter') ?? 1;

    final now = DateTime.now();
    final month = DateFormat('MMM').format(now);

    String id = "LOC-$emp_id-$month-${counter.toString().padLeft(3, '0')}";

    await prefs.setInt('locationCounter', counter + 1);
    return id;
  }
}