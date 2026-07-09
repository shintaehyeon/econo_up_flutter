// lib/main.dart

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: const String.fromEnvironment(
      'ECONOUP_KAKAO_NATIVE_APP_KEY',
      defaultValue: '325e8b419d792b1880b65a44afdf9482',
    ),
  );
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
      onGenerateRoute: (settings) {
        if (settings.name == HomeScreen.routeName) {
          final tabIndex =
              settings.arguments is int ? settings.arguments as int : 0;
          return MaterialPageRoute(
            builder: (_) => HomeScreen(initialTabIndex: tabIndex),
          );
        }
        return null;
      },
      home: const SplashScreen(),
    );
  }
}
