import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/response/store/statistics_response.dart';

/// 대시보드 통계. QR 스캔으로 기프티콘 사용 시에만 API 호출해 갱신.
class DashboardStatsProvider extends ChangeNotifier {
  int _issuedCount = 0;
  int _usedCount = 0;
  int _unusedCount = 0;
  int? _lastFetchedStoreId;

  int get issuedCount => _issuedCount;
  int get usedCount => _usedCount;
  int get unusedCount => _unusedCount;
  int? get lastFetchedStoreId => _lastFetchedStoreId;

  /// 해당 매장 통계 API 호출 후 카운트 갱신
  Future<void> refreshStats(int storeId) async {
    try {
      final raw = await Api().client.getStoreStatistics(storeId);
      final statistics = StoreStatisticsResponse.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _issuedCount = statistics.total_issued;
      _usedCount = statistics.total_used;
      _unusedCount = statistics.total_unused;
      _lastFetchedStoreId = storeId;
      notifyListeners();
    } catch (e) {
      debugPrint("DashboardStatsProvider.refreshStats error: $e");
    }
  }

  /// 선택 매장이 바뀌었을 때, 다른 매장이면 표시용 카운트 초기화
  void clearIfDifferentStore(int? currentStoreId) {
    if (currentStoreId != null && currentStoreId != _lastFetchedStoreId) {
      _issuedCount = 0;
      _usedCount = 0;
      _unusedCount = 0;
      _lastFetchedStoreId = null;
      notifyListeners();
    }
  }
}
