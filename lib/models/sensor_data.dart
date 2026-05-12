/// SensorData
///
/// ESP8266 writes:
///   /sensor/temperature  → float  (use directly)
///   /sensor/humidity     → float  (use directly)
///   /sensor/gas          → int 0-1023 raw ADC  → mapped to 0-100%
///   /sensor/light        → int 0=dark 1=bright → mapped to 0 or 100%
///   /sensor/flame        → int 0=FIRE 1=safe (active-low) → bool + intensity
class SensorData {
  final double temperature;
  final double humidity;
  final double light;
  final double gasLevel;
  final bool flameDetected;
  final double flameIntensity;
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
    final double temp = (map['temperature'] ?? 0).toDouble();
    final double hum = (map['humidity'] ?? 0).toDouble();

    // gas field from ESP8266 is raw ADC 0-1023, field name "gas"
    // but also support "gasLevel" in case firmware is updated later
    final rawGas = map['gas'] ?? map['gasLevel'] ?? 0;
    final double gasLevel = _mapGas((rawGas as num).toDouble());

    // light field from ESP8266 is digital 0 or 1, field name "light"
    final rawLight = map['light'] ?? 0;
    final double light = _mapLight(rawLight);

    // flame field from ESP8266 is active-low: 0=fire, 1=no fire, field name "flame"
    // also support "flameDetected" bool in case firmware is updated later
    final rawFlame = map['flame'] ?? map['flameDetected'] ?? 1;
    final bool flameDetected = _mapFlame(rawFlame);
    final double flameIntensity = flameDetected ? 100.0 : 0.0;

    final int updatedAt = (map['updatedAt'] ?? 0).toInt();

    return SensorData(
      temperature: temp,
      humidity: hum,
      light: light,
      gasLevel: gasLevel,
      flameDetected: flameDetected,
      flameIntensity: flameIntensity,
      updatedAt: updatedAt,
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

  // raw ADC 0-1023 → 0-100%
  // also handles if value is already a % (0-100) or fraction (0-1)
  static double _mapGas(double raw) {
    if (raw <= 1.0) return (raw * 100.0).clamp(0.0, 100.0);
    if (raw <= 100.0) return raw.clamp(0.0, 100.0);
    return ((raw / 1023.0) * 100.0).clamp(0.0, 100.0);
  }

  // digital 0/1 → 0 or 100%
  static double _mapLight(dynamic raw) {
    if (raw is bool) return raw ? 100.0 : 0.0;
    final v = (raw as num).toDouble();
    if (v > 1.0) return v.clamp(0.0, 100.0); // already a percentage
    return v >= 1.0 ? 100.0 : 0.0;
  }

  // active-low: 0 = flame detected → true
  static bool _mapFlame(dynamic raw) {
    if (raw is bool) return raw; // already a bool
    final v = (raw as num).toInt();
    return v == 0; // active-low: 0 means fire
  }
}
