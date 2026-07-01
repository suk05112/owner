import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'terms_web_view_page.dart';

class _TermsItem {
  final String label;
  final bool required;
  final String termType;
  bool agreed = false;

  _TermsItem({
    required this.label,
    required this.required,
    required this.termType,
  });
}

class TermsAgreementPage extends StatefulWidget {
  final void Function(List<TermAgreementItem> agreements) onAgreed;

  const TermsAgreementPage({Key? key, required this.onAgreed}) : super(key: key);

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  List<_TermsItem> _terms = [
    _TermsItem(label: '서비스 이용약관', required: true, termType: 'SERVICE'),
    _TermsItem(label: '수수료 정책동의', required: true, termType: 'FEE'),
    _TermsItem(label: '개인정보 수집 및 이용동의', required: true, termType: 'PRIVACY_CONSENT'),
    _TermsItem(label: '마케팅 정보 수신 동의', required: false, termType: 'MARKETING'),
  ];

  List<TermItem> _termItems = [];

  bool get _allAgreed => _terms.every((t) => t.agreed);
  bool get _allRequiredAgreed => _terms.where((t) => t.required).every((t) => t.agreed);

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final response = await Api().client.getTermsCurrent();
      if (mounted) {
        setState(() {
          _termItems = response.terms;
        });
      }
    } catch (_) {}
  }

  List<TermAgreementItem> _buildAgreements() {
    final typeToAgreed = {for (final t in _terms) t.termType: t.agreed};
    return _termItems.map((term) {
      return TermAgreementItem(
        termId: term.termId,
        termVersionId: term.termVersionId,
        agreed: typeToAgreed[term.termType] ?? false,
      );
    }).toList();
  }

  void _toggleAll(bool value) {
    setState(() {
      for (final t in _terms) {
        t.agreed = value;
      }
    });
  }

  void _toggleItem(int index, bool value) {
    setState(() {
      _terms[index].agreed = value;
    });
  }

  void _openDetail(BuildContext context, _TermsItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsWebViewPage(
          title: item.label,
          termType: item.termType,
        ),
      ),
    );
  }

  void _handleConfirm() {
    widget.onAgreed(_buildAgreements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '약관동의'),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildAllAgreeRow(),
                  ..._terms.asMap().entries.map((e) => _buildTermRow(e.key, e.value)),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('서비스 이용을 위해\n약관에 동의해주세요.', style: TextAssset.header1),
          const SizedBox(height: 8),
          Text(
            '필수 항목에 동의하셔야 서비스를 이용하실 수 있습니다.',
            style: TextAssset.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildAllAgreeRow() {
    return InkWell(
      onTap: () => _toggleAll(!_allAgreed),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _CheckIcon(checked: _allAgreed),
            const SizedBox(width: 12),
            const Text('전체 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff131313), fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  Widget _buildTermRow(int index, _TermsItem item) {
    return InkWell(
      onTap: () => _toggleItem(index, !item.agreed),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
        child: Row(
          children: [
            _CheckIcon(checked: item.agreed),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Color(0xff131313), fontFamily: 'Inter'),
                  children: [
                    if (item.required)
                      const TextSpan(
                        text: '(필수) ',
                        style: TextStyle(color: ColorAssset.mainColor, fontWeight: FontWeight.w500),
                      )
                    else
                      const TextSpan(
                        text: '(선택) ',
                        style: TextStyle(color: Color(0xff6A6A6A), fontWeight: FontWeight.w500),
                      ),
                    TextSpan(text: item.label),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xff9E9E9E)),
              onPressed: () => _openDetail(context, item),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _allRequiredAgreed ? ColorAssset.mainColor : const Color(0xffD9D9D9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 0,
          ),
          onPressed: _allRequiredAgreed ? _handleConfirm : null,
          child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  final bool checked;

  const _CheckIcon({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? ColorAssset.mainColor : Colors.transparent,
        border: Border.all(
          color: checked ? ColorAssset.mainColor : const Color(0xffD0D0D0),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
