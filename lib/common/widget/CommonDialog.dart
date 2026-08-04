import 'package:flutter/material.dart';

/// 공통 알림 다이얼로그 — 제목/내용/버튼 스타일 통일
class CommonDialog {
  static const Color _primary = Color(0xFFF27213);
  static const Color _titleColor = Color(0xFF101010);
  static const Color _contentColor = Color(0xFF808080);

  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
    bool cancel = false,
    Widget? icon,
    bool preventPop = false, // true면 뒤로가기/확인 클릭으로 다이얼로그가 닫히지 않음
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        final dialog = AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          titlePadding: EdgeInsets.zero,
          title: null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(height: 20),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _titleColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _contentColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              if (cancel)
                WithCancelBtn(context, onPressed, buttonText)
              else
                OKBtn(context, onPressed, buttonText, preventPop),
            ],
          ),
          actions: const [],
        );

        if (preventPop) {
          return PopScope(canPop: false, child: dialog);
        }
        return dialog;
      },
    );
  }

  static Widget OKBtn(BuildContext context, VoidCallback onPressed, String buttonText,
      [bool preventPop = false]) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
          if (!preventPop) {
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static Widget WithCancelBtn(BuildContext context, VoidCallback onPressed, String buttonText) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _contentColor,
              side: const BorderSide(color: Color(0xFFE6E6E6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText),
            ),
          ),
        ),
      ],
    );
  }
}
