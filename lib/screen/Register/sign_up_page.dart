import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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
                            try {
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

                              UserCredential? userCredential;

                              try {
                                // 전화번호 credential로 로그인
                                print("전화번호 credential로 로그인합니다.");
                                final phoneResult = await FirebaseAuth.instance
                                    .signInWithCredential(phoneAuthCredential!);

                                // 이메일 credential 생성
                                final emailCredential =
                                    EmailAuthProvider.credential(
                                  email: PhoneUtils.formatEmailForServer(
                                      email ?? ""),
                                  password: password ?? "",
                                );

                                // 이메일 credential을 전화번호 계정에 링크
                                userCredential = await phoneResult.user!
                                    .linkWithCredential(emailCredential);
                                print("이메일이 전화번호 계정에 성공적으로 링크되었습니다.");

                                // Display name 설정
                                await userCredential.user!
                                    .updateDisplayName("displayName");
                              } on FirebaseAuthException catch (e) {
                                print("계정 링크 실패: ${e.code} - ${e.message}");
                                setState(() {
                                  _isLoading = false;
                                });
                                String errorMessage = "회원가입 중 오류가 발생했습니다.";
                                if (e.code == 'email-already-in-use') {
                                  errorMessage = "이미 사용 중인 이메일입니다.";
                                } else if (e.code ==
                                    'credential-already-in-use') {
                                  errorMessage = "이미 다른 계정에 연결된 자격증명입니다.";
                                } else if (e.code ==
                                    'provider-already-linked') {
                                  errorMessage = "이미 가입된 계정입니다.";
                                } else {
                                  errorMessage = e.message ?? "이메일 링크 중 오류 발생";
                                }

                                if (mounted) {
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: errorMessage,
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                }
                                return;
                              } catch (e) {
                                print("계정 링크 중 일반 오류: $e");
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: e.toString(),
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                }
                                return;
                              }

                              // Firebase UserCredential이 최종적으로 설정되었는지 확인
                              if (userCredential.user == null) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  CommonDialog.show(
                                    context: context,
                                    title: "회원가입 오류",
                                    content: "Firebase 계정 처리에 실패했습니다.",
                                    buttonText: "확인",
                                    onPressed: () {},
                                  );
                                }
                                return;
                              }

                              try {
                                // 전화번호를 서버 형식으로 변환 (+821012345678)
                                String formattedPhone =
                                    PhoneUtils.formatForServer(
                                        phone_number ?? "");
                                // 이메일에 @gifnut.com 추가
                                String formattedEmail =
                                    PhoneUtils.formatEmailForServer(
                                        email ?? "");

                                OwnerRegisterPost owner = OwnerRegisterPost(
                                    uid: userCredential.user!.uid,
                                    phone_number: formattedPhone,
                                    name: name ?? "",
                                    email: formattedEmail);

                                try {
                                  print("회원가입 API 호출 시작");
                                  OwnerRegisterResponse? response;
                                  try {
                                    response =
                                        await Api().client.registerOwner(owner);
                                    print("회원가입 API 호출 성공: $response");
                                    print(
                                        "response.owner_id: ${response?.owner_id}");
                                  } catch (apiError) {
                                    print("회원가입 API 호출 중 예외 발생: $apiError");
                                    print("예외 타입: ${apiError.runtimeType}");

                                    // Firebase 계정 삭제
                                    try {
                                      await userCredential.user?.delete();
                                      await FirebaseAuth.instance.signOut();
                                      print("Firebase 계정 삭제 완료 (API 예외)");
                                    } catch (deleteError) {
                                      print(
                                          "Firebase 계정 삭제 중 오류: $deleteError");
                                    }

                                    if (mounted) {
                                      CommonDialog.show(
                                        context: context,
                                        title: "회원가입 오류",
                                        content: ApiErrorUtils.toUserMessage(apiError),
                                        buttonText: "확인",
                                        onPressed: () {},
                                      );
                                    }
                                    return;
                                  }

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

                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      print("회원가입 실패 다이얼로그 표시");
                                      CommonDialog.show(
                                        context: context,
                                        title: "회원가입 실패",
                                        content: "서버오류: 잠시 후 다시 시도해주세요.",
                                        buttonText: "확인",
                                        onPressed: () {},
                                      );
                                    }
                                    return;
                                  }

                                  // 회원가입 성공 (여기서는 response와 owner_id가 null이 아님을 확인했으므로 직접 접근)
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

                                  // 푸시 토큰 등록 (백그라운드, 실패해도 가입 플로우 계속 진행)
                                  _registerPushToken(ownerId);

                                  // 성공 시에만 가입완료 페이지로 이동
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpCompletePage()));
                                  }
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
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    CommonDialog.show(
                                      context: context,
                                      title: "회원가입 오류",
                                      content: ApiErrorUtils.toUserMessage(e),
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                  }
                                }
                              } catch (e) {
                                try {
                                  await userCredential.user?.delete();
                                  await FirebaseAuth.instance.signOut();
                                } catch (deleteError) {
                                  print("Firebase 계정 삭제 중 오류: $deleteError");
                                }

                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
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
                              setState(() {
                                _isLoading = false;
                              });
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
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }

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

  Future<void> _registerPushToken(int ownerId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      final deviceType = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await Api().client.registerOwnerPushToken(
            ownerId,
            OwnerPushTokenPost(fcm_token: fcmToken, device_type: deviceType),
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_fcm_token', fcmToken);
      print('Push token 등록 성공 (회원가입)');
    } catch (e) {
      print('Push token 등록 실패 (회원가입): $e');
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
