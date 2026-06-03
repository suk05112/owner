import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/common/utils/api_error_utils.dart';
import 'package:owner/common/widget/common_app_bar.dart';

class DetailSettlementPage extends StatefulWidget {
  const DetailSettlementPage(
      {Key? key,
      this.settlement_id,
      this.store_id,
      required this.settlement_date,
      required this.settlement_period,
      this.status,
      this.period_start,
      this.period_end})
      : super(key: key);
  final int? settlement_id;
  final int? store_id;
  final DateTime settlement_date;
  final int settlement_period;
  final String? status;
  final String? period_start;
  final String? period_end;

  @override
  State<DetailSettlementPage> createState() => _DetailSettlementPageState();
}

class _DetailSettlementPageState extends State<DetailSettlementPage> {
  late Future<SettlementDetailResponse> futureDetailSettlements;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final settlementId = widget.settlement_id;
    final storeId = widget.store_id;
    if (settlementId != null) {
      futureDetailSettlements = Api().client.getDetailSettlements(settlementId);
    } else if (storeId != null) {
      futureDetailSettlements = Api().client.getSettlementPreview(storeId);
    } else {
      futureDetailSettlements = Future.error('잘못된 접근입니다.');
    }
  }

  void _retry() {
    setState(() => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "상세 정산 내역"),
      backgroundColor: Colors.white,
      body: FutureBuilder<SettlementDetailResponse>(
        future: futureDetailSettlements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: const CircularProgressIndicator(color: Color(0xFFFE7831)),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error);
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final settlement = data.settlement;
            final details = data.details;

            int totalAmount = settlement.net_payout_amount;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettlementInfoCard(
                    settlement.status,
                    totalAmount,
                    periodStart: settlement.period_start,
                    periodEnd: settlement.period_end,
                    failureReason: settlement.failure_reason,
                    totalSalesAmount: settlement.total_sales_amount,
                    totalFeeAmount: settlement.total_fee_amount,
                    baseFeeRate: settlement.base_fee_rate,
                    promoFeeRate: settlement.promo_fee_rate,
                    promoDiscountAmount: settlement.promo_discount_amount,
                    supplyAmount: settlement.supply_amount,
                    vatAmount: settlement.vat_amount,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "주문 내역",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101010),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (data.parseFailureCount > 0)
                    _buildParseFailureWarning(data.parseFailureCount),
                  _buildDetailsList(details),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "정산내역 읽어오기 실패. 잠시 후 다시 시도해주세요.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF808080),
                  fontFamily: 'Inter',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String formatSettlementPeriod(
    DateTime settlementDate,
    int settlementPeriod, {
    String? periodStart,
    String? periodEnd,
  }) {
    if (periodStart != null && periodEnd != null) {
      try {
        final start = DateTime.parse(periodStart);
        final end = DateTime.parse(periodEnd);
        return "${start.year}년 ${start.month}월 ${start.day}일 ~ ${end.month}월 ${end.day}일";
      } catch (_) {}
    }
    if (settlementPeriod == 0) {
      final year = settlementDate.year;
      final month = settlementDate.month;
      return "$year년 $month월 1일~$month월 15일";
    } else if (settlementPeriod == 1) {
      final previousMonth =
          DateTime(settlementDate.year, settlementDate.month - 1, 16);
      final year = previousMonth.year;
      final month = previousMonth.month;
      final lastDay =
          DateTime(settlementDate.year, settlementDate.month, 0).day;
      return "$year년 $month월 16일~$month월 $lastDay일";
    }
    return "${settlementDate.year}년 ${settlementDate.month}월 정산";
  }

  String formatDateTimeToKorean(DateTime dateTime) {
    // 년, 월, 일을 추출
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0'); // 두 자리로 보장
    final day = dateTime.day.toString().padLeft(2, '0'); // 두 자리로 보장

    // 한국어 형식으로 반환
    return "$year년 $month월 $day일";
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat('#,###'); // 천 단위 쉼표 추가
    return "${formatter.format(price)}원";
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildSettlementInfoCard(
    String? status,
    int totalAmount, {
    String? periodStart,
    String? periodEnd,
    String? failureReason,
    int totalSalesAmount = 0,
    int totalFeeAmount = 0,
    double? baseFeeRate,
    double? promoFeeRate,
    int? promoDiscountAmount,
    int supplyAmount = 0,
    int vatAmount = 0,
  }) {
    String periodText = '정산 기간';
    if (periodStart != null && periodEnd != null) {
      try {
        final start = DateTime.parse(periodStart);
        final end = DateTime.parse(periodEnd);
        periodText =
            "${start.year}년 ${start.month}월 ${start.day}일 ~ ${end.month}월 ${end.day}일";
      } catch (_) {}
    }

    final hasPromo = promoFeeRate != null && promoDiscountAmount != null;
    final baseFeeLabel = baseFeeRate != null
        ? '수수료(${baseFeeRate.toStringAsFixed(1)}%)'
        : '수수료';
    final baseFeeTotal = supplyAmount + (promoDiscountAmount ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 + 상태 배지
          Row(
            children: [
              Expanded(
                child: Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101010),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          // 정산 금액 (대표 숫자)
          const Text(
            "정산 금액",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(totalAmount),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF27213),
              fontFamily: 'Inter',
            ),
          ),
          // 실패 사유
          if (status?.toUpperCase() == 'FAILED' &&
              failureReason != null &&
              failureReason.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "실패 사유",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF808080),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              failureReason.trim(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.red,
                fontFamily: 'Inter',
              ),
            ),
          ],
          // 수수료 내역 (baseFeeRate가 있을 때만 표시)
          if (baseFeeRate != null) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 16),
            // (A) 매출액
            _buildFeeRow(
              label: '(A) 매출액',
              value: formatCurrency(totalSalesAmount),
            ),
            const SizedBox(height: 10),
            // (B) 수수료
            if (hasPromo) ...[
              // (B) 수수료 - 취소선
              Row(
                children: [
                  Text(
                    '(B) $baseFeeLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatCurrency(baseFeeTotal),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFBBBBBB),
                      fontFamily: 'Inter',
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Color(0xFFBBBBBB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // 프로모션 할인 (들여쓰기 — (B) prefix 너비에 맞춤)
              Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    '프로모션 할인(${(baseFeeRate! - promoFeeRate).toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF34C759),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '-${formatCurrency(promoDiscountAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF34C759),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // → 최종 수수료 (들여쓰기)
              Row(
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    '최종 수수료',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101010),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatCurrency(supplyAmount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101010),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildFeeRow(
                label: '(B) $baseFeeLabel',
                value: formatCurrency(totalFeeAmount),
              ),
            ],
            const SizedBox(height: 10),
            // (C) 부가세
            _buildFeeRow(
              label: '(C) 부가세',
              value: formatCurrency(vatAmount),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
            const SizedBox(height: 14),
            // 정산총액
            Row(
              children: [
                Text(
                  '정산총액  A - B - C',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101010),
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                Text(
                  formatCurrency(totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF27213),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRow({required String label, required String value}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF101010),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  /// used_at 문자열 파싱 — "yyyy-MM-dd HH:mm" 또는 ISO 8601 모두 처리
  DateTime? _parseUsedAt(String? usedAt) {
    if (usedAt == null || usedAt.isEmpty) return null;
    try {
      return DateTime.parse(usedAt);
    } catch (_) {}
    // "yyyy-MM-dd HH:mm" 형식 fallback
    try {
      return DateTime.parse('${usedAt.trim()}:00');
    } catch (_) {}
    return null;
  }

  /// used_at에서 날짜 키 추출 (yyyy.MM.dd)
  String _dateKeyFromUsedAt(String? usedAt) {
    final dt = _parseUsedAt(usedAt);
    if (dt == null) return '';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  /// used_at에서 시간만 (HH:mm)
  String _timeFromUsedAt(String? usedAt) {
    final dt = _parseUsedAt(usedAt);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailsList(List<SettlementDetailItem> details) {
    if (details.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          "주문 내역이 없습니다.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      );
    }
    // 날짜별 그룹화 (used_at 기준)
    final Map<String, List<SettlementDetailItem>> byDate = {};
    for (final d in details) {
      final key = _dateKeyFromUsedAt(d.used_at).isEmpty ? '기타' : _dateKeyFromUsedAt(d.used_at);
      byDate.putIfAbsent(key, () => []).add(d);
    }
    // 날짜 순 정렬 (기타는 마지막)
    final sortedKeys = byDate.keys.toList()
      ..sort((a, b) {
        if (a == '기타') return 1;
        if (b == '기타') return -1;
        return b.compareTo(a);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((dateKey) {
        final items = byDate[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateKey != '기타')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101010),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ...items.map((d) => _buildOrderItemRow(
                  menuName: d.menu_name?.trim().isNotEmpty == true ? d.menu_name! : '주문',
                  timeStr: _timeFromUsedAt(d.used_at),
                  amount: d.amount,
                  feeAmount: d.fee_amount,
                  settlementAmount: d.settlement_amount,
                )),
          ],
        );
      }).toList(),
    );
  }

  /// 좌측 메뉴명+시간, 우측 메뉴금액·수수료(숫자만)·정산금액(주황), 구분선
  Widget _buildOrderItemRow({
    required String menuName,
    required String timeStr,
    required int amount,
    required int feeAmount,
    required int settlementAmount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E6E6), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101010),
                    fontFamily: 'Inter',
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "메뉴 금액",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCurrency(amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF101010),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "수수료",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCurrency(feeAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF101010),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "정산금액",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF27213),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCurrency(settlementAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF27213),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParseFailureWarning(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF27213).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF27213)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '일부 주문 내역($count건)을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFF27213),
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object? error) {
    final message = ApiErrorUtils.toUserMessage(error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF808080),
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _retry,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF27213),
                side: const BorderSide(color: Color(0xFFF27213)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final u = status?.toUpperCase() ?? '';
    if (u == 'PENDING' || u == 'READY') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF57B3FC).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "입금 예정",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF57B3FC),
            fontFamily: 'Inter',
          ),
        ),
      );
    }
    if (u == 'COMPLETED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF27213).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "입금완료",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFF27213),
            fontFamily: 'Inter',
          ),
        ),
      );
    }
    if (u == 'FAILED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "입금 실패",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.red,
            fontFamily: 'Inter',
          ),
        ),
      );
    }
    if (u == 'HOLD') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF808080).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "보류",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

}
