import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

typedef TokenProvider = String? Function();

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? shared;

  static final http.Client shared = http.Client();
  /// Courses/content payloads can be large on slow links.
  static const Duration receiveTimeout = Duration(seconds: 45);

  final http.Client _client;

  /// Set by [AuthSession] for authenticated calls.
  static TokenProvider? tokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
    Map<String, String>? query,
  }) {
    return _send('GET', path, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _send('PUT', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, String>? query,
  }) async {
    final token = auth ? tokenProvider?.call() : null;

    var uri = Uri.parse(
      path.startsWith('http') ? path : '${ApiConfig.baseUrl}$path',
    );
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...query,
      });
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    late http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(receiveTimeout);
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(receiveTimeout);
        default:
          response =
              await _client.get(uri, headers: headers).timeout(receiveTimeout);
      }
    } on TimeoutException {
      throw const ApiException('زمان پاسخ‌گویی سرور تمام شد');
    } on http.ClientException catch (e) {
      debugPrint('API ClientException: $e');
      throw const ApiException('اتصال به سرور برقرار نشد');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('API error: $e');
      throw const ApiException('اتصال به سرور برقرار نشد');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      throw ApiException(
        'مسیر API روی سرور فعال نیست (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    Map<String, dynamic> decodedBody = const {};
    String? rawError;
    try {
      if (response.bodyBytes.isNotEmpty) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          decodedBody = decoded;
        } else if (decoded is String && decoded.trim().isNotEmpty) {
          rawError = decoded.trim();
        }
      }
    } catch (_) {
      // Non-JSON error body from gateway/proxy.
    }

    if (response.statusCode == 502 || response.statusCode == 503) {
      throw ApiException(
        'سرویس احراز هویت موقتاً قطع است (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        throw ApiException(
          _errorMessage(decodedBody) ??
              rawError ??
              'نشست منقضی شده؛ دوباره وارد شوید',
          statusCode: 401,
        );
      }
      throw ApiException(
        _errorMessage(decodedBody) ??
            rawError ??
            'خطای سرور (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (decodedBody['ok'] == false) {
      throw ApiException(
        _errorMessage(decodedBody) ?? 'درخواست ناموفق بود',
        statusCode: response.statusCode,
      );
    }

    if (decodedBody.isEmpty) {
      throw const ApiException('پاسخ نامعتبر از سرور');
    }

    return decodedBody;
  }

  static String? _errorMessage(Map<String, dynamic> body) {
    final raw = body['error'] ?? body['message'];
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) return null;
    if (text.toLowerCase().contains('failed query') || text.length > 180) {
      return 'خطای سرور؛ لطفاً بعداً تلاش کنید';
    }
    return text;
  }
}
