/// SystemStatus
///
/// ESP8266 does NOT write /system at all.
/// SensorProvider infers online/offline from how recently
/// a sensor update arrived and sets this manually.
class SystemStatus {
  final bool deviceOnline;
  final int lastSeen;

  const SystemStatus({
    required this.deviceOnline,
    required this.lastSeen,
  });

  factory SystemStatus.fromMap(Map<dynamic, dynamic> map) {
    return SystemStatus(
      deviceOnline: _toBool(map['deviceOnline']),
      lastSeen: (map['lastSeen'] ?? 0).toInt(),
    );
  }

  factory SystemStatus.offline() {
    return SystemStatus(
      deviceOnline: false,
      lastSeen: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is double) return v != 0.0;
    return false;
  }
}
