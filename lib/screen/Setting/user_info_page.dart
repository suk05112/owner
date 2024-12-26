import "package:flutter/material.dart";
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:provider/provider.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("내정보"),
      ),
      body: SafeArea(
          bottom: false,
          child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Text("내정보"),
                    Container(
                      width: double.infinity,
                      // height: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              SizedBox(
                                width: 100,
                                child: Text("이름"),
                              ),
                              Text("${user?.name}")
                            ]),
                            Row(children: [
                              SizedBox(
                                width: 100,
                                child: Text("이메일"),
                              ),
                              Text("${user?.email ?? "email"}")
                            ]),
                            Row(children: [
                              SizedBox(
                                width: 100,
                                child: Text("전화번호"),
                              ),
                              Text("${user?.phone_number ?? "phone"}")
                            ]),
                          ]),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(thickness: 1, height: 1, color: Colors.grey),
                    Row(children: [
                      TextButton(
                          onPressed: () {
                            Provider.of<UserProvider>(context, listen: false)
                                .clearUser();

                            // Navigator.of(context).pushAndRemoveUntil(
                            //     MaterialPageRoute(
                            //         builder: (context) => TabPage()),
                            //     (route) => false);
                          },
                          child: Text('로그아웃')),
                      Spacer()
                    ]),
                    Divider(thickness: 1, height: 1, color: Colors.grey),
                    Row(children: [
                      TextButton(
                          onPressed: () {
                            print("눌림");
                            _showWithdrawalDialog();
                          },
                          child: Text('회원탈퇴'))
                    ]),
                    SizedBox(
                      height: 30,
                    )
                  ]))),
    );
  }

  // 회원탈퇴 위젯
  void _showWithdrawalDialog() {
    TextEditingController inputController = TextEditingController();
    bool showingFail = false;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                content: Container(
              width: 500,
              height: 250,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("탈퇴하시겠습니끼?"),
                  Text("'회원탈퇴' 입력"),
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: '회원탈퇴',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  Visibility(
                    child: Text(
                      "'회원탈퇴' 입력창을 다시 확인해주세요",
                      style:
                          TextStyle(color: Colors.red), // 원하는 스타일을 적용할 수 있습니다.
                    ),
                    visible: showingFail,
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('탈퇴하기'),

                          // 클릭 이벤트
                          onPressed: () async {
                            print("버튼 눌림");
                            if (inputController.text == '탈퇴하기') {
                            } else {
                              setState(() {
                                print("버튼 눌림2");

                                showingFail = true;
                              });
                            }
                          },
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('취소'),

                          // 클릭 이벤트
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
          });
        });
  }
}
