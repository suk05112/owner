import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MockDashboardStatsProvider extends ChangeNotifier {
  int _issuedCount = 0;
  int _usedCount = 0;
  int _unusedCount = 0;

  int get issuedCount => _issuedCount;
  int get usedCount => _usedCount;
  int get unusedCount => _unusedCount;
  int? get lastFetchedStoreId => null;

  Future<void> refreshStats(int storeId) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/dashboard_stats.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _issuedCount = json['total_issued'] as int;
      _usedCount = json['total_used'] as int;
      _unusedCount = json['total_unused'] as int;
      notifyListeners();
    } catch (e) {
      debugPrint("MockDashboardStatsProvider.refreshStats error: $e");
    }
  }

  void clearIfDifferentStore(int? currentStoreId) {
    // mock 모드에서는 초기화 불필요
  }
}
