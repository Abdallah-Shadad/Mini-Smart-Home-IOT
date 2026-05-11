# 🏠 Mini Smart Home

> A university IoT project — real-time home monitoring and control using **NodeMCU ESP8266**, **Firebase Realtime Database**, and a **Flutter** mobile application.

<br>

## 📸 App Preview

| Dashboard | Control | Analytics | Alerts | Settings |
|-----------|---------|-----------|--------|----------|
| Live sensors + safety banners | LED & Buzzer toggles | 5 sensor charts | Alert log | Thresholds & theme |

<br>

## 📋 Table of Contents

- [System Architecture](#-system-architecture)
- [Features](#-features)
- [Hardware Components](#-hardware-components)
- [Wiring & Pin Mapping](#-wiring--pin-mapping)
- [Firebase Structure](#-firebase-realtime-database-structure)
- [Firebase Console Setup](#-firebase-console-setup--step-by-step)
- [Flutter App Setup](#-flutter-app-setup)
- [Project File Structure](#-project-file-structure)
- [Modified Files Reference](#-modified-files-reference)
- [Auto Mode Logic](#-auto-mode-logic)
- [Tech Stack](#-tech-stack)
- [Team](#-team)

---

## 🏗 System Architecture

```
┌────────────────────────────────────────────────┐
│              NodeMCU ESP8266                   │
│                                                │
│  Sensors                Actuators              │
│  ─────────────────      ──────────────────     │
│  DHT11  → Temp/Humid    Red LED    ← Firebase  │
│  LDR    → Light         Green LED  ← Firebase  │
│  MQ2    → Gas/Smoke     Yellow LED ← Firebase  │
│  Flame  → Fire detect   Buzzer     ← Firebase  │
│                                                │
│         WiFi → Firebase Realtime DB            │
└──────────────────────┬─────────────────────────┘
                       │
          ┌────────────▼──────────────┐
          │   Firebase Realtime DB    │
          │   (Google Cloud)          │
          │                           │
          │  /sensor   /control       │
          │  /alerts   /history       │
          │  /settings /system        │
          └────────────┬──────────────┘
                       │
          ┌────────────▼──────────────┐
          │     Flutter Mobile App    │
          │                           │
          │  Dashboard  │  Control    │
          │  Analytics  │  Alerts     │
          │             │  Settings   │
          └───────────────────────────┘
```

---

## ✨ Features

### Dashboard Screen
- **Live sensor readings** — Temperature, Humidity, Light, Gas/Smoke, Flame Intensity
- **Danger banner** — appears instantly when gas exceeds threshold or flame is detected
- **Device status** — Online/Offline indicator with last-seen timestamp
- **Buzzer status** badge — shows whether alarm is armed
- **Auto/Manual mode** badge
- **Recent alerts** preview (latest 3)

### Control Screen
- Toggle **Red, Green, Yellow LEDs** individually
- **Buzzer arm/disarm** — animated card with glowing purple indicator
- **Auto Mode** toggle — when ON, disables manual controls (NodeMCU takes over)
- Live saving indicator while Firebase writes

### Analytics Screen
- **5 interactive charts** powered by `fl_chart`:
  - Temperature (DHT11)
  - Humidity (DHT11)
  - Light Level (LDR)
  - Gas / Smoke Level (MQ2)
  - Flame Intensity (Flame Sensor)
- **Dashed red danger threshold line** on Gas and Flame charts
- Summary metric pills at the top (averages + max flame)
- If Firebase history is empty → **realistic dummy data is injected automatically** so charts are never blank during demo

### Alerts Screen
- Chronological list of all alerts from Firebase
- Color-coded by type: `danger` (red), `warning` (amber), `info` (blue)
- Clear all alerts with confirmation dialog

### Settings Screen
- **Dark / Light mode** toggle (saved locally)
- **Temperature threshold** slider (20–60 °C) — synced to Firebase
- **Gas threshold** slider (10–90 %) — synced to Firebase
- Firebase path reference chips

---

## 🔧 Hardware Components

| Component | Purpose | Quantity |
|-----------|---------|----------|
| NodeMCU ESP8266 | Main microcontroller + WiFi | 1 |
| DHT11 | Temperature & Humidity sensor | 1 |
| LDR (Photoresistor) | Ambient light detection | 1 |
| **MQ2** | Gas / Smoke concentration | 1 |
| **Flame Sensor Module** | Fire / flame detection | 1 |
| Red LED | Warning indicator | 1 |
| Green LED | Normal status indicator | 1 |
| Yellow LED | Ambient / night indicator | 1 |
| **Active Buzzer** | Alarm for gas/flame events | 1 |
| 330Ω Resistors | LED current limiting | 3 |
| 10kΩ Resistor | DHT11 pull-up / LDR divider | 2 |
| Breadboard + Jumper Wires | Prototyping | — |

---

## Wiring & Pin Mapping

```
NodeMCU Pin   Component             Notes
───────────   ─────────────────     ──────────────────────────────────
D2 (GPIO4)  → Buzzer (+)           Active buzzer, GND to GND
D4 (GPIO2)  → DHT11 Data           10kΩ pull-up to 3.3V
D5 (GPIO14) → Red LED anode        330Ω series resistor to GND
D6 (GPIO12) → Green LED anode      330Ω series resistor to GND
D7 (GPIO13) → Yellow LED anode     330Ω series resistor to GND
D8 (GPIO15) → Flame sensor DO      Digital output (HIGH = flame)
A0          → LDR / MQ2 AO         Analog input (0–1023 mapped to %)
3.3V        → DHT11 VCC, Flame VCC, LDR pull-up
5V          → MQ2 VCC              MQ2 heater requires 5V
GND         → All component GNDs
```

### Circuit Notes

- **DHT11**: Place a 10kΩ resistor between the Data pin and 3.3V (pull-up). Many pre-built DHT11 modules already include this.
- **LDR**: Build a voltage divider — LDR from 3.3V to A0, then a 10kΩ resistor from A0 to GND. Higher light = higher voltage.
- **MQ2**: Requires 5V for the internal heating element. Allow 2–3 minutes warm-up time before readings are stable. Analog output goes to A0 through a voltage divider if needed (5V → 3.3V).
- **Flame Sensor**: Digital output (DO) goes HIGH when flame is detected. Analog output (AO) gives intensity — connect to A0 for intensity readings.
- **Buzzer**: Use an **active** buzzer (has internal oscillator). Connect `+` to D2 and `−` to GND.
- **LEDs**: Always use a 330Ω resistor in series to prevent burning out the LED or the GPIO pin.

> ⚠️ **A0 is a shared analog pin.** If you need both MQ2 and Flame analog readings simultaneously, use an **analog multiplexer (CD4051 or similar)** and switch between them in firmware. Alternatively, read them in alternating cycles.

---

## 🗄 Firebase Realtime Database Structure

This is the **complete, final** database structure. Every field the app reads or writes is listed here.

```json
{
  "sensor": {
    "temperature": 28.5,
    "humidity": 62,
    "light": 75,
    "gasLevel": 12,
    "flameDetected": false,
    "flameIntensity": 3,
    "updatedAt": 1710000000
  },

  "control": {
    "redLed": false,
    "greenLed": true,
    "yellowLed": false,
    "autoMode": false,
    "buzzerEnabled": false
  },

  "alerts": {
    "-alert_example_id": {
      "message": "High temperature detected",
      "type": "warning",
      "time": 1710000000
    }
  },

  "system": {
    "deviceOnline": true,
    "lastSeen": 1710000000
  },

  "history": {
    "-history_example_id": {
      "timestamp": 1710000000,
      "temperature": 28.5,
      "humidity": 62,
      "light": 75,
      "gasLevel": 12,
      "flameIntensity": 3
    }
  },

  "settings": {
    "tempThreshold": 35,
    "gasThreshold": 50
  }
}
```

### Field Reference

| Node | Field | Type | Range | Written By | Description |
|------|-------|------|-------|-----------|-------------|
| `sensor` | `temperature` | `float` | 0–50 | NodeMCU | DHT11 temperature in °C |
| `sensor` | `humidity` | `float` | 0–100 | NodeMCU | DHT11 relative humidity % |
| `sensor` | `light` | `float` | 0–100 | NodeMCU | LDR light level % |
| `sensor` | `gasLevel` | `float` | 0–100 | NodeMCU | MQ2 gas/smoke concentration % |
| `sensor` | `flameDetected` | `bool` | — | NodeMCU | `true` when flame sensor triggers |
| `sensor` | `flameIntensity` | `float` | 0–100 | NodeMCU | Flame sensor analog intensity % |
| `sensor` | `updatedAt` | `int` | Unix sec | NodeMCU | Timestamp of last sensor update |
| `control` | `redLed` | `bool` | — | App / NodeMCU | Red LED state |
| `control` | `greenLed` | `bool` | — | App / NodeMCU | Green LED state |
| `control` | `yellowLed` | `bool` | — | App / NodeMCU | Yellow LED state |
| `control` | `autoMode` | `bool` | — | App | Enables hardware automation |
| `control` | `buzzerEnabled` | `bool` | — | App / NodeMCU | Buzzer armed state |
| `alerts` | `{id}/message` | `string` | — | NodeMCU | Alert description text |
| `alerts` | `{id}/type` | `string` | `info` `warning` `danger` | NodeMCU | Alert severity |
| `alerts` | `{id}/time` | `int` | Unix sec | NodeMCU | When the alert occurred |
| `system` | `deviceOnline` | `bool` | — | NodeMCU | Device heartbeat |
| `system` | `lastSeen` | `int` | Unix sec | NodeMCU | Last heartbeat timestamp |
| `history` | `{id}/timestamp` | `int` | Unix sec | NodeMCU | Data point timestamp |
| `history` | `{id}/temperature` | `float` | — | NodeMCU | Historical temperature |
| `history` | `{id}/humidity` | `float` | — | NodeMCU | Historical humidity |
| `history` | `{id}/light` | `float` | — | NodeMCU | Historical light |
| `history` | `{id}/gasLevel` | `float` | — | NodeMCU | Historical gas level |
| `history` | `{id}/flameIntensity` | `float` | — | NodeMCU | Historical flame intensity |
| `settings` | `tempThreshold` | `int` | 20–60 | App | Temperature alert threshold °C |
| `settings` | `gasThreshold` | `int` | 10–90 | App | Gas alert threshold % |

---

## 🔥 Firebase Console Setup — Step by Step

### Step 1 — Create a Firebase Project

1. Go to **[https://console.firebase.google.com](https://console.firebase.google.com)**
2. Click **"Add project"**
3. Enter a name (e.g. `mini-smart-home`) → Click **Continue**
4. Disable Google Analytics (not needed) → Click **Continue**
5. Click **"Create project"** → Wait ~30 seconds → Click **"Continue"**

---

### Step 2 — Enable Realtime Database

1. In the left sidebar → **Build** → **Realtime Database**
2. Click **"Create Database"**
3. Choose your server location (pick the closest region to you)
4. On the security rules prompt → select **"Start in test mode"** → Click **"Enable"**

---

### Step 3 — Set Database Security Rules

1. In the Realtime Database page → click the **"Rules"** tab
2. Replace the entire content with:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

3. Click **"Publish"**

> ⚠️ These open rules are for university demo purposes only. Never use them in a production application.

---

### Step 4 — Import the Initial Database Structure

1. In the Realtime Database → **"Data"** tab
2. Click the **three-dot menu (⋮)** in the top-right corner of the data panel
3. Click **"Import JSON"**
4. Create a file named `initial_db.json` on your computer with this content:

```json
{
  "sensor": {
    "temperature": 28,
    "humidity": 60,
    "light": 70,
    "gasLevel": 10,
    "flameDetected": false,
    "flameIntensity": 0,
    "updatedAt": 1710000000
  },
  "control": {
    "redLed": false,
    "greenLed": false,
    "yellowLed": false,
    "autoMode": false,
    "buzzerEnabled": false
  },
  "alerts": {},
  "system": {
    "deviceOnline": true,
    "lastSeen": 1710000000
  },
  "history": {},
  "settings": {
    "tempThreshold": 35,
    "gasThreshold": 50
  }
}
```

5. Click **"Browse"** → select your `initial_db.json` file → Click **"Import"**

> ✅ You should now see all nodes appear in the Data tab.

---

### Step 5 — Register Your Android App

1. On the Firebase project home page → click the **Android icon** (robot head `</>`)
2. In **"Android package name"** enter exactly: `com.example.minismarthome`
3. (Optional) Add a nickname like `Mini Smart Home`
4. Click **"Register app"**
5. Click **"Download google-services.json"**
6. Copy the downloaded file into your project at this exact path:
   ```
   android/app/google-services.json
   ```
   Replace the existing file if there is one already.
7. Click **"Next"** → **"Next"** → **"Continue to console"**

---

### Step 6 — (Optional) Register Your iOS App

1. On the project home → **"Add app"** → click the **iOS icon**
2. **iOS bundle ID**: `com.example.minismarthome`
3. Click **"Register app"**
4. Download `GoogleService-Info.plist`
5. Place it at: `ios/Runner/GoogleService-Info.plist`
6. Click through the remaining steps

---

### Step 7 — Find Your Database URL

1. In **Realtime Database** → **Data** tab
2. At the top you will see a URL like:
   ```
   https://mini-smart-home-xxxxx-default-rtdb.firebaseio.com
   ```
3. Open `lib/firebase_options.dart` in your project
4. Make sure `databaseURL` in all platform sections matches your URL

> If you used the original project's `google-services.json`, the URL is already configured. Only update this if you created a brand new Firebase project.

---

### Step 8 — Test the Live Connection

1. Run the app: `flutter run`
2. Open Firebase Console → Realtime Database → Data tab
3. Manually click on `sensor` → `temperature` → change the value to `40`
4. Press Enter to save
5. Watch the Dashboard screen update **instantly** — no page refresh needed

---

## 📱 Flutter App Setup

### Prerequisites

Make sure you have the following installed:

- **Flutter SDK** — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with the Flutter & Dart extensions
- **Android Emulator** or a physical Android/iOS device

Verify your setup is working:

```bash
flutter doctor
```

All checkmarks should be green (or at least the Android/iOS target you plan to use).

---

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/mini-smart-home.git
cd mini-smart-home

# 2. Install all Flutter dependencies
flutter pub get

# 3. Verify the firebase_options.dart has your database URL
#    Open lib/firebase_options.dart and check the databaseURL field

# 4. Run the app
flutter run
```

---

### Running on Specific Platforms

```bash
# Android (emulator or USB device)
flutter run -d android

# iOS (Mac only, requires Xcode)
flutter run -d ios

# List all available devices
flutter devices
```

---

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

---

## 📁 Project File Structure

```
mini_smart_home/
│
├── lib/
│   ├── main.dart                        # App entry point, Firebase init
│   │
│   ├── firebase_options.dart            # Auto-generated Firebase config
│   │
│   ├── theme/
│   │   └── app_theme.dart               # Colors, dark/light themes
│   │
│   ├── models/                          # Pure Dart data classes
│   │   ├── sensor_data.dart             # Temp, humid, light, gas, flame
│   │   ├── control_state.dart           # LEDs + autoMode + buzzer
│   │   ├── alert_model.dart             # Alert messages
│   │   ├── history_point.dart           # Chart data point
│   │   └── system_status.dart           # Online/offline + lastSeen
│   │
│   ├── providers/                       # State management (ChangeNotifier)
│   │   ├── sensor_provider.dart         # Listens to /sensor and /system
│   │   ├── control_provider.dart        # Listens + writes to /control
│   │   ├── alerts_provider.dart         # Listens to /alerts
│   │   ├── analytics_provider.dart      # Listens to /history
│   │   └── settings_provider.dart       # Listens to /settings + SharedPrefs
│   │
│   ├── screens/
│   │   ├── splash_screen.dart           # Loading + Firebase listeners init
│   │   ├── home_screen.dart             # Bottom nav shell
│   │   ├── dashboard_screen.dart        # Live sensors + danger banner
│   │   ├── control_screen.dart          # LEDs + Buzzer + Auto Mode
│   │   ├── alerts_screen.dart           # Alert log list
│   │   ├── analytics_screen.dart        # 5 sensor charts
│   │   └── settings_screen.dart         # Theme + thresholds
│   │
│   ├── widgets/                         # Reusable UI components
│   │   ├── sensor_card.dart             # Metric card with progress bar
│   │   ├── led_control_tile.dart        # LED toggle row
│   │   ├── alert_tile.dart              # Single alert row
│   │   ├── custom_app_bar.dart          # AppBar with subtitle
│   │   ├── status_badge.dart            # Colored pill badge
│   │   ├── section_header.dart          # Section title row
│   │   ├── loading_view.dart            # Spinner + error view
│   │   └── empty_state.dart             # Empty list placeholder
│   │
│   └── utils/
│       ├── dummy_data.dart              # Demo time-series generator
│       └── formatters.dart             # Date, time, unit formatters
│
├── android/
│   └── app/
│       ├── google-services.json         # ← Your Firebase config file
│       └── build.gradle.kts
│
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist     # ← iOS Firebase config (if used)
│
├── pubspec.yaml                         # Dependencies
└── README.md
```

---

## Modified Files Reference

The following files were updated when **MQ2**, **Flame Sensor**, and **Buzzer** were added to the original DHT11 + LDR design:

| File | What Was Added |
|------|----------------|
| `lib/models/sensor_data.dart` | `gasLevel`, `flameDetected`, `flameIntensity` fields |
| `lib/models/control_state.dart` | `buzzerEnabled` field |
| `lib/models/history_point.dart` | `gasLevel`, `flameIntensity` for chart history |
| `lib/utils/dummy_data.dart` | Realistic gas spikes and evening flame simulation |
| `lib/theme/app_theme.dart` | `gasColor` (amber), `flameColor` (orange-red), `buzzerColor` (purple) |
| `lib/providers/control_provider.dart` | `setBuzzerEnabled()` Firebase write method |
| `lib/providers/settings_provider.dart` | `gasThreshold` + `setGasThreshold()` |
| `lib/screens/dashboard_screen.dart` | Safety Sensors grid, danger banner, buzzer status badge |
| `lib/screens/control_screen.dart` | Buzzer card with animated armed/disarmed UI |
| `lib/screens/analytics_screen.dart` | Gas and Flame charts with dashed danger threshold lines |
| `lib/screens/settings_screen.dart` | Gas threshold slider, refactored `_ThresholdCard` widget |

**Files that did NOT need changes** — `main.dart`, `SensorProvider`, `AlertsProvider`, `AnalyticsProvider`, all widgets, native Android/iOS files.

---

## Auto Mode Logic

When `control/autoMode` is `true`, the **NodeMCU firmware** reads thresholds from Firebase and applies this logic:

| Sensor Condition | Action | Alert Written |
|-----------------|--------|---------------|
| `temperature > settings/tempThreshold` | Turn ON Red LED | `type: "warning"` |
| `gasLevel > settings/gasThreshold` | Turn ON Buzzer | `type: "danger"` |
| `flameDetected == true` | Turn ON Buzzer + Red LED | `type: "danger"` |
| `light < 20 %` (nighttime) | Turn ON Yellow LED | — |
| All clear | Turn ON Green LED, turn OFF Buzzer | — |

The app reads the same thresholds from `settings/tempThreshold` and `settings/gasThreshold`, so both the phone and the hardware are always in sync without any hardcoded values.

---

## Dependencies

```yaml
dependencies:
  firebase_core: ^2.27.1       # Firebase initialization
  firebase_database: ^10.5.6   # Realtime Database listener + writes
  provider: ^6.1.2             # State management
  fl_chart: ^0.68.0            # Interactive sensor charts
  intl: ^0.19.0                # Date/time formatting
  shared_preferences: ^2.2.3   # Local dark mode preference
  cupertino_icons: ^1.0.6      # iOS-style icons
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Microcontroller | NodeMCU ESP8266 |
| Firmware | Arduino C++ (ESP8266 core) |
| Cloud Database | Firebase Realtime Database |
| Mobile Framework | Flutter 3.x (Dart) |
| State Management | Provider (ChangeNotifier) |
| Charts | fl_chart |
| UI Design | Material 3 — dark/light with custom teal palette |

---

## 👥 Team

Developed as a university IoT project demonstrating the full integration of:

- **Embedded Systems** — NodeMCU sensor reading and actuator control
- **Cloud Computing** — Firebase real-time data sync across all clients
- **Mobile Development** — Flutter cross-platform UI with live database listeners

---

## 📄 License

This project is for educational purposes. Feel free to use, modify, and build on it for your own university projects.
