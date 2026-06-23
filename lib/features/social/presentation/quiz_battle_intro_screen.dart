import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'quiz_battle_waiting_screen.dart';

class QuizBattleIntroScreen extends StatelessWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleIntroScreen({
    super.key,
    this.onBottomTabSelected,
  });

  static const String _swordsSvgString = '''
<svg viewBox="194 112 60 52" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M202.5 150.454L205.38 153.334L199.247 159.414C198.5 160.187 197.167 160.187 196.42 159.414C195.673 158.64 195.647 157.334 196.42 156.587L202.5 150.454ZM239.273 118.454V114.667L222.5 131.44L205.727 114.667V118.454L220.607 133.334L210.5 143.494C207.353 141.254 202.98 141.52 200.18 144.32L211.513 155.654C214.313 152.854 214.58 148.48 212.367 145.334L239.273 118.454ZM248.58 156.587L242.5 150.454L239.62 153.334L245.753 159.414C246.5 160.187 247.833 160.187 248.58 159.414C249.327 158.64 249.353 157.334 248.58 156.587ZM234.5 143.494L226.287 135.227L224.393 137.12L232.66 145.334C230.42 148.48 230.687 152.854 233.487 155.654L244.82 144.32C242.02 141.52 237.647 141.254 234.5 143.494Z" fill="#00EE94"/>
</svg>
''';

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
            // Custom Top Bar with Back Button and centered Title
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
                padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 24 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Center Card: No Opponents Swords + Messages
                    Container(
                      padding: EdgeInsets.fromLTRB(12 * scale, 12 * scale, 12 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64 * scale,
                            height: 64 * scale,
                            child: SvgPicture.string(
                              _swordsSvgString,
                              width: 64 * scale,
                              height: 64 * scale,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            '지금 대기 중인 상대가 없어요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00EE94),
                              height: 28 / 18,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '내가 먼저 문제를 풀고 기다려볼까요?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                              height: 16 / 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Card 1: 진행 방식
                    Container(
                      padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 18 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '진행 방식',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF122711),
                              height: 18 / 12,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          _buildBulletItem('① 내가 먼저 10문제 풀기', scale),
                          SizedBox(height: 6 * scale),
                          _buildBulletItem('② 상대가 도전 — 나에게 결과 알림', scale),
                          SizedBox(height: 6 * scale),
                          _buildBulletItem('③ 앱 재접속 후 배틀 결과 확인', scale),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Card 2: 오늘의 배틀 퀴즈
                    Container(
                      padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 18 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF00EE94), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📝 오늘의 배틀 퀴즈',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF122711),
                                  height: 18 / 12,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(40 * scale),
                                ),
                                child: Text(
                                  '⚔️ 랜덤 출제',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6A7282),
                                    height: 12 / 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            '경제 상식 10문항 · 제한 시간 없음',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A7282),
                              height: 16 / 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48 * scale),

                    // Button: 퀴즈 시작하기
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuizBattleWaitingScreen(
                              onBottomTabSelected: onBottomTabSelected,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48 * scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00EE94),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        child: Text(
                          '퀴즈 시작하기 →',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 20 / 14,
                          ),
                        ),
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
                  onBottomTabSelected!(_indexForBottomTab(tab));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String label, double scale) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 11 * scale,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6A7282),
        height: 16 / 11,
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
