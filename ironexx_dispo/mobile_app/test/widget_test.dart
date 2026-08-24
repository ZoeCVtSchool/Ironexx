import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/main.dart';
import 'package:mobile_app/providers/notification_provider.dart';
import 'package:mobile_app/screens/qr_scan_screen.dart';

void main() {
  testWidgets('La app carga correctamente la pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(const IronexxApp());

    expect(find.text('Ironexx'), findsOneWidget);
    expect(find.text('Escáner de Maquinaria'), findsOneWidget);
    expect(find.text('Agregar Máquina'), findsOneWidget);
    expect(find.text('Buscar Máquina'), findsOneWidget);
  });

  testWidgets('La app crea el proveedor de estado para sensores y notificaciones', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NotificationProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      ),
    );

    expect(find.byType(ChangeNotifierProvider<NotificationProvider>), findsOneWidget);
    final context = tester.element(find.byType(Scaffold));
    expect(context.read<NotificationProvider>().connectionStatus, 'Desconectado');
  });

  testWidgets('La pantalla QR inicia en modo de escaneo sin congelarse', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: QrScanScreen()));

    expect(find.text('Escáner QR'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Inventario'), findsOneWidget);
  });
}
