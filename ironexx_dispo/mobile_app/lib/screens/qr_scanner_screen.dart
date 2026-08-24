import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      isScanning = false;
      controller.stop();
      
      final code = barcode.rawValue!;
      _showMachineDetails(code);
    }
  }

  void _showMachineDetails(String qrCode) {
    // Simular datos de máquina basados en el código QR
    final machineData = _getMachineData(qrCode);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          machineData['name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Precio', machineData['price']),
            _buildDetailRow('Sucursal', machineData['branch']),
            _buildDetailRow('Estado', machineData['status']),
            const SizedBox(height: 16),
            const Text(
              'Especificaciones:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...machineData['specs'].map<Widget>((spec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $spec',
                style: const TextStyle(color: Colors.grey),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
                controller.start();
              });
            },
            child: const Text('Escanear otro', style: TextStyle(color: Color(0xFFE94560))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFFE94560))),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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

  Map<String, dynamic> _getMachineData(String qrCode) {
    // Simular diferentes máquinas basadas en el código QR
    if (qrCode.contains('CAT320')) {
      return {
        'name': 'Excavadora CAT 320',
        'price': '\$450,000',
        'branch': 'Querétaro',
        'status': 'Disponible',
        'specs': ['Capacidad: 1.5 toneladas', 'Potencia: 162 HP', 'Año: 2024', 'Horas: 1,200'],
      };
    } else if (qrCode.contains('JCB')) {
      return {
        'name': 'Retroexcavadora JCB',
        'price': '\$280,000',
        'branch': 'San Luis Potosí',
        'status': 'En mantenimiento',
        'specs': ['Capacidad: 1.2 toneladas', 'Potencia: 92 HP', 'Año: 2023', 'Horas: 2,500'],
      };
    } else if (qrCode.contains('LIEBHERR')) {
      return {
        'name': 'Grúa Torre Liebherr',
        'price': '\$890,000',
        'branch': 'Guadalajara',
        'status': 'Disponible',
        'specs': ['Capacidad: 12 toneladas', 'Altura: 60 metros', 'Año: 2024', 'Horas: 800'],
      };
    } else if (qrCode.contains('KOMATSU')) {
      return {
        'name': 'Bulldozer Komatsu',
        'price': '\$520,000',
        'branch': 'Querétaro',
        'status': 'Rentada',
        'specs': ['Potencia: 220 HP', 'Peso: 18 toneladas', 'Año: 2024', 'Horas: 1,500'],
      };
    } else {
      return {
        'name': 'Máquina Desconocida',
        'price': 'N/A',
        'branch': 'N/A',
        'status': 'No encontrado',
        'specs': ['Código QR no reconocido'],
      };
    }
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
            controller: controller,
            onDetect: _onDetect,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Apunta al código QR de la máquina',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
