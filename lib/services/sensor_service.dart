import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';
import 'firebase_service.dart';

class SensorService {
  SensorService({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService.instance;

  final FirebaseService _firebase;

  Stream<SensorData> watchSensorData() {
    return _firebase.sensorRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        return SensorData.fromMap(value);
      }
      return SensorData.empty();
    });
  }

  Stream<SystemStatus> watchSystemStatus() {
    return _firebase.systemRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        return SystemStatus.fromMap(value);
      }
      return SystemStatus.offline();
    });
  }

  Future<DataSnapshot> getSensorSnapshot() => _firebase.sensorRef.get();
}
