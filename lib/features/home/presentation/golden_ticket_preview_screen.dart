// lib/features/home/presentation/golden_ticket_preview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoldenTicketPreviewScreen extends StatelessWidget {
  const GoldenTicketPreviewScreen({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textButton = Color(0xFF4B5563);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color ticketYellow = Color(0xFFFCD31F);
  static const Color ticketBg = Color(0xFFFEFCE8);

  static const List<_PreviewStage> _stages = [
    _PreviewStage(stage: 'Stage 1', title: '주식 시장의 구조'),
    _PreviewStage(stage: 'Stage 2', title: 'ETF란 무엇인가'),
    _PreviewStage(stage: 'Stage 3', title: 'ETF 선택 기준'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      28 * scale,
                      20 * scale,
                      24 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TicketCard(scale: scale),
                        SizedBox(height: 14 * scale),
                        _buildPreviewSection(scale),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24 * scale,
                    0,
                    24 * scale,
                    22 * scale,
                  ),
                  child: Column(
                    children: [
                      _BottomActionButton(
                        label: '지금 바로 수강하기',
                        backgroundColor: themeGreen,
                        borderColor: themeGreen,
                        textColor: Colors.white,
                        fontWeight: FontWeight.w700,
                        scale: scale,
                        onTap: HapticFeedback.lightImpact,
                      ),
                      SizedBox(height: 12 * scale),
                      _BottomActionButton(
                        label: '나중에 구매하기',
                        backgroundColor: Colors.white,
                        borderColor: borderGrey,
                        textColor: textButton,
                        fontWeight: FontWeight.w500,
                        scale: scale,
                        onTap: () => _close(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return SizedBox(
      height: 47 * scale,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24 * scale, 0, 19 * scale, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '골든 티켓',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 22.5 / 16,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _close(context),
              child: SizedBox(
                width: 36 * scale,
                height: 36 * scale,
                child: Icon(
                  Icons.close_rounded,
                  size: 24 * scale,
                  color: iconGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(double scale) {
    return SizedBox(
      width: 399 * scale,
      height: 223 * scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 28 * scale,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '수강 내용 미리보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 17 / 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 14 * scale),
          for (var i = 0; i < _stages.length; i++) ...[
            _PreviewStageCard(stage: _stages[i], scale: scale),
            if (i != _stages.length - 1) SizedBox(height: 8 * scale),
          ],
        ],
      ),
    );
  }

  void _close(BuildContext context) {
    HapticFeedback.lightImpact();
    if (onClose != null) {
      onClose!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 407 * scale,
      height: 189 * scale,
      child: CustomPaint(
        painter: _TicketPainter(scale: scale),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 33 * scale,
              child: Text(
                '주식 유닛: ETF 기초',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: GoldenTicketPreviewScreen.textDark,
                  height: 21 / 18,
                ),
              ),
            ),
            Positioned(
              top: 60 * scale,
              child: Text(
                '12시간 무료 수강',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: GoldenTicketPreviewScreen.ticketYellow,
                  height: 14 / 12,
                ),
              ),
            ),
            Positioned(
              top: 84 * scale,
              child: Text(
                '유료 카테고리 무료 체험 찬스!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: GoldenTicketPreviewScreen.iconGrey,
                  height: 14 / 12,
                ),
              ),
            ),
            Positioned(
              top: 134 * scale,
              child: Text(
                '남은 시간',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                  color: GoldenTicketPreviewScreen.textMuted,
                  height: 13 / 11,
                ),
              ),
            ),
            Positioned(
              top: 149 * scale,
              child: Text(
                '11 : 23 : 44',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                  color: GoldenTicketPreviewScreen.ticketYellow,
                  height: 24 / 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  const _TicketPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = GoldenTicketPreviewScreen.ticketYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    final fill = Paint()
      ..color = GoldenTicketPreviewScreen.ticketBg
      ..style = PaintingStyle.fill;

    final path = Path();
    final radius = 16 * scale;
    final notchRadius = 10 * scale;
    final notchCenterY = 113 * scale;
    final w = size.width;
    final h = size.height;

    path
      ..moveTo(radius, 0)
      ..lineTo(w - radius, 0)
      ..quadraticBezierTo(w, 0, w, radius)
      ..lineTo(w, notchCenterY - notchRadius)
      ..arcToPoint(
        Offset(w, notchCenterY + notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(w, h - radius)
      ..quadraticBezierTo(w, h, w - radius, h)
      ..lineTo(radius, h)
      ..quadraticBezierTo(0, h, 0, h - radius)
      ..lineTo(0, notchCenterY + notchRadius)
      ..arcToPoint(
        Offset(0, notchCenterY - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);

    final dashPaint = Paint()
      ..color = GoldenTicketPreviewScreen.ticketYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    final dashY = 118 * scale;
    var x = 11 * scale;
    final endX = w - 11 * scale;
    final dash = 3 * scale;
    final gap = 4 * scale;
    while (x < endX) {
      final nextX = (x + dash).clamp(0.0, endX).toDouble();
      canvas.drawLine(Offset(x, dashY), Offset(nextX, dashY), dashPaint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}

class _PreviewStageCard extends StatelessWidget {
  const _PreviewStageCard({
    required this.stage,
    required this.scale,
  });

  final _PreviewStage stage;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 55 * scale,
        padding: EdgeInsets.fromLTRB(17 * scale, 9 * scale, 20 * scale, 9 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              offset: Offset(0, 2 * scale),
              blurRadius: 12 * scale,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4 * scale,
              height: 37 * scale,
              decoration: BoxDecoration(
                color: GoldenTicketPreviewScreen.themeGreen,
                borderRadius: BorderRadius.circular(16 * scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.stage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: GoldenTicketPreviewScreen.themeGreen,
                      height: 18 / 12,
                    ),
                  ),
                  Text(
                    stage.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: GoldenTicketPreviewScreen.iconGrey,
                      height: 14 / 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            Container(
              width: 42 * scale,
              height: 20 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(40 * scale),
              ),
              child: Text(
                '보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: GoldenTicketPreviewScreen.iconGrey,
                  height: 14 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.fontWeight,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48 * scale,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10 * scale),
            side: BorderSide(color: borderColor, width: 1 * scale),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: fontWeight,
            color: textColor,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}

class _PreviewStage {
  const _PreviewStage({
    required this.stage,
    required this.title,
  });

  final String stage;
  final String title;
}
