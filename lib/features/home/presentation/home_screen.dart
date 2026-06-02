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

  // 테마 색상 정의
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
            // 1. Custom Top Welcome Area
            _buildCustomTopHeader(),

            // 2. Scrollable main body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card 1: Streak / Review Card
                    _buildStreakReviewCard(),
                    const SizedBox(height: 14),

                    // Card 2: News Card
                    _buildNewsCard(),
                    const SizedBox(height: 14),

                    // Card 3: Golden Ticket Card
                    _buildGoldenTicketCard(),
                    const SizedBox(height: 24),

                    // Card 4: Continue Learning Section
                    _buildContinueLearningSection(),
                    const SizedBox(height: 14),

                    // Card 5: Weekly League Card
                    _buildLeagueCard(),
                    const SizedBox(height: 14),

                    // Card 6: Simulation Challenge Card
                    _buildSimulationCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 3. Pinned Bottom Navigation Tab Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Figma-aligned Top Welcome Header Area
  Widget _buildCustomTopHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                  _buildAssetPill(
                    iconPath: 'assets/heart_vector', 
                    iconColor: const Color(0xFFFF7C7C),
                    value: '3',
                  ),
                  const SizedBox(width: 12),
                  _buildAssetPill(
                    iconPath: 'assets/cash_vector',
                    iconColor: const Color(0xFFA1E669),
                    value: '5',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
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

  // Card 1: Fire Streak / Review Card (Refactored to be flexible)
  Widget _buildStreakReviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fire badge
          Container(
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
          const SizedBox(height: 12),
          // Heading description and Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  '어제 틀린 문제\n다시 풀어볼까요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '복습',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: News Card ("오늘의 뉴스")
  Widget _buildNewsCard() {
    return Container(
      width: double.infinity,
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
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.article_rounded, color: Color(0xFF4A5565), size: 20),
          ),
          const SizedBox(width: 12),
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
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB2B2B2), size: 14),
        ],
      ),
    );
  }

  // Card 3: Golden Ticket Card ("골든 티켓")
  Widget _buildGoldenTicketCard() {
    return Container(
      width: double.infinity,
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
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.confirmation_num_rounded, color: Color(0xFFFCD31F), size: 20),
          ),
          const SizedBox(width: 12),
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
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '12:34:56 후 만료',
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
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB2B2B2), size: 14),
        ],
      ),
    );
  }

  // Card 4: Continue Learning Section ("이어서 학습하기")
  Widget _buildContinueLearningSection() {
    return Column(
      children: [
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
              ),
            ),
            Icon(Icons.settings_rounded, color: Color(0xFFB2B2B2), size: 18),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildContinueCard(isEconomy: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildContinueCard(isEconomy: false)),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueCard({required bool isEconomy}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Allow it to shrink wrap height
        children: [
          Row(
            children: [
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
          const SizedBox(height: 12), // Replaced Spacer to fix overflow
          Text(
            isEconomy ? '경제 상식' : '저축',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: brandInk,
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
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16777216),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: isEconomy ? 0.6 : 0.3,
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
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3E8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFCB94D), size: 24),
          ),
          const SizedBox(width: 12),
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

  // Card 6: Simulation Challenge Card (Refactored to be flexible)
  Widget _buildSimulationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '오늘 배운 내용으로 실전 체험!',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FEE8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.sports_esports_rounded, color: Color(0xFFA1E669), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '시뮬레이션 도전',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '도전',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B505A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pinned Bottom Navigation Tab Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderLight, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
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
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
