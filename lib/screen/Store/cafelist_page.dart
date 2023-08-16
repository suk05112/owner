import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/widget/CommonWidget.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/register.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:owner/common/model/cafeInfo.dart';

import '../../common/model/CafeBasicInfo.dart';
import '../../common/provier/store_provider.dart';
import '../Register/RegisterStore.dart';
import 'cafe_detail_page.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(CafeList());
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
    print("init state 호출");
    // getData();
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).fetchStoreList();

    // _initRetrieval();
  }

  Future _initRetrieval() async {
    print(" _initRetrieval 호출");
    print(FirebaseAuth.instance.currentUser?.displayName);
    print(FirebaseAuth.instance.currentUser?.email);
    // getStoreList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          List<Store> storeList = storeProvider.storeCards ?? [];
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  itemCount: storeList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == storeList.length) {
                      return Column(
                        children: <Widget>[
                          storeCard(null),
                          TextButton(
                            onPressed: () {
                              print("container 눌림");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterStorePage(
                                    isRegister: true,
                                    store: null,
                                  ),
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
                  separatorBuilder: (BuildContext context, int index) {
                    if (index == 0) return SizedBox.shrink();
                    return const Divider();
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
            Text("dmdkdkkd"),
            Expanded(
                child: ListView.separated(
              itemCount: storeProvider.storeCards?.length ?? 5,
              itemBuilder: (context, index) {
                // return Text("card list");
                if (index == storeList!.length - 1) {
                  return Column(children: <Widget>[
                    storeCard(storeProvider.storeCards?[index]),
                    TextButton(
                      onPressed: () {
                        print("container 눌림");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterStorePage(
                                      isRegister: true,
                                      store: null,
                                    )));
                      },
                      child: const Text("매장 추가"),
                    ),
                  ]);
                } else {
                  return storeCard(storeProvider.storeCards?[index]);
                }
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index == 0) return SizedBox.shrink();
                return const Divider();
              },
            ))
          ]));
        }));
  }

  void getStoreList(BuildContext context) async {
    final currentContext = scaffoldKey.currentContext;

    try {
      final response = await Api().client.getStoreList(1);
      currentContext?.read<StoreProvider>().setStoreCard(response.body.store);
      print("get store list");
      print(response);
      // _isFirstSlotLoaded = true;
    } catch (error) {
      // stopLoading();
      currentContext?.read<StoreProvider>().setStoreCard(null);
      // _isFirstSlotLoaded = true;
      showModalDialog(context,
          "서버에서 오류가 발생하였습니다.\n앱 종료 후 다시 접속해 주세요.\n문제가 지속될 경우, 고객센터(service@loplat.com)로 문의부탁드립니다.");
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
                        storeId: store?.store_name ?? "name is null",
                      )));
        },
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 0, 0, 0)),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Row(children: [
            Expanded(
                child: Image.network(
                    store?.store_logo ??
                        'https://cafe-platform-bucket.s3.ap-northeast-2.amazonaws.com/logo/store_logo_3.png',
                    width: 1500,
                    height: 100)
                // Image(
                //   image: AssetImage('assets/logo.jpeg'),
                //   width: 1500,
                //   height: 100,
                // ),
                ),
            Text("${store?.store_name}"),
          ]),
          width: 400,
        ));
  }
}
