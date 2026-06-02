import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/home_screen.dart';

class LevelTestResultScreen extends StatelessWidget {
  final int score; // 0 ~ 100
  final String nickname;

  const LevelTestResultScreen({
    super.key,
    required this.score,
    this.nickname = '경제왕',
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = (score / 10).round();
    double progressRatio = correctCount / 10.0;

    // 레벨 판단 로직
    String levelName;
    String description;
    Color levelColor;
    Color levelBg;
    IconData iconData;

    if (score >= 80) {
      levelName = '프로 골드 주주';
      description = '완벽한 경제 지식을 갖추셨네요!';
      levelColor = AppColors.gold;
      levelBg = const Color(0xFFFFFDF2);
      iconData = Icons.workspace_premium_rounded;
    } else if (score >= 40) {
      levelName = '성장하는 실버 투자자';
      description = '기초적인 경제 흐름을 잘 이해하고 계십니다!';
      levelColor = AppColors.brand;
      levelBg = const Color(0xFFF2FFFA);
      iconData = Icons.stars_rounded;
    } else {
      levelName = '기초 탄탄 필요형';
      description = '경제 기본기를 다질 시간이에요!';
      levelColor = const Color(0xFF0DE593); // Figma spec
      levelBg = const Color(0xFFF2FFFA);
      iconData = Icons.eco_rounded; // ph:plant-duotone alternative
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Progress Bar Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simulated status bar time is usually handled by OS, skipping mock text to keep it native
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progressRatio,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00EE94),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Main Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 232,
                    decoration: BoxDecoration(
                      color: levelBg,
                      border: Border.all(color: const Color(0xFF00EE94), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          size: 66,
                          color: const Color(0xFF00EE94),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          levelName,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: levelColor,
                            height: 1.56,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF111827),
                            height: 1.33,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '정답률',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$correctCount / 10',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00EE94),
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Recommended Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '추천 시작 콘텐츠',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRecommendedCard(
                              emoji: '📚',
                              title: '경제 상식',
                              subtitle: 'Unit 1. 금리',
                            ),
                          ),
                          const SizedBox(height: 13),
                          Expanded(
                            child: _buildRecommendedCard(
                              emoji: '💰',
                              title: '저축',
                              subtitle: 'Unit 1. 현금 관리',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Bottom Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 24, // Adjust for native home indicator safely
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00EE94),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(nickname: nickname),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    '학습 시작하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.43,
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

  Widget _buildRecommendedCard({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 0, width: 8), // Replaced padding with width spacing
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7282),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Text(
            '→',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB2B2B2),
            ),
          ),
        ],
      ),
    );
  }
}
