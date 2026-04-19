import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'flavors.dart';
import 'firebase_options_mock.dart';

import 'main.dart' as runner;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.mock;
  print("설정된 환경 ${F.appFlavor}");

  // Firebase가 이미 초기화되지 않은 경우에만 초기화
  // 특정 이름으로 초기화하여 중복 방지
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 완료');
  } catch (e) {
    // 이미 초기화된 경우 무시
    if (e.toString().contains('duplicate-app') ||
        e.toString().contains('[core/duplicate-app]')) {
      print('✅ Firebase 이미 초기화됨 (중복 무시)');
    } else {
      print('⚠️ Firebase 초기화 오류: $e');
      rethrow;
    }
  }

  // Mock mode: Skip Firebase App Check and use mock data
  print('✅ Firebase App Check 비활성화 (Mock 모드)');
  print('✅ Mock 데이터 사용 및 로그인 우회 활성화');

  // runner.main()을 호출하여 앱 실행
  // runApp()은 즉시 반환되지만 await를 사용하여 초기화가 완료되도록 보장
  await runner.main();
}
