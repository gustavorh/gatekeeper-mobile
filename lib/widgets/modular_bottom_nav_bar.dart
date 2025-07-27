import 'package:flutter/material.dart';
import '../models/navigation_item.dart';
import '../services/navigation_service.dart';

class ModularBottomNavBar extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const ModularBottomNavBar({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (navigationItems.isEmpty) {
      return const SizedBox.shrink();
    }

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navigationItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onItemSelected?.call(index);
                item.onTap?.call();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF3F7FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    item.displayWidgetWithBadge,
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF357AFF)
                            : const Color(0xFF6B7280),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Convenience widget for role-based navigation
class RoleBasedBottomNavBar extends StatelessWidget {
  final List<String> userRoles;
  final int selectedIndex;
  final Function(int)? onItemSelected;
  final Map<String, VoidCallback>? customCallbacks;

  const RoleBasedBottomNavBar({
    super.key,
    required this.userRoles,
    required this.selectedIndex,
    this.onItemSelected,
    this.customCallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final navigationItems = customCallbacks != null
        ? navigationService.getNavigationItemsWithCallbacks(
            userRoles,
            customCallbacks!,
          )
        : navigationService.getNavigationItemsForRoles(userRoles);

    return ModularBottomNavBar(
      navigationItems: navigationItems,
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    );
  }
}
