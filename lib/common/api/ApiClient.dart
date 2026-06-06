import 'dart:convert';

import 'package:owner/common/api/request/owner/owner.dart';
export 'package:owner/common/api/request/owner/owner.dart' show CheckDuplicateResponse;
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/menu.dart';
import 'package:owner/common/api/response/owner/find_ownername_response.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/api/response/store/statistics_response.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/model/account_response.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/common/model/UsedGifticon.dart';
import 'package:owner/common/api/response/GifticonResponse.dart';
import 'package:owner/common/model/inquiry.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'ApiClient.g.dart';

// @RestApi(baseUrl: AppConfig.baseUrl)
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/owner/login/{uid}")
  Future<OwnerLoginResponse> login(
    @Path('uid') String uid,
  );

  @POST("/owner/register")
  Future<OwnerRegisterResponse> registerOwner(
    @Body() OwnerRegisterPost owner,
  );

  @GET("/owner/check-duplicate")
  Future<CheckDuplicateResponse> checkDuplicate({
    @Query('email') String? email,
    @Query('phone_number') String? phoneNumber,
  });

  @POST("/owner/push-token/{owner_id}")
  Future<OwnerPushTokenResponse> registerOwnerPushToken(
    @Path('owner_id') int ownerId,
    @Body() OwnerPushTokenPost pushToken,
  );

  @DELETE("/owner/push-token/{owner_id}")
  Future<void> deleteOwnerPushToken(
    @Path('owner_id') int ownerId,
    @Header('X-FCM-Token') String fcmToken,
  );

  @GET("/store/info/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int storeId,
    // @Query("owner_id") int owner_id,
  );

  @GET("/owner/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int ownerId,
  );

  @POST("/store/register")
  Future<StorePostResponse> registerStore(
    @Body() Store store,
  );

  @POST("/store/update/{menu_id}")
  Future<StoreUpdateResponse> updateStore(
    @Path('menu_id') int menuId,
    @Body() Store store,
  );

  @POST("/owner/find_ownerId")
  Future<FindOwnernameResponse> findOwnerId(
    @Body() OwnerFind ownerFind,
  );

  @POST("/owner/find_ownerPw")
  Future<String> findOwnerPw(
    @Body() OwnerFindPw ownerFind,
  );

  @GET("/menu/list/{store_Id}")
  Future<MenuGetResponse> getMenuList(
    @Path('store_Id') int storeId,
  );

  @POST("/menu/add/{store_id}")
  Future<MenuPostResponse> addMenu(
    @Path('store_id') int storeId,
    @Body() Menu menu,
  );

  @POST("/menu/update/{menu_id}")
  Future<MenuUpdateResponse> updateMenu(
    @Path('menu_id') int menuId,
    @Body() Menu menu,
  );

  @DELETE("/menu/delete/{menu_id}")
  Future<MenuDeleteResponse> deleteMenu(
    @Path('menu_id') int menuId,
  );

  @PATCH("/gifticon/use/{gifticon_id}")
  Future<GifticonPatchResponse> useGifticon(
    @Path('gifticon_id') int gifticonId,
  );

  @POST("/owner/inquiry/{owner_id}")
  Future<InquiryPostResponse> subjectInquiry(
    @Path('owner_id') int ownerId,
    @Body() Inquiry inquiry,
  );

  @GET("/owner/inquiry/{owner_id}")
  Future<InquiryListResponse> getInquiry(
    @Path('owner_id') int ownerId,
  );

  @GET("/owner/settlement/{store_id}")
  Future<SettlementList> getSettlementListByStore(
    @Path('store_id') int storeId,
    @Query('past_months') int? pastMonths,
  );

  @GET("/owner/settlement/detail/{settlement_id}")
  Future<SettlementDetailResponse> getDetailSettlements(
    @Path('settlement_id') int settlementId,
  );

  @GET("/owner/settlement/preview/{store_id}")
  Future<SettlementDetailResponse> getSettlementPreview(
    @Path('store_id') int storeId,
  );

  @POST("/settlement/register/{store_id}")
  Future<String> registerAccount(
    @Path('store_id') int storeId,
    @Body() Account account,
  );

  @GET("/gifticon/used/{store_id}")
  Future<UsedGifticonList> getUsedGifticon(
    @Path('store_id') int storeId,
  );

  @GET("/store/owner/list/{owner_id}")
  Future<OwnerStoreList> getOwnerStoreList(
    @Path('owner_id') int ownerId,
  );

  @GET("/owner/statistics/{store_id}")
  Future<String> getStoreStatistics(
    @Path('store_id') int storeId,
  );

  @GET("/owner/account/{store_id}")
  Future<GetAccountResponse> getAccount(
    @Path('store_id') int storeId,
  );

  @PUT("/owner/account/{store_id}")
  Future<UpdateAccountResponse> updateAccount(
    @Path('store_id') int storeId,
    @Body() Account account,
  );

  @GET("/owner/terms/content")
  Future<TermsContentResponse> getTermsContent(
    @Query('term_type') String termType,
  );
}

/// PUT /owner/account/{store_id} 응답 — 통장사본 있을 때 bank_book_put_url(S3 presigned) 반환
class UpdateAccountResponse {
  final String? bank_book_put_url;

  UpdateAccountResponse({this.bank_book_put_url});

  factory UpdateAccountResponse.fromJson(dynamic json) {
    if (json == null) return UpdateAccountResponse();
    Map<String, dynamic>? map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map) {
      map = Map<String, dynamic>.from(json);
    } else if (json is String) {
      try {
        map = jsonDecode(json) as Map<String, dynamic>?;
      } catch (_) {
        return UpdateAccountResponse();
      }
    }
    if (map == null) return UpdateAccountResponse();
    final url = map['bank_book_put_url'] as String? ??
        map['bankBookPutUrl'] as String? ??
        _fromNested(map, 'bank_book_put_url') ??
        _fromNested(map, 'bankBookPutUrl');
    return UpdateAccountResponse(bank_book_put_url: url);
  }

  static String? _fromNested(Map<String, dynamic> json, String key) {
    final data = json['data'];
    if (data is Map) return data[key] as String?;
    return null;
  }
}

class TermsContentResponse {
  final String content;
  final String termType;
  final String version;

  TermsContentResponse({
    required this.content,
    required this.termType,
    required this.version,
  });

  factory TermsContentResponse.fromJson(Map<String, dynamic> json) {
    return TermsContentResponse(
      content: json['content'] as String? ?? '',
      termType: json['term_type'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }
}
