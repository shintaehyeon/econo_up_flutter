import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'news_detail_screen.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({
    super.key,
    this.onBottomTabSelected,
  });

  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const String _newsImagePath = 'assets/images/news_fed_powell.png';

  static const List<_NewsItem> _items = [
    _NewsItem(category: '환율', title: '환율 급등, 원/달러 1,400원 돌파', date: '2026.04.06'),
    _NewsItem(category: '물가', title: '소비자물가 3개월 연속 하락', date: '2026.03.18'),
    _NewsItem(category: '부동산', title: '부동산 거래량 반등 조짐', date: '2026.03.02'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: contentWidth,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 34 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(scale),
                SizedBox(height: 14 * scale),
                _buildFilterTabs(scale),
                SizedBox(height: 26 * scale),
                _buildSectionTitle(scale),
                SizedBox(height: 14 * scale),
                _buildHeadlineCard(context, scale),
                SizedBox(height: 15 * scale),
                ..._items.map((item) => _buildNewsListItem(context, item, scale)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Text(
      '데일리 커넥트',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        color: brandInk,
        height: 22.5 / 16,
      ),
    );
  }

  Widget _buildFilterTabs(double scale) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: HapticFeedback.lightImpact,
          child: Container(
            width: 52.75 * scale,
            height: 37.13 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: themeGreen,
              borderRadius: BorderRadius.circular(16777216),
            ),
            child: Text(
              '전체',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: HapticFeedback.lightImpact,
          child: Container(
            width: 52.75 * scale,
            height: 37.13 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(16777216),
            ),
            child: _BookmarkIcon(
              width: 20 * scale,
              height: 20 * scale,
              color: borderGrey,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(double scale) {
    return Text(
      '오늘의 헤드라인',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14 * scale,
        fontWeight: FontWeight.w700,
        color: brandInk,
        height: 17 / 14,
        letterSpacing: -0.439453 * scale,
      ),
    );
  }

  Widget _buildHeadlineCard(BuildContext context, double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: SizedBox(
          width: double.infinity,
          height: 193 * scale,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _newsImagePath,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A000000),
                      Color(0xE6000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 17 * scale,
                right: 17 * scale,
                bottom: 65 * scale,
                child: Text(
                  '미 연준, 기준금리 동결 결정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 20 / 18,
                  ),
                ),
              ),
              Positioned(
                left: 17 * scale,
                right: 17 * scale,
                bottom: 43 * scale,
                child: Text(
                  '시장 예상에 부합, 연내 인하 기대 유지',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 16.5 / 12,
                  ),
                ),
              ),
              Positioned(
                left: 17 * scale,
                bottom: 18 * scale,
                child: Row(
                  children: [
                    _buildHeroPill('금리', scale),
                    SizedBox(width: 8 * scale),
                    _buildQuizCompletePill(scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPill(String label, double scale) {
    return Container(
      height: 22 * scale,
      padding: EdgeInsets.symmetric(horizontal: 14 * scale),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x2600EE94),
        borderRadius: BorderRadius.circular(16777216),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          color: themeGreen,
          height: 18 / 12,
        ),
      ),
    );
  }

  Widget _buildQuizCompletePill(double scale) {
    return Container(
      height: 22 * scale,
      padding: EdgeInsets.fromLTRB(12 * scale, 0, 14 * scale, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x2600EE94),
        borderRadius: BorderRadius.circular(16777216),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: 15 * scale,
            color: themeGreen,
          ),
          SizedBox(width: 5 * scale),
          Text(
            '오늘 퀴즈 완료',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: themeGreen,
              height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListItem(BuildContext context, _NewsItem item, double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context),
      child: SizedBox(
        width: double.infinity,
        height: 101 * scale,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 13 * scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6 * scale),
                child: SizedBox(
                  width: 102 * scale,
                  height: 68 * scale,
                  child: Image.asset(
                    _newsImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 13 * scale),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 13 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryPill(item.category, scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: brandInk,
                        height: 18.25 / 14,
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w500,
                        color: textLight,
                        height: 15 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 13 * scale),
              child: _BookmarkIcon(
                width: 16 * scale,
                height: 16 * scale,
                color: const Color(0xFFB2B2B2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, double scale) {
    final width = label.length > 2 ? 39.0 : 32.0;
    return Container(
      width: width * scale,
      height: 16 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10 * scale,
          fontWeight: FontWeight.w500,
          color: textMuted,
          height: 13.5 / 10,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          onBottomTabSelected: onBottomTabSelected,
        ),
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({
    required this.width,
    required this.height,
    required this.color,
    this.filled = false,
  });

  final double width;
  final double height;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BookmarkIconPainter(color: color, filled: filled),
    );
  }
}

class _BookmarkIconPainter extends CustomPainter {
  const _BookmarkIconPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.26, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.26, size.height * 0.08, size.width * 0.30, size.height * 0.08)
      ..lineTo(size.width * 0.70, size.height * 0.08)
      ..quadraticBezierTo(size.width * 0.74, size.height * 0.08, size.width * 0.74, size.height * 0.12)
      ..lineTo(size.width * 0.74, size.height * 0.88)
      ..lineTo(size.width * 0.50, size.height * 0.72)
      ..lineTo(size.width * 0.26, size.height * 0.88)
      ..close();

    if (filled) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      return;
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.12
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BookmarkIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}

class _NewsItem {
  const _NewsItem({
    required this.category,
    required this.title,
    required this.date,
  });

  final String category;
  final String title;
  final String date;
}
