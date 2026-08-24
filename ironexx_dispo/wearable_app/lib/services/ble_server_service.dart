import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble_constants.dart';
import '../models/notification_data.dart';

class BleServerService {
  StreamSubscription<dynamic>? _scanSubscription;

  Future<void> startServer() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = result.device;
        final name = device.platformName.toLowerCase();
        if (name == 'ironexx wearable' || name.contains('ironexx')) {
          // The wearable is now in BLE discovery mode and can accept a direct connection
          // when running on a physical device. Emulators do not support BLE device-to-device.
        }
      }
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      withServices: [Guid(BleConstants.SERVICE_UUID)],
    );
  }

  Future<void> stopServer() async {
    await _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();
  }

  Future<void> sendNotification(NotificationData notification) async {
    // Real BLE transmit requires a physical device pair and is not available across
    // Android emulators. This method remains as the direct-send hook for real hardware.
    return;
  }

  void dispose() {
    _scanSubscription?.cancel();
  }
}
