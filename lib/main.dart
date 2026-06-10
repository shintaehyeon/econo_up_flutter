// lib/main.dart

import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() {
  runApp(const EconoUpApp());
}

class EconoUpApp extends StatelessWidget {
  const EconoUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Econo-up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        colorScheme: const ColorScheme.light(
          primary: AppColors.brand,
          secondary: AppColors.mint,
          surface: AppColors.background,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.background,
        // 디폴트 텍스트 테마 세팅
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.ink),
          bodyMedium: TextStyle(color: AppColors.ink),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
