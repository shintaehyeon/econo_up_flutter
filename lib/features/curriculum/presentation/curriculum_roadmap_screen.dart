import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/presentation/study_detail_screen.dart';

class CurriculumRoadmapScreen extends StatefulWidget {
  final String title; // '경제 상식' 또는 '저축'

  const CurriculumRoadmapScreen({
    super.key,
    required this.title,
  });

  @override
  State<CurriculumRoadmapScreen> createState() => _CurriculumRoadmapScreenState();
}

class _CurriculumRoadmapScreenState extends State<CurriculumRoadmapScreen> {
  // 테마 색상 정의
  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color borderLight = Color(0xFFE5E7EB);

  // 커리큘럼 데이터 정의
  late final List<UnitData> _units;

  @override
  void initState() {
    super.initState();
    _units = widget.title == '저축' ? _getSavingCurriculum() : _getEconomyCurriculum();
  }

  List<UnitData> _getEconomyCurriculum() {
    return [
      UnitData(
        id: 1,
        title: '금리',
        description: '돈에도 몸값이 있다',
        emoji: '💰',
        state: UnitState.completed,
        lessons: [
          LessonData(name: '기준금리 기초', isCompleted: true),
          LessonData(name: '금리와 시장', isCompleted: true),
          LessonData(name: '매파와 비둘기파', isCompleted: true),
        ],
      ),
      UnitData(
        id: 2,
        title: '물가',
        description: '보이지 않는 내 돈 도둑',
        emoji: '📈',
        state: UnitState.active,
        lessons: [
          LessonData(name: '인플레이션', isCompleted: true),
          LessonData(name: '물가 관련 개념', isCompleted: false),
          LessonData(name: '실생활 속 물가', isCompleted: false),
        ],
      ),
      UnitData(
        id: 3,
        title: '환율',
        description: '돈의 환승역',
        emoji: '🔒',
        state: UnitState.locked,
        lessons: [
          LessonData(name: '환율의 기초', isCompleted: false),
          LessonData(name: '환율과 무역', isCompleted: false),
          LessonData(name: '기축통화와 안전자산', isCompleted: false),
        ],
      ),
    ];
  }

  List<UnitData> _getSavingCurriculum() {
    return [
      UnitData(
        id: 1,
        title: '현금 관리',
        description: '돈을 모으고 나누기',
        emoji: '💰',
        state: UnitState.completed,
        lessons: [
          LessonData(name: '예적금의 기초', isCompleted: true),
          LessonData(name: '비상금 마련', isCompleted: true),
          LessonData(name: '통장 쪼개기', isCompleted: true),
        ],
      ),
      UnitData(
        id: 2,
        title: '은행 활용법',
        description: '은행을 내 편으로 만들기',
        emoji: '🏦',
        state: UnitState.active,
        lessons: [
          LessonData(name: '금리 비교하기', isCompleted: true),
          LessonData(name: '주거래은행 혜택', isCompleted: false),
          LessonData(name: '예금자보호제도', isCompleted: false),
        ],
      ),
      UnitData(
        id: 3,
        title: '청년 정책 금융',
        description: '국가 지원 100% 활용하기',
        emoji: '🔒',
        state: UnitState.locked,
        lessons: [
          LessonData(name: '청년도약계좌', isCompleted: false),
          LessonData(name: '청년주택드림', isCompleted: false),
          LessonData(name: '정부 지원 적금', isCompleted: false),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);
    final cardWidth = (contentWidth - 32).clamp(0.0, 416.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header
            _buildHeader(),
            // 2. Main Scrollable Roadmap
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Center(
                      child: Container(
                        width: contentWidth,
                        color: const Color(0xFFF7F7F7),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Top Quote Summary Card
                            _buildTopQuoteCard(cardWidth),
                            const SizedBox(height: 16),
                            // Roadmap Nodes
                            SizedBox(
                              width: 354,
                              child: _buildRoadmapNodes(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 3. Floating Bottom Progress Card
                  Positioned(
                    bottom: 16,
                    child: _buildBottomProgressCard(cardWidth),
                  ),
                ],
              ),
            ),
            // 4. Bottom Tab Navigation
            _buildBottomNavigationBar(contentWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Designer spec: "경제상식" (No space)
    final String cleanTitle = widget.title.replaceAll(' ', '');
    return Container(
      width: double.infinity,
      height: 41,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6A7282),
                size: 20,
              ),
            ),
          ),
          Text(
            cleanTitle,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: brandInk,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuoteCard(double width) {
    final String quote = widget.title == '저축'
        ? '현명한 돈 관리가 풍요로운 미래를 만든다'
        : '세상 돌아가는 흐름을 읽는 자가 돈을 지킨다';
    return Container(
      width: width,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '총 10개 유닛',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: themeGreen,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapNodes() {
    final List<Widget> children = [];

    for (int i = 0; i < _units.length; i++) {
      final unit = _units[i];
      final bool isLeftNode = i % 2 == 0; // 0, 2, 4 -> Left Circle, Right Card

      children.add(_buildUnitRow(unit, isLeftNode));

      // If not the last unit, add the connecting curve
      if (i < _units.length - 1) {
        final nextUnit = _units[i + 1];
        final bool isCurveCompleted = unit.state == UnitState.completed && nextUnit.state != UnitState.locked;

        children.add(
          SizedBox(
            width: 354,
            height: 90,
            child: CustomPaint(
              painter: CurvePainter(
                isLeftToRight: isLeftNode, // If left circle, next is right circle, so Left-to-Right
                isCompleted: isCurveCompleted,
              ),
            ),
          ),
        );
      }
    }

    return Column(children: children);
  }

  Widget _buildUnitRow(UnitData unit, bool isLeftNode) {
    final circleButton = _buildCircleButton(unit);
    final infoCard = _buildInfoCard(unit);

    if (isLeftNode) {
      // Unit 1/3 (width 250)
      return Container(
        width: 354,
        height: 136,
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          height: 136,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                circleButton,
                const SizedBox(width: 12),
                infoCard,
              ],
            ),
          ),
        ),
      );
    } else {
      // Unit 2 (width 294)
      return Container(
        width: 354,
        height: 136,
        alignment: Alignment.center,
        child: SizedBox(
          width: 294,
          height: 136,
          child: Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Row(
              children: [
                infoCard,
                const SizedBox(width: 12),
                circleButton,
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildCircleButton(UnitData unit) {
    return GestureDetector(
      onTap: () => _handleUnitTap(unit),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Circle body
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unit.state == UnitState.completed
                  ? themeGreen
                  : unit.state == UnitState.active
                      ? Colors.white
                      : const Color(0xFFE8E8E8),
              boxShadow: [
                if (unit.state == UnitState.completed)
                  const BoxShadow(
                    color: Color(0x6600EE94),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  )
                else if (unit.state == UnitState.active)
                  const BoxShadow(
                    color: Color(0x4000EE94),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: unit.state == UnitState.active
                ? CustomPaint(
                    painter: DashedCirclePainter(color: themeGreen, strokeWidth: 3),
                    child: Center(
                      child: Text(
                        unit.emoji,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Opacity(
                      opacity: unit.state == UnitState.locked ? 0.5 : 1.0,
                      child: Text(
                        unit.state == UnitState.locked ? '🔒' : unit.emoji,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
          ),
          // Top-right badge
          if (unit.state == UnitState.completed)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: themeGreen, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A0A0A),
                    height: 1.4,
                  ),
                ),
              ),
            )
          else if (unit.state == UnitState.active)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: themeGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  '▶',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UnitData unit) {
    final bool isCompleted = unit.state == UnitState.completed;
    final bool isActive = unit.state == UnitState.active;

    return GestureDetector(
      onTap: () => _handleUnitTap(unit),
      child: Container(
        width: 140,
        height: 136,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive || isCompleted ? Colors.white : const Color(0xFFF3F3F3),
          border: Border.all(
            color: isActive
                ? themeGreen
                : isCompleted
                    ? const Color(0x4D01EE94) // rgba(1, 238, 148, 0.3)
                    : const Color(0xFFE8E8E8),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isActive)
              const BoxShadow(
                color: Color(0x2E00EE94), // rgba(0, 238, 148, 0.18)
                blurRadius: 10,
                offset: Offset(0, 2),
              )
            else if (isCompleted)
              const BoxShadow(
                color: Color(0x1F00EE94), // rgba(0, 238, 148, 0.12)
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Unit Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? const Color(0x3301EE94) // rgba(1, 238, 148, 0.2)
                    : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Unit ${unit.id}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive || isCompleted ? const Color(0xFF00C97D) : const Color(0xFFAAAAAA),
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Title
            Text(
              unit.title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive || isCompleted ? brandInk : const Color(0xFFC0C0C0),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 1),
            // Subtitle
            Text(
              unit.description,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isActive || isCompleted ? textMuted : const Color(0xFFD0D0D0),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            // Lesson Items
            ...unit.lessons.map((lesson) => _buildLessonItem(lesson, unit.state)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(LessonData lesson, UnitState unitState) {
    final bool isFinished = lesson.isCompleted && unitState != UnitState.locked;
    final bool isLocked = unitState == UnitState.locked;
    final Color textColor = isFinished
        ? themeGreen
        : isLocked
            ? const Color(0xFFD0D0D0)
            : const Color(0xFFC0C0C0);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            isFinished ? '✓' : '○',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              lesson.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: textColor,
                letterSpacing: 0.11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUnitTap(UnitData unit) {
    if (unit.state == UnitState.locked) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '이전 유닛을 완료해야 열립니다! 🔒',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyDetailScreen(
          title: widget.title,
        ),
      ),
    );
  }

  Widget _buildBottomProgressCard(double width) {
    return Container(
      width: width,
      height: 56.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '1/10 유닛 완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: themeGreen,
                  height: 1.5,
                ),
              ),
              Text(
                '10%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.10,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: themeGreen,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(double width) {
    return Container(
      width: double.infinity,
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderLight, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem(idx: 0, icon: Icons.home_rounded, label: '홈', iconSize: 29),
          _buildTabItem(idx: 1, icon: Icons.menu_book_rounded, label: '학습', iconSize: 29),
          _buildTabItem(
            idx: 2,
            icon: Icons.assignment_rounded,
            label: '커넥트',
            width: 63.14,
            iconSize: 30,
          ),
          _buildTabItem(idx: 3, icon: Icons.show_chart_rounded, label: '배틀', iconSize: 31),
          _buildTabItem(idx: 4, icon: Icons.person_rounded, label: '마이', iconSize: 29),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int idx,
    required IconData icon,
    required String label,
    double width = 56,
    double iconSize = 29,
  }) {
    final bool isActive = idx == 1; // Curriculum is part of "학습" tab
    final Color itemColor = isActive ? const Color(0xFF626262) : const Color(0xFFBCBCBC);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (idx != 1) {
          Navigator.pop(context, idx);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: itemColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: itemColor,
                height: 16 / 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Custom Painters for Roadmap Curves and Node Borders
// ----------------------------------------------------

class CurvePainter extends CustomPainter {
  final bool isLeftToRight;
  final bool isCompleted;

  CurvePainter({
    required this.isLeftToRight,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    if (isCompleted) {
      paint.color = const Color(0xB200EE94); // rgba(0, 238, 148, 0.7)
    } else {
      paint.color = const Color(0xFFE0E0E0);
    }

    final path = Path();

    // Node circles are positioned such that:
    // Left circle center is exactly x = 116.
    // Right circle center is exactly x = 216.
    const double startXLeft = 116;
    const double startXRight = 216;

    if (isLeftToRight) {
      path.moveTo(startXLeft, 0);
      path.cubicTo(
        startXLeft, size.height * 0.5,
        startXRight, size.height * 0.5,
        startXRight, size.height,
      );
    } else {
      path.moveTo(startXRight, 0);
      path.cubicTo(
        startXRight, size.height * 0.5,
        startXLeft, size.height * 0.5,
        startXLeft, size.height,
      );
    }

    if (isCompleted) {
      canvas.drawPath(path, paint);
    } else {
      _drawDashedPath(canvas, path, paint, 6, 6);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) =>
      oldDelegate.isLeftToRight != isLeftToRight || oldDelegate.isCompleted != isCompleted;
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    // Draw dashed circle
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

// ----------------------------------------------------
// Data Models for Curriculum
// ----------------------------------------------------

class UnitData {
  final int id;
  final String title;
  final String description;
  final String emoji;
  final List<LessonData> lessons;
  final UnitState state;

  UnitData({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.lessons,
    required this.state,
  });
}

class LessonData {
  final String name;
  final bool isCompleted;

  LessonData({
    required this.name,
    required this.isCompleted,
  });
}

enum UnitState {
  completed,
  active,
  locked,
}
