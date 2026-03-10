import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/LoginModels/login_models.dart';
import '../../constants.dart';

class LoginRepository extends GetxService {

  // Fetch login data from Oracle API
  Future<List<LoginModels>> fetchLoginFromApi() async {
    try {
      debugPrint('📡 Fetching login data from: $loginApiEndpoint');

      final response = await http
          .get(Uri.parse(loginApiEndpoint))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to load login data: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);

      List<dynamic> items = data['items'] ?? [];

      debugPrint('✅ Fetched ${items.length} users from API');

      return items.map((json) => LoginModels.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching login data: $e');
      return [];
    }
  }

  // Get user by credentials
  Future<LoginModels?> getUserByCredentials(String userId, String password) async {
    try {
      final apiData = await fetchLoginFromApi();

      // Try to parse userId as int for comparison
      int? userIdInt = int.tryParse(userId);

      for (var user in apiData) {
        bool idMatches = false;

        if (userIdInt != null) {
          idMatches = user.emp_id == userIdInt;
        } else {
          idMatches = user.emp_id.toString() == userId;
        }

        // For now, we're not validating password as API doesn't return passwords
        // You'll need to implement password validation separately
        if (idMatches) {
          debugPrint('✅ User found: ${user.emp_name}, Role: ${user.job}');
          return user;
        }
      }

      debugPrint('❌ User not found with ID: $userId');
      return null;
    } catch (e) {
      debugPrint('❌ Error in getUserByCredentials: $e');
      return null;
    }
  }

// // Save login data to local database
// Future<void> saveLoginDataToLocal(List<LoginModels> loginData) async {
//   var dbClient = await dbHelper.db;
//   await dbClient.delete(tableNameLogin);
//
//   for (var model in loginData) {
//     await dbClient.insert(tableNameLogin, model.toJson());
//   }
// }

// // Sync login data
// Future<bool> syncLoginData() async {
//   try {
//     final apiData = await fetchLoginFromApi();
//     if (apiData.isNotEmpty) {
//       await saveLoginDataToLocal(apiData);
//       return true;
//     }
//     return false;
//   } catch (e) {
//     debugPrint('Sync failed: $e');
//     return false;
//   }
// }
}