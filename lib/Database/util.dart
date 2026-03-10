import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

// Table Names
const String attendanceTableName = 'attendance';
const String attendanceOutTableName = 'attendance_out';
const String locationTableName = 'location';

// Global Variables - Initialize with defaults
String emp_id = '';           // Employee ID
String emp_name = '';         // Employee Name
String emp_job = '';          // Job/Designation
String emp_city = '';         // Employee City

// Serial Number Variables
int? attendanceInHighestSerial;
int? attendanceOutHighestSerial;
int? locationHighestSerial;

// Load Employee Data from SharedPreferences
Future<void> loadEmployeeData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    emp_id = prefs.getString(prefUserId) ?? '';
    emp_name = prefs.getString(prefUserName) ?? '';
    emp_job = prefs.getString(prefUserDesignation) ?? '';
    emp_city = prefs.getString(prefUserCity) ?? '';
    debugPrint('📋 Employee Data Loaded: $emp_name ($emp_id) - $emp_job');
  } catch (e) {
    debugPrint('❌ Error loading employee data: $e');
  }
}

// Network Check
Future<bool> isNetworkAvailable() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

// Connectivity Check
Future<bool> hasInternetConnection() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    return false;
  }
}