class HistoryPoint {
  final int timestamp;
  final double temperature;
  final double light;
  final double humidity;
  final double gasLevel; // MQ2 %
  final double flameIntensity; // Flame sensor %

  const HistoryPoint({
    required this.timestamp,
    required this.temperature,
    required this.light,
    required this.humidity,
    required this.gasLevel,
    required this.flameIntensity,
  });

  factory HistoryPoint.fromMap(Map<dynamic, dynamic> map) {
    return HistoryPoint(
      timestamp: (map['timestamp'] ?? 0).toInt(),
      temperature: (map['temperature'] ?? 0).toDouble(),
      light: (map['light'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      gasLevel: (map['gasLevel'] ?? 0).toDouble(),
      flameIntensity: (map['flameIntensity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'temperature': temperature,
      'light': light,
      'humidity': humidity,
      'gasLevel': gasLevel,
      'flameIntensity': flameIntensity,
    };
  }
}
