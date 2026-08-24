import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MachineScannerScreen extends StatefulWidget {
  const MachineScannerScreen({super.key});

  @override
  State<MachineScannerScreen> createState() => _MachineScannerScreenState();
}

class _MachineScannerScreenState extends State<MachineScannerScreen> {
  final TextEditingController _codeController = TextEditingController();
  final List<Map<String, dynamic>> _machines = [];
  Map<String, dynamic>? _selectedMachine;
  static const String _machinesKey = 'local_registered_machines';

  @override
  void initState() {
    super.initState();
    _loadSavedMachines();
  }

  Future<void> _loadSavedMachines() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_machinesKey) ?? <String>[];

    if (!mounted) return;

    setState(() {
      _machines.clear();
      for (final item in rawList) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            _machines.add(decoded);
          }
        } catch (_) {
          // Ignored malformed data.
        }
      }
    });
  }

  void _searchMachine() {
    final query = _codeController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _selectedMachine = null;
      });
      return;
    }

    final found = _machines.where((machine) {
      final name = (machine['nombre'] ?? '').toString().toLowerCase();
      final model = (machine['modelo'] ?? '').toString().toLowerCase();
      final code = (machine['codigo'] ?? '').toString().toLowerCase();
      final branch = (machine['sucursal'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          model.contains(query) ||
          code.contains(query) ||
          branch.contains(query);
    }).toList();

    setState(() {
      _selectedMachine = found.isNotEmpty ? found.first : null;
    });
  }

  void _removeMachine(int index) {
    final selectedId = _selectedMachine?['id'];
    final removedMachine = _machines[index];

    setState(() {
      _machines.removeAt(index);
      if (selectedId != null && removedMachine['id'] == selectedId) {
        _selectedMachine = null;
      }
    });

    _persistMachines();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Máquina eliminada del registro'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _persistMachines() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = _machines.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_machinesKey, serialized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar máquina'),
        backgroundColor: const Color(0xFFE94560),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Busca por nombre, modelo, código o sucursal',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF0F3460),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFE94560)),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _searchMachine(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchMachine,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 24),
            if (_selectedMachine != null) ...[
              Card(
                color: const Color(0xFF0F3460),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMachine!['nombre'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Código', _selectedMachine!['codigo'] ?? 'Sin código'),
                      _buildDetailRow('Modelo', _selectedMachine!['modelo'] ?? 'Sin modelo'),
                      _buildDetailRow('Sucursal', _selectedMachine!['sucursal'] ?? 'Sin sucursal'),
                      _buildDetailRow('Estado', _selectedMachine!['estado'] ?? 'Activo'),
                      if ((_selectedMachine!['descripcion'] ?? '').toString().isNotEmpty)
                        _buildDetailRow('Observaciones', _selectedMachine!['descripcion']),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No se encontraron máquinas con ese criterio.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Máquinas registradas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _machines.isEmpty
                  ? const Center(
                      child: Text(
                        'Todavía no hay máquinas registradas.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _machines.length,
                      itemBuilder: (context, index) {
                        final machine = _machines[index];
                        return Card(
                          color: const Color(0xFF0F3460),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              machine['nombre'] ?? 'Máquina',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${machine['sucursal'] ?? 'Sin sucursal'} • ${machine['modelo'] ?? 'Sin modelo'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeMachine(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
