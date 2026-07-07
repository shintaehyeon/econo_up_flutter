import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'quiz_battle_matched_screen.dart';

class QuizBattleFriendInviteScreen extends StatefulWidget {
  final ValueChanged<int>? onBottomTabSelected;

  const QuizBattleFriendInviteScreen({
    super.key,
    this.onBottomTabSelected,
  });

  @override
  State<QuizBattleFriendInviteScreen> createState() => _QuizBattleFriendInviteScreenState();
}

class _QuizBattleFriendInviteScreenState extends State<QuizBattleFriendInviteScreen> {
  String _requestStatus = '배틀 신청 중';
  bool _showRequest = true;
  bool _isActionTaken = false;

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
            // Custom Top Bar with Back Button and center Title "친구 배틀 신청"
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
                    '친구 배틀 신청',
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
                    // Box 1: 링크로 초대하기
                    Container(
                      height: 116 * scale,
                      padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 18 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF00EE94), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🔗 링크로 초대하기',
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
                            '친구에게 배틀을 신청하세요',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A7282),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '초대 링크가 복사되었습니다! 🔗',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13 * scale),
                                  ),
                                  backgroundColor: const Color(0xFF00EE94),
                                ),
                              );
                            },
                            child: Container(
                              width: 130 * scale,
                              height: 30 * scale,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00EE94),
                                borderRadius: BorderRadius.circular(20 * scale),
                              ),
                              child: Text(
                                '링크 복사',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.15 * scale,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // Box 2: 카카오로 공유
                    Container(
                      height: 116 * scale,
                      padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 18 * scale, 16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF00EE94), width: 1 * scale),
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '💬 카카오로 공유',
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
                            '카카오톡 앱으로 바로 전송',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6A7282),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '카카오톡 공유창을 열었습니다! 💬',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 13 * scale),
                                  ),
                                  backgroundColor: const Color(0xFF00EE94),
                                ),
                              );
                            },
                            child: Container(
                              width: 130 * scale,
                              height: 30 * scale,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00EE94),
                                borderRadius: BorderRadius.circular(20 * scale),
                              ),
                              child: Text(
                                '공유하기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.15 * scale,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Title: "받은 신청"
                    Text(
                      '받은 신청',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF122711),
                        letterSpacing: -0.44 * scale,
                      ),
                    ),

                    SizedBox(height: 10 * scale),

                    // Received list item
                    if (_showRequest)
                      Container(
                        height: 73 * scale,
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD0D5E0), width: 1 * scale),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 40 * scale,
                              height: 40 * scale,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12 * scale),
                            // Nickname & Subtitle
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '이수아',
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
                                    _requestStatus,
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
                            // Buttons
                            if (!_isActionTaken)
                              Row(
                                children: [
                                  // Decline
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _requestStatus = '신청 거절됨';
                                        _isActionTaken = true;
                                      });
                                      Future.delayed(const Duration(milliseconds: 1500), () {
                                        if (!mounted) return;
                                        setState(() {
                                          _showRequest = false;
                                        });
                                      });
                                    },
                                    child: Container(
                                      width: 49.18 * scale,
                                      height: 22.58 * scale,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F2F7),
                                        borderRadius: BorderRadius.circular(45.1629 * scale),
                                      ),
                                      child: Text(
                                        '거절',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 11 * scale,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5 * scale),
                                  // Accept
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _requestStatus = '수락 완료';
                                        _isActionTaken = true;
                                      });
                                      final navigator = Navigator.of(context);
                                      Future.delayed(const Duration(milliseconds: 600), () {
                                        if (!mounted) return;
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (context) => QuizBattleMatchedScreen(
                                              onBottomTabSelected: widget.onBottomTabSelected,
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 49.18 * scale,
                                      height: 22.58 * scale,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00EE94),
                                        borderRadius: BorderRadius.circular(45.1629 * scale),
                                      ),
                                      child: Text(
                                        '수락',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 11 * scale,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                if (widget.onBottomTabSelected != null) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  widget.onBottomTabSelected!(_indexForBottomTab(tab));
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
