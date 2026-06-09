import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE4E8F0)
      ..strokeWidth = 1.0;

    // Y-axis line
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);

    // X-axis line
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GraphLinePainter extends CustomPainter {
  final List<double> points;
  final int? selectedIndex;
  final bool isAnswered;
  final int correctIndex;

  GraphLinePainter({
    required this.points,
    required this.selectedIndex,
    required this.isAnswered,
    required this.correctIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF00EE94)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = (1 - points[i]) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw selected circle
    if (selectedIndex != null) {
      final double x = selectedIndex! * stepX;
      final double y = (1 - points[selectedIndex!]) * size.height;

      Color circleColor = const Color(0xFF00EE94);
      if (isAnswered && selectedIndex != correctIndex) {
        circleColor = const Color(0xFFEF4444); // wrong selection
      }

      final circlePaint = Paint()
        ..color = circleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 6.0, circlePaint);
    }

    // If answered correctly, or if we want to show correct answer on wrong
    if (isAnswered && selectedIndex != correctIndex) {
      final double x = correctIndex * stepX;
      final double y = (1 - points[correctIndex]) * size.height;
      final correctPaint = Paint()
        ..color = const Color(0xFF00EE94)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6.0, correctPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GraphLinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isAnswered != isAnswered;
  }
}

class QuestionGraphInput extends StatelessWidget {
  final Map<String, dynamic> currentQ;
  final int? selectedGraphIndex;
  final TextEditingController baseRateController;
  final bool isAnswered;
  final ValueChanged<int> onGraphIndexSelected;
  final int? correctIndex;

  const QuestionGraphInput({
    super.key,
    required this.currentQ,
    required this.selectedGraphIndex,
    required this.baseRateController,
    required this.isAnswered,
    required this.onGraphIndexSelected,
    this.correctIndex,
  });

  @override
  Widget build(BuildContext context) {
    final points = currentQ['graphPoints'] as List<double>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graph Container
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '5%',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                    ),
                    Text(
                      '3%',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                    ),
                    Text(
                      '1%',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Graph area
                Expanded(
                  child: Stack(
                    children: [
                      // X & Y Axis Lines
                      Positioned.fill(
                        child: CustomPaint(painter: AxisPainter()),
                      ),
                      // Line Graph
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onTapDown: isAnswered
                                  ? null
                                  : (details) {
                                      final double stepX =
                                          constraints.maxWidth /
                                          (points.length - 1);
                                      final dx = details.localPosition.dx;
                                      final int index = (dx / stepX).round();
                                      if (index >= 0 && index < points.length) {
                                        HapticFeedback.lightImpact();
                                        onGraphIndexSelected(index);
                                      }
                                    },
                              child: CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                  painter: GraphLinePainter(
                                    points: points,
                                    selectedIndex: selectedGraphIndex,
                                    isAnswered: isAnswered,
                                    correctIndex: correctIndex ?? (currentQ['highestIndex'] as int?) ?? 0,
                                  ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Tooltip
                      if (selectedGraphIndex != null)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double stepX =
                                  constraints.maxWidth / (points.length - 1);
                              final double x = selectedGraphIndex! * stepX;
                              final double y =
                                  (1 - points[selectedGraphIndex!]) *
                                  constraints.maxHeight;
                              return Stack(
                                children: [
                                  Positioned(
                                    left: x - 25, // center tooltip
                                    top: y - 28,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2FFFA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        '최고점!',
                                        style: TextStyle(
                                          color: Color(0xFF0DE593),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Input Title
        const Text(
          '현재 기준금리를 입력하세요',
          style: TextStyle(
            fontFamily: 'Noto Sans KR',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        // TextField
        TextField(
          controller: baseRateController,
          enabled: !isAnswered,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD0D5E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD0D5E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00EE94), width: 2),
            ),
            hintText: '입력해주세요 (예: 3.5)',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          onChanged: (val) {
            // TextField handles its own state for text changes, but if we need to trigger a rebuild
            // in the parent to enable/disable the submit button, we might need a callback here.
            // Since controller is passed from parent, we will let the parent attach a listener
            // to the controller itself instead of passing onChanged.
          },
        ),
      ],
    );
  }
}
