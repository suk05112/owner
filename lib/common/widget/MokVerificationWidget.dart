import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
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
    final result = await Navigator.push<MokAuthResult?>(
      context,
      MaterialPageRoute(builder: (_) => const _MokWebViewPage()),
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
                : Text(_result != null ? '본인인증 완료' : '본인인증 하기'),
          ),
        ),
      ],
    );
  }
}

class _MokWebViewPage extends StatefulWidget {
  const _MokWebViewPage();

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
      ..addJavaScriptChannel(
        'MokChannel',
        onMessageReceived: _onMokMessage,
      )
      ..loadRequest(Uri.parse(AppConfig.mokTestPageUrl));
  }

  void _onMokMessage(JavaScriptMessage message) {
    if (_resultHandled) return;
    _resultHandled = true;
    try {
      final json = jsonDecode(message.message) as Map<String, dynamic>;
      final resultCode = json['resultCode'] as String?;
      final clientTxId = json['clientTxId'] as String? ?? '';
      final result = MokAuthResult(
        success: resultCode == '2000',
        clientTxId: clientTxId,
      );
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, MokAuthResult(success: false, clientTxId: ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _resultHandled,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _resultHandled) return;
        _resultHandled = true;
        Navigator.pop(context, MokAuthResult(success: false, clientTxId: ''));
      },
      child: Scaffold(
        appBar: const CommonAppBar(title: "본인인증"),
        backgroundColor: Colors.white,
        body: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}
