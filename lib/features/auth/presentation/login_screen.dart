// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
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
  final ApiClient _client = ApiClient();
  bool _termsAgreed = true; // 💡 피그마 시안과 동일하게 기본적으로 체크(true)된 상태로 시작합니다.
  bool _adminLoginLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  Future<void> _handleAdminTestLogin() async {
    HapticFeedback.mediumImpact();
    if (!_termsAgreed) {
      setState(() => _termsAgreed = true);
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
        },
      );
      final accessToken = data['accessToken']?.toString();
      if (accessToken != null && accessToken.isNotEmpty) {
        AuthSession.setAccessToken(accessToken);
        if (!mounted) return;
        _goHome();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin test login failed. Check backend.')),
      );
    } finally {
      if (mounted) {
        setState(() => _adminLoginLoading = false);
      }
    }
  }

  void _handleSocialLogin(String provider) {
    if (!_termsAgreed) {
      // 💡 확정시안에 없는 빨간색 스낵바 경고창을 제거하고,
      // 약관이 해제된 상태에서 클릭 시 자연스럽게 체크를 다시 켜주며 부드럽게 진행합니다.
      setState(() {
        _termsAgreed = true;
      });
    }

    HapticFeedback.mediumImpact();
    // 💡 백엔드 명세서 POST /auth/social/login (EC-0002) 호출 모방:
    // 로그인 성공 시 온보딩 프로필 작성 화면(EC-0002-B)으로 유기적 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(),
      ),
    );
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
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    label: _adminLoginLoading ? '로그인 중...' : 'Admin Test Login (테스트용)',
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
