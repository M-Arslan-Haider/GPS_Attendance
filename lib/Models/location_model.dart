import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class LocationModel {
  dynamic location_id;
  String? emp_id;         // employee id (table: emp_id)
  String? emp_name;       // employee name (table: emp_name)
  int posted;             // 0 = not posted, 1 = posted
  String? file_name;
  Uint8List? body;
  dynamic total_distance;
  DateTime? location_date;
  DateTime? location_time;

  LocationModel({
    this.location_id,
    this.emp_id,
    this.emp_name,
    this.posted = 0,
    this.file_name,
    this.body,
    this.total_distance,
    this.location_date,
    this.location_time,
  });

  // ----------------------
  // CREATE MODEL FROM DB / API MAP
  // ----------------------
  factory LocationModel.fromMap(Map<dynamic, dynamic> json) {
    final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm:ss');

    return LocationModel(
      location_id: json['location_id'],
      emp_id: json['emp_id'],
      emp_name: json['emp_name'],
      posted: json['posted'] ?? 0,
      file_name: json['file_name'],
      total_distance: json['total_distance'],

      location_date: json['location_date'] != null
          ? dateFormat.parse(json['location_date'].toString())
          : null,

      location_time: json['location_time'] != null
          ? timeFormat.parse(json['location_time'].toString())
          : null,

      body: json['body'] != null && json['body'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['body'].toString()))
          : null,
    );
  }

  // ----------------------
  // CONVERT MODEL TO DB / API MAP
  // ----------------------
  Map<String, dynamic> toMap() {
    return {
      'location_id': location_id,
      'emp_id': emp_id,
      'emp_name': emp_name,
      'posted': posted,
      'file_name': file_name,
      'total_distance': total_distance,
      'location_date': location_date != null
          ? DateFormat('dd-MMM-yyyy').format(location_date!)
          : DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      'location_time': location_time != null
          ? DateFormat('HH:mm:ss').format(location_time!)
          : DateFormat('HH:mm:ss').format(DateTime.now()),
      'body': body != null ? base64Encode(body!) : null,
    };
  }
}