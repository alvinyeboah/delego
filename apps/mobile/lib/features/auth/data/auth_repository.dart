import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final user = body['user'] as Map<String, dynamic>;
    return AuthSession(
      accessToken: body['accessToken'] as String,
      refreshToken: body['refreshToken'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      tenantId: user['tenantId'] as String,
      defaultWorkspaceId: body['defaultWorkspaceId'] as String?,
    );
  }
}
