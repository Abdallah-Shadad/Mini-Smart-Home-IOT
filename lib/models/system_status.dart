class SystemStatus {
  final bool deviceOnline;
  final int lastSeen;

  const SystemStatus({
    required this.deviceOnline,
    required this.lastSeen,
  });

  factory SystemStatus.fromMap(Map<dynamic, dynamic> map) {
    return SystemStatus(
      deviceOnline: map['deviceOnline'] == true,
      lastSeen: (map['lastSeen'] ?? 0).toInt(),
    );
  }

  factory SystemStatus.offline() {
    return SystemStatus(
      deviceOnline: false,
      lastSeen: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}
