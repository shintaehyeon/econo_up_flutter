// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'level_test_result_screen.dart';

class LevelTestScreen extends StatefulWidget {
  final String nickname;

  const LevelTestScreen({
    super.key,
    this.nickname = '경제왕',
  });

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  int _currentIdx = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _score = 0;

  // 10 high-quality finance/economics questions matching the progress bar
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'q_level_01',
      'categoryText': '경제 상식 · 금리',
      'subtitle': '금리가 오르면 일반적으로',
      'prompt': '채권 가격은 어떻게 될까요?',
      'choices': [
        {'id': 'A', 'text': '오른다'},
        {'id': 'B', 'text': '내려간다'},
        {'id': 'C', 'text': '변화 없다'},
        {'id': 'D', 'text': '알 수 없다'},
      ],
      'answer': 'B',
      'explanation': '금리가 상승하면 새로 발행되는 채권의 금리가 더 높아지기 때문에, 상대적으로 낮은 금리를 제공하는 기존 채권의 매력도가 떨어져 가격이 내려갑니다.',
    },
    {
      'id': 'q_level_02',
      'categoryText': '경제 상식 · 물가',
      'subtitle': '물가가 지속적으로 상승하여',
      'prompt': '화폐 가치가 떨어지는 현상은?',
      'choices': [
        {'id': 'A', 'text': '디플레이션'},
        {'id': 'B', 'text': '인플레이션'},
        {'id': 'C', 'text': '스태그플레이션'},
        {'id': 'D', 'text': '리플레이션'},
      ],
      'answer': 'B',
      'explanation': '인플레이션은 상품 및 서비스의 전반적인 가격 수준이 지속적으로 상승하고, 그에 따라 화폐의 구매력이 떨어지는 현상입니다.',
    },
    {
      'id': 'q_level_03',
      'categoryText': '경제 상식 · 환율',
      'subtitle': '원·달러 환율이 상승하면',
      'prompt': '수출 기업의 원화 기준 실적은?',
      'choices': [
        {'id': 'A', 'text': '악화된다'},
        {'id': 'B', 'text': '개선된다'},
        {'id': 'C', 'text': '영향 없다'},
        {'id': 'D', 'text': '예측 불가능하다'},
      ],
      'answer': 'B',
      'explanation': '원·달러 환율이 오르면 달러당 받을 수 있는 원화가 많아지므로, 달러로 수출 대금을 받는 수출 기업의 원화 환산 매출과 이익이 늘어납니다.',
    },
    {
      'id': 'q_level_04',
      'categoryText': '투자 상식 · 주식',
      'subtitle': '기업이 벌어들인 이익의 일부를',
      'prompt': '주주들에게 분배하는 돈은?',
      'choices': [
        {'id': 'A', 'text': '배당금'},
        {'id': 'B', 'text': '이자'},
        {'id': 'C', 'text': '양도 차익'},
        {'id': 'D', 'text': '공모 자금'},
      ],
      'answer': 'A',
      'explanation': '배당금은 기업이 영업 활동을 통해 얻은 순이익 중 일부를 소유주인 주주들에게 지분에 따라 환원하는 금액입니다.',
    },
    {
      'id': 'q_level_05',
      'categoryText': '투자 상식 · 주식',
      'subtitle': '주식시장에서 기업의 가치를',
      'prompt': '나타내는 지표인 \'시가총액\'이란?',
      'choices': [
        {'id': 'A', 'text': '연간 총 매출액'},
        {'id': 'B', 'text': '발행주식수 × 주가'},
        {'id': 'C', 'text': '자산 총합에서 부채를 뺀 것'},
        {'id': 'D', 'text': '자본금의 총 액수'},
      ],
      'answer': 'B',
      'explanation': '시가총액(Market Capitalization)은 그 기업의 상장주식 수에 현재 주가를 곱한 것으로, 시장이 평가하는 기업의 총 가치입니다.',
    },
    {
      'id': 'q_level_06',
      'categoryText': '생활 금융 · 세금',
      'subtitle': '소득세 등을 납부할 때',
      'prompt': '세액공제와 소득공제의 차이는?',
      'choices': [
        {'id': 'A', 'text': '세액공제는 소득에서 빼고, 소득공제는 세금에서 뺀다'},
        {'id': 'B', 'text': '둘 다 차이가 없이 명칭만 다르다'},
        {'id': 'C', 'text': '소득공제는 세율을 낮추고, 세액공제는 소득을 낮출 뿐이다'},
        {'id': 'D', 'text': '소득공제는 과세소득을 줄이고, 세액공제는 세금 자체를 깎아준다'},
      ],
      'answer': 'D',
      'explanation': '소득공제는 세금을 매기는 기준이 되는 소득 자체를 낮춰주는 것이고, 세액공제는 세액을 계산한 후 최종 납부할 세금에서 직접 빼주는 것이라 혜택이 더 큽니다.',
    },
    {
      'id': 'q_level_07',
      'categoryText': '생활 금융 · 신용',
      'subtitle': '개인의 신용점수를',
      'prompt': '올바르게 관리하는 가장 좋은 방법은?',
      'choices': [
        {'id': 'A', 'text': '연체 없이 대금을 성실히 납부한다'},
        {'id': 'B', 'text': '신용카드를 아예 발급받지 않는다'},
        {'id': 'C', 'text': '여러 금융기관에서 동시에 대출을 받는다'},
        {'id': 'D', 'text': '대출을 최대한 많이 받고 갚기를 반복한다'},
      ],
      'answer': 'A',
      'explanation': '신용점수 관리의 핵심은 상환 능력을 증명하는 것으로, 소액이라도 카드 연체나 대출 연체 없이 꾸준히 상환하는 실적이 가장 중요합니다.',
    },
    {
      'id': 'q_level_08',
      'categoryText': '생활 금융 · 부동산',
      'subtitle': '부동산 계약 후 임대차 보증금을',
      'prompt': '보호하기 위해 최우선으로 받아야 하는 것은?',
      'choices': [
        {'id': 'A', 'text': '등기필증'},
        {'id': 'B', 'text': '인감증명서'},
        {'id': 'C', 'text': '확정일자와 전입신고'},
        {'id': 'D', 'text': '공인중개사 자격증'},
      ],
      'answer': 'C',
      'explanation': '전입신고와 확정일자를 받아두면 주택임대차보호법상 대항력과 우선변제권을 확보하여 보증금을 안전하게 지킬 수 있습니다.',
    },
    {
      'id': 'q_level_09',
      'categoryText': '금융 상품 · 펀드',
      'subtitle': '여러 투자자의 자금을 모아',
      'prompt': '전문가가 대신 굴려주는 \'간접투자상품\'은?',
      'choices': [
        {'id': 'A', 'text': '보통예금'},
        {'id': 'B', 'text': '회사채'},
        {'id': 'C', 'text': '주식예탁증서 (DR)'},
        {'id': 'D', 'text': '펀드 (Fund)'},
      ],
      'answer': 'D',
      'explanation': '펀드는 다수의 투자자로부터 모은 자금을 펀드매니저라는 전문가가 주식이나 채권 등에 대리 투자하여 그 수익을 분배하는 간접투자 상품입니다.',
    },
    {
      'id': 'q_level_10',
      'categoryText': '거시 경제 · 지표',
      'subtitle': '한 나라의 경제 규모를',
      'prompt': '측정하는 대표적 지표인 GDP의 뜻은?',
      'choices': [
        {'id': 'A', 'text': '국민총생산 (GNP)'},
        {'id': 'B', 'text': '국내총생산 (GDP)'},
        {'id': 'C', 'text': '소비자물가지수 (CPI)'},
        {'id': 'D', 'text': '종합주가지수 (KOSPI)'},
      ],
      'answer': 'B',
      'explanation': 'GDP(Gross Domestic Product)는 일정 기간 동안 한 나라 영토 안에서 생산된 최종 생산물의 시장가치 합계인 국내총생산입니다.',
    },
  ];

  String getCircleNumber(int index) {
    switch (index) {
      case 0:
        return '①';
      case 1:
        return '②';
      case 2:
        return '③';
      case 3:
        return '④';
      default:
        return '';
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _isAnswered) return;

    final currentQ = _questions[_currentIdx];
    final isCorrect = _selectedAnswer == currentQ['answer'];

    HapticFeedback.mediumImpact();
    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score += 10; // 10문항이므로 한 문항당 10점
      }
    });

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
    debugPrint('Completing level test with score: $_score');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LevelTestResultScreen(
          score: _score,
          nickname: widget.nickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIdx];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Status Bar Container (Figma: padding 16px 24px 0px, height 44px)
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '9:41',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 20 / 14,
                    ),
                  ),
                  const Spacer(),
                  // Battery / Wifi Icon Placeholder
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi, size: 14, color: Color(0xFF111827)),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF111827), width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.all(1),
                        child: Container(
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. 10-Segmented Progress Indicator Section (Figma: padding 12px 24px 0px, height 52px)
            Container(
              width: double.infinity,
              height: 52,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 10 Segments Row
                  Row(
                    children: List.generate(10, (idx) {
                      bool isActive = idx <= _currentIdx;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: idx == 9 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF00EE94) : const Color(0xFFE4E8F0),
                            borderRadius: BorderRadius.circular(16777216),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Centered Step Counter "1/10"
                  Center(
                    child: Text(
                      '${_currentIdx + 1}/10',
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

            // 3. Question Prompt Section (Figma: top 32px, left 24px, right 24px)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentQ['subtitle'] as String,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                      height: 16 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQ['prompt'] as String,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 24 / 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ['categoryText'] as String,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      height: 13 / 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Choices Buttons List (Figma: gap 12px)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: List.generate((currentQ['choices'] as List).length, (choiceIdx) {
                    final choice = (currentQ['choices'] as List)[choiceIdx] as Map<String, String>;
                    final choiceId = choice['id']!;
                    final choiceText = choice['text']!;
                    final isSelected = _selectedAnswer == choiceId;

                    // Dynamic colors based on answer & selection state
                    Color btnBg = const Color(0xFFFFFFFF);
                    Color borderCol = const Color(0xFFD0D5E0);
                    double borderW = 1.0;
                    Color txtCol = const Color(0xFF4B5563);
                    FontWeight fontW = FontWeight.w500;

                    if (_isAnswered) {
                      if (choiceId == currentQ['answer']) {
                        // Correct choice
                        btnBg = const Color(0xFFF2FFFA);
                        borderCol = const Color(0xFF00EE94);
                        borderW = 2.0;
                        txtCol = const Color(0xFF0DE593);
                        fontW = FontWeight.w700;
                      } else if (isSelected) {
                        // Incorrect selection
                        btnBg = const Color(0xFFFFF5F5);
                        borderCol = const Color(0xFFEF4444);
                        borderW = 2.0;
                        txtCol = const Color(0xFFEF4444);
                        fontW = FontWeight.w700;
                      }
                    } else if (isSelected) {
                      // Normal selected state
                      btnBg = const Color(0xFFF2FFFA);
                      borderCol = const Color(0xFF00EE94);
                      borderW = 2.0;
                      txtCol = const Color(0xFF0DE593);
                      fontW = FontWeight.w700;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: _isAnswered
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedAnswer = choiceId;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: btnBg,
                            border: Border.all(color: borderCol, width: borderW),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Text combining circled number and choice text
                              Expanded(
                                child: Text(
                                  '${getCircleNumber(choiceIdx)}  $choiceText',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 13,
                                    fontWeight: fontW,
                                    color: txtCol,
                                    height: 16 / 13,
                                  ),
                                ),
                              ),
                              // Visual check/cancel icon in answered state
                              if (_isAnswered && choiceId == currentQ['answer'])
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF00EE94), size: 20)
                              else if (_isAnswered && isSelected)
                                const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20)
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 5. Bottom Action Section (Figma: height 120px with padding 24px)
            _buildBottomActionSection(currentQ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionSection(Map<String, dynamic> currentQ) {
    if (!_isAnswered) {
      final hasSelected = _selectedAnswer != null;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE4E8F0), width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: hasSelected ? _submitAnswer : null,
            child: const Text(
              '정답 확인',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      );
    }

    // Feedback state Duolingo-style Banner Sheet
    final isCorrect = _isCorrect;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF2FFFA) : const Color(0xFFFFF0F2),
        border: Border(
          top: BorderSide(
            color: isCorrect ? const Color(0xFF00EE94).withOpacity(0.3) : const Color(0xFFEF4444).withOpacity(0.3),
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
                color: isCorrect ? const Color(0xFF00EE94) : const Color(0xFFEF4444),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '훌륭합니다! 정답이에요.' : '아쉬워요, 오답입니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isCorrect ? const Color(0xFF0DE593) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentQ['explanation'] as String,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              height: 1.4,
              color: isCorrect ? const Color(0xFF4B5563) : const Color(0xFFBC3347),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? const Color(0xFF00EE94) : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _nextQuestion,
              child: Text(
                _currentIdx == _questions.length - 1 ? '결과 확인하기 🎉' : '다음',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 20 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
