import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback? onTap;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.count,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return IconButton(
        icon: Icon(icon, color: color ?? Colors.grey.shade700),
        onPressed: onTap,
      );
    }

    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -4, end: -4),
      badgeAnimation: const badges.BadgeAnimation.slide(
        toAnimate: true,
        animationDuration: Duration(milliseconds: 300),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: Colors.red,
        shape: badges.BadgeShape.circle,
        badgeGap: 4,
        padding: const EdgeInsets.all(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.grey.shade700),
        onPressed: onTap,
      ),
      badgeContent: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
