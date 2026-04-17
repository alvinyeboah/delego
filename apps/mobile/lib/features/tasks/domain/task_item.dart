class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.workspaceId,
    required this.updatedAtIso,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final String workspaceId;
  final String updatedAtIso;

  factory TaskItem.fromMap(Map<String, Object?> map) {
    return TaskItem(
      id: map['id']! as String,
      title: map['title']! as String,
      status: map['status']! as String,
      priority: map['priority']! as String,
      workspaceId: map['workspaceId']! as String,
      updatedAtIso: map['updatedAtIso']! as String,
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
    };
  }
}
