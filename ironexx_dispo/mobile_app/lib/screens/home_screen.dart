import 'package:flutter/material.dart';
import 'machine_scanner_screen.dart';
import 'qr_scan_screen.dart';
import 'sensor_monitor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111C2E),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF2A3C5A), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(15, 23, 42, 0.35),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/ironexx_logo.png',
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'IRONEXX',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF8FAFC),
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Inventario industrial',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _statCard(
                title: 'Maquinaria',
                value: '128',
                subtitle: 'Unidades activas',
                accent: const Color(0xFFD4AF62),
              ),
              const SizedBox(height: 16),
              _actionButton(
                context: context,
                title: 'Agregar máquina',
                subtitle: 'Captura QR o registra equipo',
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScanScreen()),
                ),
                accent: const Color(0xFFD4AF62),
              ),
              const SizedBox(height: 12),
              _actionButton(
                context: context,
                title: 'Buscar máquina',
                subtitle: 'Consulta disponibilidad y ubicación',
                icon: Icons.search_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MachineScannerScreen()),
                ),
                accent: const Color(0xFF1E293B),
              ),
              const SizedBox(height: 12),
              _actionButton(
                context: context,
                title: 'Monitor BLE del wearable',
                subtitle: 'Pasos, ritmo cardíaco y calorías en tiempo real',
                icon: Icons.bluetooth_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SensorMonitorScreen()),
                ),
                accent: const Color(0xFFD4AF62),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3C5A), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.precision_manufacturing_rounded, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _actionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111C2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A3C5A), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
