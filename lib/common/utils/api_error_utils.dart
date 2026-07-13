import 'package:dio/dio.dart';

class ApiErrorUtils {
  static String toUserMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return '서버에 일시적인 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      }
      final data = error.response?.data;
      final detail = _extractDetail(data);
      if (detail != null) {
        return _mapDetail(detail);
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return '네트워크 연결이 불안정합니다. 잠시 후 다시 시도해주세요.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return '인터넷 연결을 확인해주세요.';
      }
    }
    return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  static String? _extractDetail(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) return first['msg']?.toString();
        return first.toString();
      }
      final message = data['message'];
      if (message is String) return message;
    }
    if (data is String) return data;
    return null;
  }

  static String _mapDetail(String detail) {
    // 서버가 이미 한글 사용자용 메시지를 내려준 경우 그대로 사용
    if (RegExp(r'[가-힣]').hasMatch(detail)) {
      return detail;
    }
    final lower = detail.toLowerCase();
    if (lower.contains('duplicate entry') && lower.contains('uk_email')) {
      return '이미 가입된 이메일입니다. 다른 이메일을 사용하거나 로그인해주세요.';
    }
    if (lower.contains('duplicate entry') && lower.contains('uk_phone')) {
      return '이미 가입된 전화번호입니다.';
    }
    if (lower.contains('duplicate entry')) {
      return '이미 등록된 정보입니다.';
    }
    if (lower.contains('not found') || lower.contains('no such')) {
      return '요청한 정보를 찾을 수 없습니다.';
    }
    return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }
}
