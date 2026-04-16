import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/model/user.dart';

class MockUserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  MockUserProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/user.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _user = User(
        owner_id: json['owner_id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone_number: json['phone_number'] as String,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("MockUserProvider: user.json 로드 실패: $e");
    }
  }

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<User?> fetchUser() async => _user;

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }
}
