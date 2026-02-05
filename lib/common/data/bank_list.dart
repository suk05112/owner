/// 은행/증권사 목록 (이미지 경로 포함 — 회원가입·계좌변경 공통)
class BankList {
  static const List<Map<String, String>> banks = [
    {'name': 'NH농협은행', 'code': '011', 'icon': 'assets/bank/bankName=NH농협.png'},
    {'name': '지역농축협', 'code': '012', 'icon': 'assets/bank/bankName=NH농협.png'},
    {'name': '카카오뱅크', 'code': '090', 'icon': 'assets/bank/bankName=카카오뱅크.png'},
    {'name': 'KB국민', 'code': '004', 'icon': 'assets/bank/bankName=KB국민.png'},
    {'name': '토스뱅크', 'code': '092', 'icon': 'assets/bank/bankName=토스뱅크.png'},
    {'name': '신한', 'code': '088', 'icon': 'assets/bank/bankName=신한.png'},
    {'name': 'IBK기업', 'code': '003', 'icon': 'assets/bank/bankName=IBK기업.png'},
    {'name': '하나', 'code': '081', 'icon': 'assets/bank/bankName=하나.png'},
    {'name': '새마을', 'code': '045', 'icon': 'assets/bank/bankName=새마을.png'},
    {'name': '부산', 'code': '032', 'icon': 'assets/bank/bankName=부산.png'},
    {'name': 'iM뱅크(대구)', 'code': '031', 'icon': 'assets/bank/bankName=대구.png'},
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
    {'name': 'KDB산업', 'code': '002', 'icon': 'assets/bank/bankName=KDB산업.png'},
    {'name': '산림조합', 'code': '064', 'icon': 'assets/bank/bankName=산림조합.png'},
    {
      'name': 'SBI저축은행',
      'code': '103',
      'icon': 'assets/bank/bankName=SBI저축.png'
    },
  ];

  static const List<Map<String, String>> securities = [
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
    {'name': '삼성증권', 'code': '240', 'icon': 'assets/securities/name=삼성증권.png'},
    {
      'name': 'KB증권',
      'code': '226',
      'icon': 'assets/securities/bankName=KB증권.png'
    },
    {'name': 'NH투자', 'code': '289', 'icon': 'assets/securities/name=농협.png'},
    {'name': '유안타', 'code': '209', 'icon': 'assets/securities/name=유안타증권.png'},
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
    {'name': 'DB금융투자', 'code': '279', 'icon': 'assets/securities/name=DB.png'},
    {
      'name': '우리투자증권',
      'code': '295',
      'icon': 'assets/securities/name=우리은행.png'
    },
    {'name': '신영', 'code': '291', 'icon': 'assets/securities/name=신영증권.png'},
    {'name': '다올투자증권', 'code': '227', 'icon': 'assets/securities/name=다올.png'},
    {
      'name': '케이프투자',
      'code': '292',
      'icon': 'assets/securities/name=케이프투자증권.png'
    },
    {'name': 'BNK투자', 'code': '224', 'icon': 'assets/securities/name=BNK.png'},
    {'name': '부국', 'code': '290', 'icon': 'assets/securities/name=부국증권.png'},
    {
      'name': '상상인증권',
      'code': '221',
      'icon': 'assets/securities/name=상상인증권.png'
    },
  ];
}
