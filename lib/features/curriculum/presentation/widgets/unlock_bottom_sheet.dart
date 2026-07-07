import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import 'payment_complete_screen.dart';

enum UnlockOption { categoryPass, period30, lifetime }

class UnlockBottomSheet extends StatefulWidget {
  final String category;
  final String? categoryCode;
  final int? unitId;
  final String? unitTitle;

  const UnlockBottomSheet({
    Key? key,
    required this.category,
    this.categoryCode,
    this.unitId,
    this.unitTitle,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    required String category,
    String? categoryCode,
    int? unitId,
    String? unitTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnlockBottomSheet(
        category: category,
        categoryCode: categoryCode,
        unitId: unitId,
        unitTitle: unitTitle,
      ),
    );
  }

  @override
  State<UnlockBottomSheet> createState() => _UnlockBottomSheetState();
}

class _UnlockBottomSheetState extends State<UnlockBottomSheet> {
  UnlockOption _selectedOption = UnlockOption.categoryPass;
  late final ApiClient _client;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 14, left: 24, right: 24, bottom: 51),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 63,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 30),

          // Lock Icon
          SizedBox(
            width: 26,
            height: 26,
            child: CustomPaint(
              painter: _LockIconPainter(),
            ),
          ),
          const SizedBox(height: 17),

          // Title
          Text(
            '${widget.category} 카테고리',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2A3A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '잠금을 해제하면 바로 시작할 수 있어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 1.14,
            ),
          ),
          const SizedBox(height: 30),

          // Category Pass Section
          _buildSectionTitle('카테고리'),
          const SizedBox(height: 9),
          _buildOptionCard(
            option: UnlockOption.categoryPass,
            title: '카테고리 패스',
            subtitle: '${widget.category} 전체 스테이지 무제한',
            cost: 5,
          ),
          const SizedBox(height: 24),

          // Unit Section
          _buildSectionTitle('유닛'),
          const SizedBox(height: 9),
          _buildOptionCard(
            option: UnlockOption.period30,
            title: '기간 소장 (30일)',
            subtitle: '${widget.unitTitle ?? '선택한 유닛'} 30일간 이용',
            cost: 1,
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            option: UnlockOption.lifetime,
            title: '영구 소장',
            subtitle: '${widget.unitTitle ?? '선택한 유닛'} 평생 이용',
            cost: 2,
          ),
          const SizedBox(height: 30),

          // Purchase Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _purchaseUnlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00EE94),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '구매하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseUnlock() async {
    HapticFeedback.lightImpact();
    if (_isPurchasing) return;

    final purchase = _purchasePayload();
    if (purchase == null) {
      _showMessage('해금할 콘텐츠 정보를 찾지 못했어요.');
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      await _client.post<Map<String, dynamic>>(
        ApiEndpoints.purchaseContentUnlock,
        body: purchase,
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop(true);
      navigator.push(
        MaterialPageRoute(
          builder: (context) => PaymentCompleteScreen(
            category: widget.category,
          ),
        ),
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.code == 'ALREADY_UNLOCKED') {
        Navigator.of(context).pop(true);
        _showMessage('이미 해금된 콘텐츠예요.');
        return;
      }
      final message = error.code == 'BILL_NOT_ENOUGH'
          ? '보유 지폐가 부족해요.'
          : '구매 처리에 실패했어요.';
      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('구매 처리에 실패했어요.');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Map<String, Object?>? _purchasePayload() {
    final useCategoryPass =
        _selectedOption == UnlockOption.categoryPass || widget.unitId == null;
    final contentKey = useCategoryPass
        ? widget.categoryCode
        : widget.unitId?.toString();
    if (contentKey == null || contentKey.isEmpty) return null;

    return {
      'contentType': useCategoryPass ? 'CATEGORY' : 'UNIT',
      'contentKey': contentKey,
      'priceBills': _selectedOption == UnlockOption.categoryPass
          ? 5
          : _selectedOption == UnlockOption.period30
              ? 1
              : 2,
      if (_selectedOption == UnlockOption.period30) 'durationHours': 24 * 30,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required UnlockOption option,
    required String title,
    required String subtitle,
    required int cost,
  }) {
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.only(left: 20, right: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: const Size(18, 12),
                    painter: _CashIconPainter(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cost.toString(),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B505A),
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

class _CashIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 18.0;
    final sy = h / 12.0;

    final paint = Paint()
      ..color = const Color(0xFFA1E669)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Sub-path 1: Outer rectangle (M0 0H18V12H0V0Z)
    path.addRect(Rect.fromLTWH(0, 0, w, h));

    // Sub-path 2: Center circle at (9,6) radius 3
    path.addOval(Rect.fromCircle(
      center: Offset(9 * sx, 6 * sy),
      radius: 3 * sx,
    ));

    // Sub-path 3: Inner rounded rect with corner arcs
    // M4 2 → corners at (4,2), (14,2), (14,10), (4,10) with ~2 radius arcs
    // This creates the bill border pattern
    path.moveTo(4 * sx, 2 * sy);
    path.cubicTo(4 * sx, 2.53 * sy, 3.79 * sx, 3.04 * sy, 3.41 * sx, 3.41 * sy);
    path.cubicTo(3.04 * sx, 3.79 * sy, 2.53 * sx, 4 * sy, 2 * sx, 4 * sy);
    path.lineTo(2 * sx, 8 * sy);
    path.cubicTo(2.53 * sx, 8 * sy, 3.04 * sx, 8.21 * sy, 3.41 * sx, 8.59 * sy);
    path.cubicTo(3.79 * sx, 8.96 * sy, 4 * sx, 9.47 * sy, 4 * sx, 10 * sy);
    path.lineTo(14 * sx, 10 * sy);
    path.cubicTo(14 * sx, 9.47 * sy, 14.21 * sx, 8.96 * sy, 14.59 * sx, 8.59 * sy);
    path.cubicTo(14.96 * sx, 8.21 * sy, 15.47 * sx, 8 * sy, 16 * sx, 8 * sy);
    path.lineTo(16 * sx, 4 * sy);
    path.cubicTo(15.47 * sx, 4 * sy, 14.96 * sx, 3.79 * sy, 14.59 * sx, 3.41 * sy);
    path.cubicTo(14.21 * sx, 3.04 * sy, 14 * sx, 2.53 * sy, 14 * sx, 2 * sy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.16667
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path()
      ..moveTo(20.583, 12.917)
      ..lineTo(5.417, 12.917)
      ..cubicTo(4.220, 12.917, 3.250, 13.887, 3.250, 15.084)
      ..lineTo(3.250, 22.667)
      ..cubicTo(3.250, 23.864, 4.220, 24.834, 5.417, 24.834)
      ..lineTo(20.583, 24.834)
      ..cubicTo(21.780, 24.834, 22.750, 23.864, 22.750, 22.667)
      ..lineTo(22.750, 15.084)
      ..cubicTo(22.750, 13.887, 21.780, 12.917, 20.583, 12.917)
      ..close();
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(7.583, 12.917)
      ..lineTo(7.583, 8.584)
      ..cubicTo(7.583, 7.147, 8.154, 5.769, 9.170, 4.753)
      ..cubicTo(10.186, 3.738, 11.564, 3.167, 13.000, 3.167)
      ..cubicTo(14.437, 3.167, 15.815, 3.738, 16.830, 4.753)
      ..cubicTo(17.846, 5.769, 18.417, 7.147, 18.417, 8.584)
      ..lineTo(18.417, 12.917);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
