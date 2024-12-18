import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/APIDioClient.dart';
import 'package:owner/common/api/request/store/store.dart';
// import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:owner/screen/Register/photo_upload_page.dart';
import 'package:path_provider/path_provider.dart';

// import '../../common/DatabaseService.dart';
import '../../common/Style/TextAsset.dart';
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
      {Key? key, required this.isRegister, required this.store});
  final bool isRegister;
  final Store? store;

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

  @override
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
      print("savedStoreImage ${savedStoreImage}");
    } else {
      savedStoreImage = null;
    }
  }

  Future<void> _getLogoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // title: const Text("Add Employee"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //가게 전호번호
                Text(
                  "매장 전화번호",
                  style: TextAssset.header2,
                ),
                SizedBox(height: 5),

                TextFormField(
                  controller: telePhoneController,
                  keyboardType: TextInputType.text,
                  decoration: inputDecoration.copyWith(hintText: "매장 전화번호 입력"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter telephone';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //매장 설명
                Text(
                  "매장 설명",
                  style: TextAssset.header2,
                ),
                TextFormField(
                  controller: introController,
                  keyboardType: TextInputType.text,
                  // maxLines: null,  //height 제한 X, 글자 수 에 따라 유동적으로 변함
                  maxLines: 6,
                  // maxLength: 200,
                  decoration: inputDecoration.copyWith(hintText: "매장 소개 입력"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter store description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

/*
                //주소
                _isRegister
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                              "주소",
                              style: TextAssset.header2,
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                      flex: 3,
                                      child: TextFormField(
                                        style: TextAssset.placeholder2,
                                        enabled: false,
                                        controller: addrController,
                                        keyboardType: TextInputType.text,
                                        decoration: inputDecoration.copyWith(
                                            hintText:
                                                "Enter your Store Address"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Address';
                                          }
                                          return null;
                                        },
                                      )),
                                  Container(
                                    width: 5,
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 151, 125, 253),
                                          minimumSize:
                                              const Size.fromHeight(50), // NEW
                                        ),
                                        onPressed: () async {
                                          _addressAPI();
                                        },
                                        child: Text('주소 검색'),
                                      ))
                                ]),
                            SizedBox(
                              height: 5,
                            ),
                            //상세주소
                            TextFormField(
                              controller: detailAddrController,
                              keyboardType: TextInputType.text,
                              decoration:
                                  inputDecoration.copyWith(hintText: "상세주소 입력"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter TelePhone';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                          ])
                    : SizedBox(height: 0),
*/
                SizedBox(height: 15),

                //매장 로고 업로드
                _isRegister
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                              "로고 사진",
                              style: TextAssset.header2,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () async {
                                      _getLogoImage();
                                    },
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image(
                                          image:
                                              AssetImage('assets/camera.jpeg'),
                                          width: 100,
                                          height: 100,
                                        ))),
                                SizedBox(
                                  width: 10,
                                ),
                                _logoImage != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image.file(
                                          File(_logoImage!.path),
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ))
                                    : Text(''),
                              ],
                            )
                          ])
                    : SizedBox(height: 0),

                //가게 대표 사진
                Text(
                  "가게 대표 사진",
                  style: TextAssset.header2,
                ),
                StoreImagesGridview(),

                SizedBox(height: 15),

                _isRegister
                    ? SizedBox()
                    : const Text("매장 이름/주소/사업자 등록번호 로고 수정은 문의로만 변경 가능합니다."),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 151, 125, 253),
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    // storePhoto
                    //     .asMap()
                    //     .forEach((index, value) => uploadImg(index, value));

                    setState(() {
                      // _profileImageURL = downloadURL;
                    });

                    if (_isRegister) {
                      registerStore();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SettingOpeningDatePage()));
                    } else {
                      if (_store != null) {
                        await updateStore()
                            .then((value) => Navigator.pop(context, _store));
                      }
                    }
                  },
                  child: Text('다음'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void registerStore() async {
    print("register store 호출");

    _store!.store_telephone = telePhoneController.text;
    _store!.store_photo_cnt = _storeImage.length;
    // _store!.store_address = addrController.text + detailAddrController.text;
    // _store!.store_photo = "photo";
    _store!.store_description = introController.text;

    await Api().client.registerStore(_store!).then((response) async {
      var storeId = response.store_id;
      var store_logo_url = response.store_logo_url;
      final store_photo_urls = response.store_photo_urls;
      final bankBook_put_url = response.bankBook_put_url;
      final business_put_url = response.business_put_url;

      print(storeId);
      print(store_logo_url);
      print(response.store_photo_urls[0]);

      uploadLogoImage(store_logo_url);
      uploadStoreImages(store_photo_urls);
      uploadBusinessImage(bankBook_put_url, business_put_url);

      print("등록성공" + storeId.toString());

      // ApiServiceImpl().uploadImage();
    }).onError((error, stackTrace) {
      DioError dioError = error as DioError;
      print("등록 실패" + dioError.message);
      if (dioError.response?.statusCode == 404) {
        // showToastMsg(Strings.error_network);
      } else {
        // showToastMsg("Error : [${dioError.message}]");
      }
      // result = false;
    });
  }

  Future<void> updateStore() async {
    _store?.store_telephone = telePhoneController.text;
    _store?.store_description = introController.text;
    if (isClickedPhotoUploadPage == false) {
      _store!.store_photo_cnt = -1;
    } else {
      _store!.store_photo_cnt = _storeImage.length;
    }

    await Api()
        .client
        .updateStore(_store!.store_id, _store!)
        .then((response) async {
      final store_photo_urls = response.store_photo_urls;

      print("su>> store_photo_urls: ${store_photo_urls}");
      _store?.store_photo_urls = response.store_photo_get_urls;

      if (isClickedPhotoUploadPage == true) {
        uploadStoreImages(store_photo_urls);
      }
    }).onError((error, stackTrace) {
      if (error is DioError) {
        print('DioError (fallback): $error.message}');
      } else {
        print('Unknown error: ${error.runtimeType} - $error');
      }
      // DioError dioError = error as DioError;
      // print("등록 실패" + dioError.message);
      // if (dioError.response?.statusCode == 404) {
      //   // showToastMsg(Strings.error_network);
      // } else {
      //   // showToastMsg("Error : [${dioError.message}]");
      // }
      // result = false;
    });
  }

  //매장 로고 업로드
  Future<void> uploadLogoImage(store_logo_url) async {
    try {
      http.Response response = await http.put(
        Uri.parse(store_logo_url),
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
  Future<void> uploadStoreImages(store_photo_urls) async {
    print("store_photo_urls, ${store_photo_urls}");
    print("su>>${_storeImage}");

    store_photo_urls.asMap().forEach((idx, store_photo_url) async {
      try {
        final response = await http.put(
          Uri.parse(store_photo_url),
          body: await _storeImage[idx].readAsBytes(),
        );
        await Future.delayed(Duration(seconds: 1));

        if (response.statusCode == 200) {
          // 이미지 업로드 성공
          print('store_photo uploaded successfully.');
        } else {
          // 이미지 업로드 실패
          print(
              'store_photo upload failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // 오류 처리
        print('Error uploading store_photo: $e');
      }
    });
  }

  //통장사본, 사업자등록증 업로드
  Future<void> uploadBusinessImage(bankBook_put_url, business_put_url) async {
    try {
      http.Response response = await http.put(
        Uri.parse(bankBook_put_url),
        body: await _store?.bank_book?.readAsBytes(),
        headers: {
          // 'Content-Type': 'image/jpeg', // 이미지 파일 형식에 맞게 변경
        },
      );

      http.Response response2 = await http.put(
        Uri.parse(business_put_url),
        body: await _store?.business_registration?.readAsBytes(),
        headers: {
          // 'Content-Type': 'image/jpeg', // 이미지 파일 형식에 맞게 변경
        },
      );

      if (response.statusCode == 200 && response2.statusCode == 200) {
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

  final inputDecoration = InputDecoration(
    hintStyle: TextAssset.placeholder,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      // borderSide: const BorderSide(
      //   color: Colors.redAccent,
      //   width: 2,
      // ),
    ),
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(21, 14, 21, 18),
    // contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    // contentPadding: EdgeInsets.symmetric(vertical: 5), // <-- SEE HERE
    // contentPadding:
    //     const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0)
  );

  final buttonStyle = ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0)),
      backgroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 154, 152, 152)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))));

  Widget StoreImagesGridview() {
    print("StoreImagesGridview:: 함수 진입");
    // print(savedStoreImage);

    print("su3>>${_storeImage}");

    List<Widget> itemWidgets = [];

    if (_storeImage == null) {
      _storeImage = [];
    }

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
              margin: EdgeInsets.fromLTRB(0, 2, 2, 0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.network(item,
                      width: 90, height: 90, fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                    return Image(
                        image: AssetImage('assets/logo.jpeg'),
                        width: 90,
                        height: 90,
                        fit: BoxFit.fill);
                  })));
        }).toList();
      }
    } else {
      //photo uplopad page에서 저장버튼을 누르고 back
      print("else 탐");

      itemWidgets = _storeImage.map((item) {
        return Container(
          width: 100,
          height: 100,
          margin: EdgeInsets.fromLTRB(0, 2, 2, 0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.file(
                File(item.path),
                width: 90,
                height: 90,
                fit: BoxFit.fill,
              )),
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
            margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
            child: GestureDetector(
              onTap: () async {
                print("Image clicked");
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoUploadePage(
                          savedImageUrl: savedStoreImage ?? [])),
                );

                setState(() {
                  _storeImage = result;
                  isClickedPhotoUploadPage = true;
                  print("su2>>${_storeImage}");
                  _store?.store_photo_cnt = _storeImage.length;

                  // savedStoreImage = result; // 수정 시 기존 저장된 이미지도 갱신
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: const Image(
                    image: AssetImage('assets/camera.jpeg'),
                    width: 100,
                    height: 100,
                  )),
            )));
    print("StoreImagesGridview:: return ");

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: itemWidgets),
    );
  }
}
