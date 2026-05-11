# Mini Smart Home IOT

A comprehensive, end-to-end Internet of Things (IoT) solution for real-time home monitoring and automation. This project integrates hardware sensors with a cloud backend and a mobile application to provide a seamless smart home experience.

---

## Overview

The Mini Smart Home system allows users to monitor environmental conditions (Temperature, Humidity, and Light) and control home appliances (represented by LEDs) remotely. It features an intelligent "Auto-Mode" that makes local decisions based on sensor thresholds and synchronizes everything in real-time across a mobile dashboard.

## Key Features

- **Real-time Monitoring:** Live tracking of Temperature, Humidity, and Light intensity.
- **Remote Control:** Toggle Red, Green, and Yellow LEDs directly from the application.
- **Intelligent Auto-Mode:** Automated hardware logic that reacts to environmental changes without manual intervention.
- **Smart Alerts:** Instant notifications and logging for critical conditions, such as high temperature or low light levels.
- **Data Analytics:** Visual representation of historical sensor data using interactive charts.
- **System Health:** Real-time status indicator showing whether the IoT edge device is online or offline.

---

## Tech Stack

### Hardware (Edge Layer)
- **Microcontroller:** NodeMCU (ESP8266) - The primary processing unit.
- **Sensors:** - DHT11 (Temperature & Humidity).
  - LDR (Photoresistor for Light Detection).
- **Actuators:** 3x LEDs (Red, Green, Yellow) representing smart appliances or status indicators.
- **Communication:** Built-in WiFi module for cloud connectivity.

### Backend (Cloud Layer)
- **Firebase Realtime Database:** Low-latency NoSQL database for instant state synchronization between the hardware and the mobile application.

### Mobile App (Interface Layer)
- **Framework:** Flutter (Cross-platform UI toolkit).
- **State Management:** Provider pattern for clean, predictable, and efficient data flow.
- **Visualization:** `fl_chart` for professional-grade analytics and historical data rendering.

---

## Hardware Setup & Pin Mapping

The system follows a specific wiring architecture to ensure stability and precise analog/digital readings.

| Component | NodeMCU Pin | Description |
| :--- | :--- | :--- |
| **DHT11 Data** | **D4** (GPIO2) | Digital Environmental Data |
| **LDR (Analog)** | **A0** | Analog Light Intensity Level |
| **Red LED** | **D5** | Warning / Heating Indicator |
| **Green LED** | **D6** | Normal Status Indicator |
| **Yellow LED** | **D7** | Ambient Lighting Indicator |

> **Note:** A 10K Ohm pull-up resistor is recommended for the DHT11 data line (if not using a pre-configured module). A 10K Ohm resistor must be used in the LDR voltage divider circuit. Each LED must be protected by a 330 Ohm series resistor.

---

## Firebase Data Structure

The database is structured to support efficient real-time updates and historical tracking without excessive nested queries.

```json
{
  "sensor": {
    "temperature": 25.5,
    "humidity": 60,
    "light": 450,
    "updatedAt": 1710000000
  },
  "control": {
    "redLed": false,
    "greenLed": true,
    "yellowLed": false,
    "autoMode": false
  },
  "alerts": {
    "id_1": {
      "message": "High Temp Detected",
      "type": "temp",
      "time": 1710000000
    }
  },
  "system": {
    "deviceOnline": true,
    "lastSeen": 1710000000
  }
}

```

---

## App Architecture

The Flutter application strictly follows a clean, modular architecture to ensure maintainability and scalability:

* **Providers:** Handle real-time listeners, state mutations, and business logic (e.g., `SensorProvider`, `ControlProvider`).
* **Services:** Manage direct API communication and data parsing with the Firebase backend.
* **Models:** Strongly typed Dart classes (`SensorData`, `SystemStatus`) to ensure type safety.
* **Widgets:** Reusable, stateless UI components designed for a consistent design language.

---

## Installation & Setup

### 1. Hardware Configuration

1. Flash the NodeMCU with the provided Arduino `C++` code.
2. Update the `WIFI_SSID` and `WIFI_PASSWORD` macros in the source code.
3. Update the Firebase host URL and authentication secret to point to your specific Firebase instance.

### 2. Mobile Application

1. Ensure the Flutter SDK is installed and configured on your machine.
2. Clone the repository and navigate to the project root directory.
3. Run `flutter pub get` to install all required dependencies.
4. Configure Firebase for Android/iOS using the FlutterFire CLI or by manually placing the `google-services.json` / `GoogleService-Info.plist` files in their respective directories.
5. Execute `flutter run` to build and launch the application on your target emulator or physical device.

---

## Project Developers

Developed as a comprehensive University IoT Project to demonstrate the practical integration of Embedded Systems, Cloud Computing, and Mobile Application Development.
