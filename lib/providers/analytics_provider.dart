import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/history_point.dart';
import '../utils/dummy_data.dart';

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
          // Firebase empty → inject dummy data for demo
          _history = DummyData.generateHistory(hours: 24);
          _usingDummy = true;
        }
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        // Even on error, show dummy data so the demo looks good
        _history = DummyData.generateHistory(hours: 24);
        _usingDummy = true;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }
}
