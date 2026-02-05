import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/common/widget/common_app_bar.dart';

class DetailSettlementPage extends StatefulWidget {
  const DetailSettlementPage(
      {Key? key,
      required this.settlement_id,
      required this.settlement_date,
      required this.settlement_period,
      this.status,
      this.period_start,
      this.period_end})
      : super(key: key);
  final int settlement_id;
  final DateTime settlement_date;
  final int settlement_period;
  final int? status;
  final String? period_start;
  final String? period_end;

  @override
  State<DetailSettlementPage> createState() => _DetailSettlementPageState();
}

class _DetailSettlementPageState extends State<DetailSettlementPage> {
  late int _settlement_id;
  late Future<DetailSettlementList> futureDetailSettlements;

  @override
  void initState() {
    super.initState();
    _settlement_id = widget.settlement_id;
    futureDetailSettlements = Api().client.getDetailSettlements(_settlement_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "상세 정산 내역"),
      backgroundColor: Colors.white,
      body: FutureBuilder<DetailSettlementList>(
        future: futureDetailSettlements,
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
            List<DetailSettlement> settlements =
                snapshot.data!.detailSettlements;

            // 총 정산 금액 계산
            int totalAmount =
                settlements.fold(0, (sum, item) => sum + item.deposit);

            // 날짜별로 그룹화
            Map<String, List<DetailSettlement>> groupedByDate = {};
            for (var settlement in settlements) {
              if (settlement.used_time != null) {
                String dateKey = formatDate(settlement.used_time!);
                groupedByDate.putIfAbsent(dateKey, () => []).add(settlement);
              }
            }

            // 정산 상태 확인
            int status = widget.status ?? 1; // 기본값은 입금완료

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 정산 정보 카드
                  _buildSettlementInfoCard(status, totalAmount),
                  const SizedBox(height: 16),
                  // 주문 내역
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
                  // 날짜별 주문 목록
                  ...groupedByDate.entries.map((entry) {
                    return _buildDateGroup(entry.key, entry.value);
                  }),
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

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildSettlementInfoCard(int status, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  formatSettlementPeriod(
                    widget.settlement_date,
                    widget.settlement_period,
                    periodStart: widget.period_start,
                    periodEnd: widget.period_end,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    if (status == 0) {
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

  Widget _buildDateGroup(String date, List<DetailSettlement> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE6E6E6),
                width: 1,
              ),
            ),
          ),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101010),
              fontFamily: 'Inter',
            ),
          ),
        ),
        // 주문 목록
        ...orders.map((order) => _buildOrderItem(order)),
      ],
    );
  }

  Widget _buildOrderItem(DetailSettlement settlement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE6E6E6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 메뉴명과 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settlement.menu_name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101010),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                if (settlement.used_time != null)
                  Text(
                    formatTime(settlement.used_time!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
              ],
            ),
          ),
          // 오른쪽: 금액 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 메뉴 금액
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
                    formatCurrency(settlement.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 수수료
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
                    "-${formatCurrency(settlement.commission)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 정산금액
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
                    formatCurrency(settlement.deposit),
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
}
