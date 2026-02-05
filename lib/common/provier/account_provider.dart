import 'package:flutter/foundation.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Account.dart';

/// 계좌 정보 캐시 — 계좌관리 진입 시 1회만 API 호출, 계좌 변경 후에만 재호출
class AccountProvider extends ChangeNotifier {
  final Map<int, Account?> _cache = {};

  Account? getCached(int storeId) => _cache[storeId];

  bool hasCached(int storeId) => _cache.containsKey(storeId);

  /// API 호출 후 캐시에 저장하고 반환
  Future<Account?> loadAndCache(int storeId) async {
    try {
      final res = await Api().client.getAccount(storeId);
      final account = res.account;
      _cache[storeId] = account;
      notifyListeners();
      return account;
    } catch (e) {
      _cache[storeId] = null;
      notifyListeners();
      return null;
    }
  }

  /// 캐시 무효화 (해당 매장만)
  void invalidate(int storeId) {
    _cache.remove(storeId);
    notifyListeners();
  }
}
