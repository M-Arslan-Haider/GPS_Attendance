//
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
// class DailyCounter {
//   // 🔹 Shop visit keys
//   static const String _shopKey = "daily_shop_visit";
//   static const String _shopDateKey = "daily_shop_date";
//
//   // 🔹 Order keys
//   static const String _orderKey = "daily_order_count";
//   static const String _orderAmountKey = "daily_order_amount";
//   static const String _orderDateKey = "daily_order_date";
//
//   // 🔹 Recovery order keys
//   static const String _recoveryOrderKey = "daily_recovery_order_count";
//   static const String _recoveryAmountKey = "daily_recovery_amount";
//   static const String _recoveryDateKey = "daily_recovery_date";
//
//   static String _today() => DateFormat("yyyy-MM-dd").format(DateTime.now());
//
//   /// 🔹 SHOP VISITS
//   static Future<void> increaseShopVisit() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_shopDateKey);
//     int count = prefs.getInt(_shopKey) ?? 0;
//
//     if (savedDate != today) {
//       count = 0;
//       await prefs.setString(_shopDateKey, today);
//     }
//
//     count++;
//     await prefs.setInt(_shopKey, count);
//   }
//
//   static Future<int> getTodayShopVisits() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_shopDateKey);
//     int count = prefs.getInt(_shopKey) ?? 0;
//
//     if (savedDate != today) {
//       await prefs.setString(_shopDateKey, today);
//       await prefs.setInt(_shopKey, 0);
//       return 0;
//     }
//     return count;
//   }
//
//   /// 🔹 ORDERS - FIXED
//   static Future<void> increaseOrder({int count = 1, double amount = 0.0}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_orderDateKey);
//     int currentCount = prefs.getInt(_orderKey) ?? 0;
//     double currentAmount = prefs.getDouble(_orderAmountKey) ?? 0.0;
//
//     if (savedDate != today) {
//       currentCount = 0;
//       currentAmount = 0.0;
//       await prefs.setString(_orderDateKey, today);
//     }
//
//     // FIX: Always increase by 1 for order count (ignore the 'count' parameter)
//     currentCount += 1;
//     currentAmount += amount;
//
//     await prefs.setInt(_orderKey, currentCount);
//     await prefs.setDouble(_orderAmountKey, currentAmount);
//   }
//
//   static Future<int> getTodayOrderCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_orderDateKey);
//     int count = prefs.getInt(_orderKey) ?? 0;
//
//     if (savedDate != today) {
//       await prefs.setString(_orderDateKey, today);
//       await prefs.setInt(_orderKey, 0);
//       await prefs.setDouble(_orderAmountKey, 0.0);
//       return 0;
//     }
//     return count;
//   }
//
//   static Future<double> getTodayOrderAmount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_orderDateKey);
//     double amount = prefs.getDouble(_orderAmountKey) ?? 0.0;
//
//     if (savedDate != today) {
//       await prefs.setString(_orderDateKey, today);
//       await prefs.setInt(_orderKey, 0);
//       await prefs.setDouble(_orderAmountKey, 0.0);
//       return 0.0;
//     }
//     return amount;
//   }
//
//   /// 🔹 RECOVERY ORDERS
//   static Future<void> increaseRecovery({int count = 1, double amount = 0.0}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_recoveryDateKey);
//     int currentCount = prefs.getInt(_recoveryOrderKey) ?? 0;
//     double currentAmount = prefs.getDouble(_recoveryAmountKey) ?? 0.0;
//
//     if (savedDate != today) {
//       currentCount = 0;
//       currentAmount = 0.0;
//       await prefs.setString(_recoveryDateKey, today);
//     }
//
//     currentCount += count;
//     currentAmount += amount;
//
//     await prefs.setInt(_recoveryOrderKey, currentCount);
//     await prefs.setDouble(_recoveryAmountKey, currentAmount);
//   }
//
//   static Future<int> getTodayRecoveryCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_recoveryDateKey);
//     int count = prefs.getInt(_recoveryOrderKey) ?? 0;
//
//     if (savedDate != today) {
//       await prefs.setString(_recoveryDateKey, today);
//       await prefs.setInt(_recoveryOrderKey, 0);
//       await prefs.setDouble(_recoveryAmountKey, 0.0);
//       return 0;
//     }
//     return count;
//   }
//
//   static Future<double> getTodayRecoveryAmount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = _today();
//     final savedDate = prefs.getString(_recoveryDateKey);
//     double amount = prefs.getDouble(_recoveryAmountKey) ?? 0.0;
//
//     if (savedDate != today) {
//       await prefs.setString(_recoveryDateKey, today);
//       await prefs.setInt(_recoveryOrderKey, 0);
//       await prefs.setDouble(_recoveryAmountKey, 0.0);
//       return 0.0;
//     }
//     return amount;
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DailyCounter {
  // 🔹 Shop visit keys
  static const String _shopKey = "daily_shop_visit";
  static const String _shopDateKey = "daily_shop_date";

  // 🔹 Order keys
  static const String _orderKey = "daily_order_count";
  static const String _orderAmountKey = "daily_order_amount";
  static const String _orderDateKey = "daily_order_date";

  // 🔹 Recovery order keys
  static const String _recoveryOrderKey = "daily_recovery_order_count";
  static const String _recoveryAmountKey = "daily_recovery_amount";
  static const String _recoveryDateKey = "daily_recovery_date";

  static String _today() => DateFormat("yyyy-MM-dd").format(DateTime.now());

  /// 🔹 SHOP VISITS
  static Future<void> increaseShopVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_shopDateKey);
    int count = prefs.getInt(_shopKey) ?? 0;

    if (savedDate != today) {
      count = 0;
      await prefs.setString(_shopDateKey, today);
    }

    count++;
    await prefs.setInt(_shopKey, count);
  }

  static Future<int> getTodayShopVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_shopDateKey);
    int count = prefs.getInt(_shopKey) ?? 0;

    if (savedDate != today) {
      await prefs.setString(_shopDateKey, today);
      await prefs.setInt(_shopKey, 0);
      return 0;
    }
    return count;
  }

  /// 🔹 ORDERS - FIXED
  static Future<void> increaseOrder({int count = 1, double amount = 0.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_orderDateKey);

    // FIX: Check date and reset BOTH count AND amount when date changes
    if (savedDate != today) {
      await prefs.setString(_orderDateKey, today);
      await prefs.setInt(_orderKey, 0);
      await prefs.setDouble(_orderAmountKey, 0.0);
    }

    // Now get fresh values after potential reset
    int currentCount = prefs.getInt(_orderKey) ?? 0;
    double currentAmount = prefs.getDouble(_orderAmountKey) ?? 0.0;

    // FIX: Always increase by 1 for order count (ignore the 'count' parameter)
    currentCount += 1;
    currentAmount += amount;

    await prefs.setInt(_orderKey, currentCount);
    await prefs.setDouble(_orderAmountKey, currentAmount);
  }

  static Future<int> getTodayOrderCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_orderDateKey);

    if (savedDate != today) {
      await prefs.setString(_orderDateKey, today);
      await prefs.setInt(_orderKey, 0);
      await prefs.setDouble(_orderAmountKey, 0.0);
      return 0;
    }

    return prefs.getInt(_orderKey) ?? 0;
  }

  static Future<double> getTodayOrderAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_orderDateKey);

    if (savedDate != today) {
      await prefs.setString(_orderDateKey, today);
      await prefs.setInt(_orderKey, 0);
      await prefs.setDouble(_orderAmountKey, 0.0);
      return 0.0;
    }

    return prefs.getDouble(_orderAmountKey) ?? 0.0;
  }

  /// 🔹 RECOVERY ORDERS
  static Future<void> increaseRecovery({int count = 1, double amount = 0.0}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_recoveryDateKey);

    // FIX: Check date and reset BOTH count AND amount when date changes
    if (savedDate != today) {
      await prefs.setString(_recoveryDateKey, today);
      await prefs.setInt(_recoveryOrderKey, 0);
      await prefs.setDouble(_recoveryAmountKey, 0.0);
    }

    // Now get fresh values after potential reset
    int currentCount = prefs.getInt(_recoveryOrderKey) ?? 0;
    double currentAmount = prefs.getDouble(_recoveryAmountKey) ?? 0.0;

    currentCount += count;
    currentAmount += amount;

    await prefs.setInt(_recoveryOrderKey, currentCount);
    await prefs.setDouble(_recoveryAmountKey, currentAmount);
  }

  static Future<int> getTodayRecoveryCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_recoveryDateKey);

    if (savedDate != today) {
      await prefs.setString(_recoveryDateKey, today);
      await prefs.setInt(_recoveryOrderKey, 0);
      await prefs.setDouble(_recoveryAmountKey, 0.0);
      return 0;
    }

    return prefs.getInt(_recoveryOrderKey) ?? 0;
  }

  static Future<double> getTodayRecoveryAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final savedDate = prefs.getString(_recoveryDateKey);

    if (savedDate != today) {
      await prefs.setString(_recoveryDateKey, today);
      await prefs.setInt(_recoveryOrderKey, 0);
      await prefs.setDouble(_recoveryAmountKey, 0.0);
      return 0.0;
    }

    return prefs.getDouble(_recoveryAmountKey) ?? 0.0;
  }
}