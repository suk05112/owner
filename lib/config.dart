import 'package:owner/flavors.dart';

class AppConfig {
  static const String devBaseUrl = "https://www.502company.com/dev";
  static const String prodBaseUrl = "https://www.502company.com/prod";

  // 환경에 따른 baseUrl 반환
  static String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
      case Flavor.mock:
        return devBaseUrl;
      case Flavor.prod:
      default:
        return prodBaseUrl;
    }
  }

  // mobileOK 본인인증 WebView가 로드할 서버 페이지 (JS SDK가 이 origin에서 동작)
  static String get mokTestPageUrl => "$baseUrl/owner/mok/test-page";
}
