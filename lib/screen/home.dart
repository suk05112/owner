import 'package:flutter/material.dart';
import 'package:owner/common/provier/dashboard_stats_provider.dart';
import 'package:owner/common/provier/mock_dashboard_stats_provider.dart';
import 'package:owner/common/provier/selected_store_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/flavors.dart';
import 'package:owner/screen/Setting/setting_page.dart';
import 'package:owner/screen/dashboard_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';

import 'QRScanPage.dart';
import 'Store/cafe_detail_page.dart';

import 'package:owner/common/model/user.dart' as my_app;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int qrResult = -1;

  int currentTab = 0;

  my_app.User? user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user ??= Provider.of<UserProvider>(context, listen: false).user;
  }

  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen;

  @override
  void initState() {
    super.initState();
    // 대시보드 페이지를 기본 화면으로 설정 (매장관리는 push로 이동해 네비 바 숨김)
    currentScreen = DashboardPage(
      onNavigateToStoreManagement: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CafeList()),
        );
      },
    );

    if (!F.isMock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _retryPushTokenIfNeeded();
        _listenTokenRefresh();
      });
    }
  }

  Future<void> _retryPushTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    final savedToken = prefs.getString('registered_fcm_token');
    if (savedToken == fcmToken) return;

    if (!mounted) return;
    final ownerId = Provider.of<UserProvider>(context, listen: false).user?.owner_id;
    if (ownerId == null) return;

    await _registerPushToken(ownerId, fcmToken, prefs);
  }

  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final ownerId = Provider.of<UserProvider>(context, listen: false).user?.owner_id;
      if (ownerId == null) return;
      await _registerPushToken(ownerId, newToken, prefs);
    });
  }

  Future<void> _registerPushToken(int ownerId, String fcmToken, SharedPreferences prefs) async {
    try {
      final deviceType = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await Api().client.registerOwnerPushToken(
            ownerId,
            OwnerPushTokenPost(fcm_token: fcmToken, device_type: deviceType),
          );
      await prefs.setString('registered_fcm_token', fcmToken);
      print('Push token 등록 성공');
    } catch (e) {
      print('Push token 등록 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // 뒤로 가기 방지
        child: Scaffold(
          body: PageStorage(bucket: bucket, child: currentScreen),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFF27213),
            child: const Icon(Icons.qr_code, color: Colors.white),
            onPressed: () async {
              dynamic result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return QRCheckScreen(eventKeyword: 'userId');
              }));

              if (result != null) {
                setState(() {
                  qrResult = result;

                  if (qrResult == 0) {
                    print("0 걸림");
                    // QR로 기프티콘 사용 완료 시에만 통계 갱신
                    final storeProvider = Provider.of<SelectedStoreProvider>(context, listen: false);
                    final storeId = storeProvider.selectedStoreId;
                    if (storeId != null) {
                      if (F.isMock) {
                        Provider.of<MockDashboardStatsProvider>(context, listen: false).refreshStats(storeId);
                      } else {
                        Provider.of<DashboardStatsProvider>(context, listen: false).refreshStats(storeId);
                      }
                    }
                    CommonDialog.show(
                        context: context,
                        title: "사용 완료",
                        content: "기프티콘 사용이 완료되었습니다.",
                        buttonText: "확인",
                        onPressed: () {});
                  } else if (qrResult == 1) {
                    print("1 걸림");

                    CommonDialog.show(
                        context: context,
                        title: "사용 실패",
                        content: "이미 사용된 기프티콘입니다.",
                        buttonText: "확인",
                        onPressed: () {});
                  } else if (qrResult == 2) {
                    print("2 걸림");

                    CommonDialog.show(
                        context: context,
                        title: "사용 실패",
                        content: "기간이 만료된 기프티콘입니다.",
                        buttonText: "확인",
                        onPressed: () {});
                  } else if (qrResult == -1) {
                    print("2 걸림");

                    CommonDialog.show(
                        context: context,
                        title: "사용 실패",
                        content: "매장의 기프티콘이 아닙니다.",
                        buttonText: "확인",
                        onPressed: () {});
                  } else {
                    print("else 걸림");

                    CommonDialog.show(
                        context: context,
                        title: "사용 실패",
                        content: "서비스 오류:: 잠시 후 다시 시도해주세요.",
                        buttonText: "확인",
                        onPressed: () {});
                  }
                });
              }
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFFF5F5F5),
            elevation: 0,
            notchMargin: 10,
            shape: const CircularNotchedRectangle(),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      minWidth: 0,
                      onPressed: () {
                        setState(() {
                          currentScreen = DashboardPage(
                            onNavigateToStoreManagement: (context) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CafeList()),
                              );
                            },
                          );
                          currentTab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            color: currentTab == 0
                                ? const Color(0xFFF27213)
                                : const Color(0xFF808080),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '홈',
                            style: TextStyle(
                              color: currentTab == 0
                                  ? const Color(0xFFF27213)
                                  : const Color(0xFF808080),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 0),
                  Expanded(
                    child: MaterialButton(
                      minWidth: 0,
                      onPressed: () {
                        setState(() {
                          currentScreen = const SettingPage();
                          currentTab = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.more_horiz,
                            color: currentTab == 1
                                ? const Color(0xFFF27213)
                                : const Color(0xFF808080),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '더보기',
                            style: TextStyle(
                              color: currentTab == 1
                                  ? const Color(0xFFF27213)
                                  : const Color(0xFF808080),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  /*
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() async {
                            dynamic result = await Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return QRCheckScreen(eventKeyword: 'userId');
                            }));

                            if (result != null) {
                              setState(() {
                                //qr스캐너에서 받은 결과값을 화면의 qrResult 에 적용하도록 한다.
                                qrResult = result.toString();
                              });
                            }
                          });
                          currentTab = 2;
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code,
                                color:
                                    currentTab == 2 ? Colors.blue : Colors.grey,
                              ),
                              Text(
                                '스캔',
                                style: TextStyle(
                                  color: currentTab == 2
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )
                            ]),
                      ),
                    ],
                  ),
                  */
                  /*
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentScreen = SettingPage();
                            currentTab = 3;
                          });
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                color:
                                    currentTab == 3 ? Colors.blue : Colors.grey,
                              ),
                              Text(
                                '설정',
                                style: TextStyle(
                                  color: currentTab == 3
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )
                            ]),
                      ),
                    ],
                  ),

                  */
                ],
              ),
            ),
          ),
        ));
  }

  //비동기 함수
  // Future _scan() async {
  //   //스캔 시작 - 이때 스캔 될때까지 blocking
  //   String barcode = await scanner.scan();
  //   //스캔 완료하면 _output 에 문자열 저장하면서 상태 변경 요청.
  //   setState(() => _output = barcode);
  // }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  String qrResult = '';

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const CafeDetailScreen(
    storeId: 1,
  );

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '홈 화면',
        )
      ]),
    );
  }
}
