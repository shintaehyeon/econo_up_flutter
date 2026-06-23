import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentCompleteScreen extends StatelessWidget {
  final String category;

  const PaymentCompleteScreen({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar area
            const SizedBox(height: 16),

            // Main content - centered
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Green circle with checkmark
                    Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00EE94),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(32.5, 26),
                          painter: _CheckmarkPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 19),

                    // "결제 완료!" title
                    const Text(
                      '결제 완료!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2A3A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      '$category 카테고리가 해금되었습니다',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 1.14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // "지금 바로 학습 시작" button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Pop back to roadmap (pop PaymentComplete + pop BottomSheet)
                        Navigator.of(context).pop('startLearning');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00EE94),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '지금 바로 학습 시작',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "홈으로" button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Pop all the way back to home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFD0D5E0),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '홈으로',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.875
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.10, size.height * 0.50)
      ..lineTo(size.width * 0.40, size.height * 0.80)
      ..lineTo(size.width * 0.90, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
