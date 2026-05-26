// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import 'level_test_result_screen.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  int _currentIdx = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'q_level_01',
      'prompt': '금리가 내려갈 때 일반적으로 가격이 가장 크게 오르는 자산은 무엇일까요? 📈',
      'choices': [
        {'id': 'A', 'text': '현금'},
        {'id': 'B', 'text': '채권'},
        {'id': 'C', 'text': '단기 예금'},
        {'id': 'D', 'text': '달러 외화'},
      ],
      'answer': 'B',
      'explanation': '금리가 하락하면 고정된 금리를 지급하는 기존 채권의 가격은 신규 발행되는 채권에 비해 가치가 상승하므로 가격이 오릅니다.',
    },
    {
      'id': 'q_level_02',
      'prompt': '실물 자산의 가격이 지속적으로 상승하여 돈의 가치가 떨어지는 현상을 무엇이라 할까요? 💸',
      'choices': [
        {'id': 'A', 'text': '디플레이션'},
        {'id': 'B', 'text': '인플레이션'},
        {'id': 'C', 'text': '스태그플레이션'},
        {'id': 'D', 'text': '리플레이션'},
      ],
      'answer': 'B',
      'explanation': '인플레이션은 물가가 지속적으로 오르고 화폐가치가 떨어지는 현상을 의미합니다.',
    },
    {
      'id': 'q_level_03',
      'prompt': '기업이 벌어들인 이익의 일부를 주주들에게 지분에 따라 나누어 주는 돈을 무엇이라 하나요? 💰',
      'choices': [
        {'id': 'A', 'text': '이자'},
        {'id': 'B', 'text': '배당금'},
        {'id': 'C', 'text': '양도소득'},
        {'id': 'D', 'text': '수수료'},
      ],
      'answer': 'B',
      'explanation': '배당금은 기업이 이윤의 일부를 투자한 주주들에게 환원하는 분배금입니다.',
    },
    {
      'id': 'q_level_04',
      'prompt': '부동산 임대차 계약 후 보증금을 안전하게 보호하기 위해 주민센터에서 받아두어야 하는 확인 도장은? 🏠',
      'choices': [
        {'id': 'A', 'text': '확정일자'},
        {'id': 'B', 'text': '인감도장'},
        {'id': 'C', 'text': '등기필증'},
        {'id': 'D', 'text': '전세권설정'},
      ],
      'answer': 'A',
      'explanation': '주택임대차 계약을 하고 확정일자를 받으면 후순위 권리자보다 우선하여 보증금을 변제받을 권리(우선변제권)를 얻습니다.',
    },
    {
      'id': 'q_level_05',
      'prompt': '연말정산 시 이미 산출된 세금 자체를 직접 깎아주는 가장 혜택이 큰 제도는 무엇일까요? 📑',
      'choices': [
        {'id': 'A', 'text': '소득공제'},
        {'id': 'B', 'text': '세액공제'},
        {'id': 'C', 'text': '비과세'},
        {'id': 'D', 'text': '원천징수'},
      ],
      'answer': 'B',
      'explanation': '소득공제는 과세 대상 소득을 줄여주는 반면, 세액공제는 납부해야 할 세금 자체에서 직접 일정 비율을 차감해 주어 효과가 큽니다.',
    },
  ];

  void _submitAnswer() {
    if (_selectedAnswer == null || _isAnswered) return;

    final currentQ = _questions[_currentIdx];
    final isCorrect = _selectedAnswer == currentQ['answer'];

    HapticFeedback.mediumImpact();
    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score += 20; // 5문항이므로 한 문항당 20점
      }
    });

    // 💡 백엔드 POST /level-tests/{id}/answers API 전송 모방
    final attemptPayload = {
      "questionId": currentQ['id'],
      "selectedChoiceId": _selectedAnswer,
      "isCorrect": isCorrect
    };
    debugPrint('Submitting answer to level test: $attemptPayload');
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentIdx < _questions.length - 1) {
      setState(() {
        _currentIdx++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    // 💡 백엔드 POST /level-tests/{id}/complete API 호출 및 온보딩 세션 저장 모방
    debugPrint('Completing level test with score: $_score');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LevelTestResultScreen(score: _score),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIdx];
    final progress = (_currentIdx + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 180,
            height: 8,
            color: AppColors.line,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 180 * progress,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 문제 내용 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '문제 ${_currentIdx + 1} / ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQ['prompt'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 사지선다 문항 카드 목록
                    ...(currentQ['choices'] as List<Map<String, String>>).map((choice) {
                      final choiceId = choice['id']!;
                      final choiceText = choice['text']!;
                      final isSelected = _selectedAnswer == choiceId;

                      // 정답 피드백 모드 디자인 대응
                      Color cardColor = AppColors.paper;
                      Color borderColor = AppColors.line;
                      double borderSize = 1.0;

                      if (_isAnswered) {
                        if (choiceId == currentQ['answer']) {
                          cardColor = AppColors.mintSoft;
                          borderColor = AppColors.mint;
                          borderSize = 1.8;
                        } else if (isSelected) {
                          cardColor = AppColors.dangerSoft;
                          borderColor = AppColors.danger;
                          borderSize = 1.8;
                        }
                      } else if (isSelected) {
                        cardColor = AppColors.brandSoft;
                        borderColor = AppColors.brand;
                        borderSize = 1.8;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: _isAnswered
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _selectedAnswer = choiceId;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: borderSize),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.brand : AppColors.background,
                                    border: Border.all(
                                      color: isSelected ? AppColors.brand : AppColors.lineStrong,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    choiceId,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? Colors.white : AppColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    choiceText,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                if (_isAnswered && choiceId == currentQ['answer'])
                                  const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 24)
                                else if (_isAnswered && isSelected)
                                  const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 24)
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 채점 / 정답 피드백 배너 및 하단 액션 버튼 영역 (Duolingo Style)
            _buildBottomBanner(currentQ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBanner(Map<String, dynamic> currentQ) {
    if (!_isAnswered) {
      final hasSelected = _selectedAnswer != null;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(top: BorderSide(color: AppColors.line, width: 1.0)),
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: hasSelected
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
              backgroundColor: hasSelected ? AppColors.brand : AppColors.lineStrong,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: hasSelected ? _submitAnswer : null,
            child: const Text(
              '정답 확인',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    // 채점이 완료되었을 때 배너 레이아웃 (정오답 여부에 따라 컬러 반응)
    final isCorrect = _isCorrect;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.mintSoft : AppColors.dangerSoft,
        border: Border(
          top: BorderSide(
            color: isCorrect ? AppColors.mint.withOpacity(0.3) : AppColors.danger.withOpacity(0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: isCorrect ? AppColors.mint : AppColors.danger,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? '훌륭합니다! 정답이에요.' : '아쉬워요, 오답입니다.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isCorrect ? AppColors.mint : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentQ['explanation'] as String,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isCorrect ? AppColors.mint : AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isCorrect ? AppColors.mint : AppColors.danger).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? AppColors.mint : AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _nextQuestion,
              child: Text(
                _currentIdx == _questions.length - 1 ? '결과 확인하기 🎉' : '다음 문제',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
