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
      const _BottomTabItem(tab: EconoBottomTab.battle, label: '소셜', iconWidth: 30),
      const _BottomTabItem(tab: EconoBottomTab.my, label: '마이', iconWidth: 27),
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
    final sx = size.width / 30;
    final sy = size.height / 30;
    double x(double value) => (value - 294.785) * sx;
    double y(double value) => (value - 14) * sy;

    final path = Path()
      ..moveTo(x(309.785), y(27.5714))
      ..cubicTo(x(312.265), y(27.5714), x(314.135), y(25.7286), x(314.135), y(23.2857))
      ..cubicTo(x(314.135), y(20.8429), x(312.265), y(19), x(309.785), y(19))
      ..cubicTo(x(307.306), y(19), x(305.435), y(20.8429), x(305.435), y(23.2857))
      ..cubicTo(x(305.435), y(25.7286), x(307.306), y(27.5714), x(309.785), y(27.5714))
      ..close()
      ..moveTo(x(309.785), y(21.8571))
      ..cubicTo(x(310.655), y(21.8571), x(311.235), y(22.4286), x(311.235), y(23.2857))
      ..cubicTo(x(311.235), y(24.1429), x(310.655), y(24.7143), x(309.785), y(24.7143))
      ..cubicTo(x(308.915), y(24.7143), x(308.335), y(24.1429), x(308.335), y(23.2857))
      ..cubicTo(x(308.335), y(22.4286), x(308.915), y(21.8571), x(309.785), y(21.8571))
      ..close()
      ..moveTo(x(311.235), y(29))
      ..lineTo(x(308.335), y(29))
      ..cubicTo(x(304.333), y(29), x(301.085), y(32.2), x(301.085), y(36.1429))
      ..lineTo(x(301.085), y(36.8571))
      ..cubicTo(x(301.085), y(38.0429), x(302.057), y(39), x(303.26), y(39))
      ..lineTo(x(316.31), y(39))
      ..cubicTo(x(317.514), y(39), x(318.485), y(38.0429), x(318.485), y(36.8571))
      ..lineTo(x(318.485), y(36.1429))
      ..cubicTo(x(318.485), y(32.2), x(315.237), y(29), x(311.235), y(29))
      ..close();

    path
      ..moveTo(x(303.985), y(36.1429))
      ..cubicTo(x(303.985), y(33.7857), x(305.943), y(31.8571), x(308.335), y(31.8571))
      ..lineTo(x(311.235), y(31.8571))
      ..cubicTo(x(313.628), y(31.8571), x(315.585), y(33.7857), x(315.585), y(36.1429))
      ..lineTo(x(303.985), y(36.1429))
      ..close();

    path
      ..moveTo(x(301.81), y(27.5714))
      ..cubicTo(x(302.492), y(27.5714), x(303.115), y(27.4), x(303.652), y(27.1))
      ..cubicTo(x(303.044), y(26.1461), x(302.672), y(25.0646), x(302.566), y(23.943))
      ..cubicTo(x(302.46), y(22.8213), x(302.623), y(21.6909), x(303.043), y(20.6429))
      ..cubicTo(x(302.666), y(20.5143), x(302.245), y(20.4286), x(301.81), y(20.4286))
      ..cubicTo(x(299.722), y(20.4286), x(298.185), y(21.9429), x(298.185), y(24))
      ..cubicTo(x(298.185), y(26.0571), x(299.722), y(27.5714), x(301.81), y(27.5714))
      ..close();

    path
      ..moveTo(x(301.245), y(29))
      ..lineTo(x(300.36), y(29))
      ..cubicTo(x(297.562), y(29), x(295.285), y(31.2429), x(295.285), y(34))
      ..lineTo(x(295.285), y(35.4286))
      ..cubicTo(x(295.285), y(35.8286), x(295.604), y(36.1429), x(296.01), y(36.1429))
      ..lineTo(x(298.185), y(36.1429))
      ..cubicTo(x(298.185), y(33.3429), x(299.36), y(30.8143), x(301.245), y(29))
      ..close();

    path
      ..moveTo(x(317.76), y(27.5714))
      ..cubicTo(x(319.848), y(27.5714), x(321.385), y(26.0571), x(321.385), y(24))
      ..cubicTo(x(321.385), y(21.9429), x(319.848), y(20.4286), x(317.76), y(20.4286))
      ..cubicTo(x(317.311), y(20.4286), x(316.905), y(20.5143), x(316.528), y(20.6429))
      ..cubicTo(x(316.947), y(21.6909), x(317.11), y(22.8213), x(317.005), y(23.943))
      ..cubicTo(x(316.899), y(25.0646), x(316.527), y(26.1461), x(315.919), y(27.1))
      ..cubicTo(x(316.455), y(27.4), x(317.064), y(27.5714), x(317.76), y(27.5714))
      ..close();

    path
      ..moveTo(x(319.21), y(29))
      ..lineTo(x(318.326), y(29))
      ..cubicTo(x(319.295), y(29.9285), x(320.064), y(31.0391), x(320.59), y(32.266))
      ..cubicTo(x(321.116), y(33.4929), x(321.386), y(34.8112), x(321.385), y(36.1429))
      ..lineTo(x(323.56), y(36.1429))
      ..cubicTo(x(323.966), y(36.1429), x(324.285), y(35.8286), x(324.285), y(35.4286))
      ..lineTo(x(324.285), y(34))
      ..cubicTo(x(324.285), y(31.2429), x(322.009), y(29), x(319.21), y(29))
      ..close();

    canvas.drawPath(path, paint);
  }

  void _paintMy(Canvas canvas, Size size, Paint paint) {
    final side = size.shortestSide;
    final dx = (size.width - side) / 2;
    final dy = (size.height - side) / 2;
    final scale = side / 27;
    double x(double value) => dx + (value - 378.5) * scale;
    double y(double value) => dy + (value - 15.5) * scale;

    final gear = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(x(383.075), y(27.825))
      ..cubicTo(x(383.025), y(28.2), x(383), y(28.5875), x(383), y(29))
      ..cubicTo(x(383), y(29.4), x(383.025), y(29.8), x(383.087), y(30.175))
      ..lineTo(x(380.55), y(32.15))
      ..cubicTo(x(380.325), y(32.325), x(380.262), y(32.6625), x(380.4), y(32.9125))
      ..lineTo(x(382.8), y(37.0625))
      ..cubicTo(x(382.95), y(37.3375), x(383.262), y(37.425), x(383.537), y(37.3375))
      ..lineTo(x(386.525), y(36.1375))
      ..cubicTo(x(387.15), y(36.6125), x(387.812), y(37.0125), x(388.55), y(37.3125))
      ..lineTo(x(389), y(40.4875))
      ..cubicTo(x(389.05), y(40.7875), x(389.3), y(41), x(389.6), y(41))
      ..lineTo(x(394.4), y(41))
      ..cubicTo(x(394.7), y(41), x(394.937), y(40.7875), x(394.987), y(40.4875))
      ..lineTo(x(395.437), y(37.3125))
      ..cubicTo(x(396.175), y(37.0125), x(396.85), y(36.6), x(397.462), y(36.1375))
      ..lineTo(x(400.45), y(37.3375))
      ..cubicTo(x(400.725), y(37.4375), x(401.037), y(37.3375), x(401.187), y(37.0625))
      ..lineTo(x(403.575), y(32.9125))
      ..cubicTo(x(403.725), y(32.65), x(403.675), y(32.325), x(403.425), y(32.15))
      ..lineTo(x(400.887), y(30.175))
      ..cubicTo(x(400.95), y(29.8), x(401), y(29.3875), x(401), y(29))
      ..cubicTo(x(401), y(28.6125), x(400.975), y(28.2), x(400.912), y(27.825))
      ..lineTo(x(403.45), y(25.85))
      ..cubicTo(x(403.675), y(25.675), x(403.737), y(25.3375), x(403.6), y(25.0875))
      ..lineTo(x(401.2), y(20.9375))
      ..cubicTo(x(401.05), y(20.6625), x(400.737), y(20.575), x(400.462), y(20.6625))
      ..lineTo(x(397.475), y(21.8625))
      ..cubicTo(x(396.85), y(21.3875), x(396.187), y(20.9875), x(395.45), y(20.6875))
      ..lineTo(x(395), y(17.5125))
      ..cubicTo(x(394.937), y(17.2125), x(394.7), y(17), x(394.4), y(17))
      ..lineTo(x(389.6), y(17))
      ..cubicTo(x(389.3), y(17), x(389.05), y(17.2125), x(389.012), y(17.5125))
      ..lineTo(x(388.562), y(20.6875))
      ..cubicTo(x(387.825), y(20.9875), x(387.15), y(21.3875), x(386.537), y(21.8625))
      ..lineTo(x(383.55), y(20.6625))
      ..cubicTo(x(383.275), y(20.5625), x(382.962), y(20.6625), x(382.812), y(20.9375))
      ..lineTo(x(380.412), y(25.0875))
      ..cubicTo(x(380.262), y(25.3625), x(380.325), y(25.675), x(380.562), y(25.85))
      ..lineTo(x(383.075), y(27.825))
      ..close()
      ..moveTo(x(392), y(24.5))
      ..cubicTo(x(394.475), y(24.5), x(396.5), y(26.525), x(396.5), y(29))
      ..cubicTo(x(396.5), y(31.475), x(394.475), y(33.5), x(392), y(33.5))
      ..cubicTo(x(389.525), y(33.5), x(387.5), y(31.475), x(387.5), y(29))
      ..cubicTo(x(387.5), y(26.525), x(389.525), y(24.5), x(392), y(24.5))
      ..close();
    canvas.drawPath(gear, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomTabIconPainter oldDelegate) {
    return oldDelegate.tab != tab || oldDelegate.color != color;
  }
}
