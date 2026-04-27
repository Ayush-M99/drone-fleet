class Drone {
  final int? id;
  final String name;
  final String droneType;
  double batteryLevel;
  int signalStrength;
  double latitude;
  double longitude;
  double altitude;
  String status;
  String missionStatus;
  final String createdAt;
  bool _alertFired = false;

  Drone({
    this.id,
    required this.name,
    required this.droneType,
    required this.batteryLevel,
    required this.signalStrength,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.status,
    required this.missionStatus,
    required this.createdAt,
    bool alertFired = false,
  }) : _alertFired = alertFired;

  bool get alertFired => _alertFired;
  set alertFired(bool value) => _alertFired = value;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'droneType': droneType,
      'batteryLevel': batteryLevel,
      'signalStrength': signalStrength,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'status': status,
      'missionStatus': missionStatus,
      'createdAt': createdAt,
    };
  }

  factory Drone.fromMap(Map<String, dynamic> map) {
    return Drone(
      id: map['id'] as int?,
      name: map['name'] as String,
      droneType: map['droneType'] as String,
      batteryLevel: (map['batteryLevel'] as num).toDouble(),
      signalStrength: map['signalStrength'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: (map['altitude'] as num).toDouble(),
      status: map['status'] as String,
      missionStatus: map['missionStatus'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  Drone copyWith({
    int? id,
    String? name,
    String? droneType,
    double? batteryLevel,
    int? signalStrength,
    double? latitude,
    double? longitude,
    double? altitude,
    String? status,
    String? missionStatus,
    String? createdAt,
  }) {
    return Drone(
      id: id ?? this.id,
      name: name ?? this.name,
      droneType: droneType ?? this.droneType,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalStrength: signalStrength ?? this.signalStrength,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      status: status ?? this.status,
      missionStatus: missionStatus ?? this.missionStatus,
      createdAt: createdAt ?? this.createdAt,
      alertFired: _alertFired,
    );
  }
}
