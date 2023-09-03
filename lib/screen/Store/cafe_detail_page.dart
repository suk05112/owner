import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/provier/store_provider.dart';
import 'package:owner/main.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';

// import '../../common/DatabaseService.dart';
import '../../common/Style/TextAsset.dart';
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
  // DatabaseService service = DatabaseService();
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
    var response = await StoreProvider().getDetailStore();
    store = response;
    print(" _initRetrieval 호출1 ${store}");

    StoreProvider()
        .getDetailStore()
        .then((value) => print(" _initRetrieval 호출2 ${value}"));

    // print(" _initRetrieval 호출2 ${store}");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   title: const Text("Add Employee"),
        // ),
        body: SafeArea(
      child: SingleChildScrollView(
          child: isLoading
              ? Center(
                  child: const CircularProgressIndicator(),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Header
                            Row(children: [
                              Spacer(),
                              Text(
                                "내 매장관리",
                                style: TextAssset.header1,
                              ),
                              Spacer(),
                            ]),
                            SizedBox(height: 13),

                            //매장 로고, 매장이름
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    store?.store_logo ?? "",
                                  ),
                                ),
                                SizedBox(width: 20),
                                // Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(store?.store_name ?? "매장 이름",
                                        style: TextAssset.header2),
                                    // Spacer(),
                                    Text(store?.store_address ?? "매장 주소 없음",
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
                                Text(store?.store_telephone ?? "전화번호 없음",
                                    style: TextAssset.body)
                              ],
                            ),
                            Divider(),

                            //매장소개
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("매장소개", style: TextAssset.header2),
                                // Spacer(),
                                Text(store?.store_description ?? "매장 설명 없음",
                                    style: TextAssset.body)
                              ],
                            ),
                            Divider(),

                            //운영시간
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("운영시간", style: TextAssset.header2),
                                // Spacer(),
                                Text(store?.store_description ?? "매장 설명 없음",
                                    style: TextAssset.body)
                              ],
                            ),
                            Divider(),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("매장 사진", style: TextAssset.header2),
                                // Spacer(),
                                Text(store?.store_description ?? "매장 설명 없음",
                                    style: TextAssset.body)
                              ],
                            ),
                          ])),
                  Divider(thickness: 10, height: 10, color: Color(0xffF3F5F7)),
                  //매장관리 메뉴
                  Container(
                    margin: EdgeInsets.fromLTRB(21, 25, 21, 21),
                    height: 300,
                    child: getListView(),
                  )
                ])),
    ));
  }

  List dataSource() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = ["매장 정보 수정", "영업시간 수정", "메뉴관리", "주문내역 관리"];
    return items;
  }

  List dataSource2() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      RegisterStorePage(
        isRegister: false,
        store: store,
      ),
      OperatingHoursSettingPage(),
      MenuManagementPage(
        storeId: widget.storeId.toString(),
      ),
      RegisterStorePage(
        isRegister: false,
        store: store,
      ),
    ];

    return items;
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
        return new GestureDetector(
            //You need to make my child interactive
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => selectedPage[index])),
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
