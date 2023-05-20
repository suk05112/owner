import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/StatusManager.dart';
import 'package:owner/common/api/Provider.dart';
import 'package:owner/common/model/provider.dart';

import 'Register/BasicInfoInputPage.dart';
import 'Register/DocumentGuidePage.dart';
import 'cafelist/cafelist_page.dart';
import 'home.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

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
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          LoginFormWidget(),
          TextButton(
            onPressed: () async {
              try {
                final newUser = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: "sujineasㅇmi1l@nav.com", password: "pw1234");
                if (newUser.user != null) {
                  print("login success");
                  print("new user " + newUser.user!.uid);
                  // newUser.user.uid
                  Provider().loginOwner(newUser.user!.uid);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  print('No user found for that email.');
                } else if (e.code == 'wrong-password') {
                  print('Wrong password provided for that user.');
                }
              }
            },
            child: Text("로그인"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  // context, MaterialPageRoute(builder: (context) => MyApp()));

                  context,
                  MaterialPageRoute(builder: (context) => DocumentGuidePage()));
            },
            child: Text("회원가입"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (FirebaseAuth.instance.currentUser?.uid == null) {
                print("로그 아웃 후 Null");
              } else {
                print("로그아웃 안됨");
              }
            },
            child: Text("로그아웃"),
          ),
        ]));
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
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: idController,
                    keyboardType: TextInputType.text,
                    decoration:
                        inputDecoration.copyWith(hintText: "Enter your ID"),
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
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your password"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                ])));
  }

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}

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
