// // // import 'dart:async';
// // //
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:get/get.dart';
// // // import 'package:geolocator/geolocator.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:geocoding/geocoding.dart';
// // // import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
// // // import 'package:order_booking_app/LocatioPoints/travelTimeRepository.dart';
// // //
// // // import '../Databases/util.dart';
// // //
// // // class TravelTimeViewModel extends GetxController {
// // //   final TravelTimeRepository _repository = Get.put(TravelTimeRepository());
// // //   var travelTimeData = <TravelTimeModel>[].obs;
// // //
// // //   // موجودہ سیشن کے لیے variables
// // //   Position? _lastPosition;
// // //   DateTime? _sessionStartTime;
// // //   double _totalTravelDistance = 0.0;
// // //   double _totalTravelTime = 0.0;
// // //   double _totalWorkingTime = 0.0;
// // //   double _totalStationaryTime = 0.0;
// // //
// // //   // ریئل ٹائم ٹریکنگ کے لیے
// // //   Timer? _trackingTimer;
// // //   bool _isTracking = false;
// // //
// // //   @override
// // //   void onInit() {
// // //     super.onInit();
// // //     fetchTravelTimeData();
// // //     _initializeTracking();
// // //   }
// // //
// // //   @override
// // //   void onClose() {
// // //     _stopTracking();
// // //     super.onClose();
// // //   }
// // //
// // //   // ٹریکنگ شروع کرنا
// // //   void startTracking() {
// // //     if (!_isTracking) {
// // //       _isTracking = true;
// // //       _sessionStartTime = DateTime.now();
// // //       _startPeriodicTracking();
// // //     }
// // //   }
// // //
// // //   // ٹریکنگ روکنا
// // //   void stopTracking() {
// // //     _stopTracking();
// // //     _saveSessionData();
// // //   }
// // //
// // //   void _initializeTracking() async {
// // //     // GPS کی سروس چیک کریں
// // //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// // //     if (serviceEnabled) {
// // //       startTracking();
// // //     }
// // //   }
// // //
// // //   void _startPeriodicTracking() {
// // //     _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
// // //       await _updateLocationData();
// // //     });
// // //   }
// // //
// // //   void _stopTracking() {
// // //     _trackingTimer?.cancel();
// // //     _isTracking = false;
// // //   }
// // //
// // //   Future<void> _updateLocationData() async {
// // //     try {
// // //       Position currentPosition = await Geolocator.getCurrentPosition(
// // //         desiredAccuracy: LocationAccuracy.best,
// // //       );
// // //
// // //       if (_lastPosition != null) {
// // //         // فاصلہ حساب کرنا
// // //         double distance = _calculateDistance(
// // //           _lastPosition!.latitude,
// // //           _lastPosition!.longitude,
// // //           currentPosition.latitude,
// // //           currentPosition.longitude,
// // //         );
// // //
// // //         // وقت کا فرق
// // //         double timeDiff = DateTime.now().difference(
// // //             DateTime.fromMillisecondsSinceEpoch(_lastPosition!.timestamp!.millisecondsSinceEpoch)
// // //         ).inMinutes.toDouble();
// // //
// // //         // رفتار حساب کرنا
// // //         double speed = distance / (timeDiff / 60); // km/h
// // //
// // //         // مقام کی قسم کا تعین
// // //         String travelType = _determineTravelType(distance, timeDiff, speed);
// // //
// // //         // ڈیٹا اپڈیٹ کرنا
// // //         await _updateTimeData(travelType, timeDiff, distance, speed, currentPosition);
// // //       }
// // //
// // //       _lastPosition = currentPosition;
// // //     } catch (e) {
// // //       debugPrint('Error updating location data: $e');
// // //     }
// // //   }
// // //
// // //   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// // //     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // کلومیٹر میں
// // //   }
// // //
// // //   String _determineTravelType(double distance, double timeDiff, double speed) {
// // //     if (speed > 5.0) {
// // //       return 'traveling'; // تیز رفتار - سفر
// // //     } else if (speed > 1.0 && speed <= 5.0) {
// // //       return 'working'; // آہستہ حرکت - کام کرنا
// // //     } else {
// // //       return 'stationary'; // ساکن - رکا ہوا
// // //     }
// // //   }
// // //
// // //   Future<void> _updateTimeData(
// // //       String travelType,
// // //       double timeDiff,
// // //       double distance,
// // //       double speed,
// // //       Position position
// // //       ) async {
// // //     switch (travelType) {
// // //       case 'traveling':
// // //         _totalTravelTime += timeDiff;
// // //         _totalTravelDistance += distance;
// // //         break;
// // //       case 'working':
// // //         _totalWorkingTime += timeDiff;
// // //         break;
// // //       case 'stationary':
// // //         _totalStationaryTime += timeDiff;
// // //         break;
// // //     }
// // //
// // //     // ہر 5 منٹ بعد یا جب ڈیٹا سائنفیکنٹ ہو تو محفوظ کریں
// // //     if (_totalTravelTime + _totalWorkingTime + _totalStationaryTime >= 5) {
// // //       await _saveCurrentData(travelType, distance, timeDiff, speed, position);
// // //     }
// // //   }
// // // // موجودہ ڈیٹا کو print کرنے کا method
// // //   void printTravelTimeData() {
// // //     print('=== Travel Time Data ===');
// // //
// // //     // آج کا summary
// // //     var todaySummary = getTodaySummary();
// // //     if (kDebugMode) {
// // //       print('📊 Today\'s Summaryyyyyyyyyyyyyyyyy:');
// // //     }
// // //     print('   🚗 Travel Time: ${todaySummary['travelTime']?.toStringAsFixed(2)} minutes');
// // //     print('   💼 Working Time: ${todaySummary['workingTime']?.toStringAsFixed(2)} minutes');
// // //     print('   ⏸️  Stationary Time: ${todaySummary['stationaryTime']?.toStringAsFixed(2)} minutes');
// // //     print('   📍 Total Distance: ${todaySummary['totalDistance']?.toStringAsFixed(2)} km');
// // //     print('   🚀 Average Speed: ${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h');
// // //
// // //     // تفصیلی ڈیٹا
// // //     print('\n📋 Detailed Data:');
// // //     for (var data in travelTimeData.take(10)) { // صرف پہلے 10 records
// // //       print('   ID: ${data.id}');
// // //       print('   Type: ${data.travelType}');
// // //       print('   Time: ${data.startTime} - ${data.endTime}');
// // //       print('   Distance: ${data.travelDistance} km');
// // //       print('   Duration: ${data.travelTime} minutes');
// // //       print('   Speed: ${data.averageSpeed} km/h');
// // //       print('   Address: ${data.address}');
// // //       print('   ---');
// // //     }
// // //   }
// // //
// // // // ریئل ٹائم ٹریکنگ کی معلومات دکھانے کا method
// // //   void printRealTimeTracking() {
// // //     print('🎯 Real-time Tracking Status:');
// // //     print('   Total Travel Distance: $_totalTravelDistance km');
// // //     print('   Total Travel Time: $_totalTravelTime minutes');
// // //     print('   Total Working Time: $_totalWorkingTime minutes');
// // //     print('   Total Stationary Time: $_totalStationaryTime minutes');
// // //
// // //     if (_lastPosition != null) {
// // //       print('   Last Position: ${_lastPosition!.latitude}, ${_lastPosition!.longitude}');
// // //     }
// // //   }
// // //   Future<void> _saveCurrentData(
// // //       String travelType,
// // //       double distance,
// // //       double timeDiff,
// // //       double speed,
// // //       Position position
// // //       ) async {
// // //     try {
// // //       String address = await _getAddressFromLatLng(position.latitude, position.longitude);
// // //
// // //       TravelTimeModel model = TravelTimeModel(
// // //         id: 'TT-${user_id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}',
// // //         userId: user_id,
// // //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// // //         startTime: DateFormat('HH:mm:ss').format(DateTime.now().subtract(Duration(minutes: timeDiff.toInt()))),
// // //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// // //         travelDistance: travelType == 'traveling' ? distance : 0.0,
// // //         travelTime: travelType == 'traveling' ? timeDiff : 0.0,
// // //         averageSpeed: speed,
// // //         workingTime: travelType == 'working' ? timeDiff : 0.0,
// // //         stationaryTime: travelType == 'stationary' ? timeDiff : 0.0,
// // //         travelType: travelType,
// // //         latitude: position.latitude,
// // //         longitude: position.longitude,
// // //         address: address,
// // //       );
// // //
// // // // 🪶 Debug Prints
// // //       debugPrint('🧭 TravelTimeModelllllllllllllllll Created:');
// // //       debugPrint('ID: ${model.id}');
// // //       debugPrint('User ID: ${model.userId}');
// // //       debugPrint('Travel Date: ${model.travel_date}');
// // //       debugPrint('Start Time: ${model.startTime}');
// // //       debugPrint('End Time: ${model.endTime}');
// // //       debugPrint('Travel Type: ${model.travelType}');
// // //       debugPrint('Travel Distance: ${model.travelDistance}');
// // //       debugPrint('Travel Time (min): ${model.travelTime}');
// // //       debugPrint('Average Speed: ${model.averageSpeed}');
// // //       debugPrint('Working Time: ${model.workingTime}');
// // //       debugPrint('Stationary Time: ${model.stationaryTime}');
// // //       debugPrint('Latitude: ${model.latitude}');
// // //       debugPrint('Longitude: ${model.longitude}');
// // //       debugPrint('Address: ${model.address}');
// // //       debugPrint('✅ TravelTimeModel successfully initialized.\n');
// // //       await _repository.addTravelTimeData(model);
// // //       await fetchTravelTimeData();
// // //
// // //       // ری سیٹ کاؤنٹرز
// // //       _totalTravelTime = 0;
// // //       _totalWorkingTime = 0;
// // //       _totalStationaryTime = 0;
// // //       _totalTravelDistance = 0;
// // //
// // //     } catch (e) {
// // //       debugPrint('Error saving travel time daaaaaaaaaaaaaaaata: $e');
// // //     }
// // //   }
// // //
// // //   // Future<void> _saveSessionData() async {
// // //   //   if (_sessionStartTime != null) {
// // //   //     // سیشن کا مجموعی ڈیٹا محفوظ کریں
// // //   //     double totalSessionTime = DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();
// // //   //
// // //   //     TravelTimeModel sessionModel = TravelTimeModel(
// // //   //       id: 'SESSION-${user_id}-${DateFormat('yyyyMMdd').format(DateTime.now())}',
// // //   //       userId: user_id,
// // //   //       travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// // //   //       startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
// // //   //       endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// // //   //       travelDistance: _totalTravelDistance,
// // //   //       travelTime: _totalTravelTime,
// // //   //       averageSpeed: _totalTravelTime > 0 ? _totalTravelDistance / (_totalTravelTime / 60) : 0.0,
// // //   //       workingTime: _totalWorkingTime,
// // //   //       stationaryTime: _totalStationaryTime,
// // //   //       travelType: 'session_summary',
// // //   //     );
// // //   //
// // //   //     await _repository.addTravelTimeData(sessionModel);
// // //   //     await fetchTravelTimeData();
// // //   //   }
// // //   // }
// // //   Future<void> _saveSessionData() async {
// // //     if (_sessionStartTime != null) {
// // //       // 🕒 Calculate total session time
// // //       double totalSessionTime = DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();
// // //
// // //       debugPrint('🧭 --- Saving Session Data ---');
// // //       debugPrint('User ID: $user_id');
// // //       debugPrint('Session Start Time: $_sessionStartTime');
// // //       debugPrint('Session End Time: ${DateTime.now()}');
// // //       debugPrint('Total Session Time (min): $totalSessionTime');
// // //       debugPrint('Total Travel Distance: $_totalTravelDistance');
// // //       debugPrint('Total Travel Time (min): $_totalTravelTime');
// // //       debugPrint('Total Working Time (min): $_totalWorkingTime');
// // //       debugPrint('Total Stationary Time (min): $_totalStationaryTime');
// // //       debugPrint('Average Speed: ${_totalTravelTime > 0 ? _totalTravelDistance / (_totalTravelTime / 60) : 0.0}');
// // //       debugPrint('🗓 Travel Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}');
// // //       debugPrint('--------------------------------------');
// // //
// // //       // 🧩 Create session model
// // //       TravelTimeModel sessionModel = TravelTimeModel(
// // //         id: 'SESSION-${user_id}-${DateFormat('yyyyMMdd').format(DateTime.now())}',
// // //         userId: user_id,
// // //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// // //         startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
// // //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// // //         travelDistance: _totalTravelDistance,
// // //         travelTime: _totalTravelTime,
// // //         averageSpeed: _totalTravelTime > 0 ? _totalTravelDistance / (_totalTravelTime / 60) : 0.0,
// // //         workingTime: _totalWorkingTime,
// // //         stationaryTime: _totalStationaryTime,
// // //         travelType: 'session_summary',
// // //       );
// // //
// // //       debugPrint('✅ TravelTimeModel (Session Summary) Created:');
// // //       debugPrint('ID: ${sessionModel.id}');
// // //       debugPrint('Travel Date: ${sessionModel.travel_date}');
// // //       debugPrint('Start Time: ${sessionModel.startTime}');
// // //       debugPrint('End Time: ${sessionModel.endTime}');
// // //       debugPrint('Travel Distance: ${sessionModel.travelDistance}');
// // //       debugPrint('Travel Time: ${sessionModel.travelTime}');
// // //       debugPrint('Working Time: ${sessionModel.workingTime}');
// // //       debugPrint('Stationary Time: ${sessionModel.stationaryTime}');
// // //       debugPrint('Average Speed: ${sessionModel.averageSpeed}');
// // //       debugPrint('Travel Type: ${sessionModel.travelType}');
// // //       debugPrint('--------------------------------------');
// // //
// // //       // 💾 Save data to database
// // //       await _repository.addTravelTimeData(sessionModel);
// // //       debugPrint('💾 Session data saved to database successfully.');
// // //
// // //       // 🔄 Refresh list after saving
// // //       await fetchTravelTimeData();
// // //       debugPrint('🔁 Travel time data re-fetched successfully.');
// // //     } else {
// // //       debugPrint('⚠️ Cannot save session data — _sessionStartTime is null.');
// // //     }
// // //   }
// // //
// // //   Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
// // //     try {
// // //       List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
// // //       if (placemarks.isNotEmpty) {
// // //         Placemark place = placemarks[0];
// // //         return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
// // //       }
// // //     } catch (e) {
// // //       debugPrint('Error getting address: $e');
// // //     }
// // //     return 'Address not available';
// // //   }
// // //
// // //   // ڈیٹا بیس سے ڈیٹا حاصل کرنا
// // //   Future<void> fetchTravelTimeData() async {
// // //     var data = await _repository.getTravelTimeData();
// // //     travelTimeData.value = data;
// // //   }
// // //
// // //   // API پر سینک کرنا
// // //   Future<void> syncData() async {
// // //     await _repository.syncTravelTimeData();
// // //     await fetchTravelTimeData();
// // //   }
// // //
// // //   // رپورٹس کے لیے ڈیٹا
// // //   Map<String, double> getTodaySummary() {
// // //     String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
// // //     var todayData = travelTimeData.where((data) => data.travel_date == today).toList();
// // //
// // //     double totalTravelTime = todayData.fold(0.0, (sum, data) => sum + (data.travelTime ?? 0));
// // //     double totalWorkingTime = todayData.fold(0.0, (sum, data) => sum + (data.workingTime ?? 0));
// // //     double totalStationaryTime = todayData.fold(0.0, (sum, data) => sum + (data.stationaryTime ?? 0));
// // //     double totalDistance = todayData.fold(0.0, (sum, data) => sum + (data.travelDistance ?? 0));
// // //
// // //     return {
// // //       'travelTime': totalTravelTime,
// // //       'workingTime': totalWorkingTime,
// // //       'stationaryTime': totalStationaryTime,
// // //       'totalDistance': totalDistance,
// // //       'averageSpeed': totalTravelTime > 0 ? totalDistance / (totalTravelTime / 60) : 0.0,
// // //     };
// // //   }
// // // }
// //
// //
// // // TravelTimeViewModel.dart
// // import 'dart:async';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:get/get.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:intl/intl.dart';
// // import 'package:geocoding/geocoding.dart';
// //
// // import '../Databases/util.dart';
// // import '../Models/travelTimeModel.dart';
// // import '../Repositories/travelTimeRepository.dart';
// // import 'package:order_booking_app/ViewModels/ravelTimeViewModel.dart';
// //
// //
// // class TravelTimeViewModel extends GetxController {
// //   final TravelTimeRepository _repository = Get.put(TravelTimeRepository());
// //   var travelTimeData = <TravelTimeModel>[].obs;
// //   ///added code
// //   var isWorkingScreenActive = false.obs;
// //
// //
// //   void setWorkingScreenStatus(bool isActive) {
// //     isWorkingScreenActive.value = isActive;
// //   }
// //   ///
// //
// //   // موجودہ سیشن کے لیے variables
// //   Position? _lastPosition;
// //   DateTime? _sessionStartTime;
// //   double _totalTravelDistance = 0.0;
// //   double _totalTravelTime = 0.0;
// //   double _totalWorkingTime = 0.0;
// //   double _totalStationaryTime = 0.0;
// //
// //   // ریئل ٹائم ٹریکنگ کے لیے
// //   Timer? _trackingTimer;
// //   bool _isTracking = false;
// //
// //   // Public getters for UI
// //   bool get isTracking => _isTracking;
// //   double get totalDistance => _totalTravelDistance;
// //   double get totalTravelTime => _totalTravelTime;
// //   double get totalWorkingTime => _totalWorkingTime;
// //   double get totalStationaryTime => _totalStationaryTime;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchTravelTimeData();
// //     _initializeTracking();
// //   }
// //
// //   @override
// //   void onClose() {
// //     _stopTracking();
// //     _trackingTimer?.cancel();
// //     travelTimeData.close();
// //     super.onClose();
// //   }
// //
// //   // ٹریکنگ شروع کرنا
// //   void startTracking() {
// //     if (!_isTracking) {
// //       _isTracking = true;
// //       _sessionStartTime = DateTime.now();
// //       _startPeriodicTracking();
// //       debugPrint('🚀 Travel tracking started');
// //     }
// //   }
// //
// //   // ٹریکنگ روکنا
// //   void stopTracking() {
// //     _stopTracking();
// //     _saveSessionData();
// //     debugPrint('🛑 Travel tracking stopped');
// //   }
// //
// //   void _initializeTracking() async {
// //     // GPS service چیک کریں
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       debugPrint('📍 Location service is disabled');
// //       return;
// //     }
// //
// //     // Location permission چیک کریں
// //     if (!await _checkLocationPermission()) {
// //       debugPrint('❌ Location permission denied');
// //       return;
// //     }
// //
// //     startTracking();
// //   }
// //
// //   Future<bool> _checkLocationPermission() async {
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return false;
// //       }
// //     }
// //     return permission == LocationPermission.whileInUse ||
// //         permission == LocationPermission.always;
// //   }
// //
// //   void _startPeriodicTracking() {
// //     _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
// //       if (_isTracking) {
// //         await _updateLocationData();
// //       }
// //     });
// //   }
// //
// //   void _stopTracking() {
// //     _trackingTimer?.cancel();
// //     _isTracking = false;
// //   }
// //
// //   Future<void> _updateLocationData() async {
// //     try {
// //       Position currentPosition = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.best,
// //       );
// //
// //       // Position validity چیک کریں
// //       if (!_isValidPosition(currentPosition)) {
// //         debugPrint('⚠️ Invalid position data');
// //         return;
// //       }
// //
// //       if (_lastPosition != null) {
// //         // فاصلہ حساب کرنا
// //         double distance = _calculateDistance(
// //           _lastPosition!.latitude,
// //           _lastPosition!.longitude,
// //           currentPosition.latitude,
// //           currentPosition.longitude,
// //         );
// //
// //         // وقت کا فرق - CORRECTED
// //         DateTime lastTime = _lastPosition!.timestamp ?? DateTime.now();
// //         double timeDiff = DateTime.now().difference(lastTime).inMinutes.toDouble();
// //
// //         // رفتار حساب کرنا - CORRECTED (division by zero سے بچاؤ)
// //         double speed = timeDiff > 0 ? distance / (timeDiff / 60) : 0.0;
// //
// //         // مقام کی قسم کا تعین
// //         String travelType = _determineTravelType(distance, timeDiff, speed);
// //
// //         // ڈیٹا اپڈیٹ کرنا
// //         await _updateTimeData(travelType, timeDiff, distance, speed, currentPosition);
// //       }
// //
// //       _lastPosition = currentPosition;
// //     } catch (e) {
// //       debugPrint('❌ Error updating location data: $e');
// //     }
// //   }
// //
// //   bool _isValidPosition(Position position) {
// //     return position.latitude != 0.0 &&
// //         position.longitude != 0.0 &&
// //         position.accuracy != null &&
// //         position.accuracy! < 100; // 100 meters accuracy threshold
// //   }
// //
// //   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// //     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // کلومیٹر میں
// //   }
// //
// //   String _determineTravelType(double distance, double timeDiff, double speed) {
// //     if (speed > 5.0) {
// //       return 'traveling'; // تیز رفتار - سفر
// //     } else if (speed > 1.0 && speed <= 5.0) {
// //       return 'working'; // آہستہ حرکت - کام کرنا
// //     } else {
// //       return 'stationary'; // ساکن - رکا ہوا
// //     }
// //   }
// //
// //   Future<void> _updateTimeData(
// //       String travelType,
// //       double timeDiff,
// //       double distance,
// //       double speed,
// //       Position position
// //       ) async {
// //     // Purane switch statement ko is block se replace karein
// //     if (travelType == 'traveling') {
// //       _totalTravelTime += timeDiff;
// //       _totalTravelDistance += distance;
// //       // travelType for saving will remain 'traveling'
// //     } else {
// //       // Agar traveling nahi hai ('working' ya 'stationary' hai speed ke mutabiq)
// //       if (isWorkingScreenActive.value) {
// //         // Agar Add Shop ya Shop Visit screen active hai, to WORKING TIME count hoga
// //         _totalWorkingTime += timeDiff;
// //         // typeToSave ko 'working' set karein taake DB mein sahi save ho
// //         travelType = 'working';
// //       } else {
// //         // Agar koi working screen active nahi hai, to STATIONARY TIME count hoga
// //         _totalStationaryTime += timeDiff;
// //         // typeToSave ko 'stationary' set karein taake DB mein sahi save ho
// //         travelType = 'stationary';
// //       }
// //     }
// //
// // // Har 5 minute baad ya jab data significant ho to save karein (code jaisa pehle tha waisa hi rahega)
// //     if (_totalTravelTime + _totalWorkingTime + _totalStationaryTime >= 5) {
// //       await _saveCurrentData(travelType, distance, timeDiff, speed, position); // yahan ab naya travelType use hoga
// //     }
// //
// //
// //     // ہر 5 منٹ بعد یا جب ڈیٹا سائنفیکنٹ ہو تو محفوظ کریں
// //     if (_totalTravelTime + _totalWorkingTime + _totalStationaryTime >= 1) {
// //       await _saveCurrentData(travelType, distance, timeDiff, speed, position);
// //     }
// //   }
// //
// //   // موجودہ ڈیٹا کو print کرنے کا method
// //   void printTravelTimeData() {
// //     debugPrint('=== Travel Time Data ===');
// //
// //     // آج کا summary
// //     var todaySummary = getTodaySummary();
// //     debugPrint('📊 Today\'s Summary:');
// //     debugPrint('   🚗 Travel Time: ${todaySummary['travelTime']?.toStringAsFixed(2)} minutes');
// //     debugPrint('   💼 Working Time: ${todaySummary['workingTime']?.toStringAsFixed(1)} minutes');
// //     debugPrint('   ⏸️  Stationary Time: ${todaySummary['stationaryTime']?.toStringAsFixed(1)} minutes');
// //     debugPrint('   📍 Total Distance: ${todaySummary['totalDistance']?.toStringAsFixed(2)} km');
// //     debugPrint('   🚀 Average Speed: ${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h');
// //
// //     // تفصیلی ڈیٹا
// //     debugPrint('\n📋 Detailed Data:');
// //     for (var data in travelTimeData.take(10)) {
// //       debugPrint('   ID: ${data.id}');
// //       debugPrint('   Type: ${data.travelType}');
// //       debugPrint('   Time: ${data.startTime} - ${data.endTime}');
// //       debugPrint('   Distance: ${data.travelDistance} km');
// //       debugPrint('   Duration: ${data.travelTime} minutes');
// //       debugPrint('   Speed: ${data.averageSpeed} km/h');
// //       debugPrint('   Address: ${data.address}');
// //       debugPrint('   ---');
// //     }
// //   }
// //
// //   // ریئل ٹائم ٹریکنگ کی معلومات دکھانے کا method
// //   void printRealTimeTracking() {
// //     debugPrint('🎯 Real-time Tracking Status:');
// //     debugPrint('   Total Travel Distance: $_totalTravelDistance km');
// //     debugPrint('   Total Travel Time: $_totalTravelTime minutes');
// //     debugPrint('   Total Working Time: $_totalWorkingTime minutes');
// //     debugPrint('   Total Stationary Time: $_totalStationaryTime minutes');
// //     debugPrint('   Tracking Status: ${_isTracking ? "Active" : "Inactive"}');
// //
// //     if (_lastPosition != null) {
// //       debugPrint('   Last Position: ${_lastPosition!.latitude}, ${_lastPosition!.longitude}');
// //     }
// //   }
// //
// //   Future<void> _saveCurrentData(
// //       String travelType,
// //       double distance,
// //       double timeDiff,
// //       double speed,
// //       Position position
// //       ) async {
// //     try {
// //       String address = await _getAddressFromLatLng(position.latitude, position.longitude);
// //
// //       TravelTimeModel model = TravelTimeModel(
// //         id: 'TT-${user_id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}',
// //         userId: user_id,
// //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// //         startTime: DateFormat('HH:mm:ss').format(DateTime.now().subtract(Duration(minutes: timeDiff.toInt()))),
// //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// //         travelDistance: travelType == 'traveling' ? distance : 0.0,
// //         travelTime: travelType == 'traveling' ? timeDiff : 0.0,
// //         averageSpeed: speed,
// //         workingTime: travelType == 'working' ? timeDiff : 0.0,
// //         stationaryTime: travelType == 'stationary' ? timeDiff : 0.0,
// //         travelType: travelType,
// //         latitude: position.latitude,
// //         longitude: position.longitude,
// //         address: address,
// //       );
// //
// //       // Debug Prints
// //       debugPrint('🧭 TravelTimeModel Created:');
// //       debugPrint('ID: ${model.id}');
// //       debugPrint('Travel Type: ${model.travelType}');
// //       debugPrint('Travel Distance: ${model.travelDistance}');
// //       debugPrint('Travel Time: ${model.travelTime}');
// //       debugPrint('Average Speed: ${model.averageSpeed}');
// //
// //       await _repository.addTravelTimeData(model);
// //       await fetchTravelTimeData();
// //
// //       // ری سیٹ کاؤنٹرز
// //       _totalTravelTime = 0;
// //       _totalWorkingTime = 0;
// //       _totalStationaryTime = 0;
// //       _totalTravelDistance = 0;
// //
// //     } catch (e) {
// //       debugPrint('❌ Error saving travel time data: $e');
// //     }
// //   }
// //
// //   Future<void> _saveSessionData() async {
// //     if (_sessionStartTime != null) {
// //       double totalSessionTime = DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();
// //
// //       debugPrint('🧭 --- Saving Session Data ---');
// //       debugPrint('User ID: $user_id');
// //       debugPrint('Total Travel Distance: $_totalTravelDistance');
// //       debugPrint('Total Travel Time: $_totalTravelTime');
// //       debugPrint('Total Working Time: $_totalWorkingTime');
// //       debugPrint('Total Stationary Time: $_totalStationaryTime');
// //
// //       TravelTimeModel sessionModel = TravelTimeModel(
// //         id: 'SESSION-${user_id}-${DateFormat('yyyyMMdd').format(DateTime.now())}',
// //         userId: user_id,
// //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// //         startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
// //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// //         travelDistance: _totalTravelDistance,
// //         travelTime: _totalTravelTime,
// //         averageSpeed: _totalTravelTime > 0 ? _totalTravelDistance / (_totalTravelTime / 60) : 0.0,
// //         workingTime: _totalWorkingTime,
// //         stationaryTime: _totalStationaryTime,
// //         travelType: 'session_summary',
// //       );
// //
// //       debugPrint('✅ TravelTimeModel (Session Summary) Created: ${sessionModel.id}');
// //
// //       await _repository.addTravelTimeData(sessionModel);
// //       debugPrint('💾 Session data saved to database successfully.');
// //
// //       await fetchTravelTimeData();
// //       debugPrint('🔁 Travel time data re-fetched successfully.');
// //     } else {
// //       debugPrint('⚠️ Cannot save session data — _sessionStartTime is null.');
// //     }
// //   }
// //
// //   Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
// //     try {
// //       List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
// //       if (placemarks.isNotEmpty) {
// //         Placemark place = placemarks[0];
// //         return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error getting address: $e');
// //     }
// //     return 'Address not available';
// //   }
// //
// //   // ڈیٹا بیس سے ڈیٹا حاصل کرنا
// //   Future<void> fetchTravelTimeData() async {
// //     try {
// //       var data = await _repository.getTravelTimeData();
// //       travelTimeData.value = data;
// //       debugPrint('📥 Fetched ${data.length} travel time records');
// //     } catch (e) {
// //       debugPrint('❌ Error fetching travel time data: $e');
// //     }
// //   }
// //
// //   // API پر سینک کرنا
// //   Future<void> syncData() async {
// //     try {
// //       await _repository.syncTravelTimeData();
// //       await fetchTravelTimeData();
// //       debugPrint('✅ Data synced successfully');
// //     } catch (e) {
// //       debugPrint('❌ Error syncing data: $e');
// //     }
// //   }
// //
// //   // رپورٹس کے لیے ڈیٹا
// //   Map<String, double> getTodaySummary() {
// //     String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
// //     var todayData = travelTimeData.where((data) => data.travel_date == today).toList();
// //
// //     double totalTravelTime = todayData.fold(0.0, (sum, data) => sum + (data.travelTime ?? 0));
// //     double totalWorkingTime = todayData.fold(0.0, (sum, data) => sum + (data.workingTime ?? 0));
// //     double totalStationaryTime = todayData.fold(0.0, (sum, data) => sum + (data.stationaryTime ?? 0));
// //     double totalDistance = todayData.fold(0.0, (sum, data) => sum + (data.travelDistance ?? 0));
// //
// //     return {
// //       'travelTime': totalTravelTime,
// //       'workingTime': totalWorkingTime,
// //       'stationaryTime': totalStationaryTime,
// //       'totalDistance': totalDistance,
// //       'averageSpeed': totalTravelTime > 0 ? totalDistance / (totalTravelTime / 60) : 0.0,
// //     };
// //   }
// //
// //   // Real-time tracking status for UI
// //   String get trackingStatus {
// //     if (!_isTracking) return 'Not Tracking';
// //     return 'Tracking Active - ${_totalTravelDistance.toStringAsFixed(2)} km';
// //   }
// // }
// // import 'dart:async';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:get/get.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:intl/intl.dart';
// // import 'package:geocoding/geocoding.dart';
// //
// // import '../Databases/util.dart';
// // import '../Models/travelTimeModel.dart';
// // import '../Repositories/travelTimeRepository.dart';
// // import 'package:order_booking_app/ViewModels/ravelTimeViewModel.dart';
// //
// // class TravelTimeViewModel extends GetxController {
// //   final TravelTimeRepository _repository = Get.put(TravelTimeRepository());
// //   var travelTimeData = <TravelTimeModel>[].obs;
// //
// //   /// ✅ ABDULLAH: Working screen status variable
// //   var isWorkingScreenActive = false.obs;
// //
// //   void setWorkingScreenStatus(bool isActive) {
// //     isWorkingScreenActive.value = isActive;
// //   }
// //
// //   // موجودہ سیشن کے لیے variables
// //   Position? _lastPosition;
// //   DateTime? _sessionStartTime;
// //   double _totalTravelDistance = 0.0;
// //   double _totalTravelTime = 0.0;
// //   double _totalWorkingTime = 0.0;
// //   double _totalStationaryTime = 0.0;
// //
// //   // ریئل ٹائم ٹریکنگ کے لیے
// //   Timer? _trackingTimer;
// //   bool _isTracking = false;
// //
// //   // Public getters for UI
// //   bool get isTracking => _isTracking;
// //   double get totalDistance => _totalTravelDistance;
// //   double get totalTravelTime => _totalTravelTime;
// //   double get totalWorkingTime => _totalWorkingTime;
// //   double get totalStationaryTime => _totalStationaryTime;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchTravelTimeData();
// //     _initializeTracking();
// //   }
// //
// //   @override
// //   void onClose() {
// //     _stopTracking();
// //     _trackingTimer?.cancel();
// //     travelTimeData.close();
// //     super.onClose();
// //   }
// //
// //   // ٹریکنگ شروع کرنا
// //   void startTracking() {
// //     if (!_isTracking) {
// //       _isTracking = true;
// //       _sessionStartTime = DateTime.now();
// //       _startPeriodicTracking();
// //       debugPrint('🚀 Travel tracking started');
// //     }
// //   }
// //
// //   // ٹریکنگ روکنا
// //   void stopTracking() {
// //     _stopTracking();
// //     _saveSessionData();
// //     debugPrint('🛑 Travel tracking stopped');
// //   }
// //
// //   void _initializeTracking() async {
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       debugPrint('📍 Location service is disabled');
// //       return;
// //     }
// //
// //     if (!await _checkLocationPermission()) {
// //       debugPrint('❌ Location permission denied');
// //       return;
// //     }
// //
// //     startTracking();
// //   }
// //
// //   Future<bool> _checkLocationPermission() async {
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return false;
// //       }
// //     }
// //     return permission == LocationPermission.whileInUse ||
// //         permission == LocationPermission.always;
// //   }
// //
// //   void _startPeriodicTracking() {
// //     _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
// //       if (_isTracking) {
// //         await _updateLocationData();
// //       }
// //     });
// //   }
// //
// //   void _stopTracking() {
// //     _trackingTimer?.cancel();
// //     _isTracking = false;
// //   }
// //
// //   Future<void> _updateLocationData() async {
// //     try {
// //       Position currentPosition = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.best,
// //       );
// //
// //       if (!_isValidPosition(currentPosition)) {
// //         debugPrint('⚠️ Invalid position data');
// //         return;
// //       }
// //
// //       if (_lastPosition != null) {
// //         double distance = _calculateDistance(
// //           _lastPosition!.latitude,
// //           _lastPosition!.longitude,
// //           currentPosition.latitude,
// //           currentPosition.longitude,
// //         );
// //
// //         DateTime lastTime = _lastPosition!.timestamp ?? DateTime.now();
// //         double timeDiff =
// //         DateTime.now().difference(lastTime).inMinutes.toDouble();
// //
// //         double speed = timeDiff > 0 ? distance / (timeDiff / 60) : 0.0;
// //
// //         String travelType = _determineTravelType(distance, timeDiff, speed);
// //
// //         await _updateTimeData(
// //             travelType, timeDiff, distance, speed, currentPosition);
// //       }
// //
// //       _lastPosition = currentPosition;
// //     } catch (e) {
// //       debugPrint('❌ Error updating location data: $e');
// //     }
// //   }
// //
// //   bool _isValidPosition(Position position) {
// //     return position.latitude != 0.0 &&
// //         position.longitude != 0.0 &&
// //         position.accuracy != null &&
// //         position.accuracy! < 100;
// //   }
// //
// //   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// //     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
// //   }
// //
// //   String _determineTravelType(double distance, double timeDiff, double speed) {
// //     if (speed > 5.0) {
// //       return 'traveling';
// //     } else if (speed > 1.0 && speed <= 5.0) {
// //       return 'working';
// //     } else {
// //       return 'stationary';
// //     }
// //   }
// //
// //   /// ✅ ABDULLAH: Updated _updateTimeData method
// //   Future<void> _updateTimeData(
// //       String travelType,
// //       double timeDiff,
// //       double distance,
// //       double speed,
// //       Position position) async {
// //     debugPrint("📍 [TRAVEL DEBUG] "
// //         "Type: $travelType, "
// //         "TimeDiff: ${timeDiff.toStringAsFixed(2)}, "
// //         "Distance: ${distance.toStringAsFixed(2)}, "
// //         "Speed: ${speed.toStringAsFixed(2)}, "
// //         "WorkingScreenActive: ${isWorkingScreenActive.value}");
// //
// //     // Final travel type determine karein based on screen status
// //     String finalTravelType = travelType;
// //
// //     if (travelType == 'traveling') {
// //       _totalTravelTime += timeDiff;
// //       _totalTravelDistance += distance;
// //       debugPrint("🚗 [TRAVEL] Travel time added: $timeDiff minutes");
// //     } else {
// //       if (isWorkingScreenActive.value) {
// //         finalTravelType = 'working';
// //         _totalWorkingTime += timeDiff;
// //         debugPrint("💼 [WORKING] Working time added: $timeDiff minutes");
// //       } else {
// //         finalTravelType = 'stationary';
// //         _totalStationaryTime += timeDiff;
// //         debugPrint("⏸️ [STATIONARY] Stationary time added: $timeDiff minutes");
// //       }
// //     }
// //
// //     // Har 5 minute baad save karein
// //     if (_totalTravelTime + _totalWorkingTime + _totalStationaryTime >= 5) {
// //       debugPrint("💾 [SAVE] Saving data with type: $finalTravelType");
// //       await _saveCurrentData(
// //           finalTravelType, distance, timeDiff, speed, position);
// //     }
// //   }
// //
// //   void printTravelTimeData() {

// //     debugPrint('=== Travel Time Data ===');
// //
// //     var todaySummary = getTodaySummary();
// //     debugPrint('📊 Today\'s Summary:');
// //     debugPrint(
// //         '   🚗 Travel Time: ${todaySummary['travelTime']?.toStringAsFixed(2)} minutes');
// //     debugPrint(
// //         '   💼 Working Time: ${todaySummary['workingTime']?.toStringAsFixed(2)} minutes');
// //     debugPrint(
// //         '   ⏸️ Stationary Time: ${todaySummary['stationaryTime']?.toStringAsFixed(2)} minutes');
// //     debugPrint(
// //         '   📍 Total Distance: ${todaySummary['totalDistance']?.toStringAsFixed(2)} km');
// //     debugPrint(
// //         '   🚀 Average Speed: ${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h');
// //
// //     debugPrint('\n📋 Detailed Data:');
// //     for (var data in travelTimeData.take(10)) {
// //       debugPrint('   ID: ${data.id}');
// //       debugPrint('   Type: ${data.travelType}');
// //       debugPrint('   Time: ${data.startTime} - ${data.endTime}');
// //       debugPrint('   Distance: ${data.travelDistance} km');
// //       debugPrint('   Duration: ${data.travelTime} minutes');
// //       debugPrint('   Speed: ${data.averageSpeed} km/h');
// //       debugPrint('   Address: ${data.address}');
// //       debugPrint('   ---');
// //     }
// //   }
// //
// //   void printRealTimeTracking() {
// //     debugPrint('🎯 Real-time Tracking Status:');
// //     debugPrint('   Total Travel Distance: $_totalTravelDistance km');
// //     debugPrint('   Total Travel Time: $_totalTravelTime minutes');
// //     debugPrint('   Total Working Time: $_totalWorkingTime minutes');
// //     debugPrint('   Total Stationary Time: $_totalStationaryTime minutes');
// //     debugPrint(
// //         '   Tracking Status: ${_isTracking ? "Active" : "Inactive"}');
// //
// //     if (_lastPosition != null) {
// //       debugPrint(
// //           '   Last Position: ${_lastPosition!.latitude}, ${_lastPosition!.longitude}');
// //     }
// //   }
// //
// //   Future<void> _saveCurrentData(String travelType, double distance,
// //       double timeDiff, double speed, Position position) async {
// //     try {
// //       String address =
// //       await _getAddressFromLatLng(position.latitude, position.longitude);
// //
// //       TravelTimeModel model = TravelTimeModel(
// //         id:
// //         'TT-${user_id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}',
// //         userId: user_id,
// //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// //         startTime: DateFormat('HH:mm:ss')
// //             .format(DateTime.now().subtract(Duration(minutes: timeDiff.toInt()))),
// //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// //         travelDistance: travelType == 'traveling' ? distance : 0.0,
// //         travelTime: travelType == 'traveling' ? timeDiff : 0.0,
// //         averageSpeed: speed,
// //         workingTime: travelType == 'working' ? timeDiff : 0.0,
// //         stationaryTime: travelType == 'stationary' ? timeDiff : 0.0,
// //         travelType: travelType,
// //         latitude: position.latitude,
// //         longitude: position.longitude,
// //         address: address,
// //       );
// //
// //       debugPrint('🧭 TravelTimeModel Created:');
// //       debugPrint('ID: ${model.id}');
// //       debugPrint('Travel Type: ${model.travelType}');
// //       debugPrint('Travel Distance: ${model.travelDistance}');
// //       debugPrint('Travel Time: ${model.travelTime}');
// //       debugPrint('Average Speed: ${model.averageSpeed}');
// //
// //       await _repository.addTravelTimeData(model);
// //       await fetchTravelTimeData();
// //
// //       _totalTravelTime = 0;
// //       _totalWorkingTime = 0;
// //       _totalStationaryTime = 0;
// //       _totalTravelDistance = 0;
// //     } catch (e) {
// //       debugPrint('❌ Error saving travel time data: $e');
// //     }
// //   }
// //
// //   Future<void> _saveSessionData() async {
// //     if (_sessionStartTime != null) {
// //       double totalSessionTime =
// //       DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();
// //
// //       debugPrint('🧭 --- Saving Session Data ---');
// //       debugPrint('User ID: $user_id');
// //       debugPrint('Total Travel Distance: $_totalTravelDistance');
// //       debugPrint('Total Travel Time: $_totalTravelTime');
// //       debugPrint('Total Working Time: $_totalWorkingTime');
// //       debugPrint('Total Stationary Time: $_totalStationaryTime');
// //
// //       TravelTimeModel sessionModel = TravelTimeModel(
// //         id:
// //         'SESSION-${user_id}-${DateFormat('yyyyMMdd').format(DateTime.now())}',
// //         userId: user_id,
// //         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
// //         startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
// //         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
// //         travelDistance: _totalTravelDistance,
// //         travelTime: _totalTravelTime,
// //         averageSpeed: _totalTravelTime > 0
// //             ? _totalTravelDistance / (_totalTravelTime / 60)
// //             : 0.0,
// //         workingTime: _totalWorkingTime,
// //         stationaryTime: _totalStationaryTime,
// //         travelType: 'session_summary',
// //       );
// //
// //       debugPrint(
// //           '✅ TravelTimeModel (Session Summary) Created: ${sessionModel.id}');
// //
// //       await _repository.addTravelTimeData(sessionModel);
// //       debugPrint('💾 Session data saved to database successfully.');
// //
// //       await fetchTravelTimeData();
// //       debugPrint('🔁 Travel time data re-fetched successfully.');
// //     } else {
// //       debugPrint('⚠️ Cannot save session data — _sessionStartTime is null.');
// //     }
// //   }
// //
// //   Future<String> _getAddressFromLatLng(
// //       double latitude, double longitude) async {
// //     try {
// //       List<Placemark> placemarks =
// //       await placemarkFromCoordinates(latitude, longitude);
// //       if (placemarks.isNotEmpty) {
// //         Placemark place = placemarks[0];
// //         return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error getting address: $e');
// //     }
// //     return 'Address not available';
// //   }
// //
// //   Future<void> fetchTravelTimeData() async {
// //     try {
// //       var data = await _repository.getTravelTimeData();
// //       travelTimeData.value = data;
// //       debugPrint('📥 Fetched ${data.length} travel time records');
// //     } catch (e) {
// //       debugPrint('❌ Error fetching travel time data: $e');
// //     }
// //   }
// //
// //   Future<void> syncData() async {
// //     try {
// //       await _repository.syncTravelTimeData();
// //       await fetchTravelTimeData();
// //       debugPrint('✅ Data synced successfully');
// //     } catch (e) {
// //       debugPrint('❌ Error syncing data: $e');
// //     }
// //   }
// //
// //   Map<String, double> getTodaySummary() {
// //     String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
// //     var todayData =
// //     travelTimeData.where((data) => data.travel_date == today).toList();
// //
// //     double totalTravelTime =
// //     todayData.fold(0.0, (sum, data) => sum + (data.travelTime ?? 0));
// //     double totalWorkingTime =
// //     todayData.fold(0.0, (sum, data) => sum + (data.workingTime ?? 0));
// //     double totalStationaryTime =
// //     todayData.fold(0.0, (sum, data) => sum + (data.stationaryTime ?? 0));
// //     double totalDistance =
// //     todayData.fold(0.0, (sum, data) => sum + (data.travelDistance ?? 0));
// //
// //     return {
// //       'travelTime': totalTravelTime,
// //       'workingTime': totalWorkingTime,
// //       'stationaryTime': totalStationaryTime,
// //       'totalDistance': totalDistance,
// //       'averageSpeed': totalTravelTime > 0
// //           ? totalDistance / (totalTravelTime / 60)
// //           : 0.0,
// //     };
// //   }
// //
// //   String get trackingStatus {
// //     if (!_isTracking) return 'Not Tracking';
// //     return 'Tracking Active - ${_totalTravelDistance.toStringAsFixed(2)} km';
// //   }
// // }
// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:geocoding/geocoding.dart';
//
// import '../Databases/util.dart';
// import '../Models/travelTimeModel.dart';
// import '../Repositories/travelTimeRepository.dart';
// import 'package:order_booking_app/ViewModels/ravelTimeViewModel.dart';
//
// class TravelTimeViewModel extends GetxController {
//   final TravelTimeRepository _repository = Get.put(TravelTimeRepository());
//   var travelTimeData = <TravelTimeModel>[].obs;
//
//   /// ✅ ABDULLAH: Working screen status variable
//   var isWorkingScreenActive = false.obs;
//
//   void setWorkingScreenStatus(bool isActive) {
//     isWorkingScreenActive.value = isActive;
//   }
//
//   // موجودہ سیشن کے لیے variables
//   Position? _lastPosition;
//   DateTime? _sessionStartTime;
//   double _totalTravelDistance = 0.0;
//   double _totalTravelTime = 0.0;
//   double _totalWorkingTime = 0.0;
//   double _totalStationaryTime = 0.0;
//
//   // ریئل ٹائم ٹریکنگ کے لیے
//   Timer? _trackingTimer;
//   bool _isTracking = false;
//
//   /// ✅ Abdullah: Manual working time timer
//   Timer? _forceTimeTimer;
//
//   // Public getters for UI
//   bool get isTracking => _isTracking;
//   double get totalDistance => _totalTravelDistance;
//   double get totalTravelTime => _totalTravelTime;
//   double get totalWorkingTime => _totalWorkingTime;
//   double get totalStationaryTime => _totalStationaryTime;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchTravelTimeData();
//     _initializeTracking();
//   }
//
//   @override
//   void onClose() {
//     _stopTracking();
//     _trackingTimer?.cancel();
//     _forceTimeTimer?.cancel(); // ✅ Stop manual timer
//     travelTimeData.close();
//     super.onClose();
//   }
//
//   // ✅ ABDULLAH: Manual force time tracking
//   void _startForceTimeTracking() {
//     _forceTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
//       if (_isTracking && isWorkingScreenActive.value) {
//         debugPrint("⏰ [FORCE TIME] Adding 1 minute working time");
//         _totalWorkingTime += 1.0;
//
//         if (_totalWorkingTime >= 1.0 && _lastPosition != null) {
//           await _saveCurrentData('working', 0.0, 1.0, 0.0, _lastPosition!);
//           _totalWorkingTime = 0;
//         }
//       }
//     });
//   }
//
//   void _stopForceTimeTracking() {
//     _forceTimeTimer?.cancel();
//     _forceTimeTimer = null;
//   }
//
//   // ٹریکنگ شروع کرنا
//   void startTracking() {
//     if (!_isTracking) {
//       _isTracking = true;
//       _sessionStartTime = DateTime.now();
//       _startPeriodicTracking();
//       _startForceTimeTracking(); // ✅ ADD THIS
//       debugPrint('🚀 Travel tracking started');
//     }
//   }
//
//   // ٹریکنگ روکنا
//   void stopTracking() {
//     _stopTracking();
//     _stopForceTimeTracking(); // ✅ ADD THIS
//     _saveSessionData();
//     debugPrint('🛑 Travel tracking stopped');
//   }
//
//   void _initializeTracking() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       debugPrint('📍 Location service is disabled');
//       return;
//     }
//
//     if (!await _checkLocationPermission()) {
//       debugPrint('❌ Location permission denied');
//       return;
//     }
//
//     startTracking();
//   }
//
//   Future<bool> _checkLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }
//     return permission == LocationPermission.whileInUse ||
//         permission == LocationPermission.always;
//   }
//
//   void _startPeriodicTracking() {
//     _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
//       if (_isTracking) {
//         await _updateLocationData();
//       }
//     });
//   }
//
//   void _stopTracking() {
//     _trackingTimer?.cancel();
//     _isTracking = false;
//   }
//
//   Future<void> _updateLocationData() async {
//     try {
//       Position currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//
//       if (!_isValidPosition(currentPosition)) {
//         debugPrint('⚠️ Invalid position data');
//         return;
//       }
//
//       if (_lastPosition != null) {
//         double distance = _calculateDistance(
//           _lastPosition!.latitude,
//           _lastPosition!.longitude,
//           currentPosition.latitude,
//           currentPosition.longitude,
//         );
//
//         DateTime lastTime = _lastPosition!.timestamp ?? DateTime.now();
//         double timeDiff =
//         DateTime.now().difference(lastTime).inMinutes.toDouble();
//
//         double speed = timeDiff > 0 ? distance / (timeDiff / 60) : 0.0;
//
//         String travelType = _determineTravelType(distance, timeDiff, speed);
//
//         await _updateTimeData(
//             travelType, timeDiff, distance, speed, currentPosition);
//       }
//
//       _lastPosition = currentPosition;
//     } catch (e) {
//       debugPrint('❌ Error updating location data: $e');
//     }
//   }
//
//   bool _isValidPosition(Position position) {
//     return position.latitude != 0.0 &&
//         position.longitude != 0.0 &&
//         position.accuracy != null &&
//         position.accuracy! < 100;
//   }
//
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
//   }
//
//   String _determineTravelType(double distance, double timeDiff, double speed) {
//     if (speed > 5.0) {
//       return 'traveling';
//     } else if (speed > 1.0 && speed <= 5.0) {
//       return 'working';
//     } else {
//       return 'stationary';
//     }
//   }
//
//   Future<void> _updateTimeData(
//       String travelType,
//       double timeDiff,
//       double distance,
//       double speed,
//       Position position) async {
//     debugPrint("📍 [TRAVEL DEBUG] "
//         "Type: $travelType, "
//         "TimeDiff: ${timeDiff.toStringAsFixed(2)}, "
//         "Distance: ${distance.toStringAsFixed(2)}, "
//         "Speed: ${speed.toStringAsFixed(2)}, "
//         "WorkingScreenActive: ${isWorkingScreenActive.value}");
//
//     String finalTravelType = travelType;
//
//     if (travelType == 'traveling') {
//       _totalTravelTime += timeDiff;
//       _totalTravelDistance += distance;
//       debugPrint("🚗 [TRAVEL] Travel time added: $timeDiff minutes");
//     } else {
//       if (isWorkingScreenActive.value) {
//         finalTravelType = 'working';
//         _totalWorkingTime += timeDiff;
//         debugPrint("💼 [WORKING] Working time added: $timeDiff minutes");
//       } else {
//         finalTravelType = 'stationary';
//         _totalStationaryTime += timeDiff;
//         debugPrint("⏸️ [STATIONARY] Stationary time added: $timeDiff minutes");
//       }
//     }
//
//     if (_totalTravelTime + _totalWorkingTime + _totalStationaryTime >= 5) {
//       debugPrint("💾 [SAVE] Saving data with type: $finalTravelType");
//       await _saveCurrentData(
//           finalTravelType, distance, timeDiff, speed, position);
//     }
//   }
//
//   void printTravelTimeData() {
//     debugPrint('=== Travel Time Data ===');
//
//     var todaySummary = getTodaySummary();
//     debugPrint('📊 Today\'s Summary:');
//     debugPrint(
//         '   🚗 Travel Time: ${todaySummary['travelTime']?.toStringAsFixed(2)} minutes');
//     debugPrint(
//         '   💼 Working Time: ${todaySummary['workingTime']?.toStringAsFixed(2)} minutes');
//     debugPrint(
//         '   ⏸️ Stationary Time: ${todaySummary['stationaryTime']?.toStringAsFixed(2)} minutes');
//     debugPrint(
//         '   📍 Total Distance: ${todaySummary['totalDistance']?.toStringAsFixed(2)} km');
//     debugPrint(
//         '   🚀 Average Speed: ${todaySummary['averageSpeed']?.toStringAsFixed(2)} km/h');
//
//     debugPrint('\n📋 Detailed Data:');
//     for (var data in travelTimeData.take(10)) {
//       debugPrint('   ID: ${data.id}');
//       debugPrint('   Type: ${data.travelType}');
//       debugPrint('   Time: ${data.startTime} - ${data.endTime}');
//       debugPrint('   Distance: ${data.travelDistance} km');
//       debugPrint('   Duration: ${data.travelTime} minutes');
//       debugPrint('   Speed: ${data.averageSpeed} km/h');
//       debugPrint('   Address: ${data.address}');
//       debugPrint('   ---');
//     }
//   }
//
//   void printRealTimeTracking() {
//     debugPrint('🎯 Real-time Tracking Status:');
//     debugPrint('   Total Travel Distance: $_totalTravelDistance km');
//     debugPrint('   Total Travel Time: $_totalTravelTime minutes');
//     debugPrint('   Total Working Time: $_totalWorkingTime minutes');
//     debugPrint('   Total Stationary Time: $_totalStationaryTime minutes');
//     debugPrint(
//         '   Tracking Status: ${_isTracking ? "Active" : "Inactive"}');
//
//     if (_lastPosition != null) {
//       debugPrint(
//           '   Last Position: ${_lastPosition!.latitude}, ${_lastPosition!.longitude}');
//     }
//   }
//
//   Future<void> _saveCurrentData(String travelType, double distance,
//       double timeDiff, double speed, Position position) async {
//     try {
//       String address =
//       await _getAddressFromLatLng(position.latitude, position.longitude);
//
//       TravelTimeModel model = TravelTimeModel(
//         id:
//         'TT-${user_id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}',
//         userId: user_id,
//         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
//         startTime: DateFormat('HH:mm:ss')
//             .format(DateTime.now().subtract(Duration(minutes: timeDiff.toInt()))),
//         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
//         travelDistance: travelType == 'traveling' ? distance : 0.0,
//         travelTime: travelType == 'traveling' ? timeDiff : 0.0,
//         averageSpeed: speed,
//         workingTime: travelType == 'working' ? timeDiff : 0.0,
//         stationaryTime: travelType == 'stationary' ? timeDiff : 0.0,
//         travelType: travelType,
//         latitude: position.latitude,
//         longitude: position.longitude,
//         address: address,
//       );
//
//       debugPrint('🧭 TravelTimeModel Created: ${model.id}');
//       await _repository.addTravelTimeData(model);
//       await fetchTravelTimeData();
//
//       _totalTravelTime = 0;
//       _totalWorkingTime = 0;
//       _totalStationaryTime = 0;
//       _totalTravelDistance = 0;
//     } catch (e) {
//       debugPrint('❌ Error saving travel time data: $e');
//     }
//   }
//
//   Future<void> _saveSessionData() async {
//     if (_sessionStartTime != null) {
//       double totalSessionTime =
//       DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();
//
//       TravelTimeModel sessionModel = TravelTimeModel(
//         id:
//         'SESSION-${user_id}-${DateFormat('yyyyMMdd').format(DateTime.now())}',
//         userId: user_id,
//         travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
//         startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
//         endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
//         travelDistance: _totalTravelDistance,
//         travelTime: _totalTravelTime,
//         averageSpeed: _totalTravelTime > 0
//             ? _totalTravelDistance / (_totalTravelTime / 60)
//             : 0.0,
//         workingTime: _totalWorkingTime,
//         stationaryTime: _totalStationaryTime,
//         travelType: 'session_summary',
//       );
//
//       await _repository.addTravelTimeData(sessionModel);
//       await fetchTravelTimeData();
//     }
//   }
//
//   Future<String> _getAddressFromLatLng(
//       double latitude, double longitude) async {
//     try {
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(latitude, longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
//       }
//     } catch (e) {
//       debugPrint('❌ Error getting address: $e');
//     }
//     return 'Address not available';
//   }
//
//   Future<void> fetchTravelTimeData() async {
//     try {
//       var data = await _repository.getTravelTimeData();
//       travelTimeData.value = data;
//     } catch (e) {
//       debugPrint('❌ Error fetching travel time data: $e');
//     }
//   }
//
//   Future<void> syncData() async {
//     try {
//       await _repository.syncTravelTimeData();
//       await fetchTravelTimeData();
//     } catch (e) {
//       debugPrint('❌ Error syncing data: $e');
//     }
//   }
//
//   Map<String, double> getTodaySummary() {
//     String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
//     var todayData =
//     travelTimeData.where((data) => data.travel_date == today).toList();
//
//     double totalTravelTime =
//     todayData.fold(0.0, (sum, data) => sum + (data.travelTime ?? 0));
//     double totalWorkingTime =
//     todayData.fold(0.0, (sum, data) => sum + (data.workingTime ?? 0));
//     double totalStationaryTime =
//     todayData.fold(0.0, (sum, data) => sum + (data.stationaryTime ?? 0));
//     double totalDistance =
//     todayData.fold(0.0, (sum, data) => sum + (data.travelDistance ?? 0));
//
//     return {
//       'travelTime': totalTravelTime,
//       'workingTime': totalWorkingTime,
//       'stationaryTime': totalStationaryTime,
//       'totalDistance': totalDistance,
//       'averageSpeed': totalTravelTime > 0
//           ? totalDistance / (totalTravelTime / 60)
//           : 0.0,
//     };
//   }
//
//   String get trackingStatus {
//     if (!_isTracking) return 'Not Tracking';
//     return 'Tracking Active - ${_totalTravelDistance.toStringAsFixed(2)} km';
//   }
// }






import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:order_booking_app/LocatioPoints/travelTimeModel.dart';
import 'package:order_booking_app/LocatioPoints/travelTimeRepository.dart';

import '../Databases/util.dart';

class TravelTimeViewModel extends GetxController {
  final TravelTimeRepository _repository = Get.put(TravelTimeRepository());
  var travelTimeData = <TravelTimeModel>[].obs;


  /// ✅ ABDULLAH: Working screen status variable
  var isWorkingScreenActive = false.obs;

  void setWorkingScreenStatus(bool isActive) {
    isWorkingScreenActive.value = isActive;
    debugPrint("🔄 Working Screen Active: $isActive");
  }

  Position? _lastPosition;
  DateTime? _sessionStartTime;
  double _totalTravelDistance = 0.0;
  double _totalTravelTime = 0.0;
  double _totalWorkingTime = 0.0;
  double _totalIdleTime = 0.0;

  Timer? _trackingTimer;
  bool _isTracking = false;

  Timer? _forceTimeTimer;

  bool get isTracking => _isTracking;
  double get totalDistance => _totalTravelDistance;
  double get totalTravelTime => _totalTravelTime;
  double get totalWorkingTime => _totalWorkingTime;
  double get totalIdleTime => _totalIdleTime;
  // ✅ Added by Abdullah: Prevent multiple save overlap
  bool _isSaving = false; // Added by Abdullah



  int travelSerialCounter = 1;
  int? travelHighestSerial;
  String? currentTravelUserId;
  String? travelCurrentDay;

  @override
  void onInit() {
    super.onInit();
    fetchTravelTimeData();
    _initializeTracking();
  }

  @override
  void onClose() {
    _stopTracking();
    _trackingTimer?.cancel();
    _forceTimeTimer?.cancel();
    travelTimeData.close();
    super.onClose();
  }

  void _startForceTimeTracking() {
    _forceTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_isTracking && isWorkingScreenActive.value) {
        _totalWorkingTime += 1.0;
        debugPrint("⏰ [FORCE TIME] +1 minute working time (screen active)");

        if (_totalWorkingTime >= 1.0 && _lastPosition != null) {
          await _saveCurrentData('working', 0.0, 1.0, 0.0, _lastPosition!);
          _totalWorkingTime = 0;
        }
      }
    });
  }

  void _stopForceTimeTracking() {
    _forceTimeTimer?.cancel();
    _forceTimeTimer = null;
  }

  void startTracking() {
    if (!_isTracking) {
      _isTracking = true;
      _sessionStartTime = DateTime.now();
      _startPeriodicTracking();
      _startForceTimeTracking();
      debugPrint('🚀 Travel tracking started');
    }
  }

  void stopTracking() {
    _stopTracking();
    _stopForceTimeTracking();
    _saveSessionData();
    debugPrint('🛑 Travel tracking stopped');
  }

  void _initializeTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('📍 Location service is disabled');
      return;
    }

    if (!await _checkLocationPermission()) {
      debugPrint('❌ Location permission denied');
      return;
    }

    startTracking();
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _startPeriodicTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isTracking) {
        await _updateLocationData();
      }
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _isTracking = false;
  }

  Future<void> _updateLocationData() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (!_isValidPosition(currentPosition)) {
        debugPrint('⚠️ Invalid position data');
        return;
      }

      if (_lastPosition != null) {
        DateTime currentTime = DateTime.now();
        DateTime lastTime = _lastPosition!.timestamp ?? currentTime;

        double timeDiff = currentTime.difference(lastTime).inSeconds / 60;
        double distance = _calculateDistance(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        // ✅ Real-time accurate speed & distance
        if (distance < 0.005) distance = 0.0; // Ignore GPS noise

        double speed = 0.0;
        if (timeDiff > 0) {
          speed = distance / (timeDiff / 60);
        }

        speed = speed.isFinite ? double.parse(speed.toStringAsFixed(3)) : 0.0;

        debugPrint("📍 [REALTIME] Diff: ${timeDiff.toStringAsFixed(2)} min | "
            "Distance: ${distance.toStringAsFixed(3)} km | "
            "Speed: ${speed.toStringAsFixed(2)} km/h");

        String travelType = _determineTravelType(distance, timeDiff, speed);

        await _updateTimeData(
          travelType,
          timeDiff,
          distance,
          speed,
          currentPosition,
        );
      }

      _lastPosition = currentPosition;
    } catch (e) {
      debugPrint('❌ Error updating location data: $e');
    }
  }


  bool _isValidPosition(Position position) {
    return position.latitude != 0.0 &&
        position.longitude != 0.0 &&
        position.accuracy != null &&
        position.accuracy! < 100;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  String _determineTravelType(double distance, double timeDiff, double speed) {
    if (speed > 5.0) return 'traveling';
    if (speed > 1.0 && speed <= 5.0) return 'working';
    return 'idle';
  }

  Future<void> _updateTimeData(
      String travelType,
      double timeDiff,
      double distance,
      double speed,
      Position position,
      ) async {
    debugPrint("📍 [TRAVEL DEBUG] "
        "Type: $travelType | "
        "Diff: ${timeDiff.toStringAsFixed(2)} min | "
        "Distance: ${distance.toStringAsFixed(3)} km | "
        "Speed: ${speed.toStringAsFixed(2)} km/h | "
        "WorkingActive: ${isWorkingScreenActive.value}");

    String finalTravelType = travelType;

    if (travelType == 'traveling') {
      _totalTravelTime += timeDiff;
      _totalTravelDistance += distance;
      debugPrint("🚗 [TRAVEL] +${timeDiff.toStringAsFixed(2)} min | ${distance.toStringAsFixed(3)} km");
    } else if (isWorkingScreenActive.value) {
      finalTravelType = 'working';
      _totalWorkingTime += timeDiff;
      debugPrint("💼 [WORKING ACTIVE] +${timeDiff.toStringAsFixed(2)} min (AddShop/ShopVisit)");
    } else {
      finalTravelType = 'idle';
      _totalIdleTime += timeDiff;
      debugPrint("⏸️ [IDLE] +${timeDiff.toStringAsFixed(2)} min");
    }

    if (_totalTravelTime + _totalWorkingTime + _totalIdleTime >= 1) {
      debugPrint("💾 [SAVE] Saving data: $finalTravelType");
      await _saveCurrentData(finalTravelType, distance, timeDiff, speed, position);
    }
  }
  Future<String> generateNewTravelId(String userId) async {
    final DateTime now = DateTime.now();
    final String month = DateFormat('MMM').format(now);

    int lastSerial = await _repository.getLastSerialForMonth(userId, month);
    int newSerial = lastSerial + 1;

    String travelId = 'ATD-$userId-$month-${newSerial.toString().padLeft(3, '0')}';

    debugPrint('🆔 Generated Travel ID: $travelId');

    return travelId;
  }

  Future<void> _saveTravelCounter() async {
    // optional: store counter in SharedPreferences if you want it persistent
  }



  Future<void> _saveCurrentData(String travelType, double distance,
      double timeDiff, double speed, Position position) async {
    // ✅ Added by Abdullah: Prevent duplicate concurrent saves
    if (_isSaving) return; // Added by Abdullah
    _isSaving = true; // Added by Abdullah

    try {
      String address = await _getAddressFromLatLng(
          position.latitude, position.longitude);


      TravelTimeModel model = TravelTimeModel(
        // id:
        // 'TT-${user_id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}',
        id: await generateNewTravelId(user_id),

        userId: user_id,
        travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        startTime: DateFormat('HH:mm:ss')
            .format(DateTime.now().subtract(Duration(minutes: timeDiff.toInt()))),
        endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
        travelDistance: travelType == 'traveling' ? distance : 0.0,
        travelTime: travelType == 'traveling' ? timeDiff : 0.0,
        averageSpeed: speed,
        workingTime: travelType == 'working' ? timeDiff : 0.0,
        idleTime: travelType == 'idle' ? timeDiff : 0.0,
        travelType: travelType,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      debugPrint('🧭 [SAVE MODEL] ${model.travelType} | ${model.travelTime} min');
      await _repository.addTravelTimeData(model);
      await fetchTravelTimeData();

      _totalTravelTime = 0;
      _totalWorkingTime = 0;
      _totalIdleTime = 0;
      _totalTravelDistance = 0;
    } catch (e) {
      debugPrint('❌ Error saving travel time data: $e');
    }
  }

  Future<void> _saveSessionData() async {
    if (_sessionStartTime != null) {
      double totalSessionTime =
      DateTime.now().difference(_sessionStartTime!).inMinutes.toDouble();

      TravelTimeModel sessionModel = TravelTimeModel(
        id: 'TT-${user_id}-${DateTime.now().millisecondsSinceEpoch}',

        userId: user_id,
        travel_date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        startTime: DateFormat('HH:mm:ss').format(_sessionStartTime!),
        endTime: DateFormat('HH:mm:ss').format(DateTime.now()),
        travelDistance: _totalTravelDistance,
        travelTime: _totalTravelTime,
        averageSpeed: _totalTravelTime > 0
            ? _totalTravelDistance / (_totalTravelTime / 60)
            : 0.0,
        workingTime: _totalWorkingTime,
        idleTime: _totalIdleTime,
        travelType: 'session_summary',
      );

      await _repository.addTravelTimeData(sessionModel);
      await fetchTravelTimeData();
    }
  }

  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
      }
    } catch (e) {
      debugPrint('❌ Error getting address: $e');
    }
    return 'Address not available';
  }

  Future<void> fetchTravelTimeData() async {
    try {
      var data = await _repository.getTravelTimeData();
      travelTimeData.value = data;
    } catch (e) {
      debugPrint('❌ Error fetching travel time data: $e');
    }
  }

  Future<void> syncData() async {
    try {
      await _repository.syncTravelTimeData();
      await fetchTravelTimeData();
    } catch (e) {
      debugPrint('❌ Error syncing data: $e');
    }
  }

  Map<String, double> getTodaySummary() {
    String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    var todayData =
    travelTimeData.where((data) => data.travel_date == today).toList();

    double totalTravelTime =
    todayData.fold(0.0, (sum, data) => sum + (data.travelTime ?? 0));
    double totalWorkingTime =
    todayData.fold(0.0, (sum, data) => sum + (data.workingTime ?? 0));
    double totalIdleTime =
    todayData.fold(0.0, (sum, data) => sum + (data.idleTime ?? 0));
    double totalDistance =
    todayData.fold(0.0, (sum, data) => sum + (data.travelDistance ?? 0));

    return {
      'travelTime': totalTravelTime,
      'workingTime': totalWorkingTime,
      'idleTime': totalIdleTime,
      'totalDistance': totalDistance,
      'averageSpeed':
      totalTravelTime > 0 ? totalDistance / (totalTravelTime / 60) : 0.0,
    };
  }

  String get trackingStatus {
    if (!_isTracking) return 'Not Tracking';
    return 'Tracking Active - ${_totalTravelDistance.toStringAsFixed(2)} km';
  }

  // ✅ ABDULLAH: Debug print methods for terminal output
  void printTravelTimeData() {
    for (var data in travelTimeData) {
      debugPrint(
          '🧾 [DATA] ID: ${data.id}, Type: ${data.travelType}, '
              'Distance: ${data.travelDistance}, Time: ${data.travelTime}, '
              'Working: ${data.workingTime}, Idle: ${data.idleTime}, '
              'Speed: ${data.averageSpeed}, Address: ${data.address}'
      );
    }
  }

  void printRealTimeTracking() {
    debugPrint('📍 [REAL-TIME] Working: ${_totalWorkingTime.toStringAsFixed(2)} min, '
        'Travel: ${_totalTravelTime.toStringAsFixed(2)} min, '
        'Idle: ${_totalIdleTime.toStringAsFixed(2)} min, '
        'Distance: ${_totalTravelDistance.toStringAsFixed(3)} km');
  }
}
