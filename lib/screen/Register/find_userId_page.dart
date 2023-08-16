import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'dart:io';

import '../../common/widget/CommonWidget.dart';

class FindUserIDPage extends StatefulWidget {
  const FindUserIDPage({Key? key}) : super(key: key);

  @override
  State<FindUserIDPage> createState() => _FindUserIDPageState();
}

class _FindUserIDPageState extends State<FindUserIDPage> {
  TextEditingController inputIDController = TextEditingController();

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("아이디 찾ㅣ"),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("아이디 찾기"),
          TextFormField(
            controller: inputIDController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: "이름"),
            validator: (value) {
              return validatID(value);
            },
          ),
          PhoneNumberVerificationWidget(
            successCallback: showRegisterdId,
          ), //전화번호
        ]));
  }

  String? validatID(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }

  //전화번호 인증 성공 후 uid 넘겨 받고, 이름, Uid 담아서 id response 로 받기
  showRegisterdId(String? uid) {
    Api().client.findOwnername(uid ?? "").then((response) => {
          if (response.id != null)
            {
              RegisterdIDPage(
                id: response.id,
                created_time: response.createdTime,
              )
            }
          else
            {RegisterdIDPage(msg: response.msg), print(response.msg)}
        });
    print("showRegisterdId");
  }
}

class RegisterdIDPage extends StatefulWidget {
  RegisterdIDPage({Key? key, String? id, String? created_time, String? msg})
      : super(key: key);

  String? id;
  String? created_time;
  String? msg;

  @override
  State<RegisterdIDPage> createState() => _RegisterdIDPageState();
}

class _RegisterdIDPageState extends State<RegisterdIDPage> {
  TextEditingController inputIDController = TextEditingController();

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("매장 정보 입력"),
      // ),

      body: widget.id != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("가입 하신 아이디는 아래와 같습니다."), Text("아이디 : \n 가입일: ")])
          : Text(widget.msg!),
    );
  }
}
