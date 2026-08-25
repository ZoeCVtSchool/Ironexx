import 'dart:typed_data';

import '../ble_constants.dart';

class SensorData {
  final int temperaturaMotor; // grados C
  final int nivelCombustible; // porcentaje
  final int horometroMin; // minutos simulados de operacion
  final DateTime timestamp;

  SensorData({
    required this.temperaturaMotor,
    required this.nivelCombustible,
    required this.horometroMin,
    required this.timestamp,
  });

  bool get temperaturaCritica => temperaturaMotor > BleConstants.TEMPERATURA_CRITICA;
  bool get combustibleCritico => nivelCombustible < BleConstants.COMBUSTIBLE_CRITICO;
  bool get horometroCritico => horometroMin > BleConstants.HOROMETRO_CRITICO;

  SensorData copyWith({int? temperaturaMotor, int? nivelCombustible, int? horometroMin}) {
    return SensorData(
      temperaturaMotor: temperaturaMotor ?? this.temperaturaMotor,
      nivelCombustible: nivelCombustible ?? this.nivelCombustible,
      horometroMin: horometroMin ?? this.horometroMin,
      timestamp: DateTime.now(),
    );
  }

  static SensorData zero() => SensorData(
        temperaturaMotor: 0,
        nivelCombustible: 0,
        horometroMin: 0,
        timestamp: DateTime.now(),
      );

  // Protocolo BLE: cada caracteristica notifica un Int32 little endian
  // independiente (una caracteristica por metrica, ver ble_constants.dart).
  static int parseInt32LE(List<int> bytes) {
    if (bytes.length < 4) {
      throw Exception('Payload BLE invalido: se esperaban 4 bytes (Int32 LE), llegaron ${bytes.length}');
    }
    return ByteData.sublistView(Uint8List.fromList(bytes)).getInt32(0, Endian.little);
  }

  Map<String, dynamic> toJson() {
    return {
      'temperaturaMotor': temperaturaMotor,
      'nivelCombustible': nivelCombustible,
      'horometroMin': horometroMin,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
