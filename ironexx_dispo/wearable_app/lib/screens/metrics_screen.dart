import 'dart:async';
import 'package:flutter/material.dart';

import '../services/ble_server_service.dart';
import '../services/metrics_simulator.dart';

const _kBackground = Color(0xFF0B1220);
const _kCard = Color(0xFF111C2E);
const _kBorder = Color(0xFF2A3C5A);
const _kAccent = Color(0xFFD4AF62);
const _kOk = Color(0xFF4ADE80);
const _kCritical = Color(0xFFEF4444);

/// Pantalla E1: simulador de 3 metricas de la maquina (temperatura, nivel de
/// combustible, horometro) + servidor GATT BLE con NOTIFY. Iniciar arranca
/// el simulador (Timer 1s) y el advertising BLE al mismo tiempo; cada tick
/// se muestra localmente Y se notifica por las 3 caracteristicas BLE ya
/// registradas en BleServerService.
class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  final MetricsSimulator _simulator = MetricsSimulator();
  final BleServerService _bleServer = BleServerService();

  StreamSubscription<MachineMetrics>? _subscription;
  MachineMetrics _metrics = MachineMetrics.zero;
  bool _isRunning = false;
  bool _isStarting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _subscription = _simulator.stream.listen((metrics) {
      setState(() => _metrics = metrics);
      unawaited(_bleServer.notifyTemperatura(metrics.temperaturaMotor));
      unawaited(_bleServer.notifyCombustible(metrics.nivelCombustible));
      unawaited(_bleServer.notifyHorometro(metrics.horometroMin));
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _simulator.dispose();
    _bleServer.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isRunning) {
      _simulator.stop();
      await _bleServer.stopServer();
      setState(() {
        _isRunning = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      await _bleServer.startServer();
      _simulator.start();
      setState(() {
        _isRunning = true;
        _isStarting = false;
      });
    } catch (error) {
      setState(() {
        _isStarting = false;
        _errorMessage = error.toString();
      });
    }
  }

  bool get _hayAlgunaCritica =>
      _metrics.temperaturaCritica || _metrics.combustibleCritico || _metrics.horometroCritico;

  @override
  Widget build(BuildContext context) {
    // Zona segura para pantalla circular: un cuadrado inscrito mas chico que
    // el diametro completo, centrado, para que las tarjetas rectangulares no
    // choquen con el borde curvo del reloj.
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final safeWidth = shortestSide * 0.56;

    return Scaffold(
      backgroundColor: _kBackground,
      body: Center(
        child: SizedBox(
          width: safeWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: safeWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _estadoBanner(),
                  const SizedBox(height: 5),
                  _metricRow(
                    'Motor',
                    '${_metrics.temperaturaMotor}°C',
                    Icons.thermostat_rounded,
                    _metrics.temperaturaCritica,
                  ),
                  const SizedBox(height: 4),
                  _metricRow(
                    'Combustible',
                    '${_metrics.nivelCombustible}%',
                    Icons.local_gas_station_rounded,
                    _metrics.combustibleCritico,
                  ),
                  const SizedBox(height: 4),
                  _metricRow(
                    'Horómetro',
                    '${_metrics.horometroMin} min',
                    Icons.schedule_rounded,
                    _metrics.horometroCritico,
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isStarting ? null : _toggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? _kCritical : _kAccent,
                        foregroundColor: _kBackground,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isStarting
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _kBackground),
                            )
                          : Text(
                              _isRunning ? 'Detener' : 'Iniciar',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 8, color: _kCritical),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoBanner() {
    final Color color;
    final IconData icon;
    final String label;
    if (!_isRunning) {
      color = const Color(0xFF94A3B8);
      icon = Icons.bluetooth_disabled_rounded;
      label = 'Detenido';
    } else if (_hayAlgunaCritica) {
      color = _kCritical;
      icon = Icons.warning_amber_rounded;
      label = 'Alerta';
    } else {
      color = _kOk;
      icon = Icons.bluetooth_connected_rounded;
      label = 'Transmitiendo';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _metricRow(String label, String value, IconData icon, bool critico) {
    final color = critico ? _kCritical : _kAccent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: critico ? _kCritical : _kBorder, width: critico ? 1.2 : 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
