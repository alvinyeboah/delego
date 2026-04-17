import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/tasks/presentation/task_list_page.dart';

final authStateProvider = StateProvider<bool>((_) => false);

class DelegoApp extends ConsumerWidget {
  const DelegoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'Delego',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: authenticated ? const TaskListPage() : const LoginPage(),
    );
  }
}
