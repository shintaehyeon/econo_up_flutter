import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'poke_dialog.dart';

class FriendScreen extends StatelessWidget {
  final bool isEmbedded;
  final ValueChanged<int>? onSubTabChanged;

  const FriendScreen({
    super.key,
    this.isEmbedded = false,
    this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mainContent = Column(
      children: [
        // Ranking Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            height: 33,
            decoration: BoxDecoration(
              color: const Color(0xFFF2FFFA),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '⚡ 이번 주 친구 XP 랭킹',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00EE94),
                  ),
                ),
                Text(
                  '기준: 누적 XP',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildRankItem(
                context: context,
                rank: 1,
                isMe: false,
                isOnline: true,
                emoji: '🧩',
                name: '머니킹',
                desc: '포트폴리오 설계사',
                badge: '골드',
                streak: '21일',
                xp: '1,840',
                progress: 1.0,
              ),
              const SizedBox(height: 10),
              _buildRankItem(
                context: context,
                rank: 2,
                isMe: true,
                isOnline: true,
                emoji: '🏠',
                name: '경제왕 (나)',
                desc: '내 집 마련 성공',
                badge: '골드',
                streak: '14일',
                xp: '1,280',
                progress: 0.7,
              ),
              const SizedBox(height: 10),
              _buildRankItem(
                context: context,
                rank: 3,
                isMe: false,
                isOnline: true,
                emoji: '✂️',
                name: '김준서',
                desc: '절세 설계자',
                badge: '브론즈',
                streak: '14일',
                xp: '980',
                progress: 0.5,
              ),
              const SizedBox(height: 10),
              _buildRankItem(
                context: context,
                rank: 4,
                isMe: false,
                isOnline: false,
                emoji: '👛',
                name: '박태현',
                desc: '이자 챙기기',
                badge: '브론즈',
                streak: '오늘 미접속',
                xp: '760',
                progress: 0.35,
                showPoke: true,
              ),
              const SizedBox(height: 10),
              _buildRankItem(
                context: context,
                rank: 5,
                isMe: false,
                isOnline: false,
                emoji: '👁‍🗨',
                name: '이수아',
                desc: '경제 문맹',
                badge: '브론즈',
                streak: '',
                xp: '340',
                progress: 0.15,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
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
          children: [
            // Top Bar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: const Text(
                '배틀',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF122711),
                ),
              ),
            ),
            
            // Sub Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubTab('배틀', false, 0),
                  const SizedBox(width: 6),
                  _buildSubTab('리그', false, 1),
                  const SizedBox(width: 6),
                  _buildSubTab('친구', true, 2),
                ],
              ),
            ),
            
            // Content
            Expanded(child: mainContent),
            
            // Bottom Nav
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.battle),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, bool isSelected, int tabIdx) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onSubTabChanged != null) {
            onSubTabChanged!(tabIdx);
          }
        },
        child: Container(
          height: 33,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00EE94) : Colors.white,
            border: isSelected ? null : Border.all(color: const Color(0xFFD0D5E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: isSelected ? 13 : 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF99A1AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankItem({
    required BuildContext context,
    required int rank,
    required bool isMe,
    required bool isOnline,
    required String emoji,
    required String name,
    required String desc,
    required String badge,
    required String streak,
    required String xp,
    required double progress,
    bool showPoke = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF2FFFA) : Colors.white,
        border: Border.all(color: isMe ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Rank Icon/Text
          SizedBox(
            width: 24,
            child: RankIcon(rank: rank),
          ),
          const SizedBox(width: 8),
          
          // Avatar
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    shape: BoxShape.circle,
                    border: rank <= 3
                        ? Border.all(color: const Color(0xFF00EE94), width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    left: 47.7,
                    top: 5.3,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00EE94),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Small badge icon (crown for rank1, medal for rest)
                    if (rank == 1)
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CustomPaint(painter: CrownPainter()),
                      )
                    else
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: RankIcon(rank: rank <= 2 ? 2 : 3, size: 12),
                      ),
                    const SizedBox(width: 3),
                    Text(
                      badge,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    if (streak.isNotEmpty && streak != '오늘 미접속') ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CustomPaint(
                          painter: FlamePainter(
                            strokeColor: const Color(0xFFFF7C1F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        streak,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF7C1F),
                        ),
                      ),
                    ],
                    if (streak == '오늘 미접속') ...[
                      const SizedBox(width: 21),
                      Text(
                        '오늘 미접속',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF7C1F),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // XP & Progress
          SizedBox(
            width: 85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      xp,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isMe ? const Color(0xFF00EE94) : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'XP',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Progress Bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 6,
                    width: 85 * progress,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00EE94),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (showPoke) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => PokeDialog.show(context, name.replaceAll(' (나)', '')),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '찌르기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00EE94),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/icons/poke_finger.svg',
                            width: 14,
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RankIcon extends StatelessWidget {
  final int rank;
  final double size;
  const RankIcon({super.key, required this.rank, this.size = 20});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      // Crown
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CrownPainter(),
        ),
      );
    } else if (rank == 2 || rank == 3) {
      // Medal
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: size * 0.1,
              child: CustomPaint(
                size: Size(size * 0.8, size * 0.4),
                painter: RibbonPainter(),
              ),
            ),
            Positioned(
              bottom: size * 0.05,
              child: Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(
                  color: const Color(0xFF00EE94),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: size * 0.05),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        rank.toString(),
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: size * 0.8,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4B5563),
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}

class CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00EE94)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.4);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.9, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.9);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.close();
    
    // Create the hole
    final holePath = Path();
    holePath.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.65),
      radius: size.width * 0.15,
    ));
    
    final finalPath = Path.combine(PathOperation.difference, path, holePath);
    
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00EE94)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.35, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.close();
    
    path.moveTo(size.width, 0);
    path.lineTo(size.width * 0.65, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlamePainter extends CustomPainter {
  final Color strokeColor;
  FlamePainter({this.strokeColor = const Color(0xFFFF6900)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = const Color(0xFFFFF4ED)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.42
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start at bottom center
    path.moveTo(w * 0.50, h * 0.95);

    // Right side of flame base going up
    path.cubicTo(
      w * 0.80, h * 0.95,  // control 1
      w * 0.95, h * 0.75,  // control 2
      w * 0.85, h * 0.50,  // end point
    );

    // Right curve going to tip
    path.cubicTo(
      w * 0.78, h * 0.30,  // control 1
      w * 0.65, h * 0.15,  // control 2
      w * 0.50, h * 0.05,  // tip of flame
    );

    // Left curve from tip down
    path.cubicTo(
      w * 0.42, h * 0.20,  // control 1
      w * 0.50, h * 0.35,  // control 2
      w * 0.45, h * 0.50,  // inner notch
    );

    // Inner curve back to left base
    path.cubicTo(
      w * 0.38, h * 0.60,  // control 1
      w * 0.15, h * 0.60,  // control 2
      w * 0.15, h * 0.75,  // left base curve
    );

    // Back to bottom center
    path.cubicTo(
      w * 0.15, h * 0.90,  // control 1
      w * 0.30, h * 0.95,  // control 2
      w * 0.50, h * 0.95,  // back to start
    );

    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FingerSnapSmallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    // The original SVG was 30x30
    canvas.scale(w / 30.0, h / 30.0);

    // Hand shape (gray for list item)
    final handPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.fill;

    final handPath = Path();
    handPath.moveTo(11.8498, 17.2279);
    handPath.lineTo(5.63984, 15.565);
    handPath.cubicTo(4.95359, 15.3812, 4.36849, 14.9322, 4.01324, 14.317);
    handPath.cubicTo(3.65799, 13.7017, 3.5617, 12.9706, 3.74555, 12.2843);
    handPath.cubicTo(3.92941, 11.5981, 4.37834, 11.013, 4.99359, 10.6577);
    handPath.cubicTo(5.60884, 10.3025, 6.34002, 10.2062, 7.02627, 10.39);
    handPath.lineTo(19.4441, 13.7179);
    handPath.lineTo(19.337, 11.8279);
    handPath.cubicTo(19.2975, 11.1216, 19.5139, 10.4247, 19.9464, 9.86491);
    handPath.cubicTo(20.379, 9.30514, 20.9987, 8.91994, 21.6921, 8.77991);
    handPath.cubicTo(22.3855, 8.63987, 23.1062, 8.75436, 23.7221, 9.10241);
    handPath.cubicTo(24.338, 9.45046, 24.8078, 10.0088, 25.0456, 10.675);
    handPath.lineTo(26.9313, 15.9615);
    handPath.cubicTo(27.2237, 16.7813, 27.2596, 17.6707, 27.0341, 18.5115);
    handPath.lineTo(24.8184, 26.7807);
    handPath.cubicTo(24.5098, 27.9336, 23.732, 28.9365, 22.5598, 29.1572);
    handPath.cubicTo(20.747, 29.4957, 18.4948, 29.4036, 17.1491, 29.0415);
    handPath.cubicTo(13.5277, 28.0729, 10.0134, 25.0686, 11.8477, 17.2279);
    handPath.close();

    canvas.drawPath(handPath, handPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




