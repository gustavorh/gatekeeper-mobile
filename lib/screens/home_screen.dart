import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/shift_service.dart';
import '../services/user_service.dart';
import '../services/navigation_service.dart';
import '../utils/timezone_utils.dart';
import '../widgets/modular_bottom_nav_bar.dart';
import '../navigation/app_navigator.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'package:another_flushbar/flushbar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final Function(AppScreen)? onNavigate;

  const HomeScreen({super.key, required this.onLogout, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final ShiftService _shiftService = ShiftService();
  final UserService _userService = UserService();

  Map<String, dynamic>? _currentShift;
  Map<String, dynamic>? _userProfile;
  List<String> _userRoles = [];
  int _selectedNavIndex = 1; // Dashboard is selected by default

  @override
  void initState() {
    super.initState();
    _fetchShiftData();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profileResult = await _userService.getProfile();

      setState(() {
        if (profileResult['success'] && profileResult['data'] != null) {
          _userProfile = profileResult['data'];
          _userRoles = _extractUserRoles(profileResult['data']);
        } else {
          _userProfile = null;
          _userRoles = [];
          if (profileResult['message'] != null) {
            _showNotification(profileResult['message'], isError: true);
          }
        }
      });
    } catch (e) {
      setState(() {
        _userProfile = null;
        _userRoles = [];
      });
      _showNotification(
        'Error al obtener perfil del usuario: $e',
        isError: true,
      );
    }
  }

  List<String> _extractUserRoles(Map<String, dynamic> profileData) {
    try {
      final roles = <String>[];
      final userData = profileData['data'];

      if (userData != null && userData['roles'] != null) {
        for (final role in userData['roles']) {
          if (role['name'] != null) {
            roles.add(role['name']);
          }
        }
      }

      // If no roles found, default to 'user'
      if (roles.isEmpty) {
        roles.add('user');
      }

      return roles;
    } catch (e) {
      return ['user'];
    }
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    // Get the navigation items for current user roles
    final navigationService = NavigationService();
    final navigationItems = navigationService.getNavigationItemsForRoles(
      _userRoles,
    );

    if (index < navigationItems.length) {
      final item = navigationItems[index];
      _navigateToScreen(item.id);
    }
  }

  void _navigateToScreen(String screenId) {
    switch (screenId) {
      case 'history':
        widget.onNavigate?.call(AppScreen.history);
        break;
      case 'dashboard':
        // Already on dashboard
        break;
      case 'profile':
        widget.onNavigate?.call(AppScreen.profile);
        break;
      case 'reports':
        widget.onNavigate?.call(AppScreen.reports);
        break;
      case 'users':
        widget.onNavigate?.call(AppScreen.users);
        break;
    }
  }

  Map<String, VoidCallback> _getNavigationCallbacks() {
    return {
      'history': () => _navigateToScreen('history'),
      'dashboard': () => _navigateToScreen('dashboard'),
      'profile': () => _navigateToScreen('profile'),
      'reports': () => _navigateToScreen('reports'),
      'users': () => _navigateToScreen('users'),
    };
  }

  Future<void> _fetchShiftData() async {
    try {
      final currentShiftResult = await _shiftService.getCurrentShift();

      setState(() {
        if (currentShiftResult['success'] &&
            currentShiftResult['data'] != null) {
          _currentShift = currentShiftResult;
        } else {
          _currentShift = null;
        }
      });
    } catch (e) {
      setState(() {
        _currentShift = null;
      });
      _showNotification('Error al obtener datos del turno: $e', isError: true);
    }
  }

  Future<void> _clockIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _shiftService.clockIn();

      if (result['success']) {
        setState(() {
          // Update the current shift with the new data
          _currentShift = result;
        });
        _showNotification(result['message'], isError: false);
      } else {
        _showNotification(result['message'], isError: true);
      }
    } catch (e) {
      _showNotification('Error al registrar entrada: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clockOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _shiftService.clockOut();

      if (result['success']) {
        setState(() {
          // Clear the current shift since we clocked out
          _currentShift = null;
        });
        _showNotification(result['message'], isError: false);
      } else {
        _showNotification(result['message'], isError: true);
      }
    } catch (e) {
      _showNotification('Error al registrar salida: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
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

  void _handleLogout() {
    // Use the new BLoC-based logout
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    // The main app will handle the state change automatically
  }

  @override
  Widget build(BuildContext context) {
    // Extract user data from profile
    String userName = "Usuario";

    if (_userProfile != null && _userProfile!['data'] != null) {
      final userData = _userProfile!['data'];
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';

      userName = UserService.getFullName(firstName, lastName);
    }

    final greeting = "Dashboard";
    final bool isClockedIn =
        _currentShift != null &&
        _currentShift!['data'] != null &&
        _currentShift!['data']['data'] != null &&
        _currentShift!['data']['data']['status'] == 'active';
    final bool isClockedOut =
        _currentShift == null ||
        _currentShift!['data'] == null ||
        _currentShift!['data']['data'] == null ||
        _currentShift!['data']['data']['status'] != 'active';

    return Scaffold(
      key: ValueKey('home_screen_${_currentShift?.hashCode ?? 'null'}'),
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
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([_fetchShiftData(), _fetchUserProfile()]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Row: Avatar, Greeting, Logout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar and Greeting (centered)
                        Expanded(
                          child: Row(
                            children: [
                              // User Initials Avatar
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getUserInitials(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Greeting and Username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      greeting,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _getUserRole(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout Button (top right)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: GestureDetector(
                              onTap: _handleLogout,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('🚪', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Cerrar sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
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
                    const SizedBox(height: 24),

                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      _currentShift != null &&
                                          _currentShift!['data'] != null &&
                                          _currentShift!['data']!['data'] !=
                                              null &&
                                          _currentShift!['data']!['data']!['status'] ==
                                              'active'
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentShift != null &&
                                        _currentShift!['data'] != null &&
                                        _currentShift!['data']!['data'] !=
                                            null &&
                                        _currentShift!['data']!['data']!['status'] ==
                                            'active'
                                    ? 'Actualmente en Turno'
                                    : 'Actualmente Fuera de Turno',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final now = DateTime.now();
                              final hour = now.hour > 12
                                  ? now.hour - 12
                                  : now.hour == 0
                                  ? 12
                                  : now.hour;
                              final ampm = now.hour >= 12 ? 'PM' : 'AM';
                              final timeStr =
                                  '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampm';
                              return Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF357AFF),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (_isLoading || isClockedIn)
                                ? null
                                : _clockIn,
                            child: Container(
                              height: 90,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isClockedIn
                                    ? Colors.grey[400]
                                    : const Color(0xFF2ECC71),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Marcar Entrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: (_isLoading || isClockedOut)
                                ? null
                                : _clockOut,
                            child: Container(
                              height: 90,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: isClockedOut
                                    ? Colors.grey[400]
                                    : const Color(0xFFF76C6C),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Marcar Salida',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {}, // TODO: Implement lunch break
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD580),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pausa de Almuerzo',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Today's Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Resumen de Hoy",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232946),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _summaryRow(
                            'Hora de Entrada',
                            _currentShift != null &&
                                    _currentShift!['data'] != null &&
                                    _currentShift!['data']!['data'] != null &&
                                    _currentShift!['data']!['data']!['clockInTime'] !=
                                        null
                                ? TimezoneUtils.formatUtcStringToSantiago(
                                    _currentShift!['data']!['data']!['clockInTime']
                                        .toString(),
                                  )
                                : '--:--',
                          ),
                          _summaryRow('Pausa de Almuerzo', '--:-- a --:--'),
                          _summaryRow(
                            'Horas Trabajadas',
                            _currentShift != null &&
                                    _currentShift!['data'] != null &&
                                    _currentShift!['data']!['data'] != null &&
                                    _currentShift!['data']!['data']!['clockInTime'] !=
                                        null &&
                                    _currentShift!['data']!['data']!['status'] ==
                                        'active'
                                ? _formatHoursWorked(
                                    _currentShift!['data']!['data']!['clockInTime'],
                                  )
                                : '0h 0m',
                          ),
                          _summaryRow(
                            'Estado',
                            _currentShift != null &&
                                    _currentShift!['data'] != null &&
                                    _currentShift!['data']!['data'] != null &&
                                    _currentShift!['data']!['data']!['status'] !=
                                        null
                                ? _currentShift!['data']!['data']!['status']
                                      .toString()
                                      .toUpperCase()
                                : 'NO INICIADO',
                            valueBold: true,
                          ),
                        ],
                      ),
                    ),

                    // Loading Overlay
                    if (_isLoading)
                      Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
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
      ),
      bottomNavigationBar: RoleBasedBottomNavBar(
        userRoles: _userRoles,
        selectedIndex: _selectedNavIndex,
        onItemSelected: _onNavigationItemSelected,
        customCallbacks: _getNavigationCallbacks(),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueBold ? Color(0xFF232946) : Color(0xFF6B7280),
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserInitials() {
    if (_userProfile != null && _userProfile!['data'] != null) {
      final userData = _userProfile!['data'];
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';

      return UserService.computeUserInitials(firstName, lastName);
    }
    return 'U'; // Default initial if no user data
  }

  String _getUserRole() {
    if (_userRoles.isNotEmpty) {
      // Capitalize the first letter and make it look nice
      final role = _userRoles.first;
      return role.substring(0, 1).toUpperCase() +
          role.substring(1).toLowerCase();
    }
    return 'User'; // Default role
  }

  String _formatHoursWorked(dynamic clockInTime) {
    try {
      final duration = TimezoneUtils.calculateWorkDuration(
        clockInTime.toString(),
      );
      return TimezoneUtils.formatWorkDuration(duration);
    } catch (e) {
      return '0h 0m';
    }
  }
}
