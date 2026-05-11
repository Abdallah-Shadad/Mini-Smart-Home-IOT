import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = true;
  double _tempThreshold = 35.0;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get darkMode => _darkMode;
  double get tempThreshold => _tempThreshold;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  final DatabaseReference _settingsRef =
      FirebaseDatabase.instance.ref('settings');

  Future<void> init() async {
    // Load dark mode from local storage
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? true;
    _isLoading = false;
    notifyListeners();

    // Listen to threshold from Firebase
    _settingsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        _tempThreshold = (map['tempThreshold'] ?? 35).toDouble();
        notifyListeners();
      }
    });
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setTempThreshold(double value) async {
    _tempThreshold = value;
    notifyListeners();

    _isSaving = true;
    notifyListeners();
    try {
      await _settingsRef.update({'tempThreshold': value});
    } catch (_) {}
    _isSaving = false;
    notifyListeners();
  }
}
