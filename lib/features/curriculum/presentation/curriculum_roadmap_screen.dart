import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/curriculum_api.dart';
import 'stage_map_screen.dart';
import 'widgets/unlock_bottom_sheet.dart';

class CurriculumRoadmapScreen extends StatefulWidget {
  final String title;
  final String? categoryCode;

  const CurriculumRoadmapScreen({
    super.key,
    required this.title,
    this.categoryCode,
  });

  @override
  State<CurriculumRoadmapScreen> createState() => _CurriculumRoadmapScreenState();
}

class _CurriculumRoadmapScreenState extends State<CurriculumRoadmapScreen> {
  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color bgGrey = Color(0xFFF7F7F7);

  late final ApiClient _client;
  late final CurriculumApi _api;

  RoadmapResult? _roadmap;
  bool _isLoading = true;
  String? _errorMessage;

  Color get themeColor {
    final code = _roadmap?.category.code ?? _inferCategoryCode(widget.title);
    if (code == 'SAVING') return const Color(0xFF00DAEE);
    if (code == 'STOCK') return const Color(0xFFFFA866);
    if (code == 'REAL_ESTATE') return const Color(0xFF7C3AED);
    if (code == 'TAX') return const Color(0xFFFF455D);
    return const Color(0xFF00EE94);
  }

  Color get badgeTextColor {
    final code = _roadmap?.category.code ?? _inferCategoryCode(widget.title);
    if (code == 'SAVING') return const Color(0xFF00BECF);
    if (code == 'STOCK') return const Color(0xFFFFA866);
    if (code == 'REAL_ESTATE') return const Color(0xFF7C3AED);
    if (code == 'TAX') return const Color(0xFFFF455D);
    return const Color(0xFF00C97D);
  }

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = CurriculumApi(_client);
    _loadRoadmap();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadRoadmap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!AuthSession.hasAccessToken) {
      setState(() {
        _isLoading = false;
        _errorMessage = '로그인이 필요합니다. 개발 테스트는 ECONOUP_ACCESS_TOKEN 값을 넣어 실행해주세요.';
      });
      return;
    }

    try {
      final categories = await _api.categories();
      final categoryCode = _resolveCategoryCode(categories.categories);
      final roadmap = await _api.roadmap(categoryCode);
      if (!mounted) return;
      setState(() {
        _roadmap = roadmap;
        _isLoading = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '로드맵을 불러오지 못했습니다.';
      });
    }
  }

  String _resolveCategoryCode(List<CurriculumCategory> categories) {
    if (widget.categoryCode != null && widget.categoryCode!.isNotEmpty) {
      return widget.categoryCode!;
    }
    final normalizedTitle = widget.title.replaceAll(' ', '');
    for (final category in categories) {
      if (category.name.replaceAll(' ', '') == normalizedTitle) return category.code;
    }
    return _inferCategoryCode(widget.title);
  }

  String _inferCategoryCode(String title) {
    if (title.contains('저축') || title.contains('축') || title.contains('異')) return 'SAVING';
    if (title.contains('주식') || title.contains('二')) return 'STOCK';
    if (title.contains('부동산') || title.contains('遺')) return 'REAL_ESTATE';
    if (title.contains('세금') || title.contains('멸')) return 'TAX';
    return 'ECONOMY';
  }

  void _goToLogin() {
    AuthSession.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);
    final cardWidth = (contentWidth - 32).clamp(0.0, 416.0);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent(contentWidth, cardWidth)),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double contentWidth, double cardWidth) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00EE94)));
    }
    if (_errorMessage != null) {
      return _buildError();
    }
    final roadmap = _roadmap;
    if (roadmap == null || roadmap.units.isEmpty) {
      return const Center(child: Text('로드맵 데이터가 없습니다.'));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Center(
            child: Container(
              width: contentWidth,
              color: bgGrey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTopQuoteCard(cardWidth, roadmap),
                  const SizedBox(height: 16),
                  SizedBox(width: 354, child: _buildRoadmapNodes(roadmap.units)),
                ],
              ),
            ),
          ),
        ),
        Positioned(bottom: 16, child: _buildBottomProgressCard(cardWidth, roadmap)),
      ],
    );
  }

  Widget _buildHeader() {
    final title = (_roadmap?.category.name ?? widget.title).replaceAll(' ', '');
    return Container(
      width: double.infinity,
      height: 41,
      color: bgGrey,
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6A7282), size: 20),
            ),
          ),
          Text(
            title,
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

  Widget _buildTopQuoteCard(double width, RoadmapResult roadmap) {
    final quote = roadmap.category.subtitle.isEmpty ? '${roadmap.category.name} 로드맵' : roadmap.category.subtitle;
    final totalStages = roadmap.units.fold<int>(0, (sum, unit) => sum + unit.stages.length);
    return Container(
      width: width,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, -1)),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quote,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.5),
          ),
          const SizedBox(height: 2),
          Text(
            '총 $totalStages개 스테이지',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: themeColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapNodes(List<CurriculumUnit> units) {
    final children = <Widget>[];
    for (int i = 0; i < units.length; i++) {
      final unit = units[i];
      final isLeftNode = i % 2 == 0;
      children.add(_buildUnitRow(unit, isLeftNode));
      if (i < units.length - 1) {
        final nextUnit = units[i + 1];
        final isCurveCompleted = _unitState(unit) == UnitState.completed && _unitState(nextUnit) != UnitState.locked;
        children.add(
          SizedBox(
            width: 354,
            height: 90,
            child: CustomPaint(
              painter: CurvePainter(isLeftToRight: isLeftNode, isCompleted: isCurveCompleted, curveColor: themeColor.withValues(alpha: 0.70)),
            ),
          ),
        );
      }
    }
    return Column(children: children);
  }

  Widget _buildUnitRow(CurriculumUnit unit, bool isLeftNode) {
    final circleButton = _buildCircleButton(unit);
    final infoCard = _buildInfoCard(unit);
    return Container(
      width: 354,
      constraints: const BoxConstraints(minHeight: 136),
      alignment: Alignment.center,
      child: SizedBox(
        width: isLeftNode ? 250 : 294,
        child: Padding(
          padding: EdgeInsets.only(left: isLeftNode ? 30 : 0, right: isLeftNode ? 0 : 72),
          child: Row(
            children: isLeftNode
                ? [circleButton, const SizedBox(width: 12), infoCard]
                : [infoCard, const SizedBox(width: 12), circleButton],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(CurriculumUnit unit) {
    final state = _unitState(unit);
    return GestureDetector(
      onTap: () => _handleUnitTap(unit),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state == UnitState.completed ? themeColor : state == UnitState.active ? Colors.white : const Color(0xFFE8E8E8),
              boxShadow: [
                if (state != UnitState.locked) BoxShadow(color: themeColor.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: state == UnitState.locked
                  ? const Icon(Icons.lock_rounded, color: Color(0xFFCACACA), size: 24)
                  : Icon(state == UnitState.completed ? Icons.star_rounded : Icons.play_arrow_rounded, color: state == UnitState.completed ? Colors.white : themeColor, size: 30),
            ),
          ),
          if (state != UnitState.locked)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: state == UnitState.active ? themeColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: state == UnitState.active ? Colors.white : themeColor, width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))],
                ),
                alignment: Alignment.center,
                child: Icon(state == UnitState.completed ? Icons.check_rounded : Icons.play_arrow_rounded, size: 14, color: state == UnitState.active ? Colors.white : themeColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(CurriculumUnit unit) {
    final state = _unitState(unit);
    final isActive = state == UnitState.active;
    final isCompleted = state == UnitState.completed;
    return GestureDetector(
      onTap: () => _handleUnitTap(unit),
      child: Container(
        width: 140,
        constraints: const BoxConstraints(minHeight: 136),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive || isCompleted ? Colors.white : const Color(0xFFF3F3F3),
          border: Border.all(color: isActive ? themeColor : isCompleted ? themeColor.withValues(alpha: 0.30) : const Color(0xFFE8E8E8), width: isActive ? 2 : 1),
          boxShadow: [if (isActive || isCompleted) BoxShadow(color: themeColor.withValues(alpha: isActive ? 0.18 : 0.12), blurRadius: 10, offset: const Offset(0, 2))],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(color: isActive || isCompleted ? themeColor.withValues(alpha: 0.18) : const Color(0xFFE5E5E5), borderRadius: BorderRadius.circular(100)),
              child: Text(
                'Unit ${unit.id}',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: isActive || isCompleted ? badgeTextColor : const Color(0xFFAAAAAA), height: 1.0),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: isActive || isCompleted ? brandInk : const Color(0xFFC0C0C0), height: 1.25),
            ),
            const SizedBox(height: 1),
            Text(
              unit.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w400, color: isActive || isCompleted ? textMuted : const Color(0xFFD0D0D0), height: 1.5),
            ),
            const SizedBox(height: 2),
            ...unit.stages.take(3).map((stage) => _buildStageItem(stage, unit)),
          ],
        ),
      ),
    );
  }

  Widget _buildStageItem(CurriculumStage stage, CurriculumUnit unit) {
    final locked = _unitState(unit) == UnitState.locked || stage.isLocked;
    final finished = stage.isCompleted && !locked;
    final textColor = finished ? themeColor : locked ? const Color(0xFFD0D0D0) : const Color(0xFFC0C0C0);
    return GestureDetector(
      onTap: () => _handleStageTap(stage, unit),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Icon(finished ? Icons.check_rounded : locked ? Icons.lock_rounded : Icons.circle_outlined, size: 10, color: textColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                stage.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w400, color: textColor, letterSpacing: 0.11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStageTap(CurriculumStage stage, CurriculumUnit unit) {
    if (_unitState(unit) == UnitState.locked || stage.isLocked) {
      HapticFeedback.lightImpact();
      UnlockBottomSheet.show(context, category: _roadmap?.category.name ?? widget.title);
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StageMapScreen(
          unitId: unit.id,
          stageId: stage.id,
          stageName: stage.title,
          unitName: 'Unit ${unit.id}. ${unit.title}',
          category: _roadmap?.category.name ?? widget.title,
          categoryCode: _roadmap?.category.code,
        ),
      ),
    ).then((val) {
      if (!mounted) return;
      if (val is int && val != 1) {
        Navigator.pop(context, val);
        return;
      }
      _loadRoadmap();
    });
  }

  void _handleUnitTap(CurriculumUnit unit) {
    if (_unitState(unit) == UnitState.locked) {
      HapticFeedback.lightImpact();
      UnlockBottomSheet.show(context, category: _roadmap?.category.name ?? widget.title);
      return;
    }
    final targetStage = unit.stages.firstWhere(
      (stage) => !stage.isCompleted && !stage.isLocked,
      orElse: () => unit.stages.isNotEmpty ? unit.stages.first : const CurriculumStage(id: 0, title: '', status: 'LOCKED', progressPercent: 0),
    );
    if (targetStage.id == 0) return;
    _handleStageTap(targetStage, unit);
  }

  Widget _buildBottomProgressCard(double width, RoadmapResult roadmap) {
    final completed = roadmap.summary.completedUnitCount;
    final total = roadmap.summary.totalUnitCount;
    final progress = (roadmap.summary.progressPercent / 100).clamp(0.0, 1.0);
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 56.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, -1)),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completed/$total 유닛 완료', style: TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w700, color: themeColor, height: 1.5)),
              Text('${roadmap.summary.progressPercent}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF), height: 1.5)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(100)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(100), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  UnitState _unitState(CurriculumUnit unit) {
    if (unit.status == 'COMPLETED') return UnitState.completed;
    if (unit.status == 'LOCKED') return UnitState.locked;
    return UnitState.active;
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_errorMessage ?? '오류가 발생했습니다.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: brandInk, height: 1.45)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: AuthSession.hasAccessToken ? _loadRoadmap : _goToLogin,
            style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white),
            child: Text(AuthSession.hasAccessToken ? '다시 시도' : '로그인하러 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return EconoBottomNavigationBar(
      activeTab: EconoBottomTab.learning,
      onTabSelected: (tab) {
        if (tab != EconoBottomTab.learning) Navigator.pop(context, _indexForBottomTab(tab));
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

class CurvePainter extends CustomPainter {
  final bool isLeftToRight;
  final bool isCompleted;
  final Color curveColor;

  CurvePainter({required this.isLeftToRight, required this.isCompleted, required this.curveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..color = isCompleted ? curveColor : const Color(0xFFE0E0E0);
    final path = Path();
    const startXLeft = 116.0;
    const startXRight = 216.0;
    if (isLeftToRight) {
      path.moveTo(startXLeft, 0);
      path.cubicTo(startXLeft, size.height * 0.5, startXRight, size.height * 0.5, startXRight, size.height);
    } else {
      path.moveTo(startXRight, 0);
      path.cubicTo(startXRight, size.height * 0.5, startXLeft, size.height * 0.5, startXLeft, size.height);
    }
    isCompleted ? canvas.drawPath(path, paint) : _drawDashedPath(canvas, path, paint, 6, 6);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) => oldDelegate.isLeftToRight != isLeftToRight || oldDelegate.isCompleted != isCompleted || oldDelegate.curveColor != curveColor;
}

enum UnitState { completed, active, locked }