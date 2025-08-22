class AuthState {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthState({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get willExpireSoon =>
      expiresAt.difference(DateTime.now()).inSeconds < 60;
}
