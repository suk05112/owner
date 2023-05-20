import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner/register.dart';
import 'package:owner/common/DatabaseService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:owner/common/model/CafeInfo.dart';

import '../../common/api/store_list_provider.dart';
import '../../common/model/CafeBasicInfo.dart';
import '../RegisterStore.dart';
import '../cafe_detail/cafe_detail_page.dart';

void main() {
  runApp(CafeList());
}

class CafeList extends StatefulWidget {
  const CafeList({Key? key}) : super(key: key);

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList> {
  // DatabaseService service = DatabaseService();
  // Future<List<CafeBasicInfo>>? cafeList;
  StoreListProviders storeListProvider = StoreListProviders();
  Future<List<TempStore>>? storeList;

  @override
  void initState() {
    print("init state 호출");
    // getData();
    super.initState();
    _initRetrieval();
  }

  void getData() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    // var snapshot = await db.collection("cafe").get();
    // print("suuujin");
    // print(snapshot);
  }

  Future _initRetrieval() async {
    print(" _initRetrieval 호출");
    // print(FirebaseAuth.instance.currentUser?.displayName);
    // print(FirebaseAuth.instance.currentUser?.email);

    // cafeList = service.retrieveCafeBasicInfo();
    //   storeList = await storeListProvider.getNews();
    storeList = storeListProvider.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceBsetween,
            children: <Widget>[
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: FutureBuilder<List<TempStore>>(
                future: storeList,
                builder: (context, snapshot) {
                  final List<TempStore>? storeList = snapshot.data;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('\n\n\nError: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return ListView.separated(
                      itemCount: storeList!.length,
                      itemBuilder: (context, index) {
                        final store = storeList[index];
                        if (index == snapshot.data!.length - 1) {
                          return Column(children: <Widget>[
                            MyCafe(store),
                            TextButton(
                              onPressed: () {
                                print("contaicer 눌림");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterStorePage(
                                              isRegister: true,
                                              store: null,
                                            )));
                              },
                              child: const Text("매장 추가"),
                            ),
                          ]);
                        } else {
                          return MyCafe(store);
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if (index == 0) return SizedBox.shrink();
                        return const Divider();
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No data"),
                    );
                  }
                },
              ),
            ),
          ),
        ]));
  }
}

class MyCafe extends StatelessWidget {
  MyCafe(this._cafeInfo);

  final TempStore _cafeInfo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CafeDetailScreen(
                      storeId: _cafeInfo.storeName!,
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
            child: Image(
              image: AssetImage('assets/logo.jpeg'),
              width: 1500,
              height: 100,
            ),
          ),
          Text("${_cafeInfo.storeName}"),
        ]),
        width: 400,
      ),
    );
  }
}
// class MyCafe extends StatefulWidget {
//   const MyCafe({super.key, required this.title});

//   final String title;

//   @override
//   State<MyCafe> createState() => _MyCafe();
// }

// class _MyCafe extends State<MyCafe> {
//   void _incrementCounter() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Register()));
//               },
//               child: Text("회원가입"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
