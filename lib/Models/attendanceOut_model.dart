import 'package:intl/intl.dart';

class AttendanceOutModel {
  dynamic attendance_out_id;
  String? emp_id;
  dynamic total_time;
  dynamic lat_out;
  dynamic lng_out;
  dynamic total_distance;
  dynamic address;
  dynamic attendance_out_date;
  dynamic attendance_out_time;
  int posted;
  String? reason;

  AttendanceOutModel({
    this.attendance_out_id,
    this.emp_id,
    this.total_time,
    this.lat_out,
    this.lng_out,
    this.total_distance,
    this.attendance_out_date,
    this.attendance_out_time,
    this.address,
    this.posted = 0,
    this.reason,
  });

  factory AttendanceOutModel.fromMap(Map<String, dynamic> json) {
    return AttendanceOutModel(
      attendance_out_id: json['attendance_out_id'],
      emp_id: json['emp_id'],
      total_time: json['total_time'],
      lat_out: json['lat_out'],
      lng_out: json['lng_out'],
      total_distance: json['total_distance'],
      attendance_out_date: json['attendance_out_date'],
      attendance_out_time: json['attendance_out_time'],
      address: json['address'],
      posted: json['posted'] ?? 0,
      reason: json['reason'] ?? 'manual',
    );
  }

  Map<String, dynamic> toMap() {
    // Determine date string
    String dateString;
    if (attendance_out_date is DateTime) {
      dateString = DateFormat('dd-MMM-yyyy').format(attendance_out_date);
    } else if (attendance_out_date is String) {
      dateString = attendance_out_date;
    } else {
      dateString = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    }

    // Determine time string
    String timeString;
    if (attendance_out_time is DateTime) {
      timeString = DateFormat('HH:mm:ss').format(attendance_out_time);
    } else if (attendance_out_time is String) {
      timeString = attendance_out_time;
    } else {
      timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    }

    return {
      'attendance_out_id': attendance_out_id,
      'emp_id': emp_id,
      'total_time': total_time,
      'lat_out': lat_out,
      'lng_out': lng_out,
      'total_distance': total_distance,
      'attendance_out_date': dateString,
      'attendance_out_time': timeString,
      'address': address,
      'posted': posted,
      'reason': reason ?? 'manual',
    };
  }

  // For API posting
  Map<String, dynamic> toJson() {
    return {
      'attendance_out_id': attendance_out_id,
      'emp_id': emp_id,
      'total_time': total_time,
      'lat_out': lat_out,
      'lng_out': lng_out,
      'total_distance': total_distance,
      'address': address,
      'attendance_out_date': attendance_out_date,
      'attendance_out_time': attendance_out_time,
      'reason': reason ?? 'manual',
    };
  }
}