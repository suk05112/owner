import 'package:flutter/material.dart';
import 'package:owner/common/Style/TextAsset.dart';
// import 'package:owner/common/DatabaseService.dart';
// import 'package:owner/common/model/Menu.dart';
import '../../common/api/response/menu.dart';

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

  void initState() {
    super.initState();
    print("menu id " + widget.menuId.toString());
    if (widget.menu != null) {
      menuNameInputController.text = widget.menu!.name;
      menuPriceInputController.text = widget.menu!.price.toString();
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
              // Text("메뉴수정"),
              Container(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                          image: AssetImage('assets/americano.jpeg'),
                          height: 200),
                    ]),
              ),

              Container(
                height: 15,
              ),
              //메뉴 이름
              Text("메뉴명"),
              TextFormField(
                controller: menuNameInputController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(
                    hintText: "${widget.menu?.description}"),
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
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: menuPriceInputController,
                      keyboardType: TextInputType.text,
                      decoration: inputDecoration.copyWith(
                          hintText: "${widget.menu?.price}"),
                      textAlign: TextAlign.end,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "빈 문자열";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    width: 5,
                  ),
                  Text("원")
                ],
              ),
              Container(
                height: 15,
              ),
              //설명
              Text("설명"),
              TextFormField(
                controller: menuDescInputController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(
                    hintText: "${widget.menu?.description}"),
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
              Btns()
            ]),
      )),
    );
  }

  Widget Btns() {
    return Container(
        width: double.infinity,
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // <-- Your width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      // minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      if (widget.menu == null) {
                        var new_menu = Menu(
                            name: menuNameInputController.text,
                            menu_Id: widget.menuId ?? -1,
                            description: menuDescInputController.text,
                            price: int.parse(menuPriceInputController.text),
                            status: 1);

                        Navigator.pop(context, new_menu);
                      } else {
                        var new_menu = Menu(
                            name: menuNameInputController.text,
                            menu_Id: widget.menuId ?? -1,
                            description: menuDescInputController.text,
                            price: int.parse(menuPriceInputController.text),
                            status: 2);

                        Navigator.pop(context, new_menu);
                      }
                    },
                    child: Text('확인'),
                  ),
                )),
            SizedBox(
              width: 10,
            ),
            Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // <-- Your width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      // minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('이전'),
                  ),
                ))
          ],
        ));
  }
}
