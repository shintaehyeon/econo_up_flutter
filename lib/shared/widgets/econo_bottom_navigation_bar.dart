import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EconoBottomTab {
  home,
  learning,
  connect,
  battle,
  my,
}

class EconoBottomNavigationBar extends StatelessWidget {
  const EconoBottomNavigationBar({
    super.key,
    required this.activeTab,
    this.onTabSelected,
    this.scale = 1,
  });

  final EconoBottomTab activeTab;
  final ValueChanged<EconoBottomTab>? onTabSelected;
  final double scale;

  static const Color activeColor = Color(0xFF626262);
  static const Color inactiveColor = Color(0xFFBCBCBC);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final items = [
      const _BottomTabItem(tab: EconoBottomTab.home, label: '홈'),
      const _BottomTabItem(tab: EconoBottomTab.learning, label: '학습'),
      const _BottomTabItem(tab: EconoBottomTab.connect, label: '커넥트', width: 63.14, iconWidth: 30),
      const _BottomTabItem(tab: EconoBottomTab.battle, label: '배틀', iconWidth: 30),
      const _BottomTabItem(tab: EconoBottomTab.my, label: '마이', iconWidth: 30),
    ];

    return Container(
      width: double.infinity,
      height: 77 * scale,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(8 * scale, 9 * scale, 8 * scale, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          final isActive = item.tab == activeTab;
          return item.copyWith(
            color: isActive ? activeColor : inactiveColor,
            scale: scale,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabSelected?.call(item.tab);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.tab,
    required this.label,
    this.color = EconoBottomNavigationBar.inactiveColor,
    this.scale = 1,
    this.width = 56,
    this.iconWidth = 29,
    this.onTap,
  });

  final EconoBottomTab tab;
  final String label;
  final Color color;
  final double scale;
  final double width;
  final double iconWidth;
  final VoidCallback? onTap;

  _BottomTabItem copyWith({
    required Color color,
    required double scale,
    required VoidCallback onTap,
  }) {
    return _BottomTabItem(
      tab: tab,
      label: label,
      color: color,
      scale: scale,
      width: width,
      iconWidth: iconWidth,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width * scale,
        height: 60 * scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BottomTabIcon(
              tab: tab,
              width: iconWidth * scale,
              height: 30 * scale,
              color: color,
            ),
            SizedBox(height: 4 * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: color,
                height: 16 / 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomTabIcon extends StatelessWidget {
  const _BottomTabIcon({
    required this.tab,
    required this.width,
    required this.height,
    required this.color,
  });

  final EconoBottomTab tab;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BottomTabIconPainter(tab: tab, color: color),
    );
  }
}

class _BottomTabIconPainter extends CustomPainter {
  const _BottomTabIconPainter({
    required this.tab,
    required this.color,
  });

  final EconoBottomTab tab;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (tab) {
      case EconoBottomTab.home:
        _paintHome(canvas, size, paint);
        break;
      case EconoBottomTab.learning:
        _paintLearning(canvas, size, paint);
        break;
      case EconoBottomTab.connect:
        _paintConnect(canvas, size, paint);
        break;
      case EconoBottomTab.battle:
        _paintBattle(canvas, size, paint);
        break;
      case EconoBottomTab.my:
        _paintMy(canvas, size, paint);
        break;
    }
  }

  void _paintHome(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.083)
      ..lineTo(w * 0.938, h * 0.425)
      ..lineTo(w * 0.816, h * 0.545)
      ..lineTo(w * 0.816, h * 0.875)
      ..quadraticBezierTo(w * 0.816, h * 0.925, w * 0.766, h * 0.925)
      ..lineTo(w * 0.598, h * 0.925)
      ..lineTo(w * 0.598, h * 0.650)
      ..lineTo(w * 0.402, h * 0.650)
      ..lineTo(w * 0.402, h * 0.925)
      ..lineTo(w * 0.234, h * 0.925)
      ..quadraticBezierTo(w * 0.184, h * 0.925, w * 0.184, h * 0.875)
      ..lineTo(w * 0.184, h * 0.545)
      ..lineTo(w * 0.062, h * 0.545)
      ..lineTo(w * 0.062, h * 0.425)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintLearning(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.167, h * 0.125, w * 0.666, h * 0.750),
        Radius.circular(w * 0.10),
      ),
      paint,
    );

    final cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bookmark = Path()
      ..moveTo(w * 0.325, h * 0.190)
      ..lineTo(w * 0.505, h * 0.190)
      ..lineTo(w * 0.505, h * 0.535)
      ..lineTo(w * 0.415, h * 0.450)
      ..lineTo(w * 0.325, h * 0.535)
      ..close();
    canvas.drawPath(bookmark, cutoutPaint);
  }

  void _paintConnect(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.125, h * 0.125, w * 0.750, h * 0.750),
        Radius.circular(w * 0.08),
      ),
      paint,
    );

    final cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (final top in <double>[0.300, 0.450, 0.600]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.315, h * top, w * 0.370, h * 0.070),
          Radius.circular(h * 0.012),
        ),
        cutoutPaint,
      );
    }
  }

  void _paintBattle(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    final left = Path()
      ..moveTo(w * 0.083, h * 0.146)
      ..lineTo(w * 0.270, h * 0.146)
      ..lineTo(w * 0.682, h * 0.610)
      ..lineTo(w * 0.545, h * 0.854)
      ..close();
    canvas.drawPath(left, paint);

    final right = Path()
      ..moveTo(w * 0.583, h * 0.146)
      ..lineTo(w * 0.917, h * 0.146)
      ..lineTo(w * 0.917, h * 0.300)
      ..lineTo(w * 0.668, h * 0.479)
      ..lineTo(w * 0.583, h * 0.396)
      ..close();
    canvas.drawPath(right, paint);
  }

  void _paintMy(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w * 0.500, h * 0.285), w * 0.185, paint);

    final body = Path()
      ..moveTo(w * 0.145, h * 0.875)
      ..quadraticBezierTo(w * 0.170, h * 0.560, w * 0.500, h * 0.560)
      ..quadraticBezierTo(w * 0.830, h * 0.560, w * 0.855, h * 0.875)
      ..close();
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomTabIconPainter oldDelegate) {
    return oldDelegate.tab != tab || oldDelegate.color != color;
  }
}
