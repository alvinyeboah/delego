import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../data/task_repository.dart';
import '../domain/task_item.dart';

final _repoProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(apiClientProvider));
});
final _tasksProvider = FutureProvider<List<TaskItem>>((ref) {
  final session = ref.watch(authSessionProvider);
  final workspaceId = session?.defaultWorkspaceId;
  if (workspaceId == null) {
    return <TaskItem>[];
  }
  return ref.read(_repoProvider).getRemoteTasks(workspaceId);
});

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(_tasksProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Board'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authSessionProvider.notifier).state = null;
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Tasks', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.title, style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${task.status} · ${task.priority}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repo = ref.read(_repoProvider);
          final session = ref.read(authSessionProvider);
          final workspaceId = session?.defaultWorkspaceId;
          if (workspaceId == null) {
            return;
          }
          final now = DateTime.now().toIso8601String();
          final created = await repo.createRemoteTask(
            workspaceId: workspaceId,
            title: 'Field task at $now',
          );
          await repo.upsertTask(created);
          ref.invalidate(_tasksProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
