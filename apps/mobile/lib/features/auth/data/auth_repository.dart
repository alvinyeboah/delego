import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
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
    final body = asStringKeyedMap(response.data, 'POST /auth/login');
    final user = asStringKeyedMap(body['user'], 'POST /auth/login user');
    return AuthSession(
      accessToken: body['accessToken'] as String,
      refreshToken: body['refreshToken'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      tenantId: user['tenantId'] as String,
      defaultWorkspaceId: body['defaultWorkspaceId'] as String?,
    );
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String tenantName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'tenantName': tenantName.trim(),
      },
    );
    final body = asStringKeyedMap(response.data, 'POST /auth/register');
    final user = asStringKeyedMap(body['user'], 'POST /auth/register user');
    return AuthSession(
      accessToken: body['accessToken'] as String,
      refreshToken: body['refreshToken'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      tenantId: user['tenantId'] as String,
      defaultWorkspaceId: body['defaultWorkspaceId'] as String?,
    );
  }

  Future<JwtMeDto> me() async {
    final response = await _apiClient.get('/auth/me');
    return JwtMeDto.fromJson(asStringKeyedMap(response.data, 'GET /auth/me'));
  }
}
