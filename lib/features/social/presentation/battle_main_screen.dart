import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'friend_screen.dart';
import 'league_screen.dart';
import 'quiz_battle_intro_screen.dart';
import 'quiz_battle_friend_invite_screen.dart';
import 'quiz_battle_history_screen.dart';

class BattleMainScreen extends StatefulWidget {
  final ValueChanged<int>? onBottomTabSelected;
  const BattleMainScreen({super.key, this.onBottomTabSelected});

  @override
  State<BattleMainScreen> createState() => _BattleMainScreenState();
}

class _BattleMainScreenState extends State<BattleMainScreen> {
  int _activeSubTabIdx = 0; // 0: 배틀, 1: 리그, 2: 친구

  static const String _swordsSvgString = '''
<svg viewBox="194 162 60 52" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M204.5 200.454L207.38 203.334L201.247 209.414C200.5 210.187 199.167 210.187 198.42 209.414C197.673 208.64 197.647 207.334 198.42 206.587L204.5 200.454ZM241.273 168.454V164.667L224.5 181.44L207.727 164.667V168.454L222.607 183.334L212.5 193.494C209.353 191.254 204.98 191.52 202.18 194.32L213.513 205.654C216.313 202.854 216.58 198.48 214.367 195.334L241.273 168.454ZM250.58 206.587L244.5 200.454L241.62 203.334L247.753 209.414C248.5 210.187 249.833 210.187 250.58 209.414C251.327 208.64 251.353 207.334 250.58 206.587ZM236.5 193.494L228.287 185.227L226.393 187.12L234.66 195.334C232.42 198.48 232.687 202.854 235.487 205.654L246.82 194.32C244.02 191.52 239.647 191.254 236.5 193.494Z" fill="#00EE94"/>
</svg>
''';

  static const String _crownSvgString = '''
<svg viewBox="45 509 18 14" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M59.25 521.25H48.75C48.375 521.25 48.075 521.025 48 520.65L46.5 513.15C46.5 512.85 46.575 512.55 46.875 512.325C47.175 512.175 47.475 512.175 47.7 512.325L50.775 514.8L53.325 510.975C53.625 510.525 54.3 510.525 54.6 510.975L57.15 514.8L60.225 512.325C60.45 512.1 60.825 512.1 61.05 512.325C61.35 512.475 61.425 512.775 61.425 513.15L59.925 520.65C59.925 521.025 59.55 521.25 59.175 521.25H59.25Z" fill="#FCD34D"/>
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
            // Top Bar - Title "소셜"
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 8 * scale),
              child: Text(
                '소셜',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF122711),
                  height: 22 / 16,
                ),
              ),
            ),

            // Sub-Tabs Row
            Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 6 * scale, 24 * scale, 6 * scale),
              child: Row(
                children: [
                  _buildSubTab('배틀', _activeSubTabIdx == 0, 0, scale),
                  SizedBox(width: 6 * scale),
                  _buildSubTab('리그', _activeSubTabIdx == 1, 1, scale),
                  SizedBox(width: 6 * scale),
                  _buildSubTab('친구', _activeSubTabIdx == 2, 2, scale),
                ],
              ),
            ),

            // Main Tab Content Area
            Expanded(
              child: _buildActiveTabBody(scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(String label, bool isActive, int index, double scale) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSubTabIdx = index;
          });
        },
        child: Container(
          height: 33 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00EE94) : Colors.white.withOpacity(0.15),
            border: isActive ? null : Border.all(color: const Color(0xFFD0D5E0), width: 1),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: (isActive ? 13 : 12) * scale,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF99A1AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabBody(double scale) {
    if (_activeSubTabIdx == 1) {
      return LeagueScreen(
        isEmbedded: true,
        onSubTabChanged: (index) {
          setState(() {
            _activeSubTabIdx = index;
          });
        },
      );
    }
    if (_activeSubTabIdx == 2) {
      return FriendScreen(
        isEmbedded: true,
        onSubTabChanged: (index) {
          setState(() {
            _activeSubTabIdx = index;
          });
        },
      );
    }

    // Default tab 0: 배틀 메인 (EC-4021)
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 24 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1: 랜덤 매칭
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizBattleIntroScreen(
                    onBottomTabSelected: (index) {
                      Navigator.of(context).pop();
                      if (widget.onBottomTabSelected != null) {
                        widget.onBottomTabSelected!(index);
                      }
                    },
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(12 * scale, 16 * scale, 12 * scale, 16 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF00EE94), width: 2 * scale),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00EE94).withOpacity(0.12),
                    blurRadius: 10 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
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
                  SizedBox(height: 6 * scale),
                  Text(
                    '랜덤 매칭',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00EE94),
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    '같은 티어 상대와 10문항 대결',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6A7282),
                      height: 16 / 10,
                      letterSpacing: 0.064 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12 * scale),

          // Card 2: 친구에게 배틀 신청
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizBattleFriendInviteScreen(
                    onBottomTabSelected: widget.onBottomTabSelected,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '👥',
                              style: TextStyle(fontSize: 14 * scale),
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              '친구에게 배틀 신청',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF122711),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          '카카오·링크 공유로 초대',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A7282),
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
          ),

          SizedBox(height: 24 * scale),

          // Header 3: 내 배틀 전적
          Text(
            '내 배틀 전적',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF122711),
              letterSpacing: -0.44 * scale,
            ),
          ),

          SizedBox(height: 10 * scale),

          // Card 3: 내 배틀 전적 통계
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizBattleHistoryScreen(
                    onBottomTabSelected: widget.onBottomTabSelected,
                  ),
                ),
              );
            },
            child: Container(
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
                  _buildRecordStat('승', '12', const Color(0xFF00EE94), scale),
                  Container(
                    width: 1 * scale,
                    height: 28 * scale,
                    color: const Color(0xFFD0D5E0),
                  ),
                  _buildRecordStat('무', '3', const Color(0xFF6A7282), scale),
                  Container(
                    width: 1 * scale,
                    height: 28 * scale,
                    color: const Color(0xFFD0D5E0),
                  ),
                  _buildRecordStat('패', '5', const Color(0xFFFF455D), scale),
                ],
              ),
            ),
          ),

          SizedBox(height: 12 * scale),

          // Card 4: 누적 왕관
          Container(
            padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 18 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF00EE94), width: 1 * scale),
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    SizedBox(width: 4 * scale),
                    Text(
                      '누적 왕관',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF122711),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Text(
                  '총 276개 · 이번 주 82개',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6A7282),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordStat(String label, String value, Color valueColor, double scale) {
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
}
