// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../onboarding/presentation/profile_setup_screen.dart';
import '../../home/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const bool _showDevLogin = bool.fromEnvironment('ECONOUP_SHOW_DEV_LOGIN');
  static const String _googleClientId = String.fromEnvironment('ECONOUP_GOOGLE_CLIENT_ID');
  static const String _googleServerClientId = String.fromEnvironment('ECONOUP_GOOGLE_SERVER_CLIENT_ID');

  final ApiClient _client = ApiClient();
  bool _termsAgreed = false;
  bool _adminLoginLoading = false;
  Future<void>? _googleInitializeFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AuthSession.initialize();
      if (mounted && AuthSession.hasAccessToken) {
        _goHome();
      }
    });
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _goOnboardingProfile() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      (_) => false,
    );
  }

  Future<void> _routeAfterLogin(Map<String, dynamic> data) async {
    final accessToken = data['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Missing access token');
    }
    final refreshToken = data['refreshToken']?.toString();

    await AuthSession.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    if (!mounted) return;
    final nextScreen = data['nextScreen']?.toString().toUpperCase();
    if (nextScreen == 'HOME') {
      _goHome();
    } else {
      _goOnboardingProfile();
    }
  }

  Future<void> _handleAdminTestLogin() async {
    HapticFeedback.mediumImpact();
    if (!_termsAgreed) {
      _showTermsRequiredMessage();
      return;
    }
    if (_adminLoginLoading) return;

    setState(() => _adminLoginLoading = true);
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.devLogin,
        body: const {
          'email': 'admin-test@econoup.local',
          'nickname': 'Admin Tester',
          'completeOnboarding': true,
        },
      );
      if (!mounted) return;
      await _routeAfterLogin(data);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('테스트 로그인 실패: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _adminLoginLoading = false);
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (!_termsAgreed) {
      _showTermsRequiredMessage();
      return;
    }

    HapticFeedback.mediumImpact();
    if (provider == 'GOOGLE') {
      await _handleGoogleLogin();
      return;
    }
    if (_showDevLogin) {
      _handleDevOnboardingLogin(provider);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider 로그인은 서버 설정 완료 후 이용할 수 있어요.')),
    );
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitializeFuture ??= GoogleSignIn.instance.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId: _googleServerClientId.isEmpty ? null : _googleServerClientId,
    );
  }

  Future<void> _handleGoogleLogin() async {
    if (_adminLoginLoading) return;

    setState(() => _adminLoginLoading = true);
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const FormatException('Google ID token을 받지 못했습니다.');
      }

      final data = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.googleLogin,
        body: {
          'idToken': idToken,
          'termsAgreed': true,
        },
      );
      if (!mounted) return;
      await _routeAfterLogin(data);
    } on GoogleSignInException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 실패: ${error.description ?? error.code.name}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 실패: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _adminLoginLoading = false);
      }
    }
  }

  void _showTermsRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이용약관 및 개인정보처리방침에 동의해주세요.')),
    );
  }

  Future<void> _handleDevOnboardingLogin(String provider) async {
    if (_adminLoginLoading) return;

    setState(() => _adminLoginLoading = true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.devLogin,
        body: {
          'email': 'qa-${provider.toLowerCase()}-$stamp@econoup.local',
          'nickname': 'QA가입$stamp',
          'completeOnboarding': false,
        },
      );
      if (!mounted) return;
      await _routeAfterLogin(data);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('테스트 로그인 실패: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _adminLoginLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 2. Heading Section (시작하기 / 소셜 계정으로 1초 가입)
              Column(
                children: [
                  const Text(
                    '시작하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 28 / 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '소셜 계정으로 1초 가입',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      height: 16 / 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Social Login Buttons List (카카오, Apple, Google)
              Column(
                children: [
                  // 카카오톡 버튼
                  _buildSocialButton(
                    label: '카카오로 시작하기',
                    bgColor: const Color(0xFFFEE500),
                    textColor: const Color(0xFF3C1E1E),
                    onTap: () => _handleSocialLogin('KAKAO'),
                  ),
                  const SizedBox(height: 16),
                  // Apple 버튼
                  _buildSocialButton(
                    label: 'Apple로 시작하기',
                    bgColor: const Color(0xFF111827),
                    textColor: Colors.white,
                    onTap: () => _handleSocialLogin('APPLE'),
                  ),
                  const SizedBox(height: 16),
                  // Google 버튼
                  _buildSocialButton(
                    label: 'Google로 시작하기',
                    bgColor: Colors.white,
                    textColor: const Color(0xFF111827),
                    hasBorder: true,
                    onTap: () => _handleSocialLogin('GOOGLE'),
                  ),
                  if (_showDevLogin) ...[
                    const SizedBox(height: 16),
                    _buildSocialButton(
                      label: _adminLoginLoading ? '로그인 중...' : '관리자 테스트 로그인 (QA용)',
                      bgColor: const Color(0xFF00EE94),
                      textColor: const Color(0xFF053B2B),
                      onTap: _handleAdminTestLogin,
                      child: _adminLoginLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF053B2B)),
                            )
                          : null,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // 4. Divider (또는)
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD0D5E0),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      '또는',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 16 / 12,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD0D5E0),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Terms Agreement Checkbox & Text Link
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _termsAgreed = !_termsAgreed;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 피그마 맞춤형 커스텀 체크박스 위젯 (Size 16x16)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _termsAgreed ? const Color(0xFFF2FFFA) : Colors.white,
                          border: Border.all(
                            color: _termsAgreed ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: _termsAgreed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 10,
                                color: Color(0xFF00EE94),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // 밑줄 약관 텍스트 (이용약관 및 개인정보처리방침만 각각 밑줄 처리)
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            height: 15 / 12,
                          ),
                          children: [
                            TextSpan(
                              text: '이용약관',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF9CA3AF),
                              ),
                            ),
                            TextSpan(text: ' 및 '),
                            TextSpan(
                              text: '개인정보처리방침',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF9CA3AF),
                              ),
                            ),
                            TextSpan(text: '에 동의합니다.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    bool hasBorder = false,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: hasBorder
                ? const BorderSide(color: Color(0xFFD0D5E0), width: 1.0)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: child ?? Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
