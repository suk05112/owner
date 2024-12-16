import 'package:flutter/material.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/gifticon_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/register.dart';
import 'package:owner/screen/Register/register_store_page.dart';

import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/screen/home.dart';
import 'package:provider/provider.dart';
import 'common/provier/store_provider.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screen/LoginPage.dart';
import 'screen/Register/DocumentGuidePage.dart';

import 'package:owner/common/api/API.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // User? user = Provider.of<UserProvider>(context).user;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoreProvider()),
        ChangeNotifierProvider(create: (context) => GifticonProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      // child:
      //  MaterialApp(
      //   title: 'Flutter Demo',
      //   theme: ThemeData(
      //     primarySwatch: Colors.blue,
      //   ),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          User? user = userProvider.user;

          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: user == null ? const LoginScreen() : const Home(),
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
    );
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

  // getData() async {
  //   var result = await firestore.collection('cafe').get();
  //   List<CafeInfo> cafeInfo = [];
  //   for (var snapShot in result.docs) {
  //     CafeInfo info = CafeInfo.fromQuerySnapshot(snapShot);
  //     print("sujin1" + info.toString());

  //     print(info.logo);
  //     // print(info.open_yn);
  //     print(info.store_name);
  //     print(info.store_telephone);

  //     cafeInfo.add(info);
  //   }
  //   print("sujin2" + cafeInfo.toString());
  //   print("sujin3" + result.toString());
  // }

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
