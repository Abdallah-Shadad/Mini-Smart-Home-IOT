class SensorData {
  final double temperature;
  final double humidity;
  final double light;
  final int updatedAt;

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.updatedAt,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature: (map['temperature'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      light: (map['light'] ?? 0).toDouble(),
      updatedAt: (map['updatedAt'] ?? 0).toInt(),
    );
  }

  factory SensorData.empty() {
    return const SensorData(
      temperature: 0,
      humidity: 0,
      light: 0,
      updatedAt: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      'updatedAt': updatedAt,
    };
  }
}
