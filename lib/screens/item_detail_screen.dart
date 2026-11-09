import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/item_service.dart';
import '../widgets/status_badge.dart';
import 'item_list_screen.dart' show confirmDelete;

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final String itemId;
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _service = ItemService();
  late final Stream<Item?> _stream = _service.watchItem(widget.itemId);
  bool _busy = false;

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  Future<void> _claim() async {
    setState(() => _busy = true);
    try {
      await _service.markAsClaimed(widget.itemId);
      _snack('Marked as claimed.');
    } on ItemException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Could not claim item: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(Item item) async {
    if (await confirmDelete(context, item.title) != true) return;
    try {
      await _service.deleteItem(item.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Item?>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('${snap.error}')));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        final item = snap.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This item has been deleted.')),
          );
        }
        final color = statusColor(item.status);
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(item),
              ),
            ],
          ),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            Center(
              child: Hero(
                tag: 'icon-${item.id}',
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(categoryIcon(item.category), size: 40, color: color),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: StatusBadge(item.status, key: ValueKey(item.status), large: true),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _row(Icons.category_outlined, 'Category', item.category),
                  const Divider(height: 24),
                  _row(Icons.place_outlined, 'Location', item.location),
                  const Divider(height: 24),
                  _row(Icons.person_outline, 'Posted by', item.postedBy),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Description',
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(item.description.isEmpty ? 'No description.' : item.description,
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            if (item.status != ItemStatus.claimed)
              FilledButton.icon(
                onPressed: _busy ? null : _claim,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.verified_rounded),
                label: const Text('Mark as Claimed'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
          ]),
        );
      },
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Flexible(child: Text(value, textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600))),
      ]);
}
