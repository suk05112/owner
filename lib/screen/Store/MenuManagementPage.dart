import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:owner/common/DatabaseService.dart';
import 'package:owner/common/model/Menu.dart';
import 'package:owner/screen/Store/AddMenuPage.dart';
import 'package:owner/screen/Store/EditMenuPage.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({Key? key, required this.storeId});
  final String storeId;

  @override
  State<MenuManagementPage> createState() => _MenuManagementPagetate();
}

class _MenuManagementPagetate extends State<MenuManagementPage> {
  // DatabaseService service = DatabaseService();
  Future<List<Menu>>? menuList;
  List<Menu>? menu;
  var menuLength;

  final data = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _initRetrieval();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   print("widgetbinding 실행");
    //   menuList!.then(
    //     (value) {
    //       setState(() {
    //         menu = value;
    //       });
    //     },
    //   );
    // });
  }

  Future<void> _initRetrieval() async {
    print("이건 실행됨?");
    // menuList = service.retrieveMenu(widget.storeId);
    menuList!.then(
      (value) {
        setState(() {
          menu = value;
          menuLength = value.length;
          print("메뉴 수" + menuLength.toString());
        });
      },
    );
    // menu = await menuList;

    print("읽어온 메뉴" + menuLength.toString());
    print(menu![0].description);
  }

  Widget buildItem(String text) {
    return Card(
      key: ValueKey(text),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Container(
              height: 50,
            ),
            PopupMenuButton(
                // color: Colors.black,
                // add icon, by default "3 dot" icon
                icon: Icon(Icons.settings),
                // child: Text("text"),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text("메뉴 순서 변경"),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text("메뉴 추가"),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text("Logout"),
                    ),
                  ];
                },
                onSelected: (value) async {
                  if (value == 0) {
                    print("My account menu is selected.");
                  } else if (value == 1) {
                    print("menu id in manage" + await menuLength.toString());
                    final modified_menu = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditMenuPage(
                                  storeId: widget.storeId,
                                  menuId: menuLength.toString(),
                                )));

                    // service.addMenu(modified_menu);

                    print("메뉴 추가 선택됨");
                  } else if (value == 2) {
                    print("Logout menu is selected.");
                  }
                }),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: menu?.length ?? 0 + 1,
                itemBuilder: (BuildContext context, int index) {
                  menuLength = index;
                  // if (index == 0) return HeaderTile();
                  if (menu == null) {
                    print("in listview");
                    print(menu);
                    return CircularProgressIndicator();
                  }
                  if (index == (menu?.length ?? 1)) {
                    return TextButton(
                      onPressed: () {},
                      child: Text("메뉴 추가"),
                    );
                  }
                  ;
                  return InkWell(
                      onTap: () async {
                        final modified_menu = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditMenuPage(
                                      menu: menu![index],
                                      storeId: menu![index].storeId ?? "001",
                                    )));
                        // service.addMenu(modified_menu);
                      },
                      child: ListTile(
                        title: Text("${menu?[index].description}"),
                      ));
                },
              ),
            ),
            // Expanded(child: const ReorderableExample()),
            Container(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ),
          ])),
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});
  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  final List<int> _items = List<int>.generate(50, (int index) => index);
  // DatabaseService service = DatabaseService();
  Future<List<Menu>>? menuList;
  late String _storeId;

  @override
  void initState() {
    super.initState();
    // _storeId = widget.storeId;
    // cafeList = service.retrieveCafeInfo("0000001");
    // print(" _initRetrieval 호출2 ${cafeList}");
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    print("이건 실행됨?");
    // menuList = service.retrieveMenu(_storeId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.secondary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.secondary.withOpacity(0.15);
    final Color draggableItemColor = colorScheme.secondary;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: draggableItemColor,
            shadowColor: draggableItemColor,
            child: child,
          );
        },
        child: child,
      );
    }

    return ReorderableListView(
      // padding: const EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.all(10),

      proxyDecorator: proxyDecorator,
      children: <Widget>[
        Container(
          height: 500,
          key: Key('dafd'),
          child: FutureBuilder<List<Menu>>(
              future: menuList,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Menu>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        key: Key('$index'),
                        // tileColor: snapshot.data![index].isOdd
                        //     ? oddItemColor
                        //     : evenItemColor,
                        title:
                            Text('Item ${snapshot.data![index].description}'),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      if (index == 0)
                        return SizedBox.shrink(
                          key: Key('$index'),
                        );
                      return Divider(
                        key: Key('$index'),
                      );
                    },
                  );
                } else {
                  print("여기 걸림ㅜㅜ");
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ],

      // <Widget>[
      //   for (int index = 0; index < widget.menu.length; index += 1)
      //     ListTile(
      //       key: Key('$index'),
      //       tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
      //       title: Text('Item ${_items[index]}'),
      //     ),
      // ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
    );
  }
}
