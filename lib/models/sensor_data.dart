class SensorData {
  final double temperature;
  final double humidity;
  final double light;
  final double gasLevel;       // MQ2: 0–100 (%)
  final bool flameDetected;    // Flame sensor: true = fire detected
  final double flameIntensity; // Flame sensor raw analog: 0–100 (%)
  final int updatedAt;

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.gasLevel,
    required this.flameDetected,
    required this.flameIntensity,
    required this.updatedAt,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature: (map['temperature'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      light: (map['light'] ?? 0).toDouble(),
      gasLevel: (map['gasLevel'] ?? 0).toDouble(),
      flameDetected: map['flameDetected'] == true,
      flameIntensity: (map['flameIntensity'] ?? 0).toDouble(),
      updatedAt: (map['updatedAt'] ?? 0).toInt(),
    );
  }

  factory SensorData.empty() {
    return const SensorData(
      temperature: 0,
      humidity: 0,
      light: 0,
      gasLevel: 0,
      flameDetected: false,
      flameIntensity: 0,
      updatedAt: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      'gasLevel': gasLevel,
      'flameDetected': flameDetected,
      'flameIntensity': flameIntensity,
      'updatedAt': updatedAt,
    };
  }
}