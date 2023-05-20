import 'dart:async';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/api/Provider.dart';
import 'package:owner/common/model/request/OwnerPost.dart';

import 'DocumentInputPage.dart';
import 'SingUpCompletePage.dart';

class BasicInfoInputPage extends StatefulWidget {
  const BasicInfoInputPage({Key? key}) : super(key: key);

  @override
  State<BasicInfoInputPage> createState() => _BasicInfoInputPageState();
}

class _BasicInfoInputPageState extends State<BasicInfoInputPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("가입하기"),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [BasicInfoFormWidget()])));
  }
}

class BasicInfoFormWidget extends StatefulWidget {
  const BasicInfoFormWidget({Key? key}) : super(key: key);

  @override
  State<BasicInfoFormWidget> createState() => _BasicInfoFormWidgetState();
}

class _BasicInfoFormWidgetState extends State<BasicInfoFormWidget> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InputInfoWidget(
                title: "이름",
                hintText: "Enter your name",
                validator: validateName,
              ),
              PhoneNumberVerificationWidget(), //전화번호
              IDVerificationWidget(), //아이디
              InputInfoWidget(
                title: "비밀번호",
                hintText: "Enter your email",
                validator: validatePhoneNumber,
              ),
              InputInfoWidget(
                title: "비밀번호 확인",
                hintText: "Enter your email",
                validator: validatePhoneNumber,
              ),
              InputInfoWidget(
                title: "이메일",
                hintText: "Enter your email",
                validator: validatePhoneNumber,
              ),
              TextButton(
                onPressed: () async {
                  _formKey.currentState?.validate();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpCompletePage()));
                },
                child: Text("가입하기"),
              ),

              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                width: double.infinity,
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity, // <-- Your width
                          height: 50,
                          // width: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 151, 125, 253),
                              // minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('이전'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          width: double.infinity, // <-- Your width
                          height: 50,
                          // width: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 151, 125, 253),
                              // minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: () async {
                              AggregateQuerySnapshot _myDocCnt =
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .count()
                                      .get();
                              debugPrint(
                                  'The number of users: ${_myDocCnt.count}');
                              _formKey.currentState?.validate();
                              print("pw");
                              print(pwController.text);
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: "sujineami1l3@nav.com",
                                            password: "pw1234")
                                        .then((value) async {
                                  print("됨?");
                                  if (value.user!.email != null) {
                                    print("됨?2");
                                    FirebaseAuth.instance.currentUser!
                                        .updateDisplayName("displayName");
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(value.user!.uid)
                                        .set({
                                      'userName': "sujin",
                                      'email': idController.text,
                                      'storeId': "0000000"
                                              .substring(7 - _myDocCnt.count) +
                                          _myDocCnt.count.toString(),
                                    });
                                  } else {
                                    print("여기 걸림"); // Navigator.pop(context);
                                  }
                                  return value;
                                });
                                FirebaseAuth.instance.currentUser
                                    ?.sendEmailVerification();
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  print('the password provided is too weak');
                                } else if (e.code == 'email-already-in-use') {
                                  print(
                                      'The account already exists for that email.');
                                } else {
                                  print(e.code);
                                  print('11111');
                                }
                              } catch (e) {
                                print('끝');
                              }
                              ;

                              final prov = Provider();
                              OwnerPost body = OwnerPost(
                                  uid: "flutter uid",
                                  password: "flutter pw",
                                  phone: "flutter phone",
                                  name: "sujinnn",
                                  bankbook: "aldjfladf");
                              // prov.postRequest(body);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             DocumentInputPage()));
                            },
                            child: Text('확인'),
                          ),
                        ),
                      ),
                    ]),
              ),
            ])));
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }
}

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

class PhoneNumberVerificationWidget extends StatefulWidget {
  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController validationNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Text("전화번호"),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Expanded(
              flex: 3,
              child: TextFormField(
                // style: TextStyle(fontSize: 15, height: 0.1),
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, //숫자만!
                  NumberFormatter(), // 자동하이픈
                  LengthLimitingTextInputFormatter(13)
                ],
                decoration: inputDecoration.copyWith(hintText: "전화번호를 입력하세요"),
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
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    verifyPhoneNumber("+821025446458");
                  },
                  child: Text('인증'),
                )),
          ]),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: validationNumberController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(
              hintText: "인증번호를 입력하세요",
              contentPadding:
                  const EdgeInsets.only(top: 1, bottom: 1, left: 6, right: 6),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "잘못된 인증번호입니다. 다시 입력하세요";
              }
              return null;
            },
          ),
          ElevatedButton(
            // style: ElevatedButton.styleFrom(
            //   foregroundColor: Colors.white,
            //   backgroundColor: Color.fromARGB(255, 0, 64, 255),
            // ),
            onPressed: () async {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: validationNumberController.text);
              final authCredential =
                  await _auth.signInWithCredential(credential);
              try {
                if (authCredential.user != null) {
                  setState(() {
                    print("인증완료 및 로그인성공");
                  });
                  await _auth.currentUser!.delete();
                  print("auth정보삭제");
                  _auth.signOut();
                  print("phone로그인된것 로그아웃");
                }
              }
              // signInWithPhoneAuthCredential(phoneAuthCredential);
              catch (e) {
                print('Error: $e');
              }
              ;
            },
            child: Text('인증확인'),
          )
        ]);
  }

  final inputDecoration = InputDecoration(
    // isDense: true,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        )),
  );

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

// 이메일과 비밀번호를 사용하여 Firebase Authentication에 새 사용자를 만듭니다.
  void signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // if (userCredential.additionalUserInfo!.isNewUser) {
      //   userCredential(AdditionalUserInfo(isNewUser: false, username: "addinfon"))
      // }
      String userId = userCredential.user!.uid;
      // Firestore에 사용자 정보를 저장합니다.
      // await FirebaseFirestore.instance.collection('users').doc(userId).set({
      //   'email': email,
      //   'phoneNumber': userCredential.user.phoneNumber,
      // });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
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

class IDVerificationWidget extends StatefulWidget {
  @override
  State<IDVerificationWidget> createState() => _IDVerificationWidgetState();
}

class _IDVerificationWidgetState extends State<IDVerificationWidget> {
  TextEditingController idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var hasRecipe = false;
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              Text("이메일"),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      // style: TextStyle(fontSize: 15, height: 0.1),
                      controller: idController,
                      keyboardType: TextInputType.number,

                      decoration:
                          inputDecoration.copyWith(hintText: "아이디를 입력하세요"),
                      onChanged: (text) async {
                        final check = await checkEmail(text);
                        setState(() => hasRecipe = check);
                      },
                      // validator: (_) => (hasRecipe) ? "Exists" : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "잘못된 이메일입니다. 다시 입력하세요";
                        }

                        if (hasRecipe == false) {
                          return "중복된 이메일 입니다. 다른 이메일을 입력해주세요.";
                        }

                        validateId(value);

                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 151, 125, 253),
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      onPressed: () {
                        _formKey.currentState?.validate();
                      },
                      child: Text('중복 확인'),
                    ),
                  ),
                ],
              )
            ]));
  }

  Future<String?> validateId(String? value) async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }

    bool? check;

    var value1 = await checkEmail(value);

    if (value1 == false) {
      print("값 걸림");
    } else {
      print("안걸림");
    }
    // checkEmail(value).then((result) => check = result);
    // if (check == false) {
    //   print("값 걸림");
    // } else {
    //   print("안걸림");
    // }

    // if (await checkEmail(value) == false) {
    //   return "중복된 이메일 입니다. 다른 이메일을 입력해주세요.";
    // }

    return null;
  }

  Future<bool> checkEmail(String email) async {
    final userDB = FirebaseFirestore.instance.collection('User');
    final query = userDB.where('email', isEqualTo: email);
    // final query = userDB.where('email', isEqualTo: "id3");

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      print('데이터 중복 안 됨 가입 진행 가능');
      return Future<bool>.value(true);
    } else {
      print('데이터 중복 됨 가입 진행 불가');
      return Future<bool>.value(false);
    }
  }

  final inputDecoration = InputDecoration(
    // isDense: true,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        )),
  );
}
