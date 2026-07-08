import 'package:flutter/material.dart';
import 'package:owner/common/widget/CommonWebViewPage.dart';
import 'package:owner/screen/Setting/notice_page.dart';
import 'package:owner/screen/Setting/setting_page.dart';

/// 팝업의 link_url을 처리한다.
/// - http(s) URL: 앱 내 공용 웹뷰로 표시 (title은 팝업 제목 사용)
/// - gifnut:// 딥링크: 알려진 라우트로 이동, 매칭되는 라우트가 없으면 무시
void handlePopupLink(BuildContext context, String linkUrl, {String title = ''}) {
  final uri = Uri.tryParse(linkUrl);
  if (uri == null) return;

  if (uri.scheme == 'http' || uri.scheme == 'https') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonWebViewPage(title: title, url: linkUrl),
      ),
    );
    return;
  }

  if (uri.scheme == 'gifnut') {
    final route = _resolveDeepLinkRoute(uri);
    if (route == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  }
}

Widget? _resolveDeepLinkRoute(Uri uri) {
  final path = uri.host.isNotEmpty ? uri.host : uri.path.replaceFirst('/', '');
  switch (path) {
    case 'notice':
      return const NoticePage();
    case 'settings':
      return const SettingPage();
    default:
      return null;
  }
}
