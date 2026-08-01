import 'car.dart';

class Rental {
  final String id;
  final int carId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final Car? car;

  const Rental({
    required this.id,
    required this.carId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.car,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      carId: json['car_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationMinutes: json['duration_minutes'] as int,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      car: json['cars'] != null ? Car.fromJson(json['cars'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
