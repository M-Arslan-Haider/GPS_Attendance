//
// import 'dart:ffi';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Models/returnform_details_model.dart';
// import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
// import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Databases/util.dart';
// import '../Models/ScreenModels/recovery_form_models.dart';
// import '../Models/order_master_model.dart';
// import '../Models/recovery_form_model.dart';
// import '../Repositories/recovery_form_repository.dart';
// import '../Screens/home_screen.dart';
// import '../Screens/recovery_form_2nd_page.dart';
// import '../Services/ApiServices/api_service.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class RecoveryFormViewModel extends GetxController{
//   var selectedShop = ''.obs;
//   var shops = <Shop>[].obs;
//   var paymentHistory = <PaymentHistory>[].obs;
//   var filteredRows = <PaymentHistory>[].obs;
//   var current_balance = 0.0.obs; // Current balance of selected shop
//   var cash_recovery = 0.0.obs; // Amount entered by the user for recovery
//   var net_balance = 0.0.obs; // Updated balance after cash recovery
//   var areFieldsEnabled = false.obs; // Add this line
//   var recovery_id ="".obs;
//   var allRecoveryForm = <RecoveryFormModel>[].obs;
//   RecoveryFormRepository recoveryformRepository = RecoveryFormRepository();
//   OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
//   int recoverySerialCounter = 1;
//   String recoveryCurrentMonth = DateFormat('MMM').format(DateTime.now());
//   String currentuser_id = '';
//   final TextEditingController startDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//     initializeData();
//
//     fetchAllRecoveryForm();
//   }
//   Future<void> fetchAndSaveCurrentBalance(String shop_name) async {
//     await Config.fetchLatestConfig();
//     try {
//       // Print the API URL for debugging
//       debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}currentbalance/get/$shop_name/$user_id');
//
//
//       // Fetch data from the API
//       List<dynamic> data = await ApiService.getData('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlCurrentBalance}$shop_name/$user_id');
//
//       // Check if data is not empty and assign the value to current_balance.value
//       if (data.isNotEmpty) {
//         // Assuming the API returns a list of maps and the balance is in the first item
//         var balance = data[0]['balance'];
//         // Handle cases where balance might be an int or double
//         if (balance is int) {
//           current_balance.value = balance.toDouble();
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setDouble('current_balance', current_balance.value);
//           // current_balance = balance.toDouble();// Convert int to double
//         }// Replace 'balance' with the actual key in the API response
//
//           debugPrint('Current balance fetched and updated: $balance');
//
//       } else {
//
//           debugPrint('No data received from the API.');
//
//       }
//     } catch (e) {
//
//         debugPrint('Error fetching current balance: $e');
//
//       throw Exception('Failed to fetch current balance: $e');
//     }
//   }
//   Future<void> initializeData() async {
//    await Future.delayed(Duration.zero); // Ensure this runs after the build phase
//
//    // Initialize shops dynamically based on OrderMasterViewModel data
//     Map<String, double> shopBalances = {};
//
//     // Filter orders with status "Pending"
//     List<OrderMasterModel> dispatchedOrders = orderMasterViewModel.allOrderMaster
//         .where((order) => order.order_status == "DISPATCHED")
//         .toList();
//
//     // Debug: Print the filtered orders
//     debugPrint("Filtered Orders (DISPATCHED): $dispatchedOrders");
//
//     // Aggregate data by shop name
//     for (var order in dispatchedOrders) {
//       String shopName = order.shop_name ?? "Unknown Shop"; // Default to "Unknown Shop" if null
//       double orderAmount = double.tryParse(order.total ?? '0') ?? 0.0; // Parse total to double
//
//       // Debug: debugPrint each shop and its amount
//       debugPrint("Processing Shop: $shopName, Amount: $orderAmount");
//
//       // Add or update the balance for the shop
//       shopBalances[shopName] = (shopBalances[shopName] ?? 0.0) + orderAmount;
//     }
//
//     // Convert the aggregated data into a list of Shop objects
//     shops.value = shopBalances.entries.map((entry) {
//       return Shop(
//         name: entry.key, // Shop name
//         current_balance: entry.value, // Total balance for the shop
//       );
//     }).toList();
//
//     // Refresh the observable list to update the UI
//     shops.refresh();
//     // Debug: Print the final list of shops
//     debugPrint("Final Shops List: ${shops.value}");
//
//     // Initialize payment history
//     paymentHistory.value = [
//       PaymentHistory(date: '2024-12-01', shop: 'Shop 1', amount: 100),
//       PaymentHistory(date: '2024-12-05', shop: 'Shop 2', amount: 50),
//       PaymentHistory(date: '2024-12-10', shop: 'Shop 3', amount: 200),
//     ];
//
//     filteredRows.value = paymentHistory.value;
//   }
//   void filterData(String query) {
//     final lowerCaseQuery = query.toLowerCase();
//
//     // Check if any shop is selected
//     if (selectedShop.value.isNotEmpty) {
//       // Filter data based on selected shop
//       filteredRows.value = paymentHistory.value.where((row) {
//         return row.shop == selectedShop.value &&
//             (row.date.toLowerCase().contains(lowerCaseQuery) ||
//                 row.shop.toLowerCase().contains(lowerCaseQuery) ||
//                 row.amount.toString().contains(lowerCaseQuery));
//       }).toList();
//     } else {
//       // Filter data from all data
//       filteredRows.value = paymentHistory.value.where((row) {
//         return row.date.toLowerCase().contains(lowerCaseQuery) ||
//             row.shop.toLowerCase().contains(lowerCaseQuery) ||
//             row.amount.toString().contains(lowerCaseQuery);
//       }).toList();
//     }
//   }
//
//   resetForm() {
//     selectedShop.value = '';
//     current_balance.value = 0.0;
//     cash_recovery.value = 0.0;
//     net_balance.value = 0.0;
//     areFieldsEnabled.value = true;
//     // Clear any other fields or state as needed
//   }
//   void updatecurrent_balance(String shop_name) {
//
//     net_balance.value = current_balance.value - cash_recovery.value;
//     areFieldsEnabled.value = true;
//
//     // Filter payment history based on selected shop
//     filteredRows.value = paymentHistory.value.where((payment) {
//       return payment.shop == shop_name;
//     }).toList();
//   }
//
//   void updatecash_recovery(String value) {
//     final recoveryAmount = double.tryParse(value) ?? 0.0;
//     if (recoveryAmount <= current_balance.value) {
//       cash_recovery.value = recoveryAmount;
//       net_balance.value = current_balance.value - cash_recovery.value;
//     } else {
//       // Handle invalid input
//       Get.snackbar(
//           "Error", "Recovery amount cannot be more than current balance!");
//     }
//   }
//
//   List<Map<String, dynamic>> get paymentHistoryAsMapList {
//     return paymentHistory.value.map((payment) {
//       return {
//         'Date': payment.date,
//         'Amount': payment.amount,
//         'Shop': payment.shop,
//       };
//     }).toList();
//   }
//
//   Future<void> submitForm() async {
//     await _loadCounter();
//
//     // Validate Shop Selection
//     if (selectedShop.value.isEmpty) {
//       Get.snackbar(
//         "Error",
//         "⚠ Please select a shop before submitting.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     // Validate Cash Recovery Amount
//     if (cash_recovery.value == null || cash_recovery.value <= 0) {
//       Get.snackbar(
//         "Error",
//         "⚠ Please enter a valid amount before submitting.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     final recoverySerial = generateNewOrderId(user_id);
//     recovery_id.value = recoverySerial;
//
//     await addRecoveryForm(RecoveryFormModel(
//       recovery_id: recovery_id.value,
//       shop_name: selectedShop.value,
//       current_balance: current_balance.value?.toString() ?? "0",
//       cash_recovery: cash_recovery.value,
//       net_balance: net_balance.value,
//       user_id: user_id.toString(),
//     ));
//
//     await recoveryformRepository.postDataFromDatabaseToAPI();
//
//
//     // Show success message
//     Get.snackbar(
//       "Success",
//       "Form submitted successfully!",
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     );
//
//     // Navigate to the next page
//     Get.to(() => RecoveryForm_2ndPage());
//   }
//
//
//
//
//
//
//
//   Future<void> _loadCounter() async {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//     if (recoveryCurrentMonth != currentMonth) {
//       recoverySerialCounter = 1;
//       recoveryCurrentMonth = currentMonth;
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     recoverySerialCounter = (prefs.getInt('recoverySerialCounter') ?? recoveryHighestSerial ?? 1);
//     recoveryCurrentMonth = prefs.getString('recoveryCurrentMonth') ?? currentMonth;
//     currentuser_id = prefs.getString('currentuser_id') ?? '';
//
//
//       debugPrint('SR: $recoverySerialCounter');
//
//   }
//
//   Future<void> _saveCounter() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('recoverySerialCounter', recoverySerialCounter);
//     await prefs.setString('recoveryCurrentMonth', recoveryCurrentMonth);
//     await prefs.setString('currentuser_id', currentuser_id);
//   }
//
//   String generateNewOrderId(String user_id) {
//     String currentMonth = DateFormat('MMM').format(DateTime.now());
//
//     if (currentuser_id != user_id) {
//       recoverySerialCounter = recoveryHighestSerial ?? 1;
//       currentuser_id = user_id;
//     }
//
//     if (recoveryCurrentMonth != currentMonth) {
//       recoverySerialCounter = 1;
//       recoveryCurrentMonth = currentMonth;
//     }
//
//     String orderId =
//         "SV-$user_id-$currentMonth-${recoverySerialCounter.toString().padLeft(3, '0')}";
//     recoverySerialCounter++;
//     _saveCounter();
//     return orderId;
//   }
//
//   fetchAllRecoveryForm() async{
//     var recoveryform = await recoveryformRepository.getRecoveryForm();
//     allRecoveryForm.value = recoveryform;
//   }
//
//   addRecoveryForm(RecoveryFormModel recoveryformModel){
//     recoveryformRepository.add(recoveryformModel);
//     fetchAllRecoveryForm();
//   }
//
//   updateRecoveryForm(RecoveryFormModel recoveryformModel){
//     recoveryformRepository.update(recoveryformModel);
//     fetchAllRecoveryForm();
//   }
//
//   deleteRecoveryForm(int id){
//     recoveryformRepository.delete(id);
//     fetchAllRecoveryForm();
//   }
//   serialCounterGet()async{
//     await recoveryformRepository.serialNumberGeneratorApi();
//   }
// }

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Models/returnform_details_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/return_form_details_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/ScreenModels/recovery_form_models.dart';
import '../Models/order_master_model.dart';
import '../Models/recovery_form_model.dart';
import '../Repositories/recovery_form_repository.dart';
import '../Screens/HomeScreenComponents/Today Stats/daily_counter.dart';
import '../Screens/home_screen.dart';
import '../Screens/recovery_form_2nd_page.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';


class RecoveryFormViewModel extends GetxController{
  var selectedShop = ''.obs;
  var shops = <Shop>[].obs;
  var paymentHistory = <PaymentHistory>[].obs;
  var filteredRows = <PaymentHistory>[].obs;
  var current_balance = 0.0.obs; // Current balance of selected shop
  var cash_recovery = 0.0.obs; // Amount entered by the user for recovery
  var net_balance = 0.0.obs; // Updated balance after cash recovery
  var areFieldsEnabled = false.obs; // Add this line
  var recovery_id ="".obs;
  var allRecoveryForm = <RecoveryFormModel>[].obs;
  RecoveryFormRepository recoveryformRepository = RecoveryFormRepository();
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  int recoverySerialCounter = 1;
  String recoveryCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initializeData();

    fetchAllRecoveryForm();
  }
  Future<void> fetchAndSaveCurrentBalance(String shop_name) async {
    await Config.fetchLatestConfig();
    try {
      // Print the API URL for debugging
      debugPrint('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}currentbalance/get/$shop_name/$user_id');


      // Fetch data from the API
      List<dynamic> data = await ApiService.getData('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlCurrentBalance}$shop_name/$user_id');

      // Check if data is not empty and assign the value to current_balance.value
      if (data.isNotEmpty) {
        // Assuming the API returns a list of maps and the balance is in the first item
        var balance = data[0]['balance'];
        // Handle cases where balance might be an int or double
        if (balance is int) {
          current_balance.value = balance.toDouble();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('current_balance', current_balance.value);
          // current_balance = balance.toDouble();// Convert int to double
        }// Replace 'balance' with the actual key in the API response

        debugPrint('Current balance fetched and updated: $balance');

      } else {

        debugPrint('No data received from the API.');

      }
    } catch (e) {

      debugPrint('Error fetching current balance: $e');

      throw Exception('Failed to fetch current balance: $e');
    }
  }
  Future<void> initializeData() async {
    await Future.delayed(Duration.zero); // Ensure this runs after the build phase

    // Initialize shops dynamically based on OrderMasterViewModel data
    Map<String, double> shopBalances = {};

    // Filter orders with status "Pending"
    List<OrderMasterModel> dispatchedOrders = orderMasterViewModel.allOrderMaster
        .where((order) => order.order_status == "DISPATCHED")
        .toList();

    // Debug: Print the filtered orders
    debugPrint("Filtered Orders (DISPATCHED): $dispatchedOrders");

    // Aggregate data by shop name
    for (var order in dispatchedOrders) {
      String shopName = order.shop_name ?? "Unknown Shop"; // Default to "Unknown Shop" if null
      double orderAmount = double.tryParse(order.total ?? '0') ?? 0.0; // Parse total to double

      // Debug: debugPrint each shop and its amount
      debugPrint("Processing Shop: $shopName, Amount: $orderAmount");

      // Add or update the balance for the shop
      shopBalances[shopName] = (shopBalances[shopName] ?? 0.0) + orderAmount;
    }

    // Convert the aggregated data into a list of Shop objects
    shops.value = shopBalances.entries.map((entry) {
      return Shop(
        name: entry.key, // Shop name
        current_balance: entry.value, // Total balance for the shop
      );
    }).toList();

    // Refresh the observable list to update the UI
    shops.refresh();
    // Debug: Print the final list of shops
    debugPrint("Final Shops List: ${shops.value}");

    // Initialize payment history
    paymentHistory.value = [
      PaymentHistory(date: '2024-12-01', shop: 'Shop 1', amount: 100),
      PaymentHistory(date: '2024-12-05', shop: 'Shop 2', amount: 50),
      PaymentHistory(date: '2024-12-10', shop: 'Shop 3', amount: 200),
    ];

    filteredRows.value = paymentHistory.value;
  }
  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();

    // Check if any shop is selected
    if (selectedShop.value.isNotEmpty) {
      // Filter data based on selected shop
      filteredRows.value = paymentHistory.value.where((row) {
        return row.shop == selectedShop.value &&
            (row.date.toLowerCase().contains(lowerCaseQuery) ||
                row.shop.toLowerCase().contains(lowerCaseQuery) ||
                row.amount.toString().contains(lowerCaseQuery));
      }).toList();
    } else {
      // Filter data from all data
      filteredRows.value = paymentHistory.value.where((row) {
        return row.date.toLowerCase().contains(lowerCaseQuery) ||
            row.shop.toLowerCase().contains(lowerCaseQuery) ||
            row.amount.toString().contains(lowerCaseQuery);
      }).toList();
    }
  }

  resetForm() {
    selectedShop.value = '';
    current_balance.value = 0.0;
    cash_recovery.value = 0.0;
    net_balance.value = 0.0;
    areFieldsEnabled.value = true;
    // Clear any other fields or state as needed
  }
  void updatecurrent_balance(String shop_name) {

    net_balance.value = current_balance.value - cash_recovery.value;
    areFieldsEnabled.value = true;

    // Filter payment history based on selected shop
    filteredRows.value = paymentHistory.value.where((payment) {
      return payment.shop == shop_name;
    }).toList();
  }

  void updatecash_recovery(String value) {
    final recoveryAmount = double.tryParse(value) ?? 0.0;
    if (recoveryAmount <= current_balance.value) {
      cash_recovery.value = recoveryAmount;
      net_balance.value = current_balance.value - cash_recovery.value;
    } else {
      // Handle invalid input
      Get.snackbar(
          "Error", "Recovery amount cannot be more than current balance!");
    }
  }

  List<Map<String, dynamic>> get paymentHistoryAsMapList {
    return paymentHistory.value.map((payment) {
      return {
        'Date': payment.date,
        'Amount': payment.amount,
        'Shop': payment.shop,
      };
    }).toList();
  }

  Future<void> submitForm() async {
    await _loadCounter();

    // Validate Shop Selection
    if (selectedShop.value.isEmpty) {
      Get.snackbar(
        "Error",
        "⚠ Please select a shop before submitting.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate Cash Recovery Amount
    if (cash_recovery.value == null || cash_recovery.value <= 0) {
      Get.snackbar(
        "Error",
        "⚠ Please enter a valid amount before submitting.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final recoverySerial = generateNewOrderId(user_id);
    recovery_id.value = recoverySerial;

    await addRecoveryForm(RecoveryFormModel(
      recovery_id: recovery_id.value,
      shop_name: selectedShop.value,
      current_balance: current_balance.value?.toString() ?? "0",
      cash_recovery: cash_recovery.value,
      net_balance: net_balance.value,
      user_id: user_id.toString(),
    ));

    await recoveryformRepository.postDataFromDatabaseToAPI();

    // ✅ ADD DAILY COUNTER FOR RECOVERY AMOUNT
    await DailyCounter.increaseRecovery(
      count: 1,
      amount: cash_recovery.value,
    );

    // Show success message
    Get.snackbar(
      "Success",
      "Form submitted successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Navigate to the next page
    Get.to(() => RecoveryForm_2ndPage());
  }







  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    if (recoveryCurrentMonth != currentMonth) {
      recoverySerialCounter = 1;
      recoveryCurrentMonth = currentMonth;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recoverySerialCounter = (prefs.getInt('recoverySerialCounter') ?? recoveryHighestSerial ?? 1);
    recoveryCurrentMonth = prefs.getString('recoveryCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';


    debugPrint('SR: $recoverySerialCounter');

  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recoverySerialCounter', recoverySerialCounter);
    await prefs.setString('recoveryCurrentMonth', recoveryCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      recoverySerialCounter = recoveryHighestSerial ?? 1;
      currentuser_id = user_id;
    }

    if (recoveryCurrentMonth != currentMonth) {
      recoverySerialCounter = 1;
      recoveryCurrentMonth = currentMonth;
    }

    String orderId =
        "SV-$user_id-$currentMonth-${recoverySerialCounter.toString().padLeft(3, '0')}";
    recoverySerialCounter++;
    _saveCounter();
    return orderId;
  }

  fetchAllRecoveryForm() async{
    var recoveryform = await recoveryformRepository.getRecoveryForm();
    allRecoveryForm.value = recoveryform;
  }

  addRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.add(recoveryformModel);
    fetchAllRecoveryForm();
  }

  updateRecoveryForm(RecoveryFormModel recoveryformModel){
    recoveryformRepository.update(recoveryformModel);
    fetchAllRecoveryForm();
  }

  deleteRecoveryForm(int id){
    recoveryformRepository.delete(id);
    fetchAllRecoveryForm();
  }
  serialCounterGet()async{
    await recoveryformRepository.serialNumberGeneratorApi();
  }
}