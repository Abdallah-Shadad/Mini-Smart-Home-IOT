import '../models/history_point.dart';
import '../utils/dummy_data.dart';
import 'firebase_service.dart';

class HistoryService {
  HistoryService({FirebaseService? firebase})
      : _firebase = firebase ?? FirebaseService.instance;

  final FirebaseService _firebase;

  Stream<List<HistoryPoint>> watchHistory({int limit = 50}) {
    return _firebase.historyRef.limitToLast(limit).onValue.map((event) {
      final raw = event.snapshot.value;
      final points = <HistoryPoint>[];

      if (raw is Map<dynamic, dynamic>) {
        raw.forEach((_, value) {
          if (value is Map<dynamic, dynamic>) {
            points.add(HistoryPoint.fromMap(value));
          }
        });
      }

      if (points.isEmpty) {
        return DummyData.generateHistory(hours: 24);
      }

      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return points;
    });
  }

  Future<void> addPoint(HistoryPoint point) {
    return _firebase.historyRef.push().set(point.toMap());
  }
}
