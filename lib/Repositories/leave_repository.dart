// // import 'package:order_booking_app/Databases/util.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:order_booking_app/Databases/dp_helper.dart';
// // import '../Models/leave_model.dart';
// // import '../Services/FirebaseServices/firebase_remote_config.dart';
// //
// //
// // class LeaveRepository {
// //   final DBHelper dbHelper = DBHelper();
// //
// //   // Add this helper method at the top of the class
// //   String _generateLeaveId(String bookerId, int sequenceNumber) {
// //     final now = DateTime.now();
// //     final day = now.day.toString().padLeft(2, '0');
// //     final month = _getMonthAbbreviation(now.month);
// //     final sequence = sequenceNumber.toString().padLeft(3, '0');
// //
// //     return 'LV-$bookerId-$day-$month-$sequence';
// //   }
// //
// //   String _getMonthAbbreviation(int month) {
// //     final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
// //       'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
// //     return months[month - 1];
// //   }
// //
// //   Future<bool> submitLeave(LeaveModel model) async {
// //     try {
// //       print('🔄 Starting leave submission...');
// //
// //       // First save to local database
// //       final dbResult = await dbHelper.insertLeave(model);
// //       if (dbResult > 0) {
// //         print('✅ Leave saved to local database successfully! ID: $dbResult');
// //         print('📝 Leave Details:');
// //         print('   Booker: ${model.bookerName}');
// //         print('   Type: ${model.leaveType}');
// //         print('   Dates: ${model.startDate} to ${model.endDate}');
// //         print('   Days: ${model.totalDays}');
// //       } else {
// //         print('❌ Failed to save leave to local database');
// //         return false;
// //       }
// //
// //       // Then try to submit to server if network is available
// //       final isOnline = await isNetworkAvailable();
// //       if (isOnline) {
// //         try {
// //           // Build API URL using Config class format
// //           // Adjust the endpoint name as needed (e.g., "submitLeave", "applyLeave", etc.)
// //           String apiEndpoint = "postApiUrlLeaveForm"; // Change this to your actual leave endpoint
// //           String fullUrl = "${Config.postApiUrlLeaveForm}";
// //
// //           print('🌐 Submitting to API: $fullUrl');
// //           print('📡 Request Data: ${model.toJson()}');
// //
// //           final url = Uri.parse(fullUrl);
// //           final response = await http.post(
// //             url,
// //             headers: {
// //               "Content-Type": "application/json",
// //               "Accept": "application/json",
// //             },
// //             body: jsonEncode(model.toJson()),
// //           );
// //
// //           print('📡 API Response Status: ${response.statusCode}');
// //           print('📡 API Response Body: ${response.body}');
// //
// //           if (response.statusCode == 200 || response.statusCode == 201) {
// //             try {
// //               final responseData = jsonDecode(response.body);
// //
// //               // Mark as posted in local database
// //               // Try to get leave ID from response or use generated one
// //               String leaveId = responseData['leave_id']?.toString() ??
// //                   model.id ??
// //                   'LV${DateTime.now().millisecondsSinceEpoch}${model.bookerId.substring(0, 3)}';
// //
// //               await dbHelper.markLeaveAsPosted(leaveId);
// //               print('✅ Leave submitted to server successfully! Leave ID: $leaveId');
// //
// //               // Update model with server response if needed
// //               if (responseData['id'] != null) {
// //                 model = model.copyWith(id: responseData['id'].toString());
// //               }
// //
// //               return true;
// //             } catch (e) {
// //               print('⚠️ Error parsing response, but status is 200: $e');
// //               // Still return true since server accepted the request
// //               return true;
// //             }
// //           } else {
// //             print('❌ API Error: ${response.statusCode} - ${response.body}');
// //             // Leave is saved locally, will sync later
// //             return true;
// //           }
// //         } catch (e) {
// //           print('🚨 API submission failed: $e');
// //           print('📋 Stack trace: ${e.toString()}');
// //           // Leave is saved locally, will sync later
// //           return true;
// //         }
// //       } else {
// //         print('📴 No internet connection - leave saved locally only');
// //         // If offline, leave is still saved locally
// //         return true;
// //       }
// //     } catch (e) {
// //       print('❌ Error in submitLeave: $e');
// //       print('📋 Stack trace: ${e.toString()}');
// //       return false;
// //     }
// //   }
// //
// //   Future<List<Map<String, dynamic>>> getMyLeaves(String bookerId) async {
// //     return await dbHelper.getLeavesByBookerId(bookerId);
// //   }
// //
// //   Future<List<Map<String, dynamic>>> getPendingLeaves() async {
// //     return await dbHelper.getPendingLeaves();
// //   }
// //
// //   Future<void> syncPendingLeaves() async {
// //     final isOnline = await isNetworkAvailable();
// //     if (!isOnline) {
// //       print('📴 No internet connection - cannot sync pending leaves');
// //       return;
// //     }
// //
// //     final pendingLeaves = await dbHelper.getPendingLeaves();
// //
// //     if (pendingLeaves.isEmpty) {
// //       print('📭 No pending leaves to sync');
// //       return;
// //     }
// //
// //     print('🔄 Syncing ${pendingLeaves.length} pending leaves...');
// //     int successfulSyncs = 0;
// //     int failedSyncs = 0;
// //
// //     for (var leave in pendingLeaves) {
// //       try {
// //         final model = LeaveModel(
// //           id: leave['leave_id']?.toString(),
// //           bookerId: leave['booker_id'].toString(),
// //           bookerName: leave['booker_name']?.toString(),
// //           leaveType: leave['leave_type'].toString(),
// //           startDate: leave['start_date'].toString(),
// //           endDate: leave['end_date'].toString(),
// //           totalDays: leave['total_days'] as int,
// //           isHalfDay: leave['is_half_day'] == 1,
// //           reason: leave['reason'].toString(),
// //           attachmentUrl: leave['attachment_url']?.toString(),
// //           applicationDate: leave['application_date']?.toString(),
// //           applicationTime: leave['application_time']?.toString(),
// //           status: leave['status']?.toString(),
// //         );
// //
// //         // Build API URL using Config class format
// //         String apiEndpoint = "submitLeave"; // Change this to your actual leave endpoint
// //         String fullUrl = "${Config.postApiUrlLeaveForm}";
// //
// //         print('🌐 Syncing leave ${leave['leave_id']} to: $fullUrl');
// //         print('📡 Request Data: ${model.toJson()}');
// //
// //         final url = Uri.parse(fullUrl);
// //         final response = await http.post(
// //           url,
// //           headers: {
// //             "Content-Type": "application/json",
// //             "Accept": "application/json",
// //           },
// //           body: jsonEncode(model.toJson()),
// //         );
// //
// //         if (response.statusCode == 200 || response.statusCode == 201) {
// //           await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
// //           successfulSyncs++;
// //           print('✅ Successfully synced leave ${leave['leave_id']}');
// //         } else {
// //           failedSyncs++;
// //           print('❌ Failed to sync leave ${leave['leave_id']}: ${response.statusCode} - ${response.body}');
// //         }
// //       } catch (e) {
// //         failedSyncs++;
// //         print('🚨 Failed to sync leave ${leave['leave_id']}: $e');
// //       }
// //     }
// //
// //     print('✅ Sync completed: $successfulSyncs successful, $failedSyncs failed');
// //   }
// //
// //   // Additional method: Fetch leaves from server (for syncing)
// //   Future<void> fetchLeavesFromServer(String bookerId) async {
// //     try {
// //       final isOnline = await isNetworkAvailable();
// //       if (!isOnline) {
// //         print('📴 No internet connection - cannot fetch leaves from server');
// //         return;
// //       }
// //
// //       // Build API URL for fetching leaves
// //       String apiEndpoint = "getLeaves"; // Change this to your actual endpoint
// //       String fullUrl = "${Config.postApiUrlLeaveForm}?bookerId=$bookerId";
// //
// //       print('🌐 Fetching leaves from API: $fullUrl');
// //
// //       final url = Uri.parse(fullUrl);
// //       final response = await http.get(
// //         url,
// //         headers: {
// //           "Accept": "application/json",
// //         },
// //       );
// //
// //       if (response.statusCode == 200) {
// //         try {
// //           final responseData = jsonDecode(response.body);
// //           print('✅ Successfully fetched ${responseData.length} leaves from server');
// //           // Process the server response here
// //           // You might want to update local database with server data
// //         } catch (e) {
// //           print('⚠️ Error parsing fetch response: $e');
// //         }
// //       } else {
// //         print('❌ Failed to fetch leaves: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       print('🚨 Error fetching leaves from server: $e');
// //     }
// //   }
// // }
//
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:order_booking_app/Databases/dp_helper.dart';
// import '../Models/leave_model.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
//
// class LeaveRepository {
//   final DBHelper dbHelper = DBHelper();
//
//   Future<bool> submitLeave(LeaveModel model) async {
//     try {
//       print('🔄 Starting leave submission...');
//       // submitLeave فنکشن کے شروع میں API URL چیک کریں
//       print('🔗 API URL being used: ${Config.postApiUrlLeaveForm}');
//
//       // First save to local database
//       final dbResult = await dbHelper.insertLeave(model);
//       if (dbResult > 0) {
//         print('✅ Leave saved to local database successfully! ID: $dbResult');
//         print('📝 Leave Details:');
//         print('   Booker: ${model.bookerName}');
//         print('   Type: ${model.leaveType}');
//         print('   Dates: ${model.startDate} to ${model.endDate}');
//         print('   Days: ${model.totalDays}');
//       } else {
//         print('❌ Failed to save leave to local database');
//         return false;
//       }
//
//       // تازہ ترین leave حاصل کریں
//       final latestLeaves = await dbHelper.getLeavesByBookerId(model.bookerId);
//       String? generatedLeaveId;
//
//       if (latestLeaves.isNotEmpty) {
//         generatedLeaveId = latestLeaves.first['leave_id']?.toString();
//         print('📋 Found latest leave ID: $generatedLeaveId');
//       }
//
//       // Then try to submit to server if network is available
//       final isOnline = await isNetworkAvailable();
//       if (isOnline) {
//         try {
//           // Update model with generated leave ID
//           final leaveModel = LeaveModel(
//             id: generatedLeaveId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//             leaveId: generatedLeaveId,
//             bookerId: model.bookerId,
//             bookerName: model.bookerName,
//             leaveType: model.leaveType,
//             startDate: model.startDate,
//             endDate: model.endDate,
//             totalDays: model.totalDays,
//             isHalfDay: model.isHalfDay,
//             reason: model.reason,
//             attachmentUrl: model.attachmentUrl,
//             status: model.status,
//           );
//
//           String fullUrl = "${Config.postApiUrlLeaveForm}";
//
//           print('🌐 Submitting to API: $fullUrl');
//           print('📡 Request Data: ${leaveModel.toJson()}');
//
//           final url = Uri.parse(fullUrl);
//           final response = await http.post(
//             url,
//             headers: {
//               "Content-Type": "application/json",
//               "Accept": "application/json",
//             },
//             body: jsonEncode(leaveModel.toJson()),
//           );
//
//           print('📡 API Response Status: ${response.statusCode}');
//           print('📡 API Response Body: ${response.body}');
//
//           if (response.statusCode == 200 || response.statusCode == 201) {
//             // Handle empty response body scenario
//             if (response.body.trim().isEmpty) {
//               print('✅ Server accepted the request');
//
//               // If we have a generated leave ID, mark as posted
//               if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted locally. Leave ID: $generatedLeaveId');
//               }
//
//               return true;
//             }
//
//             try {
//               final responseData = jsonDecode(response.body);
//               String serverLeaveId = responseData['leave_id']?.toString() ??
//                   responseData['id']?.toString() ??
//                   generatedLeaveId ??
//                   '';
//
//               // Mark as posted in local database
//               if (serverLeaveId.isNotEmpty) {
//                 await dbHelper.markLeaveAsPosted(serverLeaveId);
//                 print('✅ Leave submitted to server successfully! Leave ID: $serverLeaveId');
//               } else if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted (using local ID). Leave ID: $generatedLeaveId');
//               }
//
//               return true;
//             } catch (e) {
//               print('⚠ Error parsing response: $e');
//
//               if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted locally after parse error. Leave ID: $generatedLeaveId');
//               }
//
//               return true;
//             }
//           } else {
//             print('❌ API Error: ${response.statusCode} - ${response.body}');
//             // Leave is saved locally, will sync later
//             return true;
//           }
//         } catch (e) {
//           print('🚨 API submission failed: $e');
//           print('📋 Stack trace: ${e.toString()}');
//           // Leave is saved locally, will sync later
//           return true;
//         }
//       } else {
//         print('📴 No internet connection - leave saved locally only');
//         // If offline, leave is still saved locally
//         return true;
//       }
//     } catch (e) {
//       print('❌ Error in submitLeave: $e');
//       print('📋 Stack trace: ${e.toString()}');
//       return false;
//     }
//   }
//   Future<String?> getGeneratedLeaveId(int rowId, String bookerId) async {
//     try {
//       final db = await dbHelper.db;
//
//       // First, let's check what tables exist (for debugging)
//       final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
//       print('📋 Available tables: ${tables.map((t) => t['name']).toList()}');
//
//       // Query using the correct table name from DBHelper
//       final result = await db.query(
//         'leaveTable',  // Change this to your actual table name
//         where: 'booker_id = ?',
//         whereArgs: [bookerId],
//         orderBy: 'id DESC',
//         limit: 1,
//       );
//
//       if (result.isNotEmpty) {
//         print('📝 Found leave record: ${result.first}');
//         return result.first['leave_id']?.toString();
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error getting generated leave ID: $e');
//       return null;
//     }
//   }
//
// // Helper method to get the generated leave ID from database
// //   Future<String?> getGeneratedLeaveId(int rowId, String bookerId) async {
// //     try {
// //       final db = await dbHelper.db;
// //       // Query the most recent leave for this user (should be the one we just inserted)
// //       final result = await db.query(
// //         'leave_table',
// //         where: 'booker_id = ?',
// //         whereArgs: [bookerId],
// //         orderBy: 'id DESC',
// //         limit: 1,
// //       );
// //
// //       if (result.isNotEmpty) {
// //         return result.first['leave_id']?.toString();
// //       }
// //       return null;
// //     } catch (e) {
// //       print('❌ Error getting generated leave ID: $e');
// //       return null;
// //     }
// //   }
//
//   // Future<bool> submitLeave(LeaveModel model) async {
//   //   try {
//   //     print('🔄 Starting leave submission...');
//   //
//   //     // First save to local database
//   //     final dbResult = await dbHelper.insertLeave(model);
//   //     if (dbResult > 0) {
//   //       print('✅ Leave saved to local database successfully! ID: $dbResult');
//   //       print('📝 Leave Details:');
//   //       print('   Booker: ${model.bookerName}');
//   //       print('   Type: ${model.leaveType}');
//   //       print('   Dates: ${model.startDate} to ${model.endDate}');
//   //       print('   Days: ${model.totalDays}');
//   //     } else {
//   //       print('❌ Failed to save leave to local database');
//   //       return false;
//   //     }
//   //
//   //     // Then try to submit to server if network is available
//   //     final isOnline = await isNetworkAvailable();
//   //     if (isOnline) {
//   //       try {
//   //         // Build API URL using Config class format
//   //         // Adjust the endpoint name as needed (e.g., "submitLeave", "applyLeave", etc.)
//   //         String apiEndpoint = "postApiUrlLeaveForm"; // Change this to your actual leave endpoint
//   //         String fullUrl = "${Config.postApiUrlLeaveForm}";
//   //
//   //         print('🌐 Submitting to API: $fullUrl');
//   //         print('📡 Request Data: ${model.toJson()}');
//   //
//   //         final url = Uri.parse(fullUrl);
//   //         final response = await http.post(
//   //           url,
//   //           headers: {
//   //             "Content-Type": "application/json",
//   //             "Accept": "application/json",
//   //           },
//   //           body: jsonEncode(model.toJson()),
//   //         );
//   //
//   //         print('📡 API Response Status: ${response.statusCode}');
//   //         print('📡 API Response Body: ${response.body}');
//   //
//   //         if (response.statusCode == 200 || response.statusCode == 201) {
//   //           try {
//   //             final responseData = jsonDecode(response.body);
//   //
//   //             // Mark as posted in local database
//   //             // Try to get leave ID from response or use generated one
//   //             String leaveId = responseData['leave_id']?.toString() ??
//   //                 model.id ??
//   //                 'LV${DateTime.now().millisecondsSinceEpoch}${model.bookerId.substring(0, 3)}';
//   //
//   //             await dbHelper.markLeaveAsPosted(leaveId);
//   //             print('✅ Leave submitted to server successfully! Leave ID: $leaveId');
//   //
//   //             // Update model with server response if needed
//   //             if (responseData['id'] != null) {
//   //               model = model.copyWith(id: responseData['id'].toString());
//   //             }
//   //
//   //             return true;
//   //           } catch (e) {
//   //             print('⚠ Error parsing response, but status is 200: $e');
//   //             // Still return true since server accepted the request
//   //             return true;
//   //           }
//   //         } else {
//   //           print('❌ API Error: ${response.statusCode} - ${response.body}');
//   //           // Leave is saved locally, will sync later
//   //           return true;
//   //         }
//   //       } catch (e) {
//   //         print('🚨 API submission failed: $e');
//   //         print('📋 Stack trace: ${e.toString()}');
//   //         // Leave is saved locally, will sync later
//   //         return true;
//   //       }
//   //     } else {
//   //       print('📴 No internet connection - leave saved locally only');
//   //       // If offline, leave is still saved locally
//   //       return true;
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error in submitLeave: $e');
//   //     print('📋 Stack trace: ${e.toString()}');
//   //     return false;
//   //   }
//   // }
//
//   Future<List<Map<String, dynamic>>> getMyLeaves(String bookerId) async {
//     return await dbHelper.getLeavesByBookerId(bookerId);
//   }
//
//   Future<List<Map<String, dynamic>>> getPendingLeaves() async {
//     return await dbHelper.getPendingLeaves();
//   }
//
//   Future<void> syncPendingLeaves() async {
//     final isOnline = await isNetworkAvailable();
//     if (!isOnline) {
//       print('📴 No internet connection - cannot sync pending leaves');
//       return;
//     }
//
//     final pendingLeaves = await dbHelper.getPendingLeaves();
//
//     if (pendingLeaves.isEmpty) {
//       print('📭 No pending leaves to sync');
//       return;
//     }
//
//     print('🔄 Syncing ${pendingLeaves.length} pending leaves...');
//     int successfulSyncs = 0;
//     int failedSyncs = 0;
//
//     for (var leave in pendingLeaves) {
//       try {
//         final model = LeaveModel(
//           id: leave['leave_id']?.toString() ?? leave['id']?.toString(),
//           leaveId: leave['leave_id']?.toString(),
//           bookerId: leave['booker_id'].toString(),
//           bookerName: leave['booker_name']?.toString(),
//           leaveType: leave['leave_type'].toString(),
//           startDate: leave['start_date'].toString(),
//           endDate: leave['end_date'].toString(),
//           totalDays: leave['total_days'] as int,
//           isHalfDay: leave['is_half_day'] == 1,
//           reason: leave['reason'].toString(),
//           attachmentUrl: leave['attachment_url']?.toString(),
//           applicationDate: leave['application_date']?.toString(),
//           applicationTime: leave['application_time']?.toString(),
//           status: leave['status']?.toString(),
//         );
//
//         String fullUrl = "${Config.postApiUrlLeaveForm}";
//
//         print('🌐 Syncing leave ${leave['leave_id']} to: $fullUrl');
//         print('📡 Request Data: ${model.toJson()}');
//
//         final url = Uri.parse(fullUrl);
//         final response = await http.post(
//           url,
//           headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json",
//           },
//           body: jsonEncode(model.toJson()),
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           // Handle empty response scenario
//           if (response.body.trim().isNotEmpty) {
//             try {
//               final responseData = jsonDecode(response.body);
//               String? serverLeaveId = responseData['leave_id']?.toString() ??
//                   responseData['id']?.toString() ??
//                   leave['leave_id']?.toString();
//
//               if (serverLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(serverLeaveId);
//               } else {
//                 await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//               }
//             } catch (e) {
//               // If parse error but status is 200, still mark as posted
//               await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//             }
//           } else {
//             // Empty response but status 200, mark as posted
//             await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//           }
//
//           successfulSyncs++;
//           print('✅ Successfully synced leave ${leave['leave_id']}');
//         } else {
//           failedSyncs++;
//           print('❌ Failed to sync leave ${leave['leave_id']}: ${response.statusCode} - ${response.body}');
//         }
//       } catch (e) {
//         failedSyncs++;
//         print('🚨 Failed to sync leave ${leave['leave_id']}: $e');
//       }
//     }
//
//     print('✅ Sync completed: $successfulSyncs successful, $failedSyncs failed');
//   }
//
//   // Future<void> syncPendingLeaves() async {
//   //   final isOnline = await isNetworkAvailable();
//   //   if (!isOnline) {
//   //     print('📴 No internet connection - cannot sync pending leaves');
//   //     return;
//   //   }
//   //
//   //   final pendingLeaves = await dbHelper.getPendingLeaves();
//   //
//   //   if (pendingLeaves.isEmpty) {
//   //     print('📭 No pending leaves to sync');
//   //     return;
//   //   }
//   //
//   //   print('🔄 Syncing ${pendingLeaves.length} pending leaves...');
//   //   int successfulSyncs = 0;
//   //   int failedSyncs = 0;
//   //
//   //   for (var leave in pendingLeaves) {
//   //     try {
//   //       final model = LeaveModel(
//   //         id: leave['leave_id']?.toString(),
//   //         bookerId: leave['booker_id'].toString(),
//   //         bookerName: leave['booker_name']?.toString(),
//   //         leaveType: leave['leave_type'].toString(),
//   //         startDate: leave['start_date'].toString(),
//   //         endDate: leave['end_date'].toString(),
//   //         totalDays: leave['total_days'] as int,
//   //         isHalfDay: leave['is_half_day'] == 1,
//   //         reason: leave['reason'].toString(),
//   //         attachmentUrl: leave['attachment_url']?.toString(),
//   //         applicationDate: leave['application_date']?.toString(),
//   //         applicationTime: leave['application_time']?.toString(),
//   //         status: leave['status']?.toString(),
//   //       );
//   //
//   //       // Build API URL using Config class format
//   //       String apiEndpoint = "submitLeave"; // Change this to your actual leave endpoint
//   //       String fullUrl = "${Config.postApiUrlLeaveForm}";
//   //
//   //       print('🌐 Syncing leave ${leave['leave_id']} to: $fullUrl');
//   //       print('📡 Request Data: ${model.toJson()}');
//   //
//   //       final url = Uri.parse(fullUrl);
//   //       final response = await http.post(
//   //         url,
//   //         headers: {
//   //           "Content-Type": "application/json",
//   //           "Accept": "application/json",
//   //         },
//   //         body: jsonEncode(model.toJson()),
//   //       );
//   //
//   //       if (response.statusCode == 200 || response.statusCode == 201) {
//   //         await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//   //         successfulSyncs++;
//   //         print('✅ Successfully synced leave ${leave['leave_id']}');
//   //       } else {
//   //         failedSyncs++;
//   //         print('❌ Failed to sync leave ${leave['leave_id']}: ${response.statusCode} - ${response.body}');
//   //       }
//   //     } catch (e) {
//   //       failedSyncs++;
//   //       print('🚨 Failed to sync leave ${leave['leave_id']}: $e');
//   //     }
//   //   }
//   //
//   //   print('✅ Sync completed: $successfulSyncs successful, $failedSyncs failed');
//   // }
//
//   // Additional method: Fetch leaves from server (for syncing)
//   Future<void> fetchLeavesFromServer(String bookerId) async {
//     try {
//       final isOnline = await isNetworkAvailable();
//       if (!isOnline) {
//         print('📴 No internet connection - cannot fetch leaves from server');
//         return;
//       }
//
//       // Build API URL for fetching leaves
//       String apiEndpoint = "getLeaves"; // Change this to your actual endpoint
//       String fullUrl = "${Config.postApiUrlLeaveForm}?bookerId=$bookerId";
//
//       print('🌐 Fetching leaves from API: $fullUrl');
//
//       final url = Uri.parse(fullUrl);
//       final response = await http.get(
//         url,
//         headers: {
//           "Accept": "application/json",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         try {
//           final responseData = jsonDecode(response.body);
//           print('✅ Successfully fetched ${responseData.length} leaves from server');
//           // Process the server response here
//           // You might want to update local database with server data
//         } catch (e) {
//           print('⚠ Error parsing fetch response: $e');
//         }
//       } else {
//         print('❌ Failed to fetch leaves: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('🚨 Error fetching leaves from server: $e');
//     }
//   }
// }

///attachment 06-12-2025
// import 'dart:convert';
// import 'dart:typed_data'; // Add this import
// import 'package:http/http.dart' as http;
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Databases/dp_helper.dart';
// import '../Models/leave_model.dart';
// import '../Services/FirebaseServices/firebase_remote_config.dart';
//
// class LeaveRepository {
//   final DBHelper dbHelper = DBHelper();
//
//   Future<bool> submitLeave(LeaveModel model) async {
//     try {
//       print('🔄 Starting leave submission...');
//       print('🔗 API URL being used: ${Config.postApiUrlLeaveForm}');
//
//       // First save to local database
//       final dbResult = await dbHelper.insertLeave(model);
//       if (dbResult > 0) {
//         print('✅ Leave saved to local database successfully! ID: $dbResult');
//         print('📝 Leave Details:');
//         print('   Booker: ${model.bookerName}');
//         print('   Type: ${model.leaveType}');
//         print('   Dates: ${model.startDate} to ${model.endDate}');
//         print('   Days: ${model.totalDays}');
//         print('   Attachment size: ${model.attachmentData?.length ?? 0} bytes');
//       } else {
//         print('❌ Failed to save leave to local database');
//         return false;
//       }
//
//       // Get latest leave ID
//       final latestLeaves = await dbHelper.getLeavesByBookerId(model.bookerId);
//       String? generatedLeaveId;
//
//       if (latestLeaves.isNotEmpty) {
//         generatedLeaveId = latestLeaves.first['leave_id']?.toString();
//         print('📋 Found latest leave ID: $generatedLeaveId');
//       }
//
//       // Try to submit to server if network is available
//       final isOnline = await isNetworkAvailable();
//       if (isOnline) {
//         try {
//           // Create model for API submission
//           final leaveModel = LeaveModel(
//             id: generatedLeaveId ?? DateTime.now().millisecondsSinceEpoch.toString(),
//             leaveId: generatedLeaveId,
//             bookerId: model.bookerId,
//             bookerName: model.bookerName,
//             leaveType: model.leaveType,
//             startDate: model.startDate,
//             endDate: model.endDate,
//             totalDays: model.totalDays,
//             isHalfDay: model.isHalfDay,
//             reason: model.reason,
//             attachmentData: model.attachmentData,
//             status: model.status,
//           );
//
//           String fullUrl = "${Config.postApiUrlLeaveForm}";
//
//           print('🌐 Submitting to API: $fullUrl');
//
//           // Convert model to JSON for API
//           final jsonData = leaveModel.toJson();
//
//           // For API submission, we need to handle BLOB data differently
//           // Convert BLOB to base64 string for JSON transmission
//           if (jsonData['attachment_data'] != null) {
//             final bytes = jsonData['attachment_data'] as List<int>;
//             jsonData['attachment_data'] = base64Encode(bytes);
//             print('📁 Attachment converted to base64: ${bytes.length} bytes');
//           }
//
//           final url = Uri.parse(fullUrl);
//           final response = await http.post(
//             url,
//             headers: {
//               "Content-Type": "application/json",
//               "Accept": "application/json",
//             },
//             body: jsonEncode(jsonData),
//           );
//
//           print('📡 API Response Status: ${response.statusCode}');
//           print('📡 API Response Body: ${response.body}');
//
//           if (response.statusCode == 200 || response.statusCode == 201) {
//             if (response.body.trim().isEmpty) {
//               print('✅ Server accepted the request');
//
//               // Mark as posted locally
//               if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted locally. Leave ID: $generatedLeaveId');
//               }
//
//               return true;
//             }
//
//             try {
//               final responseData = jsonDecode(response.body);
//               String serverLeaveId = responseData['leave_id']?.toString() ??
//                   responseData['id']?.toString() ??
//                   generatedLeaveId ??
//                   '';
//
//               // Mark as posted
//               if (serverLeaveId.isNotEmpty) {
//                 await dbHelper.markLeaveAsPosted(serverLeaveId);
//                 print('✅ Leave submitted to server! Leave ID: $serverLeaveId');
//               } else if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted locally. Leave ID: $generatedLeaveId');
//               }
//
//               return true;
//             } catch (e) {
//               print('⚠ Error parsing response: $e');
//
//               if (generatedLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(generatedLeaveId);
//                 print('✅ Leave marked as posted locally after parse error.');
//               }
//
//               return true;
//             }
//           } else {
//             print('❌ API Error: ${response.statusCode} - ${response.body}');
//             // Leave saved locally, will sync later
//             return true;
//           }
//         } catch (e) {
//           print('🚨 API submission failed: $e');
//           print('📋 Stack trace: ${e.toString()}');
//           // Leave saved locally, will sync later
//           return true;
//         }
//       } else {
//         print('📴 No internet connection - leave saved locally only');
//         return true;
//       }
//     } catch (e) {
//       print('❌ Error in submitLeave: $e');
//       print('📋 Stack trace: ${e.toString()}');
//       return false;
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getMyLeaves(String bookerId) async {
//     return await dbHelper.getLeavesByBookerId(bookerId);
//   }
//
//   Future<List<Map<String, dynamic>>> getPendingLeaves() async {
//     return await dbHelper.getPendingLeaves();
//   }
//
//   Future<void> syncPendingLeaves() async {
//     final isOnline = await isNetworkAvailable();
//     if (!isOnline) {
//       print('📴 No internet connection - cannot sync pending leaves');
//       return;
//     }
//
//     final pendingLeaves = await dbHelper.getPendingLeaves();
//
//     if (pendingLeaves.isEmpty) {
//       print('📭 No pending leaves to sync');
//       return;
//     }
//
//     print('🔄 Syncing ${pendingLeaves.length} pending leaves...');
//     int successfulSyncs = 0;
//     int failedSyncs = 0;
//
//     for (var leave in pendingLeaves) {
//       try {
//         // Extract BLOB data from database - FIXED: Uint8List doesn't have toList()
//         List<int>? attachmentBytes;
//         if (leave['attachment_data'] != null) {
//           if (leave['attachment_data'] is List<int>) {
//             attachmentBytes = leave['attachment_data'] as List<int>;
//           } else if (leave['attachment_data'] is Uint8List) {
//             // Convert Uint8List to List<int> properly
//             Uint8List uint8list = leave['attachment_data'] as Uint8List;
//             attachmentBytes = uint8list.toList();
//           }
//         }
//
//         final model = LeaveModel(
//           id: leave['leave_id']?.toString() ?? leave['id']?.toString(),
//           leaveId: leave['leave_id']?.toString(),
//           bookerId: leave['booker_id'].toString(),
//           bookerName: leave['booker_name']?.toString(),
//           leaveType: leave['leave_type'].toString(),
//           startDate: leave['start_date'].toString(),
//           endDate: leave['end_date'].toString(),
//           totalDays: leave['total_days'] as int,
//           isHalfDay: leave['is_half_day'] == 1,
//           reason: leave['reason'].toString(),
//           attachmentData: attachmentBytes,
//           applicationDate: leave['application_date']?.toString(),
//           applicationTime: leave['application_time']?.toString(),
//           status: leave['status']?.toString(),
//         );
//
//         String fullUrl = "${Config.postApiUrlLeaveForm}";
//
//         print('🌐 Syncing leave ${leave['leave_id']} to: $fullUrl');
//
//         // Prepare JSON data
//         final jsonData = model.toJson();
//
//         // Convert BLOB to base64 for API
//         if (jsonData['attachment_data'] != null) {
//           final bytes = jsonData['attachment_data'] as List<int>;
//           jsonData['attachment_data'] = base64Encode(bytes);
//         }
//
//         final url = Uri.parse(fullUrl);
//         final response = await http.post(
//           url,
//           headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json",
//           },
//           body: jsonEncode(jsonData),
//         );
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           if (response.body.trim().isNotEmpty) {
//             try {
//               final responseData = jsonDecode(response.body);
//               String? serverLeaveId = responseData['leave_id']?.toString() ??
//                   responseData['id']?.toString() ??
//                   leave['leave_id']?.toString();
//
//               if (serverLeaveId != null) {
//                 await dbHelper.markLeaveAsPosted(serverLeaveId);
//               } else {
//                 await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//               }
//             } catch (e) {
//               await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//             }
//           } else {
//             await dbHelper.markLeaveAsPosted(leave['leave_id'].toString());
//           }
//
//           successfulSyncs++;
//           print('✅ Successfully synced leave ${leave['leave_id']}');
//         } else {
//           failedSyncs++;
//           print('❌ Failed to sync leave ${leave['leave_id']}: ${response.statusCode}');
//         }
//       } catch (e) {
//         failedSyncs++;
//         print('🚨 Failed to sync leave ${leave['leave_id']}: $e');
//       }
//     }
//
//     print('✅ Sync completed: $successfulSyncs successful, $failedSyncs failed');
//   }
//
//   Future<void> fetchLeavesFromServer(String bookerId) async {
//     try {
//       final isOnline = await isNetworkAvailable();
//       if (!isOnline) {
//         print('📴 No internet connection - cannot fetch leaves from server');
//         return;
//       }
//
//       String fullUrl = "${Config.postApiUrlLeaveForm}?bookerId=$bookerId";
//
//       print('🌐 Fetching leaves from API: $fullUrl');
//
//       final url = Uri.parse(fullUrl);
//       final response = await http.get(
//         url,
//         headers: {
//           "Accept": "application/json",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         try {
//           final responseData = jsonDecode(response.body);
//           print('✅ Successfully fetched ${responseData.length} leaves from server');
//         } catch (e) {
//           print('⚠ Error parsing fetch response: $e');
//         }
//       } else {
//         print('❌ Failed to fetch leaves: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('🚨 Error fetching leaves from server: $e');
//     }
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Databases/dp_helper.dart';
import '../Models/leave_model.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'package:http_parser/http_parser.dart';

class LeaveRepository {
  final DBHelper dbHelper = DBHelper();

  Future<bool> submitLeave(LeaveModel model) async {
    try {
      print('🔄 Starting leave submission...');
      print('🔗 API URL: ${Config.postApiUrlLeaveForm}');

      // First save to local database
      final dbResult = await dbHelper.insertLeave(model);
      if (dbResult > 0) {
        print('✅ Leave saved locally with ID: $dbResult');
      } else {
        print('❌ Failed to save locally');
        return false;
      }

      // Get the latest leave ID for this booker
      final latestLeaves = await dbHelper.getLeavesByBookerId(model.bookerId);
      String? generatedLeaveId;

      if (latestLeaves.isNotEmpty) {
        generatedLeaveId = latestLeaves.first['leave_id']?.toString();
        print('📋 Using leave ID: $generatedLeaveId');
      }

      final isOnline = await isNetworkAvailable();
      if (!isOnline) {
        print('📴 No internet - saved locally only');
        return true;
      }

      // Try ALL methods in sequence
      print('🔄 Trying submission methods...');

      // Method 1: Main method (Most reliable)
      print('\n=== METHOD 1: MAIN MULTIPART ===');
      final method1Success = await _submitLeaveMethod1(model, generatedLeaveId);
      if (method1Success) {
        print('✅ Submission successful via Method 1');
        return true;
      }

      // Method 2: Backup method
      print('\n=== METHOD 2: BACKUP JSON ===');
      final method2Success = await _submitLeaveMethod2(model, generatedLeaveId);
      if (method2Success) {
        print('✅ Submission successful via Method 2');
        return true;
      }

      print('❌ All methods failed');
      return false;

    } catch (e) {
      print('❌ Error in submitLeave: $e');
      return false;
    }
  }

  // ==================== MAIN METHOD: MULTIPART FORM ====================
  Future<bool> _submitLeaveMethod1(LeaveModel model, String? generatedLeaveId) async {
    try {
      String fullUrl = "${Config.postApiUrlLeaveForm}";
      print('🌐 Method 1: Multipart to: $fullUrl');

      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

      // ========== CRITICAL PART: ADD ALL TEXT FIELDS ==========
      // Use both UPPER_CASE and lower_case variations to ensure compatibility

      // UPPER_CASE (Oracle standard)
      request.fields['ID'] = model.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['LEAVE_ID'] = generatedLeaveId ?? '';
      request.fields['BOOKER_ID'] = model.bookerId;
      request.fields['BOOKER_NAME'] = model.bookerName ?? '';
      request.fields['LEAVE_TYPE'] = model.leaveType;
      request.fields['START_DATE'] = _formatDateForServer(model.startDate);
      request.fields['END_DATE'] = _formatDateForServer(model.endDate);
      request.fields['TOTAL_DAYS'] = model.totalDays.toString();
      request.fields['IS_HALF_DAY'] = model.isHalfDay ? '1' : '0';
      request.fields['REASON'] = model.reason;
      request.fields['APPLICATION_DATE'] = model.applicationDate ?? _getFormattedDate();
      request.fields['APPLICATION_TIME'] = model.applicationTime ?? _getFormattedTime();
      request.fields['STATUS'] = model.status ?? 'pending';
      request.fields['POSTED'] = (model.posted ?? 0).toString();
      request.fields['ATTACHMENT_IMAGE'] = model.attachmentImage ?? '';

      // Lower_case (for some servers)
      request.fields['id'] = model.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['leave_id'] = generatedLeaveId ?? '';
      request.fields['booker_id'] = model.bookerId;
      request.fields['booker_name'] = model.bookerName ?? '';
      request.fields['leave_type'] = model.leaveType;
      request.fields['start_date'] = _formatDateForServer(model.startDate);
      request.fields['end_date'] = _formatDateForServer(model.endDate);
      request.fields['total_days'] = model.totalDays.toString();
      request.fields['is_half_day'] = model.isHalfDay ? '1' : '0';
      request.fields['reason'] = model.reason;
      request.fields['application_date'] = model.applicationDate ?? _getFormattedDate();
      request.fields['application_time'] = model.applicationTime ?? _getFormattedTime();
      request.fields['status'] = model.status ?? 'pending';
      request.fields['posted'] = (model.posted ?? 0).toString();
      request.fields['attachment_image'] = model.attachmentImage ?? '';

      // CamelCase (alternative)
      request.fields['BookerId'] = model.bookerId;
      request.fields['BookerName'] = model.bookerName ?? '';
      request.fields['LeaveType'] = model.leaveType;
      request.fields['StartDate'] = _formatDateForServer(model.startDate);
      request.fields['EndDate'] = _formatDateForServer(model.endDate);
      request.fields['Reason'] = model.reason;

      // ========== ADD FILE ATTACHMENT ==========
      if (model.attachmentData != null && model.attachmentData!.isNotEmpty) {
        String filename = 'leave_${model.bookerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Try multiple field names for file
        request.files.add(
            http.MultipartFile.fromBytes(
              'ATTACHMENT_DATA', // Primary field name
              model.attachmentData!,
              filename: filename,
              contentType: MediaType('image', 'jpeg'),
            )
        );

        // Alternative field names
        request.files.add(
            http.MultipartFile.fromBytes(
              'attachment_data', // lowercase
              model.attachmentData!,
              filename: filename,
              contentType: MediaType('image', 'jpeg'),
            )
        );

        request.files.add(
            http.MultipartFile.fromBytes(
              'file', // generic
              model.attachmentData!,
              filename: filename,
              contentType: MediaType('image', 'jpeg'),
            )
        );

        print('📎 Added file: $filename (${model.attachmentData!.length} bytes)');
      } else {
        print('📎 No attachment to upload');
      }

      // ========== DEBUG LOGGING ==========
      print('📡 TEXT FIELDS being sent:');
      request.fields.forEach((key, value) {
        if (value.isNotEmpty && value != 'null') {
          print('   "$key" = "$value"');
        }
      });
      print('📡 Total text fields: ${request.fields.length}');
      print('📡 Files count: ${request.files.length}');

      // ========== SEND REQUEST ==========
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Method 1 successful!');

        // Parse response to check for success
        try {
          final jsonResponse = jsonDecode(response.body);
          print('📡 Parsed JSON Response: $jsonResponse');

          // Check server response message
          if (jsonResponse is Map) {
            if (jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
              print('🎉 Server confirmed success');
            } else if (jsonResponse.containsKey('message')) {
              print('📝 Server message: ${jsonResponse['message']}');
            }
          }
        } catch (e) {
          print('📡 Response is not JSON, but success status received');
        }

        // Mark as posted in local DB
        if (generatedLeaveId != null) {
          await dbHelper.markLeaveAsPosted(generatedLeaveId);
          print('📝 Marked leave as posted in local DB');
        }

        return true;
      } else {
        print('❌ Server returned error: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Method 1 error: $e');
      print('❌ Stack trace: ${e.toString()}');
      return false;
    }
  }

  // ==================== BACKUP METHOD: JSON ====================
  Future<bool> _submitLeaveMethod2(LeaveModel model, String? generatedLeaveId) async {
    try {
      String fullUrl = "${Config.postApiUrlLeaveForm}";
      print('🌐 Method 2: JSON to: $fullUrl');

      Map<String, dynamic> jsonData = {
        // UPPER_CASE
        "ID": model.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        "LEAVE_ID": generatedLeaveId ?? "",
        "BOOKER_ID": model.bookerId,
        "BOOKER_NAME": model.bookerName ?? "",
        "LEAVE_TYPE": model.leaveType,
        "START_DATE": _formatDateForServer(model.startDate),
        "END_DATE": _formatDateForServer(model.endDate),
        "TOTAL_DAYS": model.totalDays,
        "IS_HALF_DAY": model.isHalfDay ? 1 : 0,
        "REASON": model.reason,
        "APPLICATION_DATE": model.applicationDate ?? _getFormattedDate(),
        "APPLICATION_TIME": model.applicationTime ?? _getFormattedTime(),
        "STATUS": model.status ?? "pending",
        "POSTED": model.posted ?? 0,
        "ATTACHMENT_IMAGE": model.attachmentImage ?? "",

        // Lower_case
        "id": model.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        "leave_id": generatedLeaveId ?? "",
        "booker_id": model.bookerId,
        "booker_name": model.bookerName ?? "",
        "leave_type": model.leaveType,
        "start_date": _formatDateForServer(model.startDate),
        "end_date": _formatDateForServer(model.endDate),
        "total_days": model.totalDays,
        "is_half_day": model.isHalfDay ? 1 : 0,
        "reason": model.reason,
        "application_date": model.applicationDate ?? _getFormattedDate(),
        "application_time": model.applicationTime ?? _getFormattedTime(),
        "status": model.status ?? "pending",
        "posted": model.posted ?? 0,
        "attachment_image": model.attachmentImage ?? "",
      };

      // Add base64 image if exists
      if (model.attachmentData != null && model.attachmentData!.isNotEmpty) {
        jsonData["ATTACHMENT_DATA"] = base64Encode(model.attachmentData!);
        jsonData["attachment_data"] = base64Encode(model.attachmentData!);
        print('📎 Added base64 image (${model.attachmentData!.length} bytes)');
      }

      print('📡 JSON Data being sent:');
      jsonData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
          print('   "$key": "$value"');
        }
      });

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(jsonData),
      );

      print('📡 Response: ${response.statusCode}');
      print('📡 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Method 2 successful!');
        if (generatedLeaveId != null) {
          await dbHelper.markLeaveAsPosted(generatedLeaveId);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Method 2 error: $e');
      return false;
    }
  }

  // ==================== IMPROVED DATE FORMATTING ====================
  String _formatDateForServer(String dateString) {
    try {
      // Remove time part if exists
      String dateOnly = dateString.split(' ')[0].split('T')[0];

      // Parse to ensure proper format
      List<String> parts = dateOnly.split('-');
      if (parts.length == 3) {
        int year = int.tryParse(parts[0]) ?? DateTime.now().year;
        int month = int.tryParse(parts[1]) ?? DateTime.now().month;
        int day = int.tryParse(parts[2]) ?? DateTime.now().day;

        // Return in YYYY-MM-DD format
        return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      }

      return dateOnly;
    } catch (e) {
      print('⚠️ Date formatting error for "$dateString": $e');
      return dateString;
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  // ==================== SYNC PENDING LEAVES ====================
  Future<void> syncPendingLeaves() async {
    try {
      final isOnline = await isNetworkAvailable();
      if (!isOnline) {
        print('📴 No internet - cannot sync');
        return;
      }

      final pendingLeaves = await dbHelper.getPendingLeaves();
      if (pendingLeaves.isEmpty) {
        print('📭 No pending leaves to sync');
        return;
      }

      print('🔄 Syncing ${pendingLeaves.length} pending leaves...');

      int successCount = 0;
      for (var leave in pendingLeaves) {
        try {
          print('\n--- Syncing Leave ID: ${leave['leave_id']} ---');

          // Get attachment data if exists
          Uint8List? attachmentData;
          if (leave['has_attachment'] == 1) {
            attachmentData = await dbHelper.getLeaveAttachment(leave['leave_id'].toString());
            print('📎 Found attachment: ${attachmentData?.length ?? 0} bytes');
          }

          final model = LeaveModel(
            id: leave['id']?.toString(),
            leaveId: leave['leave_id']?.toString(),
            bookerId: leave['booker_id'].toString(),
            bookerName: leave['booker_name']?.toString(),
            leaveType: leave['leave_type'].toString(),
            startDate: leave['start_date'].toString(),
            endDate: leave['end_date'].toString(),
            totalDays: leave['total_days'] as int,
            isHalfDay: leave['is_half_day'] == 1,
            reason: leave['reason'].toString(),
            attachmentData: attachmentData,
            attachmentImage: leave['attachment_image']?.toString(),
            applicationDate: leave['application_date']?.toString(),
            applicationTime: leave['application_time']?.toString(),
            status: leave['status']?.toString(),
            posted: leave['posted'] as int?,
          );

          // Try main method first
          bool success = await _submitLeaveMethod1(model, leave['leave_id']?.toString());

          if (!success) {
            // Try backup method
            success = await _submitLeaveMethod2(model, leave['leave_id']?.toString());
          }

          if (success) {
            successCount++;
            print('✅ Successfully synced leave: ${leave['leave_id']}');
          } else {
            print('❌ Failed to sync leave: ${leave['leave_id']}');
          }
        } catch (e) {
          print('🚨 Error syncing ${leave['leave_id']}: $e');
        }
      }

      print('\n✅ Sync completed: $successCount/${pendingLeaves.length} leaves synced successfully');

    } catch (e) {
      print('❌ Sync error: $e');
    }
  }

  // ==================== OTHER METHODS ====================
  Future<List<Map<String, dynamic>>> getMyLeaves(String bookerId) async {
    return await dbHelper.getLeavesByBookerId(bookerId);
  }

  Future<List<Map<String, dynamic>>> getPendingLeaves() async {
    return await dbHelper.getPendingLeaves();
  }

  // ==================== TEST ENDPOINT ====================
  Future<Map<String, dynamic>> testServerConnection() async {
    try {
      print('🔍 Testing server connection...');

      // Test GET request
      final getResponse = await http.get(
        Uri.parse(Config.postApiUrlLeaveForm),
        headers: {'Accept': 'application/json'},
      );

      print('📡 GET Test Status: ${getResponse.statusCode}');
      print('📡 GET Test Headers: ${getResponse.headers}');
      print('📡 GET Test Body (first 500 chars): ${getResponse.body.length > 500 ? getResponse.body.substring(0, 500) + '...' : getResponse.body}');

      return {
        'status': getResponse.statusCode,
        'body': getResponse.body,
        'headers': getResponse.headers.toString(),
      };
    } catch (e) {
      print('❌ Test connection error: $e');
      return {'error': e.toString()};
    }
  }

  // ==================== VALIDATE DATA ====================
  Future<bool> validateLeaveData(LeaveModel model) async {
    try {
      // Check required fields
      if (model.bookerId.isEmpty) {
        print('❌ Validation failed: Booker ID is empty');
        return false;
      }

      if (model.leaveType.isEmpty) {
        print('❌ Validation failed: Leave Type is empty');
        return false;
      }

      if (model.startDate.isEmpty) {
        print('❌ Validation failed: Start Date is empty');
        return false;
      }

      if (model.endDate.isEmpty) {
        print('❌ Validation failed: End Date is empty');
        return false;
      }

      if (model.reason.isEmpty) {
        print('❌ Validation failed: Reason is empty');
        return false;
      }

      // Validate dates
      try {
        final start = DateTime.parse(_formatDateForServer(model.startDate));
        final end = DateTime.parse(_formatDateForServer(model.endDate));

        if (end.isBefore(start)) {
          print('❌ Validation failed: End date is before start date');
          return false;
        }
      } catch (e) {
        print('❌ Validation failed: Invalid date format');
        return false;
      }

      print('✅ Data validation passed');
      return true;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    }
  }
}