import 'package:flutter/material.dart';
 
import 'todo.dart';
import 'todo_repository.dart';
 
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
 
  @override
  State<TodoPage> createState() => _TodoPageState();
}
 
class _TodoPageState extends State<TodoPage> {
  final _repo = TodoRepository();
  final _controller = TextEditingController();
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    _controller.clear();
    await _repo.add(title);
  }
 
  Future<void> _rename(Todo todo) async {
    final editController = TextEditingController(text: todo.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename todo'),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    editController.dispose();
    if (newTitle != null && newTitle.isNotEmpty) {
      await _repo.rename(todo, newTitle);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: _repo.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data!;
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos yet'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo.done,
                        onChanged: (_) => _repo.toggleDone(todo),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration:
                              todo.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      onTap: () => _rename(todo),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _repo.remove(todo),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 