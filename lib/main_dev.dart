import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'flavors.dart';
import 'firebase_options_dev.dart';

import 'main.dart' as runner;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.dev;
  print("설정된 환경 ${F.appFlavor}");

  // Firebase가 이미 초기화되지 않은 경우에만 초기화
  // 특정 이름으로 초기화하여 중복 방지
  try {
    await Firebase.initializeApp(
      name: 'Cafe_Owner',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 완료');
  } catch (e) {
    // 이미 초기화된 경우 무시
    if (e.toString().contains('duplicate-app')) {
      print('✅ Firebase 이미 초기화됨 (중복 무시)');
    } else {
      print('⚠️ Firebase 초기화 오류: $e');
      rethrow;
    }
  }

  try {
    // Debug 모드에서는 App Check를 선택적으로 활성화
    // Firebase Console에서 Debug 토큰이 등록되지 않은 경우 실패할 수 있음
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider:
          ReCaptchaV3Provider("6LeuC04sAAAAALXiv1CX_UsbOj1Vpo1zR1DAvd8d"),
    );
    print('✅ Firebase App Check 활성화 완료');

    // 토큰 가져오기는 백그라운드에서 시도 (실패해도 계속 진행)
    // 실제로 토큰이 필요할 때만 가져오도록 API 호출 시점에 처리
    Future.delayed(Duration(seconds: 3), () async {
      try {
        final token = await FirebaseAppCheck.instance.getToken();
        if (token != null) {
          print('🔥 Firebase App Check Token 획득 성공');
        }
      } catch (e) {
        // 개발 모드에서는 토큰 획득 실패를 무시
        // Firebase Console에 Debug 토큰이 등록되어 있지 않으면 실패할 수 있음
        print('⚠️ Firebase App Check Token 획득 실패 (무시 가능): $e');
      }
    });
  } catch (e) {
    // App Check 활성화 실패 시에도 앱은 계속 실행
    // 개발 모드에서는 이 에러를 무시해도 됩니다
    print('⚠️ Firebase App Check 활성화 실패 (무시 가능): $e');
    print('💡 개발 모드에서는 App Check 없이도 정상 동작합니다.');
  }

  // runner.main()을 호출하여 앱 실행
  // runApp()은 즉시 반환되지만 await를 사용하여 초기화가 완료되도록 보장
  await runner.main();
}
