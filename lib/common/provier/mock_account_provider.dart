import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/model/Account.dart';

class MockAccountProvider extends ChangeNotifier {
  final Map<int, Account?> _cache = {};

  Account? getCached(int storeId) => _cache[storeId];

  bool hasCached(int storeId) => _cache.containsKey(storeId);

  Future<Account?> loadAndCache(int storeId) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/account.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final accountJson = json['account'] as Map<String, dynamic>?;
      final account = accountJson != null ? Account.fromJson(accountJson) : null;
      _cache[storeId] = account;
      notifyListeners();
      return account;
    } catch (e) {
      debugPrint("MockAccountProvider.loadAndCache error: $e");
      _cache[storeId] = null;
      notifyListeners();
      return null;
    }
  }

  void invalidate(int storeId) {
    _cache.remove(storeId);
    notifyListeners();
  }
}
