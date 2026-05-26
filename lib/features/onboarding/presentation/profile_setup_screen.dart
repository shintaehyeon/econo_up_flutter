// lib/features/onboarding/presentation/profile_setup_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import 'interests_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nicknameController = TextEditingController();
  Timer? _debounceTimer;

  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable;
  String _gender = 'MALE'; // MALE | FEMALE | UNDEFINED
  double _age = 25.0;

  @override
  void initState() {
    super.initState();
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
    // 💡 백엔드 GET /users/nickname-availability?nickname={nickname} API 호출 모방
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _isCheckingNickname = false;
      // 단순 검증 규칙: 2글자 이상이고 'admin'이 아니면 가용한 것으로 처리
      _isNicknameAvailable = nickname.length >= 2 && !nickname.toLowerCase().contains('admin');
    });
  }

  Future<void> _submitProfile() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || _isNicknameAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('사용 가능한 닉네임을 입력해 주세요.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 💡 백엔드 명세서 PUT /onboarding/profile 호출 데이터 연동 체크
    final requestPayload = {
      "nickname": nickname,
      "gender": _gender,
      "age": _age.toInt()
    };
    debugPrint('Submitting Profile to ${ApiEndpoints.onboardingProfile}: $requestPayload');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('프로필 저장 완료: $nickname (${_age.toInt()}세, $_gender)'),
        backgroundColor: AppColors.mint,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InterestsScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 설정',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '어떻게 불러드리면 될까요? 👀',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 1. 닉네임 입력 및 중복 검사 결과 노출 영역
                      const Text(
                        '닉네임',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nicknameController,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText: '경제왕 길동이',
                          filled: true,
                          fillColor: AppColors.paper,
                          suffixIcon: _buildNicknameSuffix(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAvailabilityFeedback(),

                      const SizedBox(height: 36),

                      // 2. 성별 선택 카드 영역 (MALE | FEMALE)
                      const Text(
                        '성별',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderCard(
                              label: '남성',
                              value: 'MALE',
                              icon: Icons.male_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderCard(
                              label: '여성',
                              value: 'FEMALE',
                              icon: Icons.female_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // 3. 나이 선택 슬라이더 영역
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '나이',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '만 ${_age.toInt()}세',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Slider(
                          value: _age,
                          min: 15.0,
                          max: 80.0,
                          activeColor: AppColors.brand,
                          inactiveColor: AppColors.line,
                          onChanged: (val) {
                            setState(() {
                              _age = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 저장하기 완료 버튼
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitProfile,
                  child: const Text(
                    '프로필 저장 및 계속하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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

  Widget? _buildNicknameSuffix() {
    if (_isCheckingNickname) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
          ),
        ),
      );
    }
    if (_isNicknameAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.mint);
    }
    if (_isNicknameAvailable == false) {
      return const Icon(Icons.error_rounded, color: AppColors.danger);
    }
    return null;
  }

  Widget _buildAvailabilityFeedback() {
    if (_isNicknameAvailable == true) {
      return const Text(
        '멋진 닉네임이네요! 사용 가능합니다.',
        style: TextStyle(fontSize: 12, color: AppColors.mint, fontWeight: FontWeight.w600),
      );
    }
    if (_isNicknameAvailable == false) {
      return const Text(
        '이미 존재하거나 사용할 수 없는 닉네임입니다.',
        style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGenderCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 104,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.line,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.brand : AppColors.muted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.brand : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
