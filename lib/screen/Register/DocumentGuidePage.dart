import 'package:flutter/material.dart';
import 'package:owner/main.dart';

import 'BasicInfoInputPage.dart';

class DocumentGuidePage extends StatelessWidget {
  const DocumentGuidePage({Key? key}) : super(key: key);

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
                    "가입 전 준비해 주세요",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  SizedBox(height: 20),
                  Container(
                    // decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)),
                    child: Text(
                        "사업자 등록증 \n 영업 신고증\n 통장사본 \n 사업자 등록증에 있는 사업자와 동일해야 합니다."),
                  ),
                ])),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 151, 125, 253),
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BasicInfoInputPage()));
              },
              child: Text('가입하기'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
