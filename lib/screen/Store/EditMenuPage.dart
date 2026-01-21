import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import '../../common/api/response/menu.dart';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EditMenuPage extends StatefulWidget {
  const EditMenuPage({Key? key, required this.storeId, this.menu, this.menuId})
      : super(key: key);
  final int storeId;
  final int? menuId;
  final Menu? menu;

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  // DatabaseService service = DatabaseService();
  TextEditingController menuNameInputController = TextEditingController();
  TextEditingController menuDescInputController = TextEditingController();
  TextEditingController menuPriceInputController = TextEditingController();
  File? _image;
  bool _isMenuImageLoading = false;

  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    print("menu id " + widget.menuId.toString());
    print("menu url ${widget.menu?.menu_image_url}");

    if (widget.menu != null) {
      menuNameInputController.text = widget.menu!.name;
      menuPriceInputController.text = widget.menu!.price.toString();
      menuDescInputController.text = widget.menu!.description;

      _fileFromImageUrl().then((value) => {
            setState(() {
              _image = value;
            })
          });
    }
  }

  final inputDecoration = InputDecoration(
    hintStyle: TextAssset.placeholder,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      // borderSide: const BorderSide(
      //   color: Colors.redAccent,
      //   width: 2,
      // ),
    ),
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(21, 14, 21, 18),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: const CommonAppBar(title: "메뉴 관리"),
            backgroundColor: Colors.white,
            body: Form(
              key: _formKey,
              child: Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: Container(
                            margin: EdgeInsets.fromLTRB(21, 10, 21, 21),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  menuImage(),
                                  Container(
                                    height: 15,
                                  ),
                                  //메뉴 이름
                                  Text("메뉴명"),
                                  TextFormField(
                                    controller: menuNameInputController,
                                    keyboardType: TextInputType.text,
                                    decoration: inputDecoration.copyWith(
                                        hintText: "메뉴명을 입력해 주세요"),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "메뉴명을 입력해 주세요";
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  //가격
                                  const Text("가격"),
                                  TextFormField(
                                    controller: menuPriceInputController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintStyle: TextAssset.placeholder,
                                      suffixText: '원',
                                      hintText: "${widget.menu?.price ?? ""}",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          21, 14, 21, 18),
                                    ),
                                    textAlign: TextAlign.end,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "메뉴금액을 입력해 주세요";
                                      }
                                      final price = int.tryParse(value);
                                      if (price == null) {
                                        return "숫자만 입력 가능합니다";
                                      }
                                      if (price > 50000) {
                                        return "메뉴 금액은 50,000원 이하만 가능합니다";
                                      }
                                      return null;
                                    },
                                  ),

                                  Container(
                                    height: 10,
                                  ),
                                  //설명
                                  const Text("설명"),
                                  TextFormField(
                                    controller: menuDescInputController,
                                    keyboardType: TextInputType.text,
                                    maxLines: null,
                                    maxLength: 200,
                                    decoration: inputDecoration.copyWith(
                                        hintText: "메뉴설명을 입력해 주세요(200자 이내)"),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "메뉴설명을 입력해 주세요";
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                ])))),
                // Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(21, 0, 21, 21),
                  child: Btns(context), // 버튼을 화면 아래로 배치
                ),
              ]),
            )));
  }

  Widget Btns(context) {
    bool isUpdated = widget.menuId != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorAssset.mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600)

                // minimumSize: const Size.fromHeight(50), // NEW
                ),
            onPressed: () {
              if (_image == null) {
                CommonDialog.show(
                    context: context,
                    title: "이미지를 등록해주세요",
                    content: "",
                    buttonText: "확인",
                    onPressed: () {});
                return;
              }
              if (_formKey.currentState!.validate()) {
                //메뉴 새로 등록
                var new_menu = Menu(
                    store_id: widget.storeId,
                    name: menuNameInputController.text,
                    menu_id: -1,
                    description: menuDescInputController.text,
                    price: int.parse(menuPriceInputController.text),
                    menu_image_url: "",
                    status: 1);

                if (isUpdated) {
                  //메뉴 수정
                  new_menu = Menu(
                      store_id: widget.storeId,
                      name: menuNameInputController.text,
                      menu_id: widget.menu!.menu_id,
                      description: menuDescInputController.text,
                      price: int.parse(menuPriceInputController.text),
                      menu_image_url: "",
                      status: 1);

                  Api()
                      .client
                      .updateMenu(new_menu.menu_id, new_menu)
                      .then((response) async => {
                            await uploadMenuImage(response.menu_put_url),
                            new_menu.menu_image_url = response.menu_get_url,
                            Navigator.pop(context, new_menu)
                          });
                } else {
                  //메뉴 등록
                  Api()
                      .client
                      .addMenu(new_menu.store_id, new_menu)
                      .then((response) async => {
                            await uploadMenuImage(response.menu_put_url),
                            new_menu.menu_image_url = response.menu_get_url,
                            Navigator.pop(context, new_menu)
                          });
                }
              }
            },
            child: const Text('확인'),
          ),
        ),
        const SizedBox(width: double.infinity, height: 5),
        if (isUpdated)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorAssset.mainColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                side: const BorderSide(
                  width: 1.0,
                  color: ColorAssset.mainColor,
                ),
              ),
              onPressed: () {
                CommonDialog.show(
                    context: context,
                    title: "메뉴를 삭제하시겠습니까",
                    content: "",
                    buttonText: "확인",
                    cancel: true,
                    onPressed: () {
                      Api().client.deleteMenu(widget.menu!.menu_id).then(
                          (response) =>
                              {Navigator.pop(context, widget.menu!.menu_id)});
                    });
              },
              child: const Text('메뉴 삭제'),
            ),
          )
      ],
    );
  }

  Widget menuImage() {
    bool isUpdated = widget.menuId != null;

    return GestureDetector(
        onTap: () async {
          pickMenuImage();
        },
        child: SizedBox(
          // width: double.infinity,
          height: 240,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 이미지가 중앙에 오도록 설정

            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_image == null)
                      if (isUpdated)
                        Image.network(widget.menu?.menu_image_url ?? "",
                            width: 200,
                            height: 200,
                            cacheWidth: 200,
                            cacheHeight: 200,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                          print("su>> Image load error: $error");
                          return Image.asset('assets/americano.jpeg',
                              width: 200, height: 200, fit: BoxFit.fill);
                        })
                      else
                        Image.asset(
                          'assets/americano.jpeg',
                          width: 200,
                          height: 200,
                        )
                    else
                      Image.file(
                        _image!,
                        fit: BoxFit.fill,
                        width: 200,
                        height: 200,
                      ),
                    const Text("이미지를 터치해 선택하세요.")
                  ]),
            ],
          ),
        ));
  }

  void pickMenuImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      print("pick image is not null");
      setState(() {
        _isMenuImageLoading = true; // 로딩 상태 시작
      });
      final fixedImage = await fixExifRotation(pickedImage.path);
      setState(() {
        _image = fixedImage;
        _isMenuImageLoading = false; // 로딩 상태 종료
      });
    } else {
      print("pick image is null");
    }
  }

  Future<void> uploadMenuImage(menu_upload_url) async {
    print("eidtMenu::uploadMenuImage");
    print(_image);

    if (_image == null) {
      print("menu image is null");
      return;
    }
    try {
      http.Response response = await http.put(
        Uri.parse(menu_upload_url),
        body: await _image?.readAsBytes(),
        headers: {
          // 'Content-Type': 'image/jpeg', // 이미지 파일 형식에 맞게 변경
        },
      );

      if (response.statusCode == 200) {
        // 이미지 업로드 성공
        print('Image uploaded successfully.');
      } else {
        // 이미지 업로드 실패
        print('Image upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<File> _fileFromImageUrl() async {
    final response =
        await http.get(Uri.parse('${widget.menu?.menu_image_url}'));

    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, 'menu.png'));
    file.writeAsBytesSync(response.bodyBytes);

    return file;
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
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage, quality: 50));

    return fixedFile;
  }
}
