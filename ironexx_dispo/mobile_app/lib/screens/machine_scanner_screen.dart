import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _syncing = false;

  // Mismo catalogo de ejemplo que pwa_tv/app.js (dummyProductsByBranch), para
  // poder demostrar E4 sin depender de que haya maquinas registradas por QR
  // (esa lista empieza vacia). Tocar un chip escribe directo a Firestore.
  static const Map<String, List<String>> _catalogoDemo = {
    'Sucursal Centro': ['Excavadora CAT 320', 'Retroexcavadora', 'Montacargas', 'Compactador'],
    'Sucursal Norte': ['Bulldozer D6', 'Grúa móvil', 'Pala cargadora', 'Cortadora'],
    'Sucursal Sur': ['Camión de volteo', 'Soldadora', 'Martillo demoledor', 'Taladro perforador'],
  };

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

    if (found.isNotEmpty) {
      setState(() => _selectedMachine = found.first);
      unawaited(_syncSelectionToFirestore(
        machineId: found.first['id'],
        machineName: found.first['nombre'],
        branch: found.first['sucursal'],
      ));
      return;
    }

    // No hay coincidencia en las maquinas registradas localmente (esa lista
    // empieza vacia hasta que se registre algo por QR) -- de todas formas se
    // sincroniza el texto buscado como nombre de maquina. pwa_tv hace match
    // por nombre como respaldo (ver handleRemoteStateChange en app.js).
    setState(() => _selectedMachine = null);
    unawaited(_syncSelectionToFirestore(machineId: null, machineName: _codeController.text.trim(), branch: null));
  }

  void _selectCatalogMachine(String name, String branch) {
    _codeController.text = name;
    setState(() {
      _selectedMachine = {'nombre': name, 'sucursal': branch, 'estado': 'disponible'};
    });
    unawaited(_syncSelectionToFirestore(machineId: null, machineName: name, branch: branch));
  }

  // E4: el telefono escribe el estado seleccionado en Firestore; la PWA de
  // la TV escucha con onSnapshot() y se actualiza sin recargar.
  Future<void> _syncSelectionToFirestore({
    required dynamic machineId,
    required String? machineName,
    required String? branch,
  }) async {
    if (machineName == null || machineName.isEmpty) return;
    setState(() => _syncing = true);
    try {
      await FirebaseFirestore.instance.collection('estado_tv').doc('actual').set({
        'machineId': machineId,
        'machineName': machineName,
        'branch': branch,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo sincronizar con la TV: $error')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
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
              child: _syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enviar a la TV (catálogo de ejemplo)',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _catalogoDemo.entries
                  .expand((entry) => entry.value.map((name) => (name, entry.key)))
                  .map((item) => ActionChip(
                        label: Text(item.$1, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF0F3460),
                        side: const BorderSide(color: Color(0xFFE94560)),
                        onPressed: () => _selectCatalogMachine(item.$1, item.$2),
                      ))
                  .toList(),
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
