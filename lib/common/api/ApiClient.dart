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

  @GET("/owner/notice")
  Future<NoticeListResponse> getNoticeList(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET("/owner/notice/{notice_id}")
  Future<NoticeDetailResponse> getNoticeDetail(
    @Path('notice_id') int noticeId,
  );

  @GET("/owner/terms/content")
  Future<TermsContentResponse> getTermsContent(
    @Query('term_type') String termType,
  );

  @GET("/owner/terms/current")
  Future<TermsCurrentResponse> getTermsCurrent();

  @POST("/owner/terms/agree")
  Future<TermsAgreeResponse> postTermsAgree(@Body() TermsAgreeRequest request);

  @GET("/owner/popups")
  Future<PopupListResponse> getPopups(
    @Query('owner_id') int? ownerId,
  );

  @POST("/owner/popups/hide")
  Future<void> hidePopups(
    @Query('owner_id') int? ownerId,
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

class TermItem {
  final int termId;
  final int termVersionId;
  final String termType;
  final String title;
  final bool required;
  final String version;

  TermItem({
    required this.termId,
    required this.termVersionId,
    required this.termType,
    required this.title,
    required this.required,
    required this.version,
  });

  factory TermItem.fromJson(Map<String, dynamic> json) {
    return TermItem(
      termId: json['term_id'] as int,
      termVersionId: json['term_version_id'] as int,
      termType: json['term_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      version: json['version'] as String? ?? '',
    );
  }
}

class TermsCurrentResponse {
  final List<TermItem> terms;

  TermsCurrentResponse({required this.terms});

  factory TermsCurrentResponse.fromJson(Map<String, dynamic> json) {
    final list = json['terms'] as List<dynamic>? ?? [];
    return TermsCurrentResponse(
      terms: list.map((e) => TermItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class TermAgreementItem {
  final int termId;
  final int termVersionId;
  final bool agreed;

  TermAgreementItem({
    required this.termId,
    required this.termVersionId,
    required this.agreed,
  });

  Map<String, dynamic> toJson() => {
        'term_id': termId,
        'term_version_id': termVersionId,
        'agreed': agreed,
      };
}

class TermsAgreeRequest {
  final int ownerId;
  final List<TermAgreementItem> agreements;

  TermsAgreeRequest({
    required this.ownerId,
    required this.agreements,
  });

  Map<String, dynamic> toJson() => {
        'owner_id': ownerId,
        'agreements': agreements.map((e) => e.toJson()).toList(),
      };
}

class TermsAgreeResponse {
  final bool success;
  final String message;
  final int agreedCount;

  TermsAgreeResponse({
    required this.success,
    required this.message,
    required this.agreedCount,
  });

  factory TermsAgreeResponse.fromJson(Map<String, dynamic> json) {
    return TermsAgreeResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      agreedCount: json['agreed_count'] as int? ?? 0,
    );
  }
}

class NoticeItem {
  final int id;
  final String title;
  final String createdAt;

  NoticeItem({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class NoticePagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  NoticePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NoticePagination.fromJson(Map<String, dynamic> json) {
    return NoticePagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

class NoticeListResponse {
  final String message;
  final List<NoticeItem> data;
  final NoticePagination pagination;

  NoticeListResponse({
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory NoticeListResponse.fromJson(Map<String, dynamic> json) {
    return NoticeListResponse(
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => NoticeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: NoticePagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class NoticeDetailResponse {
  final String message;
  final NoticeDetail data;

  NoticeDetailResponse({
    required this.message,
    required this.data,
  });

  factory NoticeDetailResponse.fromJson(Map<String, dynamic> json) {
    return NoticeDetailResponse(
      message: json['message'] as String? ?? '',
      data: NoticeDetail.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class NoticeDetail {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  NoticeDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeDetail.fromJson(Map<String, dynamic> json) {
    return NoticeDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class PopupItem {
  final int id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final int displayOrder;

  PopupItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    required this.displayOrder,
  });

  factory PopupItem.fromJson(Map<String, dynamic> json) {
    return PopupItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      linkUrl: json['link_url'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

class PopupListResponse {
  final String message;
  final List<PopupItem> data;

  PopupListResponse({
    required this.message,
    required this.data,
  });

  factory PopupListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => PopupItem.fromJson(e as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return PopupListResponse(
      message: json['message'] as String? ?? '',
      data: items,
    );
  }
}
