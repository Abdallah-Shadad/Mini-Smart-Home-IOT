/// AlertModel
///
/// ESP8266 writes /alerts as a plain STRING: "Safe", "Fire Detected!", "Gas Leak!"
/// This model handles both that string format and the object map format.
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

  /// Parse from object map: { message, type, time }
  factory AlertModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertModel(
      id: id,
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      time: (map['time'] ?? 0).toInt(),
    );
  }

  /// Parse from ESP8266 plain string value
  factory AlertModel.fromString(String value) {
    String type = 'info';
    final lower = value.toLowerCase();
    if (lower.contains('fire') || lower.contains('gas')) {
      type = 'danger';
    } else if (lower.contains('temperature') || lower.contains('temp')) {
      type = 'warning';
    }
    return AlertModel(
      id: 'esp_current',
      message: value,
      type: type,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
