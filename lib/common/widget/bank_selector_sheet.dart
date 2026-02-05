import 'package:flutter/material.dart';
import 'package:owner/common/data/bank_list.dart';
import 'package:owner/common/Style/ColorAsset.dart';

/// 은행 선택 바텀시트 — 회원가입과 동일하게 그리드 + 은행/증권사 이미지 표시
void showBankSelectorSheet(
  BuildContext context, {
  required void Function(String name, String code) onSelected,
}) {
  final height = MediaQuery.of(context).size.height * 0.7;
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "은행을 선택해주세요",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101010),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankGrid(ctx, BankList.banks, onSelected),
                  const SizedBox(height: 16),
                  const Text(
                    "증권사 선택",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101010),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBankGrid(ctx, BankList.securities, onSelected),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBankGrid(
  BuildContext context,
  List<Map<String, String>> items,
  void Function(String name, String code) onSelected,
) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    childAspectRatio: 2 / 1.5,
    mainAxisSpacing: 5,
    crossAxisSpacing: 5,
    children: List.generate(items.length, (index) {
      final item = items[index];
      final name = item['name'] ?? '';
      final code = item['code'] ?? '';
      final iconPath = item['icon'] ?? '';
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onSelected(name, code);
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: ColorAssset.bankBackground,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath.isNotEmpty)
                Image.asset(
                  iconPath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(Icons.account_balance, size: 30, color: Color(0xFF808080)),
                  ),
                )
              else
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.account_balance, size: 30, color: Color(0xFF808080)),
                ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF101010),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }),
  );
}
