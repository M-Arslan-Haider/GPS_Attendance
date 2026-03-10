import 'package:intl/intl.dart';

class AttendanceModel {
  dynamic attendance_in_id;
  String? emp_id;
  dynamic lat_in;
  dynamic lng_in;
  dynamic booker_name;
  dynamic designation;
  dynamic city;
  dynamic address;
  dynamic attendance_in_date;
  dynamic attendance_in_time;
  int posted;

  AttendanceModel({
    this.attendance_in_id,
    this.emp_id,
    this.lat_in,
    this.lng_in,
    this.booker_name,
    this.city,
    this.designation,
    this.attendance_in_date,
    this.attendance_in_time,
    this.address,
    this.posted = 0
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> json) {
    return AttendanceModel(
        attendance_in_id: json['attendance_in_id'],
        emp_id: json['emp_id'],
        lat_in: json['lat_in'],
        lng_in: json['lng_in'],
        booker_name: json['booker_name'],
        city: json['city'],
        designation: json['designation'],
        address: json['address'],
        attendance_in_date: json['attendance_in_date'],
        attendance_in_time: json['attendance_in_time'],
        posted: json['posted'] ?? 0
    );
  }

  Map<String, dynamic> toMap() {
    // Determine date string
    String dateString;
    if (attendance_in_date is DateTime) {
      dateString = DateFormat('dd-MMM-yyyy').format(attendance_in_date);
    } else if (attendance_in_date is String) {
      dateString = attendance_in_date;
    } else {
      dateString = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    }

    // Determine time string
    String timeString;
    if (attendance_in_time is DateTime) {
      timeString = DateFormat('HH:mm:ss').format(attendance_in_time);
    } else if (attendance_in_time is String) {
      timeString = attendance_in_time;
    } else {
      timeString = DateFormat('HH:mm:ss').format(DateTime.now());
    }

    return {
      'attendance_in_id': attendance_in_id,
      'emp_id': emp_id,
      'lat_in': lat_in,
      'lng_in': lng_in,
      'booker_name': booker_name,
      'city': city,
      'designation': designation,
      'address': address,
      'attendance_in_date': dateString,
      'attendance_in_time': timeString,
      'posted': posted,
    };
  }

  // For API posting
  Map<String, dynamic> toJson() {
    return {
      'attendance_in_id': attendance_in_id,
      'emp_id': emp_id,
      'lat_in': lat_in,
      'lng_in': lng_in,
      'booker_name': booker_name,
      'city': city,
      'designation': designation,
      'address': address,
      'attendance_in_date': attendance_in_date,
      'attendance_in_time': attendance_in_time,
    };
  }
}