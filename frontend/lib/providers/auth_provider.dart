// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier() : super(null);

  final AuthService _authService = AuthService(); // ← instance

  // Logout
  void logout() {
    state = null;
  }

  bool _isRefreshing = false;

  Future<void> refreshIfNeeded() async {
    if (_isRefreshing || state == null || !state!.willExpireSoon) return;

    _isRefreshing = true;

    print("this is a testing example!");
    try {
      final newState = await _authService.refreshToken(state!.refreshToken);

      state = newState;
    } catch (_) {
      logout();
    } finally {
      _isRefreshing = false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>(
  (ref) => AuthNotifier(),
);
