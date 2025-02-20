import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/model/request/OwnerPost.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:provider/provider.dart';
import 'package:owner/common/model/user.dart' as my_app;

import '../../common/widget/CommonWidget.dart';
import 'DocumentInputPage.dart';
import 'SingUpCompletePage.dart';

class BasicInfoInputPage extends StatefulWidget {
  const BasicInfoInputPage({Key? key}) : super(key: key);

  @override
  State<BasicInfoInputPage> createState() => _BasicInfoInputPageState();
}

class _BasicInfoInputPageState extends State<BasicInfoInputPage>
    with TickerProviderStateMixin {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();

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
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  String? name;
  String? email; // 이메일 값을 저장
  String? phone_number;
  String? password;
  String? confirmPassword; // 비밀번호 확인 값

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
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
                formKey: formKey2,
                onEmailChanged: (newEmail) {
                  setState(() {
                    email = newEmail; // 이메일 값 업데이트
                  });
                },
              ), //아이디
              InputInfoWidget(
                title: "비밀번호",
                hintText: "Enter your email",
                hidePassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호를 입력해주세요";
                  }
                  return null;
                },
                onChanged: (newPassword) {
                  setState(() {
                    password = newPassword;
                  });
                },
              ),
              InputInfoWidget(
                title: "비밀번호 확인",
                hintText: "Enter your email",
                hidePassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호를 입력해주세요";
                  }
                  return null;
                },
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
                              Navigator.pop(context);
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
                              if (formKey2.currentState!.validate()) {
                                print("id validator");
                              } else {
                                return;
                              }
                              if (formKey.currentState!.validate()) {
                                try {
                                  if (password != confirmPassword) {
                                    CommonDialog.show(
                                      context: context,
                                      title: "비밀번호 확인",
                                      content: "비밀번호가 일치하지 않습니다.",
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                    return;
                                  }

                                  if (phone_number == null) {
                                    CommonDialog.show(
                                      context: context,
                                      title: "전화번호를 확인할 수 없습니다.",
                                      content: "전화번호 인증을 완료해주세요.",
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                    return;
                                  }

                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: email ?? "",
                                              password: password ?? "")
                                          .then((value) async {
                                    if (value.user!.email != null) {
                                      FirebaseAuth.instance.currentUser!
                                          .updateDisplayName("displayName");
                                      OwnerRegisterPost owner =
                                          OwnerRegisterPost(
                                              uid: value.user!.uid,
                                              phone_number: phone_number ?? "",
                                              name: name ?? "",
                                              email: email ?? "");

                                      Api()
                                          .client
                                          .registerOwner(owner)
                                          .then((value) {
                                        if (value.owner_id == null) {
                                          CommonDialog.show(
                                            context: context,
                                            title: "회원가입 실패",
                                            content: "서버오류:: 잠시 후 다시 시도해주세요.",
                                            buttonText: "확인",
                                            onPressed: () {},
                                          );
                                        }
                                        my_app.User user = my_app.User(
                                            owner_id: value.owner_id ?? -1,
                                            name: name ?? "",
                                            email: email ?? "",
                                            phone_number: phone_number ?? "");

                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .setUser(user);
                                      });

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpCompletePage()));
                                    } else {
                                      CommonDialog.show(
                                        context: context,
                                        title: "회원가입을 완료할 수 없습니다.",
                                        content: "잠시 후 다시 시도해주세요.",
                                        buttonText: "확인",
                                        onPressed: () {},
                                      );
                                    }
                                    return value;
                                  });
                                  // FirebaseAuth.instance.currentUser
                                  //     ?.sendEmailVerification();
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    print('the password provided is too weak');
                                    CommonDialog.show(
                                        context: context,
                                        title: "비밀번호 확인",
                                        content:
                                            "취약한 비밀번호입니다. 다른 비밀번호를 사용해주세요.",
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
                              }

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
      return "이름을 입력해주세요.";
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
      {required this.title,
      required this.hintText,
      required this.validator,
      required this.onChanged,
      this.hidePassword});

  final String title;
  String hintText;
  Function(String?) validator;
  final Function(String) onChanged;
  bool? hidePassword;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();
  bool? _hidePassword;

  @override
  void initState() {
    super.initState();
    if (widget.hidePassword != null) {
      _hidePassword = widget.hidePassword!;
    }
  }

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
            obscureText: _hidePassword == null ? false : _hidePassword!,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    suffixIcon: _hidePassword == null
                        ? null
                        : IconButton(
                            icon: _hidePassword!
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword!;
                              });
                            },
                          ))
                .copyWith(hintText: widget.hintText),
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
  final GlobalKey<FormState> formKey;
  IDVerificationWidget({required this.onEmailChanged, required this.formKey});

  @override
  State<IDVerificationWidget> createState() => _IDVerificationWidgetState();
}

class _IDVerificationWidgetState extends State<IDVerificationWidget> {
  TextEditingController idController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  var hasRecipe = false;
  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
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
                        print("id validator 호출");
                        if (value == null || value.isEmpty) {
                          return "이메일을 입력해주세요.";
                        }

                        // if (hasRecipe == false) {
                        //   return "중복된 이메일 입니다. 다른 이메일을 입력해주세요.";
                        // }

                        if (isValidEmail(value) == false) {
                          return "이메일 형식이 올바르지 않습니다. 올바른 이메일을 입력해주세요.\n Ex) example123@naver.com";
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              )
            ]));
  }

  bool isValidEmail(String email) {
    const pattern = r'^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-za-z0-9\-]+';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
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
