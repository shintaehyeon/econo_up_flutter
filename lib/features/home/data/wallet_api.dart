import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class WalletApi {
  WalletApi(this._client);

  final ApiClient _client;

  Future<WalletData> balance() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.wallet);
    return WalletData.fromJson(data);
  }

  Future<WalletData> refillHeart() async {
    final data = await _client.post<Map<String, dynamic>>(ApiEndpoints.refillHearts);
    return WalletData.fromJson(_asMap(data['wallet']));
  }

  Future<WalletData> unlimitedHearts() async {
    final data = await _client.post<Map<String, dynamic>>(ApiEndpoints.purchaseUnlimitedHearts);
    return WalletData.fromJson(_asMap(data['wallet']));
  }

  Future<WalletData> grantBills(int amount) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.grantBills,
      body: {'amount': amount, 'memo': 'DEV_FRONTEND_GRANT'},
    );
    return WalletData.fromJson(_asMap(data['wallet']));
  }
}

class WalletData {
  const WalletData({
    required this.billBalance,
    required this.heartCurrent,
    required this.heartMax,
    required this.nextRefillAt,
    required this.unlimited,
  });

  final int billBalance;
  final int heartCurrent;
  final int heartMax;
  final String nextRefillAt;
  final bool unlimited;

  factory WalletData.fromJson(Map<String, dynamic> json) {
    final hearts = _asMap(json['hearts']);
    return WalletData(
      billBalance: _asInt(json['billBalance']),
      heartCurrent: _asInt(hearts['current']),
      heartMax: _asInt(hearts['max'], fallback: 3),
      nextRefillAt: '${hearts['nextRefillAt'] ?? ''}',
      unlimited: hearts['unlimited'] == true,
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}