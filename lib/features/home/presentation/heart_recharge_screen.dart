// lib/features/home/presentation/heart_recharge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../data/wallet_api.dart';

class HeartRechargeScreen extends StatefulWidget {
  const HeartRechargeScreen({
    super.key,
    required this.onClose,
    required this.onOpenBillPurchaseCenter,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenBillPurchaseCenter;

  @override
  State<HeartRechargeScreen> createState() => _HeartRechargeScreenState();
}

class _HeartRechargeScreenState extends State<HeartRechargeScreen> {
  late final ApiClient _client;
  late final WalletApi _walletApi;
  int _heartCount = 1;
  int _billCount = 5;
  bool _isUnlimited = false;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _walletApi = WalletApi(_client);
    _loadWallet();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await _walletApi.balance();
      if (!mounted) return;
      _applyWallet(wallet);
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('지갑 정보를 불러오지 못했어요.');
    }
  }

  Future<void> _chargeOneHeart() async {
    if (_isPurchasing) return;
    if (_isUnlimited || _heartCount >= 3) {
      _showMessage('하트가 이미 가득 찼거나 무제한 상태입니다.');
      return;
    }
    if (_billCount < 1) {
      _showMessage('지폐가 부족합니다.');
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final wallet = await _walletApi.refillHeart();
      if (!mounted) return;
      _applyWallet(wallet);
      _showMessage('하트 1개가 충전되었습니다.');
    } on ApiClientException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('하트 충전에 실패했어요.');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _activateUnlimitedHearts() async {
    if (_isPurchasing) return;
    if (_isUnlimited) {
      _showMessage('이미 무제한 상태입니다.');
      return;
    }
    if (_billCount < 3) {
      _showMessage('지폐가 부족합니다.');
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final wallet = await _walletApi.unlimitedHearts();
      if (!mounted) return;
      _applyWallet(wallet);
      _showMessage('24시간 하트 무제한이 적용되었습니다.');
    } on ApiClientException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('무제한 하트 구매에 실패했어요.');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _applyWallet(WalletData wallet) {
    setState(() {
      _heartCount = wallet.heartCurrent;
      _billCount = wallet.billBalance;
      _isUnlimited = wallet.unlimited;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);

    return Center(
      child: Container(
        width: contentWidth,
        height: double.infinity,
        color: const Color(0xFFCFCFCF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 63,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Title: 하트 충전
                  const Center(
                    child: Text(
                      '하트 충전',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2A3A),
                        height: 28 / 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Status Row
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 38),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00EE94),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '현재',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 14,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF7C7C),
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isUnlimited
                            ? '3/3 (무제한)'
                            : '$_heartCount/3',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Option 1
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _chargeOneHeart();
                    },
                    child: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFA),
                        border: Border.all(color: const Color(0xFF00EE94), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '즉시 충전',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                        height: 19 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '하트 1개 즉시 충전',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                    height: 14 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '💵 지폐 1개',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.064,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Option 2
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _activateUnlimitedHearts();
                    },
                    child: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '즉시 충전',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                        height: 19 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '24시간 동안 무제한 학습',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                    height: 14 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '💵 지폐 3개',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.064,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                  const SizedBox(height: 10),
                  // Close Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onClose();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A7282),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 51),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
