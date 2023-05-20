import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
// import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
// import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class PhotoUploadePage extends StatefulWidget {
  const PhotoUploadePage({Key? key, required this.savedImage});
  final savedImage;

  @override
  State<PhotoUploadePage> createState() => _PhotoUploadePageState();
}

class _PhotoUploadePageState extends State<PhotoUploadePage> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // var userImage = <File>[];
  final picker = ImagePicker();
  late var userImage = [];
  final data = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    userImage = widget.savedImage;
    File f = await getImageFileFromAssets('camera.jpeg');
    userImage.add(f);
    f = await getImageFileFromAssets('logo.jpeg');
    userImage.add(f);

    print("init state 실행");
    print(userImage);
  }

  Future getImage() async {
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    print("get img 실행");
    setState(() {
      if (pickedFile != null) {
        userImage.add(pickedFile);
      }
      print("img list");
      print(userImage);
    });
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildItem(String text) {
      return Card(
        key: ValueKey(text),
        child: Text(text),
      );
    }

    Widget selectedImg(path) {
      return Image.file(
        File(path.path),
        key: ValueKey(path),
        fit: BoxFit.cover,
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              print("pop될 이미지");
              print(userImage);
              final storageRef = FirebaseStorage.instance.ref();
              // for (var pickedImg in userImage) {
              //   print("이미지 저장");
              //   print(pickedImg.path);
              // try {
              //   // Upload raw data.
              //   final mountainsRef =
              //       storageRef.child("business_certification/test1.jpeg");

              //   await mountainsRef.putFile(File(pickedImg.path));
              // } on FirebaseException catch (e) {
              //   print("사진 업로드 실패" + e.code);
              //   // ...
              // }
              // }
              Navigator.pop(context, userImage);
            },
            child: Text('확인'),
          ),
          Container(
            height: 800,
            child: ReorderableGridView.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              header: [
                GestureDetector(
                  onTap: () {
                    print("touch 됨");
                    getImage();
                  },
                  child: Image(
                    image: AssetImage('assets/camera.jpeg'),
                    width: 1500,
                    height: 100,
                  ),
                )
              ],

              children: userImage.map((e) => selectedImg(e)).toList(),
              // children: this.data.map((e) => buildItem("$e")).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // final element = data.removeAt(oldIndex);
                  // data.insert(newIndex, element);
                  final element = userImage.removeAt(oldIndex);
                  userImage.insert(newIndex, element);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = userImage.removeAt(oldIndex);
      userImage.insert(newIndex, item);
    });
  }

  final buttonStyle = ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0)),
      backgroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 154, 152, 152)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))));
}
