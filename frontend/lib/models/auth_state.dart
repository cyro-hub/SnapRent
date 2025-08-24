class AuthState {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;

  AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get willExpireSoon =>
      DateTime.now().add(const Duration(minutes: 1)).isAfter(expiresAt);
}
