// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_rounded,
              size: 80,
              color: AppColors.brand,
            ),
            const SizedBox(height: 24),
            const Text(
              '이코노업 홈 화면 🏠',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w850,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                '홈 화면이 곧 구현될 예정입니다. Milestone 1에서 대대적으로 실시간 지폐/하트 지갑과 캐릭터 성장을 보실 수 있습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('온보딩 처음으로 돌아가기'),
            )
          ],
        ),
      ),
    );
  }
}
