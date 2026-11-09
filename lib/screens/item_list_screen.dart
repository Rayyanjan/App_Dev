import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/item_service.dart';
import '../widgets/status_badge.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});
  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final _service = ItemService();
  late final Stream<List<Item>> _stream = _service.watchItems();
  String _query = '';
  ItemStatus? _filter; // null = All

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  Future<void> _seed() async {
    try {
      final n = await _service.seedIfEmpty();
      _snack(n == 0 ? 'Items already exist — seed skipped.' : 'Seeded $n sample items.');
    } catch (e) {
      _snack('Seeding failed: $e');
    }
  }

  Future<void> _claim(Item item) async {
    try {
      await _service.markAsClaimed(item.id);
      _snack('"${item.title}" marked as claimed.');
    } on ItemException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Could not claim item: $e');
    }
  }

  Future<void> _delete(Item item) async {
    final ok = await confirmDelete(context, item.title);
    if (ok != true) return;
    try {
      await _service.deleteItem(item.id);
      _snack('Item deleted.');
    } catch (e) {
      _snack('Delete failed: $e');
    }
  }

  List<Item> _apply(List<Item> all) {
    final q = _query.trim().toLowerCase();
    return all.where((i) {
      final matchesStatus = _filter == null || i.status == _filter;
      final matchesText = q.isEmpty || i.title.toLowerCase().contains(q);
      return matchesStatus && matchesText; 
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => _seed(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'seed', child: Text('Seed sample data')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddItemScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Post item'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search by title…',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip('All', null, cs),
              for (final s in ItemStatus.values) _chip(s.label, s, cs),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: StreamBuilder<List<Item>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('Something went wrong:\n${snap.error}',
                    textAlign: TextAlign.center));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = _apply(snap.data!);
              if (items.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(snap.data!.isEmpty
                        ? 'No items yet. Post one or seed sample data.'
                        : 'No items match your search.',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ItemCard(
                  item: items[i],
                  onClaim: () => _claim(items[i]),
                  onDelete: () => _delete(items[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip(String label, ItemStatus? value, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == value,
          onSelected: (_) => setState(() => _filter = value),
        ),
      );
}

Future<bool?> confirmDelete(BuildContext context, String title) => showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"$title" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onClaim, required this.onDelete});
  final Item item;
  final VoidCallback onClaim;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(item.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Hero(
              tag: 'icon-${item.id}',
              child: CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(categoryIcon(item.category), color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.place_outlined, size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ]),
                const SizedBox(height: 8),
                StatusBadge(item.status),
              ]),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'claim' ? onClaim() : onDelete(),
              itemBuilder: (_) => [
                if (item.status != ItemStatus.claimed)
                  const PopupMenuItem(value: 'claim', child: Text('Mark as Claimed')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
