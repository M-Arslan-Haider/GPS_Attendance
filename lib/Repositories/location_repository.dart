import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/db_helper.dart';
import '../Database/util.dart';
import '../Models/location_model.dart';
import '../constants.dart';

class LocationRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<LocationModel>> getLocation() async {
    var dbClient = await dbHelper.db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      locationTableName,
      columns: [
        'location_id',
        'location_date',
        'location_time',
        'file_name',
        'emp_id',
        'booker_name',
        'total_distance',
        'body',
        'posted'
      ],
    );

    List<LocationModel> location =
    maps.map((map) => LocationModel.fromMap(map)).toList();

    debugPrint('Raw data from Location database:');
    for (var map in maps) {
      debugPrint('$map');
    }

    return location;
  }

  Future<void> fetchAndSaveLocation() async {
    debugPrint('$locationApi$emp_id');
    final response = await http.get(Uri.parse('$locationApi$emp_id'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      var dbClient = await dbHelper.db;

      for (var item in data) {
        item['posted'] = 1;
        LocationModel model = LocationModel.fromMap(Map<String, dynamic>.from(item));
        await dbClient.insert(locationTableName, model.toMap());
      }
    } else {
      throw Exception('Failed to fetch location data: ${response.statusCode}');
    }
  }

  Future<List<LocationModel>> getUnPostedLocation() async {
    var dbClient = await dbHelper.db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      locationTableName,
      where: 'posted = ?',
      whereArgs: [0],
    );

    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedLocation();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop, shop.body!);
            shop.posted = 1;
            await update(shop);
            debugPrint('Shop with id ${shop.location_id} posted and updated in local database.');
          } catch (e) {
            debugPrint('Failed to post shop with id ${shop.location_id}: $e');
          }
        }
      } else {
        debugPrint('Network not available. Unposted shops will remain local.');
      }
    } catch (e) {
      debugPrint('Error fetching unposted shops: $e');
    }
  }

  Future<void> postShopToAPI(LocationModel shop, Uint8List imageBytes) async {
    try {
      debugPrint('Updated Shop Post API: $locationApi');

      var shopData = shop.toMap();

      var request = http.MultipartRequest('POST', Uri.parse(locationApi));

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll(
        shopData.map((key, value) => MapEntry(key, value.toString())),
      );

      if (imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body',
            imageBytes,
            contentType: MediaType('application', 'gpx+xml'),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Shop data posted successfully: ${shop.toMap()}');
        await delete(shop.location_id!);
        debugPrint('location_id with id ${shop.location_id} deleted from local database.');
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Server error: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      debugPrint('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  Future<int> add(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(locationTableName, locationModel.toMap());
  }

  Future<int> update(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
      locationTableName,
      locationModel.toMap(),
      where: 'location_id = ?',
      whereArgs: [locationModel.location_id],
    );
  }

  Future<int> delete(String id) async {
    var dbClient = await dbHelper.db;
    return await dbClient.delete(
      locationTableName,
      where: 'location_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> serialNumberGeneratorApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse('$locationApi$emp_id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        int? maxSerial;
        if (data is List && data.isNotEmpty) {
          maxSerial = data
              .map((e) => int.tryParse(
              e['max(location_id)']?.toString().split('-').last ?? '0') ?? 0)
              .reduce((a, b) => a > b ? a : b);
        } else if (data is Map) {
          maxSerial = int.tryParse(
              data['max(location_id)']?.toString().split('-').last ?? '0');
        }

        if (maxSerial != null && maxSerial > (locationHighestSerial ?? 0)) {
          locationHighestSerial = maxSerial + 1;
        } else {
          locationHighestSerial = (locationHighestSerial ?? 0) + 1;
        }
      } else {
        locationHighestSerial = (locationHighestSerial ?? 0) + 1;
      }

      await prefs.reload();
      await prefs.setInt('locationHighestSerial', locationHighestSerial!);
      debugPrint('Location serial updated: $locationHighestSerial');
    } catch (e) {
      debugPrint('Error in serialNumberGeneratorApi: $e');
      locationHighestSerial = (locationHighestSerial ?? 0) + 1;
    }
  }
}