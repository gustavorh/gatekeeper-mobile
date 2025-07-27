import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../widgets/modular_bottom_nav_bar.dart';

/// Example usage of the modular navigation system
/// This file demonstrates how to use the role-based navigation
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int _selectedIndex = 1;
  List<String> _userRoles = ['user'];

  void _changeRole(String role) {
    setState(() {
      _userRoles = [role];
    });
  }

  void _onNavigationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Show which item was selected
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected index: $index')));
  }

  Map<String, VoidCallback> _getCallbacks() {
    return {
      'history': () => _showMessage('History tapped'),
      'dashboard': () => _showMessage('Dashboard tapped'),
      'profile': () => _showMessage('Profile tapped'),
      'admin': () => _showMessage('Admin panel tapped'),
      'reports': () => _showMessage('Reports tapped'),
      'users': () => _showMessage('Users management tapped'),
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final navigationItems = navigationService.getNavigationItemsForRoles(
      _userRoles,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeRole,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'user', child: Text('User')),
              const PopupMenuItem(
                value: 'supervisor',
                child: Text('Supervisor'),
              ),
              const PopupMenuItem(value: 'admin', child: Text('Admin')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Role: ${_userRoles.join(", ")}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Available Navigation Items:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...navigationItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• ${item.label}'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RoleBasedBottomNavBar(
        userRoles: _userRoles,
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationSelected,
        customCallbacks: _getCallbacks(),
      ),
    );
  }
}

/*
Example usage:

1. User Role (default):
   - History, Dashboard, Profile

2. Supervisor Role:
   - History, Dashboard, Profile, Reports

3. Admin Role:
   - History, Dashboard, Profile, Admin, Reports, Users, Settings

The navigation bar automatically adapts based on the user's roles,
showing only the items that the user has permission to access.
*/
