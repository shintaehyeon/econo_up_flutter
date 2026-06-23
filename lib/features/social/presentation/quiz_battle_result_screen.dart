import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class QuizBattleResultScreen extends StatelessWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleResultScreen({
    super.key,
    this.onBottomTabSelected,
  });

  // Custom victory trophy SVG matching the Figma specs (circular gradient backdrop + trophy + "승리!" text)
  static const String _victoryTrophySvgString = '''
<svg viewBox="144 100 158 158" width="158" height="158" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="paint0_linear_912_11508" x1="223.5" y1="258" x2="223.5" y2="100" gradientUnits="userSpaceOnUse">
      <stop stop-color="#EDFFF8"/>
      <stop offset="0.110577" stop-color="#E4FFF5"/>
      <stop offset="1" stop-color="white"/>
    </linearGradient>
  </defs>
  <path d="M144.5 179C144.5 135.37 179.87 100 223.5 100C267.13 100 302.5 135.37 302.5 179C302.5 222.63 267.13 258 223.5 258C179.87 258 144.5 222.63 144.5 179Z" fill="url(#paint0_linear_912_11508)"/>
  <path d="M206.833 190V183.333H220.167V173C217.444 172.389 215.014 171.237 212.877 169.543C210.739 167.85 209.169 165.724 208.167 163.167C204 162.667 200.514 160.848 197.71 157.71C194.906 154.572 193.502 150.891 193.5 146.667V143.333C193.5 141.5 194.153 139.931 195.46 138.627C196.767 137.322 198.336 136.669 200.167 136.667H206.833V130H240.167V136.667H246.833C248.667 136.667 250.237 137.32 251.543 138.627C252.85 139.933 253.502 141.502 253.5 143.333V146.667C253.5 150.889 252.097 154.57 249.29 157.71C246.483 160.85 242.998 162.669 238.833 163.167C237.833 165.722 236.264 167.848 234.127 169.543C231.989 171.239 229.558 172.391 226.833 173V183.333H240.167V190H206.833ZM206.833 156V143.333H200.167V146.667C200.167 148.778 200.778 150.681 202 152.377C203.222 154.072 204.833 155.28 206.833 156ZM230.583 163.75C232.528 161.806 233.5 159.444 233.5 156.667V136.667H213.5V156.667C213.5 159.444 214.472 161.806 216.417 163.75C218.361 165.694 220.722 166.667 223.5 166.667C226.278 166.667 228.639 165.694 230.583 163.75ZM240.167 156C242.167 155.278 243.778 154.069 245 152.373C246.222 150.678 246.833 148.776 246.833 146.667V143.333H240.167V156Z" fill="#00EE94"/>
  <path d="M213.07 205.883C213.07 207.758 215.141 209.828 219.066 210.277L218.168 212.23C215.141 211.83 212.934 210.531 211.801 208.773C210.648 210.531 208.432 211.82 205.414 212.23L204.477 210.277C208.422 209.828 210.492 207.758 210.512 205.883V205.297H213.07V205.883ZM219.887 213.207V215.16H203.676V213.207H219.887ZM211.762 216.371C215.609 216.371 217.934 217.504 217.953 219.594C217.934 221.645 215.609 222.816 211.762 222.816C207.855 222.816 205.531 221.645 205.531 219.594C205.531 217.504 207.855 216.371 211.762 216.371ZM211.762 218.246C209.301 218.246 208.051 218.676 208.07 219.594C208.051 220.512 209.301 220.922 211.762 220.922C214.164 220.922 215.434 220.512 215.453 219.594C215.434 218.676 214.164 218.246 211.762 218.246ZM235.863 205.023V222.836H233.383V205.023H235.863ZM230.355 206.508V213.363H224.496V216.625C227.201 216.615 229.506 216.459 232.113 216.039L232.328 218.051C229.398 218.559 226.762 218.676 223.52 218.676H221.918V211.391H227.816V208.52H221.898V206.508H230.355ZM242.289 206.859L242.035 216.762H239.535L239.281 206.859H242.289ZM240.805 221.176C239.887 221.176 239.145 220.434 239.164 219.535C239.145 218.637 239.887 217.914 240.805 217.914C241.664 217.914 242.426 218.637 242.426 219.535C242.426 220.434 241.664 221.176 240.805 221.176Z" fill="#00EE94"/>
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
            // Custom Top Bar with centered Title "배틀 결과"
            Container(
              height: 44 * scale,
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              alignment: Alignment.center,
              child: Text(
                '배틀 결과',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF122711),
                  height: 1.0,
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 24 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Center Victory Trophy SVG
                    Center(
                      child: SizedBox(
                        width: 158 * scale,
                        height: 158 * scale,
                        child: SvgPicture.string(
                          _victoryTrophySvgString,
                          width: 158 * scale,
                          height: 158 * scale,
                        ),
                      ),
                    ),

                    SizedBox(height: 20 * scale),

                    // Scoreboard Card: "나 8 : 머니킹 5"
                    Container(
                      height: 68 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                        borderRadius: BorderRadius.circular(15.5 * scale),
                      ),
                      child: Row(
                        children: [
                          // Left side (Me)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '나',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 11 * scale,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2 * scale),
                                Text(
                                  '8',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 25 * scale,
                                    color: const Color(0xFF00EE94),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Center colon
                          Text(
                            ':',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 25 * scale,
                              color: const Color(0xFFD0D5E0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Right side (Opponent)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '머니킹',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 11 * scale,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2 * scale),
                                Text(
                                  '5',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 25 * scale,
                                    color: const Color(0xFF888E9B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Title: "머니킹 님에게 한마디 남기기"
                    Text(
                      '머니킹 님에게 한마디 남기기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Interactive Feedback cards
                    Row(
                      children: [
                        // Left: "분발하세요! 😤"
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '상대에게 반응을 보냈습니다! 😤',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13 * scale),
                                  ),
                                  backgroundColor: const Color(0xFFFF7C1F),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              height: 68 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF6F2),
                                border: Border.all(color: const Color(0xFFFF7C1F), width: 2 * scale),
                                borderRadius: BorderRadius.circular(15.5 * scale),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('😤', style: TextStyle(fontSize: 18 * scale)),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    '분발하세요!',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        // Right: "리스펙! 🫡"
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '상대에게 반응을 보냈습니다! 🫡',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13 * scale),
                                  ),
                                  backgroundColor: const Color(0xFF00EE94),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              height: 68 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2FFFA),
                                border: Border.all(color: const Color(0xFF00EE94), width: 2 * scale),
                                borderRadius: BorderRadius.circular(15.5 * scale),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🫡', style: TextStyle(fontSize: 18 * scale)),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    '리스펙 !',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12 * scale),

                    // Notification banner
                    Container(
                      height: 33 * scale,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFA),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '반응을 보내면 상대에게 알림이 가요',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00EE94),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.notifications_rounded,
                            color: const Color(0xFF00EE94),
                            size: 14 * scale,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 60 * scale),

                    // Rewards Stats Card
                    Container(
                      height: 65 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9DDE6), width: 1 * scale),
                        borderRadius: BorderRadius.circular(15.5 * scale),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: const Color(0xFF4B5563),
                                    size: 14 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    '+80 XP 획득',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4 * scale),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: const Color(0xFF4B5563),
                                    size: 14 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    '👑 왕관 +8개',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2FFFA),
                              borderRadius: BorderRadius.circular(9 * scale),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '주간 랭킹 2위 상승',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00EE94),
                                  ),
                                ),
                                SizedBox(width: 2 * scale),
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  color: const Color(0xFF00EE94),
                                  size: 10 * scale,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Button: 한 판 더!
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Container(
                        height: 48 * scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00EE94),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        child: Text(
                          '한 판 더!',
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

            // Bottom Navigation Bar
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
