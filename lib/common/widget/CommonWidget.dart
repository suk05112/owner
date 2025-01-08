import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'dart:async'; // Import for Timer

class InputInfoWidget extends StatefulWidget {
  InputInfoWidget(
      {required this.title, required this.hintText, required this.validator});

  final String title;
  String hintText;
  Function(String?) validator;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Text(
            widget.title,
            style: TextAssset.header2,
          ),
          TextFormField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: widget.hintText),
            validator: (value) {
              return widget.validator(value);
            },
          ),
        ]);
  }

  final inputDecoration = const InputDecoration(
      hintStyle: TextAssset.placeholder,
      contentPadding: EdgeInsets.fromLTRB(0, 5, 21, 5),
      border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(8.0),
          )
      // border: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(8.0),
      //     borderSide: const BorderSide(
      //       color: Colors.redAccent,
      //       width: 2,
      //     ))
      );
}

void showModalDialog(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Text("dialog");
        // return LoplatDialogCenterConfirm(
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child : Padding(
        //             padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
        //             child: Center(
        //               child: Text(message, textAlign: TextAlign.center,
        //               style: const TextStyle(
        //                   color: Colors.black,
        //                   fontSize: 18,
        //                   fontFamily: 'AppleSDGothicNeo',
        //                     fontWeight: FontWeight.w700,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        //   confirmLabel: '확인',
        // );
      });
}

class PhoneNumberVerificationWidget extends StatefulWidget {
  PhoneNumberVerificationWidget({required this.successCallback});

  Function(String?) successCallback;

  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late PhoneAuthCredential credential;
  String _verificationId = "";
  String smsVerifyMsg = "";
  bool smsVerifyState = false;
  bool isTouched = false;

  late Timer _timer;
  int _remainingTime = 0;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController validationNumberController = TextEditingController();
  final phoneFormKey = GlobalKey<FormState>(); // Key for phone number form
  final validationFormKey = GlobalKey<FormState>();

  final inputDecoration = InputDecoration(
    // isDense: true,
    // contentPadding: EdgeInsets.fromLTRB(27, 14, 21, 18),
    border: UnderlineInputBorder(
        // borderRadius: BorderRadius.circular(8.0),
        // borderSide: const BorderSide(
        //   color: Colors.redAccent,
        //   width: 2,
        // )
        ),
  );

  void _startCountdown() {
    _remainingTime = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel(); // Stop the timer when it reaches zero
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Convert remaining time (seconds) to minutes and seconds
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;

    return SizedBox(
        width: double.infinity,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              const Text(
                "휴대폰 번호",
                style: TextAssset.header2,
              ),
              Form(
                key: phoneFormKey, // Wrap the input fields with the form
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          // style: TextStyle(fontSize: 15, height: 0.1),
                          enabled: !smsVerifyState,
                          controller: phoneNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            NumberFormatter(), // 자동하이픈
                            LengthLimitingTextInputFormatter(13)
                          ],
                          decoration: inputDecoration.copyWith(
                              hintText: "휴대폰 번호 입력(-제외)"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "잘못된 전화번호입니다. 다시 입력하세요";
                            }
                            if (value.length != 13) {
                              return "잘못된 전화번호입니다. 다시 입력하세요";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                foregroundColor: Colors.black,
                                backgroundColor:
                                    _remainingTime > 0 || smsVerifyState
                                        ? Colors.grey
                                        : Colors.white,
                                fixedSize: const Size(82, 55)),
                            onPressed: _remainingTime > 0 || smsVerifyState
                                ? null
                                : () {
                                    if (phoneFormKey.currentState?.validate() ??
                                        false) {
                                      setState(() {
                                        isTouched = true;
                                      });
                                      // verifyPhoneNumber("+821012345678");
                                      String rawPhoneNumber =
                                          phoneNumberController.text;
                                      rawPhoneNumber =
                                          rawPhoneNumber.replaceAll('-', '');
                                      if (rawPhoneNumber.startsWith("0")) {
                                        rawPhoneNumber = rawPhoneNumber
                                            .replaceFirst("0", "");
                                      }
                                      final phoneNumber = "+82$rawPhoneNumber";
                                      print(phoneNumber);
                                      verifyPhoneNumber(phoneNumber);
                                      _startCountdown();
                                    }
                                  },
                            child: isTouched
                                ? const Text('재전송')
                                : const Text('인증'),
                          )),
                    ]),
              ),
              const SizedBox(height: 10.0),
              Visibility(
                  visible: isTouched,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Form(
                          key: validationFormKey, // Form for validation input
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          enabled: !smsVerifyState,
                                          controller:
                                              validationNumberController,
                                          keyboardType: TextInputType.text,
                                          decoration: inputDecoration.copyWith(
                                            hintText: "인증번호를 입력하세요",
                                            // contentPadding:
                                            // const EdgeInsets.only(top: 1, bottom: 1, left: 6, right: 6),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "잘못된 인증번호입니다. 다시 입력하세요";
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                foregroundColor: Colors.white,
                                                backgroundColor: smsVerifyState
                                                    ? Colors.grey
                                                    : ColorAssset.mainColor,
                                                fixedSize: const Size(82, 55)),
                                            onPressed: smsVerifyState
                                                ? null
                                                : () async {
                                                    if (validationFormKey
                                                            .currentState
                                                            ?.validate() ??
                                                        false) {
                                                      credential = PhoneAuthProvider
                                                          .credential(
                                                              verificationId:
                                                                  _verificationId,
                                                              smsCode:
                                                                  validationNumberController
                                                                      .text);

                                                      final authCredential =
                                                          await _auth
                                                              .signInWithCredential(
                                                                  credential)
                                                              .catchError(
                                                                  (e) async {
                                                        print(
                                                            "signInWithCredential 실패");
                                                        print(e.message);
                                                        setState(() {
                                                          smsVerifyState =
                                                              false;
                                                          smsVerifyMsg =
                                                              "잘못된 인증번호입니다. 다시 입력하세요";
                                                        });
                                                      });
                                                      try {
                                                        if (authCredential
                                                                .user !=
                                                            null) {
                                                          setState(() {
                                                            print(
                                                                "인증완료 및 로그인성공");
                                                            smsVerifyMsg =
                                                                "인증이 완료되었습니다.";
                                                            smsVerifyState =
                                                                true;
                                                          });
                                                          await _auth
                                                              .currentUser!
                                                              .delete();
                                                          print("auth정보삭제");
                                                          _auth.signOut();
                                                          print(
                                                              "phone로그인된것 로그아웃");

                                                          widget.successCallback(
                                                              phoneNumberController
                                                                  .text);
                                                        } else {
                                                          setState(() {
                                                            smsVerifyMsg =
                                                                "잘못된 인증번호입니다. 다시 입력하세요";
                                                          });
                                                        }
                                                      } catch (e) {
                                                        print("여기 탐");
                                                        print('Error: $e');
                                                        setState(() {
                                                          smsVerifyState =
                                                              false;
                                                          smsVerifyMsg =
                                                              "문제가 발생했습니다. 다시 시도해주세요.";
                                                        });
                                                      }
                                                    }
                                                  },
                                            child: Text('인증확인'),
                                          ))
                                    ]),
                                smsVerifyState == true
                                    ? Text(
                                        smsVerifyMsg,
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(smsVerifyMsg,
                                        style: TextStyle(color: Colors.red))
                              ]),
                        ),
                        _remainingTime > 0 && !smsVerifyState
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                    Text("남은시간"),
                                    Text(
                                      "$minutes: $seconds",
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ])
                            : Text(smsVerifyState
                                ? ""
                                : "인증시간이 만료되었습니다. 다시 인증해주세요."),
                      ]))
            ]));
  }

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    print("verifyPhoneNumber 호출");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 인증 완료 콜백 함수
        print("전화번호 인증 완료");
        // await FirebaseAuth.instance.signInWithCredential(credential);
        FirebaseAuth.instance.signOut(); // 로그아웃 처리
      },
      verificationFailed: (FirebaseAuthException e) {
        print("전화번호 인증 실패");

        // 인증 실패 콜백 함수
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("코드 보내짐");
        print(verificationId);
        // 코드가 성공적으로 보내진 경우
        setState(() {
          this._verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("타임아웃");

        // 타임아웃 콜백 함수
        _verificationId = verificationId;
      },
    );
  }
}

//전화번호 입력시 자동 하이픈(-)
class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('-', ''); // 기존 하이픈 제거

    if (text.isEmpty) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 2 || i == 6) {
        // 3번째(인덱스 2)와 7번째(인덱스 6) 글자 뒤에 하이픈 추가
        if (i < text.length - 1) {
          buffer.write('-');
        }
      }
    }

    var formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
