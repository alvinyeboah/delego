import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/task_repository.dart';
import '../domain/task_item.dart';

final _repoProvider = Provider<TaskRepository>((_) => TaskRepository());
final _tasksProvider = FutureProvider<List<TaskItem>>((ref) {
  return ref.read(_repoProvider).getLocalTasks('default-workspace');
});

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(_tasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Delego Tasks')),
      body: tasksAsync.when(
        data: (tasks) => ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text('${task.status} - ${task.priority}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repo = ref.read(_repoProvider);
          final now = DateTime.now().toIso8601String();
          await repo.upsertTask(
            TaskItem(
              id: const Uuid().v4(),
              title: 'Field task at $now',
              status: 'OPEN',
              priority: 'MEDIUM',
              workspaceId: 'default-workspace',
              updatedAtIso: now,
            ),
          );
          ref.invalidate(_tasksProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
