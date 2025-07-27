import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.1.122:9000';
  static const String profileEndpoint = '/users/profile';

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al obtener el perfil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Helper method to compute user initials from first and last name
  static String computeUserInitials(String firstName, String lastName) {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  // Helper method to get full name from first and last name
  static String getFullName(String firstName, String lastName) {
    return '$firstName $lastName'.trim();
  }
}
