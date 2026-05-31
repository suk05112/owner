import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/utils/phone_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/LoginPage.dart';
import 'package:provider/provider.dart';

import '../../common/widget/CommonWidget.dart';
import '../../common/widget/CommonDialog.dart';

const _outlineBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
);
const _focusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color(0xFFAAAAAA)),
);
const _errorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color(0xFFFF5252)),
);

// ─── 비밀번호 찾기 (단일 화면) ───────────────────────────────────────────────

enum _Step { inputInfo, inputSms, inputPassword }

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({Key? key}) : super(key: key);

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // 입력 컨트롤러 + 포커스
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  final _pwController = TextEditingController();
  final _confirmController = TextEditingController();

  final _pwFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // 스크롤 위치 키
  final _pwFieldKey = GlobalKey();
  final _confirmFieldKey = GlobalKey();

  // UI 상태
  _Step _step = _Step.inputInfo;
  bool _isLoading = false;
  bool _pwObscure = true;
  bool _confirmObscure = true;
  String _pwValue = '';

  // Firebase
  String _verificationId = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    _pwController.dispose();
    _confirmController.dispose();
    _pwFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── 1단계: 서버 확인 + SMS 발송 ──────────────────────────────────────────

  Future<void> _onSendSms() async {
    final email = PhoneUtils.formatEmailForServer(_idController.text.trim());
    final phone = PhoneUtils.formatForServer(_phoneController.text.trim());

    if (_idController.text.trim().isEmpty) {
      _showSnack('아이디를 입력해주세요.');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnack('전화번호를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    // 서버에서 아이디+전화번호 존재 확인
    final exists = await _checkEmailExists(email, phone);
    if (!mounted) return;
    if (!exists) {
      setState(() => _isLoading = false);
      return;
    }

    // Firebase SMS 발송
    try {
      final e164 = _toE164(_phoneController.text.trim());
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: e164,
        verificationCompleted: (_) {}, // 자동 인증 시 signIn 하지 않음
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          String msg = '전화번호 인증에 실패했습니다.';
          if (e.code == 'invalid-phone-number') msg = '유효하지 않은 전화번호입니다.';
          if (e.code == 'too-many-requests') msg = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
          _showSnack(msg);
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _step = _Step.inputSms;
            _isLoading = false;
          });
          _showSnack('인증번호가 전송되었습니다.');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (mounted) _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('SMS 전송 중 오류가 발생했습니다.');
    }
  }

  // ── 2단계: 인증번호 확인 ──────────────────────────────────────────────────
  Future<void> _onVerifySms() async {
    final sms = _smsController.text.trim();
    if (sms.isEmpty) {
      _showSnack('인증번호를 입력해주세요.');
      return;
    }
    if (sms.length != 6 || !RegExp(r'^\d{6}$').hasMatch(sms)) {
      _showSnack('인증번호 6자리를 입력해주세요.');
      return;
    }
    if (_verificationId.isEmpty) {
      _showSnack('인증번호를 먼저 요청해주세요.');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => _isLoading = true);
    userProvider.isRegistering = true;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: sms,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCred.user == null) throw Exception();

      if (!mounted) return;
      setState(() {
        _step = _Step.inputPassword;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      userProvider.isRegistering = false;
      final msg = e.code == 'invalid-verification-code'
          ? '인증번호가 올바르지 않습니다.'
          : e.code == 'session-expired'
              ? '인증이 만료되었습니다. 인증번호를 다시 요청해주세요.'
              : '인증에 실패했습니다. 다시 시도해주세요.';
      _showSnack(msg);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      userProvider.isRegistering = false;
      _showSnack('인증에 실패했습니다. 다시 시도해주세요.');
    }
  }

  // ── 3단계: 비밀번호 변경 ──────────────────────────────────────────────────

  Future<void> _onChangePassword() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      _scrollToFirstError();
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => _isLoading = true);
    userProvider.isRegistering = true; // authStateChanges 개입 차단

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('인증 정보를 확인할 수 없습니다.');

      await user.updatePassword(_pwController.text);

      if (!mounted) return;
      setState(() => _isLoading = false);
      CommonDialog.show(
        context: context,
        title: "비밀번호 변경 완료",
        content: "비밀번호가 성공적으로 변경되었습니다.",
        buttonText: "로그인하기",
        onPressed: () {
          userProvider.isRegistering = false;
          // OKBtn이 onPressed() 실행 후 dialogContext.pop()을 호출하므로,
          // pushAndRemoveUntil은 다음 프레임에 실행해 충돌을 방지
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      userProvider.isRegistering = false;
      String msg;
      switch (e.code) {
        case 'weak-password':
          msg = '비밀번호는 6자 이상 입력해주세요.';
          break;
        case 'invalid-verification-code':
          msg = '인증이 만료되었습니다. 처음부터 다시 시도해주세요.';
          setState(() => _step = _Step.inputInfo);
          break;
        default:
          msg = e.message ?? '비밀번호 변경에 실패했습니다.';
      }
      _showSnack(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      userProvider.isRegistering = false;
      _showSnack('오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _scrollToFirstError() {
    // 비밀번호 필드 오류 먼저 확인
    if (_pwController.text.isEmpty || !_PasswordValidator.isValid(_pwController.text)) {
      _scrollToKey(_pwFieldKey);
      _pwFocus.requestFocus();
      return;
    }
    // 비밀번호 확인 필드 오류
    if (_confirmController.text.isEmpty || _confirmController.text != _pwController.text) {
      _scrollToKey(_confirmFieldKey);
      _confirmFocus.requestFocus();
    }
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.3);
  }

  // ── 헬퍼 ────────────────────────────────────────────────────────────────

  Future<bool> _checkEmailExists(String email, String phone) async {
    try {
      final response = await Api().client.findOwnerPw(
            OwnerFindPw(email: email, phone_number: phone),
          );
      final data = jsonDecode(response) as Map<String, dynamic>;
      if (data['msg'] == 'success') return true;
      if (mounted) {
        CommonDialog.show(
          context: context,
          title: "입력된 정보가 올바르지 않습니다.",
          content: "아이디와 전화번호를 다시 확인해주세요.",
          buttonText: "확인",
          onPressed: () {},
        );
      }
      return false;
    } on DioException catch (e) {
      if (!mounted) return false;
      final code = e.response?.statusCode;
      CommonDialog.show(
        context: context,
        title: "비밀번호 찾기 실패",
        content: code == 401
            ? "[401] 인증에 실패했습니다."
            : code == 500
                ? "[500] 서버 오류가 발생했습니다."
                : "오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
        buttonText: "확인",
        onPressed: () {},
      );
      return false;
    }
  }

  String _toE164(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.startsWith('0') ? '+82${digits.substring(1)}' : '+82$digits';
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF333333),
      ),
    );
  }

  // ── 빌드 ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: const CommonAppBar(title: "비밀번호 찾기"),
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── 아이디 ──
                          const Text("아이디", style: TextAssset.header2),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _idController,
                            enabled: _step == _Step.inputInfo,
                            decoration: const InputDecoration(
                              hintText: "아이디를 입력해주세요",
                              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: _outlineBorder,
                              enabledBorder: _outlineBorder,
                              focusedBorder: _focusedBorder,
                              disabledBorder: _outlineBorder,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── 전화번호 + 인증번호 발송 버튼 ──
                          const Text("전화번호", style: TextAssset.header2),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  enabled: _step == _Step.inputInfo,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    NumberFormatter(),
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: "전화번호를 입력해주세요",
                                    hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: _outlineBorder,
                                    enabledBorder: _outlineBorder,
                                    focusedBorder: _focusedBorder,
                                    disabledBorder: _outlineBorder,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    foregroundColor: Colors.white,
                                    backgroundColor: _step != _Step.inputInfo
                                        ? Colors.grey[400]
                                        : ColorAssset.mainColor,
                                    elevation: 0,
                                  ),
                                  onPressed: _step != _Step.inputInfo ? null : _onSendSms,
                                  child: Text(_step == _Step.inputInfo ? '인증' : '전송됨'),
                                ),
                              ),
                            ],
                          ),

                          // ── 인증번호 입력 (SMS 발송 후 노출) ──
                          if (_step == _Step.inputSms || _step == _Step.inputPassword) ...[
                            const SizedBox(height: 20),
                            const Text("인증번호", style: TextAssset.header2),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _smsController,
                                    enabled: _step == _Step.inputSms,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      hintText: "인증번호를 입력해주세요",
                                      hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      border: _outlineBorder,
                                      enabledBorder: _outlineBorder,
                                      focusedBorder: _focusedBorder,
                                      disabledBorder: _outlineBorder,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      foregroundColor: _step == _Step.inputPassword ? Colors.grey[600] : Colors.white,
                                      backgroundColor: _step == _Step.inputPassword ? Colors.grey[300] : ColorAssset.mainColor,
                                      elevation: 0,
                                    ),
                                    onPressed: _step == _Step.inputSms ? _onVerifySms : null,
                                    child: Text(_step == _Step.inputPassword ? '인증완료' : '인증확인'),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // ── 새 비밀번호 입력 (인증 완료 후 노출) ──
                          if (_step == _Step.inputPassword) ...[
                            const SizedBox(height: 28),
                            const Divider(color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 20),
                            const Text("새 비밀번호", style: TextAssset.header2),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: _pwFieldKey,
                              focusNode: _pwFocus,
                              controller: _pwController,
                              obscureText: _pwObscure,
                              decoration: InputDecoration(
                                hintText: "••••••••••",
                                hintStyle: const TextStyle(color: Color(0xFFBBBBBB), letterSpacing: 2),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: _outlineBorder,
                                enabledBorder: _outlineBorder,
                                focusedBorder: _focusedBorder,
                                errorBorder: _errorBorder,
                                focusedErrorBorder: _errorBorder,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _pwObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                  onPressed: () => setState(() => _pwObscure = !_pwObscure),
                                ),
                              ),
                              validator: _step == _Step.inputPassword
                                  ? (v) {
                                      if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                                      if (!_PasswordValidator.isValid(v)) return '비밀번호 규칙을 확인해주세요';
                                      return null;
                                    }
                                  : null,
                              onChanged: (v) => setState(() => _pwValue = v),
                            ),
                            const SizedBox(height: 8),
                            _RuleRow(
                              text: "영문/숫자/특수문자 중 2가지 이상 포함",
                              satisfied: _pwValue.isEmpty ? null : _PasswordValidator.hasTwoOrMoreTypes(_pwValue),
                            ),
                            _RuleRow(
                              text: "8자 이상 16자 이하 입력 (공백 제외)",
                              satisfied: _pwValue.isEmpty ? null : _PasswordValidator.hasValidLength(_pwValue),
                            ),
                            _RuleRow(
                              text: "연속 3자 이상 동일한 문자/숫자 제외",
                              satisfied: _pwValue.isEmpty ? null : _PasswordValidator.noConsecutiveChars(_pwValue),
                            ),
                            const SizedBox(height: 24),
                            const Text("비밀번호 확인", style: TextAssset.header2),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: _confirmFieldKey,
                              focusNode: _confirmFocus,
                              controller: _confirmController,
                              obscureText: _confirmObscure,
                              decoration: InputDecoration(
                                hintText: "••••••••••",
                                hintStyle: const TextStyle(color: Color(0xFFBBBBBB), letterSpacing: 2),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: _outlineBorder,
                                enabledBorder: _outlineBorder,
                                focusedBorder: _focusedBorder,
                                errorBorder: _errorBorder,
                                focusedErrorBorder: _errorBorder,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _confirmObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                  onPressed: () => setState(() => _confirmObscure = !_confirmObscure),
                                ),
                              ),
                              validator: _step == _Step.inputPassword
                                  ? (v) {
                                      if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                                      if (v != _pwController.text) return '비밀번호가 일치하지 않습니다';
                                      return null;
                                    }
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── 하단 버튼 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        foregroundColor: Colors.white,
                        backgroundColor: ColorAssset.mainColor,
                      ),
                      onPressed: _isLoading || _step != _Step.inputPassword
                          ? null
                          : _onChangePassword,
                      child: Text(
                        _step == _Step.inputPassword ? '변경하기' : '확인',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: ColorAssset.mainColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 비밀번호 유효성 검사 ─────────────────────────────────────────────────────

class _PasswordValidator {
  static bool hasValidLength(String pw) => pw.length >= 8 && pw.length <= 16;

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
