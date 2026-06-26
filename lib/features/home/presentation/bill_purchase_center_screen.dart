import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/wallet_api.dart';

class BillPurchaseCenterScreen extends StatefulWidget {
  const BillPurchaseCenterScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<BillPurchaseCenterScreen> createState() => _BillPurchaseCenterScreenState();
}

class _BillPurchaseCenterScreenState extends State<BillPurchaseCenterScreen> {
  late final ApiClient _client;
  late final WalletApi _api;

  int _selectedIdx = 0;
  WalletData? _wallet;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  final List<int> _amounts = const [5, 10, 20];

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

  Future<void> _grantBills() async {
    if (_isSubmitting) return;
    HapticFeedback.mediumImpact();
    final amount = _amounts[_selectedIdx];
    setState(() => _isSubmitting = true);
    try {
      final wallet = await _api.grantBills(amount);
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$amount bills granted.'), duration: const Duration(seconds: 1)));
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
                const Expanded(child: Text('Bill center', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E2A3A)))),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 8),
              if (_isLoading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(color: Color(0xFF00EE94))))
              else if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ] else if (wallet != null) ...[
                Text('Current bills: ${wallet.billBalance}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9CA3AF))),
                const SizedBox(height: 24),
                for (var i = 0; i < _amounts.length; i++) ...[
                  _option(i, _amounts[i]),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _grantBills,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00EE94), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                  child: Text(_isSubmitting ? 'Processing...' : 'Grant selected bills'),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _option(int index, int amount) {
    final selected = _selectedIdx == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedIdx = index);
      },
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(Icons.payments_rounded, color: selected ? const Color(0xFF00EE94) : const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(child: Text('$amount bills', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
          Text('MVP grant', style: TextStyle(color: selected ? const Color(0xFF00AA6A) : const Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}