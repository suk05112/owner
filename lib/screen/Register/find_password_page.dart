import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common/widget/CommonWidget.dart';
import '../../common/widget/CommonDialog.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({Key? key}) : super(key: key);

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final firebaseAuth = FirebaseAuth.instance;
  TextEditingController inputIDController = TextEditingController();
  bool _emailExists = false;
  bool _phoneExists = false;

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
          title: Text("비밀번호 찾기"),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("비밀번호 입력"),
          TextFormField(
            controller: inputIDController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: "아이디"),
          ),
          PhoneNumberVerificationWidget(
            // successCallback: showRegisterdId,
            successCallback: (_) {
              setState(() {
                _phoneExists =
                    true; // Assume it exists to avoid any UI confusion
              });
            },
          ), //전화번호
          TextButton(
            onPressed: () async {
              await checkEmailExists(inputIDController.text);
              if (_emailExists && _phoneExists) {
                CommonDialog.show(
                  context: context,
                  title: "인증 완료",
                  content: "비밀번호 재발급을 위한 메일이 전송되었습니다. 메일을 확인해 주세요.",
                  buttonText: "확인",
                );
                // CommonDialog(
                //   text: '다이얼로그',
                // );
                // firebaseAuth.sendPasswordResetEmail(email: "hansj4525@naver.com");
              } else {
                print("else 탐");
                CommonDialog.show(
                    context: context,
                    title: "인증 실패",
                    content: "다시 확인",
                    buttonText: "확인");
              }
            },
            child: Text("확인"),
          ),
        ]));
  }

  showRegisterdId(String? uid) {
    Api()
        .client
        .findOwnername(uid ?? "")
        .then((response) => {print("비밀번호 재발급 링크 전송")});
    print("showRegisterdId");
  }

  Future<void> checkEmailExists(String emailAddress) async {
    try {
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
      print(list);
      setState(() {
        _emailExists = list.isNotEmpty;
        print("여기 탐");
        print(_emailExists);
      });
    } catch (error) {
      print("catch 탐");

      setState(() {
        _emailExists = false; // Assume it exists to avoid any UI confusion
      });
    }
  }
}

//아이디 입력 -> 전화번호 인증 완료 -> 확인 버튼 -> complete Phoneverification&checkEmail -> alert