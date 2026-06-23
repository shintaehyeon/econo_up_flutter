import 'package:flutter/material.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'quiz_battle_solving_screen.dart';

class QuizBattleMatchedScreen extends StatelessWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleMatchedScreen({
    super.key,
    this.onBottomTabSelected,
  });

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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 24 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Banner (Tapping starts the quiz battle)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuizBattleSolvingScreen(
                              onBottomTabSelected: onBottomTabSelected,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 33 * scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FFFA),
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        child: Text(
                          '⚔️ 상대를 찾았어요! 배틀을 시작합니다',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00EE94),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // VS Card Area
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left: Me
                              _buildPlayerCard(
                                emoji: '🐷',
                                name: '경제왕',
                                tier: '🥉 브론즈',
                                badgeText: 'READY',
                                isBadgeActive: true,
                                scale: scale,
                              ),
                              SizedBox(width: 32 * scale),
                              // Center: VS
                              Text(
                                'VS',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans KR',
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0DE593),
                                ),
                              ),
                              SizedBox(width: 32 * scale),
                              // Right: Opponent
                              _buildPlayerCard(
                                emoji: '😵‍💫',
                                name: '머니킹',
                                tier: '🥉 브론즈',
                                badgeText: 'WAIT',
                                isBadgeActive: false,
                                scale: scale,
                              ),
                            ],
                          ),
                          SizedBox(height: 12 * scale),
                          // Dots Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(true, scale),
                              SizedBox(width: 4 * scale),
                              _buildDot(false, scale),
                              SizedBox(width: 4 * scale),
                              _buildDot(false, scale),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Opponent Info Card
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '상대 정보',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A7282),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            '최근 배틀 승률 62%',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF122711),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Explanation Card
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFA),
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📝 같은 문제 10문항을 풀어요',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF122711),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '상대는 이미 답변을 등록했어요 — 내 결과와 비교! 동점이면 더 빠른 시간 안에 푼 사람이 승리합니다⚡',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6A7282),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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
                if (onBottomTabSelected != null) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  onBottomTabSelected!(_indexForBottomTab(tab));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required String emoji,
    required String name,
    required String tier,
    required String badgeText,
    required bool isBadgeActive,
    required double scale,
  }) {
    return Column(
      children: [
        // Profile frame
        Container(
          width: 74 * scale,
          height: 74 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            border: Border.all(color: const Color(0xFF00EE94), width: 1.85 * scale),
            shape: BoxShape.circle,
          ),
          child: Text(
            emoji,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 29.6 * scale,
              height: 40 / 29.6,
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        // Name & Tier
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          tier,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        SizedBox(height: 10 * scale),
        // Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 2 * scale),
          decoration: BoxDecoration(
            color: isBadgeActive
                ? const Color(0xFF0DE593)
                : const Color(0x660DE593),
            borderRadius: BorderRadius.circular(30 * scale),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive, double scale) {
    return Container(
      width: 8 * scale,
      height: 8 * scale,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00EE94) : const Color(0x3300EE94),
        shape: BoxShape.circle,
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
