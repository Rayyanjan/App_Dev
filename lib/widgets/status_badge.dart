import 'package:flutter/material.dart';
import '../models/item.dart';

Color statusColor(ItemStatus s) => switch (s) {
      ItemStatus.lost => const Color(0xFFD9534F),
      ItemStatus.found => const Color(0xFF2E9E6B),
      ItemStatus.claimed => const Color(0xFF7A8794),
    };

IconData statusIcon(ItemStatus s) => switch (s) {
      ItemStatus.lost => Icons.search_rounded,
      ItemStatus.found => Icons.check_circle_outline_rounded,
      ItemStatus.claimed => Icons.verified_rounded,
    };

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.large = false});
  final ItemStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 7 : 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(statusIcon(status), size: large ? 18 : 14, color: c),
        const SizedBox(width: 5),
        Text(status.label,
            style: TextStyle(
                color: c, fontWeight: FontWeight.w600, fontSize: large ? 14 : 12)),
      ]),
    );
  }
}

IconData categoryIcon(String c) => switch (c) {
      'Bag' => Icons.backpack_rounded,
      'Accessory' => Icons.watch_rounded,
      'ID Card' => Icons.badge_rounded,
      'Electronics' => Icons.devices_rounded,
      'Keys' => Icons.key_rounded,
      'Book' => Icons.menu_book_rounded,
      'Clothing' => Icons.checkroom_rounded,
      _ => Icons.category_rounded,
    };
