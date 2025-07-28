import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Data model for User entity with JSON serialization
@JsonSerializable()
class UserModel {
  final String id;
  final String rut;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final List<RoleModel>? roles;

  const UserModel({
    required this.id,
    required this.rut,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
  });

  /// Factory constructor for creating UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert UserModel to domain User entity
  User toEntity() {
    return User(
      id: id,
      rut: rut,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isActive: isActive,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      roles: roles?.map((role) => role.name).toList() ?? [],
    );
  }

  /// Create UserModel from domain User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      rut: user.rut,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      isActive: user.isActive,
      createdAt: user.createdAt.toIso8601String(),
      updatedAt: user.updatedAt.toIso8601String(),
      roles: user.roles.map((roleName) => RoleModel(name: roleName)).toList(),
    );
  }
}

/// Data model for Role
@JsonSerializable()
class RoleModel {
  final String? id;
  final String name;
  final String? description;
  final bool? isActive;

  const RoleModel({
    this.id,
    required this.name,
    this.description,
    this.isActive,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
