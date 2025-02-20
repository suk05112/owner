import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';

class DetailSettlementPage extends StatefulWidget {
  const DetailSettlementPage(
      {Key? key,
      required this.settlement_id,
      required this.settlement_date,
      required this.settlement_period})
      : super(key: key);
  final int settlement_id;
  final DateTime settlement_date;
  final int settlement_period;

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
      appBar: AppBar(
        title: Text("정산내역"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DetailSettlementList>(
          future: futureDetailSettlements, // 비동기적으로 데이터를 가져오는 Future 객체
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터 로딩 중일 때 로딩 인디케이터 표시
              return const Center(
                  child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // 데이터가 정상적으로 로드되었을 때
              List<DetailSettlement> settlements =
                  snapshot.data!.detailSettlements;
              return Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        "${formatSettlementPeriod(widget.settlement_date, widget.settlement_period)}의 정산 내역이에요",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                          child: ListView.separated(
                        itemCount: settlements.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(children: [
                                Text("${settlements[index].used_time}"),
                                const Spacer(),
                              ]),
                              Row(children: [
                                Text(settlements[index].menu_name),
                                const Spacer(),
                              ]),
                              Row(
                                children: [
                                  const Text("(A)매출금액"),
                                  const Spacer(),
                                  Text(
                                      formatCurrency(settlements[index].price)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("(B)중개수수료"),
                                  const Spacer(),
                                  Text(formatCurrency(
                                      settlements[index].commission)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("입금금액(A-B)"),
                                  const Spacer(),
                                  Text(
                                    formatCurrency(settlements[index].deposit),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )
                            ],
                          );
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
