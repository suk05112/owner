import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/screen/LoginPage.dart';

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
        body: Container(
            margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ),
              // Spacer(),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 151, 125, 253),
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SuccessResetPWPage()));
                    await checkEmailExists(inputIDController.text);
                    if (_emailExists && _phoneExists) {
                      // CommonDialog.show(
                      //   context: context,
                      //   title: "인증 완료",
                      //   content: "비밀번호 재발급을 위한 메일이 전송되었습니다. 메일을 확인해 주세요.",
                      //   buttonText: "확인",
                      // );
                      // CommonDialog(
                      //   text: '다이얼로그',
                      // );
                      // firebaseAuth.sendPasswordResetEmail(email: "hansj4525@naver.com");
                    } else {
                      print("else 탐");
                      // CommonDialog.show(
                      //     context: context,
                      //     title: "인증 실패",
                      //     content: "다시 확인",
                      //     buttonText: "확인");
                    }
                  },
                  child: Text("확인"),
                ),
              ),
              SizedBox(
                height: 81,
              )
            ])));
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

class SuccessResetPWPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text("비밀번호 재발급을 위한 메일이 전송되었습니다. \n메일을 확인해 주세요."),
                      Spacer(),
                      SizedBox(
                        width: double.infinity, // <-- match_parent
                        height: 50, // <-- match-parent
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 151, 125, 253),
                            // minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: Text("로그인 하러가기"),
                        ),
                      ),
                      SizedBox(
                        height: 81,
                      )
                    ]))));
  }
}
