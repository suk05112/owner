import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/utils/phone_utils.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/LoginPage.dart';
import 'package:owner/screen/Register/find_password_page.dart';

import '../../common/widget/CommonWidget.dart';

const _outlineBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
);
const _focusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color(0xFFAAAAAA)),
);

class FindUserIDPage extends StatefulWidget {
  const FindUserIDPage({Key? key}) : super(key: key);

  @override
  State<FindUserIDPage> createState() => _FindUserIDPageState();
}

class _FindUserIDPageState extends State<FindUserIDPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
        Scaffold(
        appBar: const CommonAppBar(title: "아이디 찾기"),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text("이름", style: TextAssset.header2),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "이름을 입력해주세요",
                        hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: _outlineBorder,
                        enabledBorder: _outlineBorder,
                        focusedBorder: _focusedBorder,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("전화번호", style: TextAssset.header2),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
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
                      ),
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
                      borderRadius: BorderRadius.circular(5),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                  ),
                  onPressed: _isLoading ? null : () async {
                    String formattedPhone = PhoneUtils.formatForServer(_phoneController.text);
                    showRegisteredId(OwnerFind(
                      name: _nameController.text,
                      phone_number: formattedPhone,
                    ));
                  },
                  child: const Text("확인"),
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
              child: CircularProgressIndicator(
                color: ColorAssset.mainColor,
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }

  void showRegisteredId(OwnerFind ownerFind) async {
    setState(() => _isLoading = true);
    try {
      var response = await Api().client.findOwnerId(ownerFind);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.owner_id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterdIDPage(
              email: response.email,
              created_time: response.created_time,
            ),
          ),
        );
      } else {
        CommonDialog.show(
          context: context,
          title: "입력된 정보가 올바르지 않습니다.",
          content: "다시한번 확인해주세요.",
          buttonText: "확인",
          onPressed: () {},
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMsg = "";
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMsg = "[401]인증에 실패했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else if (e.response!.statusCode == 500) {
          errorMsg = "[500]서버에 오류가 발행했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else {
          errorMsg = "오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        }
      } else {
        errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.message}";
      }

      CommonDialog.show(
        context: context,
        title: "아이디 찾기 실패",
        content: errorMsg,
        buttonText: "확인",
        onPressed: () {},
      );
    }
  }
}

class RegisterdIDPage extends StatelessWidget {
  const RegisterdIDPage({Key? key, this.email, this.created_time, this.msg}) : super(key: key);

  final String? email;
  final String? created_time;
  final String? msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "아이디 찾기"),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Text(
                  "가입하신 아이디는 아래와 같습니다.",
                  style: TextAssset.header2,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        email?.replaceAll('@gifnut.com', '') ?? "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF131313),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "가입일: ${created_time?.replaceFirst('T', ' ') ?? "-"}",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  foregroundColor: Colors.white,
                  backgroundColor: ColorAssset.mainColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindPasswordPage()),
                  );
                },
                child: const Text("비밀번호 재설정하기"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  foregroundColor: ColorAssset.mainColor,
                  side: BorderSide(color: ColorAssset.mainColor),
                ),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
                child: const Text("로그인 하러 가기"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
