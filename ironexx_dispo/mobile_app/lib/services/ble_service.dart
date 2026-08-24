import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble_constants.dart';
import '../models/notification_data.dart';
import '../providers/notification_provider.dart';

class BleService {
  final NotificationProvider notificationProvider;
  StreamSubscription<dynamic>? _deviceSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<dynamic>? _scanSubscription;
  Timer? _scanTimeout;
  BluetoothDevice? _connectedDevice;

  BleService({required this.notificationProvider});

  Future<void> startScan() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        notificationProvider.setError('Bluetooth solo está disponible en Android/iOS.');
        return;
      }

      _scanTimeout?.cancel();
      await _scanSubscription?.cancel();
      notificationProvider.setScanning();

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final device = result.device;
          final name = device.platformName.toLowerCase();
          if (name == BleConstants.DEVICE_NAME.toLowerCase() || name.contains('ironexx')) {
            connectToDevice(device);
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [Guid(BleConstants.SERVICE_UUID)],
      );
    } catch (e) {
      notificationProvider.setError('Error al escanear BLE: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _scanTimeout?.cancel();
      notificationProvider.setScanning();
      _connectedDevice = device;

      if (_connectedDevice != null) {
        await _connectedDevice!.connect(timeout: const Duration(seconds: 15));
      }

      final services = await _connectedDevice!.discoverServices();
      final service = services.firstWhere(
        (element) => element.uuid.toString() == BleConstants.SERVICE_UUID,
        orElse: () => throw Exception('Servicio BLE no encontrado'),
      );

      final characteristic = service.characteristics.firstWhere(
        (element) => element.uuid.toString() == BleConstants.NOTIFICATION_CHARACTERISTIC_UUID,
        orElse: () => throw Exception('Característica BLE no encontrada'),
      );

      await characteristic.setNotifyValue(true);
      _characteristicSubscription = characteristic.lastValueStream.listen((values) {
        if (values.isEmpty) return;
        final msg = String.fromCharCodes(values);
        final notification = NotificationData(
          customerName: 'Wearable',
          message: msg,
          timestamp: DateTime.now(),
          notificationId: DateTime.now().millisecondsSinceEpoch,
        );
        notificationProvider.updateNotification(notification);
      });

      notificationProvider.setConnected(true);
    } catch (e) {
      notificationProvider.setError('Error al conectar por BLE: $e');
    }
  }

  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    await _deviceSubscription?.cancel();
    await _scanSubscription?.cancel();
    _scanTimeout?.cancel();
    _connectedDevice?.disconnect();
    notificationProvider.setConnected(false);
  }

  void dispose() {
    _characteristicSubscription?.cancel();
    _deviceSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanTimeout?.cancel();
    _connectedDevice?.disconnect();
  }
}
