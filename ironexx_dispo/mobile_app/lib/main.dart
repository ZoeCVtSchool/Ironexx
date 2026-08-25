import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sin firebase_options.dart: en Android basta con google-services.json +
  // el plugin de Gradle (google-services) para que initializeApp() resuelva
  // la configuracion del proyecto automaticamente.
  await Firebase.initializeApp();
  runApp(const IronexxApp());
}

class IronexxApp extends StatelessWidget {
  const IronexxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: MaterialApp(
        title: 'Ironexx - Maquinaria de Construcción',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0B1220),
          canvasColor: const Color(0xFF0B1220),
          primaryColor: const Color(0xFFD4AF62),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF62),
            secondary: Color(0xFF1E293B),
            surface: Color(0xFF111C2E),
            onPrimary: Color(0xFF0B1220),
            onSurface: Color(0xFFF8FAFC),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF111C2E),
            foregroundColor: Color(0xFFF8FAFC),
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF62),
              foregroundColor: const Color(0xFF0B1220),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF111C2E),
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          textTheme: ThemeData.dark().textTheme.copyWith(
            headlineLarge: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontWeight: FontWeight.w800,
            ),
            titleMedium: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: const TextStyle(
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
