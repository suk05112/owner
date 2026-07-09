import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:http/http.dart' as http;


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

  bool isLoading = false; // Track loading state (사진 선택 중)
  bool _isInitLoading = true; // 저장된 이미지 최초 로딩 중

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  /// 저장된 매장 사진 URL을 파일로 1회만 내려받는다.
  /// (build()에서 매 리빌드마다 재다운로드하던 문제를 제거)
  Future<void> _loadSavedImages() async {
    final images = await Future.wait(
      widget.savedImageUrl.asMap().entries.map((e) async {
        return await getImageFileFromUrl(e.value, e.key);
      }),
    );
    if (!mounted) return;
    setState(() {
      selectedImages = images;
      _isInitLoading = false;
    });
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
        selectedImages.add(File(xfile.path));
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
                  child: Builder(
                    builder: (context) {
                      if (_isInitLoading || isLoading) {
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
                      } else {
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
