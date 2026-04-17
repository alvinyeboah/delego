import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_session.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/tasks/presentation/task_list_page.dart';

final apiClientProvider = Provider<ApiClient>((_) {
  return ApiClient(baseUrl: AppConfig.apiBaseUrl);
});

final authSessionProvider = StateProvider<AuthSession?>((_) => null);

class DelegoApp extends ConsumerWidget {
  const DelegoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    ref.read(apiClientProvider).setBearerToken(session?.accessToken);
    return MaterialApp(
      title: 'Delego',
      theme: AppTheme.darkElite(),
      home: session != null ? const TaskListPage() : const LoginPage(),
    );
  }
}
