import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class ScreenGuard extends ConsumerWidget {
  final Widget screen;

  const ScreenGuard({super.key, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Background token refresh
    ref.read(authProvider.notifier).refreshIfNeeded();

    return authState != null ? screen : LoginScreen(redirectTo: screen);
  }
}
