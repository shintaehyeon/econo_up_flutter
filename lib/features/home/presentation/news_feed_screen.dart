import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/daily_connect_api.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key, this.onBottomTabSelected});

  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
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
      _error = null;
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
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load news feed.';
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
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
            onRefresh: _loadArticles,
            child: ListView(
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 34 * scale),
              children: [
                _buildHeader(scale),
                SizedBox(height: 14 * scale),
                _buildFilterTabs(scale),
                SizedBox(height: 24 * scale),
                Text('Today headline', style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w800, color: NewsFeedScreen.brandInk)),
                SizedBox(height: 14 * scale),
                if (_isLoading) Padding(padding: EdgeInsets.only(top: 100 * scale), child: const Center(child: CircularProgressIndicator(color: NewsFeedScreen.themeGreen))),
                if (_error != null) _errorBox(scale),
                if (!_isLoading && _error == null && _articles.isEmpty) _emptyBox(scale),
                if (!_isLoading && _error == null && _articles.isNotEmpty) ...[
                  _headlineCard(_articles.first, scale),
                  SizedBox(height: 16 * scale),
                  ..._articles.skip(1).map((article) => _newsListItem(article, scale)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Text('Daily Connect', style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w800, color: NewsFeedScreen.brandInk));
  }

  Widget _buildFilterTabs(double scale) {
    return Row(children: [
      _filterPill('All', !_bookmarkedOnly, () {
        HapticFeedback.lightImpact();
        setState(() => _bookmarkedOnly = false);
        _loadArticles();
      }, scale),
      SizedBox(width: 8 * scale),
      _filterPill('Saved', _bookmarkedOnly, () {
        HapticFeedback.lightImpact();
        setState(() => _bookmarkedOnly = true);
        _loadArticles();
      }, scale),
    ]);
  }

  Widget _filterPill(String label, bool active, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36 * scale,
        padding: EdgeInsets.symmetric(horizontal: 18 * scale),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? NewsFeedScreen.themeGreen : Colors.white,
          border: Border.all(color: active ? NewsFeedScreen.themeGreen : NewsFeedScreen.borderGrey),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : NewsFeedScreen.textMuted, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _headlineCard(DailyArticle article, double scale) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: SizedBox(
          height: 193 * scale,
          child: Stack(fit: StackFit.expand, children: [
            _thumbnail(article.thumbnailUrl),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0xDD000000)]))),
            Positioned(
              left: 17 * scale,
              right: 17 * scale,
              bottom: 46 * scale,
              child: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            Positioned(
              left: 17 * scale,
              bottom: 18 * scale,
              child: _termPill(article.term, scale),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _newsListItem(DailyArticle article, double scale) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: EdgeInsets.only(bottom: 13 * scale),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: SizedBox(width: 94 * scale, height: 74 * scale, child: _thumbnail(article.thumbnailUrl)),
          ),
          SizedBox(width: 13 * scale),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(article.term, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w800, color: NewsFeedScreen.themeGreen)),
            SizedBox(height: 5 * scale),
            Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w800, color: NewsFeedScreen.brandInk)),
            SizedBox(height: 5 * scale),
            Text(article.publishedAt.isEmpty ? article.subtitle : article.publishedAt, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12 * scale, color: NewsFeedScreen.textMuted)),
          ])),
        ]),
      ),
    );
  }

  Widget _thumbnail(String url) {
    if (url.isEmpty) {
      return Container(color: const Color(0xFFE5E7EB), child: const Icon(Icons.play_circle_fill_rounded, color: NewsFeedScreen.themeGreen, size: 44));
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E7EB), child: const Icon(Icons.play_circle_fill_rounded, color: NewsFeedScreen.themeGreen, size: 44)),
    );
  }

  Widget _termPill(String term, double scale) {
    return Container(
      height: 24 * scale,
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: NewsFeedScreen.themeGreen, borderRadius: BorderRadius.circular(999)),
      child: Text(term, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  void _openArticle(DailyArticle article) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(height: 180, width: double.infinity, child: _thumbnail(article.thumbnailUrl))),
          const SizedBox(height: 16),
          Text(article.term, style: const TextStyle(color: NewsFeedScreen.themeGreen, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(article.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: NewsFeedScreen.brandInk)),
          const SizedBox(height: 8),
          Text(article.subtitle, style: const TextStyle(color: NewsFeedScreen.textMuted)),
          const SizedBox(height: 12),
          SelectableText(article.youtubeUrl, style: const TextStyle(color: Color(0xFF2563EB))),
        ]),
      ),
    );
  }

  Widget _errorBox(double scale) => Column(children: [Text(_error!, textAlign: TextAlign.center), SizedBox(height: 12 * scale), ElevatedButton(onPressed: _loadArticles, child: const Text('Retry'))]);

  Widget _emptyBox(double scale) => Padding(padding: EdgeInsets.only(top: 80 * scale), child: const Center(child: Text('No articles from server yet.')));
}