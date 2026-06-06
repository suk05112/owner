import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/flavors.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;
  bool _profileLoaded = false;
  bool _profileLoading = false;
  bool _isRegistering = false;
  bool _isLoggingIn = false;

  User? get user => _user;
  bool get profileLoaded => _profileLoaded;

  /// 회원가입 진행 중 플래그 — true이면 main.dart의 강제 로그아웃을 건너뜀
  bool get isRegistering => _isRegistering;
  set isRegistering(bool value) {
    _isRegistering = value;
    notifyListeners();
  }

  /// 로그인 진행 중 플래그 — true이면 main.dart의 강제 로그아웃을 건너뜀
  bool get isLoggingIn => _isLoggingIn;
  set isLoggingIn(bool value) {
    _isLoggingIn = value;
    notifyListeners();
  }

  UserProvider() {
    if (F.isMock) {
      _loadMockUserFromAsset();
    }
    // real 모드에서는 authStateChanges()가 세션을 관리하므로 여기서 로드하지 않음
    // loadProfileIfSignedIn()은 main.dart의 StreamBuilder에서 호출됨
  }

  /// Firebase 세션이 살아있을 때 SecureStorage에서 프로필을 복원
  Future<void> loadProfileIfSignedIn() async {
    if (F.isMock) return;
    if (_profileLoading || _profileLoaded) return; // 중복 호출 방지
    _profileLoading = true;
    await _loadUserFromStorage();
    _profileLoading = false;
    _profileLoaded = true;
    notifyListeners();
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
    } catch (e) {
    }
  }

  /// Save the user to secure storage (private method)
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userJson = jsonEncode({
        'owner_id': user.owner_id,
        'name': user.name,
        'login_id': user.login_id,
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
          login_id: userMap['login_id'],
          email: userMap['email'],
          phone_number: userMap['phone'],
        );
        notifyListeners();

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
      _profileLoaded = false;
      _profileLoading = false;
      notifyListeners();
      print("User data cleared from storage.");
    } catch (e) {
      print("Failed to clear user data: $e");
    }
  }
}
