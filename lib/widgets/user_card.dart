import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isFavorite;
  final VoidCallback onTap;           // called when the whole card is tapped
  final VoidCallback onFavoriteToggle; // called when the heart icon is tapped

  const UserCard({
    super.key,
    required this.user,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  // Small helper: turns "Leanne Graham" into "LG" for the avatar.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap, // requirement: tapping the item navigates to Detail Screen
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            _getInitials(user.name),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteToggle, // requirement: toggles favorite state
        ),
      ),
    );
  }
}