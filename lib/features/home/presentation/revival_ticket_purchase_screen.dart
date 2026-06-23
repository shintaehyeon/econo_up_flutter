// lib/features/home/presentation/revival_ticket_purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class RevivalTicketPurchaseScreen extends StatelessWidget {
  const RevivalTicketPurchaseScreen({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textButton = Color(0xFF4B505A);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color billGreen = Color(0xFFA1E669);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

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
                _buildHeader(scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 24 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBreakStatusCard(scale),
                        SizedBox(height: 24 * scale),
                        _buildInfoSection(scale),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 33 * scale),
                  child: _buildUseButton(scale),
                ),
                _buildBottomNavigationBar(context, scale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      height: 52 * scale,
      padding: EdgeInsets.fromLTRB(24 * scale, 0, 19 * scale, 0),
      child: Row(
        children: [
          Text(
            '연속 학습 부활권',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 22.5 / 16,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              onClose();
            },
            child: SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: Icon(
                Icons.close_rounded,
                color: textMuted,
                size: 30 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakStatusCard(double scale) {
    return SizedBox(
      height: 165 * scale,
      child: Column(
        children: [
          SizedBox(height: 36 * scale),
          _CryFaceIcon(size: 36 * scale),
          SizedBox(height: 12 * scale),
          Text(
            '연속 학습이 끊겼어요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0DE593),
              height: 28 / 18,
            ),
          ),
          Text(
            '어제 학습을 빠뜨렸습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTicketDescriptionCard(scale),
        SizedBox(height: 10 * scale),
        _buildOwnedTicketCard(scale),
      ],
    );
  }

  Widget _buildTicketDescriptionCard(double scale) {
    return Container(
      height: 113 * scale,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF6FEE8),
              shape: BoxShape.circle,
            ),
            child: _RevivalWingIcon(size: 20 * scale),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연속 학습 부활권',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 28 / 16,
                    letterSpacing: -0.439453 * scale,
                  ),
                ),
                SizedBox(
                  height: 20 * scale,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '부활권을 사용하면 어제 학습한 것으로 처리되어 스트릭이 유지됩니다.',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                        height: 20 / 12,
                        letterSpacing: -0.150391 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  '* 하루에 1개씩만 사용 가능합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w400,
                    color: textLight,
                    height: 14 / 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedTicketCard(double scale) {
    return Container(
      height: 80 * scale,
      padding: EdgeInsets.fromLTRB(23 * scale, 0, 13 * scale, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '보유 부활권',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: brandInk,
                    height: 28 / 16,
                    letterSpacing: -0.439453 * scale,
                  ),
                ),
                Text(
                  '0개',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                    height: 20 / 12,
                    letterSpacing: -0.150391 * scale,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 57 * scale,
            height: 34 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16777216),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BillIcon(width: 18 * scale, height: 12 * scale),
                SizedBox(width: 6 * scale),
                Text(
                  '2',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: textButton,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseButton(double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 48 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: themeGreen,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(
          '부활권 사용하기',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, double scale) {
    return EconoBottomNavigationBar(
      activeTab: EconoBottomTab.my,
      scale: scale,
      onTabSelected: (tab) {
        if (tab != EconoBottomTab.my) {
          Navigator.pop(context, _indexForBottomTab(tab));
        }
      },
    );
  }

  int _indexForBottomTab(EconoBottomTab tab) {
    switch (tab) {
      case EconoBottomTab.home:
        return 0;
      case EconoBottomTab.learning:
        return 1;
      case EconoBottomTab.connect:
        return 2;
      case EconoBottomTab.battle:
        return 3;
      case EconoBottomTab.my:
        return 4;
    }
  }
}

class _CryFaceIcon extends StatelessWidget {
  const _CryFaceIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _CryFaceIconPainter(),
    );
  }
}

class _CryFaceIconPainter extends CustomPainter {
  const _CryFaceIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RevivalTicketPurchaseScreen.themeGreen
      ..strokeWidth = size.width * 0.095
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.44, paint);

    final fillPaint = Paint()
      ..color = RevivalTicketPurchaseScreen.themeGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.36, size.height * 0.43), size.width * 0.045, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.64, size.height * 0.43), size.width * 0.045, fillPaint);

    final mouth = Path()
      ..moveTo(size.width * 0.36, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.50, size.height * 0.58, size.width * 0.64, size.height * 0.70);
    canvas.drawPath(mouth, paint);

    final tear = Path()
      ..moveTo(size.width * 0.31, size.height * 0.56)
      ..cubicTo(size.width * 0.21, size.height * 0.67, size.width * 0.21, size.height * 0.82, size.width * 0.33, size.height * 0.88)
      ..cubicTo(size.width * 0.45, size.height * 0.82, size.width * 0.44, size.height * 0.66, size.width * 0.31, size.height * 0.56)
      ..close();
    canvas.drawPath(tear, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RevivalWingIcon extends StatelessWidget {
  const _RevivalWingIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
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
      ..color = RevivalTicketPurchaseScreen.billGreen
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
      ..color = RevivalTicketPurchaseScreen.billGreen
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

class _BillIcon extends StatelessWidget {
  const _BillIcon({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(RevivalTicketPurchaseScreen.billGreen, BlendMode.srcIn),
        child: Image.asset(
          'assets/icons/bill_vector.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
