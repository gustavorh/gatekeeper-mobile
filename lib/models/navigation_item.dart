import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData? icon;
  final String? emoji;
  final List<String> allowedRoles;
  final int badgeCount;
  final VoidCallback? onTap;

  const NavigationItem({
    required this.id,
    required this.label,
    this.icon,
    this.emoji,
    required this.allowedRoles,
    this.badgeCount = 0,
    this.onTap,
  });

  Widget get displayWidget {
    if (emoji != null) {
      return Text(emoji!, style: const TextStyle(fontSize: 28));
    } else if (icon != null) {
      return Icon(icon, size: 28, color: const Color(0xFF6B7280));
    } else {
      return const Icon(Icons.help_outline, size: 28, color: Color(0xFF6B7280));
    }
  }

  Widget get displayWidgetWithBadge {
    if (badgeCount > 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          displayWidget,
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return displayWidget;
  }

  NavigationItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    String? emoji,
    List<String>? allowedRoles,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      emoji: emoji ?? this.emoji,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      badgeCount: badgeCount ?? this.badgeCount,
      onTap: onTap ?? this.onTap,
    );
  }
}
