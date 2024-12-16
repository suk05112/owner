import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import '../../common/api/response/menu.dart';

import 'package:http/http.dart' as http;
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("메뉴 관리"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.fromLTRB(21, 10, 21, 21),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                decoration: inputDecoration.copyWith(hintText: "메뉴명을 입력해 주세요"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),
              Container(
                height: 15,
              ),
              //가격
              Text("가격"),
              TextFormField(
                controller: menuPriceInputController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintStyle: TextAssset.placeholder,
                  suffixText: '원',
                  hintText: "${widget.menu?.price}",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(21, 14, 21, 18),
                ),
                textAlign: TextAlign.end,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),

              Container(
                height: 15,
              ),
              //설명
              Text("설명"),
              TextFormField(
                controller: menuDescInputController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "메뉴설명을 입력해 주세요"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),
              Container(
                height: 15,
              ),

              Text("상태"),

              Spacer(),
              Btns(context)
            ]),
      )),
    );
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
                textStyle: TextStyle(fontWeight: FontWeight.w600)

                // minimumSize: const Size.fromHeight(50), // NEW
                ),
            onPressed: () {
              //메뉴 새로 등록
              var new_menu = Menu(
                  store_id: 1,
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
            },
            child: Text('확인'),
          ),
        ),
        SizedBox(width: double.infinity, height: 5),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ColorAssset.mainColor,
              // minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () {
              Api().client.deleteMenu(widget.menu!.menu_id).then(
                  (response) => {Navigator.pop(context, widget.menu!.menu_id)});
            },
            child: Text('메뉴 삭제'),
          ),
        )
      ],
    );
  }

  Widget menuImage() {
    return GestureDetector(
        onTap: () async {
          pickMenuImage();
        },
        child: Container(
          width: 100,
          height: 100,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _image == null
                ? Image.asset('assets/americano.jpeg')
                : Image.network(widget.menu?.menu_image_url ?? "",
                    width: 90, height: 90, fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                    return Image(
                        image: AssetImage('assets/logo.jpeg'),
                        width: 90,
                        height: 90,
                        fit: BoxFit.fill);
                  })
          ]),
        ));
  }

  void pickMenuImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
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
}
