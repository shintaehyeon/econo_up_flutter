import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../curriculum/presentation/stage_complete_screen.dart';

class StudyDetailScreen extends StatefulWidget {
  final String title;

  const StudyDetailScreen({
    super.key,
    required this.title,
  });

  @override
  State<StudyDetailScreen> createState() => _StudyDetailScreenState();
}

class _StudyDetailScreenState extends State<StudyDetailScreen> {
  int _currentPage = 0;
  final int _totalPages = 5;

  // 5-page curriculum content for "Unit 1. 금리"
  final List<Map<String, String>> _economyCurriculum = [
    {
      'title': '💰 → 📈 → 💳',
      'body': '금리란 돈을 빌린 대가로 지급하는 비용의 비율입니다. 기준금리는 한 나라의 모든 시중금리의 기준이 되는 금리로, 이것이 오르면 예금·대출 금리가 함께 오르는 경향이 있습니다.',
    },
    {
      'title': '📉 → 💸 → 🛍️',
      'body': '금리가 내려가면 시중에 돈이 많이 풀리게 됩니다. 대출 이자가 줄어들어 가계 소비와 기업 투자가 촉진되고, 경기 부양 효과를 냅니다.',
    },
    {
      'title': '🏦 → 💸 → 📉',
      'body': '반대로 금리가 올라가면 사람들은 대출을 줄이고 예금을 늘립니다. 소비가 감소하고 물가가 안정되는 효과를 가져옵니다.',
    },
    {
      'title': '📊 → 📈 → 💵',
      'body': '금리와 자산 가격(채권, 부동산 등)은 일반적으로 반대로 움직입니다. 금리가 오르면 자산의 매력도가 떨어져 가격이 하락하는 경향이 있습니다.',
    },
    {
      'title': '🦅 vs 🕊️',
      'body': '물가 안정을 위해 금리 인상을 선호하는 세력을 \'매파(Hawk)\', 경기 부양을 위해 금리 인하를 선호하는 세력을 \'비둘기파(Dove)\'라고 부릅니다.',
    },
  ];

  // 5-page curriculum content for "Unit 1. 현금 관리"
  final List<Map<String, String>> _savingCurriculum = [
    {
      'title': '💰 → 🏦 → 🔒',
      'body': '현금 관리는 자산 형성의 첫걸음입니다. 예적금 상품을 활용하여 안전하게 자산을 보관하고, 이자를 받아 자산을 늘려가는 것이 저축의 기초입니다.',
    },
    {
      'title': '💵 vs 🐷',
      'body': '예금은 일정 금액을 은행에 한 번에 예치하는 상품이고, 적금은 일정 기간 매월 일정 금액을 납입하여 목돈을 만드는 상품입니다. 목적에 맞게 두 상품을 병행하는 것이 좋습니다.',
    },
    {
      'title': '💳 → 💸 → 📊',
      'body': '체크카드는 내 통장의 잔액 한도 내에서만 지출할 수 있어, 무분별한 소비를 막고 예산 내에서 계획적인 소비를 유도하는 훌륭한 저축 도구입니다.',
    },
    {
      'title': '🚨 → 🛡️ → 🏦',
      'body': '비상금 통장은 갑작스러운 지출이나 소득 중단 상황에 대비하기 위해 최소 3~6개월 치의 생활비를 따로 분리하여 보관하는 안전장치 역할을 합니다.',
    },
    {
      'title': '🌱 → 🌲 → 💰',
      'body': '종잣돈(Seed Money)은 본격적인 투자를 시작하기 전에 모으는 기초 자금입니다. 초기에는 소비를 줄이고 저축 비율을 높여 빠르게 종잣돈을 만드는 것이 가장 중요합니다.',
    },
  ];

  List<Map<String, String>> get _pagesContent =>
      widget.title == '저축' ? _savingCurriculum : _economyCurriculum;

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Completed last page: route to StageCompleteScreen
      final bool isSaving = widget.title == '저축';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StageCompleteScreen(
            categoryTitle: widget.title,
            completionMessage: isSaving
                ? '현금 관리의 기초를 이해했어요'
                : '금리와 소비의 관계를 이해했어요',
            xpAdded: 50,
            levelName: '새싹 저축러',
            currentXp: 62,
            levelProgressRatio: 0.62,
            xpIncreaseText: '▲ +8%',
            unitProgressText: 'Unit 1 완료까지 1 스테이지 남음',
            unitCompletionRatio: '2/3',
            unitProgressRatio: 0.66,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageData = _pagesContent[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top App Bar & Progress Bar Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF6A7282),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(_totalPages, (idx) {
                      bool isActive = idx <= _currentPage;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: idx == _totalPages - 1 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF00EE94)
                                : const Color(0xFFE4E8F0),
                            borderRadius: BorderRadius.circular(16777216),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      '${_currentPage + 1}/$_totalPages',
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

            // 2. Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      pageData['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      pageData['body']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4B5563),
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4E8F0), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00EE94),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '계속 하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
