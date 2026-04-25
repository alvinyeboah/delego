import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import '../../app.dart';
import '../capture/presentation/capture_page.dart';
import '../more/command_center_page.dart';
import '../notifications/presentation/notifications_page.dart';
import '../delego_providers.dart';
import '../realtime/task_socket_service.dart';
import '../sync/presentation/sync_page.dart';
import '../tasks/presentation/task_board_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _titles = [
    'Operations board',
    'Capture',
    'Sync',
    'Alerts',
    'Command center',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authSessionProvider);
      final wid = session?.defaultWorkspaceId;
      if (wid != null) {
        ref.read(taskSocketServiceProvider).connect(
              workspaceId: wid,
              token: session!.accessToken,
            );
      }
      unawaited(_registerDeviceTokenWithApi());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              ref.read(taskSocketServiceProvider).dispose();
              ref.read(authSessionProvider.notifier).state = null;
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          TaskBoardPage(),
          CapturePage(),
          SyncPage(),
          NotificationsPage(),
          CommandCenterPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.view_kanban_outlined),
            selectedIcon: Icon(Icons.view_kanban),
            label: 'Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(Icons.photo_camera),
            label: 'Capture',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_alt_outlined),
            selectedIcon: Icon(Icons.sync_alt),
            label: 'Sync',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Command',
          ),
        ],
      ),
    );
  }

  Future<void> _registerDeviceTokenWithApi() async {
    final session = ref.read(authSessionProvider);
    if (session == null) return;
    try {
      final token = await ref.read(deviceTokenServiceProvider).getOrCreateToken();
      final platform = kIsWeb ? 'flutter-web' : 'flutter-${defaultTargetPlatform.name}';
      await ref.read(deviceTokenRepositoryProvider).register(token: token, platform: platform);
    } catch (_) {}
  }
}
