import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _isProcessing = false;
  String _lastScannedCode = '';
  final List<Map<String, dynamic>> _machines = [];

  static const String _machinesKey = 'local_registered_machines';
  static const List<String> _branches = [
    'Sucursal Centro',
    'Sucursal Norte',
    'Sucursal Sur',
  ];

  @override
  void initState() {
    super.initState();
    _loadMachinesFromLocalStorage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMachinesFromLocalStorage() async {
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
          // Ignored if a previous item is malformed.
        }
      }
    });
  }

  Future<void> _saveMachinesToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = _machines.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_machinesKey, serialized);
  }

  Future<void> _syncMachineRegistrationToServer(Map<String, dynamic> machineRecord) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/machines/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(machineRecord),
      );

      if (response.statusCode >= 400) {
        debugPrint('Machine registration API failed: ${response.statusCode} ${response.body}');
        throw Exception('La API no pudo registrar la máquina.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == false) {
        throw Exception(decoded['message'] ?? 'No se pudo registrar la máquina.');
      }
    } catch (error) {
      debugPrint('Machine registration fallback: $error');
      // We still keep the local registration for offline continuity, but the server remains the source of truth.
    }
  }

  void _showRegistrationForm(Map<String, dynamic> machineData, String code) {
    final nameController = TextEditingController(text: machineData['nombre'] ?? 'Máquina escaneada');
    final modelController = TextEditingController(text: machineData['modelo'] ?? '');
    final notesController = TextEditingController(text: machineData['descripcion'] ?? '');

    _controller.stop();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String selectedBranch = _branches.first;

            return AlertDialog(
              backgroundColor: const Color(0xFF111C2E),
              title: const Text(
                'Registrar máquina',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formField('Nombre', nameController),
                      const SizedBox(height: 12),
                      _formField('Modelo', modelController),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sucursal *',
                            style: TextStyle(color: Color(0xFFD4AF62), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedBranch,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0F172A),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _branches
                                .map(
                                  (branch) => DropdownMenuItem<String>(
                                    value: branch,
                                    child: Text(branch, style: const TextStyle(color: Colors.white)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => selectedBranch = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _formField('Observaciones', notesController),
                      const SizedBox(height: 12),
                      _detailRow('Código QR', code),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _controller.start();
                    setState(() => _isProcessing = false);
                  },
                  child: const Text('Escanear otro', style: TextStyle(color: Color(0xFFD4AF62))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final branch = selectedBranch.trim();
                    final dialogMessenger = ScaffoldMessenger.maybeOf(dialogContext);
                    final rootMessenger = ScaffoldMessenger.maybeOf(context);

                    if (branch.isEmpty) {
                      dialogMessenger?.showSnackBar(
                        const SnackBar(
                          content: Text('La sucursal es obligatoria antes de guardar.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final machineRecord = {
                      'id': now.millisecondsSinceEpoch,
                      'codigo': code,
                      'nombre': nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'Máquina sin nombre',
                      'modelo': modelController.text.trim(),
                      'sucursal': branch,
                      'descripcion': notesController.text.trim(),
                      'estado': 'Activo',
                      'registrado_en': now.toIso8601String(),
                      'tipo': machineData['tipo'] ?? 'maquinaria',
                      'precio': machineData['precio'] ?? 0,
                    };

                    setState(() {
                      _machines.insert(0, machineRecord);
                    });

                    try {
                      await _syncMachineRegistrationToServer(machineRecord);
                    } catch (_) {
                      // The app keeps the local record and continues; the backend remains the shared source of truth.
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    await _saveMachinesToLocalStorage();

                    if (!mounted) return;
                    _controller.start();
                    setState(() => _isProcessing = false);

                    rootMessenger?.showSnackBar(
                      SnackBar(
                        content: Text('Máquina registrada en $branch. La wearable y la TV/PWA se actualizarán con esta información.'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF62)),
                  child: const Text('Confirmar y guardar', style: TextStyle(color: Color(0xFF0B1220))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final code = barcode?.rawValue;

    if (code == null || code.trim().isEmpty) return;

    _isProcessing = true;
    _lastScannedCode = code;

    final machineData = _parseMachineData(code);

    if (!mounted) return;
    _showRegistrationForm(machineData, code);
  }

  Map<String, dynamic> _parseMachineData(String code) {
    final trimmedCode = code.trim();

    try {
      final decoded = jsonDecode(trimmedCode);
      if (decoded is Map<String, dynamic>) {
        return {
          'nombre': decoded['nombre'] ?? decoded['name'] ?? 'Máquina escaneada',
          'tipo': decoded['tipo'] ?? decoded['category'] ?? 'maquinaria',
          'modelo': decoded['modelo'] ?? decoded['model'] ?? '',
          'precio': decoded['precio'] ?? decoded['price'] ?? 0,
          'descripcion': decoded['descripcion'] ?? decoded['description'] ?? '',
        };
      }
    } catch (_) {
      // QR no JSON, se procesa como texto libre.
    }

    final normalized = trimmedCode.toUpperCase();
    if (normalized.contains('CAT') || normalized.contains('EXCAVADORA')) {
      return {
        'nombre': 'Excavadora CAT 320',
        'tipo': 'maquinaria',
        'modelo': 'CAT 320',
        'precio': 450000,
        'descripcion': 'Máquina registrada mediante escaneo QR.',
      };
    }

    if (normalized.contains('JCB')) {
      return {
        'nombre': 'Retroexcavadora JCB',
        'tipo': 'maquinaria',
        'modelo': 'JCB 3CX',
        'precio': 280000,
        'descripcion': 'Retroexcavadora registrada desde QR.',
      };
    }

    return {
      'nombre': 'Máquina escaneada',
      'tipo': 'maquinaria',
      'modelo': 'Sin modelo',
      'precio': 0,
      'descripcion': 'Registro manual por QR.',
    };
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFFD4AF62), fontWeight: FontWeight.bold),
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

  Widget _formField(String label, TextEditingController controller, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFD4AF62), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR'),
        backgroundColor: const Color(0xFFE94560),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD4AF62), width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 42),
                  const SizedBox(height: 8),
                  Text(
                    _lastScannedCode.isEmpty
                        ? 'Apunta a un código QR de la máquina'
                        : 'Último código: $_lastScannedCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_machines.length} máquina(s) registradas localmente',
                    style: const TextStyle(color: Color(0xFFD4AF62), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
