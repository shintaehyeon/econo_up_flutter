// lib/features/level_test/presentation/level_test_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/home_screen.dart';

class LevelTestResultScreen extends StatelessWidget {
  final int score;
  final String nickname;

  const LevelTestResultScreen({
    super.key,
    required this.score,
    this.nickname = '경제왕',
  });

  @override
  Widget build(BuildContext context) {
    // 레벨 판단 로직 및 스타일 설정
    String levelName;
    String description;
    IconData icon;
    Color levelColor;
    Color levelBg;
    String roadmapName;

    if (score >= 80) {
      levelName = '프로 골드 주주 🏆';
      description = '기본적인 금리, 채권, 공제 등 핵심 경제 지식을 이미 꿰뚫고 계시네요! 경제 상급 학습 패스로 다이렉트 매칭되었습니다.';
      icon = Icons.workspace_premium_rounded;
      levelColor = AppColors.gold;
      levelBg = AppColors.goldSoft;
      roadmapName = '실전 자산 배분 및 고소득 절세 트랙';
    } else if (score >= 40) {
      levelName = '성장하는 실버 투자자 📈';
      description = '기초적인 경제와 실물 자산 흐름을 잘 이해하고 계십니다! 중급 학습 코스에서 자산 증식 노하우를 확장하세요.';
      icon = Icons.stars_rounded;
      levelColor = AppColors.brand;
      levelBg = AppColors.brandSoft;
      roadmapName = '주식·펀드 투자 집중 마스터 트랙';
    } else {
      levelName = '스마트 새싹 저축가 🌱';
      description = '지금부터 차근차근 시작하면 됩니다! 기초 저축 예적금과 실생활 경제 용어부터 가장 쉽고 친절하게 알려 드릴게요.';
      icon = Icons.spa_rounded;
      levelColor = AppColors.mint;
      levelBg = AppColors.mintSoft;
      roadmapName = '초보 탈출 종잣돈 1억 모으기 트랙';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // 상단 로고 및 폭죽 연출
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: levelBg,
                      boxShadow: [
                        BoxShadow(
                          color: levelColor.withOpacity(0.12),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 72,
                      color: levelColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '레벨 테스트 완료! 🎉',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '당신의 정답률은 $score% 입니다.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: levelColor,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // 매핑된 배정 결과 카드 (Glassmorphism & Aesthetics)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: levelBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        levelName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: levelColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.line),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          '추천 맞춤 로드맵 배정',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roadmapName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // 서비스 시작 버튼
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
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
                      (route) => false, // 스택 완전 초기화
                    );
                  },
                  child: const Text(
                    '이코노업 학습 시작하기 🚀',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
