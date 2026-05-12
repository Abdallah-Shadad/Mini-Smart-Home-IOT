import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';
import '../models/history_point.dart';

/// SensorProvider
///
/// 1. Reads /sensor — SensorData.fromMap() maps raw ESP8266 fields automatically.
/// 2. ESP8266 never writes /system → we infer online/offline from update timing.
/// 3. ESP8266 never writes /history → we push a point on every sensor update
///    so the Analytics charts have live data to display.
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
  final DatabaseReference _historyRef =
      FirebaseDatabase.instance.ref('history');

  int _lastReceivedMs = 0;

  void startListening() {
    _isLoading = true;
    notifyListeners();

    // ── /sensor listener ────────────────────────────────────────────
    _sensorRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          _sensorData = SensorData.fromMap(
            event.snapshot.value as Map<dynamic, dynamic>,
          );
        } else {
          _sensorData = SensorData.empty();
        }

        _lastReceivedMs = DateTime.now().millisecondsSinceEpoch;

        // Data arrived → device is online
        _systemStatus = SystemStatus(
          deviceOnline: true,
          lastSeen: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );

        _isLoading = false;
        _error = null;
        notifyListeners();

        // Push a history point so charts update live
        _pushHistoryPoint();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // ── /system listener (future-proof if firmware is updated) ──────
    _systemRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          _systemStatus = SystemStatus.fromMap(
            event.snapshot.value as Map<dynamic, dynamic>,
          );
          notifyListeners();
        }
      },
      onError: (_) {
        // ESP8266 doesn't write /system — silently ignore
      },
    );

    // ── Offline detection every 5 s ─────────────────────────────────
    _startOfflineDetection();
  }

  void _startOfflineDetection() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 5));
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (_lastReceivedMs > 0 && (nowMs - _lastReceivedMs) > 15000) {
        if (_systemStatus.deviceOnline) {
          _systemStatus = SystemStatus(
            deviceOnline: false,
            lastSeen: _systemStatus.lastSeen,
          );
          notifyListeners();
        }
      }
      return true; // keep looping forever
    });
  }

  void _pushHistoryPoint() {
    final point = HistoryPoint(
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      temperature: _sensorData.temperature,
      humidity: _sensorData.humidity,
      light: _sensorData.light,
      gasLevel: _sensorData.gasLevel,
      flameIntensity: _sensorData.flameIntensity,
    );
    _historyRef.push().set(point.toMap()).catchError((_) {
      // Non-critical — ignore failures silently
    });
  }
}
