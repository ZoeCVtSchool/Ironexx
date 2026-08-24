import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/machinery.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Machinery>> getMachinery() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/productos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al consultar productos: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final rawList = payload['data'];

      if (rawList is! List) {
        return const <Machinery>[];
      }

      return rawList
          .map((item) => Machinery.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading machinery: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (captchaToken != null) 'captchaToken': captchaToken,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 400 || decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Login failed');
    }

    return decoded as Map<String, dynamic>;
  }

  Future<List<dynamic>> getInventoryByBranch({
    required int branchId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory/branch/$branchId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 400 || decoded is! Map<String, dynamic> || decoded['success'] != true) {
      throw Exception(decoded is Map<String, dynamic> ? decoded['message'] ?? 'Inventory fetch failed' : 'Inventory fetch failed');
    }

    final data = decoded['data'];
    return data is List ? data : const <dynamic>[];
  }

  Future<Map<String, dynamic>> scanInventory({
    required int productoId,
    required int sucursalId,
    required int cantidad,
    required String estado,
    required String codigoEscaneo,
    required int stockMinimo,
    required int actualizadoPor,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory/scan'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'producto_id': productoId,
        'sucursal_id': sucursalId,
        'cantidad': cantidad,
        'estado': estado,
        'codigo_escaneo': codigoEscaneo,
        'stock_minimo': stockMinimo,
        'actualizado_por': actualizadoPor,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 400 || decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Inventory update failed');
    }

    return decoded as Map<String, dynamic>;
  }
}
