import '../models/control_state.dart';
import 'firebase_service.dart';

class ControlService {
  ControlService({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService.instance;

  final FirebaseService _firebase;

  Stream<ControlState> watchControlState() {
    return _firebase.controlRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        return ControlState.fromMap(value);
      }
      return ControlState.empty();
    });
  }

  Future<void> updateControl(Map<String, dynamic> data) {
    return _firebase.controlRef.update(data);
  }

  Future<void> setRedLed(bool value) => updateControl({'redLed': value});
  Future<void> setGreenLed(bool value) => updateControl({'greenLed': value});
  Future<void> setYellowLed(bool value) => updateControl({'yellowLed': value});
  Future<void> setAutoMode(bool value) => updateControl({'autoMode': value});
}
