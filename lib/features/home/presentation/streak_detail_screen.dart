// lib/features/home/presentation/streak_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'revival_ticket_purchase_screen.dart';

class StreakDetailScreen extends StatelessWidget {
  const StreakDetailScreen({super.key});

  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color completedGreen = Color(0xFF00EE94);
  static const Color uncompletedGrey = Color(0xFFE4E8F0);
  static const Color themeOrange = Color(0xFFFF6900);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('연속학습'),
                        const SizedBox(height: 14),
                        _buildStreakCountCard(),
                        const SizedBox(height: 20),
                        _buildMonthlyRecordCard(),
                        const SizedBox(height: 20),
                        _buildRevivalTicketCard(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(right: 19),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.close_rounded,
          color: textMuted,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SizedBox(
      height: 28,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: brandInk,
            height: 19 / 16,
            letterSpacing: -0.439453,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCountCard() {
    return Container(
      height: 134,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 21,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 55,
                  color: themeOrange,
                ),
                SizedBox(width: 4),
                Text(
                  '14',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: themeOrange,
                    height: 28 / 40,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 84,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 159,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '14일 연속 학습 중!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeOrange,
                    height: 19 / 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRecordCard() {
    final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('이번 달 학습 기록'),
        const SizedBox(height: 14),
        Container(
          height: 207,
          padding: const EdgeInsets.fromLTRB(30, 22, 30, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (colIndex) {
                    return SizedBox(
                      width: 36,
                      child: Text(
                        weekDays[colIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          height: 14 / 12,
                          letterSpacing: 0.166992,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 132,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (rowIndex) {
                    final isGreen = rowIndex < 2;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (_) {
                        return Container(
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isGreen ? completedGreen : uncompletedGrey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevivalTicketCard(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(16, 0, 22, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF6FEE8),
              shape: BoxShape.circle,
            ),
            child: const _RevivalWingIcon(),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '연속 학습 부활권',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 28 / 16,
                    letterSpacing: -0.439453,
                  ),
                ),
                Text(
                  '스트릭이 끊겨도 지폐 2개로 복구',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                    height: 20 / 12,
                    letterSpacing: -0.150391,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RevivalTicketPurchaseScreen(
                    onClose: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            child: Container(
              width: 74,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '사용하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B505A),
                  height: 17 / 14,
                  letterSpacing: -0.150391,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevivalWingIcon extends StatelessWidget {
  const _RevivalWingIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _RevivalWingIconPainter(),
      ),
    );
  }
}

class _RevivalWingIconPainter extends CustomPainter {
  const _RevivalWingIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 20;
    final scaleY = size.height / 20;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = const Color(0xFFA1E669)
      ..style = PaintingStyle.fill;

    final mainWing = Path()
      ..moveTo(0.7, 16.9)
      ..cubicTo(4.3, 9.5, 10.5, 4.8, 19.6, 3.2)
      ..cubicTo(18.4, 9.8, 14.4, 13.1, 8.7, 14.5)
      ..cubicTo(5.3, 15.3, 2.7, 16.4, 0.7, 18.2)
      ..cubicTo(0.5, 17.8, 0.5, 17.3, 0.7, 16.9)
      ..close();

    final cut = Path()
      ..moveTo(4.5, 14.6)
      ..cubicTo(7.7, 10.7, 11.5, 8.0, 16.4, 6.5)
      ..cubicTo(14.4, 9.3, 11.8, 11.2, 8.7, 12.2)
      ..cubicTo(6.9, 12.7, 5.5, 13.5, 4.5, 14.6)
      ..close();

    canvas.drawPath(Path.combine(PathOperation.difference, mainWing, cut), paint);

    final shaftPaint = Paint()
      ..color = const Color(0xFFA1E669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final shaft = Path()
      ..moveTo(1.5, 17.2)
      ..cubicTo(5.2, 14.4, 9.7, 11.2, 14.5, 8.6);
    canvas.drawPath(shaft, shaftPaint);

    final lowerFeather = Path()
      ..moveTo(1.0, 18.9)
      ..cubicTo(3.7, 17.2, 6.3, 16.6, 9.3, 17.0)
      ..cubicTo(7.1, 18.8, 4.2, 19.5, 1.0, 18.9)
      ..close();
    canvas.drawPath(lowerFeather, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
