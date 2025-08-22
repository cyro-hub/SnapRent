import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_rent/models/auth_state.dart';
import 'package:snap_rent/providers/auth_provider.dart';
import 'package:snap_rent/services/api_service.dart';
import 'package:snap_rent/services/auth_service.dart';
import 'package:snap_rent/widgets/btn_widgets/primary_btn.dart';
import 'package:snap_rent/widgets/btn_widgets/tertiary_btn.dart';
import 'package:snap_rent/widgets/snack_bar.dart';

import '../main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Widget? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final api = ApiService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final data = await api.post('auth', {
        'email': email,
        'password': password,
      });

      // Show backend message
      final message = data['message'] ?? 'Login successful';
      if (mounted) {
        SnackbarHelper.show(context, message);
      }

      final tokens = data['data']?['tokens'];
      final user = data['data']?['user'];

      if (tokens == null || user == null) {
        throw Exception("Invalid login response from server");
      }

      final expiresIn = tokens['expiresIn']?.toString() ?? '15m';
      final expiresAt = parseExpiry(expiresIn);

      // Create AuthState
      final authState = AuthState(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        expiresAt: expiresAt,
        userId: user["_id"],
      );

      // Update Riverpod auth state
      if (mounted) {
        ref.read(authProvider.notifier).state = authState;
      }

      // Save tokens in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', authState.accessToken);
      await prefs.setString('refreshToken', authState.refreshToken);

      // Navigate to protected screen
      if (!mounted) return;
      if (widget.redirectTo != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.redirectTo!),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.show(context, "Login failed", success: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Sign in cancelled")));
        }
        return;
      }

      debugPrint("Google user: ${googleUser.email}");

      // Call your backend to exchange Google token for app tokens
      final data = await api.post('auth/google', {
        'email': googleUser.email,
        'idToken': (await googleUser.authentication).idToken,
      });

      final message = data['message'] ?? 'Login successful';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      final tokens = data['data']?['tokens'];
      final user = data['data']?['user'];

      if (tokens == null || user == null) {
        throw Exception("Invalid login response from server");
      }

      // Convert expiresIn ("1h") to DateTime
      DateTime expiresAt;
      final expiresIn = tokens['expiresIn']?.toString() ?? '1h';
      if (expiresIn.endsWith('h')) {
        final hours = int.tryParse(expiresIn.replaceAll('h', '')) ?? 1;
        expiresAt = DateTime.now().add(Duration(hours: hours));
      } else {
        expiresAt = DateTime.now().add(Duration(hours: 1));
      }

      // Create AuthState
      final authState = AuthState(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        expiresAt: expiresAt,
        userId: user["_id"],
      );

      // Update Riverpod auth state
      if (mounted) {
        ref.read(authProvider.notifier).state = authState;
      }

      // Save tokens in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', authState.accessToken);
      await prefs.setString('refreshToken', authState.refreshToken);

      // Navigate to redirect or MainNavigation
      if (!mounted) return;
      if (widget.redirectTo != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.redirectTo!),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color borderColor = Colors.grey, // default border color
    Color focusedBorderColor = Colors.indigo, // focused border color
  }) {
    const borderRadius = 12.0; // fixed radius
    const iconColor = Colors.indigo; // fixed icon color

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/lock_logo.png',
                      width: 200,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Enter email';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter password';
                        if (value.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryBtn(text: 'Login', onPressed: _login),
                    ),
                    const SizedBox(height: 16),
                    const Text("or"),
                    const SizedBox(height: 16),
                    TertiaryBtn(
                      text: "Continue with Google",
                      icon: Image.asset('assets/google_icon.png', height: 20),
                      onPressed: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterScreen(redirectTo: widget.redirectTo),
                          ),
                        );
                      },
                      child: const Text("Don't have an account? Register"),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
