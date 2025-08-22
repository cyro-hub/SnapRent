import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // final String baseUrl = "https://your-api.com/api/v1";
  final String baseUrl = "http://192.168.8.103:3000/api/v1";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Add token to every request
    };
  }

  Future<dynamic> get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
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
    } catch (e) {
      // Rethrow so the frontend can handle it
      throw Exception(e.toString());
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse("$baseUrl/$endpoint"), headers: headers);
  }
}
