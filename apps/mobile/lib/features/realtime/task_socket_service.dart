import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/config/app_config.dart';
import '../tasks/presentation/task_providers.dart';

final taskSocketServiceProvider = Provider<TaskSocketService>((ref) {
  final svc = TaskSocketService(ref);
  ref.onDispose(svc.dispose);
  return svc;
});

class TaskSocketService {
  TaskSocketService(this._ref);

  final Ref _ref;
  io.Socket? _socket;
  String? _workspaceId;

  bool get connected => _socket?.connected ?? false;

  void connect({required String workspaceId, required String token}) {
    if (_workspaceId == workspaceId && (_socket?.connected ?? false)) {
      return;
    }
    dispose();
    _workspaceId = workspaceId;
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    _socket = io.io(
      '$base/tasks',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableForceNew()
          .build(),
    );
    _socket!.on('connect', (_) {
      _socket!.emit('task.joinWorkspace', {'workspaceId': workspaceId});
    });
    _socket!.on('task.updated', (_) {
      _ref.read(boardRefreshProvider.notifier).state++;
    });
    _socket!.connect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _workspaceId = null;
  }
}
