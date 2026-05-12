import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';

/// AlertsProvider
///
/// ESP8266 writes /alerts as a plain string: "Safe", "Fire Detected!", "Gas Leak!"
/// This provider handles that AND the object-map format.
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

        if (raw == null) {
          _alerts = [];
        } else if (raw is String) {
          // ── ESP8266 plain string ─────────────────────────────────
          final lower = raw.toLowerCase().trim();
          if (lower == 'safe' || lower == 'ok' || lower.isEmpty) {
            _alerts = [];
          } else {
            _alerts = [AlertModel.fromString(raw)];
          }
        } else if (raw is Map) {
          // ── Object map of alerts ─────────────────────────────────
          final list = <AlertModel>[];
          raw.forEach((key, value) {
            if (value is Map) {
              list.add(AlertModel.fromMap(key.toString(), value));
            }
          });
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
