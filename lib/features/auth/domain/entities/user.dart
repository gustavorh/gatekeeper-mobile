import 'package:equatable/equatable.dart';

/// Core User entity representing a user in the domain
class User extends Equatable {
  final String id;
  final String rut;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;

  const User({
    required this.id,
    required this.rut,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });

  /// Get the full name of the user
  String get fullName => '$firstName $lastName'.trim();

  /// Get the user initials for avatars
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role.toLowerCase());

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> requiredRoles) {
    return requiredRoles.any((role) => hasRole(role));
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is supervisor
  bool get isSupervisor => hasRole('supervisor');

  /// Create a copy with updated values
  User copyWith({
    String? id,
    String? rut,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      rut: rut ?? this.rut,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [
    id,
    rut,
    email,
    firstName,
    lastName,
    isActive,
    createdAt,
    updatedAt,
    roles,
  ];

  @override
  String toString() =>
      'User(id: $id, rut: $rut, email: $email, fullName: $fullName)';
}
