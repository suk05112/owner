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

  Future<void> fetchStoreList(int owner_id) async {
    _isLoadingStoreList = true;
    notifyListeners();
    try {
      print("mock_store_provider::fetchStoreList:: mock data 반환");

      // Mock store data
      final mockStore = Store(
        id: 1,
        store_name: 'Mock 카페',
        store_address: '서울시 강남구 테헤란로 123',
        store_telephone: '02-1234-5678',
        store_business_hours: '09:00 ~ 22:00',
        store_logo: '',
        store_photo_urls: [],
        menu_list: [],
        option_list: [],
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

  Future<List<Store>> getStoreList(int owner_id) async {
    print("mock_store_provider::getStoreList:: mock 데이터 반환");

    // Mock store data
    final mockStore = Store(
      id: 1,
      store_name: 'Mock 카페',
      store_address: '서울시 강남구 테헤란로 123',
      store_telephone: '02-1234-5678',
      store_business_hours: '09:00 ~ 22:00',
      store_logo: '',
      store_photo_urls: [],
      menu_list: [],
      option_list: [],
    );

    return [mockStore];
  }

  Future<Store> getDetailStore(int storeId) async {
    print("mock_store_provider::getDetailStore:: mock 데이터 반환");

    // Mock store detail data
    return Store(
      id: storeId,
      store_name: 'Mock 카페',
      store_address: '서울시 강남구 테헤란로 123',
      store_telephone: '02-1234-5678',
      store_business_hours: '09:00 ~ 22:00',
      store_logo: '',
      store_photo_urls: [
        'https://via.placeholder.com/300x200',
        'https://via.placeholder.com/300x200/ff0000/ffffff',
      ],
      menu_list: [
        Menu(
          id: 1,
          menu_name: '아메리카노',
          menu_price: 4500,
          menu_category: '음료',
          menu_photo: '',
          menu_description: '깊은 풍미의 에스프레소',
          menu_sold_out: false,
        ),
        Menu(
          id: 2,
          menu_name: '카페 라떼',
          menu_price: 5500,
          menu_category: '음료',
          menu_photo: '',
          menu_description: '부드러운 우유와 에스프레소의 조화',
          menu_sold_out: false,
        ),
        Menu(
          id: 3,
          menu_name: '블루베리 머핀',
          menu_price: 3500,
          menu_category: '디저트',
          menu_photo: '',
          menu_description: '신선한 블루베리가 가득한 머핀',
          menu_sold_out: false,
        ),
      ],
      option_list: [
        Option(
          id: 1,
          option_name: '추가 샷',
          option_price: 500,
        ),
        Option(
          id: 2,
          option_name: '시럽 추가',
          option_price: 300,
        ),
      ],
    );
  }
}