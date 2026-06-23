import 'package:flutter/material.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class LeagueScreen extends StatelessWidget {
  final bool isEmbedded;
  final ValueChanged<int>? onSubTabChanged;

  const LeagueScreen({
    super.key,
    this.isEmbedded = false,
    this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMyLeagueCard(),
          const SizedBox(height: 32),
          const Text(
            '골드 리그 랭킹',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF122711),
            ),
          ),
          const SizedBox(height: 16),
          _buildRankingItem(1, '왕초보탈출', '320', false),
          const SizedBox(height: 12),
          _buildRankingItem(2, '경제박사', '298', false),
          const SizedBox(height: 12),
          _buildRankingItem(3, '경제왕', '나', true),
          const SizedBox(height: 12),
          _buildRankingItem(4, '머니킹', '254', false),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (isEmbedded) {
      return Container(
        color: Colors.white,
        child: mainContent,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '배틀',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF122711),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildTab('배틀', false, 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('리그', true, 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('친구', false, 2)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: mainContent,
            ),
            
            // Bottom Nav
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.battle),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, int tabIdx) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onSubTabChanged != null) {
            onSubTabChanged!(tabIdx);
          }
        },
        child: Container(
          height: 33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00EE94) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? null : Border.all(color: const Color(0xFFD0D5E0)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: isActive ? 13 : 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF99A1AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLeagueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEE201), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FEEE201),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Color(0xFF00EE94), size: 24),
                  const SizedBox(width: 6),
                  const Text(
                    '골드 리그',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FFFA),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'D-3',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0DE593),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '랭킹 3위',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '승급까지 24점',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF99A1AF),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '72%',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.72,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00EE94),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(int rank, String name, String points, bool isMe) {
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF2FFFA) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
        ),
      ),
      child: Row(
        children: [
          if (rank <= 3) ...[
            const Icon(Icons.military_tech, color: Color(0xFF00EE94), size: 16),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: rank <= 3 ? 24 : 44, // Align numbers if icon is missing
            child: Text(
              '$rank위',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF99A1AF),
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          const Icon(Icons.workspace_premium, color: Color(0xFFFCD34D), size: 18),
          const SizedBox(width: 4),
          Text(
            points,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}
