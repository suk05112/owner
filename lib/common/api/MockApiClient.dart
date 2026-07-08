import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/GifticonResponse.dart';
import 'package:owner/common/api/response/menu.dart';
import 'package:owner/common/api/response/owner/find_ownername_response.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/api/response/store/statistics_response.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/common/model/UsedGifticon.dart';
import 'package:owner/common/model/account_response.dart';
import 'package:owner/common/model/inquiry.dart';

/// mock 모드에서 Api().client 대신 사용.
/// 모든 메서드는 assets/mock/ fixture에서 데이터를 반환하고 네트워크 호출을 하지 않는다.
class MockApiClient implements ApiClient {
  Future<T> _load<T>(
      String asset, T Function(Map<String, dynamic>) parse) async {
    final str = await rootBundle.loadString(asset);
    return parse(jsonDecode(str) as Map<String, dynamic>);
  }

  // ── 로그인 / 오너 ─────────────────────────────────────────────────────────

  @override
  Future<OwnerLoginResponse> login(String uid) async =>
      OwnerLoginResponse(name: '김철수', phone_number: '010-1234-5678');

  @override
  Future<OwnerRegisterResponse> registerOwner(OwnerRegisterPost owner) async =>
      OwnerRegisterResponse(statusCode: 200, owner_id: 12345);

  @override
  Future<CheckDuplicateResponse> checkDuplicate({
    String? email,
    String? phoneNumber,
  }) async =>
      CheckDuplicateResponse(emailExists: false, phoneExists: false);

  @override
  Future<OwnerPushTokenResponse> registerOwnerPushToken(
    int ownerId,
    OwnerPushTokenPost pushToken,
  ) async =>
      OwnerPushTokenResponse(message: 'ok', owner_id: ownerId);

  @override
  Future<void> deleteOwnerPushToken(int ownerId, String fcmToken) async {}

  @override
  Future<FindOwnernameResponse> findOwnerId(OwnerFind ownerFind) async =>
      FindOwnernameResponse(statusCode: 200);

  @override
  Future<String> findOwnerPw(OwnerFindPw ownerFind) async => 'ok';

  // ── 매장 ──────────────────────────────────────────────────────────────────

  @override
  Future<StoreResponse> getStoreDetailInfo(int storeId) =>
      _load('assets/mock/store_detail.json', StoreResponse.fromJson);

  @override
  Future<StoreListResponse> getStoreList(int ownerId) =>
      _load('assets/mock/store_list.json', StoreListResponse.fromJson);

  @override
  Future<OwnerStoreList> getOwnerStoreList(int ownerId) async {
    final data =
        await _load('assets/mock/store_list.json', StoreListResponse.fromJson);
    final ownerStores = data.store
        .map((s) => OwnerStore(store_id: s.store_id, store_name: s.store_name))
        .toList();
    return OwnerStoreList(ownerStoreList: ownerStores);
  }

  @override
  Future<StorePostResponse> registerStore(Store store) async =>
      StorePostResponse(
        statusCode: 200,
        store_id: 1,
        store_logo_put_url: '',
        store_photos: [],
        bankBook_put_url: '',
      );

  @override
  Future<StoreUpdateResponse> updateStore(int menuId, Store store) async =>
      StoreUpdateResponse(
        statusCode: 200,
        msg: 'ok',
        store_photos: [],
        store_photo_get_urls: [],
      );

  @override
  Future<String> getStoreStatistics(int storeId) async {
    final data = await _load(
        'assets/mock/dashboard_stats.json', StoreStatisticsResponse.fromJson);
    return jsonEncode(data.toJson());
  }

  // ── 메뉴 ──────────────────────────────────────────────────────────────────

  @override
  Future<MenuGetResponse> getMenuList(int storeId) =>
      _load('assets/mock/menu_list.json', MenuGetResponse.fromJson);

  @override
  Future<MenuPostResponse> addMenu(int storeId, Menu menu) async =>
      MenuPostResponse(
          statusCode: 200, menu_id: 99, menu_put_url: '', menu_get_url: '');

  @override
  Future<MenuUpdateResponse> updateMenu(int menuId, Menu menu) async =>
      MenuUpdateResponse(
          statusCode: 200, msg: 'ok', menu_put_url: '', menu_get_url: '');

  @override
  Future<MenuDeleteResponse> deleteMenu(int menuId) async =>
      MenuDeleteResponse(statusCode: 200, msg: 'ok');

  // ── 기프티콘 ──────────────────────────────────────────────────────────────

  @override
  Future<GifticonPatchResponse> useGifticon(int gifticonId) async =>
      GifticonPatchResponse(result: 0);

  @override
  Future<UsedGifticonList> getUsedGifticon(int storeId) =>
      _load('assets/mock/used_gifticon_list.json', UsedGifticonList.fromJson);

  // ── 정산 ──────────────────────────────────────────────────────────────────

  @override
  Future<SettlementList> getSettlementListByStore(
          int storeId, int? pastMonths) =>
      _load('assets/mock/settlement_list.json', SettlementList.fromJson);

  @override
  Future<SettlementDetailResponse> getDetailSettlements(
      int settlementId) async {
    try {
      return await _load(
        'assets/mock/settlement_detail_$settlementId.json',
        SettlementDetailResponse.fromJson,
      );
    } catch (_) {
      return SettlementDetailResponse(settlement: SettlementSummary(), details: []);
    }
  }

  @override
  Future<SettlementDetailResponse> getSettlementPreview(int storeId) async {
    try {
      return await _load(
        'assets/mock/settlement_preview.json',
        SettlementDetailResponse.fromJson,
      );
    } catch (_) {
      return SettlementDetailResponse(settlement: SettlementSummary(), details: []);
    }
  }

  // ── 계좌 ──────────────────────────────────────────────────────────────────

  @override
  Future<GetAccountResponse> getAccount(int storeId) =>
      _load('assets/mock/account.json', GetAccountResponse.fromJson);

  @override
  Future<UpdateAccountResponse> updateAccount(
          int storeId, Account account) async =>
      UpdateAccountResponse();

  @override
  Future<String> registerAccount(int storeId, Account account) async => 'ok';

  // ── 약관 ──────────────────────────────────────────────────────────────────

  @override
  Future<TermsContentResponse> getTermsContent(String termType) async =>
      TermsContentResponse(
        content: '<p>($termType) 약관 내용입니다.</p>',
        termType: termType,
        version: '260101',
      );

  @override
  Future<TermsCurrentResponse> getTermsCurrent() async => TermsCurrentResponse(
        terms: [
          TermItem(termId: 1, termVersionId: 1, termType: 'SERVICE', title: '서비스 이용약관', required: true, version: '260101'),
          TermItem(termId: 2, termVersionId: 1, termType: 'FEE', title: '수수료 정책동의', required: true, version: '260101'),
          TermItem(termId: 3, termVersionId: 1, termType: 'PRIVACY', title: '개인정보 수집 및 이용동의', required: true, version: '260101'),
          TermItem(termId: 4, termVersionId: 1, termType: 'MARKETING', title: '마케팅 정보 수신 동의', required: false, version: '260101'),
        ],
      );

  @override
  Future<TermsAgreeResponse> postTermsAgree(TermsAgreeRequest request) async =>
      TermsAgreeResponse(success: true, message: 'ok', agreedCount: request.agreements.length);

  // ── 문의 ──────────────────────────────────────────────────────────────────

  @override
  Future<InquiryPostResponse> subjectInquiry(
          int ownerId, Inquiry inquiry) async =>
      InquiryPostResponse(statusCode: 200);

  @override
  Future<InquiryListResponse> getInquiry(int ownerId) async =>
      InquiryListResponse(inquiryResponse: []);

  @override
  Future<NoticeListResponse> getNoticeList(int page, int limit) async =>
      NoticeListResponse(
        message: '공지사항 목록 조회 성공',
        data: [
          NoticeItem(id: 1, title: '서비스 점검 안내', createdAt: '2026-07-01T10:00:00'),
          NoticeItem(id: 2, title: '앱 업데이트 안내', createdAt: '2026-06-15T09:00:00'),
        ],
        pagination: NoticePagination(total: 2, page: 1, limit: 20, totalPages: 1),
      );

  @override
  Future<NoticeDetailResponse> getNoticeDetail(int noticeId) async =>
      NoticeDetailResponse(
        message: '공지사항 상세 조회 성공',
        data: NoticeDetail(
          id: noticeId,
          title: '서비스 점검 안내',
          content: '7월 5일 새벽 2시~4시 점검 예정입니다.',
          createdAt: '2026-07-01T10:00:00',
          updatedAt: '2026-07-01T10:00:00',
        ),
      );

  @override
  Future<PopupListResponse> getPopups(int? ownerId) async =>
      PopupListResponse(message: '팝업 목록 조회 성공', data: []);

  @override
  Future<void> hidePopups(int? ownerId) async {}
}
