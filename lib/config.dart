import 'package:owner/flavors.dart';

class AppConfig {
  static const String devBaseUrl = "http://18.221.2.135/dev";
  static const String prodBaseUrl = "http://18.221.2.135";

  static const String env = String.fromEnvironment('ENV', defaultValue: 'prod');

  // 환경에 따른 baseUrl 반환
  static String get baseUrl {
    print("AppConfig:: ${env}");
    return F.appFlavor == Flavor.dev ? devBaseUrl : prodBaseUrl;
  }
}
