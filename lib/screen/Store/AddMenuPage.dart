import 'package:flutter/material.dart';
// import 'package:owner/common/DatabaseService.dart';
import 'package:owner/common/model/Menu.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({Key? key, required this.storeId}) : super(key: key);
  final String storeId;
  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  // DatabaseService service = DatabaseService();
  TextEditingController menuNameInputController = TextEditingController();
  TextEditingController menuDescInputController = TextEditingController();
  TextEditingController menuPriceInputController = TextEditingController();

  @override
  void dispose() {
    menuNameInputController.dispose();
    menuDescInputController.dispose();
    menuPriceInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("메뉴명"),
              TextFormField(
                controller: menuNameInputController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "빈 문자열";
                  }
                  return null;
                },
              ),
              const Text("설명"),
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
              const Text("가격"),
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
                  const Text("원")
                ],
              ),
              const Text("상태"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 151, 125, 253),
                  // minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () {
                  // service.addMenu(Menu(
                  //     name: "new menu",
                  //     menuId: "003",
                  //     storeId: "001",
                  //     description: "카페라떼",
                  //     price: 5000,
                  //     status: "판매",
                  //     categoryId: "001"));
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ]),
      ),
    );
  }
}
