// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../onboarding/presentation/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _termsAgreed = false;

  void _handleSocialLogin(String provider) {
    if (!_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('필수 약관 및 개인정보 처리방침에 동의해 주세요.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경 기하학적 그라데이션 장식 (Aesthetics)
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandSoft.withOpacity(0.4),
                blurRadius: 90,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // 브랜딩 헤더
                  Column(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 56,
                        color: AppColors.brand,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '소셜 계정으로 로그인하고 이코노업에 동참하세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  
                  // 약관 동의 체크박스 영역 (기획안 연동)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line, width: 1.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _termsAgreed = !_termsAgreed;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _termsAgreed,
                            onChanged: (val) {
                              setState(() {
                                _termsAgreed = val ?? false;
                              });
                            },
                            activeColor: AppColors.brand,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              '[필수] 이용약관 및 개인정보 수집/이용 동의',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 소셜 로그인 버튼 리스트
                  _buildSocialButton(
                    logo: Icons.chat_bubble_rounded,
                    label: '카카오톡으로 로그인',
                    bgColor: const Color(0xFFFEE500),
                    textColor: const Color(0xFF191919),
                    onTap: () => _handleSocialLogin('KAKAO'),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    logo: Icons.g_mobiledata_rounded,
                    label: 'Google로 로그인',
                    bgColor: Colors.white,
                    textColor: AppColors.ink,
                    hasBorder: true,
                    onTap: () => _handleSocialLogin('GOOGLE'),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialButton(
                    logo: Icons.apple_rounded,
                    label: 'Apple로 로그인',
                    bgColor: Colors.black,
                    textColor: Colors.white,
                    onTap: () => _handleSocialLogin('APPLE'),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData logo,
    required String label,
    required Color bgColor,
    required Color textColor,
    bool hasBorder = false,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: hasBorder 
              ? const BorderSide(color: AppColors.line, width: 1.0) 
              : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(logo, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
