import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.prod;
  print("설정된 환경 ${F.title}");
  await runner.main();
}
