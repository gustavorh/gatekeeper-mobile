import 'package:flutter/material.dart';
import '../models/navigation_item.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Define all possible navigation items
  static const List<NavigationItem> _allNavigationItems = [
    NavigationItem(
      id: 'history',
      label: 'Historial',
      emoji: '📊',
      allowedRoles: ['user', 'admin'],
      badgeCount: 3, // TODO: display total shifts
    ),
    NavigationItem(
      id: 'dashboard',
      label: 'Inicio',
      emoji: '🏠',
      allowedRoles: ['user', 'admin'],
    ),
    NavigationItem(
      id: 'profile',
      label: 'Perfil',
      icon: Icons.person,
      allowedRoles: ['user', 'admin'],
    ),
    NavigationItem(
      id: 'reports',
      label: 'Reportes',
      icon: Icons.assessment,
      allowedRoles: ['admin'],
    ),
    NavigationItem(
      id: 'users',
      label: 'Usuarios',
      icon: Icons.people,
      allowedRoles: ['admin'],
    ),
  ];

  /// Get navigation items filtered by user roles
  List<NavigationItem> getNavigationItemsForRoles(List<String> userRoles) {
    return _allNavigationItems
        .where((item) => _hasAnyRole(userRoles, item.allowedRoles))
        .toList();
  }

  /// Get navigation items for a specific role
  List<NavigationItem> getNavigationItemsForRole(String role) {
    return getNavigationItemsForRoles([role]);
  }

  /// Check if user has any of the required roles
  bool _hasAnyRole(List<String> userRoles, List<String> requiredRoles) {
    return userRoles.any((role) => requiredRoles.contains(role));
  }

  /// Get navigation item by ID
  NavigationItem? getNavigationItemById(String id) {
    try {
      return _allNavigationItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update badge count for a specific navigation item
  NavigationItem updateBadgeCount(String itemId, int badgeCount) {
    final item = getNavigationItemById(itemId);
    if (item != null) {
      return item.copyWith(badgeCount: badgeCount);
    }
    return item!;
  }

  /// Get all available roles from navigation items
  List<String> getAllAvailableRoles() {
    final roles = <String>{};
    for (final item in _allNavigationItems) {
      roles.addAll(item.allowedRoles);
    }
    return roles.toList();
  }

  /// Get navigation items with custom onTap callbacks
  List<NavigationItem> getNavigationItemsWithCallbacks(
    List<String> userRoles,
    Map<String, VoidCallback> callbacks,
  ) {
    final items = getNavigationItemsForRoles(userRoles);
    return items.map((item) {
      final callback = callbacks[item.id];
      return item.copyWith(onTap: callback);
    }).toList();
  }
}
