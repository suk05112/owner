import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/StatusManager.dart';

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                  Container(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      'https://cafe-platform-bucket.s3.amazonaws.com/dog.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZXR665FZ6NASG4GZ%2F20230904%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Date=20230904T150858Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=664b89c45e23a0cdac3505dd102e17812731065d68193ce0f476e8bddc886de9',
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  LoginFormWidget(),
                  SizedBox(
                    height: 90,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                      // try {
                      //   final newUser = await FirebaseAuth.instance
                      //       .signInWithEmailAndPassword(
                      //           email: "sujineasㅇmi1l@nav.com", password: "pw1234");
                      //   if (newUser.user != null) {
                      //     print("login success");
                      //     print("new user " + newUser.user!.uid);
                      //     // newUser.user.uid
                      //     Navigator.push(
                      //         context, MaterialPageRoute(builder: (context) => Home()));
                      //   }
                      // } on FirebaseAuthException catch (e) {
                      //   if (e.code == 'user-not-found') {
                      //     print('No user found for that email.');
                      //   } else if (e.code == 'wrong-password') {
                      //     print('Wrong password provided for that user.');
                      //   }
                      // }
                    },
                    child: Text("로그인"),
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
                  TextButton(
                    onPressed: () async {
                      print("main init state 호출");
                      var picker = ImagePicker();
                      var image =
                          await picker.pickImage(source: ImageSource.gallery);
                      try {
                        http.Response response = await http.put(
                          Uri.parse(
                              "https://cafe-platform-bucket.s3.amazonaws.com/logo/store_logo_30.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZXR665FZ6NASG4GZ%2F20230906%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Date=20230906T163856Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=e58aa6dd5f0df0cca763df1e398ea0871af40bda87cebdc065f0636e98df098f"),
                          body: await image?.readAsBytes(),
                          headers: {
                            'Content-Type': 'image/jpeg', // 이미지 파일 형식에 맞게 변경
                          },
                        );

                        if (response.statusCode == 200) {
                          // 이미지 업로드 성공
                          print('Image uploaded successfully.');
                        } else {
                          // 이미지 업로드 실패
                          print(
                              'Image upload failed. Status code: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error: $e');
                      }

                      // StoreProvider().getStoreList();
                      // CafeInfo response = await Api().client.getStoreList(2);
                      // Api().client.getStoreList(2).then((it) => {logger.i(it));

                      // await FirebaseAuth.instance.signOut();
                      // if (FirebaseAuth.instance.currentUser?.uid == null) {
                      //   print("로그 아웃 후 Null");
                      // } else {
                      //   print("로그아웃 안됨");
                      // }
                    },
                    child: Text("로그아웃"),
                  ),
                ])));
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

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