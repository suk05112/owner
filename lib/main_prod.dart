import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import 'flavors.dart';
import 'firebase_options_prod.dart';

import 'main.dart' as runner;
import 'main.dart' show initializeFCM;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.prod;
  print("설정된 환경 ${F.title}");

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

  if (kDebugMode) {
    FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider:
            ReCaptchaV3Provider("6LeuC04sAAAAALXiv1CX_UsbOj1Vpo1zR1DAvd8d"));
  } else {
    FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
        webProvider:
            ReCaptchaV3Provider("6LeuC04sAAAAALXiv1CX_UsbOj1Vpo1zR1DAvd8d"));
  }
  await initializeFCM();
  await runner.main();
}
