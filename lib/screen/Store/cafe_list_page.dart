import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonWidget.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/screen/Register/DocumentGuidePage.dart';
import 'package:owner/screen/Register/SingUpCompletePage.dart';
import 'package:owner/screen/Setting/setting_page.dart';

import '../../common/api/request/store/store.dart';
import '../../common/model/CafeBasicInfo.dart';
import '../../common/provier/store_provider.dart';
import '../Register/DocumentInputPage.dart';
import 'cafe_detail_page.dart';
import 'package:owner/common/model/user.dart' as my_app;

import 'package:provider/provider.dart';

void main() {
  runApp(const CafeList());
}

class CafeList extends StatefulWidget {
  const CafeList({Key? key}) : super(key: key);

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<CafeBasicInfo>>? cafeList;
  List<Store>? storeList;
  my_app.User? user;
  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;

    Provider.of<StoreProvider>(context, listen: false)
        .fetchStoreList(user?.owner_id ?? 0);

    print("init state:: StoreProvider.fetchStoreList 호출 후 ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 매장관리"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          List<Store> storeList = storeProvider.storeCards ?? [];
          return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  Provider.of<StoreProvider>(context, listen: false)
                      .fetchStoreList(user?.owner_id ?? 0);
                });
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: storeList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == storeList.length) {
                          return Column(
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DocumentGuidePage(),
                                    ),
                                  );
                                },
                                child: const Text("매장 추가"),
                              ),
                            ],
                          );
                        } else {
                          return storeCard(storeList[index]);
                        }
                      },
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  void getStoreList(BuildContext context) async {
    final currentContext = scaffoldKey.currentContext;
    my_app.User? user = Provider.of<UserProvider>(context, listen: false).user;

    try {
      final response = await Api().client.getStoreList(user?.owner_id ?? 0);
      currentContext?.read<StoreProvider>().setStoreCard(response.store);
      print(response);
    } catch (error) {
      currentContext?.read<StoreProvider>().setStoreCard(null);
      // _isFirstSlotLoaded = true;
      showModalDialog(context,
          "서버에서 오류가 발생하였습니다.\n앱 종료 후 다시 접속해 주세요.\n문제가 지속될 경우, 고객센터(service@.com)로 문의부탁드립니다.");
      rethrow;
    }
  }

  GestureDetector storeCard(Store? store) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CafeDetailScreen(
                        storeId: store?.store_id ?? -1,
                      )));
        },
        child: SizedBox(
          height: 150,
          child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                children: [
                  inspection_status(store?.inspection_status ?? -1),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(store!.store_logo,
                            width: 90,
                            height: 90,
                            cacheWidth: 100,
                            cacheHeight: 100,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                          return const Image(
                              image: AssetImage('assets/logo.jpeg'),
                              width: 90,
                              height: 90,
                              fit: BoxFit.fill);
                        }),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.store_name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(store.store_address)
                            ],
                          ),
                        )
                      ]),
                ],
              )),
        ));
  }

  Widget inspection_status(int status) {
    if (status == 0) {
      return Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: const Color(0xFF57B3FC),
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "승인대기",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (status == 1) {
      return Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "운영중",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (status == 2) {
      return Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "심사 반려",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "알수 없음",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
  }
}
