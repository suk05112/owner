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

  Future<void> fetchStoreList() async {
    try {
      print("fetchStoreList:: fetch 호출");
      var response = await Api().client.getStoreList(1);
      setStoreCard(response.body.store);
    } catch (error) {
      print("fetchStoreList:: fetch 오류: $error");
    }
  }

  Future<List<Store>> getStoreList() async {
    print("getStoreList:: fetch 호출");
    Api().client.getStoreList(2).then((response) => {
          for (var res in response.body.store) {print(res.toString())}
        });
    var response = await Api().client.getStoreList(2);
    notifyListeners();

    return response.body.store;
  }

  Future<Store> getDetailStore() async {
    print("getDetailStore:: fetch 호출");
    // Api().client.getStoreDetailInfo(1).then((response) =>
    //     {print("provider store1"), print(response.store.toString())});
    var response = await Api().client.getStoreDetailInfo(54);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
