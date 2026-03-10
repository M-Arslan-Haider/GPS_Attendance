import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import '../Database/util.dart';
import '../models/location_model.dart';
import '../repositories/location_repository.dart';
import '../../constants.dart';

class LocationViewModel extends GetxController {
  final LocationRepository _locationRepo = LocationRepository();

  var allLocations = <LocationModel>[].obs;
  var currentLat = 0.0.obs;
  var currentLng = 0.0.obs;
  var currentAddress = ''.obs;
  var isTracking = false.obs;
  var totalDistance = 0.0.obs;

  Timer? _gpxSyncTimer;

  @override
  void onInit() {
    super.onInit();
    loadEmployeeData();
    fetchAllLocations();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _gpxSyncTimer?.cancel();
    super.onClose();
  }

  // Load all locations
  Future<void> fetchAllLocations() async {
    final locations = await _locationRepo.getLocations();
    allLocations.value = locations;
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;

      // Get address
      try {
        final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          currentAddress.value = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}';
        }
      } catch (e) {
        currentAddress.value = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      debugPrint('❌ Location error: $e');
    }
  }

  // Save location with GPX
  Future<void> saveLocationWithGPX() async {
    await getCurrentLocation();

    if (currentLat.value == 0.0) {
      Get.snackbar(
        'Location Error',
        'Unable to get location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Generate location ID
    final locationId = await _locationRepo.generateLocationId();

    // Get GPX file
    final gpxBytes = await _getCurrentGPXFile();
    if (gpxBytes.isEmpty) {
      Get.snackbar(
        'GPX Error',
        'No tracking data available',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Create location record
    final location = LocationModel(
      location_id: locationId,
      emp_id: emp_id,
      file_name: 'track_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.gpx',
      booker_name: emp_name,
      total_distance: totalDistance.value.toString(),
      location_date: DateTime.now(),
      location_time: DateTime.now(),
      body: gpxBytes,
    );

    // Save to database
    await _locationRepo.addLocation(location);

    // Try to post immediately
    if (await isNetworkAvailable()) {
      await _locationRepo.postToAPI(location, gpxBytes);
    }

    Get.snackbar(
      'Location Saved',
      'GPX file saved successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    fetchAllLocations();
  }

  // Get current GPX file
  Future<Uint8List> _getCurrentGPXFile() async {
    try {
      final directory = await getDownloadsDirectory();
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final filePath = '${directory!.path}/track_${emp_id}_$date.gpx';
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsBytes();
      }

      // Create empty GPX if not exists
      final emptyGPX = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Attendance App">
  <trk>
    <name>Track $date</name>
    <trkseg>
    </trkseg>
  </trk>
</gpx>''';
      await file.writeAsString(emptyGPX);
      return Uint8List.fromList(emptyGPX.codeUnits);
    } catch (e) {
      debugPrint('❌ GPX read error: $e');
      return Uint8List(0);
    }
  }

  // ✅ ADD THIS METHOD - Sync unposted locations
  Future<void> syncUnposted() async {
    await _locationRepo.syncUnposted();
    fetchAllLocations();
  }

  // Periodic sync
  void _startPeriodicSync() {
    _gpxSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await isNetworkAvailable()) {
        await _locationRepo.syncUnposted();
      }
    });
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    await Permission.location.request();
    await Permission.notification.request();
    await Permission.locationAlways.request();

    final locationStatus = await Permission.location.status;
    return locationStatus.isGranted;
  }
}