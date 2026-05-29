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

  String? name;
  String? email; // 이메일 값을 저장
  String? phone_number;
  String? password;
  String? confirmPassword; // 비밀번호 확인 값
  PhoneAuthCredential? phoneAuthCredential; // 전화번호 인증 credential 저장

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
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor: ColorAssset.mainColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('이전'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
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

                              if (phone_number == null ||
                                  phoneAuthCredential == null) {
                                CommonDialog.show(
                                  context: context,
                                  title: "전화번호를 확인할 수 없습니다.",
                                  content: "전화번호 인증을 완료해주세요.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              UserCredential? userCredential;

                              // 전화번호로 이미 계정이 생성되어 있는지 확인
                              User? existingPhoneUser =
                                  FirebaseAuth.instance.currentUser;
                              bool isPhoneAccount = existingPhoneUser != null &&
                                  existingPhoneUser.phoneNumber != null &&
                                  existingPhoneUser.email == null;

                              if (isPhoneAccount &&
                                  phoneAuthCredential != null) {
                                // 전화번호 계정이 이미 존재하는 경우, 이메일과 비밀번호를 링크
                                print("전화번호 계정이 이미 존재합니다. 이메일을 링크합니다.");
                                try {
                                  // 이메일 credential 생성
                                  final emailCredential =
                                      EmailAuthProvider.credential(
                                    email: PhoneUtils.formatEmailForServer(
                                        email ?? ""),
                                    password: password ?? "",
                                  );

                                  // 전화번호 계정에 이메일 credential 링크
                                  userCredential = await existingPhoneUser
                                      .linkWithCredential(emailCredential);
                                  print("이메일이 전화번호 계정에 성공적으로 링크되었습니다.");
                                } on FirebaseAuthException catch (e) {
                                  print("이메일 링크 실패: ${e.code} - ${e.message}");
                                  if (e.code == 'email-already-in-use') {
                                    CommonDialog.show(
                                      context: context,
                                      title: "회원가입 오류",
                                      content: "이미 사용 중인 이메일입니다.",
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                    return;
                                  } else {
                                    CommonDialog.show(
                                      context: context,
                                      title: "회원가입 오류",
                                      content: _firebaseAuthErrorToKorean(e.code),
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                    return;
                                  }
                                } catch (e) {
                                  print("이메일 링크 중 일반 오류: $e");
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: "잠시 후 다시 시도해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                  return;
                                }
                              } else {
                                // 전화번호 계정이 없거나, 이미 이메일이 있는 계정인 경우
                                // 이메일 계정을 생성하고 전화번호를 링크
                                print("새 이메일 계정을 생성하고 전화번호를 링크합니다.");
                                userCredential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: PhoneUtils.formatEmailForServer(
                                            email ?? ""),
                                        password: password ?? "");

                                if (userCredential.user?.email == null) {
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입을 완료할 수 없습니다.",
                                    content: "잠시 후 다시 시도해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                  return;
                                }

                                try {
                                  // Display name 설정
                                  await userCredential.user!
                                      .updateDisplayName("displayName");

                                  // 전화번호 인증 credential을 이메일 계정에 링크
                                  if (phoneAuthCredential != null) {
                                    try {
                                      await userCredential.user!
                                          .linkWithCredential(
                                              phoneAuthCredential!);
                                      print("전화번호 인증이 이메일 계정에 성공적으로 링크되었습니다.");
                                    } on FirebaseAuthException catch (linkError) {
                                      // 이미 링크되어 있는 경우 무시
                                      if (linkError.code ==
                                              'credential-already-in-use' ||
                                          linkError.code ==
                                              'provider-already-linked') {
                                        print("전화번호가 이미 링크되어 있습니다.");
                                      } else {
                                        print(
                                            "전화번호 링크 실패: ${linkError.code} - ${linkError.message}");
                                        // 링크 실패해도 회원가입은 계속 진행
                                      }
                                    } catch (e) {
                                      print("전화번호 링크 중 오류: $e");
                                      // 링크 실패해도 회원가입은 계속 진행
                                    }
                                  }
                                } catch (e) {
                                  print("Firebase 계정 업데이트/링크 중 오류: $e");
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: "잠시 후 다시 시도해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                  return;
                                }
                              }

                              // Firebase UserCredential이 최종적으로 설정되었는지 확인
                              if (userCredential.user == null) {
                                CommonDialog.show(
                                  context: context,
                                  title: "회원가입 오류",
                                  content: "Firebase 계정 처리에 실패했습니다.",
                                  buttonText: "확인",
                                  onPressed: () {},
                                );
                                return;
                              }

                              // 전화번호를 서버 형식으로 변환 (+821012345678)
                              String formattedPhone =
                                  PhoneUtils.formatForServer(
                                      phone_number ?? "");
                              // 이메일에 @gifnut.com 추가
                              String formattedEmail =
                                  PhoneUtils.formatEmailForServer(email ?? "");

                              OwnerRegisterPost owner = OwnerRegisterPost(
                                  uid: userCredential.user!.uid,
                                  phone_number: formattedPhone,
                                  name: name ?? "",
                                  email: formattedEmail);

                              try {
                                print("회원가입 API 호출 시작");
                                OwnerRegisterResponse? response =
                                    await Api().client.registerOwner(owner);
                                print("회원가입 API 호출 성공: $response");
                                print(
                                    "response.owner_id: ${response?.owner_id}");

                                // response가 null이거나 owner_id가 null인 경우 실패 처리
                                if (response == null ||
                                    response.owner_id == null) {
                                  // API 호출은 성공했지만 owner_id가 null인 경우
                                  // Firebase 계정 삭제
                                  print(
                                      "회원가입 실패: owner_id가 null - Firebase 계정 삭제 시작");
                                  try {
                                    await userCredential.user?.delete();
                                    await FirebaseAuth.instance.signOut();
                                    print("Firebase 계정 삭제 완료");
                                  } catch (e) {
                                    print("Firebase 계정 삭제 중 오류: $e");
                                  }

                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 실패",
                                    content: "서버오류: 잠시 후 다시 시도해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                  return;
                                }

                                // 회원가입 성공
                                final ownerId = response.owner_id!;
                                print("회원가입 성공: owner_id=$ownerId");
                                my_app.User user = my_app.User(
                                    owner_id: ownerId,
                                    name: name ?? "",
                                    email: email ?? "",
                                    phone_number: phone_number ?? "");

                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .setUser(user);

                                // 성공 시에만 가입완료 페이지로 이동
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpCompletePage()));
                              } catch (e) {
                                print("회원가입 API 예외 발생: $e");
                                try {
                                  await userCredential.user?.delete();
                                  await FirebaseAuth.instance.signOut();
                                  print("Firebase 계정 삭제 완료 (예외)");
                                } catch (deleteError) {
                                  print("Firebase 계정 삭제 중 오류: $deleteError");
                                }

                                if (mounted) {
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 실패",
                                    content: ApiErrorUtils.toUserMessage(e),
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                }
                              }
                              // FirebaseAuth.instance.currentUser
                              //     ?.sendEmailVerification();
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
                                    content: "이미 사용중인 아이디입니다. 다른 아이디를 사용해주세요.",
                                    buttonText: "확인",
                                    onPressed: () {});
                              } else {
                                print(e.code);
                                CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: _firebaseAuthErrorToKorean(e.code),
                                    buttonText: "확인",
                                    onPressed: () {});
                              }
                            }
                          }

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             DocumentInputPage()));
                        },
                        child: const Text('확인'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  String _firebaseAuthErrorToKorean(String code) {
    switch (code) {
      case 'weak-password':
        return '비밀번호가 너무 간단합니다. 6자 이상 입력해주세요.';
      case 'email-already-in-use':
        return '이미 사용중인 아이디입니다. 다른 아이디를 사용해주세요.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'operation-not-allowed':
        return '현재 사용할 수 없는 인증 방식입니다.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'credential-already-in-use':
        return '이미 다른 계정에 연결된 인증 정보입니다.';
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인 후 시도해주세요.';
      default:
        return '잠시 후 다시 시도해주세요.';
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
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              const Text(
                "아이디",
                style: TextAssset.header2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: idController,
                      decoration:
                          inputDecoration.copyWith(hintText: "아이디를 입력하세요 (@ 제외)"),
                      onChanged: (text) async {
                        final check = await checkEmail(text);
                        setState(() => hasRecipe = check);
                        widget.onEmailChanged(text);
                      },
                      validator: (value) {
                        print("id validator 호출");
                        if (value == null || value.isEmpty) {
                          return "아이디를 입력해주세요.";
                        }
                        if (value.contains('@')) {
                          return "아이디에 @를 포함할 수 없습니다.";
                        }
                        if (!isValidId(value)) {
                          return "영문, 숫자, 특수문자(._-)만 사용 가능합니다.";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            ]));
  }

  bool isValidId(String id) {
    const pattern = r'^[A-Za-z0-9_\.\-]+$';
    return RegExp(pattern).hasMatch(id);
  }

  Future<bool> checkEmail(String email) async {
    String emailToCheck = '$email@gifnut.com';
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
