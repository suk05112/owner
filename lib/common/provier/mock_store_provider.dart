import 'package:flutter/foundation.dart';
import 'package:owner/common/api/request/store/store.dart';

class MockStoreProvider extends ChangeNotifier {
  late Store? _store;
  late List<Store>? storeCards = [];
  bool _isLoadingStoreList = false;

  bool get isLoadingStoreList => _isLoadingStoreList;
  bool get isMock => true;

  void setStoreCard(List<Store>? storeCards) {
    this.storeCards = storeCards;
    notifyListeners();
  }

  Future<void> fetchStoreList(int ownerId) async {
    _isLoadingStoreList = true;
    notifyListeners();
    try {
      print("mock_store_provider::fetchStoreList:: mock data 반환");

      // Mock store data
      final mockStore = Store(
        store_id: 1,
        store_name: 'Mock 카페',
        store_address: '서울시 강남구 테헤란로 123',
        store_telephone: '02-1234-5678',
        store_logo: '',
        store_photo_urls: [],
      );

      setStoreCard([mockStore]);
    } catch (error) {
      print("mock_store_provider::fetchStoreList:: 오류: $error");
      setStoreCard(null);
    } finally {
      _isLoadingStoreList = false;
      notifyListeners();
    }
  }

  Future<List<Store>> getStoreList(int ownerId) async {
    print("mock_store_provider::getStoreList:: mock 데이터 반환");

    // Mock store data
    final mockStore = Store(
      store_id: 1,
      store_name: 'Mock 카페',
      store_address: '서울시 강남구 테헤란로 123',
      store_telephone: '02-1234-5678',
      store_logo: '',
      store_photo_urls: [],
    );

    return [mockStore];
  }

  Future<Store> getDetailStore(int storeId) async {
    print("mock_store_provider::getDetailStore:: mock 데이터 반환");

    // Mock store detail data
    return Store(
      store_id: storeId,
      store_name: 'Mock 카페',
      store_address: '서울시 강남구 테헤란로 123',
      store_telephone: '02-1234-5678',
      store_logo: '',
      store_photo_urls: [
        'https://via.placeholder.com/300x200',
        'https://via.placeholder.com/300x200/ff0000/ffffff',
      ],
    );
  }
}
