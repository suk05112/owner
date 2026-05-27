import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/APIDioClient.dart';
import 'package:owner/common/api/request/store/store.dart';
import 'package:owner/common/model/Account.dart';
import 'package:owner/common/model/Settlement.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/screen/Register/photo_upload_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:owner/screen/home.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/Style/TextAsset.dart';
import '../../common/widget/store_image.dart';
import 'operating_hours_setting_Page.dart';
import 'SettingOpeningDatePage.dart';
import '../Store/cafe_detail_page.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;

import 'package:kpostal/kpostal.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:async';

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage(
      {super.key, required this.isRegister, required this.store, this.account});
  final bool isRegister;
  final Store? store;
  final Account? account;

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  // TextEditingController nameController = TextEditingController();
  // TextEditingController addrController = TextEditingController();
  // TextEditingController detailAddrController = TextEditingController();
  TextEditingController telePhoneController = TextEditingController();
  TextEditingController introController = TextEditingController();

  late bool _isRegister;
  late Store? _store;
  final _formKey = GlobalKey<FormState>();
  // var storePhoto = [];
  File? _logoImage;
  List<File> _storeImage = []; //갤러리에서 가져온 매장 사진
  List<String>? savedStoreImage; //기존 저장된 매장 사진
  File? _imageFile;
  bool isClickedPhotoUploadPage = false;
  bool _isLoading = false;

  @override
  @override
  void dispose() {
    telePhoneController.dispose();
    introController.dispose();
    super.dispose();
  }

  void initState() {
    _isRegister = widget.isRegister;
    if (widget.store != null) {
      _store = widget.store;
    } else {
      _store = Store(owner_id: 1);
    }

    //매장 정보 수정 화면일 경우
    if (_isRegister == false) {
      telePhoneController.text =
          _store?.store_telephone == null ? "" : "${_store?.store_telephone}";
      // addrController.text =
      // _store?.store_address == null ? "" : "${_store?.store_address}";
      introController.text = _store?.store_description == null
          ? ""
          : "${_store?.store_description}";
      savedStoreImage = _store?.store_photo_urls;
      print("savedStoreImage $savedStoreImage");
    } else {
      savedStoreImage = null;
    }
  }

  Future<void> _getLogoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);

    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  @override
  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF101010),
  );

  static const _fieldDecoration = InputDecoration(
    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF808080)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE6E6E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFF27213)),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: _isRegister ? "매장정보 입력하기(3/3)" : "매장 수정하기",
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 매장 전화번호
                      const Text("매장 전화번호", style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: telePhoneController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration.copyWith(hintText: "매장 전화번호 입력"),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '매장 전화번호를 입력해주세요.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 매장 설명
                      const Text("매장 설명", style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: introController,
                        keyboardType: TextInputType.text,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: _fieldDecoration.copyWith(hintText: "매장 소개 입력(200자 이내)"),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '매장 소개를 입력해주세요.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 로고 사진 (등록 모드 전용)
                      if (_isRegister) ...[
                        const Text("로고 사진", style: _labelStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _getLogoImage,
                              child: _logoImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _logoImage!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    )
                                  : _photoAddBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 가게 대표 사진
                      const Text("가게 대표 사진", style: _labelStyle),
                      const SizedBox(height: 8),
                      StoreImagesGridview(),

                      if (!_isRegister) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "매장 이름/주소/사업자 등록번호/로고 수정은 문의로만 변경 가능합니다.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(
                          color: const Color(0xFFFE7831),
                          backgroundColor: const Color(0x33FE7831),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF27213),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_isRegister) {
                                    if (_logoImage == null) {
                                      showToast("매장 로고를 업로드 해주세요.");
                                      return;
                                    }
                                    if (_storeImage.isEmpty) {
                                      showToast("매장 사진을 최소 1장 이상 업로드 해주세요.");
                                      return;
                                    }
                                    await registerStore();
                                  } else {
                                    if (_store != null) {
                                      await updateStore();
                                    }
                                  }
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegister ? '다음' : '저장',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageErrorBox() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFF7F7F7),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 32, color: Color(0xFFB0B0B0)),
          SizedBox(height: 4),
          Text(
            "불러오기 실패",
            style: TextStyle(fontSize: 10, color: Color(0xFFB0B0B0)),
          ),
        ],
      ),
    );
  }

  Widget _photoAddBox() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFF808080)),
          SizedBox(height: 8),
          Text(
            "사진 추가",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF808080)),
          ),
        ],
      ),
    );
  }

  void showToast(msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _saveAssetImageAsFile() async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/profile.png';

    final ByteData imageData = await rootBundle.load('assets/logo.jpeg');
    final bytes = imageData.buffer.asUint8List();

    await File(imagePath).writeAsBytes(bytes);

    setState(() {
      _imageFile = File(imagePath);
    });
  }

  Future<void> registerStore() async {
    print("register store 호출");

    setState(() => _isLoading = true);

    _store!.store_telephone = telePhoneController.text;
    _store!.image_count = _storeImage.length;
    _store!.store_description = introController.text;

    try {
      final response = await Api().client.registerStore(_store!);
      var storeId = response.store_id;
      var storeLogoUrl = response.store_logo_url;
      final storePhotoPutUrls =
          response.store_photos.map((p) => p.put_url).toList();
      final bankbookPutUrl = response.bankBook_put_url;
      final businessPutUrl = response.business_put_url;

      uploadLogoImage(storeLogoUrl);
      uploadStoreImages(storePhotoPutUrls);
      if (businessPutUrl != null) {
        uploadBusinessImage(bankbookPutUrl, businessPutUrl);
      }

      if (widget.account != null) {
        print("Account ${widget.account}");
        try {
          await Api().client.registerAccount(storeId, widget.account!);
          print("계좌 등록성공$storeId");
        } catch (e) {
          print("계좌 등록 실패 $e");
        }
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
    } catch (error) {
      print('매장 등록 실패: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('매장 등록에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> updateStore() async {
    setState(() => _isLoading = true);

    _store!.store_telephone = telePhoneController.text;
    _store!.store_description = introController.text;
    _store!.image_count = isClickedPhotoUploadPage ? _storeImage.length : null;

    try {
      final response =
          await Api().client.updateStore(_store!.store_id, _store!);
      final storePhotoPutUrls =
          response.store_photos.map((p) => p.put_url).toList();

      if (isClickedPhotoUploadPage) {
        await uploadStoreImages(storePhotoPutUrls);
      }

      final updatedStore = Store.fromJson(_store!.toJson())
        ..store_telephone = telePhoneController.text
        ..store_description = introController.text
        ..store_photo_urls = response.store_photo_get_urls;

      if (mounted) Navigator.pop(context, updatedStore);
    } catch (error) {
      if (error is DioException) {
        print('DioError: ${error.message}');
      } else {
        print('Unknown error: ${error.runtimeType} - $error');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('매장 정보 저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //매장 로고 업로드
  Future<void> uploadLogoImage(storeLogoUrl) async {
    try {
      http.Response response = await http.put(
        Uri.parse(storeLogoUrl),
        body: await _logoImage?.readAsBytes(),
        headers: {
          // 'Content-Type': 'image/jpeg', // 이미지 파일 형식에 맞게 변경
        },
      );

      if (response.statusCode == 200) {
        // 이미지 업로드 성공
        print('Image uploaded successfully.');
      } else {
        // 이미지 업로드 실패
        print('Image upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //매장 사진 업로드
  Future<void> uploadStoreImages(List<dynamic> storePhotoUrls) async {
    final entries = storePhotoUrls.asMap().entries.toList();
    await Future.wait(entries.map((e) async {
      try {
        final response = await http.put(
          Uri.parse(e.value as String),
          body: await _storeImage[e.key].readAsBytes(),
        );
        if (response.statusCode != 200) {
          print('store_photo upload failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading store_photo: $e');
      }
    }));
  }

  //통장사본, 사업자등록증 업로드
  Future<void> uploadBusinessImage(bankbookPutUrl, businessPutUrl) async {
    try {
      http.Response response = await http.put(
        Uri.parse(bankbookPutUrl),
        body: await _store?.bank_book?.readAsBytes(),
      );

      http.Response response2 = await http.put(
        Uri.parse(businessPutUrl),
        body: await _store?.business_registration?.readAsBytes(),
      );

      if (response.statusCode == 200 && response2.statusCode == 200) {
        // 이미지 업로드 성공
        print('BusinessImage upload successfully.');
      } else {
        // 이미지 업로드 실패
        print(
            'bankBook:: Image upload failed. Status code: ${response.statusCode}');
        print(
            'business:: Image upload failed. Status code: ${response2.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  final inputDecoration = InputDecoration(
    hintStyle: TextAssset.placeholder,
    border:
        UnderlineInputBorder(borderSide: const BorderSide(style: BorderStyle.none)
            // borderRadius: BorderRadius.circular(8.0),

            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(5.0),
            // borderSide: const BorderSide(
            //   color: Colors.redAccent,
            //   width: 2,
            // ),
            ),
    isDense: true,
    contentPadding: const EdgeInsets.fromLTRB(0, 10, 21, 10),
    // contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    // contentPadding: EdgeInsets.symmetric(vertical: 5), // <-- SEE HERE
    // contentPadding:
    //     const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0)
  );

  final buttonStyle = ButtonStyle(
      foregroundColor:
          WidgetStateProperty.all<Color>(const Color.fromARGB(255, 0, 0, 0)),
      backgroundColor:
          WidgetStateProperty.all<Color>(const Color.fromARGB(255, 154, 152, 152)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))));

  Widget StoreImagesGridview() {
    print("StoreImagesGridview:: 함수 진입");
    // print(savedStoreImage);

    print("su3>>$_storeImage");

    List<Widget> itemWidgets = [];

    _storeImage ??= [];

    // if (savedStoreImage == null || savedStoreImage!.isEmpty) {
    //photo uplopad page에서 저장버튼을 누르지 않고 back한경우 or 처음 화면 진입했을 때
    if (_storeImage.isEmpty) {
      print("if 탐");
      //기존 저장된 매장 사진 없을 경우(매장 처음 등록)
      if (savedStoreImage == null || savedStoreImage!.isEmpty) {
        itemWidgets = [];
        // itemWidgets = _storeImage.map((item) {
        //   return Container(
        //     width: 100,
        //     height: 100,
        //     margin: EdgeInsets.fromLTRB(0, 2, 2, 0),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(5.0),
        //       child: Image.file(
        //         File(item.path),
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //   );
        // }).toList();
      } else {
        //기존 저장된 매장 사진 있을 경우(매장 수정)
        itemWidgets = savedStoreImage!.map((item) {
          return Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.fromLTRB(0, 2, 2, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: StoreImage(
                url: item,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorWidget: _imageErrorBox(),
              ),
            ),
          );
        }).toList();
      }
    } else {
      //photo uplopad page에서 저장버튼을 누르고 back
      itemWidgets = _storeImage.map((item) {
        return Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.fromLTRB(0, 2, 2, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.file(
              File(item.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageErrorBox(),
            ),
          ),
        );
      }).toList();
    }

    print("StoreImagesGridview:: itemWidgets 전");
    //이미지 편집화면으로 이동하는 버튼 추가
    itemWidgets.insert(
        0,
        Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.fromLTRB(0, 0, 2, 0),
            child: GestureDetector(
              onTap: () async {
                print("Image clicked");
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoUploadePage(
                            savedImageUrl: savedStoreImage ?? [],
                            storeImage: _storeImage,
                          )),
                );

                if (result == null) return;
                setState(() {
                  if (result.isEmpty) {
                    // _storeImage = savedStoreImage;
                  } else {
                    _storeImage = result;
                    isClickedPhotoUploadPage = true;
                    _store?.image_count = _storeImage.length;
                  }
                });
              },
              child: _photoAddBox(),
            )));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: itemWidgets),
    );
  }
}
