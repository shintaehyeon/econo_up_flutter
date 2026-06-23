// lib/features/curriculum/presentation/stage_complete_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StageCompleteScreen extends StatelessWidget {
  final String categoryTitle; // '금리' or '저축'
  final String completionMessage; // e.g. '금리와 소비의 관계를 이해했어요'
  final int xpAdded; // e.g. 50
  final String levelName; // e.g. '새싹 저축러'
  final int currentXp; // e.g. 62
  final double levelProgressRatio; // e.g. 0.62
  final String xpIncreaseText; // e.g. '▲ +8%'
  final String unitProgressText; // e.g. 'Unit 1 완료까지 1 스테이지 남음'
  final String unitCompletionRatio; // e.g. '2/3'
  final double unitProgressRatio; // e.g. 0.66

  const StageCompleteScreen({
    super.key,
    required this.categoryTitle,
    required this.completionMessage,
    this.xpAdded = 50,
    this.levelName = '새싹 저축러',
    this.currentXp = 62,
    this.levelProgressRatio = 0.62,
    this.xpIncreaseText = '▲ +8%',
    this.unitProgressText = 'Unit 1 완료까지 1 스테이지 남음',
    this.unitCompletionRatio = '2/3',
    this.unitProgressRatio = 0.66,
  });

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF1E2A3A);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textBody = Color(0xFF6A7282);
  static const Color textButton = Color(0xFF4B5563);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color lightGreenBg = Color(0xFFF2FFFA);
  static const Color progressBg = Color(0xFFF0F0F0);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header bar (Title only)
                _buildHeader(scale),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 10 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20 * scale),
                        
                        // Trophy Icon
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 60 * scale,
                          color: themeGreen,
                        ),
                        SizedBox(height: 14 * scale),
                        
                        // Message
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                          child: Text(
                            completionMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              height: 28 / 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        
                        // XP Added badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: lightGreenBg,
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Text(
                            '+$xpAdded XP',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0DE593),
                            ),
                          ),
                        ),
                        SizedBox(height: 32 * scale),
                        
                        // "나의 성장률" Title Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '나의 성장률',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: brandInk,
                              height: 17 / 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        
                        // 1. Level Progress Card
                        _buildLevelCard(scale),
                        SizedBox(height: 12 * scale),
                        
                        // 2. Unit Progress Card
                        _buildUnitProgressCard(scale),
                        SizedBox(height: 12 * scale),
                        
                        // 3. Simulation Challenge Card
                        _buildSimulationChallengeCard(scale),
                        SizedBox(height: 40 * scale),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Buttons Area
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24 * scale,
                    0,
                    24 * scale,
                    22 * scale,
                  ),
                  child: Column(
                    children: [
                      // "다음 스테이지 학습" Button
                      _buildBottomButton(
                        label: '다음 스테이지 학습',
                        backgroundColor: themeGreen,
                        borderColor: themeGreen,
                        textColor: Colors.white,
                        fontWeight: FontWeight.w700,
                        scale: scale,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context); // Go back to stage map / roadmap
                        },
                      ),
                      SizedBox(height: 12 * scale),
                      // "홈으로" Button
                      _buildBottomButton(
                        label: '홈으로',
                        backgroundColor: Colors.white,
                        borderColor: borderGrey,
                        textColor: textButton,
                        fontWeight: FontWeight.w700,
                        scale: scale,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return SizedBox(
      height: 44 * scale,
      child: Center(
        child: Text(
          '스테이지 완료!',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: brandInk,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 12 * scale,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row: Title level name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                levelName,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 20 / 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          
          // Progress bar
          Container(
            height: 6 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: progressBg,
              borderRadius: BorderRadius.circular(100 * scale),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (levelProgressRatio * 1000).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeGreen,
                      borderRadius: BorderRadius.circular(100 * scale),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1.0 - levelProgressRatio) * 1000).toInt(),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          SizedBox(height: 6 * scale),
          
          // Under bar row: XP info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentXp XP',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                  height: 16 / 11,
                ),
              ),
              Text(
                xpIncreaseText,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                  height: 16 / 9,
                ),
              ),
              Text(
                '${(levelProgressRatio * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w400,
                  color: themeGreen,
                  height: 16 / 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitProgressCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * scale, 6 * scale, 16 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 12 * scale,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row: Label & Ratio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unitProgressText,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 20 / 10,
                ),
              ),
              Text(
                unitCompletionRatio,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                  height: 16 / 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 2 * scale),
          
          // Progress bar
          Container(
            height: 6 * scale,
            width: double.infinity,
            decoration: BoxDecoration(
              color: progressBg,
              borderRadius: BorderRadius.circular(100 * scale),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (unitProgressRatio * 1000).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeGreen,
                      borderRadius: BorderRadius.circular(100 * scale),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1.0 - unitProgressRatio) * 1000).toInt(),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationChallengeCard(double scale) {
    return Container(
      width: double.infinity,
      height: 52 * scale,
      decoration: BoxDecoration(
        color: lightGreenBg,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: themeGreen, width: 1 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports_outlined,
            size: 18 * scale,
            color: themeGreen,
          ),
          SizedBox(width: 2 * scale),
          Text(
            '시뮬레이션 도전',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: themeGreen,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '오늘 배운 내용으로 실전 체험!',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10 * scale,
              fontWeight: FontWeight.w400,
              color: textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required FontWeight fontWeight,
    required double scale,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48 * scale,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10 * scale),
            side: BorderSide(color: borderColor, width: 1 * scale),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: fontWeight,
            color: textColor,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}
