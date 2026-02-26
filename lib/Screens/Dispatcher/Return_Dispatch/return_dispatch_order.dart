import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

// Add this import for Config
import '../../../Services/FirebaseServices/firebase_remote_config.dart';


// ============================================================
// SECTION 1: CONSTANTS & CONFIG
// ============================================================

const String _kBaseUrl = 'https://cloud.metaxperts.net:8443/erp/valor_trading';
const String _kShopGetUrl = '$_kBaseUrl/dispatchshopget/get/';
const String _kItemsGetUrl = '$_kBaseUrl/dispatchproductget/get/';

// These are kept as fallbacks but will use Config values in actual API calls
const String _kReturnMasterPostUrl = '$_kBaseUrl/dispatcher_return_master/post';
const String _kReturnDetailsPostUrl = '$_kBaseUrl/dispatcher_return_details/post';
const String _kReturnMasterSerialUrl = '$_kBaseUrl/dispatcher_return_master_serial/get/';
const String _kReturnDetailsSerialUrl = '$_kBaseUrl/dispatcher_return_details_serial/get/';

const String _kReturnMasterTable = 'dispatcher_return_master';
const String _kReturnDetailsTable = 'dispatcher_return_details';

// Shared global state (mirrors util.dart pattern)
String userId = user_id; // Set this from your auth system
String? dispatcherReturnMasterId;
int? dispatcherReturnMasterHighestSerial;
int? dispatcherReturnDetailsHighestSerial;

// Add this function for network availability check
// Replace the existing isNetworkAvailable function with this improved version
Future<bool> isNetworkAvailable() async {
  try {
    // Try to ping a reliable endpoint instead of the base URL
    final result = await http.get(
      Uri.parse('https://cloud.metaxperts.net:8443'),
    ).timeout(const Duration(seconds: 5));

    return result.statusCode == 200 || result.statusCode == 404; // 404 means server is reachable
  } on http.ClientException {
    debugPrint('Network check: ClientException - No internet connection');
    return false;
  } on Exception catch (e) {
    debugPrint('Network check error: $e');
    return false;
  }
}

// ============================================================
// SECTION 2: DATABASE HELPER
// ============================================================

class _DispatcherDBHelper {
  static _DispatcherDBHelper? _instance;
  static Database? _db;

  _DispatcherDBHelper._internal();

  factory _DispatcherDBHelper() {
    _instance ??= _DispatcherDBHelper._internal();
    return _instance!;
  }

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'dispatcher_return.db');
    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_kReturnMasterTable (
            return_master_id TEXT PRIMARY KEY,
            select_shop TEXT,
            return_amount TEXT,
            return_master_date TEXT,
            return_master_time TEXT,
            user_id TEXT,
            posted INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_kReturnDetailsTable (
            return_details_id TEXT PRIMARY KEY,
            item TEXT,
            quantity TEXT,
            reason TEXT,
            return_master_id TEXT,
            return_details_date TEXT,
            return_details_time TEXT,
            user_id TEXT,
            posted INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
}

// ============================================================
// SECTION 3: MODELS
// ============================================================

class DispatcherShopModel {
  final String name;
  DispatcherShopModel({required this.name});
  factory DispatcherShopModel.fromMap(Map<dynamic, dynamic> json) {
    return DispatcherShopModel(
      name: json['shop_name'] ?? json['name'] ?? '',
    );
  }
}

class DispatcherReturnItem {
  final String name;
  final double rate;
  final double maxQuantity;
  DispatcherReturnItem(this.name, {this.rate = 0.0, this.maxQuantity = 0.0});
}

class DispatcherReturnRow {
  String quantity;
  String reason;
  String items;
  DispatcherReturnItem? selectedItem;
  double? rate;
  double? maxQuantity;

  DispatcherReturnRow({
    this.quantity = '',
    this.reason = '',
    this.items = '',
    this.selectedItem,
    this.rate,
    this.maxQuantity,
  });
}

class DispatcherReturnMasterModel {
  String? returnMasterId;
  String? selectShop;
  String? returnAmount;
  DateTime? date;
  DateTime? time;
  String? userId;
  int posted;

  DispatcherReturnMasterModel({
    this.returnMasterId,
    this.selectShop,
    this.returnAmount,
    this.userId,
    this.date,
    this.time,
    this.posted = 0,
  });

  factory DispatcherReturnMasterModel.fromMap(Map<dynamic, dynamic> json) {
    return DispatcherReturnMasterModel(
      returnMasterId: json['return_master_id'],
      selectShop: json['select_shop'],
      userId: json['user_id'],
      returnAmount: json['return_amount'],
      date: DateTime.now(),
      time: DateTime.now(),
      posted: json['posted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'return_master_id': returnMasterId,
      'select_shop': selectShop,
      'user_id': userId,
      'return_amount': returnAmount,
      'return_master_date': DateFormat('dd-MMM-yyyy').format(date ?? DateTime.now()),
      'return_master_time': DateFormat('HH:mm:ss').format(time ?? DateTime.now()),
      'posted': posted,
    };
  }
}

class DispatcherReturnDetailsModel {
  String? returnDetailsId;
  String? item;
  String? quantity;
  String? reason;
  String? returnMasterId;
  DateTime? date;
  DateTime? time;
  String? userId;
  int posted;

  DispatcherReturnDetailsModel({
    this.returnDetailsId,
    this.item,
    this.quantity,
    this.reason,
    this.returnMasterId,
    this.date,
    this.time,
    this.userId,
    this.posted = 0,
  });

  factory DispatcherReturnDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return DispatcherReturnDetailsModel(
      returnDetailsId: json['return_details_id'],
      item: json['item'],
      quantity: json['quantity'],
      reason: json['reason'],
      returnMasterId: json['return_master_id'],
      userId: json['user_id'],
      date: DateTime.now(),
      time: DateTime.now(),
      posted: json['posted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'return_details_id': returnDetailsId,
      'item': item,
      'quantity': quantity,
      'reason': reason,
      'return_master_id': returnMasterId,
      'return_details_date': DateFormat('dd-MMM-yyyy').format(date ?? DateTime.now()),
      'return_details_time': DateFormat('HH:mm:ss').format(time ?? DateTime.now()),
      'user_id': userId,
      'posted': posted,
    };
  }
}

// ============================================================
// SECTION 4: REPOSITORIES
// ============================================================

class _DispatcherReturnMasterRepository {
  final _DispatcherDBHelper _dbHelper = _DispatcherDBHelper();

  Future<List<DispatcherReturnMasterModel>> getAll() async {
    final db = await _dbHelper.db;
    final maps = await db.query(_kReturnMasterTable);
    return maps.map((m) => DispatcherReturnMasterModel.fromMap(m)).toList();
  }

  Future<List<DispatcherReturnMasterModel>> getUnPosted() async {
    final db = await _dbHelper.db;
    final maps = await db.query(_kReturnMasterTable, where: 'posted = ?', whereArgs: [0]);
    return maps.map((m) => DispatcherReturnMasterModel.fromMap(m)).toList();
  }

  Future<int> add(DispatcherReturnMasterModel model) async {
    final db = await _dbHelper.db;
    return db.insert(_kReturnMasterTable, model.toMap());
  }

  Future<int> update(DispatcherReturnMasterModel model) async {
    final db = await _dbHelper.db;
    return db.update(
      _kReturnMasterTable,
      model.toMap(),
      where: 'return_master_id = ?',
      whereArgs: [model.returnMasterId],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.db;
    return db.delete(_kReturnMasterTable, where: 'return_master_id = ?', whereArgs: [id]);
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      final unPosted = await getUnPosted();
      if (unPosted.isEmpty) {
        debugPrint('No unposted master records found');
        return;
      }

      debugPrint('Found ${unPosted.length} unposted master records');

      if (await isNetworkAvailable()) {
        for (var item in unPosted) {
          try {
            await postShopToAPI(item);
            item.posted = 1;
            await update(item);
            debugPrint('✅ Return master ${item.returnMasterId} posted successfully.');
          } catch (e) {
            debugPrint('❌ Failed to post return master ${item.returnMasterId}: $e');
          }
        }
      } else {
        debugPrint('Network not available. Unposted returns will remain local.');
      }
    } catch (e) {
      debugPrint('Error in postDataFromDatabaseToAPI (master): $e');
    }
  }

  Future<void> postShopToAPI(DispatcherReturnMasterModel shop) async {
    try {
      await Config.fetchLatestConfig();

      final url = "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlReturnForm}";
      debugPrint('Posting to master API: $url');

      var shopData = shop.toMap();
      debugPrint('Master post data: $shopData');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Master data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error posting master data: $e');
      throw Exception('Failed to post master data: $e');
    }
  }

  Future<void> fetchSerialNumber() async {
    try {
      await Config.fetchLatestConfig();

      final prefs = await SharedPreferences.getInstance();
      final url = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlReturnFormSerial}$user_id';
      debugPrint('Fetching master serial from: $url');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final maxId = data['max(return_master_id)'] as String?;
        if (maxId != null && maxId != 'null') {
          final parts = maxId.split('-');
          final serial = int.tryParse(parts.last) ?? 0;
          dispatcherReturnMasterHighestSerial = serial + 1;
          await prefs.setInt('dispatcherReturnMasterHighestSerial', dispatcherReturnMasterHighestSerial!);
          debugPrint('Master highest serial: $dispatcherReturnMasterHighestSerial');
        }
      } else {
        debugPrint('Failed to fetch master serial: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching master serial: $e');
    }
  }
}

class _DispatcherReturnDetailsRepository {
  final _DispatcherDBHelper _dbHelper = _DispatcherDBHelper();

  Future<List<DispatcherReturnDetailsModel>> getAll() async {
    final db = await _dbHelper.db;
    final maps = await db.query(_kReturnDetailsTable);
    return maps.map((m) => DispatcherReturnDetailsModel.fromMap(m)).toList();
  }

  Future<List<DispatcherReturnDetailsModel>> getUnPosted() async {
    final db = await _dbHelper.db;
    final maps = await db.query(_kReturnDetailsTable, where: 'posted = ?', whereArgs: [0]);
    return maps.map((m) => DispatcherReturnDetailsModel.fromMap(m)).toList();
  }

  Future<int> add(DispatcherReturnDetailsModel model) async {
    final db = await _dbHelper.db;
    return db.insert(_kReturnDetailsTable, model.toMap());
  }

  Future<int> update(DispatcherReturnDetailsModel model) async {
    final db = await _dbHelper.db;
    return db.update(
      _kReturnDetailsTable,
      model.toMap(),
      where: 'return_details_id = ?',
      whereArgs: [model.returnDetailsId],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.db;
    return db.delete(_kReturnDetailsTable, where: 'return_details_id = ?', whereArgs: [id]);
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      final unPosted = await getUnPosted();
      if (unPosted.isEmpty) {
        debugPrint('No unposted detail records found');
        return;
      }

      debugPrint('Found ${unPosted.length} unposted detail records');

      if (await isNetworkAvailable()) {
        for (var item in unPosted) {
          try {
            await postShopToAPI(item);
            item.posted = 1;
            await update(item);
            debugPrint('✅ Return detail ${item.returnDetailsId} posted successfully.');
          } catch (e) {
            debugPrint('❌ Failed to post return detail ${item.returnDetailsId}: $e');
          }
        }
      } else {
        debugPrint('Network not available. Unposted details will remain local.');
      }
    } catch (e) {
      debugPrint('Error in postDataFromDatabaseToAPI (details): $e');
    }
  }

  Future<void> postShopToAPI(DispatcherReturnDetailsModel shop) async {
    try {
      await Config.fetchLatestConfig();

      final url = "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.postApiUrlReturnFormDetails}";
      debugPrint('Posting to details API: $url');

      var shopData = shop.toMap();
      debugPrint('Details post data: $shopData');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Details data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error posting details data: $e');
      throw Exception('Failed to post details data: $e');
    }
  }

  Future<void> fetchSerialNumber() async {
    try {
      await Config.fetchLatestConfig();

      final prefs = await SharedPreferences.getInstance();
      final url = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlReturnFormDetailsSerial}$user_id';
      debugPrint('Fetching details serial from: $url');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final maxId = data['max(return_details_id)'] as String?;
        if (maxId != null && maxId != 'null') {
          final parts = maxId.split('-');
          final serial = int.tryParse(parts.last) ?? 0;
          dispatcherReturnDetailsHighestSerial = serial + 1;
          await prefs.setInt('dispatcherReturnDetailsHighestSerial', dispatcherReturnDetailsHighestSerial!);
          debugPrint('Details highest serial: $dispatcherReturnDetailsHighestSerial');
        }
      } else {
        debugPrint('Failed to fetch details serial: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching details serial: $e');
    }
  }
}

// ============================================================
// SECTION 5: VIEW MODELS
// ============================================================

class DispatcherReturnDetailsViewModel extends GetxController {
  final _DispatcherReturnDetailsRepository _detailsRepo = _DispatcherReturnDetailsRepository();
  final _DispatcherReturnMasterRepository _masterRepo = _DispatcherReturnMasterRepository();

  var allDetails = <DispatcherReturnDetailsModel>[].obs;
  var items = <DispatcherReturnItem>[].obs;
  var reasons = <String>["Expire", "Business Closed", "Damage", "Cancel"].obs;
  var formRows = <DispatcherReturnRow>[DispatcherReturnRow()].obs;

  int _detailsSerialCounter = 1;
  String _detailsCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String _currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    reasons.value = ["Expire", "Business Closed", "Damage", "Cancel"];
    _fetchAll();
    serialCounterGet();
  }

  void addRow() => formRows.add(DispatcherReturnRow());

  void removeRow(int index) {
    if (formRows.length > 1) formRows.removeAt(index);
  }

  double getTotalAmount() {
    double total = 0.0;
    debugPrint('=== Calculating Total Amount ===');
    for (var i = 0; i < formRows.length; i++) {
      var row = formRows[i];
      if (row.quantity.isNotEmpty && row.rate != null) {
        double quantity = double.tryParse(row.quantity) ?? 0;
        double rowTotal = quantity * row.rate!;
        total += rowTotal;
        debugPrint('Row $i: ${row.selectedItem?.name}');
        debugPrint('  Quantity: $quantity');
        debugPrint('  Rate: ${row.rate}');
        debugPrint('  Row Total: $rowTotal');
      } else {
        debugPrint('Row $i is incomplete - quantity: "${row.quantity}", rate: ${row.rate}');
      }
    }
    debugPrint('Grand Total: $total');
    debugPrint('===============================');
    return total;
  }

  Future<void> submitForm(String returnMasterId) async {
    bool isValid = true;
    String? errorMessage;

    for (var row in formRows) {
      if (row.selectedItem == null || row.quantity.isEmpty || row.reason.isEmpty) {
        isValid = false;
        errorMessage = "Please fill all fields before submitting.";
        break;
      }
      double enteredQty = double.tryParse(row.quantity) ?? 0;
      if (enteredQty <= 0) {
        isValid = false;
        errorMessage = "Quantity must be greater than 0.";
        break;
      }
      if (row.maxQuantity != null && enteredQty > row.maxQuantity!) {
        isValid = false;
        errorMessage = "Quantity for ${row.selectedItem?.name} cannot exceed ${row.maxQuantity}";
        break;
      }
    }

    if (!isValid || formRows.isEmpty) {
      Get.snackbar(
        "Error",
        errorMessage ?? "Please check your inputs",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    for (var row in formRows) {
      await _loadCounter();
      final detailSerial = _generateDetailsId(user_id);

      await _detailsRepo.add(DispatcherReturnDetailsModel(
        returnDetailsId: detailSerial,
        item: row.selectedItem?.name,
        reason: row.reason,
        quantity: row.quantity,
        userId: user_id,
        returnMasterId: returnMasterId,
      ));
    }

    await _detailsRepo.postDataFromDatabaseToAPI();
    await _masterRepo.postDataFromDatabaseToAPI();
    await _fetchAll();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateFormat('MMM').format(DateTime.now());
    _detailsSerialCounter =
        prefs.getInt('dispatcherDetailsSerialCounter') ?? dispatcherReturnDetailsHighestSerial ?? 1;
    _detailsCurrentMonth = prefs.getString('dispatcherDetailsCurrentMonth') ?? currentMonth;
    _currentUserId = prefs.getString('dispatcherCurrentUserId') ?? '';

    if (_detailsCurrentMonth != currentMonth) {
      _detailsSerialCounter = 1;
      _detailsCurrentMonth = currentMonth;
    }
    debugPrint('DetailsSerialCounter: $_detailsSerialCounter');
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dispatcherDetailsSerialCounter', _detailsSerialCounter);
    await prefs.setString('dispatcherDetailsCurrentMonth', _detailsCurrentMonth);
    await prefs.setString('dispatcherCurrentUserId', _currentUserId);
  }

  String _generateDetailsId(String userId) {
    final currentMonth = DateFormat('MMM').format(DateTime.now());
    if (_currentUserId != userId) {
      _detailsSerialCounter = dispatcherReturnDetailsHighestSerial ?? 1;
      _currentUserId = userId;
    }
    if (_detailsCurrentMonth != currentMonth) {
      _detailsSerialCounter = 1;
      _detailsCurrentMonth = currentMonth;
    }
    final id = "DRD-$userId-$currentMonth-${_detailsSerialCounter.toString().padLeft(3, '0')}";
    _detailsSerialCounter++;
    _saveCounter();
    return id;
  }

  Future<void> _fetchAll() async {
    allDetails.value = await _detailsRepo.getAll();
  }

  Future<void> serialCounterGet() async {
    await _detailsRepo.fetchSerialNumber();
    final prefs = await SharedPreferences.getInstance();
    dispatcherReturnDetailsHighestSerial =
        prefs.getInt('dispatcherReturnDetailsHighestSerial') ?? 1;
  }
}

class DispatcherReturnFormViewModel extends GetxController {
  final _DispatcherReturnMasterRepository _masterRepo = _DispatcherReturnMasterRepository();
  final DispatcherReturnDetailsViewModel detailsViewModel =
  Get.put(DispatcherReturnDetailsViewModel());

  var allReturnForms = <DispatcherReturnMasterModel>[].obs;
  var selectedShop = ''.obs;
  var shops = <DispatcherShopModel>[].obs;
  var isLoadingShops = false.obs;
  var isLoadingItems = false.obs;

  int _masterSerialCounter = 1;
  String _masterCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String _currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    fetchAllReturnForms();
    fetchShopsFromAPI();
    serialCounterGet();
  }

  /// Fetch shops from dispatcher API
  Future<void> fetchShopsFromAPI() async {
    isLoadingShops.value = true;
    try {
      final url = '$_kShopGetUrl$user_id';
      debugPrint('API URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        final List<dynamic> items = json['items'] ?? [];

        debugPrint("Found ${items.length} shops in items array");

        shops.value = items
            .map((item) => DispatcherShopModel.fromMap(item))
            .toList();

        debugPrint("Successfully loaded ${shops.length} shops");
      } else {
        debugPrint('Shop API error: ${response.statusCode}');
        Get.snackbar(
          'Warning',
          'Could not load shops (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error fetching shops: $e');
      Get.snackbar(
        'Warning',
        'Network error loading shops',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingShops.value = false;
    }
  }

  /// Fetch items for selected shop
  Future<void> fetchItemsForShop(String shopName) async {
    if (shopName.isEmpty) {
      detailsViewModel.items.clear();
      return;
    }

    isLoadingItems.value = true;
    try {
      final encodedShopName = Uri.encodeComponent(shopName);
      final url = '$_kItemsGetUrl$encodedShopName';

      debugPrint('Fetching items for shop: $shopName');
      debugPrint('Items API URL: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        debugPrint('Parsed response: $responseData');

        List<dynamic> itemsList = [];

        // Handle different response formats
        if (responseData is Map<String, dynamic>) {
          if (responseData['items'] != null) {
            itemsList = responseData['items'];
          } else if (responseData['data'] != null) {
            itemsList = responseData['data'];
          } else {
            itemsList = [responseData];
          }
        } else if (responseData is List) {
          itemsList = responseData;
        }

        debugPrint('Items list count: ${itemsList.length}');

        // Map to DispatcherReturnItem
        detailsViewModel.items.value = itemsList.map((item) {
          debugPrint('Processing item: $item');

          // Get item name - try different field names
          String name = item['PRODUCT'] ??
              item['product'] ??
              item['name'] ??
              item['ITEM_NAME'] ??
              item['item_name'] ??
              'Unknown';

          // Get rate - try different field names
          double rate = 0.0;
          if (item['RATE'] != null) {
            rate = double.tryParse(item['RATE'].toString()) ?? 0.0;
            debugPrint('Found RATE: ${item['RATE']} -> $rate');
          } else if (item['rate'] != null) {
            rate = double.tryParse(item['rate'].toString()) ?? 0.0;
            debugPrint('Found rate: ${item['rate']} -> $rate');
          } else if (item['Rate'] != null) {
            rate = double.tryParse(item['Rate'].toString()) ?? 0.0;
            debugPrint('Found Rate: ${item['Rate']} -> $rate');
          } else if (item['PRICE'] != null) {
            rate = double.tryParse(item['PRICE'].toString()) ?? 0.0;
            debugPrint('Found PRICE: ${item['PRICE']} -> $rate');
          } else if (item['price'] != null) {
            rate = double.tryParse(item['price'].toString()) ?? 0.0;
            debugPrint('Found price: ${item['price']} -> $rate');
          }

          // Get max quantity - try different field names
          double maxQuantity = 0.0;
          if (item['QUANTITY'] != null) {
            maxQuantity = double.tryParse(item['QUANTITY'].toString()) ?? 0.0;
            debugPrint('Found QUANTITY: ${item['QUANTITY']} -> $maxQuantity');
          } else if (item['quantity'] != null) {
            maxQuantity = double.tryParse(item['quantity'].toString()) ?? 0.0;
            debugPrint('Found quantity: ${item['quantity']} -> $maxQuantity');
          } else if (item['QTY'] != null) {
            maxQuantity = double.tryParse(item['QTY'].toString()) ?? 0.0;
            debugPrint('Found QTY: ${item['QTY']} -> $maxQuantity');
          } else if (item['maxQuantity'] != null) {
            maxQuantity = double.tryParse(item['maxQuantity'].toString()) ?? 0.0;
          }

          debugPrint('Mapped item: $name, Rate: $rate, Max Qty: $maxQuantity');

          return DispatcherReturnItem(
            name,
            rate: rate,
            maxQuantity: maxQuantity,
          );
        }).toList();

        debugPrint('✅ Loaded ${detailsViewModel.items.length} items for shop: $shopName');

        if (detailsViewModel.items.isEmpty) {
          Get.snackbar(
            'Info',
            'No items available for this shop',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }

        // Check if any item has rate > 0
        bool hasRate = detailsViewModel.items.any((item) => item.rate > 0);
        if (!hasRate && detailsViewModel.items.isNotEmpty) {
          Get.snackbar(
            'Warning',
            'Items loaded but rates are 0. Please check API response.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }

      } else {
        debugPrint('❌ Items API error: ${response.statusCode} - ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to load items (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching items: $e');
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<void> submitForm() async {
    try {
      final totalAmount = detailsViewModel.getTotalAmount();

      // Add debug prints
      debugPrint('Selected Shop: ${selectedShop.value}');
      debugPrint('Total Amount: $totalAmount');
      debugPrint('Form Rows Count: ${detailsViewModel.formRows.length}');

      // Check each row
      for (var i = 0; i < detailsViewModel.formRows.length; i++) {
        var row = detailsViewModel.formRows[i];
        debugPrint('Row $i - Item: ${row.selectedItem?.name}, Quantity: ${row.quantity}, Reason: ${row.reason}, Rate: ${row.rate}');
      }

      if (selectedShop.value.isEmpty) {
        throw Exception("Please select a shop.");
      }

      if (detailsViewModel.formRows.isEmpty) {
        throw Exception("Please add at least one item row.");
      }

      bool hasValidRow = false;
      for (var row in detailsViewModel.formRows) {
        if (row.selectedItem != null &&
            row.quantity.isNotEmpty &&
            double.tryParse(row.quantity) != null &&
            double.parse(row.quantity) > 0 &&
            row.reason.isNotEmpty) {
          hasValidRow = true;
          break;
        }
      }

      if (!hasValidRow) {
        throw Exception("Please fill at least one complete item row with quantity > 0.");
      }

      if (totalAmount <= 0.0) {
        throw Exception("Total amount must be greater than 0.");
      }

      await _loadCounter();
      final returnFormSerial = _generateMasterId(user_id);
      dispatcherReturnMasterId = returnFormSerial;

      await _masterRepo.add(DispatcherReturnMasterModel(
        returnMasterId: dispatcherReturnMasterId,
        selectShop: selectedShop.value,
        userId: user_id,
        returnAmount: totalAmount.toString(),
      ));

      await detailsViewModel.submitForm(dispatcherReturnMasterId!);
      await fetchAllReturnForms();

      Get.snackbar("Success", "Return form submitted!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // Clear after successful submit
      selectedShop.value = '';
      detailsViewModel.items.clear();
      detailsViewModel.formRows.value = [DispatcherReturnRow()];
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      debugPrint("Submit error: $e");
    }
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateFormat('MMM').format(DateTime.now());
    _masterSerialCounter =
        prefs.getInt('dispatcherMasterSerialCounter') ?? dispatcherReturnMasterHighestSerial ?? 1;
    _masterCurrentMonth = prefs.getString('dispatcherMasterCurrentMonth') ?? currentMonth;
    _currentUserId = prefs.getString('dispatcherCurrentUserId') ?? '';

    if (_masterCurrentMonth != currentMonth) {
      _masterSerialCounter = 1;
      _masterCurrentMonth = currentMonth;
    }
    debugPrint('MasterSerialCounter: $_masterSerialCounter');
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dispatcherMasterSerialCounter', _masterSerialCounter);
    await prefs.setString('dispatcherMasterCurrentMonth', _masterCurrentMonth);
    await prefs.setString('dispatcherCurrentUserId', _currentUserId);
  }

  String _generateMasterId(String userId) {
    final currentMonth = DateFormat('MMM').format(DateTime.now());
    if (_currentUserId != userId) {
      _masterSerialCounter = dispatcherReturnMasterHighestSerial ?? 1;
      _currentUserId = userId;
    }
    if (_masterCurrentMonth != currentMonth) {
      _masterSerialCounter = 1;
      _masterCurrentMonth = currentMonth;
    }
    final id = "DRM-$userId-$currentMonth-${_masterSerialCounter.toString().padLeft(3, '0')}";
    _masterSerialCounter++;
    _saveCounter();
    return id;
  }

  Future<void> fetchAllReturnForms() async {
    allReturnForms.value = await _masterRepo.getAll();
  }

  Future<void> serialCounterGet() async {
    await _masterRepo.fetchSerialNumber();
    final prefs = await SharedPreferences.getInstance();
    dispatcherReturnMasterHighestSerial =
        prefs.getInt('dispatcherReturnMasterHighestSerial') ?? 1;
  }
}

// ============================================================
// SECTION 6: UI — SCREEN & COMPONENTS
// ============================================================

class DispatcherReturnFormScreen extends StatefulWidget {
  const DispatcherReturnFormScreen({super.key});

  @override
  State<DispatcherReturnFormScreen> createState() => _DispatcherReturnFormScreenState();
}

class _DispatcherReturnFormScreenState extends State<DispatcherReturnFormScreen> {
  final DispatcherReturnFormViewModel _viewModel = Get.put(DispatcherReturnFormViewModel());

  @override
  void initState() {
    super.initState();
    _viewModel.detailsViewModel.serialCounterGet();
    _viewModel.serialCounterGet();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final hPadding = isTablet ? size.width * 0.08 : 16.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(isTablet: isTablet),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isTablet ? 28 : 16),
                      _buildShopDropdown(isTablet: isTablet),
                      SizedBox(height: isTablet ? 36 : 20),
                      _buildFormRowsList(size, isTablet: isTablet),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({bool isTablet = false}) {
    final titleFontSize = isTablet ? 22.0 : 17.0;
    return AppBar(
      backgroundColor: Colors.blueGrey.shade700,
      elevation: 0,
      toolbarHeight: isTablet ? 64 : kToolbarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Dispatcher Return Form',
        style: TextStyle(
          color: Colors.white,
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white, size: isTablet ? 26 : 22),
          onPressed: () => _viewModel.fetchShopsFromAPI(),
          tooltip: 'Refresh Shops',
        ),
      ],
    );
  }

  Widget _buildShopDropdown({bool isTablet = false}) {
    final labelFontSize = isTablet ? 17.0 : 15.0;
    return Obx(() {
      if (_viewModel.isLoadingShops.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 16),
            child: const CircularProgressIndicator(color: Colors.blueGrey),
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          _viewModel.selectedShop.value = '';
          _viewModel.detailsViewModel.items.clear();
          _viewModel.detailsViewModel.formRows.value = [DispatcherReturnRow()];
        },
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Shop Name',
            labelStyle: TextStyle(fontSize: labelFontSize),
            border: const UnderlineInputBorder(),
            prefixIcon: const Icon(Icons.store_outlined, color: Colors.blueGrey),
            contentPadding: EdgeInsets.symmetric(
              vertical: isTablet ? 14 : 8,
              horizontal: 0,
            ),
          ),
          value: _viewModel.selectedShop.value.isEmpty ? null : _viewModel.selectedShop.value,
          items: _viewModel.shops.map((shop) {
            return DropdownMenuItem<String>(
              value: shop.name,
              child: Text(
                shop.name,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            _viewModel.selectedShop.value = value;
            _viewModel.detailsViewModel.items.clear();
            _viewModel.detailsViewModel.formRows.value = [DispatcherReturnRow()];
            _viewModel.fetchItemsForShop(value);
          },
        ),
      );
    });
  }

  Widget _buildFormRowsList(Size size, {bool isTablet = false}) {
    return Obx(() {
      // Show loading indicator while fetching items
      if (_viewModel.isLoadingItems.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: const CircularProgressIndicator(color: Colors.blueGrey),
          ),
        );
      }

      // Show message if no items for selected shop
      if (_viewModel.selectedShop.value.isNotEmpty &&
          _viewModel.detailsViewModel.items.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Text(
              'No items available for this shop',
              style: TextStyle(
                color: Colors.grey,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
        );
      }

      // Show form rows
      return Column(
        children: _viewModel.detailsViewModel.formRows
            .asMap()
            .entries
            .map((entry) => _DispatcherFormRow(
          index: entry.key,
          row: entry.value,
          size: size,
          detailsViewModel: _viewModel.detailsViewModel,
          isTablet: isTablet,
        ))
            .toList(),
      );
    });
  }

  Widget _buildBottomButtons({bool isTablet = false}) {
    final vPadding = isTablet ? 20.0 : 14.0;
    final hPadding = isTablet ? 40.0 : 16.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isTablet
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: _DispatcherAddRowButton(
              detailsViewModel: _viewModel.detailsViewModel,
              isTablet: true,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: _DispatcherSubmitButton(viewModel: _viewModel, isTablet: true),
          ),
        ],
      )
          : Column(
        children: [
          _DispatcherAddRowButton(detailsViewModel: _viewModel.detailsViewModel),
          const SizedBox(height: 12),
          _DispatcherSubmitButton(viewModel: _viewModel),
        ],
      ),
    );
  }
}

// ---- Individual Form Row ----

class _DispatcherFormRow extends StatelessWidget {
  final int index;
  final DispatcherReturnRow row;
  final Size size;
  final DispatcherReturnDetailsViewModel detailsViewModel;
  final bool isTablet;

  const _DispatcherFormRow({
    required this.index,
    required this.row,
    required this.size,
    required this.detailsViewModel,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelFontSize = isTablet ? 15.0 : 13.0;
    final headerFontSize = isTablet ? 16.0 : 14.0;
    final amountFontSize = isTablet ? 15.0 : 13.0;
    final cardPadding = isTablet ? 18.0 : 14.0;
    final bottomMargin = isTablet ? 20.0 : 16.0;

    return Obx(() {
      return Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row header: index + remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                    fontSize: headerFontSize,
                  ),
                ),
                if (detailsViewModel.formRows.length > 1)
                  GestureDetector(
                    onTap: () => detailsViewModel.removeRow(index),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red.shade400,
                      size: isTablet ? 26 : 22,
                    ),
                  ),
              ],
            ),
            SizedBox(height: isTablet ? 14 : 10),

            // Item Dropdown
            DropdownButtonFormField<DispatcherReturnItem>(
              decoration: InputDecoration(
                labelText: 'Select Item',
                labelStyle: TextStyle(fontSize: labelFontSize),
                border: const UnderlineInputBorder(),
                isDense: true,
              ),
              value: row.selectedItem,
              items: detailsViewModel.items.map((item) {
                return DropdownMenuItem<DispatcherReturnItem>(
                  value: item,
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                  ),
                );
              }).toList(),
              onChanged: (item) {
                if (item == null) return;
                row.selectedItem = item;
                row.rate = item.rate;
                row.maxQuantity = item.maxQuantity;
                row.items = item.name;
                detailsViewModel.formRows.refresh();
              },
            ),
            SizedBox(height: isTablet ? 14 : 10),

            // Quantity + Reason in a row
            Row(
              children: [
                // Quantity field
                Expanded(
                  child: TextFormField(
                    initialValue: row.quantity,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                    decoration: InputDecoration(
                      labelText: row.maxQuantity != null && row.maxQuantity! > 0
                          ? 'Qty (max ${row.maxQuantity!.toStringAsFixed(0)})'
                          : 'Quantity',
                      labelStyle: TextStyle(fontSize: labelFontSize),
                      border: const UnderlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      row.quantity = val;
                      detailsViewModel.formRows.refresh();
                    },
                  ),
                ),
                SizedBox(width: isTablet ? 24 : 16),
                // Reason dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      labelStyle: TextStyle(fontSize: labelFontSize),
                      border: const UnderlineInputBorder(),
                      isDense: true,
                    ),
                    value: row.reason.isEmpty ? null : row.reason,
                    items: detailsViewModel.reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      row.reason = val;
                      detailsViewModel.formRows.refresh();
                    },
                  ),
                ),
              ],
            ),

            // Show amount if rate is available
            if (row.rate != null && row.rate! > 0 && row.quantity.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Amount: ${((double.tryParse(row.quantity) ?? 0) * row.rate!).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: amountFontSize,
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ---- Add Row Button ----

class _DispatcherAddRowButton extends StatelessWidget {
  final DispatcherReturnDetailsViewModel detailsViewModel;
  final bool isTablet;
  const _DispatcherAddRowButton({required this.detailsViewModel, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final buttonWidth = isTablet ? 240.0 : 200.0;
    final buttonHeight = isTablet ? 56.0 : 50.0;
    final fontSize = isTablet ? 17.0 : 16.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return GestureDetector(
      onTap: () => detailsViewModel.addRow(),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade600, Colors.blueGrey.shade500],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: iconSize),
            const SizedBox(width: 8),
            Text(
              'Add Row',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Submit Button ----

class _DispatcherSubmitButton extends StatelessWidget {
  final DispatcherReturnFormViewModel viewModel;
  final bool isTablet;
  const _DispatcherSubmitButton({required this.viewModel, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isTablet ? 56.0 : 50.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    return GestureDetector(
      onTap: () async {
        // Validate shop
        if (viewModel.selectedShop.value.isEmpty) {
          Get.snackbar(
            'Error',
            '⚠ Please select a shop before submitting.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        // Validate at least one row has data
        bool hasValidRow = false;
        for (var row in viewModel.detailsViewModel.formRows) {
          if (row.selectedItem != null &&
              row.quantity.isNotEmpty &&
              double.tryParse(row.quantity) != null &&
              double.parse(row.quantity) > 0 &&
              row.reason.isNotEmpty) {
            hasValidRow = true;
            break;
          }
        }

        if (!hasValidRow) {
          Get.snackbar(
            'Error',
            '⚠ Please fill at least one complete item row with quantity > 0.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        await viewModel.submitForm();
      },
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade600],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}