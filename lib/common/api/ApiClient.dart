import 'package:owner/common/api/request/store/register_store_post.dart';
import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/api/response/store/store_post_response.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'ApiClient.g.dart';

@RestApi(
    baseUrl: "https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/store/{owner_id}")
  Future<StoreListResponse> getStoreDetailInfo(
    @Path('owner_id') int owner_id,
    // @Query("owner_id") int owner_id,
  );

  @GET("/store/list/{owner_id}")
  Future<StoreListResponse> getStoreList(
    @Path('owner_id') int owner_id,
  );

  @POST("/store/")
  Future<StorePostResponse> registerStore(
    @Body() RegisterStorePost store,
  );
}
