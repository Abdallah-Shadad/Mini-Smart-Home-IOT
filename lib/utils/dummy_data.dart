import '../models/history_point.dart';

/// Generates realistic dummy time-series data for demo/presentation
/// when the Firebase 'history' node is empty.
class DummyData {
  static List<HistoryPoint> generateHistory({int hours = 24}) {
    final now = DateTime.now();
    final List<HistoryPoint> points = [];

    for (int i = hours; i >= 0; i--) {
      final time = now.subtract(Duration(hours: i));
      final hour = time.hour;

      // Realistic temperature curve
      double temp;
      if (hour >= 0 && hour < 6) {
        temp = 20.0 + (hour * 0.3);
      } else if (hour >= 6 && hour < 14) {
        temp = 22.0 + ((hour - 6) * 1.5);
      } else if (hour >= 14 && hour < 18) {
        temp = 34.0 - ((hour - 14) * 0.5);
      } else {
        temp = 32.0 - ((hour - 18) * 1.2);
      }
      temp += (_noise(i) * 2.0);

      // Realistic light curve
      double light;
      if (hour >= 7 && hour < 19) {
        final distFromNoon = (hour - 13.0).abs();
        light = (100.0 - (distFromNoon * 8.0) + (_noise(i + 100) * 10))
            .clamp(5.0, 100.0);
      } else {
        light = (1.0 + (_noise(i + 200) * 3.0).abs()).clamp(0.0, 10.0);
      }

      // Realistic humidity
      double humidity = (60.0 - (temp - 25.0) * 1.2 + (_noise(i + 50) * 5.0))
          .clamp(30.0, 90.0);

      // MQ2 gas level: mostly low with occasional spikes (cooking, etc.)
      double gasLevel;
      if (i % 7 == 0) {
        // Simulate a brief gas spike every ~7 hours
        gasLevel = (35.0 + (_noise(i + 300) * 15.0).abs()).clamp(0.0, 80.0);
      } else {
        gasLevel = (8.0 + (_noise(i + 300) * 5.0).abs()).clamp(0.0, 25.0);
      }

      // Flame intensity: near-zero normally, spikes during day (candle? grill?)
      double flameIntensity;
      if (hour >= 18 && hour < 22 && i % 11 == 0) {
        // Evening candle simulation
        flameIntensity =
            (20.0 + (_noise(i + 400) * 10.0).abs()).clamp(0.0, 50.0);
      } else {
        flameIntensity = (_noise(i + 400) * 3.0).abs().clamp(0.0, 5.0);
      }

      points.add(HistoryPoint(
        timestamp: time.millisecondsSinceEpoch ~/ 1000,
        temperature: double.parse(temp.toStringAsFixed(1)),
        light: double.parse(light.clamp(0, 100).toStringAsFixed(1)),
        humidity: double.parse(humidity.toStringAsFixed(1)),
        gasLevel: double.parse(gasLevel.toStringAsFixed(1)),
        flameIntensity: double.parse(flameIntensity.toStringAsFixed(1)),
      ));
    }

    return points;
  }

  // Simple deterministic pseudo-noise using modulo math
  static double _noise(int seed) {
    return (seed * 2.7183 % 3.14159) - 1.5707;
  }
}
