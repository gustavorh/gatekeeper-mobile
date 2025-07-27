import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/navigation_service.dart';

void main() {
  group('NavigationService', () {
    test('should return correct navigation items for admin role', () {
      final service = NavigationService();
      final items = service.getNavigationItemsForRole('admin');

      // Admin should have access to all items
      expect(items.length, 7);

      final itemIds = items.map((item) => item.id).toList();
      expect(itemIds, contains('history'));
      expect(itemIds, contains('dashboard'));
      expect(itemIds, contains('profile'));
      expect(itemIds, contains('admin'));
      expect(itemIds, contains('reports'));
      expect(itemIds, contains('users'));
      expect(itemIds, contains('settings'));
    });

    test('should return correct navigation items for user role', () {
      final service = NavigationService();
      final items = service.getNavigationItemsForRole('user');

      // User should only have access to basic items
      expect(items.length, 3);

      final itemIds = items.map((item) => item.id).toList();
      expect(itemIds, contains('history'));
      expect(itemIds, contains('dashboard'));
      expect(itemIds, contains('profile'));
      expect(itemIds, isNot(contains('admin')));
      expect(itemIds, isNot(contains('users')));
      expect(itemIds, isNot(contains('settings')));
    });

    test('should return correct navigation items for supervisor role', () {
      final service = NavigationService();
      final items = service.getNavigationItemsForRole('supervisor');

      // Supervisor should have access to reports but not admin items
      expect(items.length, 4);

      final itemIds = items.map((item) => item.id).toList();
      expect(itemIds, contains('history'));
      expect(itemIds, contains('dashboard'));
      expect(itemIds, contains('profile'));
      expect(itemIds, contains('reports'));
      expect(itemIds, isNot(contains('admin')));
      expect(itemIds, isNot(contains('users')));
      expect(itemIds, isNot(contains('settings')));
    });

    test('should return correct navigation items for multiple roles', () {
      final service = NavigationService();
      final items = service.getNavigationItemsForRoles(['user', 'supervisor']);

      // Should have access to items from both roles
      expect(items.length, 4);

      final itemIds = items.map((item) => item.id).toList();
      expect(itemIds, contains('history'));
      expect(itemIds, contains('dashboard'));
      expect(itemIds, contains('profile'));
      expect(itemIds, contains('reports'));
    });

    test('should get navigation item by ID', () {
      final service = NavigationService();
      final item = service.getNavigationItemById('dashboard');

      expect(item, isNotNull);
      expect(item!.id, 'dashboard');
      expect(item.label, 'Dashboard');
      expect(item.emoji, '🏠');
    });

    test('should return null for non-existent item ID', () {
      final service = NavigationService();
      final item = service.getNavigationItemById('non-existent');

      expect(item, isNull);
    });

    test('should get all available roles', () {
      final service = NavigationService();
      final roles = service.getAllAvailableRoles();

      expect(roles, contains('user'));
      expect(roles, contains('admin'));
      expect(roles, contains('supervisor'));
    });

    test('should update badge count for navigation item', () {
      final service = NavigationService();
      final originalItem = service.getNavigationItemById('history');

      expect(originalItem!.badgeCount, 3);

      final updatedItem = service.updateBadgeCount('history', 5);
      expect(updatedItem.badgeCount, 5);
    });
  });
}
