import 'package:flutter/material.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Register/terms_web_view_page.dart';

const Map<String, String> _termTypeTitles = {
  'SERVICE': '서비스 이용약관',
  'FEE': '수수료 정책동의',
  'PRIVACY': '개인정보 처리방침',
  'MARKETING': '마케팅 정보 수신 동의',
};

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  List<TermItem> _termItems = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final response = await Api().client.getTermsCurrent();
      if (!mounted) return;
      setState(() {
        _termItems = response.terms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _openTerms(TermItem term) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsWebViewPage(
          title: _termTypeTitles[term.termType] ?? term.title,
          termType: term.termType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "약관 보기"),
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFE7831)));
    }
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '약관 목록을 불러오는데 실패했습니다.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _termItems.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final term = _termItems[index];
        return ListTile(
          title: Text(
            _termTypeTitles[term.termType] ?? term.title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: () => _openTerms(term),
        );
      },
    );
  }
}
