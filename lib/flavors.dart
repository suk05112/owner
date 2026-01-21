enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Gifnut 사장님 Dev';
      case Flavor.prod:
        return 'Gifnut 사장님';
      default:
        return 'title';
    }
  }
}
