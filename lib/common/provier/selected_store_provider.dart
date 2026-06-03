import 'package:flutter/foundation.dart';
import 'package:owner/common/api/request/store/store.dart';

/// 현재 선택된 매장(스토어)을 앱 전역에서 사용하기 위한 Provider
class SelectedStoreProvider extends ChangeNotifier {
  List<Store> _stores = [];
  Store? _selectedStore;
  bool _isLoaded = false;

  List<Store> get stores => List.unmodifiable(_stores);
  Store? get selectedStore => _selectedStore;
  int? get selectedStoreId => _selectedStore?.store_id;
  bool get isLoaded => _isLoaded;

  bool get hasStores => _stores.isNotEmpty;
  bool get hasNoStores => _stores.isEmpty;

  void setStores(List<Store> stores) {
    _stores = stores;
    _isLoaded = true;
    if (stores.isEmpty) {
      _selectedStore = null;
    } else {
      final currentId = _selectedStore?.store_id;
      final stillExists = currentId != null &&
          stores.any((s) => s.store_id == currentId);
      if (!stillExists) {
        _selectedStore = stores.first;
      }
    }
    notifyListeners();
  }

  void setSelectedStore(Store? store) {
    if (store != null && !_stores.any((s) => s.store_id == store.store_id)) {
      return;
    }
    _selectedStore = store;
    notifyListeners();
  }

  void setSelectedStoreById(int storeId) {
    try {
      _selectedStore = _stores.firstWhere((s) => s.store_id == storeId);
      notifyListeners();
    } catch (_) {}
  }

  /// 캐시를 무효화하여 다음 DashboardPage 진입 시 재로드하도록 강제
  void invalidate() {
    _isLoaded = false;
    notifyListeners();
  }
}
