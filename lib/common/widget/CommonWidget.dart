import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/utils/phone_utils.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:dio/dio.dart';
import 'dart:async'; // Import for Timer

// PhoneAuthResult 클래스 추가
class PhoneAuthResult {
  final PhoneAuthCredential credential;
  final String phoneNumber;
  final String? name;

  PhoneAuthResult({
    required this.credential,
    required this.phoneNumber,
    this.name,
  });
}

class InputInfoWidget extends StatefulWidget {
  const InputInfoWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.validator,
    this.isNumber = false,
    this.onChanged,
    this.hidePassword = false,
  });

  final String title;
  final String hintText;
  final Function(String?) validator;
  final bool isNumber;
  final Function(String)? onChanged;
  final bool hidePassword;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: inputController,
            keyboardType:
                widget.isNumber ? TextInputType.number : TextInputType.text,
            obscureText: widget.hidePassword ? _obscurePassword : false,
            decoration: inputDecoration.copyWith(
              hintText: widget.hintText,
              suffixIcon: widget.hidePassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
            ),
            validator: (value) {
              return widget.validator(value);
            },
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ]);
  }

  InputDecoration get inputDecoration => InputDecoration(
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
  );
}

void showModalDialog(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const Text("dialog");
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
  const PhoneNumberVerificationWidget({
    super.key,
    required this.successCallback,
    this.isSocialLogin = false,
    this.hideButton = false,
    this.skipRegistrationCheck = false,
    this.provider, // SNS 로그인일 경우 provider, 이메일 가입일 경우 "email"
  });

  final Function(PhoneAuthResult?) successCallback;
  final bool isSocialLogin;
  final bool hideButton;
  final bool skipRegistrationCheck; // 회원가입 여부 체크 건너뛰기 (아이디/비밀번호 찾기용)
  final String? provider; // SNS provider 또는 "email"

  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  bool isTouched = false;
  bool isVerified = false; // 인증 완료 여부
  String? name;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<User?>? _authStateSubscription;
  bool _hasCalledSuccessCallback = false; // successCallback 중복 호출 방지 플래그
  bool _handlingAutoVerification = false; // 자동 인증 처리 중 플래그

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController validationNumberController = TextEditingController();

  final inputDecoration = InputDecoration(
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
  );

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "이름을 입력해주세요.";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Firebase Auth 상태 변경 리스너 설정 (자동 인증 처리용)
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null &&
          !_handlingAutoVerification &&
          !isVerified &&
          mounted) {
        // 자동 인증이 완료된 경우 (Android SMS 자동 인증)
        print("authStateChanges: 자동 인증 완료 감지");
        _handleAutoVerification(user);
      }
    });
  }

  Future<void> _handleAutoVerification(User user) async {
    _handlingAutoVerification = true;
    try {
      // 인증번호 입력 필드가 비어있으면 자동 인증을 무시 (수동 입력을 기다림)
      if (validationNumberController.text.trim().isEmpty) {
        print("자동 인증 감지되었으나 인증번호 입력 필드가 비어있어 무시");
        if (mounted) {
          await _auth.signOut();
        }
        _handlingAutoVerification = false;
        return;
      }

      // 전화번호로 이미 가입된 계정인지 확인 (회원가입 시에만 체크)
      // owner 프로젝트에는 LoginService가 없으므로 이 부분은 주석 처리
      // if (!widget.skipRegistrationCheck) {
      //   await Api().setBaseClient(AppConfig.baseUrl);
      //   String e164PhoneNumber = _formatToE164(phoneNumberController.text);
      //   final provider = widget.provider ?? (widget.isSocialLogin ? "" : "email");
      //   final isRegistered = await loginService.isRegisteredUser(null, provider, phone: e164PhoneNumber);
      //   if (isRegistered) {
      //     if (mounted) {
      //       await _auth.signOut();
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Text('이미 가입된 전화번호입니다.'),
      //           duration: Duration(seconds: 2),
      //           backgroundColor: Colors.red[700],
      //         ),
      //       );
      //     }
      //     _handlingAutoVerification = false;
      //     return;
      //   }
      // }

      // 인증 성공 처리
      if (mounted) {
        setState(() {
          isVerified = true;
        });

        // verificationId가 있으면 credential 생성하여 successCallback 호출
        if (_verificationId.isNotEmpty && !_hasCalledSuccessCallback) {
          _hasCalledSuccessCallback = true;
          final credential = PhoneAuthProvider.credential(
            verificationId: _verificationId,
            smsCode: validationNumberController.text.isNotEmpty
                ? validationNumberController.text
                : '000000', // 자동 인증의 경우 임시 코드
          );

          widget.successCallback(
            PhoneAuthResult(
              credential: credential,
              phoneNumber: phoneNumberController.text,
              name: name,
            ),
          );
        }

        // 인증 완료 후 로그아웃 (임시 인증이므로)
        await _auth.signOut();
      }
    } on DioException catch (e) {
      // API 호출 실패 처리
      String errorMessage = '네트워크 오류가 발생했습니다.';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '인터넷 연결을 확인해주세요.';
      } else if (e.response != null) {
        errorMessage = '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
      }

      if (mounted) {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      print("자동 인증 처리 오류: $e");
      if (mounted) {
        await _auth.signOut();
      }
    } finally {
      _handlingAutoVerification = false;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    phoneNumberController.dispose();
    validationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이름 입력 필드 (간편로그인일 때만 노출)
                    if (widget.isSocialLogin) ...[
                      InputInfoWidget(
                        title: "이름",
                        hintText: "이름을 입력해주세요",
                        validator: _validateName,
                        onChanged: (newName) {
                          setState(() {
                            name = newName;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      "전화번호",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              // FilteringTextInputFormatter.digitsOnly, //숫자만!
                              NumberFormatter(), // 자동하이픈
                              LengthLimitingTextInputFormatter(13)
                            ],
                            decoration: inputDecoration.copyWith(
                                hintText: "휴대폰 번호를 입력하세요"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "잘못된 전화번호입니다. 다시 입력하세요";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: ColorAssset.mainColor,
                              fixedSize: const Size(110, 50)),
                          onPressed: () async {
                            final phoneNumber = phoneNumberController.text;
                            // 전화번호 형식 검증 (3-4-4 형식: 010-1234-5678)
                            final phonePattern = RegExp(r'^010-\d{4}-\d{4}$');
                            if (!phonePattern.hasMatch(phoneNumber)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      '전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.grey[800],
                                ),
                              );
                              return;
                            }

                            // 회원가입 시 전화번호 중복 체크
                            if (!widget.skipRegistrationCheck) {
                              try {
                                final e164 = PhoneUtils.formatForServer(phoneNumber);
                                print('[중복체크] 전화번호 중복 체크 시작: $e164');
                                final result = await Api().client.checkDuplicate(phoneNumber: e164);
                                print('[중복체크] phoneExists=${result.phoneExists}');
                                if (result.phoneExists) {
                                  if (mounted) {
                                    CommonDialog.show(
                                      context: context,
                                      title: "전화번호 확인",
                                      content: "이미 가입된 번호입니다.",
                                      buttonText: "확인",
                                      onPressed: () {},
                                    );
                                  }
                                  return;
                                }
                              } catch (e) {
                                print('[중복체크] 전화번호 중복 체크 실패 (진행 허용): $e');
                              }
                            } else {
                              print('[중복체크] skipRegistrationCheck=true, 건너뜀');
                            }

                            setState(() {
                              isTouched = true;
                            });
                            verifyPhoneNumber(phoneNumberController.text);
                          },
                          child: isTouched ? const Text('재전송') : const Text('인증'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Visibility(
                        visible: isTouched,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "인증번호",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    controller: validationNumberController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: inputDecoration.copyWith(
                                      hintText: "인증번호를 입력하세요",
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
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      foregroundColor: isVerified
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      backgroundColor: isVerified
                                          ? Colors.grey[300]
                                          : ColorAssset.mainColor,
                                      fixedSize: const Size(110, 50)),
                                  onPressed: (isVerified ||
                                          _verificationId.isEmpty)
                                      ? null
                                      : () async {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            // 실제 Firebase 인증 검증
                                            try {
                                              PhoneAuthCredential credential =
                                                  PhoneAuthProvider.credential(
                                                      verificationId:
                                                          _verificationId,
                                                      smsCode:
                                                          validationNumberController
                                                              .text);

                                                // credential 유효성 확인: 임시 로그인 후 즉시 로그아웃
                                              await _auth.signInWithCredential(credential);
                                              await _auth.signOut();

                                              // 인증 성공 — credential을 상위로 전달 (실제 로그인은 상위에서 처리)
                                              if (mounted &&
                                                  !_hasCalledSuccessCallback) {
                                                _hasCalledSuccessCallback =
                                                    true;
                                                setState(() {
                                                  isVerified = true;
                                                });

                                                widget.successCallback(
                                                  PhoneAuthResult(
                                                    credential: credential,
                                                    phoneNumber:
                                                        phoneNumberController
                                                            .text,
                                                    name: name,
                                                  ),
                                                );
                                              }
                                            } on FirebaseAuthException catch (e) {
                                              // 인증 실패
                                              print(
                                                  "Firebase 인증 오류: ${e.code} - ${e.message}");
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        '인증번호가 올바르지 않습니다.'),
                                                    duration:
                                                        const Duration(seconds: 2),
                                                    backgroundColor:
                                                        Colors.red[700],
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              // 기타 오류
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        '인증 중 오류가 발생했습니다.'),
                                                    duration:
                                                        const Duration(seconds: 2),
                                                    backgroundColor:
                                                        Colors.red[700],
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                  child: Text(
                                    isVerified ? '인증완료' : '인증확인',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ])
                            ]),
                        ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

  // 전화번호를 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
  String _formatToE164(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.startsWith('0')) {
      return '+82${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('82')) {
      return '+$digitsOnly';
    } else {
      return '+82$digitsOnly';
    }
  }

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    // 하이픈 제거 후 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
    String e164PhoneNumber = _formatToE164(phoneNumber);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164PhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android 자동 인증 완료 콜백
        print("verificationCompleted::전화번호 자동 인증 완료");
        // 자동 인증이 완료된 경우 successCallback 호출 (중복 호출 방지)
        if (mounted && !_hasCalledSuccessCallback) {
          _hasCalledSuccessCallback = true;
          setState(() {
            isVerified = true;
          });

          widget.successCallback(
            PhoneAuthResult(
              credential: credential,
              phoneNumber: phoneNumber,
              name: name,
            ),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("전화번호 인증 실패");
        print(e.code);
        print(e.message);
        if (mounted) {
          String errorMessage = "전화번호 인증에 실패했습니다.";
          if (e.code == 'invalid-phone-number') {
            errorMessage = "유효하지 않은 전화번호입니다.";
          } else if (e.code == 'too-many-requests') {
            errorMessage = "요청이 너무 많습니다. 잠시 후 다시 시도해주세요.";
          } else if (e.code == 'network-request-failed') {
            errorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.";
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          setState(() {
            isVerified = false;
            isTouched = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        print("코드 보내짐");
        print(verificationId);
        // 코드가 성공적으로 보내진 경우
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
          // 토스트 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('인증번호가 전송되었습니다.'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.grey[800],
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("SMS 자동 인식 타임아웃 (수동 입력 가능)");
        // 타임아웃 콜백 함수 - SMS 자동 인식이 타임아웃되었지만,
        // verificationId는 여전히 유효하므로 수동으로 인증번호를 입력하여 인증할 수 있습니다.
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
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
