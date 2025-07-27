import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ShiftService {
  static const String baseUrl = 'http://192.168.1.122:9000';
  static const String clockInEndpoint = '/shifts/clock-in';
  static const String clockOutEndpoint = '/shifts/clock-out';

  Future<Map<String, dynamic>> clockIn() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl$clockInEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'timestamp': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Entrada registrada exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al registrar entrada',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> clockOut() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl$clockOutEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'timestamp': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Salida registrada exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al registrar salida',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getCurrentShift() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/shifts/current'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'No se pudo obtener el turno actual',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getShiftHistory({
    int? limit,
    int? offset,
    String? startDate, // format: YYYY-MM-DD
    String? endDate, // format: YYYY-MM-DD
    String? status, // 'pending', 'active', 'completed'
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/shifts/history',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'No se pudo obtener el historial de turnos',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getActiveShifts({
    int? limit,
    int? offset,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '$baseUrl/admin/shifts/active',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'No se pudo obtener los turnos activos',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllShifts({
    int? limit,
    int? offset,
    String? startDate, // format: YYYY-MM-DD
    String? endDate, // format: YYYY-MM-DD
    String? status, // 'pending', 'active', 'completed'
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/admin/shifts',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'No se pudo obtener todos los turnos',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
