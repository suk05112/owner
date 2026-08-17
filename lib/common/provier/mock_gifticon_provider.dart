import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/GifticonResponse.dart';
import 'package:owner/common/model/UsedGifticon.dart';

class MockGifticonProvider extends ChangeNotifier {
  List<Store>? storeCards = [];

  void setStoreCard(List<Store>? storeCards) {
    this.storeCards = storeCards;
    notifyListeners();
  }

  Future<void> fetchStoreList(int ownerId) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/store_list.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final response = StoreListResponse.fromJson(json);
      setStoreCard(response.store);
    } catch (error) {
      debugPrint("MockGifticonProvider.fetchStoreList error: $error");
    }
  }

  Future<List<Store>> getStoreList(int ownerId) async {
    final jsonStr = await rootBundle.loadString('assets/mock/store_list.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final response = StoreListResponse.fromJson(json);
    notifyListeners();
    return response.store;
  }

  Future<Store> getDetailStore(int storeId) async {
    final jsonStr = await rootBundle.loadString('assets/mock/store_detail.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final response = StoreResponse.fromJson(json);
    return response.store;
  }

  Future<GifticonPatchResponse> useGifticon(
      int gifticonId, Map<String, dynamic> body) async {
    // mock: 항상 성공(result=0) 반환
    return GifticonPatchResponse(result: 0);
  }

  Future<UsedGifticonList> getUsedGifticon(int storeId) async {
    final jsonStr = await rootBundle.loadString('assets/mock/used_gifticon_list.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UsedGifticonList.fromJson(json);
  }
}
