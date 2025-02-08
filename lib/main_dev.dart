import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.dev;
  print("설정된 환경 ${F.appFlavor}");
  await runner.main();
}
