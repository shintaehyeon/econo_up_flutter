import 'package:flutter/material.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class PromotionResultScreen extends StatelessWidget {
  const PromotionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '승급 결과',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF122711),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6A7282), size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Trophy Circle
                    Center(
                      child: Container(
                        width: 232,
                        height: 232,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE4FFFF), Colors.white],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              size: 60,
                              color: Color(0xFF00EE94),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              '플래티넘 리그 승급!',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E2A3A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '골드 → 플래티넘',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00EE94),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60), // Add some spacing before statistics
                    
                    // Statistics Section
                    const Text(
                      '승급 통계',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF122711),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 69,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        border: Border.all(color: const Color(0xFFD0D5E0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Total Crowns
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '총 왕관',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '320개',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00EE94),
                                ),
                              ),
                            ],
                          ),
                          // Divider
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFD0D5E0),
                          ),
                          // Battles Won
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '이긴 배틀 수',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '8회',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00EE94),
                                ),
                              ),
                            ],
                          ),
                          // Divider
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFD0D5E0),
                          ),
                          // Accuracy
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '정답률',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '82%',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00EE94),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Nav
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.battle),
          ],
        ),
      ),
    );
  }
}
