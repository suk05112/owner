import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/screen/Register/account_register_page.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../common/api/request/store/store.dart';
import '../../common/widget/common_app_bar.dart';
import '../../common/utils/address_parser.dart';

class DocumentInputPage extends StatefulWidget {
  const DocumentInputPage({Key? key}) : super(key: key);

  @override
  State<DocumentInputPage> createState() => _DocumentInputPageState();
}

class _DocumentInputPageState extends State<DocumentInputPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController storenNameController = TextEditingController();
  TextEditingController addrController = TextEditingController();
  TextEditingController detailAddrController = TextEditingController();
  TextEditingController telePhoneController = TextEditingController();
  TextEditingController introController = TextEditingController();
  TextEditingController businessNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _nameKey = GlobalKey();
  final _storeNameKey = GlobalKey();
  final _addrKey = GlobalKey();
  final _phoneKey = GlobalKey();
  final _businessNumberKey = GlobalKey();
  final _businessRegKey = GlobalKey();
  final _storeImagesKey = GlobalKey();
  final _privacyKey = GlobalKey();

  final _nameFocus = FocusNode();
  final _storeNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _businessNumberFocus = FocusNode();

  late Store _store;
  bool _isChecked = false;
  File? _logoImage;
  final List<File> _storeImages = [];
  File? _businessRegistration;
  String? uploadedBusinessRegistrationFilename;

  final picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    User? user = Provider.of<UserProvider>(context, listen: false).user;
    _store = Store(owner_id: user?.owner_id ?? 0);
  }

  @override
  void dispose() {
    nameController.dispose();
    storenNameController.dispose();
    addrController.dispose();
    detailAddrController.dispose();
    telePhoneController.dispose();
    introController.dispose();
    businessNumberController.dispose();
    _scrollController.dispose();
    _nameFocus.dispose();
    _storeNameFocus.dispose();
    _phoneFocus.dispose();
    _businessNumberFocus.dispose();
    super.dispose();
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

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> pickedImages = await picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        setState(() {
          int remainingSlots = 10 - _storeImages.length;
          if (remainingSlots > 0) {
            int imagesToAdd = pickedImages.length > remainingSlots
                ? remainingSlots
                : pickedImages.length;
            for (int i = 0; i < imagesToAdd; i++) {
              _storeImages.add(File(pickedImages[i].path));
            }
            if (pickedImages.length > remainingSlots) {
              showToast("최대 10장까지 업로드 가능합니다.");
            }
          } else {
            showToast("최대 10장까지 업로드 가능합니다.");
          }
        });
      }
    } catch (e) {
      // iOS 등에서 pickMultiImage가 지원되지 않는 경우
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null && _storeImages.length < 10) {
        setState(() {
          _storeImages.add(File(pickedImage.path));
        });
      }
    }
  }

  Future<void> _pickLogoImage() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickBusinessRegistration() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _businessRegistration = File(pickedImage.path);
        uploadedBusinessRegistrationFilename = pickedImage.name;
        _store.business_registration = _businessRegistration;
      });
    }
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

  _addressAPI() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          kakaoKey: '16dd251b86287783606ea600a98c7131',
          useLocalServer: false,
          callback: (Kpostal result) {
            setState(() {
              final address = result.address;
              final buildingName = result.buildingName;
              addrController.text = "$address $buildingName";
              if (result.latitude != null) {
                _store.store_lat = result.latitude as double;
              }
              if (result.longitude != null) {
                _store.store_lng = result.longitude as double;
              }
              
              // 주소에서 district_code와 region_code 추출
              final addressString = result.address;
              final codes = parseAddressCodes(addressString);
              _store.district_code = codes["district_code"];
              _store.region_code = codes["region_code"];
              
              print("주소: $addressString");
              print("district_code: ${_store.district_code}, region_code: ${_store.region_code}");
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CommonAppBar(title: "매장 정보 입력(1/2)"),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 대표자명
                      SizedBox(key: _nameKey, child: _buildLabel("대표자명")),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        focusNode: _nameFocus,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration.copyWith(hintText: "대표자명을 입력해주세요"),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '대표자명을 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 매장명
                      SizedBox(key: _storeNameKey, child: _buildLabel("매장명")),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: storenNameController,
                        focusNode: _storeNameFocus,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration.copyWith(hintText: "매장명을 입력해주세요"),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '매장명을 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 주소
                      SizedBox(key: _addrKey, child: _buildLabel("주소")),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: addrController,
                              enabled: false,
                              decoration: inputDecoration.copyWith(
                                hintText: "주소를 검색해주세요",
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                                ),
                              ),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF808080), fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return '주소를 검색해주세요';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 91,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _addressAPI,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF27213),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(91, 44),
                              ),
                              child: const Text(
                                '주소 검색',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: detailAddrController,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration.copyWith(hintText: "상세주소를 입력해주세요"),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 24),

                      // 매장 전화번호
                      SizedBox(key: _phoneKey, child: _buildLabel("매장 전화번호")),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: telePhoneController,
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.phone,
                        decoration: inputDecoration.copyWith(hintText: "전화번호를 입력해주세요"),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '전화번호를 입력해주세요';
                          final phoneRegex = RegExp(r'^0\d{1,2}-?\d{3,4}-?\d{4}$');
                          if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
                            return '올바른 전화번호 형식을 입력해주세요 (예: 0507-1234-5678)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 매장 설명
                      _buildLabel("매장 설명"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: introController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: inputDecoration.copyWith(
                          hintText: "매장 설명을 입력해주세요",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 24),

                      // 로고 이미지
                      _buildLabel("로고 이미지"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickLogoImage,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                          ),
                          child: _logoImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(_logoImage!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Color(0xFF808080), size: 24),
                                    SizedBox(height: 4),
                                    Text("추가", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF808080), fontFamily: 'Inter')),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 사업자 등록번호
                      SizedBox(key: _businessNumberKey, child: _buildLabel("사업자 등록번호")),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: businessNumberController,
                        focusNode: _businessNumberFocus,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(hintText: "사업자 등록번호를 입력해주세요"),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF101010), fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '사업자 등록번호를 입력해주세요';
                          final digits = value.replaceAll('-', '');
                          if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
                            return '사업자 등록번호는 10자리 숫자입니다 (예: 000-00-00000)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 사업자 등록증
                      SizedBox(key: _businessRegKey, child: _buildLabel("사업자 등록증")),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickBusinessRegistration,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, color: Color(0xFF808080), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  uploadedBusinessRegistrationFilename ?? "파일 추가",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF808080), fontFamily: 'Inter'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 매장 사진
                      SizedBox(key: _storeImagesKey, child: _buildLabel("매장 사진")),
                      const SizedBox(height: 8),
                      _buildStoreImagesGrid(),
                      const SizedBox(height: 24),

                      // 개인정보 수집 및 이용 동의
                      SizedBox(
                        key: _privacyKey,
                        child: _PrivacyConsentWidget(
                          isChecked: _isChecked,
                          onChanged: (value) {
                            setState(() => _isChecked = value ?? false);
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // 하단 버튼
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27213),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        if (nameController.text.isEmpty) {
                          _scrollToKey(_nameKey);
                          _nameFocus.requestFocus();
                        } else if (storenNameController.text.isEmpty) {
                          _scrollToKey(_storeNameKey);
                          _storeNameFocus.requestFocus();
                        } else if (addrController.text.isEmpty) {
                          _scrollToKey(_addrKey);
                        } else if (telePhoneController.text.isEmpty) {
                          _scrollToKey(_phoneKey);
                          _phoneFocus.requestFocus();
                        } else if (businessNumberController.text.isEmpty) {
                          _scrollToKey(_businessNumberKey);
                          _businessNumberFocus.requestFocus();
                        } else {
                          final phoneOk = RegExp(r'^0\d{8,9}$')
                              .hasMatch(telePhoneController.text.replaceAll('-', ''));
                          if (phoneOk) {
                            _scrollToKey(_businessNumberKey);
                            _businessNumberFocus.requestFocus();
                          } else {
                            _scrollToKey(_phoneKey);
                            _phoneFocus.requestFocus();
                          }
                        }
                        return;
                      }

                      if (_businessRegistration == null) {
                        showToast("사업자 등록증을 업로드해주세요.");
                        _scrollToKey(_businessRegKey);
                        return;
                      }
                      if (_storeImages.isEmpty) {
                        showToast("매장 사진을 최소 1장 이상 업로드해주세요.");
                        _scrollToKey(_storeImagesKey);
                        return;
                      }
                      if (!_isChecked) {
                        showToast("개인정보 수집 및 이용에 동의해주세요.");
                        _scrollToKey(_privacyKey);
                        return;
                      }

                      _store.store_name = storenNameController.text;
                      _store.store_address = "${addrController.text} ${detailAddrController.text}";
                      _store.store_telephone = telePhoneController.text;
                      _store.store_description = introController.text;
                      _store.business_registration = _businessRegistration;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountRegisterPage(
                            store: _store,
                            logoImage: _logoImage,
                            storeImages: _storeImages,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '다음',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreImagesGrid() {
    List<Widget> itemWidgets = [];

    // 사진 추가 버튼 (항상 첫 번째에 위치)
    itemWidgets.add(
      GestureDetector(
        onTap: _storeImages.length < 10 ? _pickMultipleImages : null,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: _storeImages.length < 10
                ? const Color(0xFFF7F7F7)
                : const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE6E6E6),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: _storeImages.length < 10
                    ? const Color(0xFF808080)
                    : const Color(0xFFB0B0B0),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                "추가",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _storeImages.length < 10
                      ? const Color(0xFF808080)
                      : const Color(0xFFB0B0B0),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 업로드된 이미지들
    for (int i = 0; i < _storeImages.length; i++) {
      itemWidgets.add(
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE6E6E6),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _storeImages[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _storeImages.removeAt(i);
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: itemWidgets
                .map((widget) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "최대 10장까지 업로드 가능합니다.",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _PrivacyConsentWidget extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const _PrivacyConsentWidget({
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<_PrivacyConsentWidget> createState() => _PrivacyConsentWidgetState();
}

class _PrivacyConsentWidgetState extends State<_PrivacyConsentWidget> {
  bool _isExpanded = false;

  static const _privacyText = '''개인정보 수집 및 이용 동의

기프넛은 서비스 제공 및 원활한 운영을 위해 아래와 같이 개인정보를 수집·이용합니다.

1. 수집 항목
• 필수 항목: 사업자명, 대표자명, 휴대전화번호, 이메일, 사업자등록번호, 정산 계좌정보
• 선택 항목: 매장 사진, 메뉴 사진, 위치 정보

2. 수집 및 이용 목적
• 회원가입 및 본인 확인
• 가맹점 관리 및 서비스 제공
• 주문, 정산 및 고객 문의 대응
• 공지사항 및 중요 안내 전달
• 서비스 개선 및 부정 이용 방지

3. 보유 및 이용 기간
회사는 개인정보 수집 및 이용 목적이 달성된 후 지체 없이 파기합니다.
단, 관계 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 안전하게 보관합니다.

4. 동의 거부 권리 및 불이익 안내
이용자는 개인정보 수집 및 이용에 대한 동의를 거부할 권리가 있습니다.
다만, 필수 항목에 대한 동의를 거부할 경우 서비스 이용이 제한될 수 있습니다.''';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.isChecked,
              onChanged: widget.onChanged,
              activeColor: const Color(0xFFF27213),
              checkColor: Colors.white,
              side: const BorderSide(color: Color(0xFFB0B0B0), width: 1.5),
            ),
            const Expanded(
              child: Text(
                "개인정보 수집 및 이용에 동의합니다.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF101010),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFF808080),
                size: 20,
              ),
            ),
          ],
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: const Text(
              _privacyText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF808080),
                fontFamily: 'Inter',
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }
}
