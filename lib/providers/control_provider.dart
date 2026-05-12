import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/control_state.dart';

class ControlProvider extends ChangeNotifier {
  ControlState _state = ControlState.empty();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  ControlState get state => _state;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  final DatabaseReference _ref = FirebaseDatabase.instance.ref('control');

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _ref.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          _state = ControlState.fromMap(
            event.snapshot.value as Map<dynamic, dynamic>,
          );
        } else {
          _state = ControlState.empty();
        }
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> setRedLed(bool value) => _update({'redLed': value});
  Future<void> setGreenLed(bool value) => _update({'greenLed': value});
  Future<void> setYellowLed(bool value) => _update({'yellowLed': value});
  Future<void> setAutoMode(bool value) => _update({'autoMode': value});
  Future<void> setBuzzerEnabled(bool value) =>
      _update({'buzzerEnabled': value});

  Future<void> _update(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _ref.update(data);
    } catch (e) {
      _error = 'Failed to update: $e';
      notifyListeners();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
