// lib/features/onboarding/presentation/interests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../level_test/presentation/level_test_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  int _currentStep = 1; // 1 ~ 4 단계 (실질적인 온보딩 2/6 ~ 5/6 단계에 매핑)
  final int _totalSteps = 4;

  // 선택된 상태 변수들
  final List<String> _selectedInterests = [];
  String _selectedGoal = '';
  String _selectedStudyStyle = '';
  String _selectedFailureReason = '';

  // 1단계: 관심사 데이터 정의 (피그마 시안 반영)
  final List<Map<String, dynamic>> _interestsData = [
    {'code': 'ECONOMY', 'title': '📊 경제 상식'},
    {'code': 'SAVING', 'title': '💰 저축'},
    {'code': 'STOCK', 'title': '📈 주식'},
    {'code': 'REAL_ESTATE', 'title': '🏠 부동산'},
    {'code': 'TAX', 'title': '🧾 세금'},
  ];

  // 2단계: 핵심 목표 데이터 정의 (💸 손실 예방, 📈 재테크 시작, 🏦 실생활 대비, 🎓 자기 개발)
  final List<Map<String, String>> _goalsData = [
    {'code': 'LOSS_PREVENTION', 'emoji': '💸', 'title': '손실 예방', 'desc': '투자 전 제대로 알고 싶어요'},
    {'code': 'START_INVESTING', 'emoji': '📈', 'title': '재테크 시작', 'desc': '돈을 불리는 방법이 궁금해요'},
    {'code': 'REAL_LIFE_PREPARATION', 'emoji': '🏦', 'title': '실생활 대비', 'desc': '연말정산·청약 등 실용 지식'},
    {'code': 'SELF_DEVELOPMENT', 'emoji': '🎓', 'title': '자기 개발', 'desc': '경제 상식을 쌓고 싶어요'},
  ];

  // 3단계: 하루 학습 시간 스타일 정의
  final List<Map<String, String>> _studyStylesData = [
    {'code': 'LIGHT', 'title': '가볍게 (하루 5분)', 'desc': '주당 35분, 바쁜 일상 속 스낵 학습'},
    {'code': 'NORMAL', 'title': '보통 (하루 10분)', 'desc': '주당 70분, 꾸준하게 습관 기르기 (추천)'},
    {'code': 'SERIOUS', 'title': '진지하게 (하루 15분)', 'desc': '주당 105분, 빠른 경제 실력 향상'},
    {'code': 'INTENSE', 'title': '강렬하게 (하루 20분)', 'desc': '주당 140분, 경제 전문가가 되기 위한 하드 스터디'},
  ];

  // 4단계: 작심삼일 공부 실패 원인 정의
  final List<Map<String, String>> _failureReasonsData = [
    {'code': 'TERMINOLOGY', 'title': '전문 용어가 너무 난해해서', 'desc': '무슨 소리인지 모르는 금융 용어의 장벽'},
    {'code': 'WHERE_TO_START', 'title': '어디서부터 시작할지 몰라서', 'desc': '방대한 양에 갈 길을 잃음'},
    {'code': 'BUSY', 'title': '일상 업무/공부에 치여 꾸준히 못함', 'desc': '습관화 실패 및 시간 부족'},
    {'code': 'NO_FUN', 'title': '강제성이 없고 재미가 없어서', 'desc': '흥미를 붙이기 어려운 줄글 위주의 설명'},
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep++;
      });
    } else {
      _submitSurvey();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitSurvey() async {
    HapticFeedback.mediumImpact();
    // 💡 백엔드 명세서 PUT API 데이터 연동 매핑
    final interestsPayload = {"categoryCodes": _selectedInterests};
    final goalPayload = {"goal": _selectedGoal.isEmpty ? "LOSS_PREVENTION" : _selectedGoal};
    
    final studyStylePayload = {
      "frequency": "DAILY",
      "depth": _selectedStudyStyle == 'LIGHT' ? 'EASY' : (_selectedStudyStyle == 'SERIOUS' || _selectedStudyStyle == 'INTENSE' ? 'HARD' : 'NORMAL'),
      "sessionVolume": _selectedStudyStyle == 'LIGHT' ? 'LESS_THAN_ONE' : (_selectedStudyStyle == 'INTENSE' ? 'THREE_OR_MORE' : 'ONE_TO_TWO')
    };

    final failureReasonPayload = {
      "reason": _selectedFailureReason.isEmpty ? "BORING_AND_HARD" : _selectedFailureReason,
      "skipped": _selectedFailureReason.isEmpty
    };

    debugPrint('Submitting Interests: $interestsPayload to ${ApiEndpoints.onboardingInterests}');
    debugPrint('Submitting Goal: $goalPayload to ${ApiEndpoints.onboardingGoal}');
    debugPrint('Submitting Study Style: $studyStylePayload to ${ApiEndpoints.onboardingStudyStyle}');
    debugPrint('Submitting Failure Reason: $failureReasonPayload to ${ApiEndpoints.onboardingFailureReason}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '맞춤형 경제 커리큘럼 설정을 완료했습니다! 🎯',
          style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00EE94),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // 다음 화면: 레벨테스트 선택 화면(EC-0007)으로 이동
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LevelTestScreen(),
        ),
      );
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
              // 1. Back button row (Custom Top Bar)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
                      onPressed: _prevStep,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // 2. Progress Bar Section (Figma: padding 12px 24px 0px)
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
                              widthFactor: _currentStep == 1
                                  ? 2 / 6
                                  : (_currentStep == 2
                                      ? 3 / 6
                                      : (_currentStep == 3 ? 4 / 6 : 5 / 6)),
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
                      child: Text(
                        _currentStep == 1
                            ? '2 / 6'
                            : (_currentStep == 2
                                ? '3 / 6'
                                : (_currentStep == 3 ? '4 / 6' : '5 / 6')),
                        style: const TextStyle(
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

              // 3. Main Scrollable Content Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading Section
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 1
                                  ? '관심 분야를 선택하세요'
                                  : (_currentStep == 2
                                      ? '학습 목적을 선택하세요'
                                      : (_currentStep == 3 ? '하루 경제 공부 페이스 설정' : '공부 실패 원인이 무엇인가요?')),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                height: 26 / 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentStep == 1
                                  ? '(복수 선택 가능) 나중에 변경할 수 있어요'
                                  : (_currentStep == 2
                                      ? '가장 가까운 것 하나만 선택해주세요'
                                      : '나중에 설정에서 변경할 수 있어요'),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                                height: 16 / 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildCurrentStepContent(),
                    ],
                  ),
                ),
              ),

              // 4. Bottom Button
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Interests();
      case 2:
        return _buildStep2Goals();
      case 3:
        return _buildStep3StudyStyle();
      case 4:
        return _buildStep4FailureReason();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1단계: 관심사 선택 (OnboardingInterests - 2/6)
  Widget _buildStep1Interests() {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Row 1 (📊 경제 상식 / 💰 저축)
        Row(
          children: [
            Expanded(child: _buildInterestButton(_interestsData[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildInterestButton(_interestsData[1])),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2 (📈 주식 / 🏠 부동산)
        Row(
          children: [
            Expanded(child: _buildInterestButton(_interestsData[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildInterestButton(_interestsData[3])),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3 (🧾 세금 - 가로 꽉 차는 버튼)
        _buildInterestButton(_interestsData[4]),
      ],
    );
  }

  Widget _buildInterestButton(Map<String, dynamic> item) {
    final code = item['code'] as String;
    final title = item['title'] as String;
    final isSelected = _selectedInterests.contains(code);

    return SizedBox(
      height: 56,
      width: double.infinity,
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
            if (isSelected) {
              _selectedInterests.remove(code);
            } else {
              _selectedInterests.add(code);
            }
          });
        },
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4B5563),
            height: 16 / 13,
          ),
        ),
      ),
    );
  }

  // 2단계: 핵심 목표 선택 (OnboardingGoal - 3/6)
  Widget _buildStep2Goals() {
    return Column(
      children: [
        const SizedBox(height: 32),
        ..._goalsData.map((item) {
          final isSelected = _selectedGoal == item['code'];
          return _buildGoalTile(
            emoji: item['emoji']!,
            title: item['title']!,
            desc: item['desc']!,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedGoal = item['code']!;
              });
            },
          );
        }),
      ],
    );
  }

  // OnboardingGoal 세부 카드 디자인 컴포넌트 (높이 81.5px, emoji+title Row, desc Column 배치)
  Widget _buildGoalTile({
    required String emoji,
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        height: 81.5,
        width: double.infinity,
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
            padding: const EdgeInsets.all(16.0),
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1: Emoji + Title (gap: 8px, height: 28px)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            height: 28 / 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            height: 16 / 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Row 2: Description (Aligned under title, gap: 4px, height: 13.5px)
                    Padding(
                      padding: const EdgeInsets.only(left: 26.0), // emoji(18) + gap(8) = 26px 여백 정렬
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                          height: 14 / 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Suffix selection checkmark circle (Figma: width 20px, height 20px, check icon)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3단계: 하루 학습 시간 페이스 설정
  Widget _buildStep3StudyStyle() {
    return Column(
      children: [
        const SizedBox(height: 32),
        ..._studyStylesData.map((item) {
          final isSelected = _selectedStudyStyle == item['code'];
          return _buildSelectionTile(
            title: item['title']!,
            desc: item['desc']!,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedStudyStyle = item['code']!;
              });
            },
          );
        }),
      ],
    );
  }

  // 4단계: 작심삼일 공부 실패 원인 설정
  Widget _buildStep4FailureReason() {
    return Column(
      children: [
        const SizedBox(height: 32),
        ..._failureReasonsData.map((item) {
          final isSelected = _selectedFailureReason == item['code'];
          return _buildSelectionTile(
            title: item['title']!,
            desc: item['desc']!,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedFailureReason = item['code']!;
              });
            },
          );
        }),
      ],
    );
  }

  // 공용 세로형 리스트 타일 컴포넌트
  Widget _buildSelectionTile({
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        height: 72,
        width: double.infinity,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          onPressed: onTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 15 / 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
                    width: isSelected ? 5.5 : 1.0,
                  ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool isEnabled = false;
    if (_currentStep == 1 && _selectedInterests.isNotEmpty) isEnabled = true;
    if (_currentStep == 2 && _selectedGoal.isNotEmpty) isEnabled = true;
    if (_currentStep == 3 && _selectedStudyStyle.isNotEmpty) isEnabled = true;
    if (_currentStep == 4 && _selectedFailureReason.isNotEmpty) isEnabled = true;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color(0xFF00EE94) : const Color(0xFFE4E8F0),
            foregroundColor: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: isEnabled ? _nextStep : null,
          child: Text(
            _currentStep == _totalSteps ? '맞춤 커리큘럼 생성하기 🚀' : '다음',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
