import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user.company.name,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(Icons.phone, 'Phone', user.phone),
            _buildInfoRow(
              Icons.location_on,
              'Address',
              '${user.address.street}, ${user.address.city}',
            ),
            _buildInfoRow(Icons.business, 'Company', user.company.name),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent!')),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15)),
    );
  }
}