import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/item_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _postedBy = TextEditingController();
  String _category = itemCategories.first;
  ItemStatus _status = ItemStatus.found;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _postedBy.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ItemService().addItem(
        title: _title.text,
        category: _category,
        location: _location.text,
        status: _status,
        description: _description.text,
        postedBy: _postedBy.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an item')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          SegmentedButton<ItemStatus>(
            segments: const [
              ButtonSegment(value: ItemStatus.found, label: Text('I found it'), icon: Icon(Icons.check_circle_outline)),
              ButtonSegment(value: ItemStatus.lost, label: Text('I lost it'), icon: Icon(Icons.search)),
            ],
            selected: {_status},
            onSelectionChanged: (s) => setState(() => _status = s.first),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: _required,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [for (final c in itemCategories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _location,
            decoration: InputDecoration(
                labelText: _status == ItemStatus.found ? 'Where was it found?' : 'Where was it lost?'),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Description', alignLabelWithHint: true),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _postedBy,
            decoration: const InputDecoration(labelText: 'Your name'),
            validator: _required,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: const Text('Post'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
        ]),
      ),
    );
  }
}
