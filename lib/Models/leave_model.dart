// //
// //
// // // leave_model.dart - پوری فائل اپڈیٹ کریں
// // class LeaveModel {
// //   String? id;
// //   String? leaveId;
// //   String bookerId;
// //   String? bookerName;
// //   String leaveType;
// //   String startDate;
// //   String endDate;
// //   int totalDays;
// //   bool isHalfDay;
// //   String reason;
// //   String? attachmentUrl;
// //   String? applicationDate;
// //   String? applicationTime;
// //   String? status;
// //
// //   LeaveModel({
// //     this.id,
// //     this.leaveId,
// //     required this.bookerId,
// //     this.bookerName,
// //     required this.leaveType,
// //     required this.startDate,
// //     required this.endDate,
// //     required this.totalDays,
// //     required this.isHalfDay,
// //     required this.reason,
// //     this.attachmentUrl,
// //     this.applicationDate,
// //     this.applicationTime,
// //     this.status = 'pending',
// //   });
// //
// //   // ========== اہم تبدیلی: toJson() میں ==========
// //   Map<String, dynamic> toJson() {
// //     // صرف تاریخ نکالنے کے لیے ہیلپر فنکشن
// //     String extractDateOnly(String dateString) {
// //       try {
// //         // اگر dateString میں space ہے (مثال: "2025-12-04 00:00:00.000")
// //         if (dateString.contains(' ')) {
// //           return dateString.split(' ')[0]; // صرف "2025-12-04"
// //         }
// //         // اگر ISO format میں ہے (مثال: "2025-12-04T00:00:00.000")
// //         if (dateString.contains('T')) {
// //           return dateString.split('T')[0]; // صرف "2025-12-04"
// //         }
// //         // اگر صرف تاریخ ہی ہے
// //         return dateString;
// //       } catch (e) {
// //         return dateString;
// //       }
// //     }
// //
// //     // تاریخ حاصل کرنے کے لیے ہیلپر فنکشن
// //     String getFormattedDate() {
// //       final now = DateTime.now();
// //       return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
// //     }
// //
// //     // وقت حاصل کرنے کے لیے ہیلپر فنکشن
// //     String getFormattedTime() {
// //       final now = DateTime.now();
// //       return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
// //     }
// //
// //     return {
// //       "id": id,
// //       "leave_id": leaveId,
// //       "booker_id": bookerId,
// //       "booker_name": bookerName,
// //       "leave_type": leaveType,
// //       // ========== یہاں اہم تبدیلی ہے ==========
// //       "start_date": extractDateOnly(startDate), // صرف تاریخ
// //       "end_date": extractDateOnly(endDate),     // صرف تاریخ
// //       "total_days": totalDays,
// //       "is_half_day": isHalfDay ? 1 : 0,
// //       "reason": reason,
// //       "attachment_url": attachmentUrl ?? "",
// //       "application_date": applicationDate ?? getFormattedDate(), // صرف تاریخ
// //       "application_time": applicationTime ?? getFormattedTime(),
// //       "status": status ?? "pending",
// //     };
// //   }
// //
// //   factory LeaveModel.fromMap(Map<String, dynamic> map) {
// //     // DB سے ڈیٹا پڑھتے وقت بھی صرف تاریخ نکالیں
// //     String extractDateOnly(String? dateString) {
// //       if (dateString == null) return "";
// //       try {
// //         if (dateString.contains(' ')) {
// //           return dateString.split(' ')[0];
// //         }
// //         if (dateString.contains('T')) {
// //           return dateString.split('T')[0];
// //         }
// //         return dateString;
// //       } catch (e) {
// //         return dateString;
// //       }
// //     }
// //
// //     return LeaveModel(
// //       id: map['id']?.toString(),
// //       leaveId: map['leave_id']?.toString(),
// //       bookerId: map['booker_id'].toString(),
// //       bookerName: map['booker_name']?.toString(),
// //       leaveType: map['leave_type'].toString(),
// //       startDate: extractDateOnly(map['start_date']?.toString()),
// //       endDate: extractDateOnly(map['end_date']?.toString()),
// //       totalDays: map['total_days'] as int,
// //       isHalfDay: map['is_half_day'] == 1,
// //       reason: map['reason'].toString(),
// //       attachmentUrl: map['attachment_url']?.toString(),
// //       applicationDate: map['application_date']?.toString(),
// //       applicationTime: map['application_time']?.toString(),
// //       status: map['status']?.toString() ?? 'pending',
// //     );
// //   }
// //
// //   // Copy with method
// //   LeaveModel copyWith({
// //     String? id,
// //     String? leaveId,
// //     String? bookerId,
// //     String? bookerName,
// //     String? leaveType,
// //     String? startDate,
// //     String? endDate,
// //     int? totalDays,
// //     bool? isHalfDay,
// //     String? reason,
// //     String? attachmentUrl,
// //     String? applicationDate,
// //     String? applicationTime,
// //     String? status,
// //   }) {
// //     return LeaveModel(
// //       id: id ?? this.id,
// //       leaveId: leaveId ?? this.leaveId,
// //       bookerId: bookerId ?? this.bookerId,
// //       bookerName: bookerName ?? this.bookerName,
// //       leaveType: leaveType ?? this.leaveType,
// //       startDate: startDate ?? this.startDate,
// //       endDate: endDate ?? this.endDate,
// //       totalDays: totalDays ?? this.totalDays,
// //       isHalfDay: isHalfDay ?? this.isHalfDay,
// //       reason: reason ?? this.reason,
// //       attachmentUrl: attachmentUrl ?? this.attachmentUrl,
// //       applicationDate: applicationDate ?? this.applicationDate,
// //       applicationTime: applicationTime ?? this.applicationTime,
// //       status: status ?? this.status,
// //     );
// //   }
// // }
//
//
//
// ///attachment 06-12-2025
// import 'dart:typed_data'; // Add this import
//
// // leave_model.dart - پوری فائل اپڈیٹ کریں
// class LeaveModel {
//   String? id;
//   String? leaveId;
//   String bookerId;
//   String? bookerName;
//   String leaveType;
//   String startDate;
//   String endDate;
//   int totalDays;
//   bool isHalfDay;
//   String reason;
//   // String? attachmentUrl; // For file path reference
//   List<int>? attachmentData; // For BLOB storage
//   String? applicationDate;
//   String? applicationTime;
//   String? status;
//
//   LeaveModel({
//     this.id,
//     this.leaveId,
//     required this.bookerId,
//     this.bookerName,
//     required this.leaveType,
//     required this.startDate,
//     required this.endDate,
//     required this.totalDays,
//     required this.isHalfDay,
//     required this.reason,
//     // this.attachmentUrl,
//     this.attachmentData,
//     this.applicationDate,
//     this.applicationTime,
//     this.status = 'pending',
//   });
//
//   Map<String, dynamic> toJson() {
//     String extractDateOnly(String dateString) {
//       try {
//         if (dateString.contains(' ')) {
//           return dateString.split(' ')[0];
//         }
//         if (dateString.contains('T')) {
//           return dateString.split('T')[0];
//         }
//         return dateString;
//       } catch (e) {
//         return dateString;
//       }
//     }
//
//     String getFormattedDate() {
//       final now = DateTime.now();
//       return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//     }
//
//     String getFormattedTime() {
//       final now = DateTime.now();
//       return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
//     }
//
//     return {
//       "id": id,
//       "leave_id": leaveId,
//       "booker_id": bookerId,
//       "booker_name": bookerName,
//       "leave_type": leaveType,
//       "start_date": extractDateOnly(startDate),
//       "end_date": extractDateOnly(endDate),
//       "total_days": totalDays,
//       "is_half_day": isHalfDay ? 1 : 0,
//       "reason": reason,
//       "attachment_data": attachmentData, // BLOB data
//       "application_date": applicationDate ?? getFormattedDate(),
//       "application_time": applicationTime ?? getFormattedTime(),
//       "status": status ?? "pending",
//     };
//   }
//
//   factory LeaveModel.fromMap(Map<String, dynamic> map) {
//     String extractDateOnly(String? dateString) {
//       if (dateString == null) return "";
//       try {
//         if (dateString.contains(' ')) {
//           return dateString.split(' ')[0];
//         }
//         if (dateString.contains('T')) {
//           return dateString.split('T')[0];
//         }
//         return dateString;
//       } catch (e) {
//         return dateString;
//       }
//     }
//
//     // Extract BLOB data from map - FIXED: Uint8List doesn't have toList()
//     List<int>? attachmentBytes;
//     if (map['attachment_data'] != null) {
//       if (map['attachment_data'] is List<int>) {
//         attachmentBytes = map['attachment_data'] as List<int>;
//       } else if (map['attachment_data'] is Uint8List) {
//         // Convert Uint8List to List<int> properly
//         Uint8List uint8list = map['attachment_data'] as Uint8List;
//         attachmentBytes = uint8list.toList();
//       }
//     }
//
//     return LeaveModel(
//       id: map['id']?.toString(),
//       leaveId: map['leave_id']?.toString(),
//       bookerId: map['booker_id'].toString(),
//       bookerName: map['booker_name']?.toString(),
//       leaveType: map['leave_type'].toString(),
//       startDate: extractDateOnly(map['start_date']?.toString()),
//       endDate: extractDateOnly(map['end_date']?.toString()),
//       totalDays: map['total_days'] as int,
//       isHalfDay: map['is_half_day'] == 1,
//       reason: map['reason'].toString(),
//       attachmentData: attachmentBytes,
//       applicationDate: map['application_date']?.toString(),
//       applicationTime: map['application_time']?.toString(),
//       status: map['status']?.toString() ?? 'pending',
//     );
//   }
//
//   LeaveModel copyWith({
//     String? id,
//     String? leaveId,
//     String? bookerId,
//     String? bookerName,
//     String? leaveType,
//     String? startDate,
//     String? endDate,
//     int? totalDays,
//     bool? isHalfDay,
//     String? reason,
//     List<int>? attachmentData,
//     String? applicationDate,
//     String? applicationTime,
//     String? status,
//   }) {
//     return LeaveModel(
//       id: id ?? this.id,
//       leaveId: leaveId ?? this.leaveId,
//       bookerId: bookerId ?? this.bookerId,
//       bookerName: bookerName ?? this.bookerName,
//       leaveType: leaveType ?? this.leaveType,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       totalDays: totalDays ?? this.totalDays,
//       isHalfDay: isHalfDay ?? this.isHalfDay,
//       reason: reason ?? this.reason,
//       /*attachmentUrl: attachmentUrl ?? this.attachmentUrl,*/
//       attachmentData: attachmentData ?? this.attachmentData,
//       applicationDate: applicationDate ?? this.applicationDate,
//       applicationTime: applicationTime ?? this.applicationTime,
//       status: status ?? this.status,
//     );
//   }
// }

import 'dart:typed_data';
import 'dart:convert';

class LeaveModel {
  String? id;
  String? leaveId;
  String bookerId;
  String? bookerName;
  String leaveType;
  String startDate;
  String endDate;
  int totalDays;
  bool isHalfDay;
  String reason;
  Uint8List? attachmentData; // Shop visit style: Uint8List for image
  String? attachmentImage; // Filename

  String? applicationDate;
  String? applicationTime;
  String? status;
  int? posted;

  LeaveModel({
    this.id,
    this.leaveId,
    required this.bookerId,
    this.bookerName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.isHalfDay,
    required this.reason,
    this.attachmentData,
    this.attachmentImage,
    this.applicationDate,
    this.applicationTime,
    this.status = 'pending',
    this.posted = 0,
  });

  // For JSON submission (fallback)
  Map<String, dynamic> toJson() {
    String extractDateOnly(String dateString) {
      try {
        if (dateString.contains(' ')) {
          return dateString.split(' ')[0];
        }
        if (dateString.contains('T')) {
          return dateString.split('T')[0];
        }
        return dateString;
      } catch (e) {
        return dateString;
      }
    }

    String getFormattedDate() {
      final now = DateTime.now();
      return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }

    String getFormattedTime() {
      final now = DateTime.now();
      return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    }

    return {
      "ID": id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      "Leave_ID": leaveId ?? "",
      "Booker_ID": bookerId,
      "Booker_Name": bookerName ?? "",
      "Leave_Type": leaveType,
      "Start_Date": extractDateOnly(startDate),
      "End_Date": extractDateOnly(endDate),
      "Total_Days": totalDays,
      "Is_Half_Day": isHalfDay ? 1 : 0,
      "Reason": reason,
      "Application_Date": applicationDate ?? getFormattedDate(),
      "Application_Time": applicationTime ?? getFormattedTime(),
      "Attachment_Image": attachmentImage ?? "",
      "Status": status ?? "pending",
      "Posted": posted ?? 0,

    };
  }

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    String extractDateOnly(String? dateString) {
      if (dateString == null) return "";
      try {
        if (dateString.contains(' ')) {
          return dateString.split(' ')[0];
        }
        if (dateString.contains('T')) {
          return dateString.split('T')[0];
        }
        return dateString;
      } catch (e) {
        return dateString;
      }
    }

    // Shop visit style: Parse BLOB/Uint8List
    Uint8List? parseAttachmentData(dynamic data) {
      if (data == null) return null;
      if (data is Uint8List) {
        return data;
      }
      if (data is List<int>) {
        return Uint8List.fromList(data);
      }
      if (data is String && data.isNotEmpty) {
        try {
          return base64Decode(data);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return LeaveModel(
      id: map['ID']?.toString() ?? map['id']?.toString(),
      leaveId: map['Leave_ID']?.toString() ?? map['leave_id']?.toString(),
      bookerId: map['Booker_ID']?.toString() ?? map['booker_id']?.toString() ?? '',
      bookerName: map['Booker_Name']?.toString() ?? map['booker_name']?.toString(),
      leaveType: map['Leave_Type']?.toString() ?? map['leave_type']?.toString() ?? '',
      startDate: extractDateOnly(map['Start_Date']?.toString() ?? map['start_date']?.toString()),
      endDate: extractDateOnly(map['End_Date']?.toString() ?? map['end_date']?.toString()),
      totalDays: map['Total_Days'] as int? ?? map['total_days'] as int? ?? 0,
      isHalfDay: (map['Is_Half_Day'] ?? map['is_half_day']) == 1,
      reason: map['Reason']?.toString() ?? map['reason']?.toString() ?? '',
      attachmentData: parseAttachmentData(map['attachment_data']),
      attachmentImage: map['Attachment_Image']?.toString() ?? map['attachment_image']?.toString(),

      applicationDate: map['Application_Date']?.toString() ?? map['application_date']?.toString(),
      applicationTime: map['Application_Time']?.toString() ?? map['application_time']?.toString(),
      status: map['Status']?.toString() ?? map['status']?.toString() ?? 'pending',
      posted: map['Posted'] as int? ?? map['posted'] as int? ?? 0,
    );
  }

  LeaveModel copyWith({
    String? id,
    String? leaveId,
    String? bookerId,
    String? bookerName,
    String? leaveType,
    String? startDate,
    String? endDate,
    int? totalDays,
    bool? isHalfDay,
    String? reason,
    Uint8List? attachmentData,
    String? attachmentImage,
    String? attachmentUrl,
    String? applicationDate,
    String? applicationTime,
    String? status,
    int? posted,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      leaveId: leaveId ?? this.leaveId,
      bookerId: bookerId ?? this.bookerId,
      bookerName: bookerName ?? this.bookerName,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      reason: reason ?? this.reason,
      attachmentData: attachmentData ?? this.attachmentData,
      attachmentImage: attachmentImage ?? this.attachmentImage,

      applicationDate: applicationDate ?? this.applicationDate,
      applicationTime: applicationTime ?? this.applicationTime,
      status: status ?? this.status,
      posted: posted ?? this.posted,
    );
  }
}