import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
// import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';

Future<File> resizeImage(File originalFile, int maxWidth, int maxHeight) async {
  Uint8List imageBytes = await originalFile.readAsBytes();
  img.Image? decodedImage = img.decodeImage(imageBytes);

  if (decodedImage == null) {
    throw Exception("Failed to decode image");
  }

  img.Image resizedImage =
      img.copyResize(decodedImage, width: maxWidth, height: maxHeight);
  File resizedFile = File(originalFile.path);
  resizedFile.writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

  return resizedFile;
}

class PhotoUploadePage extends StatefulWidget {
  const PhotoUploadePage(
      {Key? key, required this.savedImageUrl, required this.storeImage});
  final List<String> savedImageUrl;
  final List<File> storeImage;

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
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    selectedImages = widget.storeImage;
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

      var imageFile = await getImageFileFromUrl(url, idx);
      var resizedImage = await resizeImage(imageFile, 800, 800);
      selectedImages.add(resizedImage);
      setState(() {}); // UI 업데이트

      // selectedImages.add(await getImageFileFromUrl(url, idx));

      // setState(() async {

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
    setState(() {
      isLoading = true; // Start loading
    });

    final pickedFile = await picker.pickMultiImage(
      imageQuality: 70, // To set quality of images
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
        selectedImages.add(await fixExifRotation(xfilePick[i].path));

        // selectedImages.add(File(xfilePick[i].path));
      }
      setState(
        () {
          isLoading = false; // Images are loaded, stop loading
        },
      );
    } else {
      // If no image is selected, show a snackbar
      setState(() {
        isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }

  Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(Uint8List.fromList(imageBytes));

    final height = originalImage!.height;
    final width = originalImage.width;

    // Let's check for the image size
    // This will be true also for upside-down photos but it's ok for me
    if (height >= width) {
      // I'm interested in portrait photos so
      // I'll just return here
      return originalFile;
    }

    // We'll use the exif package to read exif data
    // This is map of several exif properties
    // Let's check 'Image Orientation'
    final exifData = await readExifFromBytes(imageBytes);

    img.Image fixedImage = img.copyRotate(originalImage, angle: 0);

    if (exifData.containsKey('Image Orientation')) {
      final orientation = exifData['Image Orientation']!.printable;
      print("Image Orientation: $orientation");
    } else {
      print("key 없음");
    }
    if (height < width) {
      print('Rotating image necessary');
      // rotate
      if (exifData['Image Orientation']!.printable.contains('Horizontal')) {
        // fixedImage = img.copyRotate(originalImage, angle: 90);
      } else if (exifData['Image Orientation']!.printable.contains('180')) {
        // fixedImage = img.copyRotate(originalImage, angle: -90);
      } else if (exifData['Image Orientation']!.printable.contains('CW')) {
        fixedImage = img.copyRotate(originalImage, angle: -90);
      } else {
        fixedImage = img.copyRotate(originalImage, angle: 0);
      }
    }

    // Here you can select whether you'd like to save it as png
    // or jpg with some compression
    // I choose jpg with 100% quality
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
        appBar: AppBar(
          title: const Text("매장사진 업로드"),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<File>>(
                future: _loadImages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    print("connection done");
                  }
                  if ((snapshot.connectionState == ConnectionState.waiting &&
                          isInit == false) ||
                      (isLoading == true)) {
                    return const CircularProgressIndicator(); // 데이터 로딩 중일 때 표시할 위젯
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    isInit = true;
                    // 데이터 로딩이 완료된 경우 화면을 그립니다.
                    selectedImages =
                        isInit == false ? snapshot.data ?? [] : selectedImages;
                    print("build:: ${selectedImages}");

                    return Expanded(
                      // height: 800,
                      child: ReorderableGridView.count(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        header: [
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: const Image(
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
                  }
                },
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorAssset.mainColor,
                ),
                onPressed: () async {
                  print("pop될 이미지");
                  print(selectedImages);
                  final storageRef = FirebaseStorage.instance.ref();
                  print("su1>>${selectedImages}");

                  Navigator.pop(context, selectedImages);
                },
                child: Text('확인'),
              ),
            ],
          ),
        ));
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
