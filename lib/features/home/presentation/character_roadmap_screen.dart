import 'package:flutter/material.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class CharacterRoadmapScreen extends StatelessWidget {
  const CharacterRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6A7282), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      '저축 캐릭터',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF122711),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for centering
                ],
              ),
            ),
            
            // Subtitle & Current Character
            Container(
              padding: const EdgeInsets.only(top: 14, bottom: 5),
              child: Column(
                children: [
                  const Text(
                    '저축 학습 성장에 따라 캐릭터가 변해요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF0FFF9), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '🐷',
                          style: TextStyle(fontSize: 36),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '현재 단계',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0DE593),
                          ),
                        ),
                        Text(
                          '저금통 텅텅',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Roadmap List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '전체 성장 로드맵',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF122711),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLevelItem(
                      emoji: '🐷',
                      title: '저금통 텅텅',
                      levelXp: '저축 Lv.1 · XP 0',
                      desc: '거지 신세 탈출! 지출 분석 마스터',
                      status: '장착',
                      isLocked: false,
                    ),
                    const SizedBox(height: 10),
                    _buildLevelItem(
                      emoji: '🪙',
                      title: '동전 모으기',
                      levelXp: '저축 Lv.2 · XP 200',
                      desc: '통장 쪼개기 달인. 새는 돈이 없다',
                      status: '장착 중',
                      isLocked: false,
                    ),
                    const SizedBox(height: 10),
                    _buildLevelItem(
                      emoji: '🔒',
                      title: '통장 쪼개기',
                      levelXp: '저축 Lv.3 · XP 300',
                      desc: '',
                      status: '예정',
                      isLocked: true,
                    ),
                    const SizedBox(height: 10),
                    _buildLevelItem(
                      emoji: '🔒',
                      title: '이자 챙기기',
                      levelXp: '저축 Lv.4 · XP 400',
                      desc: '',
                      status: '예정',
                      isLocked: true,
                    ),
                    const SizedBox(height: 10),
                    _buildLevelItem(
                      emoji: '🔒',
                      title: '목표 저축러',
                      levelXp: '저축 Lv.5 · XP 500',
                      desc: '',
                      status: '예정',
                      isLocked: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bottom Nav
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.my),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem({
    required String emoji,
    required String title,
    required String levelXp,
    required String desc,
    required String status,
    required bool isLocked,
  }) {
    Color bgColor = isLocked ? const Color(0xFFF3F3F3) : const Color(0xFFF2FFFA);
    Color borderColor = isLocked ? const Color(0xFFE8E8E8) : (status == '장착 중' ? const Color(0xFF00EE94) : Colors.transparent);
    Color iconBgColor = isLocked ? const Color(0xFFE8E8E8) : Colors.white;
    
    Color titleColor = isLocked ? const Color(0xFFC0C0C0) : const Color(0xFF111827);
    Color levelXpColor = isLocked ? const Color(0xFFD0D0D0) : const Color(0xFF9CA3AF);
    
    Color btnBgColor;
    Color btnTextColor;
    if (status == '장착 중') {
      btnBgColor = const Color(0xFF00EE94);
      btnTextColor = Colors.white; // Or 4B5563 if requested, but green button usually white text or dark text
    } else if (status == '장착') {
      btnBgColor = const Color(0xFF4B5563);
      btnTextColor = const Color(0xFFE8E8E8);
    } else {
      btnBgColor = const Color(0xFFE8E8E8);
      btnTextColor = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 21,
                color: isLocked ? Colors.black.withOpacity(0.5) : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: btnBgColor,
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: status == '장착 중' ? const Color(0xFF4B5563) : btnTextColor, // Figma says 4B5563 for 장착 중
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  levelXp,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: levelXpColor,
                  ),
                ),
                if (!isLocked && desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
