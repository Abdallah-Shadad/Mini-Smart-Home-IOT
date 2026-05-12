import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/history_point.dart';
import '../utils/dummy_data.dart';

/// AnalyticsProvider
///
/// Listens to /history limitToLast(50) in realtime.
/// SensorProvider writes a new point every time ESP8266 sends data.
/// If /history is empty → show dummy data so charts are never blank.
class AnalyticsProvider extends ChangeNotifier {
  List<HistoryPoint> _history = [];
  bool _isLoading = true;
  String? _error;
  bool _usingDummy = false;

  List<HistoryPoint> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usingDummy => _usingDummy;

  final DatabaseReference _ref = FirebaseDatabase.instance.ref('history');

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _ref.limitToLast(50).onValue.listen(
      (event) {
        final raw = event.snapshot.value;

        if (raw != null && raw is Map && raw.isNotEmpty) {
          final list = <HistoryPoint>[];
          raw.forEach((key, value) {
            if (value is Map) {
              list.add(HistoryPoint.fromMap(value));
            }
          });
          list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _history = list;
          _usingDummy = false;
        } else {
          _history = DummyData.generateHistory(hours: 24);
          _usingDummy = true;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _history = DummyData.generateHistory(hours: 24);
        _usingDummy = true;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }
}
