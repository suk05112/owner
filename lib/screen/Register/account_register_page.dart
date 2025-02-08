import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/Style/TextAsset.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/model/Settlement.dart';
import 'package:owner/screen/Register/register_store_page.dart';

class AccountRegisterPage extends StatefulWidget {
  const AccountRegisterPage({Key? key, required this.store}) : super(key: key);
  final Store store;

  @override
  State<AccountRegisterPage> createState() => _AccountRegisterPageState();
}

class _AccountRegisterPageState extends State<AccountRegisterPage> {
  late Store _store;
  String selectedBank = "은행선택";
  late Account account;

  TextEditingController nameController = TextEditingController();
  TextEditingController accountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _store = widget.store;
  }

  final inputDecoration = const InputDecoration(
    hintStyle: TextAssset.placeholder,
    border: UnderlineInputBorder(),
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(0, 10, 21, 5),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text("계좌 등록하기(2/3)"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            backgroundColor: Colors.white,
            body: Container(
                margin: const EdgeInsets.fromLTRB(27, 0, 27, 21),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "정산받을 계좌를 입력해주세요",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const Text(
                            "대표자 본인명의의 계좌만 입력할 수 있으며,\n정산일은 매월 1일, 15일입니다.",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "예금주",
                            style: TextAssset.header2,
                          ),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration:
                                inputDecoration.copyWith(hintText: "예금주명 입력"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '예금주명을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "계좌정보",
                            style: TextAssset.header2,
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet<Map<String, String>>(
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  showDragHandle: true,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 682,
                                      child: bankList(),
                                    );
                                  }).then((value) {
                                print("선택된 은행 ${value!['name']}");
                                setState(() {
                                  selectedBank = value['name']!;
                                  account = Account(
                                    bank: value['name'],
                                    code: value['code'],
                                  );
                                });
                              });
                            },
                            child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                                width: double.infinity,
                                height: 30,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedBank,
                                      // style: const TextStyle(fontSize: 12),
                                    ),
                                    const Spacer(),
                                    const Image(
                                      image:
                                          AssetImage('assets/chevron-down.png'),
                                    )
                                  ],
                                )),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            width: double.infinity,
                            child: TextFormField(
                              controller: accountController,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration.copyWith(
                                  hintText: "계좌번호 입력(-없이 입력)"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '계좌번호를 입력해주세요.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorAssset.mainColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onPressed: () {
                                  if (selectedBank == '은행선택') {
                                    Fluttertoast.showToast(
                                        msg: "은행을 선택해주세요",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    account.account = accountController.text;
                                    account.name = nameController.text;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterStorePage(
                                                  isRegister: true,
                                                  store: _store,
                                                  account: account,
                                                )));
                                  }
                                },
                                child: const Text(
                                  '다음',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                        ])))));
  }

  Widget bankList() {
    List<Map<String, String>> bankData = [
      {'name': 'NH농협', 'code': '011', 'icon': 'assets/bank/bankName=NH농협.png'},
      {
        'name': '카카오뱅크',
        'code': '090',
        'icon': 'assets/bank/bankName=카카오뱅크.png'
      },
      {'name': 'KB국민', 'code': '004', 'icon': 'assets/bank/bankName=KB국민.png'},
      {'name': '토스뱅크', 'code': '092', 'icon': 'assets/bank/bankName=토스뱅크.png'},
      {'name': '신한', 'code': '088', 'icon': 'assets/bank/bankName=신한.png'},
      {
        'name': 'IBK기업',
        'code': '003',
        'icon': 'assets/bank/bankName=IBK기업.png'
      },
      {'name': '하나', 'code': '081', 'icon': 'assets/bank/bankName=하나.png'},
      {'name': '새마을', 'code': '045', 'icon': 'assets/bank/bankName=새마을.png'},
      {'name': '부산', 'code': '032', 'icon': 'assets/bank/bankName=부산.png'},
      {
        'name': 'iM뱅크(대구)',
        'code': '031',
        'icon': 'assets/bank/bankName=대구.png'
      },
      {'name': '케이뱅크', 'code': '089', 'icon': 'assets/bank/bankName=케이뱅크.png'},
      {'name': '신협', 'code': '048', 'icon': 'assets/bank/bankName=신협.png'},
      {'name': '우체국', 'code': '071', 'icon': 'assets/bank/bankName=우체국.png'},
      {'name': 'SC제일', 'code': '023', 'icon': 'assets/bank/bankName=SC제일.png'},
      {'name': '경남', 'code': '039', 'icon': 'assets/bank/bankName=경남.png'},
      {'name': '광주', 'code': '034', 'icon': 'assets/bank/bankName=광주.png'},
      {'name': '수협', 'code': '1007', 'icon': 'assets/bank/bankName=수협.png'},
      {'name': '전북', 'code': '037', 'icon': 'assets/bank/bankName=전북.png'},
      {'name': '저축은행', 'code': '050', 'icon': 'assets/bank/bankName=저축은행.png'},
      {'name': '제주', 'code': '035', 'icon': 'assets/bank/bankName=제주.png'},
      {'name': '씨티', 'code': '027', 'icon': 'assets/bank/bankName=씨티.png'},
      {
        'name': 'KDB산업',
        'code': '002',
        'icon': 'assets/bank/bankName=KDB산업.png'
      },
      {'name': '산림조합', 'code': '064', 'icon': 'assets/bank/bankName=산림조합.png'},
      {
        'name': 'SBI저축은행',
        'code': '103',
        'icon': 'assets/bank/bankName=SBI저축.png'
      },
    ];

    List<Map<String, String>> securitiesData = [
      {
        'name': '토스증권',
        'code': '271',
        'icon': 'assets/securities/bankName=토스뱅크.png'
      },
      {
        'name': '카카오페이증권',
        'code': '288',
        'icon': 'assets/securities/name=카카오.png'
      },
      {
        'name': '미래에셋',
        'code': '230',
        'icon': 'assets/securities/name=미래에셋증권.png'
      },
      {'name': '키움', 'code': '264', 'icon': 'assets/securities/name=키움증권.png'},
      {
        'name': '한국투자',
        'code': '243',
        'icon': 'assets/securities/name=한국투자증권.png'
      },
      {
        'name': '신한투자',
        'code': '106',
        'icon': 'assets/securities/bankName=신한.png'
      },
      {
        'name': '삼성증권',
        'code': '240',
        'icon': 'assets/securities/name=삼성증권.png'
      },
      {
        'name': 'KB증권',
        'code': '226',
        'icon': 'assets/securities/bankName=KB증권.png'
      },
      {'name': 'NH투자', 'code': '289', 'icon': 'assets/securities/name=농협.png'},
      {
        'name': '유안타',
        'code': '209',
        'icon': 'assets/securities/name=유안타증권.png'
      },
      {'name': '대신', 'code': '267', 'icon': 'assets/securities/name=대신증권.png'},
      {
        'name': 'IBK투자',
        'code': '225',
        'icon': 'assets/securities/bankName=IBK기업.png'
      },
      {'name': '하나증권', 'code': '270', 'icon': 'assets/securities/name=하나.png'},
      {
        'name': '한화투자',
        'code': '269',
        'icon': 'assets/securities/name=한화투자증권.png'
      },
      {
        'name': '유진투자',
        'code': '280',
        'icon': 'assets/securities/name=유진투자증권.png'
      },
      {'name': '아이엠증권', 'code': '262', 'icon': 'assets/securities/name=iM.png'},
      {'name': '교보', 'code': '261', 'icon': 'assets/securities/name=교보증권.png'},
      {
        'name': '메리츠증권',
        'code': '287',
        'icon': 'assets/securities/name=메리츠증권.png'
      },
      {'name': 'SK', 'code': '266', 'icon': 'assets/securities/name=sk증권.png'},
      {'name': 'LS', 'code': '265', 'icon': 'assets/securities/name=LS증권.png'},
      {
        'name': '현대차증권',
        'code': '263',
        'icon': 'assets/securities/name=현대차증권.png'
      },
      {
        'name': 'DB금융투자',
        'code': '279',
        'icon': 'assets/securities/name=DB.png'
      },
      {
        'name': '우리투자증권',
        'code': '295',
        'icon': 'assets/securities/name=우리은행.png'
      },
      {'name': '신영', 'code': '291', 'icon': 'assets/securities/name=신영증권.png'},
      {
        'name': '다올투자증권',
        'code': '227',
        'icon': 'assets/securities/name=다올.png'
      },
      {
        'name': '케이프투자',
        'code': '292',
        'icon': 'assets/securities/name=케이프투자증권.png'
      },
      {
        'name': 'BNK투자',
        'code': '224',
        'icon': 'assets/securities/name=BNK.png'
      },
      {'name': '부국', 'code': '290', 'icon': 'assets/securities/name=부국증권.png'},
      {
        'name': '상상인증권',
        'code': '221',
        'icon': 'assets/securities/name=상상인증권.png'
      },
    ];
    return Container(
        color: Colors.white,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(21, 0, 21, 21),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "은행을 선택해주세요",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                  childAspectRatio: 2 / 1.5, //item 의 가로 1, 세로 2 의 비율
                  mainAxisSpacing: 5, //수평 Padding
                  crossAxisSpacing: 5, //수직 Padding
                  physics: ScrollPhysics(),
                  children: List.generate(bankData.length, (index) {
                    final bank = bankData[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, bank);
                      },
                      child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: ColorAssset.bankBackground,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                bank['icon'] ?? 'assets/placeholder.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.fill,
                              ),
                              Text(bank['name'] ?? ''),
                            ],
                          )),
                    );
                  }),
                ),
                const Text("증권사 선택",
                    style: TextStyle(
                      fontSize: 16,
                    )),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                  childAspectRatio: 2 / 1.5, //item 의 가로 1, 세로 2 의 비율
                  mainAxisSpacing: 5, //수평 Padding
                  crossAxisSpacing: 5, //수직 Padding
                  physics: ScrollPhysics(),
                  children: List.generate(securitiesData.length, (index) {
                    final security = securitiesData[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, security);
                      },
                      child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: ColorAssset.bankBackground,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                security['icon'] ?? 'assets/placeholder.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.fill,
                              ),
                              Text(security['name'] ?? ''),
                            ],
                          )),
                    );
                  }),
                ),
              ],
            )));
  }
}
