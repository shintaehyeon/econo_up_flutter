class AuthSession {
  AuthSession._();

  static const String _definedToken = String.fromEnvironment('ECONOUP_ACCESS_TOKEN');
  static String? _accessToken = _definedToken == '' ? null : _definedToken;

  static Future<String?> accessToken() async => _accessToken;

  static bool get hasAccessToken => _accessToken != null && _accessToken!.isNotEmpty;

  static void setAccessToken(String? token) {
    _accessToken = token == null || token.isEmpty ? null : token;
  }

  static Future<void> clear() async {
    _accessToken = null;
  }
}