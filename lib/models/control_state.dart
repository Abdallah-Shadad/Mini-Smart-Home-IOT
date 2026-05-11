class ControlState {
  final bool redLed;
  final bool greenLed;
  final bool yellowLed;
  final bool autoMode;

  const ControlState({
    required this.redLed,
    required this.greenLed,
    required this.yellowLed,
    required this.autoMode,
  });

  factory ControlState.fromMap(Map<dynamic, dynamic> map) {
    return ControlState(
      redLed: map['redLed'] == true,
      greenLed: map['greenLed'] == true,
      yellowLed: map['yellowLed'] == true,
      autoMode: map['autoMode'] == true,
    );
  }

  factory ControlState.empty() {
    return const ControlState(
      redLed: false,
      greenLed: false,
      yellowLed: false,
      autoMode: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'redLed': redLed,
      'greenLed': greenLed,
      'yellowLed': yellowLed,
      'autoMode': autoMode,
    };
  }

  ControlState copyWith({
    bool? redLed,
    bool? greenLed,
    bool? yellowLed,
    bool? autoMode,
  }) {
    return ControlState(
      redLed: redLed ?? this.redLed,
      greenLed: greenLed ?? this.greenLed,
      yellowLed: yellowLed ?? this.yellowLed,
      autoMode: autoMode ?? this.autoMode,
    );
  }
}
