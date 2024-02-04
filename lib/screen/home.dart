import 'package:flutter/material.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/screen/Setting/setting_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';

import 'QRScanPage.dart';
import 'Store/cafe_detail_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String qrResult = '';

  int currentTab = 0;

  final List<Widget> screens = [
    Main(),
    CafeList(),
    CafeDetailScreen(
      storeId: 1,
    ),
    SettingPage()
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = CafeDetailScreen(
    storeId: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
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
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                        currentScreen = Main();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dashboard,
                            color: currentTab == 0 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            '홈',
                            style: TextStyle(
                              color:
                                  currentTab == 0 ? Colors.blue : Colors.grey,
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
                            Icons.dashboard,
                            color: currentTab == 1 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            '매장관리',
                            style: TextStyle(
                              color:
                                  currentTab == 1 ? Colors.blue : Colors.grey,
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
                        // currentScreen = CafeDetailScreen(
                        //   storeId: '0000001',
                        // );
                        currentTab = 2;
                      });
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: currentTab == 2 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            '주문관리',
                            style: TextStyle(
                              color:
                                  currentTab == 2 ? Colors.blue : Colors.grey,
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
                        currentScreen = SettingPage();
                        currentTab = 3;
                      });
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dashboard,
                            color: currentTab == 3 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            '설정',
                            style: TextStyle(
                              color:
                                  currentTab == 3 ? Colors.blue : Colors.grey,
                            ),
                          )
                        ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
