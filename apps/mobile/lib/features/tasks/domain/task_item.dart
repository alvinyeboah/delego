import '../../../core/api/delego_json.dart';

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.workspaceId,
    required this.updatedAtIso,
    this.description = '',
    this.assigneeUserId,
    this.version = 1,
    this.createdAtIso,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final String workspaceId;
  final String updatedAtIso;
  final String description;
  final String? assigneeUserId;
  final int version;
  /// Present when API returns `createdAtIso` (task service) or `createdAt` (raw Prisma).
  final String? createdAtIso;

  factory TaskItem.fromMap(Map<String, Object?> map) {
    return TaskItem(
      id: map['id']! as String,
      title: map['title']! as String,
      status: map['status']! as String,
      priority: map['priority']! as String,
      workspaceId: map['workspaceId']! as String,
      updatedAtIso: map['updatedAtIso']! as String,
      description: map['description'] as String? ?? '',
      assigneeUserId: map['assigneeUserId'] as String?,
      version: switch (map['version']) {
        final int v => v,
        final num v => v.toInt(),
        _ => 1,
      },
    );
  }

  /// Task service payloads (`updatedAtIso` / `createdAtIso`) and raw Prisma rows (`updatedAt` / `createdAt`).
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    for (final k in <String>[
      'workspace',
      'statusHistory',
      'priorityScores',
      'comments',
      'attachments',
    ]) {
      m.remove(k);
    }
    final updatedAtIso = m.containsKey('updatedAtIso')
        ? parseRequiredIso(m['updatedAtIso'], 'Task.updatedAtIso')
        : parseRequiredIso(m['updatedAt'], 'Task.updatedAt');
    final createdAtIso = m.containsKey('createdAtIso')
        ? parseOptionalIso(m['createdAtIso'])
        : parseOptionalIso(m['createdAt']);
    return TaskItem(
      id: parseRequiredString(m['id'], 'Task.id'),
      title: parseRequiredString(m['title'], 'Task.title'),
      status: parseRequiredString(m['status'], 'Task.status'),
      priority: parseRequiredString(m['priority'], 'Task.priority'),
      workspaceId: parseRequiredString(m['workspaceId'], 'Task.workspaceId'),
      updatedAtIso: updatedAtIso,
      description: parseOptionalString(m['description']) ?? '',
      assigneeUserId: parseOptionalString(m['assigneeUserId']),
      version: parseRequiredInt(m['version'], 'Task.version'),
      createdAtIso: createdAtIso,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'priority': priority,
      'workspaceId': workspaceId,
      'updatedAtIso': updatedAtIso,
      'description': description,
      'assigneeUserId': assigneeUserId,
      'version': version,
    };
  }
}

