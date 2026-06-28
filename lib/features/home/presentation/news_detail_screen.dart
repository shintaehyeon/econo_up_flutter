import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/daily_connect_api.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({
    super.key,
    required this.article,
    this.onBottomTabSelected,
  });

  final DailyArticle article;
  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color accentGreen = Color(0xFF1DDC83);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const String _fallbackImagePath = 'assets/images/news_fed_powell.png';

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final ApiClient _client;
  late final DailyConnectApi _api;

  DailyArticleDetail? _detail;

  DailyArticle get _article => _detail?.article ?? widget.article;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = DailyConnectApi(_client);
    _loadDetail();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _api.article(widget.article.id);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (_) {
      // 목록 응답만으로도 상세 화면을 그릴 수 있어, 상세 API 실패 시 화면은 유지합니다.
    }
  }

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
                _buildHeader(context, scale),
                _buildMetaRow(scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24 * scale, 14 * scale, 24 * scale, 24 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTitleBlock(scale),
                        SizedBox(height: 18 * scale),
                        _buildSummaryCard(scale),
                        SizedBox(height: 16 * scale),
                        _buildImageCard(scale),
                        SizedBox(height: 20 * scale),
                        _buildSectionTitle(scale),
                        SizedBox(height: 12 * scale),
                        ..._buildTermCards(context, scale),
                        SizedBox(height: 14 * scale),
                        _buildLearnButton(scale),
                      ],
                    ),
                  ),
                ),
                EconoBottomNavigationBar(
                  activeTab: EconoBottomTab.connect,
                  scale: scale,
                  onTabSelected: (tab) => _handleBottomTab(context, tab),
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
      height: 41 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: SizedBox(
                  width: 24 * scale,
                  height: 24 * scale,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: NewsDetailScreen.textMuted,
                    size: 18 * scale,
                  ),
                ),
              ),
            ),
            Text(
              '뉴스 상세',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: NewsDetailScreen.brandInk,
                height: 16 / 16,
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: HapticFeedback.lightImpact,
                child: _BookmarkIcon(
                  width: 19 * scale,
                  height: 19 * scale,
                  color: NewsDetailScreen.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(double scale) {
    return SizedBox(
      height: 51 * scale,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24 * scale, 10 * scale, 24 * scale, 0),
        child: Row(
          children: [
            Container(
              width: 53 * scale,
              height: 29 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2FFFA),
                borderRadius: BorderRadius.circular(16777216),
              ),
              child: Text(
                _categoryLabel(_article),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: NewsDetailScreen.accentGreen,
                  height: 18 / 12,
                ),
              ),
            ),
            SizedBox(width: 6 * scale),
            Text(
              _formatDate(_article.publishedAt),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w500,
                color: NewsDetailScreen.textLight,
                height: 15 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock(double scale) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _article.title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 20 / 18,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            _article.subtitle.isEmpty ? _article.sourceName : _article.subtitle,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 16.5 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double scale) {
    final summary = _summaryLines();
    return Container(
      height: 124 * scale,
      padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 18 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x3300EE94), width: 1.14217 * scale),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x12000000),
            blurRadius: 12 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 3줄 요약',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: NewsDetailScreen.themeGreen,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 8 * scale),
          _buildSummaryLine('① ${summary[0]}', scale),
          SizedBox(height: 6 * scale),
          _buildSummaryLine('② ${summary[1]}', scale),
          SizedBox(height: 6 * scale),
          _buildSummaryLine('③ ${summary[2]}', scale),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String text, double scale) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 11 * scale,
        fontWeight: FontWeight.w400,
        color: NewsDetailScreen.textMuted,
        height: 16.5 / 11,
      ),
    );
  }

  Widget _buildImageCard(double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openOriginal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: SizedBox(
          height: 193 * scale,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildThumbnail(_article.thumbnailUrl),
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
                bottom: 18 * scale,
                child: Container(
                  width: 95 * scale,
                  height: 22 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x2600EE94),
                    borderRadius: BorderRadius.circular(16777216),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 10 * scale,
                        color: const Color(0xFF0DE593),
                      ),
                      SizedBox(width: 5 * scale),
                      Text(
                        '원문 보러가기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0DE593),
                          height: 15 / 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(double scale) {
    return SizedBox(
      height: 28 * scale,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          '주요 용어',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            color: NewsDetailScreen.brandInk,
            height: 17 / 14,
            letterSpacing: -0.439453 * scale,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTermCards(BuildContext context, double scale) {
    final terms = _detail?.terms.where((term) => term.name.isNotEmpty).toList() ?? const <DailyTerm>[];
    final displayTerms = terms.isEmpty
        ? [
            DailyTerm(
              id: _article.id,
              name: _article.term.isEmpty ? _article.title : _article.term,
              definition: _article.subtitle.isEmpty ? '데일리 커넥트 핵심 용어입니다.' : _article.subtitle,
              relatedStageId: 0,
            ),
          ]
        : terms.take(2).toList();

    return [
      for (final term in displayTerms) ...[
        _buildTermCard(
          context: context,
          title: term.name,
          description: term.definition,
          modalDefinition: term.definition,
          scale: scale,
        ),
        SizedBox(height: 8 * scale),
      ],
    ];
  }

  Widget _buildTermCard({
    required BuildContext context,
    required String title,
    required String description,
    required String modalDefinition,
    required double scale,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showTermExplanation(
        context: context,
        title: title,
        definition: modalDefinition,
      ),
      child: Container(
        height: 55 * scale,
        padding: EdgeInsets.fromLTRB(17 * scale, 9 * scale, 20 * scale, 9 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12000000),
              blurRadius: 12 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4 * scale,
              height: 37 * scale,
              decoration: BoxDecoration(
                color: NewsDetailScreen.themeGreen,
                borderRadius: BorderRadius.circular(16777216),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: NewsDetailScreen.textMuted,
                      height: 18 / 14,
                    ),
                  ),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: NewsDetailScreen.textMuted,
                      height: 14 / 12,
                    ),
                  ),
                ],
              ),
            ),
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
                  color: NewsDetailScreen.textMuted,
                  height: 14 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnButton(double scale) {
    final stageId = _detail?.relatedStageId ?? 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 52 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2FFFA),
          border: Border.all(color: NewsDetailScreen.themeGreen),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 15 * scale,
                  color: NewsDetailScreen.accentGreen,
                ),
                SizedBox(width: 4 * scale),
                Text(
                  '이 개념 제대로 배우기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: NewsDetailScreen.accentGreen,
                    height: 17 / 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2 * scale),
            Text(
              stageId > 0 ? '관련 Stage $stageId →' : '경제 상식 > Unit 1. 금리 →',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w400,
                color: NewsDetailScreen.textMuted,
                height: 15 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    if (url.trim().isEmpty) {
      return Image.asset(
        NewsDetailScreen._fallbackImagePath,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          NewsDetailScreen._fallbackImagePath,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Future<void> _openOriginal() async {
    HapticFeedback.lightImpact();
    final url = (_detail?.sourceUrl.isNotEmpty == true ? _detail!.sourceUrl : _article.youtubeUrl).trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연결할 원문 링크가 없습니다.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원문 링크를 열 수 없습니다.')),
      );
    }
  }

  void _showTermExplanation({
    required BuildContext context,
    required String title,
    required String definition,
  }) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final scale = (screenWidth / 447.0).clamp(0.0, 1.0).toDouble();

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24 * scale),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TermExplanationDialog(
            title: title,
            definition: definition,
            scale: scale,
          ),
        );
      },
    );
  }

  void _handleBottomTab(BuildContext context, EconoBottomTab tab) {
    if (tab == EconoBottomTab.connect) {
      return;
    }

    Navigator.pop(context);
    widget.onBottomTabSelected?.call(_indexForBottomTab(tab));
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

  List<String> _summaryLines() {
    final lines = _article.summary.where((line) => line.trim().isNotEmpty).toList();
    while (lines.length < 3) {
      lines.add(_article.subtitle.isEmpty ? '${_article.title} 내용을 확인해보세요.' : _article.subtitle);
    }
    return lines.take(3).toList();
  }

  String _categoryLabel(DailyArticle article) {
    switch (article.categoryCode.toUpperCase()) {
      case 'ECONOMY':
        return '경제';
      case 'SAVING':
        return '저축';
      case 'STOCK':
        return '주식';
      case 'REAL_ESTATE':
        return '부동산';
      case 'TAX':
        return '세금';
      default:
        return article.term.isEmpty ? '경제' : article.term;
    }
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
  }
}

class TermExplanationDialog extends StatelessWidget {
  const TermExplanationDialog({
    super.key,
    required this.title,
    required this.definition,
    required this.scale,
  });

  final String title;
  final String definition;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320 * scale,
      height: 312.48 * scale,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x26000000),
            blurRadius: 40 * scale,
            offset: Offset(0, 12 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w700,
              color: NewsDetailScreen.themeGreen,
              height: 27 / 24,
            ),
          ),
          SizedBox(height: 28 * scale),
          Text(
            '정의',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: NewsDetailScreen.textLight,
              height: 15 / 11,
            ),
          ),
          SizedBox(height: 8 * scale),
          SizedBox(
            height: 39 * scale,
            child: Text(
              definition,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13 * scale,
                fontWeight: FontWeight.w400,
                color: NewsDetailScreen.brandInk,
                height: 19.2 / 13,
              ),
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            '관련 학습',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: NewsDetailScreen.textLight,
              height: 15 / 11,
            ),
          ),
          SizedBox(height: 8 * scale),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: HapticFeedback.lightImpact,
            child: Container(
              height: 36.49 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F7),
                borderRadius: BorderRadius.circular(30 * scale),
              ),
              child: Text(
                '경제 상식 · Unit 1. 금리 Stage 1 →',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                  height: 14 / 12,
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              height: 36.49 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NewsDetailScreen.themeGreen,
                borderRadius: BorderRadius.circular(30 * scale),
              ),
              child: Text(
                '확인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 17 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BookmarkIconPainter(color: color),
    );
  }
}

class _BookmarkIconPainter extends CustomPainter {
  const _BookmarkIconPainter({required this.color});

  final Color color;

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

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.10
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BookmarkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
