import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/menu.dart';
import 'package:owner/common/api/response/owner/find_ownername_response.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/common/api/response/GifticonResponse.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'ApiClient.g.dart';

@RestApi(baseUrl: "http://18.221.2.135")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/store/info/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int store_Id,
    // @Query("owner_id") int owner_id,
  );

  @GET("/store/list/{owner_id}")
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

  @POST("owner/find_username")
  Future<FindOwnernameResponse> findOwnername(
    @Body() String uid,
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
}
