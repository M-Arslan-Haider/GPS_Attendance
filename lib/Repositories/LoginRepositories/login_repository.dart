
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../Models/LoginModels/login_models.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Services/ApiServices/api_service.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';

class LoginRepository extends GetxService{

  DBHelper dbHelper = DBHelper();
  // Fetch a specific user by user_id and password
  Future<LoginModels?> getUserByCredentials(String user_id, String password) async {
    var dbClient = await dbHelper.db;

    List<Map> maps = await dbClient.query(
        tableNameLogin,
        where: 'user_id = ? AND password = ?',
        whereArgs: [user_id, password],
        columns: ['user_id', 'password' , 'city' ,'user_name', 'designation' , 'brand' , 'images' ,'rsm','rsm_id','sm','sm_id','nsm','nsm_id', 'dispatcher', 'dispatcher_id' ]
    );

    if (maps.isNotEmpty) {
      return LoginModels.fromMap(maps.first); // Return the first matching user
    }
    return null; // No user found
  }
  Future<Map?> getUserDetailsById(String user_id) async {
    var dbClient = await dbHelper.db;

    List<Map> maps = await dbClient.query(
      tableNameLogin,
      where: 'user_id = ?',
      whereArgs: [user_id],
      columns: ['user_id', 'city', 'user_name', 'designation', 'brand', 'images', 'rsm', 'rsm_id', 'sm', 'sm_id', 'nsm', 'nsm_id',  'dispatcher', 'dispatcher_id'],
    );

    if (maps.isNotEmpty) {
      return maps.first; // Return the first matching user details as a Map
    }
    return null; // No user found
  }
  Future<List<LoginModels>> getLogin() async {
    // Get the database client
    var dbClient = await dbHelper.db;

    // Query the database
    List<Map> maps = await dbClient.query(
        tableNameLogin,
        columns: ['user_id', 'password' , 'city' ,'user_name', 'designation' , 'brand' ,  'images' ,'rsm','rsm_id','sm','sm_id','nsm','nsm_id',  'dispatcher', 'dispatcher_id']
    );

    // Print the raw data retrieved from the database

      debugPrint('Raw data from database:');

    // ignore: unused_local_variable
    for (var map in maps) {

        debugPrint("$map");

    }

    // Convert the raw data into a list
    List<LoginModels> login = [];
    for (int i = 0; i < maps.length; i++) {
      login.add(LoginModels.fromMap(maps[i]));
    }

    // Print the list of

      debugPrint('Parsed LoginModels objects:');


    return login;
  }

  Future<void> fetchAndSaveLogin() async {
    await Config.fetchLatestConfig();
    debugPrint( "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlLogin}");

    List<dynamic> data = await ApiService.getData(
        "${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlLogin}");
    // List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/valor_trading/login1/get");
    //  List<dynamic> data = await ApiService.getData("http://103.149.32.30:8080/ords/alnoor_town/login/get/");
    // List<dynamic> data = await ApiService.getData(
    //     "https://cloud.metaxperts.net:8443/erp/test1/loginget/get/"
    // );
    var dbClient = await dbHelper.db;

    debugPrint("Login Data: $data");
    // Save data to local database
    for (var item in data) {
      LoginModels model = LoginModels.fromMap(item);
      await dbClient.insert(tableNameLogin, model.toMap());

      // Save data to Firebase Firestore
      await FirebaseFirestore.instance
          .collection(tableNameLogin)
          .doc(model.user_id?.toString()) // Convert int? to String?
          .set(model.toMap());
    }
  }

  Future<int>add(LoginModels loginModels) async{
    var dbClient = await dbHelper.db;
    return await dbClient.insert(tableNameLogin,loginModels.toMap());
  }

  Future<int>update(LoginModels loginModels) async{
    var dbClient = await dbHelper.db;
    return await dbClient.update(tableNameLogin,loginModels.toMap(),
        where: 'user_id = ?', whereArgs: [loginModels.user_id]);

  }

  Future<int>delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient.delete(tableNameLogin,
        where: 'user_id = ?', whereArgs: [id]);
  }
  Future<List<LoginModels>> getBookerNamesByDesignation(String designationColumn, String designationValue) async {
    var dbClient = await dbHelper.db;

    // Debug: Print the query parameters
    debugPrint('Querying table: $tableNameLogin');
    debugPrint('Where: $designationColumn = $designationValue');

    // Query the database for users with the given designation column and value
    List<Map> maps = await dbClient.query(
      tableNameLogin,
      where: '$designationColumn = ?',
      whereArgs: [designationValue],
      columns: ['user_id', 'password', 'city', 'user_name', 'designation', 'brand', 'images', 'rsm', 'rsm_id', 'sm', 'sm_id', 'nsm', 'nsm_id',  'dispatcher', 'dispatcher_id'],
    );

    // Debug: Print the fetched data
    debugPrint('Fetched data: $maps');

    // Convert the raw data into a list of LoginModels
    List<LoginModels> bookers = [];
    for (var map in maps) {
      bookers.add(LoginModels.fromMap(map));
    }

    return bookers;
  }
  Future<List<String>> getBookerNamesByRSMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      tableNameLogin,
      where: 'rsm_id = ?',
      whereArgs: [user_id],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }
  Future<List<String>> getBookerNamesBySMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      tableNameLogin,
      where: 'sm_id = ?',
      whereArgs: [user_id],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }
  Future<List<String>> getBookerNamesByNSMDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      tableNameLogin,
      where: 'nsm_id = ?',
      whereArgs: [user_id],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }
  Future<List<String>> getBookerNamesByDISPATCHERDesignation() async {
    var dbClient = await dbHelper.db;

    final List<Map<String, dynamic>> bookerNames = await dbClient!.query(
      tableNameLogin,
      where: 'dispatcher_id = ?',
      whereArgs: [user_id],
    );
    return bookerNames.map((map) => map['user_id'] as String).toList();

  }


}