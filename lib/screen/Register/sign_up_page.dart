import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:owner/common/model/user.dart' as my_app;

import '../../common/widget/CommonWidget.dart';
import '../../common/utils/phone_utils.dart';
import '../../common/utils/api_error_utils.dart';
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
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //FocusManager.instance.primaryFocus?.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: const Scaffold(
          appBar: CommonAppBar(title: "가입하기"),
          backgroundColor: Colors.white,
          body: BasicInfoFormWidget(),
        ));
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

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  String? name;
  String? email; // 이메일 값을 저장
  String? phone_number;
  String? password;
  String? confirmPassword; // 비밀번호 확인 값
  PhoneAuthCredential? phoneAuthCredential; // 전화번호 인증 credential 저장
  bool _isLoading = false; // API 요청 중 로딩 상태

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputInfoWidget(
                      title: "이름",
                      hintText: "이름을 입력해주세요",
                      validator: validateName,
                      onChanged: (newName) {
                        setState(() {
                          name = newName;
                        });
                      },
                    ),
                    PhoneNumberVerificationWidget(
                        successCallback: (phoneAuthResult) {
                      // 여기서 phoneNumber 변수에 인증된 전화번호가 들어옵니다.
                      if (phoneAuthResult != null) {
                        print(
                            "회원가입 전화번호 인증 성공: ${phoneAuthResult.phoneNumber}");
                        phone_number = phoneAuthResult.phoneNumber;
                        phoneAuthCredential =
                            phoneAuthResult.credential; // credential 저장
                      } else {
                        print("전화번호 인증 실패");
                        phoneAuthCredential = null;
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
                      hintText: "비밀번호를 입력해주세요",
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
                      hintText: "비밀번호를 입력해주세요",
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor:
                        _isLoading ? Colors.grey : ColorAssset.mainColor,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (formKey2.currentState!.validate()) {
                            print("id validator");
                          } else {
                            return;
                          }
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            Provider.of<UserProvider>(context, listen: false)
                                .isRegistering = true;
                            if (password != confirmPassword) {
                                setState(() {
                                  _isLoading = false;
                                });
                                CommonDialog.show(
                                  context: context,
                                  title: "비밀번호 확인",
                                  content: "비밀번호가 일치하지 않습니다.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              if (phone_number == null ||
                                  phoneAuthCredential == null) {
                                setState(() {
                                  _isLoading = false;
                                });
                                CommonDialog.show(
                                  context: context,
                                  title: "전화번호를 확인할 수 없습니다.",
                                  content: "전화번호 인증을 완료해주세요.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              if ((password ?? "").length < 6) {
                                setState(() {
                                  _isLoading = false;
                                });
                                CommonDialog.show(
                                  context: context,
                                  title: "비밀번호 확인",
                                  content: "비밀번호는 6자 이상 입력해주세요.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              UserCredential? userCredential;

                              // Step 1: 전화번호 계정 확보 + 이메일 링크
                              try {
                                // 이미 로그인된 전화번호 계정이 있으면 재사용, 없으면 signIn
                                User? phoneUser = FirebaseAuth.instance.currentUser;
                                if (phoneUser == null) {
                                  final result = await FirebaseAuth.instance
                                      .signInWithCredential(phoneAuthCredential!);
                                  phoneUser = result.user;
                                }

                                final emailCredential =
                                    EmailAuthProvider.credential(
                                  email: PhoneUtils.formatEmailForServer(
                                      email ?? ""),
                                  password: password ?? "",
                                );
                                userCredential = await phoneUser!
                                    .linkWithCredential(emailCredential);
                                await userCredential.user!
                                    .updateDisplayName("displayName");
                              } on FirebaseAuthException catch (e) {
                                print("Step1 FirebaseAuthException: ${e.code} - ${e.message}");
                                await _deleteFirebaseAccount();
                                if (!mounted) return;
                                Provider.of<UserProvider>(context, listen: false)
                                    .isRegistering = false;
                                setState(() => _isLoading = false);
                                String msg;
                                if (e.code == 'email-already-in-use') {
                                  msg = "이미 사용 중인 아이디입니다.";
                                } else if (e.code == 'credential-already-in-use') {
                                  msg = "이미 다른 계정에 연결된 전화번호입니다.";
                                } else if (e.code == 'weak-password') {
                                  msg = "비밀번호는 6자 이상 입력해주세요.";
                                } else {
                                  msg = "잠시 후 다시 시도해주세요.";
                                }
                                CommonDialog.show(
                                  context: context,
                                  title: "회원가입 오류",
                                  content: msg,
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              } catch (e) {
                                print("Step1 일반 오류: ${e.runtimeType} - $e");
                                await _deleteFirebaseAccount();
                                if (!mounted) return;
                                Provider.of<UserProvider>(context, listen: false)
                                    .isRegistering = false;
                                setState(() => _isLoading = false);
                                CommonDialog.show(
                                  context: context,
                                  title: "회원가입 오류",
                                  content: "잠시 후 다시 시도해주세요.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              // Step 2: 서버 회원가입 API 호출
                              try {
                                final response = await Api()
                                    .client
                                    .registerOwner(OwnerRegisterPost(
                                      uid: userCredential.user!.uid,
                                      phone_number: PhoneUtils.formatForServer(
                                          phone_number ?? ""),
                                      name: name ?? "",
                                      email: PhoneUtils.formatEmailForServer(
                                          email ?? ""),
                                    ));

                                if (response == null ||
                                    response.owner_id == null) {
                                  await _deleteFirebaseAccount(userCredential);
                                  if (!mounted) return;
                                  Provider.of<UserProvider>(context, listen: false)
                                      .isRegistering = false;
                                  setState(() => _isLoading = false);
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 실패",
                                    content: "서버 오류: 잠시 후 다시 시도해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                  return;
                                }

                                if (!mounted) return;
                                Provider.of<UserProvider>(context, listen: false)
                                  ..isRegistering = false
                                  ..setUser(my_app.User(
                                    owner_id: response.owner_id!,
                                    name: name ?? "",
                                    email: email ?? "",
                                    phone_number: phone_number ?? "",
                                  ));

                                setState(() => _isLoading = false);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpCompletePage()));
                              } catch (e) {
                                await _deleteFirebaseAccount(userCredential);
                                if (!mounted) return;
                                Provider.of<UserProvider>(context, listen: false)
                                    .isRegistering = false;
                                setState(() => _isLoading = false);
                                CommonDialog.show(
                                  context: context,
                                  title: "회원가입 오류",
                                  content: ApiErrorUtils.toUserMessage(e),
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                              }
                          } // if (formKey)

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             DocumentInputPage()));
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('확인'),
                ),
              ),
            ),
          ],
        ));
  }

  /// Firebase 계정 삭제 후 로그아웃. 실패해도 무시하고 계속 진행.
  Future<void> _deleteFirebaseAccount([UserCredential? credential]) async {
    try {
      final user = credential?.user ?? FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Firebase 계정 삭제 시도: uid=${user.uid}");
        await user.delete();
        print("Firebase 계정 삭제 완료");
      } else {
        print("Firebase 계정 삭제: currentUser 없음 (이미 로그아웃 상태)");
      }
    } catch (e) {
      print("Firebase 계정 삭제 실패: ${e.runtimeType} - $e");
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Firebase signOut 실패: $e");
    }
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
      {super.key,
      required this.title,
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
  void dispose() {
    inputController.dispose();
    super.dispose();
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
                    border: const UnderlineInputBorder(),
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

  static const inputDecoration =
      InputDecoration(border: UnderlineInputBorder());
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
    // String userId = userCredential.user!.uid;
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
  const IDVerificationWidget(
      {super.key, required this.onEmailChanged, required this.formKey});

  @override
  State<IDVerificationWidget> createState() => _IDVerificationWidgetState();
}

class _IDVerificationWidgetState extends State<IDVerificationWidget> {
  TextEditingController idController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  var hasRecipe = false;

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

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

                        // 내부적으로 @gifnut.com을 붙여서 검사
                        if (isValidEmail(value) == false) {
                          return "이메일 형식이 올바르지 않습니다. 올바른 이메일을 입력해주세요.";
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
    // 내부적으로 @gifnut.com을 붙여서 검사
    String emailToCheck = email.contains('@') ? email : '$email@gifnut.com';
    const pattern = r'^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-za-z0-9\-]+';
    final regex = RegExp(pattern);
    return regex.hasMatch(emailToCheck);
  }

  Future<bool> checkEmail(String email) async {
    // 내부적으로 @gifnut.com을 붙여서 중복 체크
    String emailToCheck = email.contains('@') ? email : '$email@gifnut.com';
    final userDB = FirebaseFirestore.instance.collection('User');
    final query = userDB.where('email', isEqualTo: emailToCheck);
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

  static const inputDecoration = InputDecoration(
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
