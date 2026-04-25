import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../data/task_repository.dart';
import '../domain/task_item.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(apiClientProvider));
});

/// Increment to refresh the operations board from anywhere (sync, sockets, etc.).
final boardRefreshProvider = StateProvider<int>((ref) => 0);

final boardTasksProvider = FutureProvider<List<TaskItem>>((ref) async {
  ref.watch(boardRefreshProvider);
  final session = ref.watch(authSessionProvider);
  final workspaceId = session?.defaultWorkspaceId;
  if (workspaceId == null) {
    return <TaskItem>[];
  }
  return ref.read(taskRepositoryProvider).getRemoteTasks(workspaceId);
});
