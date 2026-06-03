import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsWebViewPage extends StatefulWidget {
  final String title;
  final String termType;

  const TermsWebViewPage({
    Key? key,
    required this.title,
    required this.termType,
  }) : super(key: key);

  @override
  State<TermsWebViewPage> createState() => _TermsWebViewPageState();
}

class _TermsWebViewPageState extends State<TermsWebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final response = await Api().client.getTermsContent(widget.termType);
      if (!mounted) return;
      await _webViewController.loadHtmlString(response.content);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '약관을 불러오는데 실패했습니다.\n잠시 후 다시 시도해주세요.';
        _isLoading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.title),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xff6A6A6A)),
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFE7831)),
            ),
          ),
      ],
    );
  }
}
