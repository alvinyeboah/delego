import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../delego_providers.dart';
import '../domain/task_item.dart';
import 'task_providers.dart';

class TaskBoardPage extends ConsumerWidget {
  const TaskBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(boardTasksProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(boardRefreshProvider.notifier).state++;
          await ref.read(boardTasksProvider.future);
        },
        child: tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No tasks yet. Tap + to create one.')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskCard(
                  task: task,
                  onTap: () => _openTaskSheet(context, ref, task),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTask(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }

  Future<void> _openCreateTask(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final session = ref.read(authSessionProvider);
    final wid = session?.defaultWorkspaceId;
    if (wid == null) return;
    String priority = 'MEDIUM';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Create task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(priority),
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
                    DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                    DropdownMenuItem(value: 'CRITICAL', child: Text('CRITICAL')),
                  ],
                  onChanged: (v) => setLocal(() => priority = v ?? 'MEDIUM'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (titleCtrl.text.trim().isEmpty) return;
    try {
      final repo = ref.read(taskRepositoryProvider);
      final created = await repo.createRemoteTask(
        workspaceId: wid,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        priority: priority,
      );
      await repo.upsertTask(created);
      ref.read(boardRefreshProvider.notifier).state++;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _openTaskSheet(BuildContext context, WidgetRef ref, TaskItem task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _TaskDetailSheet(task: task),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 52,
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
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      [
                        task.status,
                        task.priority,
                        'v${task.version}',
                        if (task.createdAtIso != null) 'created ${task.createdAtIso}',
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (task.assigneeUserId != null && task.assigneeUserId!.isNotEmpty)
                      Text('Assignee: ${task.assigneeUserId}', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskDetailSheet extends ConsumerStatefulWidget {
  const _TaskDetailSheet({required this.task});

  final TaskItem task;

  @override
  ConsumerState<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<_TaskDetailSheet> {
  late String _status;
  final _reasonCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _assigneeCtrl.text = widget.task.assigneeUserId ?? '';
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.paddingOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
            if (t.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.description, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_status),
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('IN_PROGRESS')),
                DropdownMenuItem(value: 'BLOCKED', child: Text('BLOCKED')),
                DropdownMenuItem(value: 'REVIEW_REQUIRED', child: Text('REVIEW_REQUIRED')),
                DropdownMenuItem(value: 'DONE', child: Text('DONE')),
                DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
              ],
              onChanged: _busy ? null : (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Status reason (optional)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _assigneeCtrl,
              decoration: const InputDecoration(labelText: 'Assignee user id'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () {
                            final session = ref.read(authSessionProvider);
                            if (session != null) {
                              _assigneeCtrl.text = session.userId;
                            }
                          },
                    child: const Text('Use my user id'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : () => _applyStatus(context),
                child: Text(_busy ? 'Saving…' : 'Update status'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _busy ? null : () => _applyAssign(context),
                child: const Text('Save assignment'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _auditQuick(context),
                child: const Text('Log audit: viewed task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyStatus(BuildContext context) async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      final updated = await repo.updateTaskStatus(
        taskId: widget.task.id,
        status: _status,
        reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      );
      await repo.upsertTask(updated);
      ref.read(boardRefreshProvider.notifier).state++;
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyAssign(BuildContext context) async {
    if (_assigneeCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      final updated = await repo.assignTask(
        taskId: widget.task.id,
        assigneeUserId: _assigneeCtrl.text.trim(),
      );
      await repo.upsertTask(updated);
      ref.read(boardRefreshProvider.notifier).state++;
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assign failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _auditQuick(BuildContext context) async {
    final session = ref.read(authSessionProvider);
    if (session == null) return;
    setState(() => _busy = true);
    try {
      final audit = ref.read(auditRepositoryProvider);
      final row = await audit.log(
        tenantId: session.tenantId,
        actorUserId: session.userId,
        action: 'TASK_VIEWED',
        resource: 'Task',
        resourceId: widget.task.id,
        metadata: {'source': 'mobile', 'title': widget.task.title},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AuditLog ${row.id} at ${row.createdAtIso}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audit failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
