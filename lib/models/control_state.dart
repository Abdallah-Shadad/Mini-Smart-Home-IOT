/// ControlState
///
/// ESP8266 writes int 0 or 1 for LED fields.
/// Flutter writes bool true/false.
/// _toBool() handles both so nothing crashes.
class ControlState {
  final bool redLed;
  final bool greenLed;
  final bool yellowLed;
  final bool autoMode;
  final bool buzzerEnabled;

  const ControlState({
    required this.redLed,
    required this.greenLed,
    required this.yellowLed,
    required this.autoMode,
    required this.buzzerEnabled,
  });

  factory ControlState.fromMap(Map<dynamic, dynamic> map) {
    return ControlState(
      redLed: _toBool(map['redLed']),
      greenLed: _toBool(map['greenLed']),
      yellowLed: _toBool(map['yellowLed']),
      autoMode: _toBool(map['autoMode']),
      buzzerEnabled: _toBool(map['buzzerEnabled']),
    );
  }

  factory ControlState.empty() {
    return const ControlState(
      redLed: false,
      greenLed: false,
      yellowLed: false,
      autoMode: false,
      buzzerEnabled: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'redLed': redLed,
      'greenLed': greenLed,
      'yellowLed': yellowLed,
      'autoMode': autoMode,
      'buzzerEnabled': buzzerEnabled,
    };
  }

  ControlState copyWith({
    bool? redLed,
    bool? greenLed,
    bool? yellowLed,
    bool? autoMode,
    bool? buzzerEnabled,
  }) {
    return ControlState(
      redLed: redLed ?? this.redLed,
      greenLed: greenLed ?? this.greenLed,
      yellowLed: yellowLed ?? this.yellowLed,
      autoMode: autoMode ?? this.autoMode,
      buzzerEnabled: buzzerEnabled ?? this.buzzerEnabled,
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
