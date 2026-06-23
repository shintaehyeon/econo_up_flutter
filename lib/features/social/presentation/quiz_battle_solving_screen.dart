import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'quiz_battle_result_screen.dart';

class QuizBattleSolvingScreen extends StatefulWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleSolvingScreen({
    super.key,
    this.onBottomTabSelected,
  });

  @override
  State<QuizBattleSolvingScreen> createState() => _QuizBattleSolvingScreenState();
}

class _QuizBattleSolvingScreenState extends State<QuizBattleSolvingScreen> {
  String _selectedOption = 'B'; // Default active option from Figma spec

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header: "퀴즈 배틀"
            Container(
              height: 44 * scale,
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8 * scale),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF6A7282),
                          size: 20 * scale,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '퀴즈 배틀',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF122711),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Header: "6/10" & "배틀 퀴즈"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 6 * scale),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '6/10',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        '⚔️ 배틀 퀴즈',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  // Segmented Progress Bar
                  Row(
                    children: List.generate(10, (index) {
                      final isCompletedOrCurrent = index < 6; // Questions 1-6 are green
                      return Expanded(
                        child: Container(
                          height: 4 * scale,
                          margin: EdgeInsets.only(
                            right: index == 9 ? 0 : 8 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: isCompletedOrCurrent
                                ? const Color(0xFF00EE94)
                                : const Color(0xFFE4E8F0),
                            borderRadius: BorderRadius.circular(1.68 * scale),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12 * scale),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 24 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Opponent Status Banner
                    Container(
                      height: 33 * scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFA),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Text(
                        '상대 머니킹 — 이미 모든 답변 완료 ✅',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00EE94),
                        ),
                      ),
                    ),

                    SizedBox(height: 32 * scale),

                    // Question Content Box
                    Column(
                      children: [
                        // Category Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2FFFA),
                            borderRadius: BorderRadius.circular(30 * scale),
                          ),
                          child: Text(
                            '경제 상식 · 금리',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0DE593),
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        // Topic
                        Text(
                          '금리가 오를 때',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                            height: 1.14,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        // Question
                        Text(
                          '채권 가격은?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            height: 1.42,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32 * scale),

                    // Choices Area
                    Column(
                      children: [
                        _buildChoiceButton(
                          id: 'A',
                          text: 'A. 오른다',
                          scale: scale,
                        ),
                        SizedBox(height: 12 * scale),
                        _buildChoiceButton(
                          id: 'B',
                          text: 'B. 내려간다',
                          scale: scale,
                        ),
                        SizedBox(height: 12 * scale),
                        _buildChoiceButton(
                          id: 'C',
                          text: 'C. 변화 없다',
                          scale: scale,
                        ),
                        SizedBox(height: 12 * scale),
                        _buildChoiceButton(
                          id: 'D',
                          text: 'D. 알 수 없다',
                          scale: scale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Nav Bar highlighted on Battle
            EconoBottomNavigationBar(
              activeTab: EconoBottomTab.battle,
              scale: scale,
              onTabSelected: (tab) {
                if (widget.onBottomTabSelected != null) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  widget.onBottomTabSelected!(_indexForBottomTab(tab));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String id,
    required String text,
    required double scale,
  }) {
    final isSelected = _selectedOption == id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedOption = id;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizBattleResultScreen(
                onBottomTabSelected: widget.onBottomTabSelected,
              ),
            ),
          );
        });
      },
      child: Container(
        height: 55 * scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
            width: isSelected ? 2 * scale : 1 * scale,
          ),
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
            height: 1.14,
          ),
        ),
      ),
    );
  }

  int _indexForBottomTab(EconoBottomTab tab) {
    switch (tab) {
      case EconoBottomTab.home:
        return 0;
      case EconoBottomTab.learning:
        return 1;
      case EconoBottomTab.connect:
        return 2;
      case EconoBottomTab.battle:
        return 3;
      case EconoBottomTab.my:
        return 4;
    }
  }
}
