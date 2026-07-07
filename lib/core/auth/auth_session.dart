import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static const String _definedToken = String.fromEnvironment('ECONOUP_ACCESS_TOKEN');
  static const String _accessTokenKey = 'econoup.accessToken';
  static const String _refreshTokenKey = 'econoup.refreshToken';

  static String? _accessToken = _definedToken == '' ? null : _definedToken;
  static String? _refreshToken;
  static bool _initialized = _definedToken != '';

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _initialized = true;
  }

  static Future<String?> accessToken() async {
    await initialize();
    return _accessToken;
  }

  static bool get hasAccessToken => _accessToken != null && _accessToken!.isNotEmpty;

  static Future<void> setTokens({
    required String? accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken == null || accessToken.isEmpty ? null : accessToken;
    _refreshToken = refreshToken == null || refreshToken.isEmpty ? null : refreshToken;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    if (_accessToken == null) {
      await prefs.remove(_accessTokenKey);
    } else {
      await prefs.setString(_accessTokenKey, _accessToken!);
    }
    if (_refreshToken == null) {
      await prefs.remove(_refreshTokenKey);
    } else {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
  }

  static Future<void> setAccessToken(String? token) {
    return setTokens(accessToken: token, refreshToken: _refreshToken);
  }

  static Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
