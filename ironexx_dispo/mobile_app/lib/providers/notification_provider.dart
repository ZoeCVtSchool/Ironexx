import 'package:flutter/foundation.dart';
import '../models/notification_data.dart';
import '../models/sensor_data.dart';

class NotificationProvider with ChangeNotifier {
  NotificationData? _currentNotification;
  final List<NotificationData> _history = [];
  bool _isConnected = false;
  String _connectionStatus = 'Desconectado';
  SensorData? _currentData;

  NotificationData? get currentNotification => _currentNotification;
  List<NotificationData> get history => _history;
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  int get unreadCount => _history.length;
  SensorData? get currentData => _currentData;

  bool get isStepsCritical => _currentData != null && _currentData!.steps > 10000;
  bool get isHeartRateCritical => _currentData != null && _currentData!.heartRate > 120;

  void updateSensorData(SensorData data) {
    _currentData = data;
    notifyListeners();
  }

  void updateNotification(NotificationData notification) {
    _currentNotification = notification;
    _history.add(notification);

    if (_history.length > 50) {
      _history.removeAt(0);
    }

    notifyListeners();
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    _connectionStatus = connected ? 'Conectado' : 'Desconectado';
    notifyListeners();
  }

  void setScanning() {
    _connectionStatus = 'Buscando dispositivo...';
    notifyListeners();
  }

  void setError(String error) {
    _connectionStatus = 'Error: $error';
    _isConnected = false;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _currentNotification = null;
    _currentData = null;
    notifyListeners();
  }
}
