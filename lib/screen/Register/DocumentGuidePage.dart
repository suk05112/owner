import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/main.dart';

import 'BasicInfoInputPage.dart';

class DocumentGuidePage extends StatelessWidget {
  const DocumentGuidePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                padding: EdgeInsets.fromLTRB(21, 5, 21, 5),
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "가입 전 준비해 주세요",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Text(
                            "사업자 등록증 \n 영업 신고증\n 통장사본 \n 사업자 등록증에 있는 사업자와 동일해야 합니다."),
                      ),
                    ])),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                backgroundColor: ColorAssset.mainColor,
                foregroundColor: Colors.white,
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
