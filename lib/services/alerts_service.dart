import '../models/alert_model.dart';
import 'firebase_service.dart';

class AlertsService {
  AlertsService({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService.instance;

  final FirebaseService _firebase;

  Stream<List<AlertModel>> watchAlerts() {
    return _firebase.alertsRef.onValue.map((event) {
      final raw = event.snapshot.value;
      final alerts = <AlertModel>[];

      if (raw is Map<dynamic, dynamic>) {
        raw.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            alerts.add(AlertModel.fromMap(key.toString(), value));
          }
        });
      }

      alerts.sort((a, b) => b.time.compareTo(a.time));
      return alerts;
    });
  }

  Future<void> addAlert({
    required String message,
    String type = 'info',
  }) {
    final alert = AlertModel(
      id: '',
      message: message,
      type: type,
      time: _firebase.nowSeconds(),
    );
    return _firebase.alertsRef.push().set(alert.toMap());
  }

  Future<void> clearAll() => _firebase.alertsRef.remove();
}
