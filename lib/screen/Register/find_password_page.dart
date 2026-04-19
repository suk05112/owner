import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/utils/phone_utils.dart';
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
  final bool _emailExists = false;
  final bool _phoneExists = false;

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
          title: const Text("비밀번호 찾기"),
        ),
        body: Container(
            margin: const EdgeInsets.fromLTRB(27, 0, 27, 21),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("아이디(이메일) 입력"),
              TextFormField(
                controller: inputIDController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "이름"),
              ),
              const Text("전화번호 입력"),
              TextFormField(
                controller: inputPhoneNumbfController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  NumberFormatter(), // 자동하이픈
                  LengthLimitingTextInputFormatter(13)
                ],
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
                    // 이메일에 @gifnut.com 추가
                    String formattedEmail =
                        PhoneUtils.formatEmailForServer(inputIDController.text);
                    // 전화번호를 서버 형식으로 변환
                    String formattedPhone = PhoneUtils.formatForServer(
                        inputPhoneNumbfController.text);

                    bool emailExists =
                        await checkEmailExists(formattedEmail, formattedPhone);

                    if (emailExists) {
                      await firebaseAuth.sendPasswordResetEmail(
                          email: formattedEmail);

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
                  child: const Text("확인"),
                ),
              ),
            ])));
  }

  Future<bool> checkEmailExists(String email, String phoneNumber) async {
    try {
      final response = await Api().client.findOwnerPw(
            OwnerFindPw(email: email, phone_number: phoneNumber),
          );
      final Map<String, dynamic> data = jsonDecode(response);
      if (data['msg'] == "success") {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      String errorMsg = "";
      if (e.response != null) {
        // 서버에서 받은 상태 코드에 따른 처리
        if (e.response!.statusCode == 401) {
          // 인증 실패
          print("인증 실패: ${e.response!.data}");
          errorMsg = "[401]인증에 실패했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else if (e.response!.statusCode == 500) {
          // 서버 오류
          print("서버 오류: ${e.response!.data}");
          errorMsg =
              "[500]서버에 오류가 발행했습니다.잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else {
          // 기타 오류
          print("기타 오류: ${e.response!.data}");
          errorMsg = "오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        }
      } else {
        // 네트워크 연결 실패 등
        print("네트워크 오류: ${e.message}");
        errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.message}";
      }

      CommonDialog.show(
          context: context,
          title: "아이디 찾기 실패",
          content: errorMsg,
          buttonText: "확인",
          onPressed: () {});
    }
    return false;
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
  const SuccessResetPWPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: const EdgeInsets.fromLTRB(21, 0, 21, 21),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Text("비밀번호 재발급을 위한 메일이 전송되었습니다. \n메일을 확인해 주세요."),
                      const Spacer(),
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
                                    builder: (context) => const LoginScreen()));
                          },
                          child: const Text("로그인 하러가기"),
                        ),
                      ),
                      const SizedBox(
                        height: 81,
                      )
                    ]))));
  }
}
