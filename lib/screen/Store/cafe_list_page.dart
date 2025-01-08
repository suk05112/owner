import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonWidget.dart';
import 'package:owner/common/api/API.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/register.dart';

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

  @override
  void initState() {
    super.initState();
    my_app.User? user = Provider.of<UserProvider>(context, listen: false).user;
    print("여기 호출됨? ${user?.owner_id}");

    Provider.of<StoreProvider>(context, listen: false)
        .fetchStoreList(user?.owner_id ?? 0);

    print("init state:: StoreProvider.fetchStoreList 호출 후 ");
  }

  Future _initRetrieval() async {
    print(FirebaseAuth.instance.currentUser?.displayName);
    print(FirebaseAuth.instance.currentUser?.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 매장관리"),
        centerTitle: true,
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          List<Store> storeList = storeProvider.storeCards ?? [];
          return Column(
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
                                      const DocumentInputPage(),
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
          );
        },
      ),
    );
  }

  Align buildStoreCardList() {
    return Align(
        alignment: Alignment.center,
        child:
            Consumer<StoreProvider>(builder: (context, storeProvider, child) {
          return Scaffold(
              body: Column(children: [
            Expanded(
                child: ListView.builder(
              itemCount: storeProvider.storeCards?.length ?? 5,
              itemBuilder: (context, index) {
                // return Text("card list");
                if (index == storeList!.length - 1) {
                  return Column(children: <Widget>[
                    storeCard(storeProvider.storeCards?[index]),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DocumentInputPage()));
                      },
                      child: const Text("매장 추가"),
                    ),
                  ]);
                } else {
                  return storeCard(storeProvider.storeCards?[index]);
                }
              },
            )),
          ]));
        }));
  }

  void getStoreList(BuildContext context) async {
    final currentContext = scaffoldKey.currentContext;

    try {
      final response = await Api().client.getStoreList(1);
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              width: 400,
              child: Column(
                children: [
                  inspection_status(store?.inspection_status ?? -1),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Image.network(store!.store_logo,
                        width: 90, height: 90, fit: BoxFit.fill,
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
                          Text(store.store_name),
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
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Color(0xFF57B3FC),
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
          Spacer()
        ],
      );
    } else if (status == 1) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Color(0xFF57B3FC),
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
          Spacer()
        ],
      );
    } else if (status == 1) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Color(0xFF57B3FC),
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "운영 중",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
          Spacer()
        ],
      );
    } else {
      return Row(
        children: [
          Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
            decoration: BoxDecoration(
              color: Color(0xFF57B3FC),
              borderRadius: BorderRadius.circular(5.0),
            ),
            alignment: Alignment.center,
            child: const Text(
              "심사 반려",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    }
  }
}
