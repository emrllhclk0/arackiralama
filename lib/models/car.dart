class Car {
  final int id;
  final String name;
  final String color;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;

  const Car({
    required this.id,
    required this.name,
    required this.color,
    required this.status,
    required this.createdAt,
    this.imageUrl,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
