import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/history_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/users_management_screen.dart';

enum AppScreen { home, history, profile, reports, users }

class AppNavigator {
  static final AppNavigator _instance = AppNavigator._internal();
  factory AppNavigator() => _instance;
  AppNavigator._internal();

  AppScreen _currentScreen = AppScreen.home;
  final List<AppScreen> _screenHistory = [];

  AppScreen get currentScreen => _currentScreen;

  void navigateTo(AppScreen screen) {
    _screenHistory.add(_currentScreen);
    _currentScreen = screen;
  }

  void goBack() {
    if (_screenHistory.isNotEmpty) {
      _currentScreen = _screenHistory.removeLast();
    }
  }

  bool get canGoBack => _screenHistory.isNotEmpty;

  void reset() {
    _currentScreen = AppScreen.home;
    _screenHistory.clear();
  }
}

class AppNavigatorWidget extends StatefulWidget {
  final VoidCallback onLogout;

  const AppNavigatorWidget({super.key, required this.onLogout});

  @override
  State<AppNavigatorWidget> createState() => _AppNavigatorWidgetState();
}

class _AppNavigatorWidgetState extends State<AppNavigatorWidget> {
  final AppNavigator _navigator = AppNavigator();

  @override
  Widget build(BuildContext context) {
    switch (_navigator.currentScreen) {
      case AppScreen.home:
        return HomeScreen(
          onLogout: widget.onLogout,
          onNavigate: (screen) {
            setState(() {
              _navigator.navigateTo(screen);
            });
          },
        );
      case AppScreen.history:
        return HistoryScreen(
          onBack: () {
            setState(() {
              _navigator.goBack();
            });
          },
          onNavigate: (screen) {
            setState(() {
              _navigator.navigateTo(screen);
            });
          },
        );
      case AppScreen.profile:
        return ProfileScreen(
          onBack: () {
            setState(() {
              _navigator.goBack();
            });
          },
          onNavigate: (screen) {
            setState(() {
              _navigator.navigateTo(screen);
            });
          },
        );
      case AppScreen.reports:
        return ReportsScreen(
          onBack: () {
            setState(() {
              _navigator.goBack();
            });
          },
          onNavigate: (screen) {
            setState(() {
              _navigator.navigateTo(screen);
            });
          },
        );
      case AppScreen.users:
        return UsersManagementScreen(
          onBack: () {
            setState(() {
              _navigator.goBack();
            });
          },
          onNavigate: (screen) {
            setState(() {
              _navigator.navigateTo(screen);
            });
          },
        );
    }
  }

  Widget _buildPlaceholderScreen(
    String title,
    String message,
    VoidCallback onBack,
  ) {
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
                      onTap: onBack,
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
                        title,
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.construction,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
