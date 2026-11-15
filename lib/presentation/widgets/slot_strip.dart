import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_models.dart';
import '../../domain/booking.dart';
import '../providers.dart';
import '../ui_helpers.dart';

class SlotStrip extends ConsumerWidget {
  const SlotStrip({super.key, required this.room, required this.day,
      required this.user, required this.adminView});
  final Room room;
  final DateTime day;
  final AppUser user;
  final bool adminView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(roomDayBookingsProvider((roomId: room.id, day: day)));
    return async.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
      data: (bookings) {
        final byStart = {for (final b in bookings) b.slotStart.millisecondsSinceEpoch: b};
        final now = DateTime.now();
        return Wrap(spacing: 4, runSpacing: 4, children: [
          for (var i = 0; i < kSlotsPerDay; i++)
            _cell(context, ref, DateTime(day.year, day.month, day.day, kDayStartHour, i * kSlotMinutes),
                byStart, now),
        ]);
      },
    );
  }

  Widget _cell(BuildContext context, WidgetRef ref, DateTime start,
      Map<int, Booking> byStart, DateTime now) {
    final b = byStart[start.millisecondsSinceEpoch];
    final past = start.add(const Duration(minutes: kSlotMinutes)).isBefore(now);
    final Color color = b != null
        ? (b.userId == user.uid ? Colors.blue : Colors.red)
        : (past ? Colors.grey.shade400 : Colors.green);

    return Tooltip(
      message: b == null ? 'Free' : (adminView || b.userId == user.uid ? b.userName : 'Booked'),
      child: InkWell(
        onTap: () => _onTap(context, ref, start, b, past),
        child: Container(
          width: 46, height: 34, alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(fmtTime(start), style: const TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, DateTime start,
      Booking? b, bool past) async {
    final actions = ref.read(bookingActionProvider.notifier);
    if (b == null) {
      if (past) return;
      actions.book(roomId: room.id, slotStart: start, userId: user.uid, userName: user.name);
    } else if (adminView) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Force-cancel booking?'),
          content: Text('${b.userName} • ${room.name} • ${fmtDateTime(b.slotStart)}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel it')),
          ],
        ),
      );
      if (ok == true) actions.cancel(b);
    } else if (b.userId == user.uid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cancel it from the My bookings tab')));
    }
  }
}
