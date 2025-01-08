import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/screen/Settlement/detail_settlement_page.dart';
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
      appBar: AppBar(
        title: Text("정산내역"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<SettlementList>(
          future: futureSettlements, // 비동기적으로 데이터를 가져오는 Future 객체
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터 로딩 중일 때 로딩 인디케이터 표시
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // 데이터가 정상적으로 로드되었을 때
              List<Settlement> settlements = snapshot.data!.settlements;
              return Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: Column(
                    children: [
                      settlementHeader(settlements[0]),
                      Expanded(
                          child: ListView.separated(
                        itemCount: settlements.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailSettlementPage(
                                                settlement_id:
                                                    settlements[index]
                                                        .settlement_id)));
                              },
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(formatSettlementPeriod(
                                          settlements[index].settlement_date,
                                          settlements[index]
                                              .settlement_period)),
                                      Spacer(),
                                      settlementStatus(
                                          settlements[index].status)
                                    ],
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Spacer(),
                                        Text(
                                          formatCurrency(
                                              settlements[index].total_price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ])
                                ],
                              ));
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      ))
                    ],
                  ));
            } else {
              return const Text("정산내역 읽어오기 실패. 잠시 후 다시 시도해주세요.");
            }
          }),
    );
  }

  Widget settlementHeader(Settlement settlement) {
    if (settlement.status == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              "${formatDateTimeToKorean(settlement.settlement_date)}에 정산 예정이에요!"),
          const Text("정산 예정금액"),
          Text(
            formatCurrency(settlement.total_price),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
          Text(formatSettlementPeriod(
              settlement.settlement_date, settlement.settlement_period)),
          const Divider(),
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  Widget settlementStatus(int status) {
    if (status == 0) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Color(0xFF57B3FC),
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignment: Alignment.center,
        child: Text(
          "입금 예정",
          style: TextStyle(
            // fontSize: 38,
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 1) {
      return Container(
        margin: const EdgeInsets.fromLTRB(3, 1, 3, 1),
        decoration: BoxDecoration(
          color: Color(0xFF57B3FC),
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignment: Alignment.center,
        child: const Text(
          "입금 완료",
          style: TextStyle(
            fontSize: 38,
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 2) {
      return Container(
        margin: const EdgeInsets.fromLTRB(3, 1, 3, 1),
        decoration: BoxDecoration(
          color: Color(0xFF57B3FC),
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignment: Alignment.center,
        child: const Text(
          "입금 실패",
          style: TextStyle(
            fontSize: 38,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(3, 1, 3, 1),
      decoration: BoxDecoration(
        color: Color(0xFF57B3FC),
        borderRadius: BorderRadius.circular(5.0),
      ),
      alignment: Alignment.center,
      child: const Text(
        "입금 상태",
        style: TextStyle(
          fontSize: 38,
          color: Colors.white,
        ),
      ),
    );
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
