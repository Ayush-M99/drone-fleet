class DroneAlert {
  final int? id;
  final int droneId;
  final String alertType;
  final String message;
  final String timestamp;

  DroneAlert({
    this.id,
    required this.droneId,
    required this.alertType,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'droneId': droneId,
      'alertType': alertType,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory DroneAlert.fromMap(Map<String, dynamic> map) {
    return DroneAlert(
      id: map['id'] as int?,
      droneId: map['droneId'] as int,
      alertType: map['alertType'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
