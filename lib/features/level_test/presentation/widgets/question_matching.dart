import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(10),
        ),
      );

    Path dashPath = Path();
    double distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0; // Reset for next metric if any
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QuestionMatching extends StatelessWidget {
  final Map<String, dynamic> currentQ;
  final Map<String, String> matchingAnswers;
  final bool isAnswered;
  final ValueChanged<Map<String, String>> onMatchingChanged;

  const QuestionMatching({
    super.key,
    required this.currentQ,
    required this.matchingAnswers,
    required this.isAnswered,
    required this.onMatchingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final draggables = currentQ['draggableItems'] as List<String>;
    final targets = currentQ['targetDescriptions'] as List<String>;

    // Filter out items that are already matched
    final availableDraggables = draggables
        .where((item) => !matchingAnswers.containsValue(item))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          currentQ['prompt'] as String,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
            height: 16 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Draggable Cards Row
        Row(
          children: [
            Expanded(
              child: _buildDraggableItem(
                draggables[0],
                availableDraggables.contains(draggables[0]),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _buildDraggableItem(
                draggables[1],
                availableDraggables.contains(draggables[1]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Drag Targets (Dashed Slots)
        Row(
          children: [
            Expanded(child: _buildDragTarget(targets[0])),
            const SizedBox(width: 7),
            Expanded(child: _buildDragTarget(targets[1])),
          ],
        ),

        const SizedBox(height: 8),

        // Descriptions Row
        Row(
          children: [
            Expanded(child: _buildDescriptionCard(targets[0])),
            const SizedBox(width: 7),
            Expanded(child: _buildDescriptionCard(targets[1])),
          ],
        ),
      ],
    );
  }

  Widget _buildDraggableItem(String text, bool isAvailable) {
    if (!isAvailable) {
      // Return an empty placeholder if it's already dragged
      return const SizedBox(height: 51);
    }

    final card = Container(
      height: 51,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
          height: 16 / 14,
        ),
      ),
    );

    return Draggable<String>(
      data: text,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 196, // Fixed width for feedback to look similar
            child: card,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  Widget _buildDragTarget(String targetDesc) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        HapticFeedback.lightImpact();
        final newMap = Map<String, String>.from(matchingAnswers);
        newMap.removeWhere((key, value) => value == details.data);
        newMap[targetDesc] = details.data;
        onMatchingChanged(newMap);
      },
      builder: (context, candidateData, rejectedData) {
        final droppedItem = matchingAnswers[targetDesc];

        if (droppedItem != null) {
          // Show the dropped card, make it tappable to remove
          return GestureDetector(
            onTap: isAnswered
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    final newMap = Map<String, String>.from(matchingAnswers);
                    newMap.remove(targetDesc);
                    onMatchingChanged(newMap);
                  },
            child: Container(
              height: 51,
              decoration: BoxDecoration(
                color: isAnswered ? const Color(0xFFF2FFFA) : Colors.white,
                border: Border.all(
                  color: isAnswered
                      ? const Color(0xFF00EE94)
                      : const Color(0xFF00EE94),
                  width: isAnswered ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                droppedItem,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isAnswered
                      ? const Color(0xFF0DE593)
                      : const Color(0xFF111827),
                  height: 16 / 14,
                ),
              ),
            ),
          );
        }

        // Dashed Empty Slot
        return CustomPaint(
          painter: DashedRectPainter(
            color: const Color(0xFFD0D5E0),
            strokeWidth: 1.0,
            gap: 4.0,
          ),
          child: Container(height: 51, alignment: Alignment.center),
        );
      },
    );
  }

  Widget _buildDescriptionCard(String text) {
    return Container(
      height: 71,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Noto Sans KR',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4B5563),
          height: 14 / 12,
        ),
      ),
    );
  }
}
