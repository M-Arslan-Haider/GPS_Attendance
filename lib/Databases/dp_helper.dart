// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'package:sqflite/sqflite.dart';
// import 'dart:io' as io;
//
// class DBHelper extends GetxService {
//   static Database? _db;
//
//   // Table Names as Static Constants
//   // static const String centralPoints = 'centralPoints';
//
//
//   Future<Database> get db async {
//     if (_db != null) {
//       return _db!;
//     }
//     _db = await initDatabase();
//     return _db!;
//   }
//
//   initDatabase() async {
//     io.Directory documentDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentDirectory.path, 'bookIt.db');
//     var db = openDatabase(path, version: 7, onCreate: _onCreate);
//     return db;
//   }
//
//   _onCreate(Database db, int version) async {
//     // Database Tables
//     List<String> tableQueries = [
//       // Existing tables
//       "CREATE TABLE IF NOT EXISTS $tableNameLogin(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT,images BLOB)",
//       "CREATE TABLE IF NOT EXISTS $addShopTableName(shop_id TEXT PRIMARY KEY, shop_date TEXT, shop_time TEXT, shop_name TEXT,city TEXT,shop_address TEXT,owner_name TEXT,owner_cnic TEXT,phone_no TEXT,address TEXT, alternative_phone_no TEXT,latitude TEXT, longitude TEXT, user_id TEXT, posted INTEGER DEFAULT 0 )",
//       "CREATE TABLE IF NOT EXISTS $shopVisitMasterTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT, shop_visit_time TEXT, brand TEXT, shop_address TEXT,user_id TEXT, shop_name TEXT, address TEXT, latitude TEXT, longitude TEXT, city TEXT,owner_name TEXT,posted INTEGER DEFAULT 0, booker_name TEXT,walk_through TEXT,planogram TEXT,signage TEXT,product_reviewed TEXT,feedback TEXT,body BLOB)",
//       "CREATE TABLE IF NOT EXISTS $shopVisitDetailsTableName(shop_visit_details_id TEXT PRIMARY KEY, shop_visit_details_date TEXT, shop_visit_details_time TEXT,user_id TEXT, shop_visit_master_id TEXT, product TEXT, quantity TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(shop_visit_master_id) REFERENCES $shopVisitMasterTableName(shop_visit_master_id))",
//       "CREATE TABLE IF NOT EXISTS $orderMasterTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,user_name TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT,city TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT)",
//       "CREATE TABLE IF NOT EXISTS $orderMasterStatusTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT)",
//       "CREATE TABLE IF NOT EXISTS $orderDetailsTableName (order_details_id TEXT PRIMARY KEY, order_details_date TEXT, order_details_time TEXT,user_id TEXT, order_master_id TEXT, product TEXT, quantity TEXT, in_stock TEXT, rate TEXT,posted INTEGER DEFAULT 0, amount TEXT, FOREIGN KEY(order_master_id) REFERENCES $orderMasterTableName(order_master_id))",
//       "CREATE TABLE IF NOT EXISTS $returnFormMasterTableName(return_master_id TEXT PRIMARY KEY, return_amount TEXT,return_master_date TEXT,user_id TEXT, return_master_time TEXT, posted INTEGER DEFAULT 0,select_shop TEXT)",
//       "CREATE TABLE IF NOT EXISTS $returnFormDetailsTableName(return_details_id TEXT PRIMARY KEY, return_details_date TEXT, return_details_time TEXT,user_id TEXT, return_master_id TEXT, item TEXT, quantity TEXT, reason TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(return_master_id) REFERENCES $returnFormMasterTableName(return_master_id))",
//       "CREATE TABLE IF NOT EXISTS $recoveryFormTableName(recovery_id TEXT PRIMARY KEY, recovery_date TEXT, recovery_time TEXT, shop_name TEXT,user_id TEXT,current_balance TEXT,cash_recovery TEXT,net_balance TEXT,posted INTEGER DEFAULT 0)",
//       "CREATE TABLE IF NOT EXISTS $attendanceTableName(attendance_in_id TEXT PRIMARY KEY, attendance_in_date TEXT, attendance_in_time TEXT,user_id TEXT, lat_in TEXT, lng_in TEXT, booker_name TEXT,designation, city TEXT,posted INTEGER DEFAULT 0, address TEXT)",
//       "CREATE TABLE IF NOT EXISTS $attendanceOutTableName(attendance_out_id TEXT PRIMARY KEY, attendance_out_date TEXT, attendance_out_time TEXT,  total_time TEXT, user_id TEXT, lat_out TEXT, lng_out TEXT, total_distance TEXT,posted INTEGER DEFAULT 0, address TEXT)",
//       "CREATE TABLE IF NOT EXISTS $locationTableName(location_id TEXT PRIMARY KEY, location_date TEXT, location_time TEXT, file_name TEXT, user_id TEXT, total_distance TEXT, booker_name TEXT, posted INTEGER DEFAULT 0, body BLOB)",
//       "CREATE TABLE IF NOT EXISTS $productsTableName(id NUMBER, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT, in_stock TEXT)",
//       "CREATE TABLE IF NOT EXISTS $headsShopVisitsTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT,shop_visit_time TEXT,posted INTEGER DEFAULT 0, shop_name TEXT, user_id TEXT, city TEXT, booker_name TEXT, feedback TEXT, shop_address TEXT, booker_id TEXT)",
//
//       // Travel Time Table
//       '''CREATE TABLE IF NOT EXISTS $travelTimeData (
//         id TEXT PRIMARY KEY,
//         user_id TEXT,
//         travel_date TEXT,
//         start_time TEXT,
//         end_time TEXT,
//         travel_distance REAL,
//         travel_time REAL,
//         average_speed REAL,
//         working_time REAL,
//         idle_time REAL,
//         travel_type TEXT,
//         latitude REAL,
//         longitude REAL,
//         address TEXT,
//         posted INTEGER DEFAULT 0
//       )''',
//       //
//       // // Travel Data Master Table
//       // '''CREATE TABLE IF NOT EXISTS $TravelDataMasterTable(
//       //   id INTEGER PRIMARY KEY AUTOINCREMENT,
//       //   travel_id TEXT UNIQUE,
//       //   user_id TEXT,
//       //   travel_date TEXT,
//       //   start_time TEXT,
//       //   end_time TEXT,
//       //   total_travel_time TEXT,
//       //   total_travel_distance REAL,
//       //   average_speed REAL,
//       //   total_working_time TEXT,
//       //   start_lat REAL,
//       //   start_lng REAL,
//       //   end_lat REAL,
//       //   end_lng REAL,
//       //   gpx BLOB,
//       //   posted INTEGER DEFAULT 0,
//       //   created_at TEXT
//       // )''',
//
//       // Location Clusters Table
//       // '''CREATE TABLE IF NOT EXISTS $locationClusters(
//       //   id INTEGER PRIMARY KEY AUTOINCREMENT,
//       //   user_id TEXT,
//       //   start_time TEXT,
//       //   end_time TEXT,
//       //   start_lat REAL,
//       //   start_lon REAL,
//       //   end_lat REAL,
//       //   end_lon REAL,
//       //   radius REAL,
//       //   stay_time TEXT
//       // )''',
//
//       // CENTRAL POINTS TABLE - NEW
//       '''CREATE TABLE IF NOT EXISTS $centralPoints(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         central_point_id TEXT UNIQUE,
//         user_id TEXT,
//         overall_center_lat REAL,
//         overall_center_lng REAL,
//         total_clusters INTEGER,
//         total_coordinates INTEGER,
//         processing_date TEXT,
//         booker_name TEXT,
//         cluster_data TEXT,
//         posted INTEGER DEFAULT 0,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP
//       )''',
//     ];
//
//     debugPrint('✅ All tables created successfully - Version 6');
//
//     for (var query in tableQueries) {
//       await db.execute(query);
//     }
//   }
//
//   Future<void> clearData() async {
//     final db = await this.db;
//     List<String> tableNames = [productsTableName];
//
//     for (var tableName in tableNames) {
//       await db.execute("DELETE FROM $tableName");
//     }
//   }
// }



import 'package:get/get.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DBHelper extends GetxService {
  /// In Dart, the underscore (_) at the beginning of a variable or method name indicates private access.
  /// This means the variable or method is only accessible within the file in which it is declared.
  /// Like Encapsulation process

  static Database? _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }
  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'bookIt.db');
    var db = openDatabase(path, version: 7, onCreate: _onCreate);
    return db;
  }

  // initDatabase() async {
  //   io.Directory documentDirectory = await getApplicationDocumentsDirectory();
  //   String path = join(documentDirectory.path, 'bookIt.db');
  //   var db = openDatabase(path, version: 1, onCreate: _onCreate);
  //   return db;
  // }

  _onCreate(Database db, int version) async {
    // Database Table
    List<String> tableQueries = [
      "CREATE TABLE IF NOT EXISTS $tableNameLogin(user_id TEXT , password TEXT ,user_name TEXT, city TEXT, designation TEXT,brand TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT,images BLOB)",
      "CREATE TABLE IF NOT EXISTS $addShopTableName(shop_id TEXT PRIMARY KEY, shop_date TEXT, shop_time TEXT, shop_name TEXT,city TEXT,shop_address TEXT,owner_name TEXT,owner_cnic TEXT,phone_no TEXT,address TEXT, alternative_phone_no TEXT,latitude TEXT, longitude TEXT, user_id TEXT, posted INTEGER DEFAULT 0 )",
      "CREATE TABLE IF NOT EXISTS $shopVisitMasterTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT, shop_visit_time TEXT, brand TEXT, shop_address TEXT,user_id TEXT, shop_name TEXT, address TEXT, latitude TEXT, longitude TEXT, city TEXT,owner_name TEXT,posted INTEGER DEFAULT 0, booker_name TEXT,walk_through TEXT,planogram TEXT,signage TEXT,product_reviewed TEXT,feedback TEXT,body BLOB)",
      "CREATE TABLE IF NOT EXISTS $shopVisitDetailsTableName(shop_visit_details_id TEXT PRIMARY KEY, shop_visit_details_date TEXT, shop_visit_details_time TEXT,user_id TEXT, shop_visit_master_id TEXT, product TEXT, quantity TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(shop_visit_master_id) REFERENCES $shopVisitMasterTableName(shop_visit_master_id))",
      "CREATE TABLE IF NOT EXISTS $orderMasterTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,user_name TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT,city TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT,rsm TEXT,sm TEXT,nsm TEXT,rsm_id TEXT,sm_id TEXT,nsm_id TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderMasterStatusTableName(order_master_id TEXT PRIMARY KEY,order_status TEXT, order_master_date TEXT, order_master_time TEXT,user_id TEXT,shop_name TEXT,owner_name TEXT, phone_no TEXT,brand TEXT,total TEXT, credit_limit TEXT, posted INTEGER DEFAULT 0,required_delivery_date TEXT)",
      "CREATE TABLE IF NOT EXISTS $orderDetailsTableName (order_details_id TEXT PRIMARY KEY, order_details_date TEXT, order_details_time TEXT,user_id TEXT, order_master_id TEXT, product TEXT, quantity TEXT, in_stock TEXT, rate TEXT,posted INTEGER DEFAULT 0, amount TEXT, FOREIGN KEY(order_master_id) REFERENCES $orderMasterTableName(order_master_id))",
      "CREATE TABLE IF NOT EXISTS $returnFormMasterTableName(return_master_id TEXT PRIMARY KEY, return_amount TEXT,return_master_date TEXT,user_id TEXT, return_master_time TEXT, posted INTEGER DEFAULT 0,select_shop TEXT)",
      "CREATE TABLE IF NOT EXISTS $returnFormDetailsTableName(return_details_id TEXT PRIMARY KEY, return_details_date TEXT, return_details_time TEXT,user_id TEXT, return_master_id TEXT, item TEXT, quantity TEXT, reason TEXT,posted INTEGER DEFAULT 0, FOREIGN KEY(return_master_id) REFERENCES $returnFormMasterTableName(return_master_id))",
      "CREATE TABLE IF NOT EXISTS $recoveryFormTableName(recovery_id TEXT PRIMARY KEY, recovery_date TEXT, recovery_time TEXT, shop_name TEXT,user_id TEXT,current_balance TEXT,cash_recovery TEXT,net_balance TEXT,posted INTEGER DEFAULT 0)",
      "CREATE TABLE IF NOT EXISTS $attendanceTableName(attendance_in_id TEXT PRIMARY KEY, attendance_in_date TEXT, attendance_in_time TEXT,user_id TEXT, lat_in TEXT, lng_in TEXT, booker_name TEXT,designation, city TEXT,posted INTEGER DEFAULT 0, address TEXT)",
      "CREATE TABLE IF NOT EXISTS $attendanceOutTableName(attendance_out_id TEXT PRIMARY KEY, attendance_out_date TEXT, attendance_out_time TEXT,  total_time TEXT, user_id TEXT, lat_out TEXT, lng_out TEXT, total_distance TEXT,posted INTEGER DEFAULT 0, address TEXT)",
      "CREATE TABLE IF NOT EXISTS $locationTableName(location_id TEXT PRIMARY KEY, location_date TEXT, location_time TEXT, file_name TEXT, user_id TEXT, total_distance TEXT, booker_name TEXT, posted INTEGER DEFAULT 0, body BLOB)",
      "CREATE TABLE IF NOT EXISTS $productsTableName(id NUMBER, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT, in_stock TEXT)",
      "CREATE TABLE IF NOT EXISTS $headsShopVisitsTableName(shop_visit_master_id TEXT PRIMARY KEY, shop_visit_date TEXT,shop_visit_time TEXT,posted INTEGER DEFAULT 0, shop_name TEXT, user_id TEXT, city TEXT, booker_name TEXT, feedback TEXT, shop_address TEXT, booker_id TEXT)",

      // ✅ CORRECTED Travel Time Table
      'CREATE TABLE IF NOT EXISTS $travelTimeData (id TEXT PRIMARY KEY, user_id TEXT,  travel_date TEXT, start_time TEXT, end_time TEXT, travel_distance REAL, travel_time REAL, average_speed REAL, working_time REAL, idle_time REAL, travel_type TEXT, latitude REAL, longitude REAL, address TEXT, posted INTEGER DEFAULT 0)',


      '''
      CREATE TABLE $centralPoints(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  central_point_id TEXT UNIQUE,
  user_id TEXT,
  overall_center_lat REAL,
  overall_center_lng REAL,
  total_clusters INTEGER,
  total_coordinates INTEGER,
  processing_date TEXT,
  booker_name TEXT,
  cluster_data TEXT,

  created_at TEXT,
  cluster_area TEXT,
  address_district TEXT,
  stay_time_in_cluster REAL
)
    ''',
        ];

    print('✅ All tables created successfully - Version 5');
    print('✅ Travel time table created in upgrade');

    for (var query in tableQueries) {
      await db.execute(query);
    }
  }
  Future<void> clearData() async {
    final db = await this.db; // Get the database instance

    // List of all table names to clear data
    List<String> tableNames = [
      // tableNameLogin,
      productsTableName
    ];

    for (var tableName in tableNames) {
      await db.execute("DELETE FROM $tableName");
    }
  }

}
