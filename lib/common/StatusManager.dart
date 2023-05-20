import 'package:shared_preferences/shared_preferences.dart';

class StatusManager {
  static final StatusManager _shared = StatusManager._internal();
  late SharedPreferences prefs;

  // int get ownerId => prefs.getInt('ownerId') ?? 0;

  int ownerId = 0;
  factory StatusManager() {
    return _shared;
  }

  StatusManager._internal() {
    //처음 인스턴스를 만들고, 실행하는 코드(?) 걍 init함수 인듯
    //클래스 생성되고 최초 1회만 실행
    // ownerId = 1;
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

// prefs.setInt('counter', 0);
// prefs.setDouble('width', 20.5);
// prefs.setBool('isAdmin', true);
// prefs.setString('userName', 'dev-yakuza');
// prefs.setStringList('alphabet', ['a', 'b', 'c', 'd']);

// final counter = prefs.getInt('counter') ?? 0;
// final width = prefs.getDouble('width') ?? 10.5;
// final isAdmin = prefs.getBool('isAdmin') ?? false;
// final userName = prefs.getString('userName') ?? '';
// final alphabet = prefs.getStringList('alphabet') ?? [];
// final data = prefs.get('userInfo') : {};

// prefs.remove('counter');
}
