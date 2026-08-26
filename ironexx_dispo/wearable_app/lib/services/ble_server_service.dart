import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble_constants.dart';

/// GATT Server real del wearable (rol periferico/servidor).
///
/// flutter_blue_plus solo implementa el rol cliente/central, por eso el
/// servidor usa `ble_peripheral`. Registra el servicio y sus 3 caracteristicas
/// ANTES de iniciar el advertising (requisito de la guia, seccion 6.2), y
/// notifica usando la misma instancia de caracteristica ya registrada
/// (BlePeripheral.updateCharacteristic referencia por characteristicId).
class BleServerService {
  bool _isReady = false;
  bool _isAdvertising = false;

  bool get isAdvertising => _isAdvertising;

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startServer() async {
    if (_isAdvertising) return;

    final granted = await requestPermissions();
    if (!granted) {
      throw Exception(
        'Permisos de Bluetooth denegados (Advertise/Connect). '
        'Actívalos en Ajustes > Apps > Ironexx Wearable > Permisos.',
      );
    }

    if (!_isReady) {
      await BlePeripheral.initialize();
      // Confirma con el callback nativo si el advertising realmente arranco
      // (en vez de asumirlo apenas resuelve el Future), igual que el
      // proyecto de referencia -- startAdvertising() puede resolver sin
      // error aunque el advertising real haya fallado en el lado nativo.
      BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {
        _isAdvertising = advertising;
      });
      await BlePeripheral.addService(
        BleService(
          uuid: BleConstants.SERVICE_UUID,
          primary: true,
          characteristics: [
            _notifyCharacteristic(BleConstants.TEMPERATURA_CHARACTERISTIC_UUID),
            _notifyCharacteristic(BleConstants.COMBUSTIBLE_CHARACTERISTIC_UUID),
            _notifyCharacteristic(BleConstants.HOROMETRO_CHARACTERISTIC_UUID),
          ],
        ),
      );
      _isReady = true;
    }

    // Sin localName: junto con un service UUID de 128 bits supera el limite
    // de 31 bytes del advertising BLE legacy y el advertising falla en
    // silencio. El cliente ya filtra por SERVICE_UUID, no por nombre.
    await BlePeripheral.startAdvertising(services: [BleConstants.SERVICE_UUID]);
  }

  Future<void> stopServer() async {
    if (!_isAdvertising) return;
    await BlePeripheral.stopAdvertising();
    _isAdvertising = false;
  }

  Future<void> notifyTemperatura(int gradosC) =>
      _notifyInt32(BleConstants.TEMPERATURA_CHARACTERISTIC_UUID, gradosC);

  Future<void> notifyCombustible(int porcentaje) =>
      _notifyInt32(BleConstants.COMBUSTIBLE_CHARACTERISTIC_UUID, porcentaje);

  Future<void> notifyHorometro(int minutos) =>
      _notifyInt32(BleConstants.HOROMETRO_CHARACTERISTIC_UUID, minutos);

  Future<void> _notifyInt32(String characteristicId, int value) async {
    if (!_isAdvertising) return;
    // Protocolo: Int32 little endian para las 3 caracteristicas.
    final bytes = ByteData(4)..setInt32(0, value, Endian.little);
    await BlePeripheral.updateCharacteristic(
      characteristicId: characteristicId,
      value: bytes.buffer.asUint8List(),
    );
  }

  // Sin descriptor CCCD explicito: el paquete ble_peripheral lo gestiona
  // automaticamente para caracteristicas NOTIFY (igual que en el proyecto
  // de referencia, ble_server.dart). Agregarlo a mano puede duplicar/
  // corromper la estructura del servicio GATT sin que el error se note en
  // el status=0 del log de addService().
  BleCharacteristic _notifyCharacteristic(String uuid) {
    return BleCharacteristic(
      uuid: uuid,
      properties: [
        CharacteristicProperties.read.index,
        CharacteristicProperties.notify.index,
      ],
      permissions: [AttributePermissions.readable.index],
      value: null,
    );
  }

  void dispose() {
    unawaited(stopServer());
  }
}
