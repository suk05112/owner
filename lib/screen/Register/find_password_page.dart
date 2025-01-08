import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/api/request/owner/owner.dart';
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
  TextEditingController inputPhoneNumbfController = TextEditingController();
  bool _emailExists = false;
  bool _phoneExists = false;

  final inputDecoration = InputDecoration(
      border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(8.0),
          // borderSide: const BorderSide(
          //   color: Colors.redAccent,
          //   width: 2,
          // )
          ));

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
              Text("아이디(이메일) 입력"),
              TextFormField(
                controller: inputIDController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "이름"),
              ),
              Text("전화번호 입력"),
              TextFormField(
                controller: inputPhoneNumbfController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "전화번호"),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                  ),
                  onPressed: () async {
                    bool emailExists = await checkEmailExists(
                        inputIDController.text, inputPhoneNumbfController.text);

                    if (emailExists) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessResetPWPage()));
                    } else {
                      CommonDialog.show(
                          context: context,
                          title: "입력된 정보가 올바르지 않습니다.",
                          content: "다시한번 확인해주세요.",
                          buttonText: "확인",
                          onPressed: () {});
                    }
                  },
                  child: Text("확인"),
                ),
              ),
            ])));
  }

  Future<bool> checkEmailExists(String email, String phone_number) async {
    final response = await Api().client.findOwnerPw(
          OwnerFindPw(email: email, phone_number: phone_number),
        );

    if (response == "success") {
      return true;
    } else {
      return false;
    }
  }
//   Future<void> checkEmailExists(String emailAddress) async {
//     try {
//       final list =
//           await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
//       print(list);
//       setState(() {
//         _emailExists = list.isNotEmpty;
//         print("여기 탐");
//         print(_emailExists);
//       });
//     } catch (error) {
//       print("catch 탐");

//       setState(() {
//         _emailExists = false; // Assume it exists to avoid any UI confusion
//       });
//     }
//   }
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
                            foregroundColor: Colors.white,
                            backgroundColor: ColorAssset.mainColor,
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
