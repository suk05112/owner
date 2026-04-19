import 'package:flutter/material.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/provier/account_provider.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Account/change_account_page.dart';
import 'package:provider/provider.dart';

/// 계좌관리: 캐시된 계좌 표시(최초 1회 API), 계좌 변경 후에만 재요청
class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({Key? key, required this.storeId})
      : super(key: key);
  final int storeId;

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  bool _loadRequested = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final storeId = widget.storeId;
        final cached = accountProvider.getCached(storeId);
        final hasCache = accountProvider.hasCached(storeId);

        if (!hasCache && !_loadRequested) {
          _loadRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            accountProvider.loadAndCache(storeId);
          });
        }

        if (!hasCache) {
          return const Scaffold(
            appBar: CommonAppBar(title: "계좌관리"),
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final account = cached;
        final hasAccount = account != null &&
            (account.name?.isNotEmpty == true ||
                account.bank?.isNotEmpty == true ||
                account.account?.isNotEmpty == true);

        return Scaffold(
          appBar: const CommonAppBar(title: "계좌관리"),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                  ),
                  child: hasAccount
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "등록된 계좌 정보",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _infoRow("예금주", account.name ?? "-"),
                            _infoRow("은행", account.bank ?? "-"),
                            _infoRow("계좌번호", account.account ?? "-"),
                          ],
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              "등록된 계좌가 없습니다.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _openChangeAccount(context, account),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27213),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("계좌 변경하기"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF808080),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF101010),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChangeAccount(BuildContext context, Account? current) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeAccountPage(
          storeId: widget.storeId,
          initialAccount: current,
        ),
      ),
    );
    if (result == true && context.mounted) {
      await Provider.of<AccountProvider>(context, listen: false)
          .loadAndCache(widget.storeId);
    }
  }
}
