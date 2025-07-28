import 'package:flutter/material.dart';
import '../services/shift_service.dart';
import '../services/user_service.dart';
import '../services/navigation_service.dart';
import '../utils/timezone_utils.dart';
import '../widgets/modular_bottom_nav_bar.dart';
import '../navigation/app_navigator.dart';
import 'package:another_flushbar/flushbar.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(AppScreen)? onNavigate;

  const HistoryScreen({super.key, required this.onBack, this.onNavigate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  final ShiftService _shiftService = ShiftService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _shifts = [];
  List<String> _userRoles = [];
  int _selectedNavIndex = 0; // History is selected by default

  @override
  void initState() {
    super.initState();
    _fetchShiftHistory();
    _fetchUserProfile();
  }

  Future<void> _fetchShiftHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _shiftService.getShiftHistory();

      setState(() {
        if (result['success'] && result['data'] != null) {
          final data = result['data'];

          // The shifts are nested in data.data.shifts
          final nestedData = data['data'];
          if (nestedData != null &&
              nestedData['shifts'] != null &&
              nestedData['shifts'] is List) {
            _shifts = List<Map<String, dynamic>>.from(nestedData['shifts']);
          } else {
            _shifts = [];
          }
        } else {
          _shifts = [];
          if (result['message'] != null) {
            _showNotification(result['message'], isError: true);
          }
        }
      });
    } catch (e) {
      setState(() {
        _shifts = [];
      });
      _showNotification('Error al obtener historial: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profileResult = await _userService.getProfile();

      setState(() {
        if (profileResult['success'] && profileResult['data'] != null) {
          _userRoles = _extractUserRoles(profileResult['data']);
        } else {
          _userRoles = ['user']; // Default to user role
          if (profileResult['message'] != null) {
            _showNotification(profileResult['message'], isError: true);
          }
        }
      });
    } catch (e) {
      setState(() {
        _userRoles = ['user']; // Default to user role
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
        // Already on history screen
        break;
      case 'dashboard':
        widget.onNavigate?.call(AppScreen.home);
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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _calculateWorkDuration(String? clockInTime, String? clockOutTime) {
    if (clockInTime == null) return '--:--';

    try {
      final clockIn = TimezoneUtils.utcStringToSantiago(clockInTime);
      final clockOut = clockOutTime != null
          ? TimezoneUtils.utcStringToSantiago(clockOutTime)
          : TimezoneUtils.getCurrentSantiagoTime();

      final duration = clockOut.difference(clockIn);
      return TimezoneUtils.formatWorkDuration(duration);
    } catch (e) {
      return '--:--';
    }
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
                        'Historial de Turnos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _fetchShiftHistory,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
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
                      : _shifts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay turnos registrados',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Los turnos aparecerán aquí cuando\nregistres entradas y salidas',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchShiftHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _shifts.length,
                            itemBuilder: (context, index) {
                              final shift = _shifts[index];
                              final clockInTime = shift['clockInTime']
                                  ?.toString();
                              final clockOutTime = shift['clockOutTime']
                                  ?.toString();
                              final status =
                                  shift['status']?.toString() ?? 'unknown';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with status
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Turno #${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF232946),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: _getStatusColor(status),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _formatStatus(status),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Time details
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTimeCard(
                                            'Entrada',
                                            clockInTime != null
                                                ? TimezoneUtils.formatUtcStringToSantiago(
                                                    clockInTime,
                                                  )
                                                : '--:--',
                                            Icons.login,
                                            Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildTimeCard(
                                            'Salida',
                                            clockOutTime != null
                                                ? TimezoneUtils.formatUtcStringToSantiago(
                                                    clockOutTime,
                                                  )
                                                : '--:--',
                                            Icons.logout,
                                            Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Total hours
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F7FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: const Color(0xFF357AFF),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Total trabajado: ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            _calculateWorkDuration(
                                              clockInTime,
                                              clockOutTime,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF357AFF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
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

  Widget _buildTimeCard(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
