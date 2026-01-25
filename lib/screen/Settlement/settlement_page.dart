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
              // status == 0인 정산 예정 항목 찾기
              Settlement? pendingSettlement;
              List<Settlement> pastSettlements = [];

              for (var settlement in settlements) {
                if (settlement.status == 0 && pendingSettlement == null) {
                  pendingSettlement = settlement;
                } else {
                  pastSettlements.add(settlement);
                }
              }

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 정산 예정 카드
                    if (pendingSettlement != null)
                      _buildPendingSettlementCard(pendingSettlement),
                    if (pendingSettlement != null && pastSettlements.isNotEmpty)
                      const SizedBox(height: 16),
                    // 정산 내역 카드들
                    ...pastSettlements.map((settlement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSettlementCard(settlement),
                        )),
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

  Widget _buildPendingSettlementCard(Settlement settlement) {
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
          Text(
            "${formatDateTimeToKorean(settlement.settlement_date)}에 정산 예정이에요!",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101010),
              fontFamily: 'Inter',
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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatSettlementPeriod(
              settlement.settlement_date,
              settlement.settlement_period,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
              fontFamily: 'Inter',
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

  String formatSettlementPeriod(DateTime settlementDate, int settlementPeriod) {
    // Parse settlementDate
    // final date = DateTime.parse(settlementDate);

    if (settlementPeriod == 0) {
      // 같은 달의 1~15일
      final year = settlementDate.year;
      final month = settlementDate.month;
      return "$year년 $month월 1일~$month월 15일";
    } else if (settlementPeriod == 1) {
      // 이전 달의 16~말일
      final previousMonth =
          DateTime(settlementDate.year, settlementDate.month - 1, 16);
      final year = previousMonth.year;
      final month = previousMonth.month;
      final lastDay = DateTime(settlementDate.year, settlementDate.month, 0)
          .day; // 이전 달 말일 계산
      return "$year년 $month월 16일~$month월 $lastDay일";
    }

    return "Invalid settlement period";
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
