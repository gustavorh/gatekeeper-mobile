import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.122:9000';
  static const String loginEndpoint = '/auth/login';

  // Helper function to clean RUT format (remove dots and dashes)
  static String cleanRut(String rut) {
    return rut.replaceAll(RegExp(r'[.-]'), '');
  }

  // Helper function to format RUT for display
  static String formatRut(String rut) {
    final cleanedRut = rut.replaceAll(RegExp(r'[.-]'), '');
    if (cleanedRut.length < 2) return cleanedRut;

    final body = cleanedRut.substring(0, cleanedRut.length - 1);
    final dv = cleanedRut.substring(cleanedRut.length - 1);

    if (body.length <= 3) {
      return '$body-$dv';
    } else if (body.length <= 6) {
      return '${body.substring(0, body.length - 3)}.${body.substring(body.length - 3)}-$dv';
    } else {
      return '${body.substring(0, body.length - 6)}.${body.substring(body.length - 6, body.length - 3)}.${body.substring(body.length - 3)}-$dv';
    }
  }

  // Validate RUT format
  static bool isValidRut(String rut) {
    final cleanedRut = cleanRut(rut);
    if (cleanedRut.length < 8 || cleanedRut.length > 9) return false;

    // Check if it's numeric except for the last character (which can be 'k' or 'K')
    final body = cleanedRut.substring(0, cleanedRut.length - 1);
    final dv = cleanedRut.substring(cleanedRut.length - 1);

    if (!RegExp(r'^\d+$').hasMatch(body)) return false;
    if (!RegExp(r'^[\dkK]$').hasMatch(dv)) return false;

    return true;
  }

  Future<Map<String, dynamic>> login(String rut, String password) async {
    try {
      final cleanRut = AuthService.cleanRut(rut);

      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rut': cleanRut, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract token and user data from the nested structure
        final token = responseData['data']?['token'] ?? '';
        final userData = responseData['data']?['user'] ?? {};

        // Store the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', json.encode(userData));

        return {'success': true, 'data': responseData};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error de inicio de sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de red: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
