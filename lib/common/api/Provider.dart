import 'package:http/http.dart' as http;
import 'package:owner/common/StatusManager.dart';
import 'dart:convert';
import 'package:owner/common/model/request/OwnerPost.dart';

class Provider {
  String url =
      'https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging/owner/register';

  OwnerPost post = OwnerPost();
  postRequest(OwnerPost owner) async {
    http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{"Content-Type": "application/json"},
        body: jsonEncode(owner.toJson()));
    if (response.statusCode == 200) {
      print("post response");
      print(response.statusCode);
      print(jsonDecode(response.body));

      print(jsonDecode(response.body)['owner_id']);
    } else {
      print("제대로 못읽어옴");
      print(response.body);
    }
  }

  loginOwner(String uid) async {
    Uri uri = Uri.parse(
        "https://ot113tt778.execute-api.us-east-2.amazonaws.com/staging/owner/login");

    final body = {"uid": uid};

    final response = await http.post(uri,
        headers: <String, String>{"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      print("post response");
      print(response.statusCode);
      print(jsonDecode(response.body));
    } else {
      print("제대로 못읽어옴");
      print(response.body);
    }

    int ownerId = jsonDecode(response.body)['owner_id'];
    StatusManager().ownerId = ownerId;

    // return ownerId;
  }
}
