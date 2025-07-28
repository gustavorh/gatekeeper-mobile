class User {
  final String id;
  final String rut;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Role>? roles;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      rut: json['rut'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      roles: json['roles'] != null
          ? (json['roles'] as List)
                .map((roleJson) => Role.fromJson(roleJson))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rut': rut,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? rut,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Role>? roles,
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
  String toString() {
    return 'User{id: $id, rut: $rut, email: $email, firstName: $firstName, lastName: $lastName, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Role {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Permission>? permissions;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
                .map((permJson) => Permission.fromJson(permJson))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'permissions': permissions?.map((perm) => perm.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Role{id: $id, name: $name, description: $description, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Permission {
  final String id;
  final String name;
  final String description;
  final String resource;
  final String action;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.resource,
    required this.action,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      resource: json['resource'] ?? '',
      action: json['action'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'resource': resource,
      'action': action,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Permission{id: $id, name: $name, resource: $resource, action: $action}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permission && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Utility class for user creation/update operations
class UserFormData {
  String rut;
  String email;
  String password;
  String firstName;
  String lastName;
  bool isActive;
  List<String> roleIds;

  UserFormData({
    this.rut = '',
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.isActive = true,
    this.roleIds = const [],
  });

  bool get isValid {
    return rut.isNotEmpty &&
        email.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty;
  }

  Map<String, dynamic> toCreateJson() {
    final data = <String, dynamic>{
      'rut': rut,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
    if (roleIds.isNotEmpty) {
      data['roleIds'] = roleIds;
    }
    return data;
  }

  Map<String, dynamic> toUpdateJson({bool includePassword = false}) {
    final data = <String, dynamic>{
      'rut': rut,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isActive': isActive,
    };
    if (includePassword && password.isNotEmpty) {
      data['password'] = password;
    }
    if (roleIds.isNotEmpty) {
      data['roleIds'] = roleIds;
    }
    return data;
  }

  factory UserFormData.fromUser(User user) {
    return UserFormData(
      rut: user.rut,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      isActive: user.isActive,
      roleIds: user.roles?.map((role) => role.id).toList() ?? [],
    );
  }
}
