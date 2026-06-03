import 'dart:async';

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
  final idWidgetKey = GlobalKey<_IDVerificationWidgetState>();
  final _scrollController = ScrollController();

  // 각 필드 섹션의 위치 추적용 GlobalKey
  final _nameKey = GlobalKey();
  final _phoneKey = GlobalKey();
  final _pwKey = GlobalKey();
  final _pwConfirmKey = GlobalKey();

  // FocusNode
  final _nameFocus = FocusNode();
  final _idFocus = FocusNode();
  final _pwConfirmFocus = FocusNode();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    _scrollController.dispose();
    _nameFocus.dispose();
    _idFocus.dispose();
    _pwConfirmFocus.dispose();
    super.dispose();
  }

  /// 특정 위젯으로 스크롤 + 포커스 이동
  void _focusAndScroll(GlobalKey key, FocusNode focusNode) {
    focusNode.requestFocus();
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputInfoWidget(
                      key: _nameKey,
                      focusNode: _nameFocus,
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
                        key: _phoneKey,
                        successCallback: (phoneAuthResult) {
                      if (phoneAuthResult != null) {
                        phone_number = phoneAuthResult.phoneNumber;
                        phoneAuthCredential = phoneAuthResult.credential;
                      } else {
                        phoneAuthCredential = null;
                      }
                    }), //전화번호
                    IDVerificationWidget(
                      key: idWidgetKey,
                      formKey: formKey2,
                      focusNode: _idFocus,
                      onEmailChanged: (newEmail) {
                        setState(() {
                          email = newEmail;
                        });
                      },
                    ), //아이디
                    PasswordInputWidget(
                      key: _pwKey,
                      onPasswordChanged: (newPassword) {
                        setState(() {
                          password = newPassword;
                        });
                      },
                    ),
                    InputInfoWidget(
                      key: _pwConfirmKey,
                      focusNode: _pwConfirmFocus,
                      title: "비밀번호 확인",
                      hintText: "비밀번호를 입력해주세요",
                      hidePassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "비밀번호를 입력해주세요";
                        }
                        if (value != password) {
                          return "비밀번호가 일치하지 않습니다";
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                          // 1. 아이디 형식 검증
                          if (!formKey2.currentState!.validate()) {
                            _focusAndScroll(idWidgetKey, _idFocus);
                            return;
                          }
                          // 2. 나머지 필드 검증 (이름, 비밀번호 확인)
                          if (!formKey.currentState!.validate()) {
                            if (name == null || name!.isEmpty) {
                              _focusAndScroll(_nameKey, _nameFocus);
                            } else {
                              _focusAndScroll(_pwConfirmKey, _pwConfirmFocus);
                            }
                            return;
                          }

                          // 3. 비밀번호 일치 확인
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

                          // 4. 전화번호 인증 완료 확인
                          if (phone_number == null || phoneAuthCredential == null) {
                            _scrollToKey(_phoneKey);
                            CommonDialog.show(
                              context: context,
                              title: "전화번호를 확인할 수 없습니다.",
                              content: "전화번호 인증을 완료해주세요.",
                              buttonText: "확인",
                              onPressed: () {},
                            );
                            return;
                          }

                          // 5. 비밀번호 규칙 확인
                          if (!PasswordValidator.isValid(password ?? "")) {
                            _scrollToKey(_pwKey);
                            CommonDialog.show(
                              context: context,
                              title: "비밀번호 확인",
                              content: "비밀번호 규칙을 확인해주세요.",
                              buttonText: "확인",
                              onPressed: () {},
                            );
                            return;
                          }

                          // 6. 아이디 중복 체크 (마지막)
                          setState(() => _isLoading = true);
                          final idAvailable = await idWidgetKey.currentState!.checkDuplicateForSubmit();
                          if (!mounted) return;
                          if (!idAvailable) {
                            setState(() => _isLoading = false);
                            formKey2.currentState!.validate();
                            _focusAndScroll(idWidgetKey, _idFocus);
                            return;
                          }
                          _proceedSignUp();
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('확인'),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> _proceedSignUp() async {
    setState(() => _isLoading = true);
    Provider.of<UserProvider>(context, listen: false).isRegistering = true;

    UserCredential? userCredential;
    bool didCreatePhoneAccount = false;

    // Step 1: 전화번호 계정 확보 + 이메일 링크
    try {
      User? phoneUser = FirebaseAuth.instance.currentUser;
      if (phoneUser == null) {
        final result = await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential!);
        phoneUser = result.user;
        didCreatePhoneAccount = true;
      }
      final emailCredential = EmailAuthProvider.credential(
        email: PhoneUtils.formatEmailForServer(email ?? ""),
        password: password ?? "",
      );
      userCredential = await phoneUser!.linkWithCredential(emailCredential);
      await userCredential.user!.updateDisplayName("displayName");
    } on FirebaseAuthException catch (e) {
      print("Step1 FirebaseAuthException: ${e.code} - ${e.message}");
      if (didCreatePhoneAccount) {
        await _deleteFirebaseAccount();
      } else {
        await FirebaseAuth.instance.signOut();
      }
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).isRegistering = false;
      setState(() => _isLoading = false);
      String msg;
      if (e.code == 'email-already-in-use' || e.code == 'provider-already-linked') {
        msg = "이미 사용 중인 아이디입니다.";
      } else if (e.code == 'credential-already-in-use') {
        msg = "이미 다른 계정에 연결된 전화번호입니다.";
      } else if (e.code == 'weak-password') {
        msg = "비밀번호는 6자 이상 입력해주세요.";
      } else {
        msg = "잠시 후 다시 시도해주세요.";
      }
      CommonDialog.show(context: context, title: "회원가입 오류", content: msg, buttonText: "확인", onPressed: () {});
      return;
    } catch (e) {
      print("Step1 일반 오류: ${e.runtimeType} - $e");
      if (didCreatePhoneAccount) {
        await _deleteFirebaseAccount();
      } else {
        await FirebaseAuth.instance.signOut();
      }
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).isRegistering = false;
      setState(() => _isLoading = false);
      CommonDialog.show(context: context, title: "회원가입 오류", content: "잠시 후 다시 시도해주세요.", buttonText: "확인", onPressed: () {});
      return;
    }

    // Step 2: 서버 회원가입 API 호출
    try {
      final response = await Api().client.registerOwner(OwnerRegisterPost(
        uid: userCredential.user!.uid,
        phone_number: PhoneUtils.formatForServer(phone_number ?? ""),
        name: name ?? "",
        email: PhoneUtils.formatEmailForServer(email ?? ""),
      ));

      if (response == null || response.owner_id == null) {
        await _deleteFirebaseAccount(userCredential);
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).isRegistering = false;
        setState(() => _isLoading = false);
        CommonDialog.show(context: context, title: "회원가입 실패", content: "서버 오류: 잠시 후 다시 시도해주세요.", buttonText: "확인", onPressed: () {});
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpCompletePage()));
    } catch (e) {
      await _deleteFirebaseAccount(userCredential);
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).isRegistering = false;
      setState(() => _isLoading = false);
      CommonDialog.show(context: context, title: "회원가입 오류", content: ApiErrorUtils.toUserMessage(e), buttonText: "확인", onPressed: () {});
    }
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
      this.hidePassword,
      this.focusNode});

  final String title;
  String hintText;
  Function(String?) validator;
  final Function(String) onChanged;
  bool? hidePassword;
  final FocusNode? focusNode;

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
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: TextAssset.header2,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: inputController,
            focusNode: widget.focusNode,
            obscureText: _hidePassword == null ? false : _hidePassword!,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFAAAAAA)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFF5252)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFF5252)),
              ),
              suffixIcon: _hidePassword == null
                  ? null
                  : IconButton(
                      icon: _hidePassword!
                          ? const Icon(Icons.visibility_off_outlined, color: Color(0xFFAAAAAA))
                          : const Icon(Icons.visibility_outlined, color: Color(0xFFAAAAAA)),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword!;
                        });
                      },
                    ),
            ),
            validator: (value) {
              return widget.validator(value);
            },
            onChanged: (value) {
              widget.onChanged(value); // 입력 값 변경 시 콜백 호출
            },
          ),
        ]);
  }

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
  final Function(String) onEmailChanged;
  final GlobalKey<FormState> formKey;
  final FocusNode? focusNode;
  const IDVerificationWidget(
      {super.key, required this.onEmailChanged, required this.formKey, this.focusNode});

  @override
  State<IDVerificationWidget> createState() => _IDVerificationWidgetState();
}

class _IDVerificationWidgetState extends State<IDVerificationWidget> {
  TextEditingController idController = TextEditingController();
  String _value = '';
  // null = 미체크, true = 사용 가능, false = 중복
  bool? _idAvailable;
  bool _isChecking = false;

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  // 확인 버튼에서 호출 — 중복 체크 후 결과 반환 (true=진행 가능, false=중복)
  Future<bool> checkDuplicateForSubmit() async {
    final value = idController.text;
    if (!RegExp(r'^[a-z0-9]{5,20}$').hasMatch(value)) return false;
    setState(() {
      _isChecking = true;
      _idAvailable = null;
    });
    try {
      final response = await Api().client.checkDuplicate(email: '$value@gifnut.com');
      final available = !response.emailExists;
      if (mounted) setState(() => _idAvailable = available);
      return available;
    } catch (e) {
      print('[아이디 중복체크 에러] $e');
      if (mounted) setState(() => _idAvailable = null);
      return true; // 서버 에러 시 진행 허용
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "아이디",
                style: TextAssset.header2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: idController,
                focusNode: widget.focusNode,
                decoration: _inputDecoration.copyWith(
                  hintText: "아이디를 입력하세요",
                  suffixIcon: _isChecking
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFE7831)),
                          ),
                        )
                      : null,
                ),
                onChanged: (text) {
                  setState(() {
                    _value = text;
                    _idAvailable = null;
                  });
                  widget.onEmailChanged(text);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "아이디를 입력해주세요.";
                  }
                  if (!RegExp(r'^[a-z0-9]{5,20}$').hasMatch(value)) {
                    return "5~20자의 영문 소문자, 숫자만 사용 가능합니다.";
                  }
                  if (_idAvailable == false) {
                    return "이미 존재하는 아이디입니다.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _RuleRow(
                text: "5~20자 입력",
                satisfied: _value.isEmpty
                    ? null
                    : (_value.length >= 5 && _value.length <= 20),
              ),
              _RuleRow(
                text: "영문 소문자, 숫자만 사용 가능",
                satisfied: _value.isEmpty
                    ? null
                    : RegExp(r'^[a-z0-9]+$').hasMatch(_value),
              ),
              if (_idAvailable != null) ...[
                const SizedBox(height: 2),
                _RuleRow(
                  text: _idAvailable! ? "사용 가능한 아이디입니다." : "이미 존재하는 아이디입니다.",
                  satisfied: _idAvailable,
                ),
              ],
            ]));
  }

  static InputDecoration get _inputDecoration => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFAAAAAA)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF5252)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF5252)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class PasswordValidator {
  static bool hasValidLength(String pw) =>
      pw.length >= 8 && pw.length <= 16;

  static bool hasTwoOrMoreTypes(String pw) {
    int count = 0;
    if (RegExp(r'[A-Za-z]').hasMatch(pw)) count++;
    if (RegExp(r'[0-9]').hasMatch(pw)) count++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) count++;
    return count >= 2;
  }

  static bool noConsecutiveChars(String pw) {
    for (int i = 0; i < pw.length - 2; i++) {
      if (pw[i] == pw[i + 1] && pw[i + 1] == pw[i + 2]) return false;
    }
    return true;
  }

  static bool isValid(String pw) =>
      hasValidLength(pw) && hasTwoOrMoreTypes(pw) && noConsecutiveChars(pw);
}

class PasswordInputWidget extends StatefulWidget {
  final Function(String) onPasswordChanged;

  const PasswordInputWidget({super.key, required this.onPasswordChanged});

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String _value = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("비밀번호", style: TextAssset.header2),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFAAAAAA)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF5252)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF5252)),
            ),
            hintText: "••••••••••",
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB), letterSpacing: 2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFFAAAAAA),
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "비밀번호를 입력해주세요";
            if (!PasswordValidator.isValid(value)) return "비밀번호 규칙을 확인해주세요";
            return null;
          },
          onChanged: (value) {
            setState(() => _value = value);
            widget.onPasswordChanged(value);
          },
        ),
        const SizedBox(height: 8),
        _RuleRow(
          text: "영문/숫자/특수문자 중 2가지 이상 포함",
          satisfied: _value.isEmpty ? null : PasswordValidator.hasTwoOrMoreTypes(_value),
        ),
        _RuleRow(
          text: "8자 이상 16자 이하 입력 (공백 제외)",
          satisfied: _value.isEmpty ? null : PasswordValidator.hasValidLength(_value),
        ),
        _RuleRow(
          text: "연속 3자 이상 동일한 문자/숫자 제외",
          satisfied: _value.isEmpty ? null : PasswordValidator.noConsecutiveChars(_value),
        ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String text;
  final bool? satisfied;

  const _RuleRow({required this.text, required this.satisfied});

  @override
  Widget build(BuildContext context) {
    final color = satisfied == null
        ? const Color(0xFF888888)
        : satisfied!
            ? const Color(0xFF4CAF50)
            : const Color(0xFF888888);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("✓ ", style: TextStyle(fontSize: 12, color: color)),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
