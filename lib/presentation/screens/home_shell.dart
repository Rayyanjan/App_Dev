import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_models.dart';
import '../providers.dart';
import 'my_bookings_screen.dart';
import 'rooms_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.user});
  final AppUser user;
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final pages = <Widget>[
      RoomsScreen(user: u),
      MyBookingsScreen(user: u),
      if (u.isAdmin) RoomsScreen(user: u, adminView: true),
    ];
    final idx = _i.clamp(0, pages.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: Text(['Rooms', 'My bookings', 'Admin'][idx]),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authActionProvider.notifier).signOut(),
          ),
        ],
      ),
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => _i = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.meeting_room), label: 'Rooms'),
          const NavigationDestination(icon: Icon(Icons.event), label: 'My bookings'),
          if (u.isAdmin)
            const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
