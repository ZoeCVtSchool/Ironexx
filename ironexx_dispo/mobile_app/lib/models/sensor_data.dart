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

  factory SensorData.fromBytes(List<int> bytes) {
    // Parse bytes: [steps(4 bytes), heartRate(2 bytes), calories(4 bytes)]
    final steps = ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.little);
    final heartRate = ByteData.sublistView(Uint8List.fromList(bytes)).getUint16(4, Endian.little);
    final calories = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(6, Endian.little);
    
    return SensorData(
      steps: steps,
      heartRate: heartRate,
      calories: calories,
      timestamp: DateTime.now(),
    );
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
