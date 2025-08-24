import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_rent/screens/token_and_payment/buy_token.dart';
import '../screens/auth/login_screen.dart';

class ApiService {
  final String baseUrl = "http://192.168.8.103:3000/api/v1";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Handle token expiration (401)
  void _handleUnauthorized(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('authToken');
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Handle forbidden (403)
  void _handleForbidden(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BuyTokenScreen()));
  }

  Future<dynamic> get(
    String endpoint,
    BuildContext context, [
    Map<String, String>? queryParams,
  ]) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      _handleForbidden(context);
      return jsonDecode(response.body);
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
    BuildContext context,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/$endpoint');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      _handleForbidden(context);
      return jsonDecode(response.body);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid JSON response: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      final errorMessage = decoded is Map && decoded.containsKey('message')
          ? decoded['message']
          : 'Request failed with status ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
    BuildContext context,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      _handleForbidden(context);
      return jsonDecode(response.body);
    }

    return response;
  }

  Future<http.Response> delete(String endpoint, BuildContext context) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$endpoint"),
      headers: headers,
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(context);
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      _handleForbidden(context);
      return jsonDecode(response.body);
    }

    return response;
  }
}
