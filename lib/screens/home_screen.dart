import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/shift_service.dart';
import '../services/user_service.dart';
import '../utils/timezone_utils.dart';
import 'package:another_flushbar/flushbar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final ShiftService _shiftService = ShiftService();
  final UserService _userService = UserService();

  Map<String, dynamic>? _currentShift;
  Map<String, dynamic>? _userProfile;

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
        } else {
          _userProfile = null;
          if (profileResult['message'] != null) {
            _showNotification(profileResult['message'], isError: true);
          }
        }
      });
    } catch (e) {
      setState(() {
        _userProfile = null;
      });
      _showNotification(
        'Error al obtener perfil del usuario: $e',
        isError: true,
      );
    }
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
                          child: Column(
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
                            ],
                          ),
                        ),
                        // Logout Button (top right)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final authService = AuthService();
                                await authService.logout();
                                widget.onLogout();
                              },
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
                                    ? 'Currently Clocked In'
                                    : 'Currently Clocked Out',
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
                                    'Clock In',
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
                                    'Clock Out',
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
                              'Lunch Break',
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
                            "Today's Summary",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232946),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _summaryRow(
                            'Clock In Time',
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
                          _summaryRow('Lunch Break', '--:-- to --:--'),
                          _summaryRow(
                            'Hours Worked',
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
                            'Status',
                            _currentShift != null &&
                                    _currentShift!['data'] != null &&
                                    _currentShift!['data']!['data'] != null &&
                                    _currentShift!['data']!['data']!['status'] !=
                                        null
                                ? _currentShift!['data']!['data']!['status']
                                      .toString()
                                      .toUpperCase()
                                : 'NOT STARTED',
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
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

// Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex; // 0: History, 1: Dashboard, 2: Profile
  const CustomBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 18, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // History (left)
          Expanded(
            child: GestureDetector(
              onTap: () {}, // TODO: Implement navigation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 28)),
                      Positioned(
                        right: -2,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'History',
                    style: TextStyle(
                      color: selectedIndex == 0
                          ? Color(0xFF357AFF)
                          : Color(0xFF6B7280),
                      fontWeight: selectedIndex == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dashboard (center)
          Expanded(
            child: GestureDetector(
              onTap: () {}, // TODO: Implement navigation
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? Color(0xFFF3F7FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: selectedIndex == 1
                            ? Color(0xFF357AFF)
                            : Color(0xFF6B7280),
                        fontWeight: selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Profile (right)
          Expanded(
            child: GestureDetector(
              onTap: () {}, // TODO: Implement navigation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 28, color: Color(0xFF6B7280)),
                  const SizedBox(height: 4),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: selectedIndex == 2
                          ? Color(0xFF357AFF)
                          : Color(0xFF6B7280),
                      fontWeight: selectedIndex == 2
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
