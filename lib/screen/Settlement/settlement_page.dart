import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/common/utils/api_error_utils.dart';
import 'package:owner/screen/Settlement/detail_settlement_page.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:intl/intl.dart';

class SettlementPage extends StatefulWidget {
  const SettlementPage({Key? key, required this.storeId}) : super(key: key);
  final int storeId;

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  late int _storeId;
  late Future<SettlementList> futureSettlements;

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    _load();
  }

  void _load() {
    futureSettlements = Api().client.getSettlementListByStore(_storeId, 3);
  }

  void _retry() {
    setState(() => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "정산 내역"),
      backgroundColor: Colors.white,
      body: FutureBuilder<SettlementList>(
        future: futureSettlements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error);
          } else if (snapshot.hasData) {
            List<Settlement> settlements = snapshot.data!.settlements;
            if (settlements.isNotEmpty) {
              // 상단 카드: PENDING이면서 expected_payout_date가 오늘 이상인 것 중 가장 앞선(가장 빠른) 날짜 항목
              final cardSettlement = _findPendingSettlementForCard(settlements);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (cardSettlement != null) _buildPendingSettlementCard(cardSettlement),
                    if (cardSettlement != null) const SizedBox(height: 16),
                    _buildSettlementList(settlements),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  '정산 내역이 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF808080),
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }
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

  /// PENDING이면서 expected_payout_date가 오늘 이상인 항목 중 가장 빠른 날짜 것 반환
  Settlement? _findPendingSettlementForCard(List<Settlement> settlements) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Settlement? candidate;
    for (final s in settlements) {
      if (s.status?.toUpperCase() != 'PENDING') continue;
      final payoutDate = DateTime(s.settlement_date.year, s.settlement_date.month, s.settlement_date.day);
      if (payoutDate.isBefore(today)) continue; // 오늘 지난 건 제외
      if (candidate == null || s.settlement_date.isBefore(candidate.settlement_date)) {
        candidate = s;
      }
    }
    return candidate;
  }

  /// Figma 1760-1319: 정산예정 카드 — 화면 전체 너비, 16 radius, #e6e6e6 테두리
  Widget _buildPendingSettlementCard(Settlement settlement) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${formatDateTimeToKorean(settlement.settlement_date)}에 정산 예정이에요!",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101010),
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "정산 예정금액",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(settlement.total_price),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF27213),
              fontFamily: 'Inter',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatSettlementPeriod(
              settlement.settlement_date,
              settlement.settlement_period,
              periodStart: settlement.period_start,
              periodEnd: settlement.period_end,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  /// Figma 1760-1340: 박스 없이 구분선만으로 리스트 표시
  Widget _buildSettlementList(List<Settlement> settlements) {
    return Column(
      children: [
        for (int i = 0; i < settlements.length; i++) ...[
          _buildSettlementListTile(settlements[i]),
          if (i < settlements.length - 1)
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
        ],
      ],
    );
  }

  Widget _buildSettlementListTile(Settlement settlement) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          final id = settlement.settlement_id;
          if (id == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSettlementPage(
                settlement_id: id,
                settlement_date: settlement.settlement_date,
                settlement_period: settlement.settlement_period,
                status: settlement.status,
                period_start: settlement.period_start,
                period_end: settlement.period_end,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatSettlementPeriod(
                              settlement.settlement_date,
                              settlement.settlement_period,
                              periodStart: settlement.period_start,
                              periodEnd: settlement.period_end,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF101010),
                              fontFamily: 'Inter',
                              height: 20 / 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(settlement.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(settlement.total_price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF27213),
                        fontFamily: 'Inter',
                        height: 28 / 18,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF101010),
                size: 20,
              ),
            ],
          ),
        ),
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
      final lastDay = DateTime(settlementDate.year, settlementDate.month, 0).day;
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
}
