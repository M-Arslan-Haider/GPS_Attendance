
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Repositories/update_functions_repository.dart';
import 'package:order_booking_app/Repositories/add_shop_repository.dart';
import 'package:order_booking_app/Repositories/shop_visit_repository.dart';
import 'package:order_booking_app/Repositories/order_master_repository.dart';
import 'package:order_booking_app/Repositories/attendance_repository.dart'; // ✅ ADD THIS
import 'package:order_booking_app/Repositories/attendance_out_repository.dart'; // ✅ ADD THIS
import 'package:order_booking_app/Repositories/location_repository.dart'; // ✅ ADD THIS
import 'package:shared_preferences/shared_preferences.dart';

class UpdateFunctionViewModel extends GetxController {
  UpdateFunctionsRepository updateFunctionsRepository = Get.put(UpdateFunctionsRepository());
  final AddShopRepository addShopRepository = Get.put(AddShopRepository());
  final ShopVisitRepository shopVisitRepository = Get.put(ShopVisitRepository());
  final OrderMasterRepository orderMasterRepository = Get.put(OrderMasterRepository());
  final AttendanceRepository attendanceRepository = Get.put(AttendanceRepository()); // ✅ ADD THIS
  final AttendanceOutRepository attendanceOutRepository = Get.put(AttendanceOutRepository()); // ✅ ADD THIS
  final LocationRepository locationRepository = Get.put(LocationRepository()); // ✅ ADD THIS

  bool isUpdate = false;
  var isInitialized = false.obs;
  var lastSyncTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndSetInitializationDateTime();
  }

  Future<void> checkAndSetInitializationDateTime() async {
    await updateFunctionsRepository.checkAndSetInitializationDateTime();
  }

  Future<void> fetchAndSaveUpdatedOrderMaster() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedOrderMaster();
  }

  Future<void> fetchAndSaveUpdatedProducts() async {
    await updateFunctionsRepository.fetchAndSaveUpdatedProducts();
  }

  Future<List<String>> fetchAndSaveUpdatedCities() async {
    return await updateFunctionsRepository.fetchAndSaveUpdatedCities();
  }

  // ✅ SIMPLE FIX: Just add attendance sync to your existing working logic
  Future<void> syncAllLocalDataToServer() async {
    try {
      debugPrint('🔄 Starting automatic sync of all local data to server...');

      // ✅ ONLY ADD THESE 3 LINES - Keep everything else the same
      await attendanceRepository.postDataFromDatabaseToAPI();
      await attendanceOutRepository.postDataFromDatabaseToAPI();
      await locationRepository.postDataFromDatabaseToAPI();

      // Keep your original working sync logic
      await addShopRepository.syncAllPendingData();
      await shopVisitRepository.syncAllPendingData();
      await orderMasterRepository.syncAllPendingData();

      // Update sync time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentDateTime = DateTime.now().toString();
      await prefs.setString('initializationDateTime', currentDateTime);
      lastSyncTime.value = currentDateTime;

      debugPrint('✅ All local data synced to server successfully at: $currentDateTime');
    } catch (e) {
      debugPrint('❌ Error during automatic sync: $e');
      rethrow;
    }
  }

  // Force refresh all data
  Future<void> forceRefreshAllData() async {
    try {
      await fetchAndSaveUpdatedCities();
      await fetchAndSaveUpdatedProducts();
      await fetchAndSaveUpdatedOrderMaster();
      await syncAllLocalDataToServer();

      debugPrint('✅ Force refresh completed successfully');
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
      rethrow;
    }
  }
}


