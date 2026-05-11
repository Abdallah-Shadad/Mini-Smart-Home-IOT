class AlertModel {
  final String id;
  final String message;
  final String type; // 'warning' | 'danger' | 'info'
  final int time;

  const AlertModel({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
  });

  factory AlertModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertModel(
      id: id,
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      time: (map['time'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type,
      'time': time,
    };
  }
}
