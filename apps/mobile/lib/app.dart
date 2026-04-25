import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/branding/delego_brand.dart';
import 'core/theme/app_theme.dart';
export 'features/auth/auth_providers.dart';
import 'features/auth/auth_providers.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/shell/app_shell.dart';

class DelegoApp extends ConsumerStatefulWidget {
  const DelegoApp({super.key});

  @override
  ConsumerState<DelegoApp> createState() => _DelegoAppState();
}

class _DelegoAppState extends ConsumerState<DelegoApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        FlutterNativeSplash.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    ref.read(apiClientProvider).setBearerToken(session?.accessToken);
    return MaterialApp(
      title: kAppDisplayName,
      theme: AppTheme.darkElite(),
      home: session != null ? const AppShell() : const LoginPage(),
    );
  }
}
