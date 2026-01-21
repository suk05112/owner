import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/gifticon_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/screen/home.dart';
import 'common/provier/store_provider.dart';
import 'screen/LoginPage.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/config.dart';

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase는 main_dev.dart 또는 main_prod.dart에서 이미 초기화됨
  // 여기서는 API만 초기화

  // API 초기화 - 환경에 맞는 baseUrl 설정
  await Api().setBaseClient(AppConfig.baseUrl);

  // debugInvertOversizedImages = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // User? user = Provider.of<UserProvider>(context).user;
    return PopScope(
        canPop: false,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => StoreProvider()),
            ChangeNotifierProvider(create: (context) => GifticonProvider()),
            ChangeNotifierProvider(create: (context) => UserProvider()),
          ],

          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              User? user = userProvider.user;

              return MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: user == null ? const LoginScreen() : const Home(),
                debugShowCheckedModeBanner: false,
              );
            },
          ),
          // routes: {
          //   '/': (context) => const LoginScreen(),
          //   // '/': (context) => const MyHomePage(
          //   //       title: 'my page',
          //   //     ),
          //   '/add': (context) => const CafeList(),
          //   '/edit': (context) => const DocumentGuidePage(),
          // },
          // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final firestore = FirebaseFirestore.instance;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                // getData();
                // Navigator.pushNamed(context, '/edit');

                // Navigator.push(
                //     context,
                // MaterialPageRoute(builder: (context) => CafeList()));
                // MaterialPageRoute(builder: (context) => EmployeeScreen()));
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
