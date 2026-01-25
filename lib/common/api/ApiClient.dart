import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/menu.dart';
import 'package:owner/common/api/response/owner/find_ownername_response.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/api/response/store/statistics_response.dart';
import 'package:owner/common/model/Account.dart';
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

  @POST("/owner/push-token/{owner_id}")
  Future<OwnerPushTokenResponse> registerOwnerPushToken(
    @Path('owner_id') int owner_id,
    @Body() OwnerPushTokenPost pushToken,
  );

  @GET("/store/info/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int store_Id,
    // @Query("owner_id") int owner_id,
  );

  @GET("/owner/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int owner_id,
  );

  @POST("/store/register")
  Future<StorePostResponse> registerStore(
    @Body() Store store,
  );

  @POST("/store/update/{menu_id}")
  Future<StoreUpdateResponse> updateStore(
    @Path('menu_id') int menu_id,
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
    @Path('store_Id') int store_Id,
  );

  @POST("/menu/add/{store_id}")
  Future<MenuPostResponse> addMenu(
    @Path('store_id') int store_id,
    @Body() Menu menu,
  );

  @POST("/menu/update/{menu_id}")
  Future<MenuUpdateResponse> updateMenu(
    @Path('menu_id') int menu_id,
    @Body() Menu menu,
  );

  @DELETE("/menu/delete/{menu_id}")
  Future<MenuDeleteResponse> deleteMenu(
    @Path('menu_id') int menu_id,
  );

  @PATCH("/gifticon/use/{gifticon_id}")
  Future<GifticonPatchResponse> useGifticon(
    @Path('gifticon_id') int gifticon_id,
  );

  @POST("/owner/inquiry/{owner_id}")
  Future<InquiryPostResponse> subjectInquiry(
    @Path('owner_id') int owner_id,
    @Body() Inquiry inquiry,
  );

  @GET("/owner/inquiry/{owner_id}")
  Future<InquiryListResponse> getInquiry(
    @Path('owner_id') int owner_id,
  );

  @GET("/settlement/list/{store_id}")
  Future<SettlementList> getSettlementListByStore(
    @Path('store_id') int store_id,
  );

  @GET("/settlement/detail/{settlement_id}")
  Future<DetailSettlementList> getDetailSettlements(
    @Path('settlement_id') int settlement_id,
  );

  @POST("/settlement/register/{store_id}")
  Future<String> registerAccount(
    @Path('store_id') int store_id,
    @Body() Account account,
  );

  @GET("/gifticon/used/{store_id}")
  Future<UsedGifticonList> getUsedGifticon(
    @Path('store_id') int store_id,
  );

  @GET("/store/owner/list/{owner_id}")
  Future<OwnerStoreList> getOwnerStoreList(
    @Path('owner_id') int owner_id,
  );

  @GET("/statistics/{store_id}")
  Future<StoreStatisticsResponse> getStoreStatistics(
    @Path('store_id') int store_id,
  );
}
