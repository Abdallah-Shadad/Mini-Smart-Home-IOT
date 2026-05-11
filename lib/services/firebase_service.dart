import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get sensorRef => _database.ref('sensor');
  DatabaseReference get controlRef => _database.ref('control');
  DatabaseReference get alertsRef => _database.ref('alerts');
  DatabaseReference get historyRef => _database.ref('history');
  DatabaseReference get settingsRef => _database.ref('settings');
  DatabaseReference get systemRef => _database.ref('system');

  int nowSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
