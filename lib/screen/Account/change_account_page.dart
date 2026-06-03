import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/utils/account_number_formatter.dart';
import 'package:owner/common/widget/bank_selector_sheet.dart';
import 'package:owner/common/widget/common_app_bar.dart';

/// Figma 1787-573: 계좌 변경 — 은행 선택·계좌번호·예금주·안내문·변경하기
class ChangeAccountPage extends StatefulWidget {
  const ChangeAccountPage({
    Key? key,
    required this.storeId,
    this.initialAccount,
  }) : super(key: key);

  final int storeId;
  final Account? initialAccount;

  @override
  State<ChangeAccountPage> createState() => _ChangeAccountPageState();
}

class _ChangeAccountPageState extends State<ChangeAccountPage> {
  String _bankName = '';
  String _bankCode = '';
  final _accountController = TextEditingController();
  final _nameController = TextEditingController();
  File? _bankBook;
  String? _bankBookFilename;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  static const Color _borderColor = Color(0xFFE6E6E6);
  static const Color _hintColor = Color(0xFF808080);
  static const Color _primary = Color(0xFFF27213);
  static const Color _noticeBg = Color(0xFFFFEDE0);

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bank = _bankName.trim();
    final account = _accountController.text.trim().replaceAll('-', '');
    final name = _nameController.text.trim();
    if (bank.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('은행을 선택해주세요.')),
      );
      return;
    }
    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌번호를 입력해주세요.')),
      );
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(account)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌번호는 숫자만 입력 가능합니다.')),
      );
      return;
    }
    if (account.length < 10 || account.length > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌번호는 10~14자리여야 합니다.')),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예금주명을 입력해주세요.')),
      );
      return;
    }
    if (!RegExp(r'^[가-힣\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예금주는 한글만 입력 가능합니다.')),
      );
      return;
    }
    if (_bankBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('통장 사본을 추가해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await Api().client.updateAccount(
            widget.storeId,
            Account(
              name: name,
              code: _bankCode.isEmpty ? null : _bankCode,
              bank: bank,
              account: account,
            ),
          );

      if (_bankBook != null && response.bank_book_put_url != null) {
        print("response.bank_book_put_url: ${response.bank_book_put_url}");
        final bytes = await _bankBook!.readAsBytes();
        final ext = _bankBookFilename?.toLowerCase() ?? '';
        final contentType = ext.endsWith('.jpg') || ext.endsWith('.jpeg')
            ? 'image/jpeg'
            : 'image/png';
        final dio = Dio(BaseOptions(
          validateStatus: (status) => status != null && status < 500,
        ));
        // S3 presigned PUT: raw bytes as stream, Content-Length required
        final uploadRes = await dio.put<dynamic>(
          response.bank_book_put_url!,
          data: Stream.fromIterable([bytes]),
          options: Options(
            contentType: contentType,
            headers: {'Content-Length': bytes.length},
          ),
        );
        print("uploadRes: ${uploadRes.statusCode}");
        if (uploadRes.statusCode != 200 && mounted) {
          setState(() => _isSubmitting = false);
          final errMsg =
              uploadRes.data?.toString() ?? '${uploadRes.statusCode}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('통장 사본 업로드 실패: $errMsg')),
          );
          return;
        }
      } else {
        print("uploadRes: 값 없음");
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌가 변경되었습니다.')),
      );
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      if (!mounted) return;
      String message = '계좌 변경에 실패했습니다.';
      final data = e.response?.data;
      if (data != null) {
        try {
          final decoded =
              data is String ? jsonDecode(data) as Map : data as Map;
          final detail = decoded['detail'];
          if (detail is List && detail.isNotEmpty) {
            final first = detail[0];
            if (first is Map && first['msg'] != null) {
              String msg = first['msg'].toString();
              if (msg.startsWith('Value error, ')) {
                msg = msg.replaceFirst('Value error, ', '');
              }
              message = msg;
            }
          }
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('변경 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const CommonAppBar(title: "계좌 변경"),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 은행
                      _label("은행"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showBankSelectorSheet(context,
                              onSelected: (name, code) {
                            setState(() {
                              _bankName = name;
                              _bankCode = code;
                              _accountController.clear();
                            });
                          });
                        },
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _bankName.isEmpty ? "은행 선택" : _bankName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: _bankName.isEmpty
                                      ? _hintColor
                                      : const Color(0xFF101010),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 16, color: _hintColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 계좌번호
                      _label("계좌번호"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          AccountNumberFormatter(bankCode: _bankCode),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        decoration: _inputDecoration(
                          hint: _bankCode.isEmpty ? "은행 선택 후 입력해주세요" : "계좌번호를 입력해주세요",
                        ),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF101010)),
                      ),
                      const SizedBox(height: 24),

                      // 예금주
                      _label("예금주"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ\s]')),
                        ],
                        decoration: _inputDecoration(hint: "이름을 입력해주세요"),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF101010)),
                      ),
                      const SizedBox(height: 24),

                      // 통장 사본 (필수)
                      _label("통장 사본 (필수)"),
                      const SizedBox(height: 4),
                      const Text(
                        "사업자 등록증에 있는 사업자와 동일해야 합니다.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _hintColor,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (picked != null && mounted) {
                            setState(() {
                              _bankBook = File(picked.path);
                              _bankBookFilename = picked.name;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  color: _hintColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _bankBookFilename ?? "파일 추가",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _hintColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (_bankBook != null)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _bankBook = null;
                                    _bankBookFilename = null;
                                  }),
                                  child: const Icon(Icons.close,
                                      color: _hintColor, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 안내
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _noticeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "계좌 정보 변경 시 확인 절차가 필요할 수 있습니다.",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _primary,
                                height: 1.33,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "정확한 정보를 입력해 주세요.",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _primary,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 버튼 영역
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _borderColor)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "변경하기",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: const CircularProgressIndicator(color: Color(0xFFFE7831)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _hintColor,
        height: 20 / 14,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _hintColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1),
      ),
    );
  }
}
