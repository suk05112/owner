import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/user.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/provier/store_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/main.dart';
import 'package:owner/screen/Settlement/settlement_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:provider/provider.dart';

// import '../../common/DatabaseService.dart';
import '../../common/Style/TextAsset.dart';
import '../../common/Style/CommonSection.dart';

import '../../common/api/request/store/store.dart';
import '../../common/model/cafeInfo.dart';
import '../../common/model/OperatingHours.dart';
import '../Register/operating_hours_setting_Page.dart';
import '../Register/register_store_page.dart';
import 'MenuManagementPage.dart';

class CafeDetailScreen extends StatefulWidget {
  const CafeDetailScreen({Key? key, required this.storeId}) : super(key: key);
  final int storeId;
  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  Future<CafeInfo>? cafeList;
  Future<OperatingHours>? operatingHours;
  late int _storeId;
  CafeInfo? _cafeInfo;
  Future<OperatingHours>? op;
  bool isLoading = true;
  Store? store;

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    // cafeList = service.retrieveCafeInfo("0000001");
    // print(" _initRetrieval 호출2 ${cafeList}");
    _initRetrieval().then((value) => setState(() {
          isLoading = false;
          store = value;
          print("init 호출 후 store ${store}");
        }));
  }

  Future<Store> _initRetrieval() async {
    var response = await StoreProvider().getDetailStore(_storeId);
    store = response;
    print(" _initRetrieval 호출1 ${store?.store_photo_urls ?? "photo url null"}");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("내 매장관리"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child: isLoading
                  ? Center(
                      child: const CircularProgressIndicator(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    store?.inspection_status == 2
                                        ? inspectionMsg(
                                            store?.inspection_msg ?? "")
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: Image(
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                              store?.store_logo ?? "",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        // Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(store?.store_name ?? "매장 이름",
                                                style: TextAssset.header2),
                                            // Spacer(),
                                            Text(
                                                store?.store_address ??
                                                    "매장 주소 없음",
                                                style: TextAssset.body)
                                          ],
                                        ),
                                      ],
                                    ),

                                    Divider(),
                                    //전화번호
                                    Row(
                                      children: [
                                        Text("전화번호", style: TextAssset.header2),
                                        SizedBox(width: 20),
                                        // Spacer(),
                                        Text(
                                            store?.store_telephone ?? "전화번호 없음",
                                            style: TextAssset.body)
                                      ],
                                    ),
                                    Divider(),

                                    //매장소개
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("매장소개", style: TextAssset.header2),
                                        // Spacer(),
                                        Text(
                                            store?.store_description ??
                                                "매장 설명 없음",
                                            style: TextAssset.body)
                                      ],
                                    ),
                                    Divider(),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("매장주소", style: TextAssset.header2),
                                        // Spacer(),
                                        Text(store?.store_address ?? "매장 설명 없음",
                                            style: TextAssset.body)
                                      ],
                                    ),
                                    Divider(),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("매장 사진",
                                            style: TextAssset.header2),
                                        // Spacer(),
                                        StoreImagesGridview(),
                                      ],
                                    ),
                                  ])),
                          Divider(
                              thickness: 10,
                              height: 10,
                              color: Color(0xffF3F5F7)),
                          //매장관리 메뉴
                          Container(
                            margin: EdgeInsets.fromLTRB(21, 25, 21, 21),
                            height: 300,
                            child: getListView(),
                          )
                        ])),
        ));
  }

  Widget StoreImagesGridview() {
    print("StoreImagesGridview 호출됨 ${store!.store_photo_urls}");
    List<Widget> itemWidgets = store!.store_photo_urls.map((item) {
      return Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.fromLTRB(0, 2, 2, 0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(item,
                  width: 90,
                  height: 90,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  fit: BoxFit.fill, errorBuilder: (context, error, stackTrace) {
                print(error);
                return Image(
                    image: AssetImage('assets/logo.jpeg'),
                    width: 90,
                    height: 90,
                    fit: BoxFit.fill);
              })));
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: itemWidgets),
    );
  }

  List dataSource() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = ["매장 정보 수정", /*"영업시간 수정",*/ "메뉴관리", "주문내역 관리", "정산내역"];
    return items;
  }

  List dataSource2() {
    var items = [
      RegisterStorePage(
        isRegister: false,
        store: store,
      ),
      // OperatingHoursSettingPage(),
      MenuManagementPage(
        storeId: widget.storeId,
      ),
      RegisterStorePage(
        isRegister: false,
        store: store,
      ),
      SettlementPage(
        storeId: _storeId,
      ),
    ];

    return items;
  }

  Widget inspectionMsg(String msg) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 2, 0, 5),
        decoration: BoxDecoration(
          color: Color(0xECECEC),
          borderRadius: BorderRadius.circular(5),
        ),
        width: 400,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text("**승인 반려**"), Text(msg)]));
  }

//Converting the dataSources as a widget
  Widget getListView() {
    var allItems = dataSource();
    var selectedPage = dataSource2();
    // var listView = ListView.separated(
    var listView = ListView.builder(
      itemCount: allItems.length,
      itemExtent: 46.0,
      itemBuilder: (context, index) {
        return GestureDetector(
            //You need to make my child interactive
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => selectedPage[index]));
              if (result.runtimeType == Store) {
                await Future.delayed(Duration(seconds: 3));

                setState(() {
                  store = result;
                });
              }
            },
            child: Column(
                children: <Widget>[Text("${allItems[index]}"), Divider()]));
        // return ListTile(title: Text(allItems[index]));
      },
      // separatorBuilder: (BuildContext context, int index) {
      //   return Divider(
      //     color: Theme.of(context).primaryColor,
      //   );
      // },
    );
    return listView;
  }
}

class OperatingHourWidget extends StatelessWidget {
  OperatingHours operatingHours;

  OperatingHourWidget({required this.operatingHours});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(-1.0, 0.0),
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("영업시작시간"),
            Text("${operatingHours.startTime}"),
          ],
        ));
  }
}
