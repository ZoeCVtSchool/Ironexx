import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sensor_data.dart';
import '../providers/notification_provider.dart';
import '../services/ble_service.dart';

/// Pantalla E2: cliente BLE (rol central). NO escanea automaticamente al
/// abrir -- el usuario debe iniciar primero el wearable (Iniciar en el
/// reloj) y luego presionar "Buscar reloj" aqui, igual que el patron ya
/// probado en el proyecto de referencia (evita el caso donde el telefono
/// escanea y agota el timeout antes de que el reloj empiece a anunciar).
class SensorMonitorScreen extends StatefulWidget {
  const SensorMonitorScreen({super.key});

  @override
  State<SensorMonitorScreen> createState() => _SensorMonitorScreenState();
}

class _SensorMonitorScreenState extends State<SensorMonitorScreen> {
  late final BleService _bleService;

  @override
  void initState() {
    super.initState();
    _bleService = BleService(notificationProvider: context.read<NotificationProvider>());
  }

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Monitor de Sensores (BLE)'),
            backgroundColor: const Color(0xFFE94560),
            actions: [
              IconButton(
                tooltip: notificationProvider.isConnected ? 'Desconectar' : 'Buscar reloj',
                icon: Icon(
                  notificationProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                ),
                onPressed: notificationProvider.isConnected ? _bleService.disconnect : _bleService.startScan,
              ),
            ],
          ),
          body: _buildBody(notificationProvider),
        );
      },
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    final status = provider.connectionStatus;
    final data = provider.currentData;

    if (provider.isConnected && data != null) {
      return _MetricsView(provider: provider, data: data);
    }

    if (status == 'Buscando dispositivo...') {
      return const _EstadoInfo(
        spinner: true,
        titulo: 'Buscando reloj...',
        subtitulo: 'Asegúrate de que el reloj ya esté transmitiendo (botón Iniciar en el wearable).',
      );
    }

    if (status.startsWith('Error')) {
      return _EstadoInfo(
        icono: Icons.error_outline,
        color: Colors.red,
        titulo: 'No se pudo conectar',
        subtitulo: status,
        boton: ('Reintentar', _bleService.startScan),
      );
    }

    return _EstadoInfo(
      icono: Icons.watch,
      color: Colors.grey,
      titulo: 'Conecta tu wearable',
      subtitulo: 'Inicia la transmisión en el reloj y luego presiona el botón para buscarlo.',
      boton: ('Buscar reloj', _bleService.startScan),
    );
  }
}

/// Umbral para considerar el flujo de datos "detenido": el reloj notifica
/// cada ~1s mientras el simulador esta activo, asi que 3s sin una
/// actualizacion nueva es tiempo de sobra para descartar solo jitter de BLE.
const _umbralDatosDetenidos = Duration(seconds: 3);

class _MetricsView extends StatefulWidget {
  final NotificationProvider provider;
  final SensorData data;

  const _MetricsView({required this.provider, required this.data});

  @override
  State<_MetricsView> createState() => _MetricsViewState();
}

class _MetricsViewState extends State<_MetricsView> {
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    // Redibuja cada segundo solo para reevaluar "hace cuanto llego el
    // ultimo dato" -- data.timestamp no cambia por si solo cuando el reloj
    // deja de mandar NOTIFY, asi que sin este tick la UI se quedaria
    // congelada en "recibiendo datos" para siempre.
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final provider = widget.provider;
    final recibiendoDatos = DateTime.now().difference(data.timestamp) < _umbralDatosDetenidos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSensorCard(
            'Temperatura del motor',
            '${data.temperaturaMotor}°C',
            Icons.thermostat,
            provider.isTemperaturaCritica ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSensorCard(
            'Nivel de combustible',
            '${data.nivelCombustible}%',
            Icons.local_gas_station,
            provider.isCombustibleCritico ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSensorCard(
            'Horómetro',
            '${data.horometroMin} min',
            Icons.schedule,
            provider.isHorometroCritico ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 16),
          if (provider.isTemperaturaCritica || provider.isCombustibleCritico)
            Card(
              color: Colors.red.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        provider.isTemperaturaCritica
                            ? '¡Motor sobrecalentado!'
                            : '¡Nivel de combustible bajo!',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.isHorometroCritico)
            Card(
              color: Colors.orange.withOpacity(0.15),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.build_circle_outlined, color: Colors.orange, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Mantenimiento recomendado (horómetro por encima del umbral).',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Última actualización: ${data.timestamp.hour.toString().padLeft(2, '0')}:'
            '${data.timestamp.minute.toString().padLeft(2, '0')}:'
            '${data.timestamp.second.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: recibiendoDatos ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                recibiendoDatos ? 'Recibiendo datos en vivo' : 'Sin datos recientes',
                style: TextStyle(
                  fontSize: 11,
                  color: recibiendoDatos ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF0F3460),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoInfo extends StatelessWidget {
  final IconData? icono;
  final bool spinner;
  final Color? color;
  final String titulo;
  final String subtitulo;
  final (String, VoidCallback)? boton;

  const _EstadoInfo({
    this.icono,
    this.spinner = false,
    this.color,
    required this.titulo,
    required this.subtitulo,
    this.boton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (spinner) const CircularProgressIndicator(color: Color(0xFFE94560)),
            if (icono != null) Icon(icono, size: 64, color: color ?? Colors.grey),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (boton != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: boton!.$2,
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(boton!.$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
