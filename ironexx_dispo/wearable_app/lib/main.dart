import 'package:flutter/material.dart';
import 'screens/metrics_screen.dart';

void main() {
  runApp(const IronexxWearableApp());
}

class IronexxWearableApp extends StatelessWidget {
  const IronexxWearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ironexx Wearable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF62),
          secondary: Color(0xFF1E293B),
          surface: Color(0xFF111C2E),
          onSurface: Color(0xFFF8FAFC),
          onPrimary: Color(0xFF0B1220),
        ),
      ),
      home: const MetricsScreen(),
    );
  }
}
