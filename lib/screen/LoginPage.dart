import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/provier/mock_user_provider.dart';
import 'package:owner/common/provier/mock_auth_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:provider/provider.dart';
import 'package:owner/flavors.dart';

import 'Register/sign_up_page.dart';
import 'Register/find_password_page.dart';
import 'Register/find_userId_page.dart';
import 'home.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/model/user.dart' as my_app;
import 'package:owner/common/utils/phone_utils.dart';

class LoginScreen extends StatefulWidget {
  final bool returnToPrevious;

  const LoginScreen({Key? key, this.returnToPrevious = false})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

  // 이메일/비밀번호 로그인을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // 비밀번호 숨김/표시

  my_app.User user = my_app.User(
      owner_id: 0, name: 'name', email: 'email', phone_number: 'phone');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이메일과 비밀번호를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final emailInput = _emailController.text.trim();
    final emailWithDomain = PhoneUtils.formatEmailForServer(emailInput);
    print("로그인 시도 $emailWithDomain");

    try {
      if (F.isMock) {
        // Mock mode: bypass Firebase auth and use mock providers
        print('Mock mode: bypassing Firebase authentication');

        // Simulate network delay
        await Future.delayed(Duration(milliseconds: 500));

        // Create mock user
        final mockUser = my_app.User(
          owner_id: 12345,
          name: 'Mock Store Owner',
          email: emailWithDomain.isNotEmpty ? emailWithDomain : 'mock@example.com',
          phone_number: '010-1234-5678',
        );

        user = mockUser;

        // Set user in mock provider
        Provider.of<MockUserProvider>(context, listen: false).setUser(mockUser);

        // Also set in regular UserProvider for compatibility
        Provider.of<UserProvider>(context, listen: false).setUser(mockUser);

        print('Mock login success');
      } else {
        // Normal mode: use Firebase authentication
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailWithDomain,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          user.email = emailWithDomain;
          await login(userCredential.user!.uid);
          // login 함수가 완료되면 _loading은 login 함수 내에서 false로 설정됨
        } else {
          setState(() {
            _loading = false;
          });
          CommonDialog.show(
              context: context,
              title: "로그인 실패",
              content: "입력된 정보가 올바르지 않습니다. 다시 입력해주세요",
              buttonText: "확인",
              onPressed: () {});
        }
      }
    } on FirebaseAuthException catch (e) {
      // Only show Firebase errors in non-mock mode
      if (!F.isMock) {
        String errorMessage = "로그인에 실패했습니다.";
        if (e.code == 'user-not-found') {
          errorMessage = "등록되지 않은 이메일입니다.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "비밀번호가 잘못되었습니다.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "이메일 형식이 올바르지 않습니다.";
        } else if (e.code == 'invalid-credential') {
          errorMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
        }
        print("로그인 실패 ${e.code}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        // In mock mode, treat Firebase errors as unexpected
        print('Mock mode: Unexpected Firebase error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 중 오류가 발생했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40),
                          SizedBox(height: 50),
                          // 상단 제목 영역
                          SizedBox(height: 8),
                          Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 40),
                          // 이메일 입력 필드
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '아이디를 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // 비밀번호 입력 필드
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              suffixIcon: IconButton(
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
                              ),
                            ),
                          ),

                          SizedBox(height: 50),
                          // 이메일로 로그인 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleEmailLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorAssset.mainColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      '아이디로 로그인',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // 회원가입 | 아이디 찾기 | 비밀번호 찾기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BasicInfoInputPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FindUserIDPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '아이디 찾기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FindPasswordPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '비밀번호 찾기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 전체 화면 프로그레스바
              if (_loading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ));
  }

  Future<void> login(String uid) async {
    print("로그인 함수 호출 ${uid}");

    try {
      if (F.isMock) {
        // Mock mode: bypass API call and simulate successful login
        print('Mock mode: bypassing API login call');

        // Simulate network delay
        await Future.delayed(Duration(milliseconds: 500));

        // Set mock user data (already set in _handleEmailLogin, but ensure consistency)
        user.owner_id = 12345;
        user.phone_number = '010-1234-5678';
        user.name = 'Mock Store Owner';

        // Ensure user is set in providers
        Provider.of<MockUserProvider>(context, listen: false).setUser(user);
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        print('Mock login success');
      } else {
        // Normal mode: use actual API
        var response = await Api().client.login(uid);

        if (response.owner_id != null) {
          print(
              "로그인 성공 ${response.owner_id}, ${response.name}, ${response.phone_number}");
          user.owner_id = response.owner_id ?? 0;
          user.phone_number = response.phone_number;
          user.name = response.name;

          Provider.of<UserProvider>(context, listen: false).setUser(user);

          // Push token 등록 (백그라운드에서 실행, 실패해도 로그인은 계속 진행)
          _registerPushToken(response.owner_id!).catchError((error) {
            print('Push token 등록 실패 (무시): $error');
          });
        } else {
          // owner_id가 null인 경우
          if (mounted) {
            setState(() {
              _loading = false;
            });
            CommonDialog.show(
                context: context,
                title: "로그인 실패",
                content: "로그인 정보를 확인할 수 없습니다.",
                buttonText: "확인",
                onPressed: () {});
          }
          return; // Exit early to avoid navigation
        }
      }

      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      // returnToPrevious가 true면 이전 페이지로 돌아가기, false면 Home으로 이동
      if (widget.returnToPrevious && Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } on DioException catch (e) {
      // Only show detailed errors in non-mock mode
      if (!F.isMock) {
        String errorMsg = "";
        if (e.response != null) {
          // 서버에서 받은 상태 코드에 따른 처리
          if (e.response!.statusCode == 401) {
            // 인증 실패
            print("인증 실패: ${e.response!.data}");
            errorMsg = "[401]인증에 실패했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
          } else if (e.response!.statusCode == 500) {
            // 서버 오류
            print("서버 오류: ${e.response!.data}");
            errorMsg =
                "[500]서버에 오류가 발행했습니다.잠시 후 다시 실행해주세요.\n ${e.response!.data}";
          } else {
            // 기타 오류
            print("기타 오류: ${e.response!.data}");
            errorMsg = "오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
          }
        } else {
          // 네트워크 연결 실패 등
          print("네트워크 오류: ${e.message}");
          errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.message}";
        }

        // 로딩 상태 해제
        if (mounted) {
          setState(() {
            _loading = false;
          });
          CommonDialog.show(
              context: context,
              title: "로그인 실패",
              content: errorMsg,
              buttonText: "확인",
              onPressed: () {});
        }
      } else {
        // In mock mode, show generic error
        print('Mock mode: API call failed: $e');
        if (mounted) {
          setState(() {
            _loading = false;
          });
          CommonDialog.show(
              context: context,
              title: "로그인 실패",
              content: "로그인 중 오류가 발생했습니다.",
              buttonText: "확인",
              onPressed: () {});
        }
      }
    } catch (e) {
      // 기타 예외 처리
      if (mounted) {
        setState(() {
          _loading = false;
        });
        if (F.isMock) {
          CommonDialog.show(
              context: context,
              title: "로그인 실패",
              content: "알 수 없는 오류가 발생했습니다.",
              buttonText: "확인",
              onPressed: () {});
        } else {
          CommonDialog.show(
              context: context,
              title: "로그인 실패",
              content: "알 수 없는 오류가 발생했습니다.",
              buttonText: "확인",
              onPressed: () {});
        }
      }
    }
  }

  /// Push token을 서버에 등록하는 함수
  Future<void> _registerPushToken(int ownerId) async {
    try {
      // Firebase Messaging에서 FCM token 가져오기
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token을 가져올 수 없어 push token 등록을 건너뜁니다.');
        return;
      }

      print('FCM token 획득: $fcmToken');

      final pushTokenRequest = OwnerPushTokenPost(push_token: fcmToken);
      final response = await Api().client.registerOwnerPushToken(
            owner_id: ownerId,
            pushToken: pushTokenRequest,
          );

      print(
          'Push token 등록 성공: ${response.message}, owner_id: ${response.owner_id}');
    } catch (e) {
      print('Push token 등록 실패: $e');
      // 실패해도 로그인은 계속 진행되므로 에러를 throw하지 않음
    }
  }
}
