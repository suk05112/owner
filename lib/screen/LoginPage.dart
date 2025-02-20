import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/StatusManager.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:provider/provider.dart';

import '../common/model/cafeInfo.dart';
import 'Register/BasicInfoInputPage.dart';
import 'Register/DocumentGuidePage.dart';
import 'Register/find_password_page.dart';
import 'Register/find_userId_page.dart';
import 'home.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:owner/common/api/API.dart';
import 'package:owner/common/provier/store_provider.dart';
import 'package:owner/common/model/user.dart' as my_app;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  my_app.User user = my_app.User(
      owner_id: 0, name: 'name', email: 'email', phone_number: 'phone');

  String userId = '';
  String userPw = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "로그인 하기",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  LoginFormWidget(onLoginInputChanged: (id, pw) {
                    setState(() {
                      userId = id;
                      userPw = pw;
                    });
                  }),
                  SizedBox(
                    height: 90,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: ColorAssset.mainColor,
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () async {
                      try {
                        print('입력된 pw ${userPw}');
                        final newUser = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: userId, password: userPw);
                        if (newUser.user != null) {
                          print("not null 걸림");
                          user.email = userId;
                          login(newUser.user!.uid);
                        } else {
                          CommonDialog.show(
                              context: context,
                              title: "로그인 실패",
                              content: "입력된 정보가 올바르지 않습니다. 다시 입력해주세요",
                              buttonText: "확인",
                              onPressed: () {});
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                          CommonDialog.show(
                              context: context,
                              title: "로그인 실패",
                              content: "아이디를 찾을 수 없습니다.. 다시 입력해주세요",
                              buttonText: "확인",
                              onPressed: () {});
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                          CommonDialog.show(
                              context: context,
                              title: "로그인 실패",
                              content: "잘못된 비밀번호 입니다. 다시 입력해주세요",
                              buttonText: "확인",
                              onPressed: () {});
                        }
                      }
                    },
                    child: Text(
                      "로그인",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              // context, MaterialPageRoute(builder: (context) => MyApp()));
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BasicInfoInputPage()));
                        },
                        child: Text("회원가입"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              // context, MaterialPageRoute(builder: (context) => MyApp()));
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FindUserIDPage()));
                        },
                        child: Text("아이디 찾기"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              // context, MaterialPageRoute(builder: (context) => MyApp()));
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FindPasswordPage()));
                        },
                        child: Text("비밀번호 찾기"),
                      ),
                    ],
                  ),
                ])));
  }

  void login(uid) async {
    print("로그인 함수 호출 ${uid}");
    /*
    try {
      Response<OwnerLoginResponse> response = await Api().client.login(uid);
      if (response.statusCode == 200) {
        // HTTP 상태 코드 200 ~ 299
        final data = response.data!;
        print("로그인 성공: ${data.owner_id}, ${data.name}, ${data.phone_number}");

        user.owner_id = data.owner_id ?? 0;
        user.phone_number = data.phone_number;
        user.name = data.name;
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // HTTP 오류 응답 처리
        print("로그인 실패: ${response.statusCode}");
        // handleError(response.statusCode, response.error);
      }
    } catch (e) {
      // 네트워크 오류 또는 예외 처리
      print("로그인 요청 중 오류 발생: $e");
      // handleError(null, e.toString());
    }
    */

    try {
      var response = await Api().client.login(uid);

      if (response.owner_id != null) {
        print(
            "로그인 성공 ${response.owner_id}, ${response.name}, ${response.phone_number}");
        user.owner_id = response.owner_id ?? 0;
        user.phone_number = response.phone_number;
        user.name = response.name;

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
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
          title: "로그인 실패",
          content: errorMsg,
          buttonText: "확인",
          onPressed: () {});
    }
  }
}

class LoginFormWidget extends StatefulWidget {
  final Function(String id, String pw) onLoginInputChanged;

  const LoginFormWidget({Key? key, required this.onLoginInputChanged})
      : super(key: key);
  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8.0),
              TextFormField(
                controller: idController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "Enter your ID"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter id';
                  }
                  return null;
                },
                onChanged: (value) {
                  widget.onLoginInputChanged(
                      idController.text, pwController.text);
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: pwController,
                keyboardType: TextInputType.text,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 2,
                      )),
                  suffixIcon: IconButton(
                    icon: hidePassword
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Name';
                  }
                  return null;
                },
                onChanged: (value) {
                  widget.onLoginInputChanged(
                      idController.text, pwController.text);
                },
              ),
            ]));
  }

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}
