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
  int _currentStep = 1; // 1 to 4 steps
  final int _totalSteps = 4;

  // Selected state variables
  final List<String> _selectedInterests = [];
  String _selectedGoal = '';
  String _selectedStudyStyle = '';
  String _selectedFailureReason = '';

  // Data definitions
  final List<Map<String, dynamic>> _interestsData = [
    {'code': 'ECONOMY', 'title': '기초 거시경제', 'icon': Icons.public_rounded, 'desc': '인플레이션, 금리, 환율 기초'},
    {'code': 'SAVING', 'title': '스마트 저축·예금', 'icon': Icons.savings_rounded, 'desc': '종잣돈 마련 및 예적금 가이드'},
    {'code': 'STOCK', 'title': '주식·펀드 투자', 'icon': Icons.analytics_rounded, 'desc': '차트 분석 및 포트폴리오 설계'},
    {'code': 'REAL_ESTATE', 'title': '부동산·내집마련', 'icon': Icons.home_work_rounded, 'desc': '청약 제도 및 전월세 상식'},
    {'code': 'TAX', 'title': '세금·연말정산', 'icon': Icons.percent_rounded, 'desc': '소득세 절세 및 소등 공제 전략'},
  ];

  final List<Map<String, String>> _goalsData = [
    {'code': 'BEGINNER', 'title': '경제 금융 문맹 탈출', 'desc': '뉴스를 읽을 때 모르는 단어가 없도록!'},
    {'code': 'CHALLENGE', 'title': '절약·저축 1억 모으기 챌린지', 'desc': '시드머니 형성을 위한 첫 발걸음'},
    {'code': 'INVEST', 'title': '내 돈 굴리기 실전 주식', 'desc': '자산 증식을 위한 실전형 주식 정보 습득'},
    {'code': 'BUY_HOME', 'title': '내 집 마련 부동산 기초', 'desc': '어려운 부동산 청약 및 전월세 정책 정복'},
  ];

  final List<Map<String, String>> _studyStylesData = [
    {'code': 'LIGHT', 'title': '가볍게 (하루 5분)', 'desc': '주당 35분, 바쁜 일상 속 스낵 학습'},
    {'code': 'NORMAL', 'title': '보통 (하루 10분)', 'desc': '주당 70분, 꾸준하게 습관 기르기 (추천)'},
    {'code': 'SERIOUS', 'title': '진지하게 (하루 15분)', 'desc': '주당 105분, 빠른 경제 실력 향상'},
    {'code': 'INTENSE', 'title': '강렬하게 (하루 20분)', 'desc': '주당 140분, 경제 전문가가 되기 위한 하드 스터디'},
  ];

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
    // 💡 백엔드 명세서 PUT /onboarding/interests, onboarding/goal 등 순차 API 모방
    final interestsPayload = {"interests": _selectedInterests};
    final goalPayload = {"goal": _selectedGoal};
    final studyStylePayload = {"studyStyle": _selectedStudyStyle};
    final failureReasonPayload = {"failureReason": _selectedFailureReason};

    debugPrint('Submitting Interests: $interestsPayload to ${ApiEndpoints.onboardingInterests}');
    debugPrint('Submitting Goal: $goalPayload to ${ApiEndpoints.onboardingGoal}');
    debugPrint('Submitting Study Style: $studyStylePayload to ${ApiEndpoints.onboardingStudyStyle}');
    debugPrint('Submitting Failure Reason: $failureReasonPayload to ${ApiEndpoints.onboardingFailureReason}');

    // 성공 노티 바인딩
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('맞춤형 경제 커리큘럼 설정을 완료했습니다! 🎯'),
        backgroundColor: AppColors.mint,
        behavior: SnackBarBehavior.floating,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: _prevStep,
        ),
        title: _buildProgressHeader(),
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
                  child: _buildCurrentStepContent(),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = _currentStep / _totalSteps;
    return Container(
      width: 200,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200 * progress,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ]
            ),
          ),
        ],
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

  // 1단계: 관심사 선택 (EC-0003)
  Widget _buildStep1Interests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '관심 있는 경제 분야를\n모두 선택해 주세요! 💼',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w850, color: AppColors.ink, height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          '선택하신 관심사를 바탕으로 개인화된 로드맵을 구성해 드립니다. (복수 선택 가능)',
          style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),
        ..._interestsData.map((item) {
          final isSelected = _selectedInterests.contains(item['code']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(item['code']);
                  } else {
                    _selectedInterests.add(item['code']);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandSoft : AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand : AppColors.line,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brand.withOpacity(0.12) : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? AppColors.brand : AppColors.muted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AppColors.brand, size: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 2단계: 주간 목표 설정 (EC-0004)
  Widget _buildStep2Goals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이코노업을 통해 달성할\n핵심 목표를 선택해 주세요! 🏆',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w850, color: AppColors.ink, height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          '가장 먼저 정복하고 싶은 단 하나의 도전 목표를 설정합니다.',
          style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),
        ..._goalsData.map((item) {
          final isSelected = _selectedGoal == item['code'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedGoal = item['code']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandSoft : AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand : AppColors.line,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    _buildSelectionIndicator(isSelected),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 3단계: 학습 강도/스타일 설정 (EC-0005)
  Widget _buildStep3StudyStyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '하루에 얼마나 학습을\n진행하시겠어요? ⏱️',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w850, color: AppColors.ink, height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          '본인의 일일 경제 학습 페이스를 결정합니다. 언제든 설정에서 변경 가능합니다.',
          style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),
        ..._studyStylesData.map((item) {
          final isSelected = _selectedStudyStyle == item['code'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedStudyStyle = item['code']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandSoft : AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand : AppColors.line,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    _buildSelectionIndicator(isSelected),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 4단계: 실패 원인 (EC-0006)
  Widget _buildStep4FailureReason() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '과거 경제 공부를 끝까지\n마치지 못했던 원인은 무엇인가요? 🥺',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w850, color: AppColors.ink, height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          '작심삼일을 깨뜨리고 완주할 수 있는 흥미 위주의 보상 시스템을 설계해 드립니다.',
          style: TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),
        ..._failureReasonsData.map((item) {
          final isSelected = _selectedFailureReason == item['code'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedFailureReason = item['code']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.brandSoft : AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand : AppColors.line,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    _buildSelectionIndicator(isSelected),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.brand : AppColors.lineStrong,
          width: isSelected ? 6.0 : 1.5,
        ),
        color: Colors.white,
      ),
    );
  }

  Widget _buildBottomButton() {
    bool isEnabled = false;
    if (_currentStep == 1 && _selectedInterests.isNotEmpty) isEnabled = true;
    if (_currentStep == 2 && _selectedGoal.isNotEmpty) isEnabled = true;
    if (_currentStep == 3 && _selectedStudyStyle.isNotEmpty) isEnabled = true;
    if (_currentStep == 4 && _selectedFailureReason.isNotEmpty) isEnabled = true;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.brand : AppColors.lineStrong,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isEnabled ? _nextStep : null,
        child: Text(
          _currentStep == _totalSteps ? '맞춤 커리큘럼 생성하기 🚀' : '계속하기',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w850,
          ),
        ),
      ),
    );
  }
}
