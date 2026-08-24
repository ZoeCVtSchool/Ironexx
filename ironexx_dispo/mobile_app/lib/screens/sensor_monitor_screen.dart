import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class SensorMonitorScreen extends StatelessWidget {
  const SensorMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final data = notificationProvider.currentData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Monitor de Sensores'),
            backgroundColor: const Color(0xFFE94560),
          ),
          body: data != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSensorCard(
                        'Pasos',
                        '${data.steps}',
                        Icons.directions_walk,
                        notificationProvider.isStepsCritical ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildSensorCard(
                        'Ritmo Cardíaco',
                        '${data.heartRate} BPM',
                        Icons.favorite,
                        notificationProvider.isHeartRateCritical ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildSensorCard(
                        'Calorías',
                        '${data.calories.toStringAsFixed(1)} kcal',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      if (notificationProvider.isHeartRateCritical)
                        Card(
                          color: Colors.red.withOpacity(0.2),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red, size: 32),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '¡Ritmo cardíaco elevado! Por favor descanse.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Esperando datos del wearable...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        );
      },
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
