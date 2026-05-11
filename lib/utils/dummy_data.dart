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

      // Realistic temperature curve: lower at night, peak in afternoon
      double temp;
      if (hour >= 0 && hour < 6) {
        temp = 20.0 + (hour * 0.3); // Cool night
      } else if (hour >= 6 && hour < 14) {
        temp = 22.0 + ((hour - 6) * 1.5); // Morning rise
      } else if (hour >= 14 && hour < 18) {
        temp = 34.0 - ((hour - 14) * 0.5); // Afternoon peak
      } else {
        temp = 32.0 - ((hour - 18) * 1.2); // Evening cool down
      }
      // Add slight noise
      temp += (_noise(i) * 2.0);

      // Realistic light curve: zero at night, peak at noon
      double light;
      if (hour >= 7 && hour < 19) {
        final midday = 13.0;
        final distFromNoon = (hour - midday).abs();
        light = 100.0 - (distFromNoon * 8.0);
        light = light.clamp(5.0, 100.0);
        light += (_noise(i + 100) * 10);
      } else {
        light = 1.0 + (_noise(i + 200) * 3.0).abs();
      }

      // Realistic humidity: inverse of temperature roughly
      double humidity = 60.0 - (temp - 25.0) * 1.2 + (_noise(i + 50) * 5.0);
      humidity = humidity.clamp(30.0, 90.0);

      points.add(HistoryPoint(
        timestamp: time.millisecondsSinceEpoch ~/ 1000,
        temperature: double.parse(temp.toStringAsFixed(1)),
        light: double.parse(light.clamp(0, 100).toStringAsFixed(1)),
        humidity: double.parse(humidity.toStringAsFixed(1)),
      ));
    }

    return points;
  }

  // Simple deterministic pseudo-noise using sine
  static double _noise(int seed) {
    return (seed * 2.7183 % 3.14159) - 1.5707;
  }
}
