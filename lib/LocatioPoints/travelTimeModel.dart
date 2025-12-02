// class TravelTimeModel {
//   String? id;
//   String? userId;
//   String? travel_date;
//   String? startTime;
//   String? endTime;
//   double? travelDistance; // کلومیٹر میں
//   double? travelTime; // منٹ میں
//   double? averageSpeed; // کلومیٹر فی گھنٹہ
//   double? workingTime; // منٹ میں
//   double? stationaryTime; // منٹ میں
//   String? travelType; // 'traveling', 'working', 'stationary'
//   double? latitude;
//   double? longitude;
//   String? address;
//   int posted = 0;
//
//   TravelTimeModel({
//     this.id,
//     this.userId,
//     this.travel_date,
//     this.startTime,
//     this.endTime,
//     this.travelDistance,
//     this.travelTime,
//     this.averageSpeed,
//     this.workingTime,
//     this.stationaryTime,
//     this.travelType,
//     this.latitude,
//     this.longitude,
//     this.address,
//     this.posted = 0,
//   });
//
//   factory TravelTimeModel.fromMap(Map<dynamic, dynamic> json) {
//     return TravelTimeModel(
//       id: json['id'],
//       userId: json['user_id'],
//       travel_date: json['travel_date'],
//       startTime: json['start_time'],
//       endTime: json['end_time'],
//       travelDistance: json['travel_distance'] != null ? double.parse(json['travel_distance'].toString()) : 0.0,
//       travelTime: json['travel_time'] != null ? double.parse(json['travel_time'].toString()) : 0.0,
//       averageSpeed: json['average_speed'] != null ? double.parse(json['average_speed'].toString()) : 0.0,
//       workingTime: json['working_time'] != null ? double.parse(json['working_time'].toString()) : 0.0,
//       stationaryTime: json['stationary_time'] != null ? double.parse(json['stationary_time'].toString()) : 0.0,
//       travelType: json['travel_type'],
//       latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : 0.0,
//       longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : 0.0,
//       address: json['address'],
//       posted: json['posted'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'travel_date': travel_date,
//       'start_time': startTime,
//       'end_time': endTime,
//       'travel_distance': travelDistance?.toString(),
//       'travel_time': travelTime?.toString(),
//       'average_speed': averageSpeed?.toString(),
//       'working_time': workingTime?.toString(),
//       'stationary_time': stationaryTime?.toString(),
//       'travel_type': travelType,
//       'latitude': latitude?.toString(),
//       'longitude': longitude?.toString(),
//       'address': address,
//       'posted': posted,
//     };
//   }
// }

// travelTimeModel.dart
class TravelTimeModel {
  String? id;
  String? userId;
  String? travel_date;
  String? startTime;
  String? endTime;
  double? travelDistance;
  double? travelTime;
  double? averageSpeed;
  double? workingTime;
  double? idleTime;
  String? travelType;
  double? latitude;
  double? longitude;
  String? address;
  int posted = 0;

  TravelTimeModel({
    this.id,
    this.userId,
    this.travel_date,
    this.startTime,
    this.endTime,
    this.travelDistance,
    this.travelTime,
    this.averageSpeed,
    this.workingTime,
    this.idleTime,
    this.travelType,
    this.latitude,
    this.longitude,
    this.address,
    this.posted = 0,
  });

  factory TravelTimeModel.fromMap(Map<dynamic, dynamic> json) {
    return TravelTimeModel(
      id: json['id'],
      userId: json['user_id'],
      travel_date: json['travel_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      travelDistance: _parseDouble(json['travel_distance']),
      travelTime: _parseDouble(json['travel_time']),
      averageSpeed: _parseDouble(json['average_speed']),
      workingTime: _parseDouble(json['working_time']),
      idleTime: _parseDouble(json['idle_time']),
      travelType: json['travel_type'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address'],
      posted: json['posted'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'travel_date': travel_date,
      'start_time': startTime,
      'end_time': endTime,
      'travel_distance': travelDistance,
      'travel_time': travelTime,
      'average_speed': averageSpeed,
      'working_time': workingTime,
      'idle_time': idleTime,
      'travel_type': travelType,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'posted': posted,
    };
  }
}