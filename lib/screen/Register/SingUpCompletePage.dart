import 'package:flutter/material.dart';
import 'package:owner/main.dart';

import '../Store/cafe_list_page.dart';

class SignUpCompletePage extends StatelessWidget {
  const SignUpCompletePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // SizedBox(),
            Container(
              height: 40,
              margin: EdgeInsets.fromLTRB(10, 100, 30, 0),
              // color: Colors.red,
            ),
            Container(
                // decoration:
                // BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  Text(
                    "가입 완료",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  SizedBox(height: 20),
                  Container(
                    // decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)),
                    child: Text(
                        "승인까지  최대 3일이 소요될 수 있습니다. \n승인 후 문자메시지로 알려드립니다.\n매장 등록 및 메뉴 등록을 함께 하면 \n빠른 심사가 가능합니다."),
                  ),
                ])),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: [
                SizedBox(
                  width: double.infinity, // <-- Your width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      // minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CafeList()));
                    },
                    child: Text('매장 등록하러 가기'),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  // width: double.infinity,
                  // height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    child: Text('홈으로'),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
