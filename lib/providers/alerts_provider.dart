import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';

class AlertsProvider extends ChangeNotifier {
  List<AlertModel> _alerts = [];
  bool _isLoading = true;
  String? _error;

  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseReference _ref = FirebaseDatabase.instance.ref('alerts');

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _ref.onValue.listen(
      (event) {
        final raw = event.snapshot.value;
        if (raw != null && raw is Map) {
          final list = <AlertModel>[];
          raw.forEach((key, value) {
            if (value is Map) {
              list.add(AlertModel.fromMap(key.toString(), value));
            }
          });
          // Sort newest first
          list.sort((a, b) => b.time.compareTo(a.time));
          _alerts = list;
        } else {
          _alerts = [];
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

  Future<void> clearAll() async {
    try {
      await _ref.remove();
    } catch (e) {
      _error = 'Failed to clear: $e';
      notifyListeners();
    }
  }
}
