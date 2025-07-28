import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AdminService {
  static const String baseUrl = 'http://192.168.1.122:9000';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminRolesEndpoint = '/admin/roles';

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl$adminUsersEndpoint',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
          'message': errorData['message'] ?? 'Error al obtener usuarios',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl$adminUsersEndpoint/$userId/with-roles'),
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
          'message': errorData['message'] ?? 'Error al obtener usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String rut,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    List<String>? roleIds,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final body = <String, dynamic>{
        'rut': rut,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };
      if (roleIds != null && roleIds.isNotEmpty) {
        body['roleIds'] = roleIds;
      }

      final response = await http.post(
        Uri.parse('$baseUrl$adminUsersEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al crear usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId, {
    String? rut,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    List<String>? roleIds,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final body = <String, dynamic>{};
      if (rut != null) body['rut'] = rut;
      if (email != null) body['email'] = email;
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (isActive != null) body['isActive'] = isActive;
      if (roleIds != null) body['roleIds'] = roleIds;

      final response = await http.put(
        Uri.parse('$baseUrl$adminUsersEndpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al actualizar usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$adminUsersEndpoint/$userId'),
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
          'message': errorData['message'] ?? 'Error al eliminar usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getRoles({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No hay sesión activa'};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl$adminRolesEndpoint',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
          'message': errorData['message'] ?? 'Error al obtener roles',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
