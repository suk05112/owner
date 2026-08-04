import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owner/flavors.dart';

import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/account_provider.dart';
import 'package:owner/common/provier/dashboard_stats_provider.dart';
import 'package:owner/common/provier/gifticon_provider.dart';
import 'package:owner/common/provier/selected_store_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/provier/mock_user_provider.dart';
import 'package:owner/common/provier/mock_auth_provider.dart';
import 'package:owner/common/provier/mock_store_provider.dart';
import 'package:owner/common/provier/mock_dashboard_stats_provider.dart';
import 'package:owner/common/provier/mock_account_provider.dart';
import 'package:owner/common/provier/mock_gifticon_provider.dart';
import 'package:owner/screen/home.dart';
import 'package:owner/screen/splash_screen.dart';
import 'package:owner/common/provier/store_provider.dart';
import 'screen/LoginPage.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/utils/network_utils.dart';
import 'package:owner/common/utils/version_compare.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/config.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  '주요 알림',
  description: '기프넛 오너 앱의 주요 알림입니다.',
  importance: Importance.high,
);

// 백그라운드/종료 상태에서 FCM 메시지 수신 (top-level 함수 필수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 메시지 수신: ${message.messageId}');

  final title = message.notification?.title ?? message.data['title'] as String?;
  final body = message.notification?.body ?? message.data['body'] as String?;
  if (title == null && body == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/owner_logo'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  await plugin.show(
    message.messageId.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/owner_logo',
      ),
    ),
  );
}

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureFlavor();
  print('최종 Flavor: ${F.appFlavor}');

  // 세로 모드만 허용 (가로 회전 방지)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase는 main_dev.dart 또는 main_prod.dart에서 이미 초기화됨
  // 여기서는 API만 초기화

  // API 초기화 - 환경에 맞는 baseUrl 설정
  await Api().setBaseClient(AppConfig.baseUrl);

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(const MyApp());
}

Future<void> initializeFCM() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 안드로이드 local notification 초기화
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  await _localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/owner_logo'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  final messaging = FirebaseMessaging.instance;

  // iOS/Android 알림 권한 요청
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('FCM 알림 권한 상태: ${settings.authorizationStatus}');

  // iOS 포그라운드에서도 배너/소리/배지 표시
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 포그라운드 메시지 수신 — 안드로이드는 local notification으로 직접 표시
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] as String?;
    final body = message.notification?.body ?? message.data['body'] as String?;
    print('포그라운드 메시지 수신: $title');
    if (title == null && body == null) return;

    _localNotifications.show(
      message.messageId.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/owner_logo',
        ),
      ),
    );
  });
}

Future<void> _ensureFlavor() async {
  final env =
      const String.fromEnvironment('ENV', defaultValue: '').toLowerCase();
  final envFlavor = _flavorFromString(env);
  if (envFlavor != null) {
    F.appFlavor = envFlavor;
  }

  // iOS MockDebug safety-net:
  // if app bundle/app name contains "mock", force mock flavor
  // even when the wrong entrypoint was selected.
  try {
    final info = await PackageInfo.fromPlatform();
    final marker = '${info.packageName} ${info.appName}'.toLowerCase();
    if (marker.contains('mock')) {
      F.appFlavor = Flavor.mock;
    }
  } catch (_) {
    // Keep already resolved flavor.
  }

  F.appFlavor ??= Flavor.prod;
}

Flavor? _flavorFromString(String value) {
  switch (value) {
    case 'dev':
      return Flavor.dev;
    case 'prod':
    case 'production':
      return Flavor.prod;
    case 'mock':
      return Flavor.mock;
    default:
      return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget _buildApp(BuildContext context, Widget home) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _NetworkFirstRunCheck(child: home),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => MockStoreProvider()),
            ChangeNotifierProvider(
                create: (context) => MockDashboardStatsProvider()),
            ChangeNotifierProvider(create: (context) => MockAccountProvider()),
            ChangeNotifierProvider(create: (context) => MockGifticonProvider()),
            ChangeNotifierProvider(create: (context) => StoreProvider()),
            ChangeNotifierProvider(
                create: (context) => SelectedStoreProvider()),
            ChangeNotifierProvider(
                create: (context) => DashboardStatsProvider()),
            ChangeNotifierProvider(create: (context) => GifticonProvider()),
            ChangeNotifierProvider(create: (context) => MockUserProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (context) => AccountProvider()),
          ],
          child: F.isMock
              ? _buildApp(context, const Home())
              : _AuthGate(buildApp: _buildApp),
        ));
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.buildApp});
  final Widget Function(BuildContext, Widget) buildApp;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  // null = 아직 확인 중, true = 로그인, false = 로그아웃
  bool? _isLoggedIn;
  bool _forceUpdateShown = false;
  final GlobalKey<NavigatorState> _splashNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shown = await _checkForceUpdate();
      if (!mounted) return;
      if (shown) {
        setState(() => _forceUpdateShown = true);
        return;
      }
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    });
  }

  /// 서버에 등록된 강제 업데이트 버전을 체크하고, 대상이면 다이얼로그를 띄운다.
  /// 다이얼로그를 띄운 경우(이후 로직 중단이 필요한 경우) true를 반환한다.
  Future<bool> _checkForceUpdate() async {
    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : null;
    if (platform == null) return false;

    try {
      final response = await Api().client.getAppVersion(platform, 'owner');
      if (response.version == null || !response.isForceUpdate) {
        return false;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      if (!isNewerVersion(response.version!, packageInfo.version)) {
        return false;
      }

      final dialogContext = _splashNavigatorKey.currentContext;
      if (dialogContext == null) return true;
      CommonDialog.show(
        context: dialogContext,
        title: '최신 버전 업데이트',
        content: '최신버전 앱으로 업데이트를 위해\n스토어로 이동합니다.',
        buttonText: '확인',
        cancel: false,
        preventPop: true,
        onPressed: () {
          _openStore(platform);
        },
      );
      return true;
    } catch (e) {
      print('[ForceUpdate] 체크 실패(무시): $e');
      return false;
    }
  }

  Future<void> _openStore(String platform) async {
    if (platform == 'android') {
      final marketUri = Uri.parse('market://details?id=com.gifnut.owner');
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(
        Uri.parse(
            'https://play.google.com/store/apps/details?id=com.gifnut.owner'),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    await launchUrl(
      Uri.parse('https://apps.apple.com/app/id6777555229'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 회원가입 또는 로그인 진행 중이면 authStateChanges 무시
    if (userProvider.isRegistering || userProvider.isLoggingIn) return;

    if (firebaseUser == null) {
      await userProvider.clearUser();
      if (mounted) {
        Provider.of<SelectedStoreProvider>(context, listen: false).invalidate();
        Provider.of<DashboardStatsProvider>(context, listen: false).clear();
        setState(() => _isLoggedIn = false);
      }
      return;
    }

    // 이메일 없는 전화번호 전용 계정 → 로그아웃
    if (firebaseUser.email == null) {
      try { await FirebaseAuth.instance.signOut(); } catch (_) {}
      await userProvider.clearUser();
      if (mounted) {
        Provider.of<SelectedStoreProvider>(context, listen: false).invalidate();
        Provider.of<DashboardStatsProvider>(context, listen: false).clear();
        setState(() => _isLoggedIn = false);
      }
      return;
    }

    // 정상 계정 → SecureStorage 프로필 로드
    await userProvider.loadProfileIfSignedIn();
    if (!mounted) return;

    if (userProvider.user == null) {
      await FirebaseAuth.instance.signOut();
      setState(() => _isLoggedIn = false);
    } else {
      Api().client.ping(userProvider.user!.owner_id).catchError((e) {
        print('ping 실패 (무시): $e');
      });
      setState(() => _isLoggedIn = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_forceUpdateShown || _isLoggedIn == null) {
      return MaterialApp(
        navigatorKey: _splashNavigatorKey,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
    return widget.buildApp(
      context,
      _isLoggedIn! ? const Home() : const LoginScreen(),
    );
  }
}

/// 앱 최초 진입 시 인터넷 미연결이면 안내 다이얼로그 표시 (공통 모듈 사용)
class _NetworkFirstRunCheck extends StatefulWidget {
  const _NetworkFirstRunCheck({required this.child});
  final Widget child;

  @override
  State<_NetworkFirstRunCheck> createState() => _NetworkFirstRunCheckState();
}

class _NetworkFirstRunCheckState extends State<_NetworkFirstRunCheck> {
  @override
  void initState() {
    super.initState();
    if (!F.isMock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NetworkUtils.checkOnFirstLaunchAndShowDialogIfOffline(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final firestore = FirebaseFirestore.instance;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                // getData();
                // Navigator.pushNamed(context, '/edit');

                // Navigator.push(
                //     context,
                // MaterialPageRoute(builder: (context) => CafeList()));
                // MaterialPageRoute(builder: (context) => EmployeeScreen()));
              },
              child: const Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
