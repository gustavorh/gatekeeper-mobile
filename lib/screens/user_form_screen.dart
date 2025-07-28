import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:another_flushbar/flushbar.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  final VoidCallback? onSave;

  const UserFormScreen({super.key, this.user, this.onSave});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final AdminService _adminService = AdminService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // State variables
  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingRoles = true;
  bool _obscurePassword = true;
  List<Role> _availableRoles = [];
  List<String> _selectedRoleIds = [];

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    if (_isEditing) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _rutController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final user = widget.user!;
    _rutController.text = user.rut;
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _isActive = user.isActive;
    _selectedRoleIds = user.roles?.map((role) => role.id).toList() ?? [];
  }

  Future<void> _loadRoles() async {
    try {
      final result = await _adminService.getRoles(limit: 100);

      if (result['success'] && result['data'] != null) {
        final rolesData =
            result['data']['data']?['roles'] ?? result['data']['roles'] ?? [];
        setState(() {
          _availableRoles = rolesData
              .map<Role>((roleJson) => Role.fromJson(roleJson))
              .toList();
          _isLoadingRoles = false;
        });
      } else {
        setState(() {
          _isLoadingRoles = false;
        });
        _showNotification(
          result['message'] ?? 'Error al cargar roles',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingRoles = false;
      });
      _showNotification('Error de conexión: $e', isError: true);
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate RUT
    if (!AuthService.isValidRut(_rutController.text)) {
      _showNotification('RUT inválido', isError: true);
      return;
    }

    // Validate password for new users
    if (!_isEditing && _passwordController.text.length < 6) {
      _showNotification(
        'La contraseña debe tener al menos 6 caracteres',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanRut = AuthService.cleanRut(_rutController.text);

      Map<String, dynamic> result;

      if (_isEditing) {
        // Update user
        result = await _adminService.updateUser(
          widget.user!.id,
          rut: cleanRut,
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          isActive: _isActive,
          roleIds: _selectedRoleIds,
        );
      } else {
        // Create user
        result = await _adminService.createUser(
          rut: cleanRut,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          roleIds: _selectedRoleIds,
        );
      }

      if (result['success']) {
        // Call onSave before popping to avoid navigation conflicts
        widget.onSave?.call();

        // Pop first, then show notification via callback
        Navigator.of(context).pop(true);

        // Show success message briefly without Flushbar to avoid Navigator conflicts
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Usuario actualizado exitosamente'
                    : 'Usuario creado exitosamente',
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showNotification(
          result['message'] ??
              (_isEditing
                  ? 'Error al actualizar usuario'
                  : 'Error al crear usuario'),
          isError: true,
        );
      }
    } catch (e) {
      _showNotification('Error de conexión: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;

    // Use ScaffoldMessenger instead of Flushbar to avoid Navigator conflicts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _isLoadingRoles
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Personal Information Section
                                const Text(
                                  'Información Personal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // RUT Field
                                TextFormField(
                                  controller: _rutController,
                                  decoration: InputDecoration(
                                    labelText: 'RUT',
                                    hintText: '12345678-9',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.badge),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'RUT es requerido';
                                    }
                                    if (!AuthService.isValidRut(value)) {
                                      return 'RUT inválido';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    // Auto-format RUT as user types
                                    if (value.isNotEmpty) {
                                      final formatted = AuthService.formatRut(
                                        value,
                                      );
                                      if (formatted != value) {
                                        _rutController.value = TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(
                                            offset: formatted.length,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'usuario@ejemplo.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email es requerido';
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(value)) {
                                      return 'Email inválido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // First Name Field
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nombre',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nombre es requerido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Last Name Field
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Apellido',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Apellido es requerido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password Field (only for new users or if editing password)
                                if (!_isEditing)
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (!_isEditing &&
                                          (value == null || value.isEmpty)) {
                                        return 'Contraseña es requerida';
                                      }
                                      if (!_isEditing && value!.length < 6) {
                                        return 'Contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                if (!_isEditing) const SizedBox(height: 16),

                                // Active Status (only for editing)
                                if (_isEditing) ...[
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isActive,
                                        onChanged: (value) {
                                          setState(() {
                                            _isActive = value ?? true;
                                          });
                                        },
                                      ),
                                      const Text('Usuario activo'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Roles Section
                                const Text(
                                  'Roles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Roles Selection
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: _availableRoles.map((role) {
                                      final isSelected = _selectedRoleIds
                                          .contains(role.id);
                                      return CheckboxListTile(
                                        title: Text(role.name),
                                        subtitle: role.description.isNotEmpty
                                            ? Text(role.description)
                                            : null,
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedRoleIds.add(role.id);
                                            } else {
                                              _selectedRoleIds.remove(role.id);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Save Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _saveUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667eea),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          _isEditing
                                              ? 'Actualizar Usuario'
                                              : 'Crear Usuario',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
