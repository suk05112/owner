/// 전화번호 포맷팅 유틸리티
class PhoneUtils {
  /// 전화번호를 서버 저장 형식으로 변환 (01012345678 -> +821012345678)
  static String formatForServer(String phoneNumber) {
    // 하이픈 제거
    String cleaned = phoneNumber.replaceAll('-', '');
    
    // 0으로 시작하면 제거
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    
    // +82 추가
    return '+82$cleaned';
  }

  /// 전화번호를 화면 표시 형식으로 변환 (01012345678 -> 010-1234-5678)
  static String formatForDisplay(String phoneNumber) {
    // 하이픈 제거
    String cleaned = phoneNumber.replaceAll('-', '');
    
    // +82 제거 및 0으로 시작하지 않으면 0 추가
    if (cleaned.startsWith('+82')) {
      cleaned = '0${cleaned.substring(3)}';
    } else if (!cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }
    
    // 3-4-4 형식으로 포맷팅
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return cleaned;
  }

  /// 이메일 주소에 도메인 추가 (id -> id@gifnut.com)
  static String formatEmailForServer(String id) {
    if (id.contains('@')) {
      return id; // 이미 이메일 형식이면 그대로 반환
    }
    return '$id@gifnut.com';
  }
}
