import 'dart:async';
import 'dart:math';
import '../models/notification_data.dart';

class NotificationSimulator {
  Timer? _timer;
  bool _isRunning = false;
  final Random _random = Random();
  int _notificationCount = 0;

  final StreamController<NotificationData> _dataController = StreamController<NotificationData>();
  Stream<NotificationData> get notificationStream => _dataController.stream;

  final List<String> _customerNames = [
    'Carlos López',
    'María González',
    'Roberto Sánchez',
    'Ana Martínez',
    'Juan Pérez'
  ];

  final List<String> _messages = [
    'Interesado en excavadora CAT 320',
    'Cotización para retroexcavadora',
    'Información sobre grúa torre',
    'Consulta disponibilidad bulldozer',
    'Visita a sucursal Querétaro'
  ];

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _generateNotification();
    });
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void _generateNotification() {
    final customerName = _customerNames[_random.nextInt(_customerNames.length)];
    final message = _messages[_random.nextInt(_messages.length)];
    _notificationCount++;
    
    final notification = NotificationData(
      customerName: customerName,
      message: message,
      timestamp: DateTime.now(),
      notificationId: _notificationCount,
    );
    
    _dataController.add(notification);
  }

  bool get isRunning => _isRunning;

  void dispose() {
    stop();
    _dataController.close();
  }
}
