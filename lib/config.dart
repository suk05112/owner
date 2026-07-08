import 'package:owner/flavors.dart';

class AppConfig {
  static const String devBaseUrl = "https://www.502company.com/dev";
  static const String prodBaseUrl = "https://www.502company.com/prod";

  static const String mokDevUrl = "https://scert.mobile-ok.com/gui/service/v1/hauth/request";
  static const String mokProdUrl = "https://cert.mobile-ok.com/gui/service/v1/hauth/request";

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

  // 환경에 따른 mobileOK 표준창 URL 반환
  static String get mokStandardUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
      case Flavor.mock:
        return mokDevUrl;
      case Flavor.prod:
      default:
        return mokProdUrl;
    }
  }
}
