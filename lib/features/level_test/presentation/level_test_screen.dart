// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LevelTestScreen extends StatelessWidget {
  const LevelTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '레벨 테스트',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz_rounded,
              size: 80,
              color: AppColors.brand,
            ),
            const SizedBox(height: 24),
            const Text(
              '레벨 테스트가 곧 시작됩니다! 🧠',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w850,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                '본인의 경제 상식 수준을 측정하고 최적의 스테이지를 배정받으세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                // TODO: 레벨 테스트 정밀 구현
              },
              child: const Text('테스트 시작하기'),
            )
          ],
        ),
      ),
    );
  }
}
