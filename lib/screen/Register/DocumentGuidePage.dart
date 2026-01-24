import 'package:flutter/material.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Register/DocumentInputPage.dart';

class DocumentGuidePage extends StatelessWidget {
  const DocumentGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "매장 등록"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: <Widget>[
              // 제목
              const Text(
                "가입 전 준비해주세요",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF101010),
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // 항목 리스트
              _buildDocumentItem(
                icon: Icons.description,
                title: "사업자 등록증",
              ),
              const SizedBox(height: 24),
              _buildDocumentItem(
                icon: Icons.account_balance_wallet,
                title: "통장사본",
                description: "사업자 등록증에 있는 사업자와 동일해야합니다.",
              ),
              const SizedBox(height: 24),
              _buildDocumentItem(
                icon: Icons.photo_camera,
                title: "매장 사진",
              ),
              const SizedBox(height: 100),
              // 가입하기 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocumentInputPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF27213),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String title,
    String? description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDE0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF27213),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        // 텍스트
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101010),
                  fontFamily: 'Inter',
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF808080),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
