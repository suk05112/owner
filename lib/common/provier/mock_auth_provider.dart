import 'package:flutter/foundation.dart';
import 'package:owner/common/model/user.dart';

class MockAuthProvider {
  static final MockAuthProvider instance = MockAuthProvider._internal();

  factory MockAuthProvider() => instance;
  MockAuthProvider._internal() {
    print('Mock auth singleton created');
  }

  String? errorMessage;

  Future<User> login(String email, String password) async {
    // Mock login: accept any credentials
    print('Mock login start - accepting any credentials');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock user
    final mockUser = User(
      owner_id: 12345,
      name: '김철수',
      email: email.isNotEmpty ? email : 'chulsu@gifnut.com',
      phone_number: '010-1234-5678',
    );

    print('Mock login success');
    return mockUser;
  }

  Future<User?> autoLogin(String refreshToken) async {
    // Mock auto-login: always return mock user
    print('Mock auto login start');

    await Future.delayed(const Duration(milliseconds: 300));

    final mockUser = User(
      owner_id: 12345,
      name: '김철수',
      email: 'mock@example.com',
      phone_number: '010-1234-5678',
    );

    print('Mock auto login success');
    return mockUser;
  }

  Future<void> logout() async {
    print('Mock logout start');
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock logout success');
  }

  void clearPreference() {
    // No-op for mock
    print('Mock clear preference');
  }
}
