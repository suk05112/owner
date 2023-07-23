import 'package:flutter/material.dart';
// import 'package:owner/common/DatabaseService.dart';
import 'package:owner/common/model/Menu.dart';

class EditMenuPage extends StatefulWidget {
  const EditMenuPage({Key? key, required this.storeId, this.menu, this.menuId})
      : super(key: key);
  final String storeId;
  final String? menuId;
  final Menu? menu;

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  // DatabaseService service = DatabaseService();
  TextEditingController menuNameInputController = TextEditingController();
  TextEditingController menuDescInputController = TextEditingController();
  TextEditingController menuPriceInputController = TextEditingController();

  void initState() {
    super.initState();
    print("menu id " + widget.menuId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("메뉴수정"),
              TextFormField(
                controller: menuNameInputController,
                keyboardType: TextInputType.text,
                decoration:
                    InputDecoration(hintText: "${widget.menu?.description}"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),
              Text("설명"),
              TextFormField(
                controller: menuDescInputController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),
              Text("가격"),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: menuPriceInputController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "빈 문자열";
                        }
                        return null;
                      },
                    ),
                  ),
                  Text("원")
                ],
              ),
              Text("상태"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 151, 125, 253),
                  // minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () {
                  if (widget.menu == null) {
                    var new_menu = Menu(
                        name: menuNameInputController.text,
                        menuId: widget.menuId,
                        storeId: widget.storeId,
                        description: menuDescInputController.text,
                        price: int.parse(menuPriceInputController.text),
                        status: "판매",
                        categoryId: "001");

                    Navigator.pop(context, new_menu);
                  } else {
                    var new_menu = Menu(
                        name: menuNameInputController.text,
                        menuId: widget.menuId.toString(),
                        storeId: widget.storeId,
                        description: menuDescInputController.text,
                        price: int.parse(menuPriceInputController.text),
                        status: "판매",
                        categoryId: "001");

                    Navigator.pop(context, new_menu);
                  }
                },
                child: Text('확인'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 151, 125, 253),
                  // minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('이전'),
              ),
            ]),
      ),
    );
  }
}
