import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../navigation/app_navigator.dart';
import 'package:another_flushbar/flushbar.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(AppScreen)? onNavigate;

  const ProfileScreen({super.key, required this.onBack, this.onNavigate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();

  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _rutController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileResult = await _userService.getProfile();

      if (profileResult['success'] && profileResult['data'] != null) {
        final userData = profileResult['data']['data'];
        setState(() {
          _userProfile = profileResult['data'];
          // Populate form fields with current user data
          _emailController.text = userData['email'] ?? '';
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _rutController.text = userData['rut'] ?? '';
        });
      } else {
        _showNotification(
          profileResult['message'] ?? 'Error al cargar el perfil',
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final result = await _userService.updateProfile(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (result['success']) {
        _showNotification(
          result['message'] ?? 'Perfil actualizado exitosamente',
          isError: false,
        );
        // Refresh profile data
        await _fetchUserProfile();
      } else {
        _showNotification(
          result['message'] ?? 'Error al actualizar perfil',
          isError: true,
        );
      }
    } catch (e) {
      _showNotification('Error de conexión: $e', isError: true);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade600,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    ).show(context);
  }

  String _getUserInitials() {
    if (_userProfile != null && _userProfile!['data'] != null) {
      final userData = _userProfile!['data'];
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      return UserService.computeUserInitials(firstName, lastName);
    }
    return 'U';
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
                      onTap: widget.onBack,
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
                    const Expanded(
                      child: Text(
                        'Mi Perfil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF667eea),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Avatar Section
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF667eea,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF667eea),
                                            width: 3,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getUserInitials(),
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF667eea),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        UserService.getFullName(
                                          _firstNameController.text,
                                          _lastNameController.text,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF232946),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _emailController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Form Fields
                                const Text(
                                  'Información Personal',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF232946),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // RUT Field (Read-only)
                                _buildInputField(
                                  label: 'RUT',
                                  controller: _rutController,
                                  icon: Icons.badge_outlined,
                                  enabled: false,
                                  helperText: 'El RUT no se puede modificar',
                                ),
                                const SizedBox(height: 16),

                                // Email Field
                                _buildInputField(
                                  label: 'Correo Electrónico',
                                  controller: _emailController,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El correo electrónico es requerido';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Ingrese un correo electrónico válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // First Name Field
                                _buildInputField(
                                  label: 'Nombres',
                                  controller: _firstNameController,
                                  icon: Icons.person_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Los nombres son requeridos';
                                    }
                                    if (value.trim().length > 100) {
                                      return 'Los nombres no pueden exceder 100 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Last Name Field
                                _buildInputField(
                                  label: 'Apellidos',
                                  controller: _lastNameController,
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Los apellidos son requeridos';
                                    }
                                    if (value.trim().length > 100) {
                                      return 'Los apellidos no pueden exceder 100 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Update Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isUpdating
                                        ? null
                                        : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667eea),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isUpdating
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Actualizar Perfil',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF232946),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? const Color(0xFF667eea) : Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            helperText: helperText,
            helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ],
    );
  }
}
