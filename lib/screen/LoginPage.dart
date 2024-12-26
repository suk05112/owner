import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/StatusManager.dart';
import 'package:owner/common/Style/ColorAsset.dart';
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
                          user.email = userId;
                          login(newUser.user!.uid);
                        } else {
                          CommonDialog.show(
                              context: context,
                              title: "로그인 실패",
                              content: "입력된 정보가 올바르지 않습니다. 다시 입력해주세요",
                              buttonText: "확인");
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                          CommonDialog.show(
                              context: context,
                              title: "로그인 실패",
                              content: "잘못된 비밀번호 입니다. 다시 입력해주세요",
                              buttonText: "확인");
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
                                  builder: (context) => DocumentGuidePage()));
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
    var response = await Api().client.login(uid);
    if (response.owner_id != null) {
      print(
          "로그인 성공 ${response.owner_id}, ${response.name}, ${response.phone_number}");
      user.owner_id = response.owner_id ?? 0;
      user.phone_number = response.phone_number;
      user.name = response.name;
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }

    Provider.of<UserProvider>(context, listen: false).setUser(user);
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
                decoration:
                    inputDecoration.copyWith(hintText: "Enter your password"),
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

/*

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodosWidget(),
    );
  }
}


class TodosWidget extends StatefulWidget {
  const TodosWidget({Key? key}) : super(key: key);

  @override
  _TodosWidgetState createState() => _TodosWidgetState();
}
class _TodosWidgetState extends State<TodosWidget> {
  List<TempStore> news = [];
  bool isLoading = true;
  NewsProviders newsProvider = NewsProviders();

  Future initNews() async {
    news = await newsProvider.getNews();
  }

  @override
  void initState() {
    super.initState();
    initNews().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("뉴스 http"),
      ),
      body: isLoading
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: news.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(news[index].name ?? "no name"),
                      Text(news[index].store_logo ?? "no logo"),
                    ],
                  ),
                );
              }),
    );
  }
}
*/
