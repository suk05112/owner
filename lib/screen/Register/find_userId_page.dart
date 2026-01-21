import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/utils/phone_utils.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/screen/Register/find_password_page.dart';
import 'dart:io';

import '../../common/widget/CommonWidget.dart';

class FindUserIDPage extends StatefulWidget {
  const FindUserIDPage({Key? key}) : super(key: key);

  @override
  State<FindUserIDPage> createState() => _FindUserIDPageState();
}

class _FindUserIDPageState extends State<FindUserIDPage> {
  TextEditingController inputIDController = TextEditingController();
  TextEditingController inputPhoneNumbfController = TextEditingController();

  final inputDecoration = const InputDecoration(
      border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(8.0),
          // borderSide: const BorderSide(
          //   color: Colors.redAccent,
          //   width: 2,
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("아이디 찾기"),
        ),
        body: Container(
            margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("이름 입력"),
              TextFormField(
                controller: inputIDController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(hintText: "이름"),
              ),
              Text("전화번호 입력"),
              TextFormField(
                controller: inputPhoneNumbfController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  NumberFormatter(), // 자동하이픈
                  LengthLimitingTextInputFormatter(13)
                ],
                decoration: inputDecoration.copyWith(hintText: "전화번호"),
              ),
              // PhoneNumberVerificationWidget(
              //   successCallback: showRegisteredId,
              // ),
              Spacer(),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    // 전화번호를 서버 형식으로 변환
                    String formattedPhone = PhoneUtils.formatForServer(inputPhoneNumbfController.text);
                    showRegisteredId(OwnerFind(
                        name: inputIDController.text,
                        phone_number: formattedPhone));
                  },
                  child: Text("확인"),
                ),
              ),
              SizedBox(
                height: 81,
              ) //전화번호
            ])));
  }

  //전화번호 인증 성공 후 uid 넘겨 받고, 이름, Uid 담아서 id response 로 받기
  showRegisteredId(OwnerFind ownerFind) async {
    try {
      var response = await Api().client.findOwnerId(ownerFind);

      if (response.owner_id != null) {
        print(
            "결과 값 ${response.owner_id}, ${response.created_time}, ${response.msg}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterdIDPage(
              email: response.email,
              created_time: response.created_time,
            ),
          ),
        );
      } else {
        CommonDialog.show(
            context: context,
            title: "입력된 정보가 올바르지 않습니다.",
            content: "다시한번 확인해주세요.",
            buttonText: "확인",
            onPressed: () {});
        print(response.msg);
      }
    } on DioException catch (e) {
      String errorMsg = "";
      if (e.response != null) {
        // 서버에서 받은 상태 코드에 따른 처리
        if (e.response!.statusCode == 401) {
          // 인증 실패
          print("인증 실패: ${e.response!.data}");
          errorMsg = "[401]인증에 실패했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else if (e.response!.statusCode == 500) {
          // 서버 오류
          print("서버 오류: ${e.response!.data}");
          errorMsg =
              "[500]서버에 오류가 발행했습니다.잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else {
          // 기타 오류
          print("기타 오류: ${e.response!.data}");
          errorMsg = "오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        }
      } else {
        // 네트워크 연결 실패 등
        print("네트워크 오류: ${e.message}");
        errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.message}";
      }

      CommonDialog.show(
          context: context,
          title: "아이디 찾기 실패",
          content: errorMsg,
          buttonText: "확인",
          onPressed: () {});
    }
    print("showRegisterdId");
  }
}

class RegisterdIDPage extends StatefulWidget {
  RegisterdIDPage({Key? key, this.email, this.created_time, this.msg})
      : super(key: key);

  final String? email;
  final String? created_time;
  final String? msg;

  @override
  State<RegisterdIDPage> createState() => _RegisterdIDPageState();
}

class _RegisterdIDPageState extends State<RegisterdIDPage> {
  TextEditingController inputIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("아이디 찾기"),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
          child: Column(
            // 세로 컬럼 생성
            mainAxisAlignment: MainAxisAlignment.center, // 새로축 가운데 정렬
            children: <Widget>[
              Spacer(),
              // 컬럼에 들어갈 위젯들
              const Text("가입 하신 아이디는 아래와 같습니다."),
              Container(
                  // color: ColorAssset.greyBackground,
                  width: double.infinity, // <-- match_parent

                  margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "아이디 : ${widget.email} \n가입일: ${widget.created_time}"),
                      ])),
              Spacer(),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindPasswordPage()),
                    );
                  },
                  child: Text("비밀번호 재설정하기"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text("로그인 하러 가기"),
                ),
              )
            ],
          ),
        ));
  }
}
