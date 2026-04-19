import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/api/request/store/store.dart';

class MockStoreProvider extends ChangeNotifier {
  List<Store>? storeCards = [];
  bool _isLoadingStoreList = false;

  bool get isLoadingStoreList => _isLoadingStoreList;

  void setStoreCard(List<Store>? storeCards) {
    this.storeCards = storeCards;
    notifyListeners();
  }

  Future<void> fetchStoreList(int ownerId) async {
    _isLoadingStoreList = true;
    notifyListeners();
    try {
      final stores = await getStoreList(ownerId);
      setStoreCard(stores);
    } catch (error) {
      debugPrint("mock_store_provider::fetchStoreList:: 오류: $error");
      setStoreCard(null);
    } finally {
      _isLoadingStoreList = false;
      notifyListeners();
    }
  }

  Future<List<Store>> getStoreList(int ownerId) async {
    final jsonStr = await rootBundle.loadString('assets/mock/store_list.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final response = StoreListResponse.fromJson(json);
    return response.store;
  }

  Future<Store> getDetailStore(int storeId) async {
    final jsonStr = await rootBundle.loadString('assets/mock/store_detail.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final response = StoreResponse.fromJson(json);
    return response.store;
  }
}
