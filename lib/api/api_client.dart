import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  static const Duration receiveTimeout = Duration(seconds: 20);

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
      throw ApiException(
        kIsWeb
            ? 'مرورگر به API وصل نشد (CORS یا قطعی سرور). روی Android تست کنید یا CORS را روی سرور باز کنید.'
            : 'اتصال به سرور برقرار نشد',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('API error: $e');
      throw const ApiException('اتصال به سرور برقرار نشد');
    }

    Map<String, dynamic> decodedBody = const {};
    try {
      if (response.bodyBytes.isNotEmpty) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          decodedBody = decoded;
        }
      }
    } catch (_) {
      // Non-JSON body (e.g. HTML 502 gateway page).
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
          _errorMessage(decodedBody) ?? 'نشست منقضی شده؛ دوباره وارد شوید',
          statusCode: 401,
        );
      }
      throw ApiException(
        _errorMessage(decodedBody) ?? 'خطای سرور (${response.statusCode})',
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
