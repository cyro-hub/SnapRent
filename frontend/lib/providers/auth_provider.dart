import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier() : super(null);

  final AuthService _authService = AuthService();
  bool _isRefreshing = false;

  /// Automatically refresh token if needed
  Future<void> refreshIfNeeded(BuildContext context) async {
    if (_isRefreshing || state == null || !state!.willExpireSoon) return;

    _isRefreshing = true;

    try {
      final newState = await _authService.refreshToken(
        state!.refreshToken,
        context,
      );

      state = newState;
    } catch (_) {
      logout(context);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Logout user and redirect
  void logout(BuildContext context) {
    state = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>(
  (ref) => AuthNotifier(),
);
