import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Store/EditMenuPage.dart';
import '../../common/api/response/menu.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<MenuManagementPage> createState() => _MenuManagementPagetate();
}

class _MenuManagementPagetate extends State<MenuManagementPage> {
  // DatabaseService service = DatabaseService();
  // Future<List<Menu>>? menuList;
  List<Menu>? menu;
  var menuLength;
  late int _storeId;

  final data = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    _initRetrieval();
    print("menu page sotreId: ${widget.storeId}");
  }

  Future<void> _initRetrieval() async {
    await Api().client.getMenuList(_storeId).then((value) => setState(() {
          menu = value.menuList;
          menuLength = value;
        }));
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
      appBar: const CommonAppBar(title: "메뉴 관리"),
      backgroundColor: Colors.white,
      body: menu == null
          ? const Center(
              child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ))
          : menu!.isEmpty
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorAssset.mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditMenuPage(
                                        storeId: widget.storeId,
                                      )));

                          if (result.runtimeType == Menu) {
                            setState(() {
                              menu!.add(result);
                            });
                          }
                        },
                        child: const Text("메뉴 추가"),
                      )
                    ],
                  ))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: menu!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == menu!.length) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorAssset.mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditMenuPage(
                                        storeId: widget.storeId,
                                      )));

                          if (result.runtimeType == Menu) {
                            setState(() {
                              menu!.add(result);
                            });
                          }
                        },
                        child: const Text("메뉴 추가"),
                      );
                    }
                    return InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMenuPage(
                              menu: menu![index],
                              storeId: _storeId,
                              menuId: menu![index].menu_id,
                            ),
                          ),
                        );
                        if (result.runtimeType == Menu) {
                          setState(() {
                            menu![index] = result;
                          });
                        } else if (result.runtimeType == int) {
                          setState(() {
                            menu!.removeWhere((item) => item.menu_id == result);
                          });
                        }
                      },
                      child: MenuItem(menu![index]),
                    );
                  },
                ),
    );
  }

  Widget PopupMenu() {
    return Container(
      // width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PopupMenuButton(
              // color: Colors.black,
              // add icon, by default "3 dot" icon
              icon: const Icon(Icons.settings),
              // child: Text("text"),
              itemBuilder: (context) {
                return [
                  // PopupMenuItem<int>(
                  //   value: 0,
                  //   child: Text("메뉴 순서 변경"),
                  // ),
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("메뉴 추가"),
                  ),
                  // PopupMenuItem<int>(
                  //   value: 2,
                  //   child: Text("Logout"),
                  // ),
                ];
              },
              onSelected: (value) async {
                if (value == 0) {
                  final modifiedMenu = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditMenuPage(
                                storeId: widget.storeId,
                              )));
                  setState(() {
                    print("메뉴 수정 완료");
                    menu!.add(modifiedMenu);
                  });
                  print("My account menu is selected.");
                } else if (value == 1) {
                  print("menu id in manage${await menuLength.toString()}");
                } else if (value == 2) {
                  print("Logout menu is selected.");
                }
              })
        ],
      ),
    );
  }

  Widget MenuItem(Menu menu) {
    print("MenuItem: ${menu.menu_image_url}");

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(menu.menu_image_url,
                headers: const {
                  "Cache-Control": "no-cache",
                },
                width: 90,
                height: 90,
                cacheWidth: 100,
                cacheHeight: 100,
                fit: BoxFit.fill, errorBuilder: (context, error, stackTrace) {
              print("Image load failed: $error");

              return const Image(
                  image: AssetImage('assets/americano.jpeg'),
                  width: 90,
                  height: 90,
                  fit: BoxFit.fill);
            }),
            // Image(image: AssetImage('assets/americano.jpeg'), height: 100),
            Container(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(menu.name), Text("${menu.price}원")],
            )
          ],
        ));
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
      padding: const EdgeInsets.all(10),

      proxyDecorator: proxyDecorator,
      children: <Widget>[
        SizedBox(
          height: 500,
          key: const Key('dafd'),
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
                      if (index == 0) {
                        return SizedBox.shrink(
                          key: Key('$index'),
                        );
                      }
                      return Divider(
                        key: Key('$index'),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ));
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
