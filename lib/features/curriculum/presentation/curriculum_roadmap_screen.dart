import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../data/curriculum_api.dart';
import 'stage_map_screen.dart';
import 'widgets/unlock_bottom_sheet.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class CurriculumRoadmapScreen extends StatefulWidget {
  final String title; // '경제 상식' 또는 '저축'
  final String? categoryCode;

  const CurriculumRoadmapScreen({
    super.key,
    required this.title,
    this.categoryCode,
  });

  @override
  State<CurriculumRoadmapScreen> createState() =>
      _CurriculumRoadmapScreenState();
}

class _CurriculumRoadmapScreenState extends State<CurriculumRoadmapScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ApiClient _client;
  late final CurriculumApi _api;

  // 테마 색상 정의
  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF6A7282);

  Color get themeColor {
    if (widget.title == '저축') return const Color(0xFF00DAEE);
    if (widget.title == '주식') return const Color(0xFFFFA866);
    if (widget.title == '부동산') return const Color(0xFF7C3AED);
    if (widget.title == '세금') return const Color(0xFFFF455D);
    return const Color(0xFF00EE94);
  }

  Color get completedNodeShadowColor {
    if (widget.title == '저축') return const Color(0x6600DAEE);
    if (widget.title == '주식') return const Color(0x66FFA866);
    if (widget.title == '부동산') return const Color(0x667C3AED);
    if (widget.title == '세금') return const Color(0x66FF455D);
    return const Color(0x6600EE94);
  }

  Color get activeNodeShadowColor {
    if (widget.title == '저축') return const Color(0x4000DAEE);
    if (widget.title == '주식') return const Color(0x40FFA866);
    if (widget.title == '부동산') return const Color(0x407C3AED);
    if (widget.title == '세금') return const Color(0x40FF455D);
    return const Color(0x4000EE94);
  }

  Color get activeCardShadowColor {
    if (widget.title == '저축') return const Color(0x2E00DAEE);
    if (widget.title == '주식') return const Color(0x2EFFA866);
    if (widget.title == '부동산') return const Color(0x2E7C3AED);
    if (widget.title == '세금') return const Color(0x2EFF455D);
    return const Color(0x2E00EE94);
  }

  Color get completedCardShadowColor {
    if (widget.title == '저축') return const Color(0x1F00DAEE);
    if (widget.title == '주식') return const Color(0x1FFFA866);
    if (widget.title == '부동산') return const Color(0x1F7C3AED);
    if (widget.title == '세금') return const Color(0x1FFF455D);
    return const Color(0x1F00EE94);
  }

  Color get completedCardBorderColor {
    if (widget.title == '저축') return const Color(0x4D00DAEE);
    if (widget.title == '주식') return const Color(0x4DFFA866);
    if (widget.title == '부동산') return const Color(0x4D7C3AED);
    if (widget.title == '세금') return const Color(0x4DFF455D);
    return const Color(0x4D01EE94);
  }

  Color get badgeBgColor {
    if (widget.title == '저축') return const Color(0x3300DAEE);
    if (widget.title == '주식') return const Color(0x33FFA866);
    if (widget.title == '부동산') return const Color(0x337C3AED);
    if (widget.title == '세금') return const Color(0x33FF455D);
    return const Color(0x3301EE94);
  }

  Color get badgeTextColor {
    if (widget.title == '저축') return const Color(0xFF00BECF);
    if (widget.title == '주식') return const Color(0xFFFFA866);
    if (widget.title == '부동산') return const Color(0xFF7C3AED);
    if (widget.title == '세금') return const Color(0xFFFF455D);
    return const Color(0xFF00C97D);
  }

  Color get curveColor {
    if (widget.title == '저축') return const Color(0xB202B7C8);
    if (widget.title == '주식') return const Color(0xB2FFA866);
    if (widget.title == '부동산') return const Color(0xB27C3AED);
    if (widget.title == '세금') return const Color(0xB2FF455D);
    return const Color(0xB200EE94);
  }

  List<UnitData> _units = [];
  RoadmapSummary? _summary;
  String? _categorySubtitle;
  bool _isLoading = true;
  String? _errorMessage;

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
    _scrollController.dispose();
    _client.close();
    super.dispose();
  }

  String get _categoryCode {
    if (widget.categoryCode != null && widget.categoryCode!.isNotEmpty) {
      return widget.categoryCode!;
    }
    return switch (widget.title) {
      '저축' => 'SAVING',
      '주식' => 'STOCK',
      '부동산' => 'REAL_ESTATE',
      '세금' => 'TAX',
      _ => 'ECONOMY',
    };
  }

  Future<void> _loadRoadmap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _api.roadmap(_categoryCode);
      final categoryUnlocks = await _loadUnlockKeys('CATEGORY');
      final unitUnlocks = await _loadUnlockKeys('UNIT');
      if (!mounted) return;
      final units = _normalizeUnitStates(
        result.units,
        categoryUnlocked: categoryUnlocks.contains(_categoryCode),
        unlockedUnitIds: unitUnlocks,
      );
      setState(() {
        _summary = result.summary;
        _categorySubtitle = result.category.subtitle;
        _units = units;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentUnit(),
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '커리큘럼 정보를 불러오지 못했어요.';
      });
    }
  }

  Future<Set<String>> _loadUnlockKeys(String contentType) async {
    try {
      final result = await _api.contentUnlocks(contentType);
      return result.items.map((item) => item.contentKey).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  List<UnitData> _normalizeUnitStates(
    List<CurriculumUnit> apiUnits, {
    required bool categoryUnlocked,
    required Set<String> unlockedUnitIds,
  }) {
    if (apiUnits.isEmpty) return [];

    var currentIndex = apiUnits.indexWhere(
      (unit) => unit.status == 'IN_PROGRESS',
    );
    if (currentIndex < 0) {
      currentIndex = apiUnits.indexWhere(
        (unit) => unit.status != 'COMPLETED' && unit.status != 'LOCKED',
      );
    }
    if (currentIndex < 0) {
      currentIndex = apiUnits.length - 1;
    }

    return List.generate(apiUnits.length, (index) {
      final unit = apiUnits[index];
      final isUnlockedByPurchase =
          categoryUnlocked || unlockedUnitIds.contains('${unit.id}');
      final state = _unitStateFor(
        unit.status,
        index,
        currentIndex,
        isUnlockedByPurchase: isUnlockedByPurchase,
      );
      return UnitData(
        id: index + 1,
        backendId: unit.id,
        title: unit.title,
        description: unit.subtitle,
        emoji: _emojiForUnit(unit.title, state),
        state: state,
        progressPercent: unit.progressPercent,
        lessons:
            unit.stages.map((stage) {
              return LessonData(
                id: stage.id,
                name: stage.title,
                status: stage.status,
                isCompleted: stage.status == 'COMPLETED',
              );
            }).toList(),
      );
    });
  }

  UnitState _unitStateFor(
    String status,
    int index,
    int currentIndex, {
    required bool isUnlockedByPurchase,
  }) {
    if (status == 'LOCKED') return UnitState.locked;
    if (status == 'COMPLETED') return UnitState.completed;
    if (isUnlockedByPurchase) return UnitState.active;
    if (index == currentIndex) return UnitState.active;
    if (index < currentIndex) return UnitState.completed;
    return UnitState.locked;
  }

  String _emojiForUnit(String title, UnitState state) {
    if (state == UnitState.locked) return '🔒';
    if (title.contains('금리') || title.contains('저축') || title.contains('예금'))
      return '💰';
    if (title.contains('물가') || title.contains('주식') || title.contains('ETF'))
      return '📈';
    if (title.contains('환율')) return '💱';
    if (title.contains('은행') || title.contains('대출')) return '🏦';
    if (title.contains('부동산') || title.contains('청약') || title.contains('전월세'))
      return '🏠';
    if (title.contains('세금') || title.contains('소득세')) return '🧾';
    return '💡';
  }

  void _scrollToCurrentUnit() {
    if (!_scrollController.hasClients || _units.isEmpty) return;
    final currentIndex = _currentUnitIndex();
    if (currentIndex <= 0) return;

    final targetOffset = (currentIndex * 226.0 - 24).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(targetOffset);
  }

  int _currentUnitIndex() {
    final inProgressIndex = _units.indexWhere(
      (unit) => unit.state == UnitState.active && unit.progressPercent > 0,
    );
    if (inProgressIndex >= 0) return inProgressIndex;

    final lastProgressIndex = _units.lastIndexWhere(
      (unit) => unit.progressPercent > 0,
    );
    if (lastProgressIndex >= 0) return lastProgressIndex;

    final lastCompletedIndex = _units.lastIndexWhere(
      (unit) => unit.state == UnitState.completed,
    );
    if (lastCompletedIndex >= 0) return lastCompletedIndex;

    final activeIndex = _units.indexWhere(
      (unit) => unit.state == UnitState.active,
    );
    if (activeIndex >= 0) return activeIndex;

    return 0;
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
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00EE94),
                        ),
                      )
                      : _errorMessage != null
                      ? _buildErrorState()
                      : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
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
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage ?? '커리큘럼 정보를 불러오지 못했어요.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadRoadmap,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '다시 불러오기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
    final String quote =
        (_categorySubtitle != null && _categorySubtitle!.isNotEmpty)
            ? _categorySubtitle!
            : widget.title == '저축'
            ? '현명한 돈 관리가 풍요로운 미래를 만든다'
            : widget.title == '주식'
            ? '수익을 만드는 주식 투자의 기초'
            : widget.title == '부동산'
            ? '내 집 마련의 첫 걸음'
            : widget.title == '세금'
            ? '세금 절약이 곧 수익이다'
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
          Text(
            '총 ${_summary?.totalUnitCount ?? _units.length}개 유닛',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: themeColor,
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
        final bool isCurveCompleted =
            unit.state == UnitState.completed &&
            nextUnit.state != UnitState.locked;

        children.add(
          SizedBox(
            width: 354,
            height: 90,
            child: CustomPaint(
              painter: CurvePainter(
                isLeftToRight:
                    isLeftNode, // If left circle, next is right circle, so Left-to-Right
                isCompleted: isCurveCompleted,
                curveColor: curveColor,
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
        constraints: const BoxConstraints(minHeight: 136),
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [circleButton, const SizedBox(width: 12), infoCard],
            ),
          ),
        ),
      );
    } else {
      // Unit 2 (width 294)
      return Container(
        width: 354,
        constraints: const BoxConstraints(minHeight: 136),
        alignment: Alignment.center,
        child: SizedBox(
          width: 294,
          child: Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Row(
              children: [infoCard, const SizedBox(width: 12), circleButton],
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
              color:
                  unit.state == UnitState.completed
                      ? themeColor
                      : unit.state == UnitState.active
                      ? Colors.white
                      : const Color(0xFFE8E8E8),
              boxShadow: [
                if (unit.state == UnitState.completed)
                  BoxShadow(
                    color: completedNodeShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                else if (unit.state == UnitState.active)
                  BoxShadow(
                    color: activeNodeShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child:
                unit.state == UnitState.active
                    ? CustomPaint(
                      painter: DashedCirclePainter(
                        color: themeColor,
                        strokeWidth: 3,
                      ),
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
                  border: Border.all(color: themeColor, width: 2),
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
                  color: themeColor,
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
        constraints: const BoxConstraints(minHeight: 136),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isActive || isCompleted ? Colors.white : const Color(0xFFF3F3F3),
          border: Border.all(
            color:
                isActive
                    ? themeColor
                    : isCompleted
                    ? completedCardBorderColor
                    : const Color(0xFFE8E8E8),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: activeCardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            else if (isCompleted)
              BoxShadow(
                color: completedCardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
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
                color:
                    isActive || isCompleted
                        ? badgeBgColor
                        : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                unit.customUnitLabel ?? 'Unit ${unit.id}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                      isActive || isCompleted
                          ? badgeTextColor
                          : const Color(0xFFAAAAAA),
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Title
            Text(
              unit.title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color:
                    isActive || isCompleted
                        ? brandInk
                        : const Color(0xFFC0C0C0),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 1),
            // Subtitle
            Text(
              unit.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color:
                    isActive || isCompleted
                        ? textMuted
                        : const Color(0xFFD0D0D0),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUnitTap(UnitData unit) {
    if (unit.state == UnitState.locked) {
      HapticFeedback.lightImpact();
      _showUnlockSheet(unit: unit);
      return;
    }

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StageMapScreen(
              unitName: 'Unit ${unit.id}. ${unit.title}',
              unitTitle: unit.title,
              unitSubtitle: unit.description,
              category: widget.title,
              unitId: unit.backendId,
              stages: _stageItemsForUnit(unit),
            ),
      ),
    ).then((val) {
      if (!mounted) return;
      if (val is int && val != 1) {
        Navigator.pop(context, val);
      }
    });
  }

  List<StageListItem> _stageItemsForUnit(UnitData unit) {
    final visibleStages = unit.lessons.take(3).toList();
    return List.generate(visibleStages.length, (index) {
      final lesson = visibleStages[index];
      return StageListItem(
        id: lesson.id ?? 0,
        sequence: index + 1,
        title: lesson.name,
        status: lesson.status,
      );
    });
  }

  Future<void> _showUnlockSheet({required UnitData unit}) async {
    final purchased = await UnlockBottomSheet.show(
      context,
      category: widget.title,
      categoryCode: _categoryCode,
      unitId: unit.backendId,
      unitTitle: unit.title,
    );
    if (purchased == true && mounted) {
      await _loadRoadmap();
    }
  }

  Widget _buildBottomProgressCard(double width) {
    final completed =
        _summary?.completedUnitCount ??
        _units.where((unit) => unit.state == UnitState.completed).length;
    final total = _summary?.totalUnitCount ?? _units.length;
    final progress =
        total <= 0
            ? 0
            : (_summary?.progressPercent ?? (completed * 100 / total).round())
                .clamp(0, 100);

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 56.5),
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
            children: [
              Text(
                '$completed/$total 유닛 완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                  height: 1.5,
                ),
              ),
              Text(
                '$progress%',
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
            child:
                progress <= 0
                    ? const SizedBox.shrink()
                    : FractionallySizedBox(
                      widthFactor: progress / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeColor,
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

  Widget _buildBottomNavigationBar() {
    return EconoBottomNavigationBar(
      activeTab: EconoBottomTab.learning,
      onTabSelected: (tab) {
        if (tab != EconoBottomTab.learning) {
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

// ----------------------------------------------------
// Custom Painters for Roadmap Curves and Node Borders
// ----------------------------------------------------

class CurvePainter extends CustomPainter {
  final bool isLeftToRight;
  final bool isCompleted;
  final Color curveColor;

  CurvePainter({
    required this.isLeftToRight,
    required this.isCompleted,
    required this.curveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round;

    if (isCompleted) {
      paint.color = curveColor;
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
        startXLeft,
        size.height * 0.5,
        startXRight,
        size.height * 0.5,
        startXRight,
        size.height,
      );
    } else {
      path.moveTo(startXRight, 0);
      path.cubicTo(
        startXRight,
        size.height * 0.5,
        startXLeft,
        size.height * 0.5,
        startXLeft,
        size.height,
      );
    }

    if (isCompleted) {
      canvas.drawPath(path, paint);
    } else {
      _drawDashedPath(canvas, path, paint, 6, 6);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
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
      oldDelegate.isLeftToRight != isLeftToRight ||
      oldDelegate.isCompleted != isCompleted ||
      oldDelegate.curveColor != curveColor;
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final path =
        Path()..addOval(Rect.fromCircle(center: center, radius: radius));

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
  final int? backendId;
  final String title;
  final String description;
  final String emoji;
  final List<LessonData> lessons;
  final UnitState state;
  final String? customUnitLabel;
  final int progressPercent;

  UnitData({
    required this.id,
    this.backendId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.lessons,
    required this.state,
    this.customUnitLabel,
    this.progressPercent = 0,
  });
}

class LessonData {
  final int? id;
  final String name;
  final String status;
  final bool isCompleted;

  LessonData({
    this.id,
    required this.name,
    this.status = 'AVAILABLE',
    bool? isCompleted,
  }) : isCompleted = isCompleted ?? status == 'COMPLETED';
}

enum UnitState { completed, active, locked }
