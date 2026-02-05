import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';
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
    futureSettlements = Api().client.getSettlementListByStore(_storeId);
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
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF808080),
                  fontFamily: 'Inter',
                ),
              ),
            );
          } else if (snapshot.hasData) {
            List<Settlement> settlements = snapshot.data!.settlements;
            if (settlements.isNotEmpty) {
              // 가장 최근(첫 번째) = 정산예정 카드, 나머지 = 리스트 (Figma 1760-1319)
              final pendingSettlement = settlements.first;
              final pastSettlements =
                  settlements.length > 1 ? settlements.sublist(1) : <Settlement>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPendingSettlementCard(pendingSettlement),
                    if (pastSettlements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...pastSettlements.map(
                        (settlement) => Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 12,
                          ),
                          child: _buildSettlementCard(settlement),
                        ),
                      ),
                    ],
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

  Widget _buildSettlementCard(Settlement settlement) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSettlementPage(
              settlement_id: settlement.settlement_id,
              settlement_date: settlement.settlement_date,
              settlement_period: settlement.settlement_period,
              status: settlement.status,
              period_start: settlement.period_start,
              period_end: settlement.period_end,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: const Color(0xFFE6E6E6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF101010),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    if (status == 0) {
      // 입금 예정
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
    } else if (status == 1) {
      // 입금 완료
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
    } else if (status == 2) {
      // 입금 실패
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
