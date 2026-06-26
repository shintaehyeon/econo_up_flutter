// lib/core/network/api_client.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';

typedef AccessTokenProvider = Future<String?> Function();

typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedHandler? onUnauthorized,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
        _accessTokenProvider = accessTokenProvider,
        _onUnauthorized = onUnauthorized;

  final http.Client _httpClient;
  final String _baseUrl;
  final AccessTokenProvider? _accessTokenProvider;
  final UnauthorizedHandler? _onUnauthorized;

  Future<T> get<T>(String path, {Map<String, String>? query}) {
    return _send<T>('GET', path, query: query);
  }

  Future<T> post<T>(String path, {Object? body, Map<String, String>? query}) {
    return _send<T>('POST', path, query: query, body: body);
  }

  Future<T> put<T>(String path, {Object? body, Map<String, String>? query}) {
    return _send<T>('PUT', path, query: query, body: body);
  }

  Future<T> delete<T>(String path, {Object? body, Map<String, String>? query}) {
    return _send<T>('DELETE', path, query: query, body: body);
  }

  Future<T> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _headers();
    final encodedBody = body == null ? null : jsonEncode(body);

    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(uri, headers: headers, body: encodedBody),
      'PUT' => await _httpClient.put(uri, headers: headers, body: encodedBody),
      'DELETE' => await _httpClient.delete(uri, headers: headers, body: encodedBody),
      _ => throw ArgumentError('Unsupported HTTP method: $method'),
    };

    return _decode<T>(response);
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final normalizedBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query,
    });
  }

  Future<Map<String, String>> _headers() async {
    final token = await _accessTokenProvider?.call();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<T> _decode<T>(http.Response response) async {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw ApiClientException(
        statusCode: response.statusCode,
        code: 'INVALID_RESPONSE',
        message: 'Server response is not a JSON object.',
      );
    }

    final success = decoded['success'] == true;
    if (!success) {
      if (response.statusCode == 401) {
        await _onUnauthorized?.call();
      }
      final error = decoded['error'];
      throw ApiClientException(
        statusCode: response.statusCode,
        code: error is Map ? '${error['code'] ?? 'API_ERROR'}' : 'API_ERROR',
        message: error is Map ? '${error['message'] ?? 'Request failed.'}' : 'Request failed.',
      );
    }

    return decoded['data'] as T;
  }

  void close() {
    _httpClient.close();
  }
}

class ApiClientException implements Exception {
  const ApiClientException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'ApiClientException($statusCode, $code, $message)';
}
