import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/wallet_api.dart';

class HeartRechargeScreen extends StatefulWidget {
  const HeartRechargeScreen({super.key, required this.onClose, required this.onOpenBillPurchaseCenter});

  final VoidCallback onClose;
  final VoidCallback onOpenBillPurchaseCenter;

  @override
  State<HeartRechargeScreen> createState() => _HeartRechargeScreenState();
}

class _HeartRechargeScreenState extends State<HeartRechargeScreen> {
  late final ApiClient _client;
  late final WalletApi _api;

  WalletData? _wallet;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
    _api = WalletApi(_client);
    _load();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _load() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final wallet = await _api.balance();
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
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
        _error = 'Could not load wallet.';
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

  Future<void> _runWalletAction(Future<WalletData> Function() action, String success) async {
    if (_isSubmitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    try {
      final wallet = await action();
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success), duration: const Duration(seconds: 1)));
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), duration: const Duration(seconds: 1)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet request failed.'), duration: Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final wallet = _wallet;

    return Center(
      child: Container(
        width: contentWidth,
        height: double.infinity,
        color: const Color(0x99000000),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 34),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 63, height: 4, decoration: BoxDecoration(color: const Color(0xFFE4E8F0), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 26),
              Row(children: [
                const Expanded(child: Text('Heart recharge', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E2A3A)))),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 8),
              if (_isLoading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(color: Color(0xFF00EE94))))
              else if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ] else if (wallet != null) ...[
                Text(wallet.unlimited ? 'Unlimited hearts active' : '${wallet.heartCurrent}/${wallet.heartMax} hearts 쨌 Bills ${wallet.billBalance}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9CA3AF))),
                const SizedBox(height: 24),
                _option(Icons.favorite_rounded, 'Refill one heart', 'Spend bills through backend wallet API', () => _runWalletAction(_api.refillHeart, 'Heart refilled.'), enabled: !_isSubmitting),
                const SizedBox(height: 10),
                _option(Icons.all_inclusive_rounded, 'Unlimited hearts', 'Activate unlimited-pass MVP API', () => _runWalletAction(_api.unlimitedHearts, 'Unlimited hearts activated.'), enabled: !_isSubmitting),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: _isSubmitting ? null : widget.onOpenBillPurchaseCenter, child: const Text('Get more bills')),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _option(IconData icon, String title, String subtitle, VoidCallback onTap, {required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 65),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF2FFFA), border: Border.all(color: const Color(0xFF00EE94)), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFF7C7C)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ])),
          if (_isSubmitting) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        ]),
      ),
    );
  }
}
