# Drone Fleet Dashboard

A Flutter-based fleet monitoring dashboard for tracking multiple drones, simulating live telemetry, reviewing alerts, and exploring analytics in a polished control-room style interface.

## Overview

This project models a small autonomous drone fleet and presents it through a multi-screen dashboard experience. It includes seeded sample drones, persistent local storage, simulated status changes, and visual monitoring tools for operators.

The app is built as a cross-platform Flutter application and currently includes support for Android, iOS, Web, Windows, Linux, and macOS.

## Features

- Fleet dashboard with live drone cards and quick status counts
- Real-time telemetry simulation for battery, signal, altitude, and GPS drift
- Add, edit, and remove drones from the fleet
- Alert generation for low-battery events
- Interactive live map using OpenStreetMap tiles
- Analytics screen with battery charts, altitude history, and fleet composition
- Local persistence using SQLite so fleet data survives app restarts
- Seeded demo data for immediate exploration

## Screens

- `Fleet`: overview of all drones with simulation controls
- `Map`: live marker-based map with status legend and drone detail overlay
- `Alerts`: operational alerts raised during simulation
- `Analytics`: charts and summary metrics for fleet health
- `Drone Detail`: deeper telemetry and mission view for an individual drone

## Tech Stack

- `Flutter`
- `Provider` for state management
- `sqflite` and `sqflite_common_ffi` for local database support
- `fl_chart` for analytics visualizations
- `flutter_map` and `latlong2` for mapping

## Project Structure

```text
lib/
  database/     SQLite helper and persistence logic
  models/       Drone and alert models
  providers/    App state and telemetry simulation
  screens/      Main UI screens
  theme/        Colors and app styling
  widgets/      Reusable UI components
paper/          IEEE paper source and figures
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK included with Flutter
- A device, emulator, browser, or desktop target enabled for Flutter

Verify your environment:

```bash
flutter doctor
```

### Installation

```bash
git clone https://github.com/Ayush-M99/drone-fleet.git
cd drone-fleet
flutter pub get
```

### Run the App

For Chrome:

```bash
flutter run -d chrome
```

For Windows:

```bash
flutter run -d windows
```

For Android:

```bash
flutter run -d android
```

## How the Simulation Works

- The app seeds an initial fleet if the local database is empty.
- A timer updates active telemetry every 3 seconds.
- Battery drains during normal missions and recharges while charging.
- Drone coordinates drift slightly to mimic motion.
- Signal strength and altitude vary within safe bounds.
- Low-battery thresholds trigger alerts and critical status updates.

## Demo Data

The app starts with a preloaded sample fleet including drones such as:

- `Alpha-01`
- `Beta-02`
- `Gamma-03`
- `Delta-04`
- `Echo-05`

These seeded entries make it easy to test the dashboard, alerts, analytics, and map experience without manual setup.

## Research Paper

The repository also includes an IEEE-style paper source in [`paper/`](paper/) documenting the project. See [`paper/README.md`](paper/README.md) for compilation notes and asset requirements.

## Notes

- Map tiles are loaded from OpenStreetMap.
- Data is stored locally on the device using SQLite.
- This repository currently focuses on simulated fleet operations rather than live hardware integration.

## Future Improvements

- Real drone telemetry ingestion over MQTT or WebSockets
- Authentication and operator roles
- Mission planning workflows
- Geofencing and route replay
- Cloud sync and fleet-wide collaboration

## License

No license has been specified yet. Add a license file if you plan to distribute or reuse the project publicly.
