import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_models.dart';
import '../../domain/booking.dart';
import '../providers.dart';
import '../ui_helpers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenBookingActions(context, ref);
    final upcoming = ref.watch(myBookingsProvider(user.uid));
    final past = ref.watch(pastBookingsProvider(user.uid));
    final now = DateTime.now();

    Widget tile(Booking b, {bool canCancel = false}) {
      final status = b.effectiveStatus(now); 
      return ListTile(
        title: Text('${b.roomId}  •  ${fmtDateTime(b.slotStart)}–${fmtTime(b.slotEnd)}'),
        subtitle: Text(status),
        trailing: canCancel && status == 'active' && b.slotStart.isAfter(now)
            ? TextButton(
                onPressed: () => ref.read(bookingActionProvider.notifier).cancel(b),
                child: const Text('Cancel'))
            : null,
      );
    }

    return ListView(children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Upcoming')),
      upcoming.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
        data: (l) => l.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: Text('No upcoming bookings'))
            : Column(children: [for (final b in l) tile(b, canCancel: true)]),
      ),
      const Divider(),
      const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Past')),
      past.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
        data: (s) => Column(children: [
          if (s.items.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No past bookings')),
          for (final b in s.items) tile(b),
          if (s.hasMore)
            TextButton(
              onPressed: () => ref.read(pastBookingsProvider(user.uid).notifier).loadMore(),
              child: const Text('Load more'),
            ),
        ]),
      ),
    ]);
  }
}
