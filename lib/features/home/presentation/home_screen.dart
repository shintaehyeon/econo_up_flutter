// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final String nickname;

  const HomeScreen({
    super.key,
    this.nickname = '경제왕',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIdx = 0; // 0: 홈, 1: 학습, 2: 커넥트, 3: 배틀, 4: 마이

  // 테마 색상 정의 (Figma CSS의 #122711 브랜드 잉크 및 온보딩 그린 대응)
  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color borderLight = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Custom Top Welcome Area (Figma height 136px, background #F7F7F7)
            _buildCustomTopHeader(),

            // 2. Scrollable main body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card 1: Streak / Review Card (Height 100px)
                    _buildStreakReviewCard(),
                    const SizedBox(height: 14),

                    // Card 2: News Card (Height 74px)
                    _buildNewsCard(),
                    const SizedBox(height: 14),

                    // Card 3: Golden Ticket Card (Height 74px)
                    _buildGoldenTicketCard(),
                    const SizedBox(height: 24),

                    // Card 4: Continue Learning Section (Height 153px)
                    _buildContinueLearningSection(),
                    const SizedBox(height: 14),

                    // Card 5: Weekly League Card (Height 62px)
                    _buildLeagueCard(),
                    const SizedBox(height: 14),

                    // Card 6: Simulation Challenge Card (Height 98px)
                    _buildSimulationCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 3. Pinned Bottom Navigation Tab Bar (Height 77px)
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Figma-aligned Top Welcome Header Area (Height 136px)
  Widget _buildCustomTopHeader() {
    return Container(
      width: double.infinity,
      height: 136,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Econo-up" Title
              const Text(
                'Econo-up',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 32 / 24,
                ),
              ),
              // Asset Pills (Heart & Cash)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heart Asset Pill (3 hearts)
                  _buildAssetPill(
                    iconPath: 'assets/heart_vector', // Mock vector using custom colors
                    iconColor: const Color(0xFFFF7C7C),
                    value: '3',
                  ),
                  const SizedBox(width: 12),
                  // Cash Asset Pill (5 bills)
                  _buildAssetPill(
                    iconPath: 'assets/cash_vector',
                    iconColor: const Color(0xFFA1E669),
                    value: '5',
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Heading 2: Welcome dynamic nickname message
          Text(
            '${widget.nickname} 님, 환영해요!',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 32 / 22,
            ),
          ),
          const SizedBox(height: 15), // Align space dynamically
        ],
      ),
    );
  }

  // Helper asset pill
  Widget _buildAssetPill({
    required String iconPath,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconColor == const Color(0xFFFF7C7C) ? Icons.favorite_rounded : Icons.payments_rounded,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB2B2B2),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }

  // Card 1: Fire Streak / Review Card
  Widget _buildStreakReviewCard() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Fire badge
          Positioned(
            left: 19,
            top: 17,
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEADB),
                borderRadius: BorderRadius.circular(16777216),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF6900)),
                  SizedBox(width: 4),
                  Text(
                    '14일 연속 학습 중!',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                      height: 14 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Heading description
          const Positioned(
            left: 22,
            top: 54,
            child: Text(
              '어제 틀린 문제\n다시 풀어볼까요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: brandInk,
                height: 28 / 18,
              ),
            ),
          ),
          // "복습" Button
          Positioned(
            left: 323,
            top: 49,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Navigate to review (Phase 2 scope)
              },
              child: Container(
                width: 63,
                height: 34,
                decoration: BoxDecoration(
                  color: themeGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '복습',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 17 / 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: News Card ("오늘의 뉴스")
  Widget _buildNewsCard() {
    return Container(
      width: double.infinity,
      height: 74,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon wrapper
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.article_rounded,
              color: Color(0xFF4A5565),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '오늘의 뉴스',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 20 / 14,
                  ),
                ),
                Text(
                  '미 연준 금리 동결 결정...',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7282),
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFFB2B2B2),
            size: 14,
          ),
        ],
      ),
    );
  }

  // Card 3: Golden Ticket Card ("골든 티켓")
  Widget _buildGoldenTicketCard() {
    return Container(
      width: double.infinity,
      height: 74,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon wrapper
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.confirmation_num_rounded,
              color: Color(0xFFFCD31F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '골든 티켓',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 20 / 14,
                  ),
                ),
                Text(
                  '12:34:56 후 만료',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7282),
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFFB2B2B2),
            size: 14,
          ),
        ],
      ),
    );
  }

  // Card 4: Continue Learning Section ("이어서 학습하기")
  Widget _buildContinueLearningSection() {
    return Column(
      children: [
        // Title block
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '이어서 학습하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: brandInk,
                height: 19 / 16,
              ),
            ),
            Icon(
              Icons.settings_rounded,
              color: Color(0xFFB2B2B2),
              size: 18,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Content Row with exactly two cards
        Row(
          children: [
            // Card 4.1: 경제 상식
            Expanded(child: _buildContinueCard(isEconomy: true)),
            const SizedBox(width: 12),
            // Card 4.2: 저축
            Expanded(child: _buildContinueCard(isEconomy: false)),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueCard({required bool isEconomy}) {
    return Container(
      height: 113,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon block
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  isEconomy ? '📚' : '💰',
                  style: const TextStyle(fontSize: 24, height: 1),
                ),
              ),
              const Spacer(),
              // Arrow "→"
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
          const Spacer(),
          // Titles
          Text(
            isEconomy ? '경제 상식' : '저축',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 19 / 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isEconomy ? 'Unit 1. 금리' : 'Unit 1. 현금 관리',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              height: 14 / 12,
            ),
          ),
          const SizedBox(height: 8),
          // Progress indicator background
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16777216),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: isEconomy ? 0.6 : 0.3, // 60% vs 30% progress
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: themeGreen,
                  borderRadius: BorderRadius.circular(16777216),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 5: Weekly League Card
  Widget _buildLeagueCard() {
    return Container(
      width: double.infinity,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Crown Icon wrapper
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3E8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFCB94D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Text Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '골드 리그',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brandInk,
                    height: 16 / 13,
                  ),
                ),
                Text(
                  '주간 랭킹 3위 · 승급까지 24점',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7282),
                    height: 13 / 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 6: Simulation Challenge Card
  Widget _buildSimulationCard() {
    return Container(
      width: double.infinity,
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Subtext
          const Positioned(
            left: 21,
            top: 15,
            child: Text(
              '오늘 배운 내용으로 실전 체험!',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A7282),
                height: 20 / 12,
              ),
            ),
          ),
          // Main Title
          const Positioned(
            left: 48,
            top: 35,
            child: Text(
              '시뮬레이션 도전',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: brandInk,
                height: 28 / 18,
              ),
            ),
          ),
          // Icon container
          Positioned(
            left: 16,
            top: 44,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF6FEE8),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Color(0xFFA1E669),
                size: 24,
              ),
            ),
          ),
          // Button "도전"
          Positioned(
            left: 323,
            top: 45,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
              },
              child: Container(
                width: 63,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '도전',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B505A),
                    height: 17 / 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pinned Bottom Navigation Tab Bar (Height 77px)
  Widget _buildBottomNavigationBar() {
    return Container(
      width: double.infinity,
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderLight, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 9, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(idx: 0, icon: Icons.home_rounded, label: '홈'),
          _buildTabItem(idx: 1, icon: Icons.menu_book_rounded, label: '학습'),
          _buildTabItem(idx: 2, icon: Icons.connect_without_contact_rounded, label: '커넥트'),
          _buildTabItem(idx: 3, icon: Icons.insights_rounded, label: '배틀'),
          _buildTabItem(idx: 4, icon: Icons.person_rounded, label: '마이'),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int idx,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _currentTabIdx == idx;
    final Color itemColor = isActive ? themeGreen : textMuted;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentTabIdx = idx;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: itemColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: itemColor,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
