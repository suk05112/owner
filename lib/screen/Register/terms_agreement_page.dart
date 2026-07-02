import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'terms_web_view_page.dart';

enum _TermsType {
  service('SERVICE'),
  fee('FEE'),
  privacy('PRIVACY_CONSENT'),
  marketing('MARKETING');

  const _TermsType(this.termType);
  final String termType;
}

class TermsAgreementPage extends StatefulWidget {
  final void Function(List<TermAgreementItem> agreements) onAgreed;

  const TermsAgreementPage({Key? key, required this.onAgreed}) : super(key: key);

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  bool agreeAll = false;
  bool agreeService = false;
  bool agreeFee = false;
  bool agreePrivacy = false;
  bool agreeMarketing = false;

  List<TermItem> _termItems = [];

  bool get _canProceed => agreeService && agreeFee && agreePrivacy;

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
    final typeToAgreed = {
      'SERVICE': agreeService,
      'FEE': agreeFee,
      'PRIVACY_CONSENT': agreePrivacy,
      'MARKETING': agreeMarketing,
    };
    return _termItems.map((term) {
      return TermAgreementItem(
        termId: term.termId,
        termVersionId: term.termVersionId,
        agreed: typeToAgreed[term.termType] ?? false,
      );
    }).toList();
  }

  void _toggleAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      agreeAll = checked;
      agreeService = checked;
      agreeFee = checked;
      agreePrivacy = checked;
      agreeMarketing = checked;
    });
  }

  void _toggleItem({required bool value, required ValueSetter<bool> update}) {
    setState(() {
      update(!value);
      agreeAll = agreeService && agreeFee && agreePrivacy && agreeMarketing;
    });
  }

  void _openDetail(_TermsType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsWebViewPage(
          title: _termTitle(type),
          termType: type.termType,
        ),
      ),
    );
  }

  String _termTitle(_TermsType type) {
    switch (type) {
      case _TermsType.service:
        return '서비스 이용약관';
      case _TermsType.fee:
        return '수수료 정책동의';
      case _TermsType.privacy:
        return '개인정보 수집 및 이용동의';
      case _TermsType.marketing:
        return '마케팅 정보 수신 동의';
    }
  }

  void _handleConfirm() {
    if (!_canProceed) return;
    widget.onAgreed(_buildAgreements());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CommonAppBar(title: '약관동의'),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AgreementTile(
                  label: '약관 전체동의',
                  requiredLabel: '',
                  value: agreeAll,
                  onChanged: _toggleAll,
                  onLinkTap: null,
                  isAll: true,
                ),
                const Divider(height: 16),
                _AgreementTile(
                  label: '서비스 이용약관 동의',
                  requiredLabel: '(필수)',
                  value: agreeService,
                  onChanged: (_) => _toggleItem(
                    value: agreeService,
                    update: (v) => agreeService = v,
                  ),
                  onLinkTap: () => _openDetail(_TermsType.service),
                ),
                _AgreementTile(
                  label: '수수료 정책동의',
                  requiredLabel: '(필수)',
                  value: agreeFee,
                  onChanged: (_) => _toggleItem(
                    value: agreeFee,
                    update: (v) => agreeFee = v,
                  ),
                  onLinkTap: () => _openDetail(_TermsType.fee),
                ),
                _AgreementTile(
                  label: '개인정보 수집 및 이용동의',
                  requiredLabel: '(필수)',
                  value: agreePrivacy,
                  onChanged: (_) => _toggleItem(
                    value: agreePrivacy,
                    update: (v) => agreePrivacy = v,
                  ),
                  onLinkTap: () => _openDetail(_TermsType.privacy),
                ),
                _AgreementTile(
                  label: '마케팅 정보 수신 동의',
                  requiredLabel: '(선택)',
                  value: agreeMarketing,
                  onChanged: (_) => _toggleItem(
                    value: agreeMarketing,
                    update: (v) => agreeMarketing = v,
                  ),
                  onLinkTap: () => _openDetail(_TermsType.marketing),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _handleConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorAssset.mainColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.label,
    required this.requiredLabel,
    required this.value,
    required this.onChanged,
    this.onLinkTap,
    this.isAll = false,
  });

  final String label;
  final String requiredLabel;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onLinkTap;
  final bool isAll;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashColor: Colors.grey[100],
      highlightColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: const CircleBorder(),
                activeColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isAll ? 15 : 14,
                    fontWeight: isAll ? FontWeight.w600 : FontWeight.w400,
                    height: 1.3,
                  ),
                  children: [
                    if (requiredLabel.isNotEmpty)
                      TextSpan(
                        text: ' $requiredLabel',
                        style: TextStyle(
                          color: requiredLabel.contains('필수')
                              ? Colors.redAccent
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onLinkTap != null)
              GestureDetector(
                onTap: onLinkTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
