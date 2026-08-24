import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Android Emulator must use 10.0.2.2 to reach the host machine's localhost.
// For a physical device, replace this with the machine's LAN IP (for example 192.168.1.10).
const String _apiBaseUrl = 'http://10.0.2.2:3000/api';
const String _loginEmail = 'chandussandra@gmail.com';
const String _loginPassword = '***REDACTED-PASSWORD***';
const int _adminUserId = 2;
const String _deviceId = 'wearable-admin-device';
String? _bearerToken;
int _userId = _adminUserId;

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
      home: const WearableHomeScreen(),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, String> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final customer = notification['customer'] ?? 'Cliente';
    final email = notification['email'] ?? '';
    final phone = notification['telefono'] ?? '';
    final message = notification['message'] ?? 'Sin mensaje';
    final machineName = notification['machineName'] ?? '';
    final branch = notification['branch'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Contacto',
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A2338), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD4AF62), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cliente',
                                style: TextStyle(
                                  color: Color(0xFFD4AF62),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                customer,
                                style: const TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (email.isNotEmpty || phone.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF2A3C5A), width: 1),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (email.isNotEmpty)
                                  _WearableInfoChip(icon: Icons.email_rounded, text: email),
                                if (phone.isNotEmpty)
                                  _WearableInfoChip(icon: Icons.phone_rounded, text: phone),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (machineName.isNotEmpty || branch.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF2A3C5A), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (machineName.isNotEmpty)
                                  Text(
                                    'Máquina: $machineName',
                                    style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
                                  ),
                                if (branch.isNotEmpty)
                                  Text(
                                    'Sucursal: $branch',
                                    style: const TextStyle(color: Color(0xFFD4AF62), fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'Mensaje',
                          style: TextStyle(
                            color: Color(0xFFD4AF62),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111C2E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A3C5A), width: 1.1),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Color(0xFFF8FAFC),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WearableInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WearableInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFD4AF62)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 11,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class WearableHomeScreen extends StatefulWidget {
  const WearableHomeScreen({super.key});

  @override
  State<WearableHomeScreen> createState() => _WearableHomeScreenState();
}

class _WearableHomeScreenState extends State<WearableHomeScreen> with WidgetsBindingObserver {
  final List<Map<String, String>> _notifications = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _errorMessage;
  Timer? _pollingTimer;
  int _lastNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadNotifications());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      if (_loginPassword.isEmpty) {
        throw Exception('Falta el password válido del admin. Se requiere la contraseña real de admin@ironexx.com para hacer login.');
      }

      final loginResponse = await http.post(
        Uri.parse('$_apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _loginEmail,
          'password': _loginPassword,
          'captchaToken': 'test',
        }),
      );

      final loginData = jsonDecode(loginResponse.body) as Map<String, dynamic>;
      if (loginResponse.statusCode != 200 || loginData['success'] != true || loginData['token'] == null) {
        final message = loginData['message']?.toString() ?? 'Credenciales o usuario inválidos';
        throw Exception('Login falló para admin@ironexx.com. $message');
      }

      _bearerToken = loginData['token'] as String;
      final user = loginData['user'] as Map<String, dynamic>? ?? {};
      _userId = (user['id'] as int?) ?? _adminUserId;
      final nombre = user['nombre']?.toString() ?? 'Admin';
      debugPrint('Wearable login OK: userId=$_userId, nombre=$nombre');

      await _registerToken();
      await _loadNotifications();

      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        if (!mounted) {
          return;
        }
        await _loadNotifications();
      });
    } catch (error) {
      setState(() {
        _notifications.clear();
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      if (_bearerToken == null || _bearerToken!.isEmpty) {
        throw Exception('JWT no disponible');
      }

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/wearable/notifications/$_userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_bearerToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('GET /wearable/notifications/2 falló con status ${response.statusCode}: ${response.body}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as List? ?? const [];
      final fallbacks = <Map<String, String>>[];

      try {
        final sharedPrefs = await SharedPreferences.getInstance();
        final saved = sharedPrefs.getStringList('local_registered_machines') ?? <String>[];
        for (final raw in saved) {
          try {
            final item = jsonDecode(raw);
            if (item is Map<String, dynamic>) {
              final machineName = (item['nombre'] ?? '').toString();
              final branch = (item['sucursal'] ?? '').toString();
              if (machineName.isNotEmpty) {
                fallbacks.add({
                  'customer': 'Administrador',
                  'title': 'Nueva máquina',
                  'message': 'Se registró una nueva máquina en $branch',
                  'email': '',
                  'telefono': '',
                  'time': 'Reciente',
                  'machineName': machineName,
                  'branch': branch,
                });
              }
            }
          } catch (_) {
            // Ignored malformed local data.
          }
        }
      } catch (_) {
        // SharedPreferences may not be available in this runtime.
      }

      final parsedItems = data.map<Map<String, String>>((item) {
        final map = item as Map<String, dynamic>;
        final name = (
              map['nombre']?.toString() ??
              map['cliente']?.toString() ??
              map['nombre_cliente']?.toString() ??
              map['remitente']?.toString() ??
              map['origen']?.toString() ??
              'Cliente'
            ).trim();
        final rawTitle = map['titulo']?.toString() ?? '';
        final genericTitle = rawTitle.toLowerCase();
        final title = (rawTitle.isEmpty || genericTitle.contains('nuevo contacto') || genericTitle.contains('contacto') || genericTitle.contains('mensaje') || genericTitle.contains('nueva máquina') || genericTitle.contains('nueva maquina') || genericTitle.contains('maquina') || genericTitle.contains('web')) ? name : rawTitle;
        final email = (
              map['email']?.toString() ??
              map['correo']?.toString() ??
              map['correo_electronico']?.toString() ??
              ''
            ).trim();
        final phone = (
              map['telefono']?.toString() ??
              map['telefono_contacto']?.toString() ??
              map['celular']?.toString() ??
              ''
            ).trim();
        final message = (
              map['mensaje']?.toString() ??
              map['message']?.toString() ??
              map['descripcion']?.toString() ??
              map['detalle']?.toString() ??
              map['observaciones']?.toString() ??
              'Mensaje de prueba'
            ).trim();
        final machineName = (
              map['maquina']?.toString() ??
              map['machine_name']?.toString() ??
              map['nombre_maquina']?.toString() ??
              map['nombre']?.toString() ??
              map['machine']?.toString() ??
              ''
            ).trim();
        final branch = (
              map['sucursal']?.toString() ??
              map['branch']?.toString() ??
              map['nombre_sucursal']?.toString() ??
              map['sucursal_nombre']?.toString() ??
              ''
            ).trim();

        final normalizedMachineName = machineName.isNotEmpty ? machineName : (name == 'Sistema Web' ? 'Portal Web' : '');
        final normalizedBranch = branch.isNotEmpty ? branch : (name == 'Sistema Web' ? 'Sucursal Centro' : '');
        final finalMessage = message.isNotEmpty
            ? message
            : (normalizedMachineName.isNotEmpty && normalizedBranch.isNotEmpty ? 'Se registró una nueva máquina en $normalizedBranch' : 'Mensaje de prueba');

        return {
          'customer': name,
          'title': title,
          'message': finalMessage,
          'email': email,
          'telefono': phone,
          'time': 'Reciente',
          'machineName': normalizedMachineName,
          'branch': normalizedBranch,
        };
      }).toList();

      final seen = <String>{};
      final items = <Map<String, String>>[];
      for (final item in [...parsedItems, ...fallbacks]) {
        final signature = [
          item['customer'] ?? '',
          item['title'] ?? '',
          item['message'] ?? '',
          item['machineName'] ?? '',
          item['branch'] ?? '',
        ].join('|');
        if (signature.isEmpty || seen.contains(signature)) {
          continue;
        }
        seen.add(signature);
        items.add(item);
      }

      final hadPreviousNotifications = _lastNotificationCount > 0;
      final newCount = items.length;
      final hasNewNotifications = newCount > _lastNotificationCount;

      setState(() {
        _notifications.clear();
        _notifications.addAll(items);
        _loading = false;
        _errorMessage = null;
        if (_notifications.isNotEmpty) {
          _currentIndex = 0;
        }
      });

      _lastNotificationCount = newCount;

      if (hasNewNotifications || (!hadPreviousNotifications && newCount > 0)) {
        _playNotificationAlert();
      }
      return;
    } catch (error) {
      setState(() {
        _notifications.clear();
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _registerToken() async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/wearable/register-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_bearerToken',
      },
      body: jsonEncode({
        'usuario_id': _adminUserId,
        'device_id': _deviceId,
        'token': 'wearable-admin-${DateTime.now().millisecondsSinceEpoch}',
        'plataforma': 'android',
      }),
    );

    if (response.statusCode >= 400) {
      final decoded = jsonDecode(response.body);
      final message = decoded is Map<String, dynamic> ? decoded['message']?.toString() ?? response.body : response.body;
      throw Exception('register-token falló: $message');
    }
  }

  void _playNotificationAlert() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignored: some emulators may not support system alert sound.
    }
  }

  void _nextNotification() {
    if (_notifications.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _notifications.length;
    });
  }

  void _previousNotification() {
    if (_notifications.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _notifications.length) % _notifications.length;
    });
  }

  void _openNotificationDetails(Map<String, String> notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ironexx_logo.png',
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFD4AF62),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: Text(
            _errorMessage ?? 'Sin notificaciones',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFF8FAFC)),
          ),
        ),
      );
    }

    final current = _notifications[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C2E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF2A3C5A), width: 1.1),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/ironexx_logo.png',
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'IRONEXX',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _openNotificationDetails(current),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111C2E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD4AF62), width: 1.2),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF62).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person, size: 16, color: Color(0xFFD4AF62)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      current['customer']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFF8FAFC),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.message_rounded, size: 12, color: Color(0xFFD4AF62)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            current['message']!,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFCBD5E1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      current['time']!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: _previousNotification,
                            icon: const Icon(Icons.chevron_left_rounded),
                            color: const Color(0xFFD4AF62),
                            iconSize: 24,
                            splashRadius: 18,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentIndex + 1}/${_notifications.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _nextNotification,
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: const Color(0xFFD4AF62),
                            iconSize: 24,
                            splashRadius: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Centro de control',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
