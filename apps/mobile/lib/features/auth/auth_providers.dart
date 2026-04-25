import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import 'domain/auth_session.dart';

final apiClientProvider = Provider<ApiClient>((_) {
  return ApiClient(baseUrl: AppConfig.apiBaseUrl);
});

final authSessionProvider = StateProvider<AuthSession?>((_) => null);
