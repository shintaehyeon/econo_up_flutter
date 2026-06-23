import 'package:flutter/material.dart';

class PokeDialog extends StatelessWidget {
  final String targetName;
  const PokeDialog({super.key, required this.targetName});

  static Future<void> show(BuildContext context, String targetName) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => PokeDialog(targetName: targetName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 335,
          padding: const EdgeInsets.fromLTRB(34, 22, 34, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD0D5E0)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Finger snapping icon
              SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(
                  painter: _FingerSnapPainter(),
                ),
              ),
              const SizedBox(height: 10),

              // "박태현님을"
              Text(
                '$targetName님을',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  height: 21 / 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // "찔렀습니다!"
              const Text(
                '찔렀습니다!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00EE94),
                  height: 21 / 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                '지폐 1개 지급!\n$targetName님도 접속하시면 지폐 1개를 받아요!',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                  height: 16 / 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // 닫기
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F7),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 소식 공유하기
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00EE94),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '소식 공유하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4B5563),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FingerSnapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    // The original SVG was 30x30
    canvas.scale(w / 30.0, h / 30.0);

    // === Snap dots (#0BC44F) ===
    final dotPaint = Paint()
      ..color = const Color(0xFF0BC44F)
      ..style = PaintingStyle.fill;

    final dotPath = Path();
    dotPath.moveTo(9.42851, 4.82115);
    dotPath.cubicTo(9.07508, 4.8527, 8.72357, 4.74269, 8.45117, 4.51529);
    dotPath.cubicTo(8.17877, 4.28789, 8.00775, 3.96168, 7.97565, 3.6083);
    dotPath.lineTo(7.83851, 2.09115);
    dotPath.cubicTo(7.80669, 1.73738, 7.9167, 1.38544, 8.14436, 1.11278);
    dotPath.cubicTo(8.37201, 0.840113, 8.69866, 0.669052, 9.05244, 0.637226);
    dotPath.cubicTo(9.40622, 0.6054, 9.75815, 0.715416, 10.0308, 0.943072);
    dotPath.cubicTo(10.3035, 1.17073, 10.4745, 1.49738, 10.5064, 1.85115);
    dotPath.lineTo(10.6435, 3.3683);
    dotPath.cubicTo(10.675, 3.72207, 10.5647, 4.07388, 10.3369, 4.34634);
    dotPath.cubicTo(10.109, 4.6188, 9.78229, 4.7896, 9.42851, 4.82115);
    dotPath.close();
    dotPath.moveTo(15.7285, 3.28258);
    dotPath.cubicTo(16.2857, 3.76901, 16.3435, 4.61544, 15.8571, 5.17258);
    dotPath.lineTo(14.8542, 6.31901);
    dotPath.cubicTo(14.7404, 6.45771, 14.5998, 6.57211, 14.4408, 6.65541);
    dotPath.cubicTo(14.2819, 6.73872, 14.1078, 6.78923, 13.929, 6.80395);
    dotPath.cubicTo(13.7501, 6.81867, 13.5701, 6.7973, 13.3997, 6.7411);
    dotPath.cubicTo(13.2293, 6.68491, 13.0719, 6.59504, 12.9369, 6.47683);
    dotPath.cubicTo(12.8019, 6.35862, 12.692, 6.21448, 12.6138, 6.05297);
    dotPath.cubicTo(12.5355, 5.89147, 12.4906, 5.71589, 12.4815, 5.53666);
    dotPath.cubicTo(12.4725, 5.35744, 12.4996, 5.17822, 12.5611, 5.00967);
    dotPath.cubicTo(12.6227, 4.84111, 12.7175, 4.68664, 12.8399, 4.55544);
    dotPath.lineTo(13.8407, 3.40901);
    dotPath.cubicTo(13.9564, 3.2766, 14.0972, 3.16829, 14.2548, 3.09027);
    dotPath.cubicTo(14.4125, 3.01225, 14.584, 2.96605, 14.7595, 2.95431);
    dotPath.cubicTo(14.935, 2.94257, 15.1111, 2.96552, 15.2777, 3.02184);
    dotPath.cubicTo(15.4444, 3.07817, 15.5961, 3.16677, 15.7285, 3.28258);
    dotPath.close();
    dotPath.moveTo(3.52066, 6.74973);
    dotPath.cubicTo(3.20808, 6.58008, 2.9757, 6.29322, 2.87463, 5.95223);
    dotPath.cubicTo(2.77356, 5.61125, 2.81208, 5.24409, 2.98173, 4.93151);
    dotPath.cubicTo(3.15137, 4.61894, 3.43824, 4.38655, 3.77922, 4.28548);
    dotPath.cubicTo(4.1202, 4.18441, 4.48736, 4.22294, 4.79994, 4.39258);
    dotPath.lineTo(6.13708, 5.12115);
    dotPath.cubicTo(6.44909, 5.29137, 6.68071, 5.57855, 6.78097, 5.91953);
    dotPath.cubicTo(6.88124, 6.26051, 6.84194, 6.62736, 6.67173, 6.93937);
    dotPath.cubicTo(6.50151, 7.25138, 6.21433, 7.48299, 5.87335, 7.58325);
    dotPath.cubicTo(5.53237, 7.68352, 5.16552, 7.64422, 4.85351, 7.47401);
    dotPath.lineTo(3.52066, 6.74973);
    dotPath.close();
    canvas.drawPath(dotPath, dotPaint);

    // === Hand body (#00EE94) ===
    final handPaint = Paint()
      ..color = const Color(0xFF00EE94)
      ..style = PaintingStyle.fill;

    final handPath = Path();
    handPath.moveTo(11.8498, 17.2279);
    handPath.lineTo(5.63984, 15.565);
    handPath.cubicTo(4.95359, 15.3812, 4.36849, 14.9322, 4.01324, 14.317);
    handPath.cubicTo(3.65799, 13.7017, 3.5617, 12.9706, 3.74555, 12.2843);
    handPath.cubicTo(3.92941, 11.5981, 4.37834, 11.013, 4.99359, 10.6577);
    handPath.cubicTo(5.60884, 10.3025, 6.34002, 10.2062, 7.02627, 10.39);
    handPath.lineTo(19.4441, 13.7179);
    handPath.lineTo(19.337, 11.8279);
    handPath.cubicTo(19.2975, 11.1216, 19.5139, 10.4247, 19.9464, 9.86491);
    handPath.cubicTo(20.379, 9.30514, 20.9987, 8.91994, 21.6921, 8.77991);
    handPath.cubicTo(22.3855, 8.63987, 23.1062, 8.75436, 23.7221, 9.10241);
    handPath.cubicTo(24.338, 9.45046, 24.8078, 10.0088, 25.0456, 10.675);
    handPath.lineTo(26.9313, 15.9615);
    handPath.cubicTo(27.2237, 16.7813, 27.2596, 17.6707, 27.0341, 18.5115);
    handPath.lineTo(24.8184, 26.7807);
    handPath.cubicTo(24.5098, 27.9336, 23.732, 28.9365, 22.5598, 29.1572);
    handPath.cubicTo(20.747, 29.4957, 18.4948, 29.4036, 17.1491, 29.0415);
    handPath.cubicTo(13.5277, 28.0729, 10.0134, 25.0686, 11.8477, 17.2279);
    handPath.close();

    canvas.drawPath(handPath, handPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

