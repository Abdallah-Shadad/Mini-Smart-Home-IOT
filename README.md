<!-- # Mini Smart Home

Flutter + Firebase Realtime Database dashboard for a university IoT mini smart
home project.

## Features

- Real-time sensor monitoring for temperature, humidity, and light.
- Firebase synchronized LED controls and automatic mode.
- Device online/offline status.
- Alerts list with clear action.
- Analytics charts with realistic demo data when `history/` is empty.
- Material 3 light and dark themes.

## Firebase Realtime Database paths

```text
sensor/
control/
alerts/
history/
settings/
system/
```

## Run

```bash
flutter pub get
flutter run
```

Replace the values in `lib/firebase_options.dart` with your Firebase project
configuration, or pass them with `--dart-define` values such as
`FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, and `FIREBASE_DATABASE_URL`. -->
