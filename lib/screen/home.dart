import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/screen/Setting/setting_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:owner/screen/used_gifticon_page.dart';
import 'package:provider/provider.dart';

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
  Widget currentScreen = UsedGifticonPage(
    storeId: 1,
  );

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      UsedGifticonPage(
        storeId: 1,
      ),
      CafeList(),
      CafeDetailScreen(
        storeId: 1,
      ),
      SettingPage()
    ];
    return PopScope(
        canPop: false, // 뒤로 가기 방지
        child: Scaffold(
          body: PageStorage(bucket: bucket, child: currentScreen),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.qr_code),
            onPressed: () async {
              dynamic result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return QRCheckScreen(eventKeyword: 'userId');
              }));

              if (result != null) {
                setState(() {
                  //qr스캐너에서 받은 결과값을 화면의 qrResult 에 적용하도록 한다.
                  qrResult = result;

                  if (qrResult == 0) {
                    print("0 걸림");
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
            shape: CircularNotchedRectangle(),
            notchMargin: 10,
            child: Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentScreen = UsedGifticonPage(
                              storeId: 1,
                            );
                            currentTab = 0;
                          });
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home,
                                color:
                                    currentTab == 0 ? Colors.blue : Colors.grey,
                              ),
                              Text(
                                '홈',
                                style: TextStyle(
                                  color: currentTab == 0
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )
                            ]),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentScreen = CafeList();
                            currentTab = 1;
                          });
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list,
                                color:
                                    currentTab == 1 ? Colors.blue : Colors.grey,
                              ),
                              Text(
                                '매장관리',
                                style: TextStyle(
                                  color: currentTab == 1
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )
                            ]),
                      ),
                    ],
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
  Widget currentScreen = CafeDetailScreen(
    storeId: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '홈 화면',
        )
      ]),
    );
  }
}
