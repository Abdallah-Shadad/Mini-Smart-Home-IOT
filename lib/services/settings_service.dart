import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class SettingsService {
  SettingsService({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService.instance;

  final FirebaseService _firebase;

  Stream<double> watchTempThreshold() {
    return _firebase.settingsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        return (value['tempThreshold'] ?? 35).toDouble();
      }
      return 35.0;
    });
  }

  Future<void> setTempThreshold(double value) {
    return _firebase.settingsRef.update({'tempThreshold': value});
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? true;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }
}
