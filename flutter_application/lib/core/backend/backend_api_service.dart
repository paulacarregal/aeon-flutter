import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';

class BackendApiService {
  BackendApiService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  bool get isConfigured => AppConfig.backendUrl.trim().isNotEmpty;

  Future<Map<String, dynamic>> getHealth() async {
    final baseUrl = AppConfig.backendUrl.trim();

    if (baseUrl.isEmpty) {
      throw StateError('BACKEND_URL nao configurado.');
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/api/health'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendApiException(
        statusCode: response.statusCode,
        body: decoded,
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final baseUrl = AppConfig.backendUrl.trim();

    if (baseUrl.isEmpty) {
      throw StateError('BACKEND_URL nao configurado.');
    }

    final authToken =
        await FirebaseAuth.instance.currentUser?.getIdToken();

    final appCheckToken = await _getAppCheckToken();

    final response = await _client.post(
      Uri.parse('$baseUrl/$path'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null)
          'Authorization': 'Bearer $authToken',
        if (appCheckToken != null)
          'X-Firebase-AppCheck': appCheckToken,
      },
      body: jsonEncode(body),
    );

    final decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendApiException(
        statusCode: response.statusCode,
        body: decoded,
      );
    }

    return decoded;
  }

  Future<String?> _getAppCheckToken() async {
    try {
      return await FirebaseAppCheck.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}

class BackendApiException implements Exception {
  final int statusCode;
  final Map<String, dynamic> body;

  const BackendApiException({
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() =>
      'BackendApiException($statusCode, $body)';
}