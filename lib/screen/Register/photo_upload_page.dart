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
import 'package:http/http.dart' as http;

// import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
// import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class PhotoUploadePage extends StatefulWidget {
  const PhotoUploadePage({Key? key, required this.savedImageUrl});
  final List<String> savedImageUrl;

  @override
  State<PhotoUploadePage> createState() => _PhotoUploadePageState();
}

class _PhotoUploadePageState extends State<PhotoUploadePage> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // var userImage = <File>[];
  final picker = ImagePicker();

  List<File> selectedImages = []; // List of selected image
  late var userImage = [];
  final data = [1, 2, 3, 4, 5];

  bool isInit = false;
  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    // selectedImages = widget.savedImage;
    // widget.savedImageUrl.asMap().forEach((idx, url) async {
    //   selectedImages.add(await getImageFileFromUrl(url, idx));
    // });

    await Future.wait(widget.savedImageUrl.asMap().entries.map((e) async {
      var idx = e.key;
      var url = e.value;
      // setState(() async {
      selectedImages.add(await getImageFileFromUrl(url, idx));
      // });
    }));

    // widget.savedImageUrl.asMap().entries.map((e) async {
    //   var idx = e.key;
    //   var url = e.value;
    //   selectedImages.add(await getImageFileFromUrl(url, idx));
    // });

// final List<User> = await Future.wait(querySnapshot.documents.map((doc) async {
//   final snapshot = await doc['user'].get();
//   return User(id: snapshot["id"], name: snapshot["mail"]);
// }));

    // for (String url in widget.savedImageUrl) {
    //   selectedImages.add(await getImageFileFromUrl(url));
    // }

    print("photo upload page:: init state 실행");
    print(selectedImages);
  }

  Future<List<File>> _loadImages() async {
    List<File> images = [];
    await Future.wait(widget.savedImageUrl.asMap().entries.map((e) async {
      var idx = e.key;
      var url = e.value;
      images.add(await getImageFileFromUrl(url, idx));
    }));
    return images;
  }

  Future<List<File>> _loadImages2() async {
    List<File> images = [];
    await Future.wait(widget.savedImageUrl.asMap().entries.map((e) async {
      var idx = e.key;
      var url = e.value;
      images.add(await getImageFileFromUrl(url, idx));
    }));
    return images;
  }

  Future<File> getImageFileFromUrl(String imageUrl, int idx) async {
    // 이미지 URL을 사용하여 이미지 파일을 가져옵니다.
    // 예: https://example.com/image.jpg
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    final tempFile =
        File('${(await getTemporaryDirectory()).path}/image_${idx}.jpeg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  Future getImage() async {
    final pickedFile = await picker.pickMultiImage(
        //   imageQuality: 100, // To set quality of images
        // maxHeight: 1000, // To set maxheight of images that you want in your app
        // maxWidth: 1000
        ); // To set maxheight of images that you want in your app
    List<XFile> xfilePick = pickedFile;

    print("image 선택됨");
    print(xfilePick.length);
    // if atleast 1 images is selected it will add
    // all images in selectedImages
    // variable so that we can easily show them in UI
    if (xfilePick.isNotEmpty) {
      for (var i = 0; i < xfilePick.length; i++) {
        selectedImages.add(File(xfilePick[i].path));
      }
      setState(
        () {},
      );
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }

/*
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
  */

  @override
  Widget build(BuildContext context) {
    print("build 실행");
    Widget buildItem(String text) {
      return Card(
        key: ValueKey(text),
        child: Text(text),
      );
    }

    Widget selectedImg(path, index) {
      void _deleteImage(int index) {
        print("run _deleteImage");

        setState(() {
          selectedImages.removeAt(index);
        });
      }

      return Stack(
        key: ValueKey(path),
        children: [
          Image.file(
            File(path.path),
            key: ValueKey(path),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                print("touch delete icon");
                // 이미지 삭제 로직을 여기에 추가
                _deleteImage(index);
              },
              child: Image(
                key: ValueKey("${path}_1"),
                image: AssetImage('assets/delete.png'),
                width: 20,
                height: 20,
              ),
            ),
          )
        ],
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
              print(selectedImages);
              final storageRef = FirebaseStorage.instance.ref();
              Navigator.pop(context, selectedImages);
            },
            child: Text('확인'),
          ),
          FutureBuilder<List<File>>(
            future: _loadImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print("connection done");
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  isInit == false) {
                return CircularProgressIndicator(); // 데이터 로딩 중일 때 표시할 위젯
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                isInit = true;
                // 데이터 로딩이 완료된 경우 화면을 그립니다.
                selectedImages =
                    isInit == false ? snapshot.data ?? [] : selectedImages;
                print("build:: ${selectedImages}");

                return Container(
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

                    children: selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return selectedImg(image, index);
                    }).toList(),
                    // children:
                    // selectedImages.map((e) => selectedImg(e)).toList(),
                    // children: this.data.map((e) => buildItem("$e")).toList(),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        // final element = data.removeAt(oldIndex);
                        // data.insert(newIndex, element);
                        final element = selectedImages.removeAt(oldIndex);
                        selectedImages.insert(newIndex, element);
                      });
                    },
                  ),
                );

                // return Container(
                //   height: 800,
                //   child: ReorderableGridView.count(
                //     // ...
                //   ),
                // );
              }
            },
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = selectedImages.removeAt(oldIndex);
      selectedImages.insert(newIndex, item);
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
