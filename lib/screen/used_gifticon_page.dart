import 'package:flutter/material.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:intl/intl.dart';
import 'package:owner/common/model/UsedGifticon.dart';
import 'package:owner/common/model/user.dart' as my_app;
import 'package:owner/common/provier/user_provider.dart';
import 'package:provider/provider.dart';

class UsedGifticonPage extends StatefulWidget {
  const UsedGifticonPage({Key? key, required this.storeId}) : super(key: key);
  final int storeId;

  @override
  State<UsedGifticonPage> createState() => _UsedGifticonPagetate();
}

class _UsedGifticonPagetate extends State<UsedGifticonPage> {
  late int _storeId;
  Future<UsedGifticonList> futureUsedGifticonList =
      Future.value(UsedGifticonList(gifticonList: []));

  List<OwnerStore> _stores = [];
  String _selectedStore = '';

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    my_app.User? user = Provider.of<UserProvider>(context, listen: false).user;

    Api().client.getOwnerStoreList(user?.owner_id ?? 0).then((value) => {
          setState(() {
            _stores = value.ownerStoreList;
            _selectedStore = _stores[0].store_name;

            if (_stores.isNotEmpty) {
              futureUsedGifticonList =
                  Api().client.getUsedGifticon(_stores[0].store_id);
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("사용된 기프티콘"),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(21, 0, 21, 21),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton(
                      value: _selectedStore,
                      items: _stores
                          .map((OwnerStore store) => DropdownMenuItem(
                                value: store
                                    .store_name, // 선택 시 onChanged 를 통해 반환할 value
                                child: Text(store.store_name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        // items 의 DropdownMenuItem 의 value 반환
                        setState(() {
                          _selectedStore = value! as String;
                          print("selectedStore ${_selectedStore}");

                          // 선택된 store의 store_id 찾기
                          final selectedStore = _stores.firstWhere(
                            (store) => store.store_name == _selectedStore,
                          );

                          // 새로운 store_id로 API 호출
                          futureUsedGifticonList = Api()
                              .client
                              .getUsedGifticon(selectedStore.store_id);
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                    child: FutureBuilder<UsedGifticonList>(
                        future:
                            futureUsedGifticonList, // 비동기적으로 데이터를 가져오는 Future 객체
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // 데이터 로딩 중일 때 로딩 인디케이터 표시
                            return const Center(
                                child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(),
                            ));
                          } else if (snapshot.hasError) {
                            // 에러가 발생한 경우
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            // 데이터가 정상적으로 로드되었을 때
                            List<UsedGifticon> usedGifticonList =
                                snapshot.data?.gifticonList ?? [];

                            if (usedGifticonList.isNotEmpty) {
                              return RefreshIndicator(
                                  onRefresh: () async {
                                    setState(() {
                                      final selectedStore = _stores.firstWhere(
                                        (store) =>
                                            store.store_name == _selectedStore,
                                      );
                                      futureUsedGifticonList = Api()
                                          .client
                                          .getUsedGifticon(
                                              selectedStore.store_id);
                                    });
                                  },
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: usedGifticonList.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          "${usedGifticonList[index].used_time}"
                                                              .split('.')[0])
                                                    ],
                                                  ),
                                                  Text(
                                                    usedGifticonList[index]
                                                        .menu_name,
                                                    style: TextAssset.body,
                                                  ),
                                                  Text(
                                                      "${usedGifticonList[index].price}원"),
                                                ],
                                              );
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return const Divider();
                                            },
                                          ),
                                        ),
                                        const Text(
                                            "모든 정산내역은 매장관리>매장 선택>정산내역에서 확인 하실 수 있습니다.")
                                      ]));
                            } else {
                              return RefreshIndicator(onRefresh: () async {
                                setState(() {
                                  final selectedStore = _stores.firstWhere(
                                    (store) =>
                                        store.store_name == _selectedStore,
                                  );
                                  futureUsedGifticonList = Api()
                                      .client
                                      .getUsedGifticon(selectedStore.store_id);
                                });
                              }, child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height: constraints.maxHeight,
                                        child: const Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text("오늘 사용된 기프티콘이 없습니다.")
                                              ],
                                            ),
                                          ],
                                        ))));
                              }));
                            }
                          } else {
                            return const Text("문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
                          }
                        }))
              ],
            )));
  }
}
