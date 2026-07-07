// lib/features/home/presentation/golden_ticket_preview_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class GoldenTicketPreviewScreen extends StatefulWidget {
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

  @override
  State<GoldenTicketPreviewScreen> createState() => _GoldenTicketPreviewScreenState();
}

class _GoldenTicketPreviewScreenState extends State<GoldenTicketPreviewScreen> {
  late final ApiClient _client;
  Timer? _ticker;

  bool _isLoading = true;
  bool _isActivating = false;
  bool _available = false;
  bool _eligible = false;
  int _requiredStreakDays = 7;
  int _currentStreakDays = 0;
  String? _errorMessage;
  _GoldenTicket? _ticket;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _loadTicket();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _client.close();
    super.dispose();
  }

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
                    child: _buildBody(scale),
                  ),
                ),
                _buildActions(context, scale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_isLoading) {
      return SizedBox(
        height: 420 * scale,
        child: Center(
          child: SizedBox(
            width: 28 * scale,
            height: 28 * scale,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: GoldenTicketPreviewScreen.themeGreen,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _MessagePanel(
        title: '골든 티켓을 불러오지 못했어요',
        description: _errorMessage!,
        scale: scale,
        onRetry: _loadTicket,
      );
    }

    if (!_available || _ticket == null) {
      final description = _eligible
          ? '현재 사용할 수 있는 골든 티켓이 없습니다.'
          : '연속 학습 $_requiredStreakDays일 달성 시 골든 티켓을 받을 수 있어요. 현재 $_currentStreakDays일 연속 학습 중입니다.';
      return _MessagePanel(
        title: '사용 가능한 골든 티켓이 없어요',
        description: description,
        scale: scale,
        onRetry: _loadTicket,
      );
    }

    final ticket = _ticket!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TicketCard(
          title: _ticketTitle(ticket),
          remainingTime: _remainingTime(ticket),
          scale: scale,
        ),
        SizedBox(height: 14 * scale),
        _buildPreviewSection(ticket.stages, scale),
      ],
    );
  }

  Widget _buildActions(BuildContext context, double scale) {
    final canActivate = !_isLoading && _available && _ticket != null && !_isActivating;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        0,
        24 * scale,
        22 * scale,
      ),
      child: Column(
        children: [
          _BottomActionButton(
            label: _isActivating
                ? '활성화 중'
                : canActivate
                    ? '지금 바로 수강하기'
                    : '사용 가능한 티켓 없음',
            backgroundColor: canActivate ? GoldenTicketPreviewScreen.themeGreen : const Color(0xFFE5E7EB),
            borderColor: canActivate ? GoldenTicketPreviewScreen.themeGreen : const Color(0xFFE5E7EB),
            textColor: canActivate ? Colors.white : GoldenTicketPreviewScreen.textMuted,
            fontWeight: FontWeight.w700,
            scale: scale,
            onTap: canActivate ? _activateTicket : null,
          ),
          SizedBox(height: 12 * scale),
          _BottomActionButton(
            label: '나중에 구매하기',
            backgroundColor: Colors.white,
            borderColor: GoldenTicketPreviewScreen.borderGrey,
            textColor: GoldenTicketPreviewScreen.textButton,
            fontWeight: FontWeight.w500,
            scale: scale,
            onTap: () => _close(context),
          ),
        ],
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
                  color: GoldenTicketPreviewScreen.brandInk,
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
                  color: GoldenTicketPreviewScreen.iconGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(List<_PreviewStage> stages, double scale) {
    final items = stages.isEmpty
        ? const [
            _PreviewStage(stage: '스테이지 1', title: '미리보기 정보가 없습니다'),
          ]
        : stages;

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
                  color: GoldenTicketPreviewScreen.brandInk,
                  height: 17 / 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 14 * scale),
          for (var i = 0; i < items.length; i++) ...[
            _PreviewStageCard(
              stage: items[i],
              scale: scale,
              onTap: () => _showStagePreview(items[i]),
            ),
            if (i != items.length - 1) SizedBox(height: 8 * scale),
          ],
        ],
      ),
    );
  }

  Future<void> _loadTicket() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.currentGoldenTicket);
      final ticketJson = _asMap(data['ticket']);
      final ticket = ticketJson.isEmpty ? null : _GoldenTicket.fromJson(ticketJson);

      if (!mounted) return;
      setState(() {
        _available = data['available'] == true;
        _eligible = data['eligible'] == true;
        _requiredStreakDays = _asInt(data['requiredStreakDays'], fallback: 7);
        _currentStreakDays = _asInt(data['currentStreakDays']);
        _ticket = ticket;
        _isLoading = false;
      });
      _startTicker();
    } on ApiClientException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '잠시 후 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  Future<void> _activateTicket() async {
    final ticket = _ticket;
    if (ticket == null || _isActivating) return;

    HapticFeedback.lightImpact();
    setState(() => _isActivating = true);

    try {
      await _client.post<Map<String, dynamic>>(ApiEndpoints.activateGoldenTicket(ticket.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('골든 티켓이 활성화되었습니다.')),
      );
      _close(context);
    } on ApiClientException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('골든 티켓 활성화에 실패했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_ticket?.expiresAt == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _showStagePreview(_PreviewStage stage) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  stage.stage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GoldenTicketPreviewScreen.themeGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stage.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: GoldenTicketPreviewScreen.textDark,
                  ),
                ),
                if (stage.stageTitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    stage.stageTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GoldenTicketPreviewScreen.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _BottomActionButton(
                  label: '확인',
                  backgroundColor: GoldenTicketPreviewScreen.themeGreen,
                  borderColor: GoldenTicketPreviewScreen.themeGreen,
                  textColor: Colors.white,
                  fontWeight: FontWeight.w700,
                  scale: 1,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _ticketTitle(_GoldenTicket ticket) {
    if (ticket.stages.isEmpty) return ticket.title;
    final first = ticket.stages.first;
    if (first.stageTitle.isEmpty) return ticket.title;
    return '${_categoryLabel(first.categoryCode)} 유닛: ${first.stageTitle}';
  }

  String _remainingTime(_GoldenTicket ticket) {
    final expiresAt = ticket.expiresAt;
    if (expiresAt == null) return '-- : -- : --';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '00 : 00 : 00';
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours : $minutes : $seconds';
  }

  String _categoryLabel(String code) {
    return switch (code) {
      'SAVING' || 'SAVINGS' => '저축',
      'STOCK' || 'STOCKS' => '주식',
      'REAL_ESTATE' || 'REALTY' => '부동산',
      'TAX' => '세금',
      _ => '경제',
    };
  }

  void _close(BuildContext context) {
    HapticFeedback.lightImpact();
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.title,
    required this.remainingTime,
    required this.scale,
  });

  final String title;
  final String remainingTime;
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
              left: 24 * scale,
              right: 24 * scale,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                remainingTime,
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
    required this.onTap,
  });

  final _PreviewStage stage;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
  final VoidCallback? onTap;

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
          disabledBackgroundColor: backgroundColor,
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

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.title,
    required this.description,
    required this.scale,
    required this.onRetry,
  });

  final String title;
  final String description;
  final double scale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420 * scale,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: GoldenTicketPreviewScreen.borderGrey),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: GoldenTicketPreviewScreen.textDark,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: GoldenTicketPreviewScreen.textMuted,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 18 * scale),
              _BottomActionButton(
                label: '다시 불러오기',
                backgroundColor: GoldenTicketPreviewScreen.themeGreen,
                borderColor: GoldenTicketPreviewScreen.themeGreen,
                textColor: Colors.white,
                fontWeight: FontWeight.w700,
                scale: scale,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldenTicket {
  const _GoldenTicket({
    required this.id,
    required this.title,
    required this.status,
    required this.stages,
    required this.expiresAt,
  });

  factory _GoldenTicket.fromJson(Map<String, dynamic> json) {
    final stages = _asList(json['previewStages'])
        .asMap()
        .entries
        .map((entry) => _PreviewStage.fromJson(_asMap(entry.value), entry.key))
        .toList();
    return _GoldenTicket(
      id: _asInt(json['id']),
      title: _asString(json['title'], fallback: '골든 티켓'),
      status: _asString(json['status']),
      stages: stages,
      expiresAt: DateTime.tryParse(_asString(json['expiresAt']))?.toLocal(),
    );
  }

  final int id;
  final String title;
  final String status;
  final List<_PreviewStage> stages;
  final DateTime? expiresAt;
}

class _PreviewStage {
  const _PreviewStage({
    required this.stage,
    required this.title,
    this.stageTitle = '',
    this.categoryCode = '',
    this.sessionId = 0,
    this.stageId = 0,
  });

  factory _PreviewStage.fromJson(Map<String, dynamic> json, int index) {
    return _PreviewStage(
      stage: '스테이지 ${index + 1}',
      title: _asString(json['title'], fallback: _asString(json['stageTitle'], fallback: '미리보기')),
      stageTitle: _asString(json['stageTitle']),
      categoryCode: _asString(json['categoryCode']),
      sessionId: _asInt(json['sessionId']),
      stageId: _asInt(json['stageId']),
    );
  }

  final String stage;
  final String title;
  final String stageTitle;
  final String categoryCode;
  final int sessionId;
  final int stageId;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

List<dynamic> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}
