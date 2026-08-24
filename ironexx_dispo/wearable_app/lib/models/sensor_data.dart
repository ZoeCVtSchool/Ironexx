import 'dart:typed_data';

class SensorData {
  final int steps;
  final int heartRate;
  final double calories;
  final DateTime timestamp;

  SensorData({
    required this.steps,
    required this.heartRate,
    required this.calories,
    required this.timestamp,
  });

  // Convert to bytes for BLE transmission
  // Format: [steps(4 bytes), heartRate(2 bytes), calories(4 bytes)]
  List<int> toBytes() {
    final byteData = ByteData(10);
    byteData.setUint32(0, steps, Endian.little);
    byteData.setUint16(4, heartRate, Endian.little);
    byteData.setFloat32(6, calories, Endian.little);
    return byteData.buffer.asUint8List();
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'calories': calories,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
