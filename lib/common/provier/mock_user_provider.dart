import 'package:flutter/foundation.dart';
import 'package:owner/common/model/user.dart';

class MockUserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isMock => true;

  MockUserProvider() {
    // Initialize with mock user data
    _user = User(
      owner_id: 12345,
      name: 'Mock Store Owner',
      email: 'mock@example.com',
      phone_number: '010-1234-5678',
    );
  }

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<User?> fetchUser() async {
    return _user;
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }
}