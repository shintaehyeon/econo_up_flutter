import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class QuizBattleHistoryScreen extends StatelessWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleHistoryScreen({
    super.key,
    this.onBottomTabSelected,
  });

  // Mint color crown SVG matching the Figma specs (filled with #00EE94)
  static const String _crownSvgString = '''
<svg viewBox="45 509 18 14" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M59.25 521.25H48.75C48.375 521.25 48.075 521.025 48 520.65L46.5 513.15C46.5 512.85 46.575 512.55 46.875 512.325C47.175 512.175 47.475 512.175 47.7 512.325L50.775 514.8L53.325 510.975C53.625 510.525 54.3 510.525 54.6 510.975L57.15 514.8L60.225 512.325C60.45 512.1 60.825 512.1 61.05 512.325C61.35 512.475 61.425 512.775 61.425 513.15L59.925 520.65C59.925 521.025 59.55 521.25 59.175 521.25H59.25Z" fill="#00EE94"/>
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
            // Custom Top Bar with Back Button and center Title "배틀 전적"
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
                    '배틀 전적',
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
                    // Stats Overview Card (Wins, Draws, Losses, Crowns)
                    Container(
                      height: 69 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('승', '12', const Color(0xFF00EE94), scale),
                          _buildDivider(scale),
                          _buildStatItem('무', '3', const Color(0xFF6A7282), scale),
                          _buildDivider(scale),
                          _buildStatItem('패', '5', const Color(0xFFFF6A7D), scale),
                          _buildDivider(scale),
                          _buildStatItem('왕관', '276', const Color(0xFFFFA866), scale),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Section Title: "최근 배틀"
                    Text(
                      '최근 배틀',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF122711),
                        letterSpacing: -0.44 * scale,
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Recent Battles List
                    Column(
                      children: [
                        // Card 1: 김경제왕 (승 8:5)
                        _buildRecentBattleItem(
                          isWin: true,
                          name: '김경제왕',
                          score: '8:5',
                          scale: scale,
                        ),
                        SizedBox(height: 12 * scale),
                        // Card 2: 머니킹 (패 4:7)
                        _buildRecentBattleItem(
                          isWin: false,
                          name: '머니킹',
                          score: '4:7',
                          scale: scale,
                        ),
                        SizedBox(height: 12 * scale),
                        // Card 3: 주식초보 (승 9:3)
                        _buildRecentBattleItem(
                          isWin: true,
                          name: '주식초보',
                          score: '9:3',
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
                if (onBottomTabSelected != null) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  onBottomTabSelected!(_indexForBottomTab(tab));
                } else {
                  EconoBottomNavigationBar.goToRootTab(context, tab);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, double scale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(double scale) {
    return Container(
      width: 1 * scale,
      height: 28 * scale,
      color: const Color(0xFFD0D5E0),
    );
  }

  Widget _buildRecentBattleItem({
    required bool isWin,
    required String name,
    required String score,
    required double scale,
  }) {
    final statusColor = isWin ? const Color(0xFF00EE94) : const Color(0xFFFF8897);
    final statusText = isWin ? '승' : '패';

    return Container(
      height: 73 * scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          // Win/Loss Badge
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          SizedBox(width: 14 * scale),
          // Name & Score Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                  score,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // League/Crown status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: SvgPicture.string(
                  _crownSvgString,
                  width: 18 * scale,
                  height: 18 * scale,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                '상대의 리그',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
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
