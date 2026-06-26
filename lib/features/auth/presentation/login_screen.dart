import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../home/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiClient _client = ApiClient();
  bool _termsAgreed = true;
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

  void _handleSocialLogin(String provider) {
    HapticFeedback.mediumImpact();
    if (!_termsAgreed) {
      setState(() => _termsAgreed = true);
      return;
    }
    if (AuthSession.hasAccessToken) {
      _goHome();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login needs provider setup. Use Admin Test Login for now.')),
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
      if (accessToken == null || accessToken.isEmpty) {
        throw const ApiClientException(
          statusCode: 500,
          code: 'TOKEN_MISSING',
          message: 'Admin login did not return an access token.',
        );
      }
      AuthSession.setAccessToken(accessToken);
      if (!mounted) return;
      _goHome();
    } on ApiClientException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin test login failed: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin test login failed. Check backend server.')),
      );
    } finally {
      if (mounted) {
        setState(() => _adminLoginLoading = false);
      }
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Start Econo-up',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use Admin Test Login until social provider setup is ready.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 28),
              _buildSocialButton(
                label: 'Continue with Kakao',
                bgColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF3C1E1E),
                onTap: () => _handleSocialLogin('KAKAO'),
              ),
              const SizedBox(height: 14),
              _buildSocialButton(
                label: 'Continue with Apple',
                bgColor: const Color(0xFF111827),
                textColor: Colors.white,
                onTap: () => _handleSocialLogin('APPLE'),
              ),
              const SizedBox(height: 14),
              _buildSocialButton(
                label: 'Continue with Google',
                bgColor: Colors.white,
                textColor: const Color(0xFF111827),
                hasBorder: true,
                onTap: () => _handleSocialLogin('GOOGLE'),
              ),
              const SizedBox(height: 14),
              _buildSocialButton(
                label: _adminLoginLoading ? 'Logging in...' : 'Admin Test Login',
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _termsAgreed,
                    activeColor: const Color(0xFF00EE94),
                    onChanged: (value) => setState(() => _termsAgreed = value ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to terms and privacy policy.',
                      style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: Color(0xFF6A7282)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'Admin Test Login is for internal testing only.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 20),
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
    required VoidCallback onTap,
    bool hasBorder = false,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: const Color(0xFFD0D5E0)) : null,
        ),
        child: child ??
            Text(
              label,
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
            ),
      ),
    );
  }
}
