import 'package:intl/intl.dart';

class Formatters {
  static String timeAgo(int unixSeconds) {
    if (unixSeconds == 0) return 'Never';
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String formatTime(int unixSeconds) {
    if (unixSeconds == 0) return '--:--';
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    return DateFormat('HH:mm').format(dt);
  }

  static String formatDateTime(int unixSeconds) {
    if (unixSeconds == 0) return '---';
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    return DateFormat('MMM d, HH:mm').format(dt);
  }

  static String formatHour(int unixSeconds) {
    if (unixSeconds == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    return DateFormat('HH:mm').format(dt);
  }

  static String temp(double value) => '${value.toStringAsFixed(1)}°C';

  static String humidity(double value) => '${value.toStringAsFixed(0)}%';

  static String light(double value) => '${value.toStringAsFixed(0)}%';
}
