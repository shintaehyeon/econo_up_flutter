// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIdx = 0; // 0: 홈, 1: 학습, 2: 커넥트, 3: 배틀, 4: 마이

  // 테마 색상 상속 (CSS의 #122711 대응하는 진녹색)
  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color themeRed = Color(0xFFFF7C7C);
  static const Color themeGold = Color(0xFFFCB94D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. 커스텀 탑 앱바 (Header)
            _buildTopAppBar(),

            // 2. 스크롤 가능한 메인 바디 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 복습 배너 (Streak & Review Card)
                    _buildStreakReviewCard(),
                    const SizedBox(height: 14),

                    // 오늘의 뉴스 한 줄 카드
                    _buildNewsCard(),
                    const SizedBox(height: 14),

                    // 골든 티켓 시한부 카드
                    _buildGoldenTicketCard(),
                    const SizedBox(height: 24),

                    // 이어서 학습하기 영역 (Continue learning)
                    _buildContinueLearningSection(),
                    const SizedBox(height: 14),

                    // 골드 리그 등급 카드
                    _buildLeagueCard(),
                    const SizedBox(height: 14),

                    // 시뮬레이션 도전 카드
                    _buildSimulationCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 3. 커스텀 하단 네비게이션 바 (Tab Bar)
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // 탑 앱바 (Econo-up 타이틀 & 하트, 지폐 재화 노출 영역)
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      color: const Color(0xFFF7F7F7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Econo-up',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  // 하트 충전 현황 알약 (Heart Pill)
                  _buildAssetPill(
                    icon: Icons.favorite_rounded,
                    value: '3',
                    iconColor: themeRed,
                  ),
                  const SizedBox(width: 12),
                  // 지폐 재화 알약 (Cash Pill)
                  _buildAssetPill(
                    icon: Icons.payments_rounded,
                    value: '5',
                    iconColor: const Color(0xFFA1E669),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '경제왕 님, 환영해요!',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: brandInk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetPill({
    required IconData icon,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB2B2B2),
            ),
          ),
        ],
      ),
    );
  }

  // 연속 학습 스트릭 및 데일리 복습 배너
  Widget _buildStreakReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 불꽃 스트릭 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEADB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF6900)),
                    SizedBox(width: 4),
                    Text(
                      '14일 연속 학습 중!',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: brandInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '어제 배운 용어 복습하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: brandInk,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 34,
              width: 63,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeGreen,
                  foregroundColor: brandInk,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // 복습 연결 액션
                },
                child: const Text(
                  '복습',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 오늘의 뉴스 연동 카드
  Widget _buildNewsCard() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.article_rounded, color: Color(0xFF4A5565), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 뉴스',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '미 연준 금리 동결 결정...',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB2B2B2), size: 20),
          ],
        ),
      ),
    );
  }

  // 골든 티켓 제한 시간 카드
  Widget _buildGoldenTicketCard() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFEFCE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_activity_rounded, color: Color(0xFFFCD31F), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '골든 티켓',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '12:34:56 후 만료',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '이어서 학습하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w750,
                color: brandInk,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Color(0xFFB2B2B2), size: 18),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 카드 1: 경제 상식
            Expanded(
              child: _buildLearningCard(
                category: '경제 상식',
                unit: 'Unit 1. 금리',
                progress: 0.6,
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            // 카드 2: 저축
            Expanded(
              child: _buildLearningCard(
                category: '저축',
                unit: 'Unit 1. 현금 관리',
                progress: 0.3,
                icon: Icons.savings_rounded,
                iconColor: AppColors.mint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLearningCard({
    required String category,
    required String unit,
    required double progress,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 113,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: brandInk,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A7282),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFFB2B2B2)),
            ],
          ),
          const Spacer(),
          // 그린 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 6,
              color: const Color(0xFFF3F4F6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 골드 리그 순위 카드
  Widget _buildLeagueCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFCB94D), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '골드 리그',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brandInk,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '주간 랭킹 3위 · 승급까지 24점',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 시뮬레이션 도전 카드
  Widget _buildSimulationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF6FEE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_esports_rounded, color: Color(0xFFA1E669), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 배운 내용으로 실전 체험!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7282),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '시뮬레이션 도전',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    letterSpacing: -0.44,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 34,
            width: 63,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF4B505A),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // 시뮬레이션 이동
              },
              child: const Text(
                '도전',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 5개 탭을 지원하는 persistent 하단 네비게이션 바 (Home, Learn, Connect, Battle, My)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabButton(0, Icons.home_rounded, '홈'),
          _buildTabButton(1, Icons.menu_book_rounded, '학습'),
          _buildTabButton(2, Icons.forum_rounded, '커넥트'),
          _buildTabButton(3, Icons.bolt_rounded, '배틀'),
          _buildTabButton(4, Icons.person_rounded, '마이'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isSelected = _currentTabIdx == index;
    final color = isSelected ? themeGreen : const Color(0xFF6A7282);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentTabIdx = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 60,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
