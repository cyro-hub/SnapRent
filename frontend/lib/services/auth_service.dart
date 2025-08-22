import 'package:snap_rent/services/api_service.dart';
import '../models/auth_state.dart';

class AuthService {
  final ApiService _api = ApiService();

  /// Refresh the access token using refreshToken
  Future<AuthState> refreshToken(String refreshToken) async {
    final data = await _api.post('auth/refresh', {
      'refreshToken': refreshToken,
    });

    final tokens = data['data']?['tokens'];
    final user = data['data']?['user'];

    if (tokens == null || user == null) {
      throw Exception("Invalid refresh response: missing tokens or user");
    }

    // Parse expiresIn
    final expiresIn = tokens['expiresIn']?.toString() ?? '15m';
    final expiresAt = parseExpiry(expiresIn);

    return AuthState(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
      expiresAt: expiresAt,
      userId: user["_id"],
    );
  }
}

/// Convert "15m", "1h", "7d" into a DateTime expiry

DateTime parseExpiry(String expiresIn) {
  final now = DateTime.now();

  if (expiresIn.endsWith('m')) {
    final minutes = int.tryParse(expiresIn.replaceAll('m', '')) ?? 15;
    return now.add(Duration(minutes: minutes));
  } else if (expiresIn.endsWith('h')) {
    final hours = int.tryParse(expiresIn.replaceAll('h', '')) ?? 1;
    return now.add(Duration(hours: hours));
  } else if (expiresIn.endsWith('d')) {
    final days = int.tryParse(expiresIn.replaceAll('d', '')) ?? 7;
    return now.add(Duration(days: days));
  }

  // Default to 15 minutes if format unknown
  return now.add(const Duration(minutes: 15));
}
