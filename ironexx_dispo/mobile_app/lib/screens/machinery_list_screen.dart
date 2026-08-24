import 'package:flutter/material.dart';
import '../models/machinery.dart';

class MachineryListScreen extends StatelessWidget {
  final List<Machinery> machinery;

  const MachineryListScreen({super.key, required this.machinery});

  @override
  Widget build(BuildContext context) {
    if (machinery.isEmpty) {
      return const Center(
        child: Text(
          'No hay maquinaria disponible',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: machinery.length,
      itemBuilder: (context, index) {
        final machine = machinery[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF0F3460),
          child: ExpansionTile(
            title: Text(
              machine.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              machine.price,
              style: const TextStyle(
                color: Color(0xFFE94560),
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFE94560)),
                        const SizedBox(width: 8),
                        Text(
                          machine.branch,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detalles:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...machine.details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(color: Color(0xFFE94560)),
                            ),
                            Expanded(
                              child: Text(
                                detail,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
