import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'quiz_battle_matched_screen.dart';

class QuizBattleWaitingScreen extends StatefulWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleWaitingScreen({
    super.key,
    this.onBottomTabSelected,
  });

  @override
  State<QuizBattleWaitingScreen> createState() => _QuizBattleWaitingScreenState();
}

class _QuizBattleWaitingScreenState extends State<QuizBattleWaitingScreen> {
  bool _receiveNotifications = true;

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
            // Header: "배틀 대기 중"
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
                    '배틀 대기 중',
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
                    // Top Card: Completion details
                    Container(
                      padding: EdgeInsets.fromLTRB(12 * scale, 20 * scale, 12 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        children: [
                          // Green Check Circle
                          Container(
                            width: 65 * scale,
                            height: 65 * scale,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00EE94),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 32 * scale,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            '내 답변 등록 완료!',
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
                            '10문제 완료 · 정답률 알 수 없음',
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

                    SizedBox(height: 12 * scale),

                    // Mint Status Card with dots indicator (Tapping simulates matching an opponent)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QuizBattleMatchedScreen(
                              onBottomTabSelected: widget.onBottomTabSelected,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18 * scale, horizontal: 12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FFFA),
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '상대가 배틀에 참가하면\n결과를 알려드릴게요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00EE94),
                                height: 1.5,
                              ),
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
                    ),

                    SizedBox(height: 12 * scale),

                    // Toggle Notification Card
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF00EE94), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Row(
                        children: [
                          // Bell icon
                          Icon(
                            Icons.notifications_active_rounded,
                            color: const Color(0xFF00EE94),
                            size: 18 * scale,
                          ),
                          SizedBox(width: 12 * scale),
                          // Text Area
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '배틀 결과 알림 받기',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF122711),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 2 * scale),
                                Text(
                                  '상대가 도전하면 바로 알림을 드려요',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6A7282),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Toggle Switch
                          Transform.scale(
                            scale: 0.8 * scale,
                            child: Switch.adaptive(
                              value: _receiveNotifications,
                              activeColor: const Color(0xFF00EE94),
                              activeTrackColor: const Color(0x6600EE94),
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _receiveNotifications = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // "기다리는 동안" Title
                    Text(
                      '기다리는 동안',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF122711),
                        letterSpacing: -0.439453 * scale,
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Card 1: 학습 이어가기
                    _buildWaitingActionCard(
                      icon: Icons.menu_book_rounded,
                      title: '학습 이어가기',
                      subtitle: '지식 더 쌓으러 가기',
                      scale: scale,
                      onTap: () {
                        if (widget.onBottomTabSelected != null) {
                          // Tab 1 is 학습 (Learning)
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          widget.onBottomTabSelected!(1);
                        }
                      },
                    ),

                    SizedBox(height: 12 * scale),

                    // Card 2: 데일리 커넥트
                    _buildWaitingActionCard(
                      icon: Icons.article_rounded,
                      title: '데일리 커넥트',
                      subtitle: '오늘의 뉴스 확인하기',
                      scale: scale,
                      onTap: () {
                        if (widget.onBottomTabSelected != null) {
                          // Tab 2 is 커넥트 (Connect)
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          widget.onBottomTabSelected!(2);
                        }
                      },
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

  Widget _buildWaitingActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00EE94),
              size: 20 * scale,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF6A7282),
              size: 20 * scale,
            ),
          ],
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
