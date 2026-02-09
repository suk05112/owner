import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/widget/CommonDialog.dart';

/// 인터넷 연결 확인 및 오프라인 안내 공통 모듈
class NetworkUtils {
  NetworkUtils._();

  static bool _didShowOfflineOnLaunch = false;

  /// 현재 연결 상태 확인 (WiFi/모바일 등 연결 여부)
  static Future<bool> isOnline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      return hasConnection;
    } catch (_) {
      return false;
    }
  }

  /// 오프라인일 때 공통 안내 다이얼로그 표시
  static void showOfflineDialog(BuildContext context) {
    CommonDialog.show(
      context: context,
      title: '인터넷 연결 안내',
      content: '인터넷에 연결되어 있지 않습니다.\n네트워크 연결을 확인한 후 다시 시도해주세요.',
      buttonText: '확인',
      onPressed: () {},
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF27213).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.wifi_off_rounded, size: 28, color: Color(0xFFF27213)),
      ),
    );
  }

  /// 연결 여부 확인 후, 오프라인이면 안내 다이얼로그 표시. 반환값: 온라인이면 true
  static Future<bool> checkAndShowOfflineDialogIfNeeded(BuildContext context) async {
    final online = await isOnline();
    if (!online && context.mounted) {
      showOfflineDialog(context);
      return false;
    }
    return true;
  }

  /// 앱 최초 진입 시 한 번만 오프라인 여부 확인 후 다이얼로그 표시
  static Future<void> checkOnFirstLaunchAndShowDialogIfOffline(BuildContext context) async {
    if (_didShowOfflineOnLaunch) return;
    final online = await isOnline();
    if (!online && context.mounted) {
      _didShowOfflineOnLaunch = true;
      showOfflineDialog(context);
    }
  }
}
