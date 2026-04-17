class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.tenantId,
    required this.defaultWorkspaceId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String tenantId;
  final String? defaultWorkspaceId;
}
