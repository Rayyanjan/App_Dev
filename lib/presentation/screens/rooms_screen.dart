import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_models.dart';
import '../providers.dart';
import '../ui_helpers.dart';
import '../widgets/slot_strip.dart';

const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];


class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key, required this.user, this.adminView = false});
  final AppUser user;
  final bool adminView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenBookingActions(context, ref);
    final day = ref.watch(selectedDateProvider);
    final rooms = ref.watch(roomsProvider);
    final today = dateOnly(DateTime.now());

    return Column(children: [
      SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: 7,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = DateTime(today.year, today.month, today.day + i);
            return ChoiceChip(
              label: Text(i == 0 ? 'Today' : '${_wd[d.weekday - 1]} ${d.day}'),
              selected: d == day,
              onSelected: (_) => ref.read(selectedDateProvider.notifier).state = d,
            );
          },
        ),
      ),
      const _Legend(),
      Expanded(
        child: rooms.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final r in list)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${r.name}  •  Floor ${r.floor}  •  Capacity ${r.capacity}',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SlotStrip(room: r, day: day, user: user, adminView: adminView),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 12, color: c),
          const SizedBox(width: 4),
          Text(t, style: const TextStyle(fontSize: 12)),
        ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(spacing: 16, children: [
        dot(Colors.green, 'Free'),
        dot(Colors.red, 'Booked'),
        dot(Colors.blue, 'Mine'),
        dot(Colors.grey, 'Passed'),
      ]),
    );
  }
}
