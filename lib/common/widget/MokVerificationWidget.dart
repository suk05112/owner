import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/owner/owner.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MokVerificationWidget extends StatefulWidget {
  const MokVerificationWidget({
    super.key,
    required this.successCallback,
  });

  final Function(MokAuthResult?) successCallback;

  @override
  State<MokVerificationWidget> createState() => _MokVerificationWidgetState();
}

class _MokVerificationWidgetState extends State<MokVerificationWidget> {
  bool _isLoading = false;
  MokAuthResult? _result;

  Future<void> _startVerification() async {
    setState(() => _isLoading = true);
    try {
      final clientInfo = await Api().client.mokClientInfo();
      if (!mounted) return;
      final result = await Navigator.push<MokAuthResult?>(
        context,
        MaterialPageRoute(
          builder: (_) => _MokWebViewPage(clientInfo: clientInfo),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (result != null && result.success) {
          _result = result;
        }
      });
      if (result != null && result.success) {
        widget.successCallback(result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CommonDialog.show(
        context: context,
        title: "본인인증 오류",
        content: "본인인증 요청 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
        buttonText: "확인",
        onPressed: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "본인인증",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: Colors.white,
              backgroundColor: _result != null ? Colors.grey[400] : ColorAssset.mainColor,
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _startVerification,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_result != null ? '본인인증 완료 (${_result!.name ?? ""})' : '본인인증 하기'),
          ),
        ),
      ],
    );
  }
}

class _MokWebViewPage extends StatefulWidget {
  const _MokWebViewPage({required this.clientInfo});

  final MokClientInfoResponse clientInfo;

  @override
  State<_MokWebViewPage> createState() => _MokWebViewPageState();
}

class _MokWebViewPageState extends State<_MokWebViewPage> {
  late final WebViewController _webViewController;
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _onPageFinished,
        ),
      )
      ..loadHtmlString(_buildAutoSubmitForm());
  }

  String _buildAutoSubmitForm() {
    final escaped = widget.clientInfo.mokReqClientInfo
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;');
    return '''
<!DOCTYPE html>
<html>
<body onload="document.forms[0].submit()">
  <form action="${AppConfig.mokStandardUrl}" method="post">
    <input type="hidden" name="mokReqClientInfo" value="$escaped" />
  </form>
</body>
</html>
''';
  }

  Future<void> _onPageFinished(String url) async {
    if (_resultHandled) return;
    if (!url.startsWith(widget.clientInfo.returnUrl)) return;

    _resultHandled = true;
    try {
      final raw = await _webViewController
          .runJavaScriptReturningResult('document.body.innerText') as String;
      final decoded = _decodeJsResult(raw);
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final result = MokAuthResult.fromJson(json, widget.clientInfo.clientTxId);
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(
        context,
        MokAuthResult(success: false, clientTxId: widget.clientInfo.clientTxId),
      );
    }
  }

  String _decodeJsResult(String raw) {
    // runJavaScriptReturningResult는 문자열을 JSON 인코딩된 형태(양쪽 따옴표 포함)로 반환할 수 있음
    var value = raw;
    if (value.startsWith('"') && value.endsWith('"')) {
      value = jsonDecode(value) as String;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _resultHandled,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _resultHandled) return;
        _resultHandled = true;
        Navigator.pop(
          context,
          MokAuthResult(success: false, clientTxId: widget.clientInfo.clientTxId),
        );
      },
      child: Scaffold(
        appBar: const CommonAppBar(title: "본인인증"),
        backgroundColor: Colors.white,
        body: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}
