import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/data/local_database.dart';
import '../../delego_providers.dart';
import '../../tasks/domain/task_item.dart';
import '../../tasks/presentation/task_providers.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  String? _lastCheckpoint;
  bool _busy = false;
  int _queueKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCheckpoint());
  }

  Future<void> _loadCheckpoint() async {
    final v = await LocalDatabase.readMeta('sync_checkpoint');
    if (mounted) setState(() => _lastCheckpoint = v);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final wid = session?.defaultWorkspaceId;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Sync center', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          "Pull the latest tasks from your team's server, or record when two edits disagree so nothing gets lost.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text('Last checkpoint: ${_lastCheckpoint ?? '(none)'}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (_busy || wid == null) ? null : () => _pull(wid),
          child: Text(_busy ? 'Pulling…' : 'Pull from server'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: (_busy || session == null) ? null : () => _openConflictDialog(context, session.userId),
          child: const Text('Record conflict…'),
        ),
        const SizedBox(height: 28),
        Text('Offline queue', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String, Object?>>>(
          key: ValueKey(_queueKey),
          future: ref.read(syncQueueRepositoryProvider).pending(),
          builder: (context, snap) {
            final rows = snap.data ?? [];
            if (rows.isEmpty) {
              return Text('Queue empty', style: Theme.of(context).textTheme.bodySmall);
            }
            return Column(
              children: rows
                  .map(
                    (r) => ListTile(
                      dense: true,
                      title: Text((r['id'] as String?) ?? ''),
                      subtitle: Text(
                        (r['payload'] as String?) ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy ? null : () => _flushCaptureQueue(context),
          child: const Text('Upload queued capture sessions'),
        ),
      ],
    );
  }

  Future<void> _flushCaptureQueue(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final queue = ref.read(syncQueueRepositoryProvider);
    final cap = ref.read(captureRepositoryProvider);
    final pending = await queue.pending();
    var ok = 0;
    var fail = 0;
    for (final row in pending) {
      final id = row['id'] as String?;
      final raw = row['payload'] as String?;
      if (id == null || raw == null) continue;
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if (map['op'] == 'capture.session') {
          await cap.createSession(
            workspaceId: map['workspaceId'] as String,
            imageStorageKey: map['imageStorageKey'] as String,
            createdById: map['createdById'] as String?,
            latitude: (map['latitude'] as num?)?.toDouble(),
            longitude: (map['longitude'] as num?)?.toDouble(),
            deviceModel: map['deviceModel'] as String?,
            capturedAtIso: map['capturedAt'] as String?,
          );
          await queue.remove(id);
          ok++;
        } else {
          fail++;
        }
      } catch (_) {
        fail++;
      }
    }
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Queue flush: $ok uploaded, $fail failed/skipped')),
    );
    setState(() {
      _busy = false;
      _queueKey++;
    });
  }

  Future<void> _pull(String workspaceId) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final sync = ref.read(syncRepositoryProvider);
      final tasksRepo = ref.read(taskRepositoryProvider);
      final result = await sync.pull(workspaceId: workspaceId, sinceIso: _lastCheckpoint);
      for (final item in result.tasks) {
        await tasksRepo.upsertTask(item);
      }
      await LocalDatabase.writeMeta('sync_checkpoint', result.checkpointIso);
      if (!context.mounted) return;
      setState(() => _lastCheckpoint = result.checkpointIso);
      messenger.showSnackBar(
        SnackBar(content: Text('Pulled ${result.tasks.length} task(s); checkpoint updated')),
      );
      ref.read(boardRefreshProvider.notifier).state++;
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Pull failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openConflictDialog(BuildContext context, String userId) async {
    final messenger = ScaffoldMessenger.of(context);
    final tasks = await ref.read(boardTasksProvider.future);
    if (!context.mounted) return;
    if (tasks.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('No tasks to attach conflict to')));
      return;
    }
    var taskId = tasks.first.id;
    final localV = TextEditingController(text: '${tasks.first.version}');
    final serverV = TextEditingController(text: '${tasks.first.version + 1}');
    final resolution = TextEditingController();

    TaskItem taskById(String id) => tasks.firstWhere((t) => t.id == id);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final current = taskById(taskId);
          return AlertDialog(
            title: const Text('Record conflicting edits'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey<String>(taskId),
                    initialValue: taskId,
                    decoration: const InputDecoration(labelText: 'taskId'),
                    items: tasks
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.title, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() {
                        taskId = v;
                        final nt = taskById(taskId);
                        localV.text = '${nt.version}';
                        serverV.text = '${nt.version + 1}';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Selected: ${current.title}', style: Theme.of(ctx).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  TextField(
                    controller: localV,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'localVersion'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serverV,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'serverVersion'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: resolution,
                    decoration: const InputDecoration(labelText: 'resolution (optional)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    final lv = int.tryParse(localV.text.trim());
    final sv = int.tryParse(serverV.text.trim());
    if (lv == null || sv == null) {
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Versions must be integers')));
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await ref.read(syncRepositoryProvider).reportConflict(
            taskId: taskId,
            userId: userId,
            localVersion: lv,
            serverVersion: sv,
            resolution: resolution.text.trim().isEmpty ? null : resolution.text.trim(),
          );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('ConflictRecord ${res.id} created at ${res.createdAtIso}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Conflict failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
