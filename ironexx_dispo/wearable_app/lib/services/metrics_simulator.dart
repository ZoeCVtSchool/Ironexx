import 'dart:async';
import 'dart:math';

import '../ble_constants.dart';

/// 3 metricas del wearable, propias del dominio del proyecto (monitoreo de
/// la maquina que opera el tecnico): temperatura de motor, nivel de
/// combustible y horometro. Se recalculan cada ~1s mientras esta corriendo
/// (requisito E1: "Generacion aproximadamente cada segundo").
class MachineMetrics {
  final int temperaturaMotor; // grados C
  final int nivelCombustible; // porcentaje
  final int horometroMin; // minutos simulados de operacion

  const MachineMetrics({
    required this.temperaturaMotor,
    required this.nivelCombustible,
    required this.horometroMin,
  });

  bool get temperaturaCritica => temperaturaMotor > BleConstants.TEMPERATURA_CRITICA;
  bool get combustibleCritico => nivelCombustible < BleConstants.COMBUSTIBLE_CRITICO;
  bool get horometroCritico => horometroMin > BleConstants.HOROMETRO_CRITICO;

  static const zero = MachineMetrics(temperaturaMotor: 0, nivelCombustible: 0, horometroMin: 0);
}

class MetricsSimulator {
  Timer? _timer;
  bool _isRunning = false;
  final Random _random = Random();

  int _temperatura = 75; // arranca en operacion normal
  int _combustible = 100; // tanque lleno al iniciar
  int _horometro = 0;

  final StreamController<MachineMetrics> _controller =
      StreamController<MachineMetrics>.broadcast();

  Stream<MachineMetrics> get stream => _controller.stream;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    // Temperatura del motor: fluctua con caminata aleatoria, puede subir a
    // rango critico si "trabaja" varios ciclos seguidos (simula sobrecarga).
    _temperatura = (_temperatura + _random.nextInt(5) - 2).clamp(60, 120);

    // Combustible: se consume progresivamente durante la operacion.
    _combustible = (_combustible - _random.nextInt(2)).clamp(0, 100);

    // Horometro: minutos de operacion acumulados en esta sesion (escala
    // acelerada para que el umbral de mantenimiento sea demostrable en una
    // sesion corta: 1 tick de 1s = 1 minuto simulado de operacion).
    _horometro += 1;

    _controller.add(MachineMetrics(
      temperaturaMotor: _temperatura,
      nivelCombustible: _combustible,
      horometroMin: _horometro,
    ));
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
