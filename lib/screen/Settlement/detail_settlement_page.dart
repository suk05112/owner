import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/Settlement.dart';

class DetailSettlementPage extends StatefulWidget {
  const DetailSettlementPage({Key? key, required this.settlement_id})
      : super(key: key);
  final int settlement_id;

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
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // 데이터가 정상적으로 로드되었을 때
              List<DetailSettlement> settlements =
                  snapshot.data!.detailSettlements;
              return Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: Column(
                    children: [
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
                                Text("${settlements[index].menu_name}"),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
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
              return Text("정산내역 읽어오기 실패. 잠시 후 다시 시도해주세요.");
            }
          }),
    );
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat('#,###'); // 천 단위 쉼표 추가
    return "${formatter.format(price)}원";
  }
}
