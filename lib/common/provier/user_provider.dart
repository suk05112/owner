import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/flavors.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user; // Nullable for better initialization handling

  User? get user => _user;

  // Constructor: Initialize UserProvider and load user from storage
  UserProvider() {
    if (F.isMock) {
      _loadMockUserFromAsset();
    } else {
      _loadUserFromStorage();
    }
  }

  /// mock 모드 전용: 스토리지 저장 없이 메모리에만 유저 세팅
  void setMockUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// Set the user and save it to storage
  Future<void> setUser(User user) async {
    _user = user;
    if (!F.isMock) {
      await _saveUserToStorage(user);
    }
    notifyListeners();
  }

  /// Fetch the user from secure storage (public method)
  Future<User?> fetchUser() async {
    if (F.isMock) {
      return _user;
    }
    return await _loadUserFromStorage();
  }

  Future<void> _loadMockUserFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/user.json');
      final userMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      _user = User(
        owner_id: userMap['owner_id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        phone_number: userMap['phone_number'] as String,
      );
      notifyListeners();
      print("Mock user loaded from asset.");
      print("${_user?.name}, ${_user?.email}, ${_user?.phone_number}");
    } catch (e) {
      print("Failed to load mock user from asset: $e");
    }
  }

  /// Save the user to secure storage (private method)
  Future<void> _saveUserToStorage(User user) async {
    print("${user.name}, ${user.email}, ${user.phone_number}");
    try {
      final userJson = jsonEncode({
        'owner_id': user.owner_id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone_number,
      });
      await _storage.write(key: "user", value: userJson);
      print("User saved to secure storage.");
    } catch (e) {
      print("Failed to save user to storage: $e");
    }
  }

  /// Load the user from secure storage (private method)
  Future<User?> _loadUserFromStorage() async {
    print("_loadUserFromStorage 호출됨");
    try {
      final userJson = await _storage.read(key: "user");
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _user = User(
          owner_id: userMap['owner_id'],
          name: userMap['name'],
          email: userMap['email'],
          phone_number: userMap['phone'],
        );
        notifyListeners();
        print("User loaded from secure storage.");
        print("${_user?.name}, ${_user?.email}, ${_user?.phone_number}");

        return _user;
      } else {
        print("No user data found in secure storage.");
        return null;
      }
    } catch (e) {
      print("Failed to load user from storage: $e");
      return null;
    }
  }

  /// Clear the user from secure storage
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: "user");
      _user = null;
      notifyListeners();
      print("User data cleared from storage.");
    } catch (e) {
      print("Failed to clear user data: $e");
    }
  }
}
