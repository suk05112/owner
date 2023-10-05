import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/api/response/menu.dart';
import 'package:owner/common/api/response/owner/find_ownername_response.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'ApiClient.g.dart';

@RestApi(
    baseUrl: "https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/store/{store_Id}")
  Future<StoreResponse> getStoreDetailInfo(
    @Path('store_Id') int store_Id,
    // @Query("owner_id") int owner_id,
  );

  @GET("/store/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int owner_id,
  );

  @POST("/store/")
  Future<StorePostResponse> registerStore(
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
}
