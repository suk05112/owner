import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/main.dart';
import 'package:owner/screen/cafelist/cafelist_page.dart';

import '../../common/DatabaseService.dart';
import '../../common/model/CafeInfo.dart';
import '../../common/model/OperatingHours.dart';
import '../RegisterStore.dart';
import '../Store/CafeDetailPage.dart';
import '../Store/MenuManagementPage.dart';

class CafeDetailScreen extends StatefulWidget {
  const CafeDetailScreen({Key? key, required this.storeId}) : super(key: key);
  final String storeId;
  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  DatabaseService service = DatabaseService();
  Future<CafeInfo>? cafeList;
  Future<OperatingHours>? operatingHours;
  late String _storeId;
  CafeInfo? _cafeInfo;

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    // cafeList = service.retrieveCafeInfo("0000001");
    // print(" _initRetrieval 호출2 ${cafeList}");
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    cafeList = service.retrieveCafeInfo("0000001");
    _cafeInfo = await cafeList;
    print(" _initRetrieval 호출2 ${cafeList}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Add Employee"),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder<CafeInfo>(
                future: cafeList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error cafe info: ${snapshot.error}');
                    } else {
                      final cafe = snapshot.data;

                      return FutureBuilder<OperatingHours>(
                          future: service
                              .retrieveOperatingHours(cafe!.operatingHourId!),
                          builder: (context, operatingHoursSnapshot) {
                            if (operatingHoursSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              if (operatingHoursSnapshot.hasError) {
                                return Text(
                                    'Error: oper: ${operatingHoursSnapshot.error}');
                              } else {
                                final operatingHours =
                                    operatingHoursSnapshot.data;
                                // final _cafeInfo = cafe;
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "cafe 이름 ${cafe?.store_name}, ${cafe?.open_yn}"),
                                      DefaultTabController(
                                        length: 2,
                                        child: SizedBox(
                                          height: 300.0,
                                          child: Column(
                                            children: <Widget>[
                                              TabBar(
                                                unselectedLabelColor:
                                                    Colors.black,
                                                labelColor: Colors.blue,
                                                tabs: <Widget>[
                                                  Tab(
                                                    text: "기본정보",
                                                  ),
                                                  Tab(
                                                    text: "운영정보",
                                                  )
                                                ],
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  children: <Widget>[
                                                    Container(
                                                      color: Colors.green,
                                                      child: DetailInfoWidget(
                                                          cafeInfo: cafe!),
                                                    ),
                                                    Container(
                                                      color: Colors.yellow,
                                                      child: OperatingHourWidget(
                                                          operatingHours:
                                                              operatingHours!),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text("tab bar 끝"),
                                      Container(
                                        height: 300,
                                        child: getListView(),
                                      )
                                    ]);
                              }
                            }
                          });
                    }
                  }
                })));
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
        store: _cafeInfo,
      ),
      RegisterStorePage(
        isRegister: false,
        store: _cafeInfo,
      ),
      MenuManagementPage(
        storeId: widget.storeId,
      ),
      RegisterStorePage(
        isRegister: false,
        store: _cafeInfo,
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

class DetailInfoWidget extends StatelessWidget {
  CafeInfo cafeInfo;

  DetailInfoWidget({required this.cafeInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(-1.0, 0.0),
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("상호명"),
            Text("${cafeInfo.store_name}"),
            Text("전화번호"),
            Text("${cafeInfo.store_telephone}"),
            Text("매장 소개"),
            Text("${cafeInfo.store_telephone}"),
            Text("사업자 등록번호"),
            Text("${cafeInfo.store_telephone}"),
            Text("사진"),
            Text("${cafeInfo.logo}"),
          ],
        ));
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
