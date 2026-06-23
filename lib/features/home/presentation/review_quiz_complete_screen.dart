// lib/features/home/presentation/review_quiz_complete_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReviewQuizCompleteScreen extends StatelessWidget {
  const ReviewQuizCompleteScreen({super.key});

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color rewardGreen = Color(0xFF1DDC83);
  static const Color streakOrange = Color(0xFFFF6900);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildResultCard(),
                        const SizedBox(height: 10),
                        _buildXpBanner(),
                        const SizedBox(height: 10),
                        _buildStreakBanner(),
                        const SizedBox(height: 10),
                        _buildLevelCard(),
                        const Spacer(),
                        _buildActionButton(
                          context,
                          '학습 이어가기',
                          primary: true,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          '홈으로',
                          primary: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SizedBox(
      height: 47,
      child: Center(
        child: Text(
          '복습 완료',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: brandInk,
            height: 22.5 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return SizedBox(
      height: 292,
      child: Column(
        children: [
          const SizedBox(height: 22),
          const _ClapIcon(),
          const SizedBox(height: 25),
          const Text(
            '5문제 중 4개 정답!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0DE593),
              height: 28 / 18,
            ),
          ),
          const Text(
            '정답률 80%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textDark,
              height: 16 / 12,
            ),
          ),
          const SizedBox(height: 51),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isFilled = index < 4;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 20,
                color: themeGreen,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBanner() {
    return Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FFFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+50 XP 획득',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: rewardGreen,
              height: 18 / 15,
            ),
          ),
          Text(
            '오늘의 복습 완료 보너스',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 15 / 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 17,
                color: streakOrange,
              ),
              SizedBox(width: 2),
              Text(
                '15일 연속 달성!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: brandInk,
                  height: 18 / 15,
                ),
              ),
            ],
          ),
          Text(
            '내일도 달려보자',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 15 / 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                '저축 새싹러',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 19.5 / 12,
                  letterSpacing: -0.0761719,
                ),
              ),
              Spacer(),
              Text(
                '다음 레벨까지 38%',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: themeGreen,
                  height: 16.5 / 11,
                  letterSpacing: 0.0644531,
                ),
              ),
              SizedBox(width: 14),
              Text(
                '62 XP',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                  height: 16.5 / 11,
                  letterSpacing: 0.0644531,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(19162500),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFF0F0F0)),
                  FractionallySizedBox(
                    widthFactor: 229 / 375,
                    child: Container(color: themeGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label, {
    required bool primary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.lightImpact();
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          }
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary ? themeGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: primary ? null : Border.all(color: borderGrey),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
              color: primary ? Colors.white : const Color(0xFF4B5563),
              height: primary ? 20 / 14 : 16 / 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClapIcon extends StatelessWidget {
  const _ClapIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/clap.png',
      width: 67,
      height: 67,
      fit: BoxFit.contain,
    );
  }
}
