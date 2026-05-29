import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/common/utils/address_parser.dart';
import 'package:owner/screen/Home.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class AccountRegisterPage extends StatefulWidget {
  const AccountRegisterPage({
    Key? key,
    required this.store,
    this.logoImage,
    this.storeImages,
  }) : super(key: key);
  final Store store;
  final File? logoImage;
  final List<File>? storeImages;

  @override
  State<AccountRegisterPage> createState() => _AccountRegisterPageState();
}

class _AccountRegisterPageState extends State<AccountRegisterPage> {
  late Store _store;
  String selectedBank = "은행선택";
  late Account account;
  File? _bankBook;
  String? uploadedBankBookFilename;
  final picker = ImagePicker();
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController accountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameKey = GlobalKey();
  final _bankKey = GlobalKey();
  final _accountKey = GlobalKey();
  final _bankBookKey = GlobalKey();
  final _nameFocus = FocusNode();
  final _accountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    account = Account();
  }

  @override
  void dispose() {
    nameController.dispose();
    accountController.dispose();
    _scrollController.dispose();
    _nameFocus.dispose();
    _accountFocus.dispose();
    super.dispose();
  }

  final inputDecoration = InputDecoration(
    hintStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF808080),
      fontFamily: 'Inter',
    ),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101010),
        fontFamily: 'Inter',
      ),
    );
  }

  void showToast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF333333),
      ),
    );
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final target = (_scrollController.offset + offset.dy - 100).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const CommonAppBar(title: "계좌 정보 입력(2/2)"),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 예금주
                      SizedBox(key: _nameKey, height: 0),
                      _buildLabel("예금주"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        focusNode: _nameFocus,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration.copyWith(
                          hintText: "예금주명을 입력해주세요",
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101010),
                          fontFamily: 'Inter',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '예금주명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 은행선택
                      SizedBox(key: _bankKey, height: 0),
                      _buildLabel("은행선택"),
                      const SizedBox(height: 8),
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
                            },
                          ).then((value) {
                            if (value != null) {
                              print("선택된 은행 ${value['name']}");
                              setState(() {
                                selectedBank = value['name']!;
                                account = Account(
                                  bank: value['name'],
                                  code: value['code'],
                                );
                              });
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE6E6E6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                selectedBank,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: selectedBank == "은행선택"
                                      ? const Color(0xFF808080)
                                      : const Color(0xFF101010),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF808080),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 계좌번호
                      SizedBox(key: _accountKey, height: 0),
                      _buildLabel("계좌번호"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: accountController,
                        focusNode: _accountFocus,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
                          hintText: "계좌번호를 입력해주세요",
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101010),
                          fontFamily: 'Inter',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '계좌번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 통장 사본
                      SizedBox(key: _bankBookKey, height: 0),
                      _buildLabel("통장 사본"),
                      const SizedBox(height: 8),
                      const Text(
                        "사업자 등록증에 있는 사업자와 동일해야합니다.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF808080),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final pickedImage = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedImage != null) {
                            setState(() {
                              _bankBook = File(pickedImage.path);
                              uploadedBankBookFilename = pickedImage.name;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE6E6E6),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add,
                                    color: Color(0xFF808080), size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    uploadedBankBookFilename ?? "파일 추가",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF808080),
                                      fontFamily: 'Inter',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF27213),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) {
                            if (nameController.text.isEmpty) {
                              _scrollToKey(_nameKey);
                              _nameFocus.requestFocus();
                            } else if (accountController.text.isEmpty) {
                              _scrollToKey(_accountKey);
                              _accountFocus.requestFocus();
                            }
                            return;
                          }
                          if (selectedBank == '은행선택') {
                            showToast("은행을 선택해주세요");
                            _scrollToKey(_bankKey);
                            return;
                          }
                          if (_bankBook == null) {
                            showToast("통장 사본을 업로드해주세요.");
                            _scrollToKey(_bankBookKey);
                            return;
                          }
                          account.account = accountController.text;
                          account.name = nameController.text;
                          _store.bank_book = _bankBook;
                          registerStore();
                        },
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            '완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bankList() {
    List<Map<String, String>> bankData = [
      {
        'name': 'NH농협은행',
        'code': '011',
        'icon': 'assets/bank/bankName=NH농협.png'
      },
      {'name': '지역농축협', 'code': '012', 'icon': 'assets/bank/bankName=NH농협.png'},
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
                  physics: const ScrollPhysics(),
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
                  physics: const ScrollPhysics(),
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

  void registerStore() async {
    print("register store 호출");

    setState(() {
      _isLoading = true;
    });

    try {
      _store.image_count = widget.storeImages?.length ?? 0;

      // region_code와 district_code가 null인 경우 기본값 설정
      if (_store.region_code == null || _store.district_code == null) {
        print("경고: region_code 또는 district_code가 null입니다. 주소를 다시 확인해주세요.");
        // 주소가 설정되어 있다면 다시 파싱 시도
        if (_store.store_address.isNotEmpty) {
          final codes = parseAddressCodes(_store.store_address);
          _store.district_code = codes["district_code"];
          _store.region_code = codes["region_code"];
          print(
              "재파싱 결과 - district_code: ${_store.district_code}, region_code: ${_store.region_code}");
        }
      }

      // region_code와 district_code가 여전히 null이면 빈 문자열로 설정 (서버에서 null 처리 가능하도록)
      _store.region_code ??= "";
      _store.district_code ??= "";

      // 매장 등록 API 호출
      final response = await Api().client.registerStore(_store);
      var storeId = response.store_id;
      final storeLogoPutUrl = response.store_logo_put_url;
      final storePhotoUrls = response.store_photos.map((p) => p.put_url).whereType<String>().toList();
      final bankbookPutUrl = response.bankBook_put_url;
      final businessPutUrl = response.business_put_url;

      // 이미지 업로드
      try {
        if (widget.logoImage != null && storeLogoPutUrl != null) {
          await uploadLogoImage(storeLogoPutUrl);
        }
        if (widget.storeImages != null && widget.storeImages!.isNotEmpty) {
          await uploadStoreImages(storePhotoUrls);
        }
        if (businessPutUrl != null) {
          await uploadBusinessImage(bankbookPutUrl, businessPutUrl);
        }
        print('All images uploaded successfully.');
      } catch (e) {
        print('Error during image upload: $e');
        // 이미지 업로드 실패해도 계속 진행 (선택적)
        // throw e; // 또는 에러를 다시 throw하여 전체 프로세스 중단
      }

      // 계좌 등록 API 호출
      try {
        await Api().client.registerAccount(storeId, account);
        print("계좌 등록성공 $storeId");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showToast("매장 등록이 완료되었습니다.");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false,
          );
        }
      } on DioException catch (e) {
        print("계좌 등록 실패: ${e.message}");
        String errorMessage = "계좌 등록에 실패했습니다.";
        if (e.response != null) {
          errorMessage = "계좌 등록에 실패했습니다. (${e.response?.statusCode})";
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showToast(errorMessage);
        }
      } catch (e) {
        print("계좌 등록 실패: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showToast("계좌 등록에 실패했습니다. 다시 시도해주세요.");
        }
      }
    } on DioException catch (e) {
      print("매장 등록 실패: ${e.message}");
      String errorMessage = "매장 등록에 실패했습니다.";
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 500) {
          errorMessage = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
        } else {
          errorMessage = "매장 등록에 실패했습니다. ($statusCode)";
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast(errorMessage);
      }
    } catch (e) {
      print("매장 등록 실패: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast("매장 등록에 실패했습니다. 다시 시도해주세요.");
      }
    }
  }

  // 매장 로고 업로드
  Future<void> uploadLogoImage(String storeLogoUrl) async {
    try {
      if (widget.logoImage == null) {
        print('Logo image is null, skipping upload.');
        return;
      }

      print('Uploading logo image to: $storeLogoUrl');
      final imageBytes = await widget.logoImage!.readAsBytes();
      print('Logo image size: ${imageBytes.length} bytes');

      http.Response response = await http.put(
        Uri.parse(storeLogoUrl),
        body: imageBytes,
        headers: {
          'Content-Type': 'image/png',
        },
      );

      if (response.statusCode == 200) {
        print('Logo image uploaded successfully.');
      } else {
        print(
            'Logo image upload failed. Status code: ${response.statusCode}, Response: ${response.body}');
        throw Exception(
            'Logo image upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading logo image: $e');
      rethrow;
    }
  }

  // 매장 사진 업로드
  Future<void> uploadStoreImages(List<String> storePhotoUrls) async {
    if (widget.storeImages == null || widget.storeImages!.isEmpty) {
      print('Store images are null or empty, skipping upload.');
      return;
    }

    print('Uploading ${widget.storeImages!.length} store images...');
    for (int idx = 0;
        idx < widget.storeImages!.length && idx < storePhotoUrls.length;
        idx++) {
      try {
        print('Uploading store photo $idx to: ${storePhotoUrls[idx]}');
        final imageBytes = await widget.storeImages![idx].readAsBytes();
        print('Store photo $idx size: ${imageBytes.length} bytes');

        final response = await http.put(
          Uri.parse(storePhotoUrls[idx]),
          body: imageBytes,
          headers: {
            'Content-Type': 'image/png',
          },
        );
        await Future.delayed(const Duration(milliseconds: 500));

        if (response.statusCode == 200) {
          print('Store photo $idx uploaded successfully.');
        } else {
          print(
              'Store photo $idx upload failed. Status code: ${response.statusCode}, Response: ${response.body}');
          throw Exception(
              'Store photo $idx upload failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading store photo $idx: $e');
        rethrow;
      }
    }
  }

  // 통장사본, 사업자등록증 업로드
  Future<void> uploadBusinessImage(
      String bankbookPutUrl, String businessPutUrl) async {
    try {
      http.Response? response1;
      if (_store.bank_book != null) {
        print('Uploading bank book to: $bankbookPutUrl');
        final bankBookBytes = await _store.bank_book!.readAsBytes();
        print('Bank book size: ${bankBookBytes.length} bytes');

        response1 = await http.put(
          Uri.parse(bankbookPutUrl),
          body: bankBookBytes,
          headers: {
            'Content-Type': 'image/png',
          },
        );

        if (response1.statusCode != 200) {
          print(
              'Bank book upload failed. Status code: ${response1.statusCode}, Response: ${response1.body}');
          throw Exception(
              'Bank book upload failed with status code: ${response1.statusCode}');
        }
        print('Bank book uploaded successfully.');
      } else {
        print('Bank book is null, skipping upload.');
      }

      http.Response? response2;
      if (_store.business_registration != null) {
        print('Uploading business registration to: $businessPutUrl');
        final businessBytes = await _store.business_registration!.readAsBytes();
        print('Business registration size: ${businessBytes.length} bytes');

        response2 = await http.put(
          Uri.parse(businessPutUrl),
          body: businessBytes,
          headers: {
            'Content-Type': 'image/png',
          },
        );

        if (response2.statusCode != 200) {
          print(
              'Business registration upload failed. Status code: ${response2.statusCode}, Response: ${response2.body}');
          throw Exception(
              'Business registration upload failed with status code: ${response2.statusCode}');
        }
        print('Business registration uploaded successfully.');
      } else {
        print('Business registration is null, skipping upload.');
      }

      print('Business images upload completed.');
    } catch (e) {
      print('Error uploading business images: $e');
      rethrow;
    }
  }
}
