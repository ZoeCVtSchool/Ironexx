// BLE Service and Characteristic UUIDs for Ironexx Ecosystem
//
// UUIDs custom de 128 bits (no usar UUIDs reservados del Bluetooth SIG como
// 0x180A/0x2A7D: colisionan con servicios reales del stack del sistema).
// Este archivo debe ser IDENTICO al de wearable_app/lib/ble_constants.dart.
//
// Metricas del wearable: monitoreo de la maquina que opera el tecnico
// (temperatura de motor, nivel de combustible, horometro), acorde al
// dominio del proyecto (venta/administracion de maquinaria pesada).
class BleConstants {
  // Service UUID
  static const String SERVICE_UUID = 'e2bca587-9a7c-419f-bc59-975f76d22b75';

  // Characteristic UUIDs (una por metrica, cada una NOTIFY, payload Int32 little endian)
  static const String TEMPERATURA_CHARACTERISTIC_UUID = 'de952db7-c3e7-4d5d-b529-dd33bddedaf0';
  static const String COMBUSTIBLE_CHARACTERISTIC_UUID = '27d5880c-69bc-4560-9786-d9eeb421e473';
  static const String HOROMETRO_CHARACTERISTIC_UUID = '21eb1556-c1c4-4c1f-8bc4-aea8263f2afb';

  // Device name (el scan filtra por SERVICE_UUID, no por nombre)
  static const String DEVICE_NAME = 'Ironexx Wearable';

  // Umbrales criticos (deben coincidir con wearable_app/lib/ble_constants.dart)
  static const int TEMPERATURA_CRITICA = 100; // grados C
  static const int COMBUSTIBLE_CRITICO = 15; // porcentaje
  static const int HOROMETRO_CRITICO = 60; // minutos simulados de operacion
}
