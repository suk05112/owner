import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:owner/register.dart';
import 'package:owner/common/model/DataModel.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const CafeList());
}

class CafeList extends StatelessWidget {
  const CafeList({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Cafe());
  }
}

class Cafe extends StatelessWidget {
  // This widget is the root of your application.

  Map<String, DataModel> responseData = Map();
  final List<String> cafeList = <String>[];

  Future<void> init(String collection) async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .listen((event) {
      event.docs.forEach((element) {
        log("id : ${element.data()['id']}");
        log("title : ${element.data()['title']}");
        log("image : ${element.data()['image']}");
        log("view : ${element.data()['view']}");

        if (collection == 'my_youtube') {
          cafeList.add(element.data()['id']);
          responseData[element.data()['id']] = DataModel(
            storeName: element.data()['store_Name'],
            storeTelephone: element.data()['store_Telephone'],
            logo: element.data()['logo'],
            ownerId: element.data()['owner_Id'],
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new GestureDetector(
      onTap: () {
        print("Container clicked");
      },
      child: Container(
        child: Row(children: [
          Image(image: AssetImage('assets/logo.jpeg')),
          Text((cafeList[0] as DataModel).storeName),
        ]),
      ),
    ));
  }
}

class MyCafe extends StatefulWidget {
  const MyCafe({super.key, required this.title});

  final String title;

  @override
  State<MyCafe> createState() => _MyCafe();
}

class _MyCafe extends State<MyCafe> {
  void _incrementCounter() {
    setState(() {});
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
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Register()));
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
