import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';

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
          Text(widget.title),
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

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
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
  String _verificationId = "";
  bool isTouched = false;

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController validationNumberController = TextEditingController();

  final inputDecoration = InputDecoration(
    // isDense: true,
    // contentPadding: EdgeInsets.fromLTRB(27, 14, 21, 18),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        )),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              Text("휴대폰 번호"),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        // style: TextStyle(fontSize: 15, height: 0.1),
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          // FilteringTextInputFormatter.digitsOnly, //숫자만!
                          NumberFormatter(), // 자동하이픈
                          LengthLimitingTextInputFormatter(13)
                        ],
                        decoration: inputDecoration.copyWith(
                            hintText: "휴대폰 번호 입력(-제외)"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                              foregroundColor: Colors.white,
                              backgroundColor: ColorAssset.mainColor,
                              fixedSize: const Size(82, 55)),
                          onPressed: () {
                            setState(() {
                              isTouched = true;
                            });
                            // verifyPhoneNumber("+821012345678");
                            verifyPhoneNumber("+821025446458");
                          },
                          child: isTouched ? Text('재전송') : Text('인증'),
                        )),
                  ]),
              const SizedBox(height: 10.0),
              Visibility(
                  visible: isTouched,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: validationNumberController,
                            keyboardType: TextInputType.text,
                            decoration: inputDecoration.copyWith(
                              hintText: "인증번호를 입력하세요",
                              // contentPadding:
                              // const EdgeInsets.only(top: 1, bottom: 1, left: 6, right: 6),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
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
                                  foregroundColor: Colors.white,
                                  backgroundColor: ColorAssset.mainColor,
                                  fixedSize: const Size(82, 55)),
                              onPressed: () async {
                                PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(
                                        verificationId: _verificationId,
                                        smsCode:
                                            validationNumberController.text);
                                final authCredential = await _auth
                                    .signInWithCredential(credential);
                                try {
                                  if (authCredential.user != null) {
                                    setState(() {
                                      print("인증완료 및 로그인성공");
                                    });
                                    await _auth.currentUser!.delete();
                                    print("auth정보삭제");
                                    _auth.signOut();
                                    print("phone로그인된것 로그아웃");

                                    widget.successCallback(
                                        authCredential.user!.uid);
                                  }
                                }
                                // signInWithPhoneAuthCredential(phoneAuthCredential);
                                catch (e) {
                                  print('Error: $e');
                                }
                                ;
                              },
                              child: Text('인증확인'),
                            ))
                      ]))
            ]));
  }

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
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
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex <= 3) {
        if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
          buffer.write('-'); // Add double spaces.
        }
      } else {
        if (nonZeroIndex % 7 == 0 &&
            nonZeroIndex != text.length &&
            nonZeroIndex > 4) {
          buffer.write('-');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
