import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/daily_connect_api.dart';
import 'news_detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({
    super.key,
    this.onBottomTabSelected,
  });

  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  late final ApiClient _client;
  late final DailyConnectApi _api;

  List<DailyArticle> _articles = const [];
  bool _bookmarkedOnly = false;
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = DailyConnectApi(_client);
    _loadArticles();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final articles = await _api.articles(bookmarkedOnly: _bookmarkedOnly);
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _errorText = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = '데일리 커넥트를 불러오지 못했어요.';
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: contentWidth,
          height: double.infinity,
          child: RefreshIndicator(
            color: NewsFeedScreen.themeGreen,
            onRefresh: _loadArticles,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 34 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(scale),
                  SizedBox(height: 14 * scale),
                  _buildFilterTabs(scale),
                  SizedBox(height: 26 * scale),
                  _buildSectionTitle(scale),
                  SizedBox(height: 14 * scale),
                  if (_isLoading)
                    _buildLoading(scale)
                  else if (_errorText != null)
                    _buildError(scale)
                  else if (_articles.isEmpty)
                    _buildEmpty(scale)
                  else ...[
                    _buildHeadlineCard(context, _articles.first, scale),
                    SizedBox(height: 15 * scale),
                    ..._articles.skip(1).map((item) => _buildNewsListItem(context, item, scale)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Text(
      '데일리 커넥트',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        color: NewsFeedScreen.brandInk,
        height: 22.5 / 16,
      ),
    );
  }

  Widget _buildFilterTabs(double scale) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            if (!_bookmarkedOnly) return;
            setState(() => _bookmarkedOnly = false);
            _loadArticles();
          },
          child: Container(
            width: 52.75 * scale,
            height: 37.13 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: !_bookmarkedOnly ? NewsFeedScreen.themeGreen : Colors.white,
              border: Border.all(color: !_bookmarkedOnly ? NewsFeedScreen.themeGreen : NewsFeedScreen.borderGrey),
              borderRadius: BorderRadius.circular(16777216),
            ),
            child: Text(
              '전체',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w700,
                color: !_bookmarkedOnly ? Colors.white : NewsFeedScreen.textMuted,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            if (_bookmarkedOnly) return;
            setState(() => _bookmarkedOnly = true);
            _loadArticles();
          },
          child: Container(
            width: 52.75 * scale,
            height: 37.13 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bookmarkedOnly ? NewsFeedScreen.themeGreen : const Color(0x26FFFFFF),
              border: Border.all(color: _bookmarkedOnly ? NewsFeedScreen.themeGreen : NewsFeedScreen.borderGrey),
              borderRadius: BorderRadius.circular(16777216),
            ),
            child: _BookmarkIcon(
              width: 20 * scale,
              height: 20 * scale,
              color: _bookmarkedOnly ? Colors.white : NewsFeedScreen.borderGrey,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(double scale) {
    return Text(
      '오늘의 헤드라인',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14 * scale,
        fontWeight: FontWeight.w700,
        color: NewsFeedScreen.brandInk,
        height: 17 / 14,
        letterSpacing: -0.439453 * scale,
      ),
    );
  }

  Widget _buildHeadlineCard(BuildContext context, DailyArticle article, double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, article),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: SizedBox(
          width: double.infinity,
          height: 193 * scale,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildThumbnail(article.thumbnailUrl),
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
                right: 17 * scale,
                bottom: 65 * scale,
                child: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 20 / 18,
                  ),
                ),
              ),
              Positioned(
                left: 17 * scale,
                right: 17 * scale,
                bottom: 43 * scale,
                child: Text(
                  article.subtitle.isEmpty ? article.sourceName : article.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 16.5 / 12,
                  ),
                ),
              ),
              Positioned(
                left: 17 * scale,
                bottom: 18 * scale,
                child: Row(
                  children: [
                    _buildHeroPill(_categoryLabel(article), scale),
                    SizedBox(width: 8 * scale),
                    _buildQuizCompletePill(article.quizCompleted, scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPill(String label, double scale) {
    return Container(
      height: 22 * scale,
      padding: EdgeInsets.symmetric(horizontal: 14 * scale),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x2600EE94),
        borderRadius: BorderRadius.circular(16777216),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          color: NewsFeedScreen.themeGreen,
          height: 18 / 12,
        ),
      ),
    );
  }

  Widget _buildQuizCompletePill(bool completed, double scale) {
    return Container(
      height: 22 * scale,
      padding: EdgeInsets.fromLTRB(12 * scale, 0, 14 * scale, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x2600EE94),
        borderRadius: BorderRadius.circular(16777216),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_rounded : Icons.play_arrow_rounded,
            size: 15 * scale,
            color: NewsFeedScreen.themeGreen,
          ),
          SizedBox(width: 5 * scale),
          Text(
            completed ? '오늘 퀴즈 완료' : '오늘 퀴즈',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: NewsFeedScreen.themeGreen,
              height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListItem(BuildContext context, DailyArticle item, double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(context, item),
      child: SizedBox(
        width: double.infinity,
        height: 101 * scale,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 13 * scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6 * scale),
                child: SizedBox(
                  width: 102 * scale,
                  height: 68 * scale,
                  child: _buildThumbnail(item.thumbnailUrl),
                ),
              ),
            ),
            SizedBox(width: 13 * scale),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 13 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryPill(_categoryLabel(item), scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: NewsFeedScreen.brandInk,
                        height: 18.25 / 14,
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    Text(
                      _formatDate(item.publishedAt),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w500,
                        color: NewsFeedScreen.textLight,
                        height: 15 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 13 * scale),
              child: _BookmarkIcon(
                width: 16 * scale,
                height: 16 * scale,
                color: item.bookmarked ? NewsFeedScreen.themeGreen : const Color(0xFFB2B2B2),
                filled: item.bookmarked,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, double scale) {
    final width = label.length > 2 ? 39.0 : 32.0;
    return Container(
      width: width * scale,
      height: 16 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10 * scale,
          fontWeight: FontWeight.w500,
          color: NewsFeedScreen.textMuted,
          height: 13.5 / 10,
        ),
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    if (url.trim().isEmpty) {
      return _buildImagePlaceholder();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Icon(Icons.article_rounded, color: Color(0xFF9CA3AF), size: 28),
    );
  }

  Widget _buildLoading(double scale) {
    return SizedBox(
      height: 420 * scale,
      child: const Center(
        child: CircularProgressIndicator(color: NewsFeedScreen.themeGreen),
      ),
    );
  }

  Widget _buildError(double scale) {
    return SizedBox(
      height: 420 * scale,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorText ?? '데일리 커넥트를 불러오지 못했어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: NewsFeedScreen.textMuted,
              ),
            ),
            SizedBox(height: 12 * scale),
            TextButton(
              onPressed: _loadArticles,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(double scale) {
    return SizedBox(
      height: 420 * scale,
      child: Center(
        child: Text(
          _bookmarkedOnly ? '저장한 데일리 커넥트가 없어요.' : '아직 데일리 커넥트가 없어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13 * scale,
            fontWeight: FontWeight.w600,
            color: NewsFeedScreen.textMuted,
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, DailyArticle article) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          article: article,
          onBottomTabSelected: widget.onBottomTabSelected,
        ),
      ),
    );
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

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({
    required this.width,
    required this.height,
    required this.color,
    this.filled = false,
  });

  final double width;
  final double height;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BookmarkIconPainter(color: color, filled: filled),
    );
  }
}

class _BookmarkIconPainter extends CustomPainter {
  const _BookmarkIconPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

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

    if (filled) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      return;
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.12
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BookmarkIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}
