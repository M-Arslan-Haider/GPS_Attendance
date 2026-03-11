import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

import '../Database/db_helper.dart';
import '../Models/location_model.dart';

class LocationRepository {
  final DBHelper _dbHelper = DBHelper();

  static const String _postApiUrl =
      'http://oracle.metaxperts.net/ords/production/location/post/';

  // ─────────────────────────────────────────────
  // READ – all records
  // ─────────────────────────────────────────────
  Future<List<LocationModel>> getAll() async {
    final rows = await _dbHelper.getAll(DBHelper.locationTable);
    return rows.map((row) => LocationModel.fromMap(row)).toList();
  }

  // ─────────────────────────────────────────────
  // READ – unposted records only
  // ─────────────────────────────────────────────
  Future<List<LocationModel>> getUnposted() async {
    final rows = await _dbHelper.getUnposted(DBHelper.locationTable);
    return rows.map((row) => LocationModel.fromMap(row)).toList();
  }

  // ─────────────────────────────────────────────
  // READ – single record by ID
  // ─────────────────────────────────────────────
  Future<LocationModel?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((r) => r.location_id?.toString() == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // INSERT
  // ─────────────────────────────────────────────
  Future<int> add(LocationModel model) async {
    model.location_id ??= const Uuid().v4();

    return await _dbHelper.insert(
      DBHelper.locationTable,
      model.toMap(),
    );
  }

  // ─────────────────────────────────────────────
  // MARK AS POSTED (local DB)
  // ─────────────────────────────────────────────
  Future<int> markAsPosted(String id) async {
    return await _dbHelper.markAsPosted(
      DBHelper.locationTable,
      'location_id',
      id,
    );
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<int> delete(String id) async {
    return await _dbHelper.delete(
      DBHelper.locationTable,
      'location_id',
      id,
    );
  }

  // ─────────────────────────────────────────────
  // POST single record to API (multipart/form-data + GPX body)
  // ─────────────────────────────────────────────
  Future<bool> _postToApi(LocationModel model) async {
    if (model.body == null) {
      debugPrint('⚠️ [LocRepo] No body (GPX) for ${model.location_id} — skipping');
      return false;
    }

    try {
      final fields = model.toMap();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_postApiUrl),
      )
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(
          fields.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        )
        ..files.add(
          http.MultipartFile.fromBytes(
            'body',
            model.body!,
            contentType: MediaType('application', 'gpx+xml'),
          ),
        );

      debugPrint('📡 [LocRepo] POST ${model.location_id}');

      final streamed = await request.send()
          .timeout(const Duration(seconds: 30));

      debugPrint('📡 [LocRepo] Response ${streamed.statusCode} for ${model.location_id}');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        debugPrint('✅ [LocRepo] Posted: ${model.location_id}');
        return true;
      }

      // 409 = already on server
      if (streamed.statusCode == 409) {
        debugPrint('⚠️ [LocRepo] Already on server (409): ${model.location_id}');
        return true;
      }

      final body = await streamed.stream.bytesToString();
      debugPrint('❌ [LocRepo] Server error ${streamed.statusCode}: $body');
      return false;
    } catch (e) {
      debugPrint('❌ [LocRepo] Network error for ${model.location_id}: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // SYNC – push all unposted records to API
  //        On success → mark as posted in local DB
  //        (delete behaviour preserved as option)
  // ─────────────────────────────────────────────
  Future<void> syncUnposted({bool deleteAfterPost = false}) async {
    final unposted = await getUnposted();

    if (unposted.isEmpty) {
      debugPrint('ℹ️ [LocRepo] No unposted location records to sync.');
      return;
    }

    debugPrint('🔄 [LocRepo] Syncing ${unposted.length} location record(s)...');

    int success = 0, failed = 0;

    for (final model in unposted) {
      final id = model.location_id?.toString();
      if (id == null || id.isEmpty) {
        debugPrint('⚠️ [LocRepo] Skipping record with null/empty ID');
        continue;
      }

      final posted = await _postToApi(model);

      if (posted) {
        if (deleteAfterPost) {
          await delete(id);
          debugPrint('🗑️ [LocRepo] Deleted after post: $id');
        } else {
          await markAsPosted(id);
          debugPrint('✅ [LocRepo] Marked as posted: $id');
        }
        success++;
      } else {
        failed++;
        debugPrint('⚠️ [LocRepo] Will retry later: $id');
      }
    }

    debugPrint('📊 [LocRepo] Sync done — ✅ $success posted, ❌ $failed failed');
  }
}