import 'package:flutter/foundation.dart';
import 'package:owner/common/api/API.dart';

import '../api/request/store/store.dart';
// import 'package:owner/common/api/response/store/store.dart';

class StoreProvider extends ChangeNotifier {
  late Store? _store;
  late List<Store>? storeCards = [];

  void setStoreCard(List<Store>? storeCards) {
    // if ((storeCards?.length ?? 0) > 0) {
    //     slotCardsListVisible = true;
    // } else {
    //     slotCardsListVisible = false;
    // }

    this.storeCards = storeCards;
    notifyListeners();
  }

  Future<void> fetchStoreList(int owner_id) async {
    try {
      print("store_provider::fetchStoreList:: fetch 호출");
      var response = await Api().client.getStoreList(owner_id);
      setStoreCard(response.store);
    } catch (error) {
      print("store_provider::fetchStoreList:: fetch 오류: $error");
    }
  }

  Future<List<Store>> getStoreList() async {
    print("store_provider::getStoreList:: fetch 호출");
    Api().client.getStoreList(2).then((response) => {
          for (var res in response.store) {print(res.toString())}
        });
    var response = await Api().client.getStoreList(2);
    notifyListeners();

    return response.store;
  }

  Future<Store> getDetailStore(int storeId) async {
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
