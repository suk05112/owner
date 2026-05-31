import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';


class PhotoUploadePage extends StatefulWidget {
  const PhotoUploadePage(
      {super.key, required this.savedImageUrl, required this.storeImage});
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

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> _initRetrieval() async {
    // selectedImages = widget.savedImage;
    // widget.savedImageUrl.asMap().forEach((idx, url) async {
    //   selectedImages.add(await getImageFileFromUrl(url, idx));
    // });

    // await Future.wait(widget.savedImageUrl.asMap().entries.map((e) async {
    // var idx = e.key;
    // var url = e.value;

    // var imageFile = await getImageFileFromUrl(url, idx);
    // var resizedImage = await resizeImage(imageFile, 500, 500);
    // selectedImages.add(resizedImage);
    // selectedImages = selectedImages;
    // setState(() {}); // UI 업데이트

    selectedImages = await Future.wait(
      widget.savedImageUrl.asMap().entries.map((e) async {
        var idx = e.key;
        var url = e.value;
        return await getImageFileFromUrl(url, idx);
      }),
    );

    setState(() {}); // 최종 UI 갱신

    // selectedImages.add(await getImageFileFromUrl(url, idx));
    // setState(() async {
    // });
    // }
    // )
    // );

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

  Future<File> getImageFileFromUrl(String imageUrl, int idx) async {
    // 이미지 URL을 사용하여 이미지 파일을 가져옵니다.
    // 예: https://example.com/image.jpg
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    final tempFile =
        File('${(await getTemporaryDirectory()).path}/image_$idx.jpeg');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  static const int _maxImages = 10;

  Future getImage() async {
    final remaining = _maxImages - selectedImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진은 최대 10장까지 업로드할 수 있습니다.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final pickedFile = await picker.pickMultiImage(
      imageQuality: 100,
    );
    List<XFile> xfilePick = pickedFile;

    if (xfilePick.isNotEmpty) {
      final limited = xfilePick.take(remaining).toList();
      if (xfilePick.length > remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최대 10장까지만 업로드 가능해서 $remaining장만 추가되었습니다.')),
        );
      }
      for (var xfile in limited) {
        selectedImages.add(await fixExifRotation(xfile.path));
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
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
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage, quality: 100));

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
      void deleteImage(int index) {
        print("run _deleteImage");

        setState(() {
          selectedImages.removeAt(index);
        });
      }

      return ClipRRect(
        key: ValueKey(path),
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(path.path),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  print("touch delete icon");
                  deleteImage(index);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
        appBar: const CommonAppBar(title: "매장사진 업로드"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "매장 사진을 업로드해주세요",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "최대 10장 · 드래그하여 순서 변경 가능",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<File>>(
                    future: _loadImages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        print("connection done");
                      }
                      if ((snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              isInit == false) ||
                          (isLoading == true)) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorAssset.mainColor),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "이미지를 불러오는 중...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                '오류가 발생했습니다: ${snapshot.error}',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        isInit = true;

                        selectedImages = isInit == false
                            ? (snapshot.data ?? [])
                                .map((file) => file.path)
                                .toSet()
                                .map((path) => File(path))
                                .toList()
                            : selectedImages
                                .map((file) => file.path)
                                .toSet()
                                .map((path) => File(path))
                                .toList();

                        print(
                            "build:: ${selectedImages.map((file) => file.path).toList()}");
                        return ReorderableGridView.count(
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          crossAxisCount: 3,
                          header: [
                            GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      size: 32,
                                      color: ColorAssset.mainColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "사진 추가",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                          children: selectedImages
                              .toSet()
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final image = entry.value;
                            return selectedImg(image, index);
                          }).toList(),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              final element = selectedImages.removeAt(oldIndex);
                              selectedImages.insert(newIndex, element);
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: ColorAssset.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      print("pop될 이미지");
                      print(selectedImages);
                      final storageRef = FirebaseStorage.instance.ref();
                      print("su1>>$selectedImages");

                      Navigator.pop(context, selectedImages);
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          WidgetStateProperty.all<Color>(const Color.fromARGB(255, 0, 0, 0)),
      backgroundColor: WidgetStateProperty.all<Color>(
          const Color.fromARGB(255, 154, 152, 152)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))));
}
