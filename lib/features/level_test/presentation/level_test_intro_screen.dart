// lib/features/level_test/presentation/level_test_intro_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'level_test_screen.dart';
import '../../home/presentation/home_screen.dart';

class LevelTestIntroScreen extends StatelessWidget {
  final String nickname;

  const LevelTestIntroScreen({
    super.key,
    this.nickname = '경제왕',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Status Bar Container (Figma: padding 16px 24px 0px, height 44px)
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button & Time Row
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time "9:41"
                  const Text(
                    '9:41',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 20 / 14,
                    ),
                  ),
                  const Spacer(),
                  // Battery / Wifi Icon Placeholder
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi, size: 14, color: Color(0xFF111827)),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF111827), width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.all(1),
                        child: Container(
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Progress Indicator Section (Figma: padding 12px 24px 0px, height 48px)
            Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Bar Background
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E8F0),
                      borderRadius: BorderRadius.circular(16777216),
                    ),
                    alignment: Alignment.centerLeft,
                    // Fully filled 100% since it's 6/6 steps
                    child: Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00EE94),
                        borderRadius: BorderRadius.circular(16777216),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Step Indicator text "6 / 6"
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '6 / 6',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 16 / 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spacer to push content down nicely
            const Spacer(flex: 1),

            // 3. Main Content Card area (Figma: width 399px inside horizontal margin 24px)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3.1. Top Level Test Green Badge (height 55px, background #F2FFFA, radius 16px)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FFFA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '레벨 테스트',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0DE593),
                            height: 20 / 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '딱 10문제예요!',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                            height: 14 / 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3.2. Central Info Box (height 185px, border 1px #D0D5E0, radius 10px)
                  Container(
                    width: double.infinity,
                    height: 185,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(21),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NicName block
                        Text(
                          '$nickname 님에게',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                            height: 16 / 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Content Intro description
                        const Text(
                          '딱 맞는 콘텐츠를 추천하기 위해\n레벨 테스트를 진행할게요!',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            height: 21 / 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Bullet 1: Time spent
                        Row(
                          children: const [
                            Text(
                              '⏱️',
                              style: TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '10문제, 약 3분 소요',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                                height: 16 / 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Bullet 2: Outcome
                        Row(
                          children: const [
                            Text(
                              '📊',
                              style: TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '결과에 따라 딱 맞는 시작 콘텐츠 추천',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4B5563),
                                height: 16 / 12,
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

            // Spacer to push buttons to the bottom
            const Spacer(flex: 2),

            // 4. Bottom Button Group (Figma: padding 0px, gap 12px, height 132px)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button 1: 시작하기
                  SizedBox(
                    width: double.infinity,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LevelTestScreen(nickname: nickname),
                          ),
                        );
                      },
                      child: const Text(
                        '레벨 테스트 시작하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button 2: 건너뛰기
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD0D5E0), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        '건너뛰고 기본 레벨로 시작',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
