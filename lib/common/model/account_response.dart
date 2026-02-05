import 'package:owner/common/model/Account.dart';

/// GET /owner/account/{store_id} 응답
class GetAccountResponse {
  final Account? account;

  GetAccountResponse({this.account});

  factory GetAccountResponse.fromJson(Map<String, dynamic> json) {
    final a = json['account'];
    if (a == null) return GetAccountResponse(account: null);
    if (a is Map && a.isEmpty)
      return GetAccountResponse(account: null);
    return GetAccountResponse(
      account: Account.fromJson(Map<String, dynamic>.from(a as Map)),
    );
  }
}
