import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble_constants.dart';
import '../models/sensor_data.dart';
import '../providers/notification_provider.dart';

class BleService {
  final NotificationProvider notificationProvider;

  StreamSubscription<dynamic>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  final List<StreamSubscription<List<int>>> _characteristicSubscriptions = [];
  Timer? _scanTimeout;
  BluetoothDevice? _connectedDevice;

  // Evita disparar un segundo scan/connect mientras ya hay uno en curso
  // (requisito E2 punto 17: "Evitar conexiones duplicadas").
  bool _isConnecting = false;
  SensorData _lastData = SensorData.zero();

  BleService({required this.notificationProvider});

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan() async {
    if (_isConnecting || _connectedDevice != null) {
      // Ya hay una conexion en curso o activa: no iniciar otro scan.
      return;
    }

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        notificationProvider.setError('Bluetooth solo está disponible en Android/iOS.');
        return;
      }

      final granted = await _requestPermissions();
      if (!granted) {
        notificationProvider.setError('Permisos de Bluetooth/ubicación denegados.');
        return;
      }

      _isConnecting = true;
      _scanTimeout?.cancel();
      await _scanSubscription?.cancel();
      notificationProvider.setScanning();

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (_connectedDevice != null) return;
        for (final result in results) {
          final serviceUuids = result.advertisementData.serviceUuids
              .map((g) => g.toString().toLowerCase())
              .toList();
          if (serviceUuids.contains(BleConstants.SERVICE_UUID.toLowerCase())) {
            unawaited(connectToDevice(result.device));
            return;
          }
        }
      });

      _scanTimeout = Timer(const Duration(seconds: 12), () {
        if (_connectedDevice == null) {
          FlutterBluePlus.stopScan();
          _isConnecting = false;
          notificationProvider.setError('No se encontró el wearable (SERVICE_UUID no anunciado).');
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        withServices: [Guid(BleConstants.SERVICE_UUID)],
      );
    } catch (e) {
      _isConnecting = false;
      notificationProvider.setError('Error al escanear BLE: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null) return; // ya conectado, evita duplicados
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanTimeout?.cancel();

      notificationProvider.setScanning();
      _connectedDevice = device;

      await device.connect(timeout: const Duration(seconds: 15));

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnected();
        }
      });

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == BleConstants.SERVICE_UUID.toLowerCase(),
        orElse: () => throw Exception('Servicio BLE no encontrado'),
      );

      await _subscribeCharacteristic(
        service,
        BleConstants.TEMPERATURA_CHARACTERISTIC_UUID,
        (value) => _lastData = _lastData.copyWith(temperaturaMotor: value),
      );
      await _subscribeCharacteristic(
        service,
        BleConstants.COMBUSTIBLE_CHARACTERISTIC_UUID,
        (value) => _lastData = _lastData.copyWith(nivelCombustible: value),
      );
      await _subscribeCharacteristic(
        service,
        BleConstants.HOROMETRO_CHARACTERISTIC_UUID,
        (value) => _lastData = _lastData.copyWith(horometroMin: value),
      );

      _isConnecting = false;
      notificationProvider.setConnected(true);
    } catch (e) {
      _isConnecting = false;
      _connectedDevice = null;
      notificationProvider.setError('Error al conectar por BLE: $e');
    }
  }

  Future<void> _subscribeCharacteristic(
    BluetoothService service,
    String characteristicUuid,
    void Function(int value) onValue,
  ) async {
    final characteristic = service.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase(),
      orElse: () => throw Exception('Característica BLE no encontrada: $characteristicUuid'),
    );

    await characteristic.setNotifyValue(true); // habilita NOTIFY + escribe CCCD

    final sub = characteristic.lastValueStream.listen((bytes) {
      if (bytes.isEmpty) return;
      try {
        final value = SensorData.parseInt32LE(bytes);
        onValue(value);
        notificationProvider.updateSensorData(_lastData);
      } catch (_) {
        // Payload malformado: se ignora ese NOTIFY, no se rompe la conexion.
      }
    });
    _characteristicSubscriptions.add(sub);
  }

  void _handleDisconnected() {
    for (final sub in _characteristicSubscriptions) {
      sub.cancel();
    }
    _characteristicSubscriptions.clear();
    _connectionSubscription?.cancel();
    _connectedDevice = null;
    _isConnecting = false;
    notificationProvider.setConnected(false);
  }

  Future<void> disconnect() async {
    final device = _connectedDevice;
    _handleDisconnected();
    await device?.disconnect();
  }

  void dispose() {
    for (final sub in _characteristicSubscriptions) {
      sub.cancel();
    }
    _connectionSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanTimeout?.cancel();
    _connectedDevice?.disconnect();
  }
}
