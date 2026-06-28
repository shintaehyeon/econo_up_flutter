// lib/features/onboarding/presentation/profile_setup_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import 'interests_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final ApiClient _client;

  // 피그마 시안의 예시 가이드 반영 (닉네임 힌트: "ex) 경제왕", 나이 힌트: "ex) 26", 성별 기본값: "MALE")
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'MALE'; // MALE | FEMALE
  Timer? _debounceTimer;

  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable; // 💡 비어있으므로 초기 검증 상태는 null로 시작합니다.
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _nicknameController.addListener(_onNicknameChanged);
  }

  void _onNicknameChanged() {
    final text = _nicknameController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isNicknameAvailable = null;
        _isCheckingNickname = false;
      });
      return;
    }

    // 💡 백엔드 명세서 EC-0002-B (디바운싱): 500ms 동안 입력을 멈췄을 때만 API 조회
    _debounceTimer?.cancel();
    setState(() {
      _isCheckingNickname = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _checkNicknameAvailability(text);
    });
  }

  Future<void> _checkNicknameAvailability(String nickname) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.checkNickname,
        query: {'nickname': nickname},
      );
      if (!mounted || _nicknameController.text.trim() != nickname) return;
      setState(() {
        _isCheckingNickname = false;
        _isNicknameAvailable = data['available'] == true;
      });
    } catch (_) {
      if (!mounted || _nicknameController.text.trim() != nickname) return;
      setState(() {
        _isCheckingNickname = false;
        _isNicknameAvailable = false;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_isSubmitting) return;
    final nickname = _nicknameController.text.trim();
    final ageText = _ageController.text.trim();

    if (nickname.isEmpty || _isNicknameAvailable != true) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '사용 가능한 닉네임을 입력해 주세요.',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (ageText.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '나이를 입력해 주세요.',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final age = int.tryParse(ageText) ?? 26;

    // 💡 백엔드 명세서 PUT /onboarding/profile 호출 데이터 연동 체크
    final requestPayload = {
      "nickname": nickname,
      "gender": _gender,
      "age": age
    };
    debugPrint('Submitting Profile to ${ApiEndpoints.onboardingProfile}: $requestPayload');

    HapticFeedback.mediumImpact();

    setState(() => _isSubmitting = true);
    try {
      await _client.put<Map<String, dynamic>>(
        ApiEndpoints.onboardingProfile,
        body: requestPayload,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterestsScreen(nickname: nickname),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '프로필 저장에 실패했어요. 로그인 상태와 서버 연결을 확인해주세요.',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    _ageController.dispose();
    _debounceTimer?.cancel();
    _client.close();
    super.dispose();
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
              // 1. Progress Bar Section (Figma: padding 12px 24px 0px)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E8F0),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 1 / 6, // 1 / 6 단계 활성화
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00EE94),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        '1 / 6',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Main Scrollable Content Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading Section (반가워요! 🎉 / 기본 정보를 알려주세요)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '반가워요! 🎉',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                height: 28 / 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '기본 정보를 알려주세요',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                                height: 16 / 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '나중에 설정에서 변경할 수 있어요',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                                height: 13 / 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Input Fields Group
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3.1. 닉네임 입력 영역
                          const Text(
                            '닉네임',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                              height: 13 / 9,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _nicknameController,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                              ),
                              decoration: InputDecoration(
                                hintText: 'ex) 경제왕',
                                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_nicknameController.text.length}/20자',
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      if (_buildNicknameSuffix() != null) ...[
                                        const SizedBox(width: 8),
                                        _buildNicknameSuffix()!,
                                      ],
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFD0D5E0), width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFD0D5E0), width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF00EE94), width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildAvailabilityFeedback(),

                          const SizedBox(height: 20),

                          // 3.2. 성별 입력 영역
                          const Text(
                            '성별',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                              height: 11 / 9,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderButton(
                                  label: '남성',
                                  value: 'MALE',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGenderButton(
                                  label: '여성',
                                  value: 'FEMALE',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 3.3. 나이 입력 영역
                          const Text(
                            '나이',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                              height: 11 / 9,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                              ),
                              decoration: InputDecoration(
                                hintText: 'ex) 26',
                                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '세',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFD0D5E0), width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFD0D5E0), width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF00EE94), width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 4. 정보 알림 배너
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FFFA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '나이는 콘텐츠 추천에만 활용되며 외부에 공개되지 않아요',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0DE593),
                            height: 15 / 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. 다음 완료 버튼 (Figma: bottom 0px, padding 24px 0px 0px)
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00EE94),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _submitProfile,
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required String value,
  }) {
    final isSelected = _gender == value;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
            width: isSelected ? 2.0 : 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            _gender = value;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF4B5563),
            height: 16 / 12,
          ),
        ),
      ),
    );
  }

  Widget? _buildNicknameSuffix() {
    if (_isCheckingNickname) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00EE94)),
        ),
      );
    }
    if (_isNicknameAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: Color(0xFF00EE94), size: 14);
    }
    if (_isNicknameAvailable == false) {
      return const Icon(Icons.error_rounded, color: AppColors.danger, size: 14);
    }
    return null;
  }

  Widget _buildAvailabilityFeedback() {
    if (_isNicknameAvailable == true) {
      return const Padding(
        padding: EdgeInsets.only(left: 6.0),
        child: Text(
          '멋진 닉네임이네요! 사용 가능합니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            color: Color(0xFF00EE94),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (_isNicknameAvailable == false) {
      return const Padding(
        padding: EdgeInsets.only(left: 6.0),
        child: Text(
          '이미 존재하거나 사용할 수 없는 닉네임입니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            color: AppColors.danger,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
