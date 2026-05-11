import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';

class SensorProvider extends ChangeNotifier {
  SensorData _sensorData = SensorData.empty();
  SystemStatus _systemStatus = SystemStatus.offline();
  bool _isLoading = true;
  String? _error;

  SensorData get sensorData => _sensorData;
  SystemStatus get systemStatus => _systemStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensor');
  final DatabaseReference _systemRef = FirebaseDatabase.instance.ref('system');

  void startListening() {
    _isLoading = true;
    notifyListeners();

    // Listen to sensor data
    _sensorRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          _sensorData = SensorData.fromMap(
            event.snapshot.value as Map<dynamic, dynamic>,
          );
        } else {
          _sensorData = SensorData.empty();
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

    // Listen to system status
    _systemRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          _systemStatus = SystemStatus.fromMap(
            event.snapshot.value as Map<dynamic, dynamic>,
          );
        } else {
          _systemStatus = SystemStatus.offline();
        }
        notifyListeners();
      },
      onError: (_) {
        _systemStatus = SystemStatus.offline();
        notifyListeners();
      },
    );
  }
}
