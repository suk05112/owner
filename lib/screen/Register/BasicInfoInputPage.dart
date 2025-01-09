import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/model/request/OwnerPost.dart';
import 'package:owner/common/widget/CommonDialog.dart';

import '../../common/widget/CommonWidget.dart';
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
    return GestureDetector(
        onTap: () {
          //FocusManager.instance.primaryFocus?.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("가입하기"),
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [BasicInfoFormWidget()]))));
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
  String? name;
  String? email; // 이메일 값을 저장
  String? phone_number;
  String? password;
  String? confirmPassword; // 비밀번호 확인 값

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
                onChanged: (newName) {
                  setState(() {
                    name = newName;
                  });
                },
              ),
              PhoneNumberVerificationWidget(successCallback: (newPhoneNumber) {
                // 여기서 phoneNumber 변수에 인증된 전화번호가 들어옵니다.
                if (newPhoneNumber != null) {
                  print("회원가입 전화번호 인증 성공: $newPhoneNumber");
                  phone_number = newPhoneNumber;
                } else {
                  print("전화번호 인증 실패");
                }
              }), //전화번호
              IDVerificationWidget(
                onEmailChanged: (newEmail) {
                  setState(() {
                    email = newEmail; // 이메일 값 업데이트
                  });
                },
              ), //아이디
              InputInfoWidget(
                title: "비밀번호",
                hintText: "Enter your email",
                validator: validatePhoneNumber,
                onChanged: (newPassword) {
                  setState(() {
                    password = newPassword;
                  });
                },
              ),
              InputInfoWidget(
                title: "비밀번호 확인",
                hintText: "Enter your email",
                validator: validatePhoneNumber,
                onChanged: (newConfirmPassword) {
                  setState(() {
                    confirmPassword = newConfirmPassword;
                  });
                },
              ),

              Container(
                // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              backgroundColor: ColorAssset.mainColor,
                              foregroundColor: Colors.white,
                              // minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: () {
                              // Navigator.pop(context);
                              CommonDialog.show(
                                  context: context,
                                  title: "인증 실패",
                                  content: "다시 확인",
                                  buttonText: "확인",
                                  onPressed: () {});
                            },
                            child: Text('이전'),
                          ),
                        ),
                      ),
                      const SizedBox(
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: ColorAssset.mainColor,
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
                                            email: email ?? "",
                                            password: password ?? "")
                                        .then((value) async {
                                  if (value.user!.email != null) {
                                    FirebaseAuth.instance.currentUser!
                                        .updateDisplayName("displayName");

                                    OwnerRegisterPost owner = OwnerRegisterPost(
                                        uid: value.user!.uid,
                                        phone_number: phone_number ?? "",
                                        name: name ?? "",
                                        email: email ?? "");

                                    Api().client.registerOwner(owner);
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
                                  CommonDialog.show(
                                      context: context,
                                      title: "비밀번호 확인",
                                      content: "취약한 비밀번호입니다. 다른 비밀번호를 사용해주세요.",
                                      buttonText: "확인",
                                      onPressed: () {});
                                } else if (e.code == 'email-already-in-use') {
                                  print(
                                      'The account already exists for that email.');
                                  CommonDialog.show(
                                      context: context,
                                      title: "아이디 확인",
                                      content:
                                          "이미 사용중인 아이디입니다. 다른 아이디를 사용해주세요.",
                                      buttonText: "확인",
                                      onPressed: () {});
                                } else {
                                  print(e.code);
                                }
                              } catch (e) {}

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpCompletePage()));

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
  InputInfoWidget({
    required this.title,
    required this.hintText,
    required this.validator,
    required this.onChanged,
  });

  final String title;
  String hintText;
  Function(String?) validator;
  final Function(String) onChanged;

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
            onChanged: (value) {
              widget.onChanged(value); // 입력 값 변경 시 콜백 호출
            },
          ),
        ]);
  }

  final inputDecoration = InputDecoration(border: UnderlineInputBorder());
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

class IDVerificationWidget extends StatefulWidget {
  final Function(String) onEmailChanged; // 이메일 변경 시 호출되는 콜백

  IDVerificationWidget({required this.onEmailChanged});

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
              const Text(
                "이메일",
                style: TextAssset.header2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      // style: TextStyle(fontSize: 15, height: 0.1),
                      controller: idController,
                      decoration:
                          inputDecoration.copyWith(hintText: "아이디를 입력하세요"),
                      onChanged: (text) async {
                        final check = await checkEmail(text);
                        setState(() => hasRecipe = check);
                        widget.onEmailChanged(text); // 부모에게 이메일 값 전달
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
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // Expanded(
                  //   flex: 1,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Color.fromARGB(255, 151, 125, 253),
                  //       minimumSize: const Size.fromHeight(50), // NEW
                  //     ),
                  //     onPressed: () {
                  //       _formKey.currentState?.validate();
                  //     },
                  //     child: Text('중복 확인'),
                  //   ),
                  // ),
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
    border: UnderlineInputBorder(
        // borderRadius: BorderRadius.circular(8.0),
        // borderSide: const BorderSide(
        //   color: Colors.redAccent,
        //   width: 2,
        // )
        ),
  );
}
