import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/utils/image_util.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/common/widget/store_image.dart';
import '../../common/api/response/menu.dart';

import 'package:http/http.dart' as http;


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
  bool _imageRemoved = false;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("menu id ${widget.menuId}");
    print("menu url ${widget.menu?.menu_image_url}");

    if (widget.menu != null) {
      menuNameInputController.text = widget.menu!.name;
      menuPriceInputController.text = widget.menu!.price.toString();
      menuDescInputController.text = widget.menu!.description;
    }
  }

  @override
  void dispose() {
    menuNameInputController.dispose();
    menuDescInputController.dispose();
    menuPriceInputController.dispose();
    super.dispose();
  }

  final inputDecoration = InputDecoration(
    hintStyle: TextAssset.placeholder,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.fromLTRB(21, 14, 21, 18),
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
                            margin: const EdgeInsets.fromLTRB(21, 10, 21, 21),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  menuImage(),
                                  Container(
                                    height: 15,
                                  ),
                                  //메뉴 이름
                                  const Text("메뉴명"),
                                  TextFormField(
                                    controller: menuNameInputController,
                                    keyboardType: TextInputType.text,
                                    decoration: inputDecoration.copyWith(
                                        hintText: "메뉴명을 입력해 주세요"),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
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
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                                      ),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(21, 14, 21, 18),
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
                                      if (price < 100) {
                                        return "메뉴 금액은 100원 이상이어야 합니다";
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
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSubmitting = true);
                    try {
                      var newMenu = Menu(
                          store_id: widget.storeId,
                          name: menuNameInputController.text,
                          menu_id: isUpdated ? widget.menu!.menu_id : -1,
                          description: menuDescInputController.text,
                          price: int.parse(menuPriceInputController.text),
                          status: 'ACTIVE');

                      if (isUpdated) {
                        if (_imageRemoved) newMenu.delete_image = true;
                        if (_image != null && !_imageRemoved) {
                          newMenu.change_image = true;
                        }
                        final response = await Api()
                            .client
                            .updateMenu(newMenu.menu_id, newMenu);
                        if (_image != null &&
                            !_imageRemoved &&
                            response.menu_put_url != null) {
                          await uploadMenuImage(response.menu_put_url!);
                          newMenu.menu_image_url = response.menu_get_url;
                          // 이미지를 교체한 경우, 같은 URL 재사용 시에도 새 이미지가
                          // 보이도록 캐시를 무효화한다.
                          await CachedNetworkImage.evictFromCache(
                              response.menu_get_url!);
                        } else if (_imageRemoved) {
                          newMenu.menu_image_url = null;
                        } else {
                          newMenu.menu_image_url = widget.menu?.menu_image_url;
                        }
                      } else {
                        final response = await Api()
                            .client
                            .addMenu(widget.storeId, newMenu);
                        newMenu.menu_id = response.menu_id;
                        if (_image != null) {
                          await uploadMenuImage(response.menu_put_url);
                          newMenu.menu_image_url = response.menu_get_url;
                        }
                      }
                      if (mounted) Navigator.pop(context, newMenu);
                    } catch (e) {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('확인'),
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
                    onPressed: () async {
                      try {
                        await Api().client.deleteMenu(widget.menu!.menu_id);
                        if (context.mounted) Navigator.pop(context, widget.menu!.menu_id);
                      } catch (e) {
                        if (context.mounted) {
                          CommonDialog.show(
                            context: context,
                            title: "삭제 실패",
                            content: "메뉴 삭제에 실패했습니다.\n다시 시도해 주세요.",
                            buttonText: "확인",
                            cancel: false,
                            onPressed: () {},
                          );
                        }
                      }
                    });
              },
              child: const Text('메뉴 삭제'),
            ),
          )
      ],
    );
  }

  static const Color _borderColor = Color(0xFFE6E6E6);
  static const Color _hintColor = Color(0xFF808080);

  Widget menuImage() {
    bool isUpdated = widget.menuId != null;
    final hasImage = _image != null ||
        (isUpdated && !_imageRemoved && (widget.menu?.menu_image_url ?? '').isNotEmpty);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: pickMenuImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          ),
                        )
                      : isUpdated && !_imageRemoved
                          ? StoreImage(
                              url: widget.menu?.menu_image_url ?? "",
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                              errorWidget: _emptyImagePlaceholder(),
                            )
                          : _emptyImagePlaceholder(),
                ),
              ),
              if (hasImage)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _image = null;
                        _imageRemoved = true;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "이미지를 터치해 선택하세요.",
            style: TextStyle(fontSize: 13, color: _hintColor),
          ),
        ],
      ),
    );
  }

  Widget _emptyImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.camera_alt_outlined, size: 40, color: _hintColor),
        SizedBox(height: 8),
        Text(
          "사진 추가",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: _hintColor,
          ),
        ),
      ],
    );
  }

  void pickMenuImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);

    if (pickedImage != null) {
      print("pick image is not null");
      // 선택 시엔 원본을 그대로 미리보기로 사용 (무거운 처리는 업로드 직전 1회)
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      print("pick image is null");
    }
  }

  Future<void> uploadMenuImage(menuUploadUrl) async {
    print("eidtMenu::uploadMenuImage");
    print(_image);

    if (_image == null) {
      print("menu image is null");
      return;
    }
    try {
      // 업로드 직전 리사이즈/압축 (긴 변 1280px, JPEG 85%)
      final uploadFile = await prepareUploadImage(_image!.path);
      http.Response response = await http.put(
        Uri.parse(menuUploadUrl),
        body: await uploadFile.readAsBytes(),
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
}
