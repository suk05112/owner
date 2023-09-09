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
  // DatabaseService service = DatabaseService();

  TextEditingController nameController = TextEditingController();
  TextEditingController addrController = TextEditingController();
  TextEditingController detailAddrController = TextEditingController();
  TextEditingController telePhoneController = TextEditingController();
  TextEditingController introController = TextEditingController();

  late bool _isRegister;
  late Store? _store;
  final _formKey = GlobalKey<FormState>();
  // var storePhoto = [];
  File? _logoImage;
  List<File> _storeImage = [];
  File? _imageFile;

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
      addrController.text =
          _store?.store_address == null ? "" : "${_store?.store_address}";
      introController.text = _store?.store_description == null
          ? ""
          : "${_store?.store_description}";
    }
    if (_isRegister == false) {
      // getImge();
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
                //매장 이름
                Text(
                  "매장 이름",
                  style: TextAssset.header2,
                ),
                SizedBox(height: 5),

                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: inputDecoration.copyWith(hintText: "매장 이름 입력"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),

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
                    registerStore();
                    // storePhoto
                    //     .asMap()
                    //     .forEach((index, value) => uploadImg(index, value));

                    setState(() {
                      // _profileImageURL = downloadURL;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SettingOpeningDatePage()));
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

    // Store store = Store(
    //     owner_id: 1,
    //     store_logo: "new logo",
    //     store_name: nameController.text,
    //     store_telephone: telePhoneController.text,
    //     store_photo_cnt: 5,
    //     store_photo: "photo",
    //     store_address: "Adr",
    //     store_lat: 1,
    //     store_lng: 1,
    //     business_registration: "busi",
    //     store_description: introController.text);

    _store!.store_name = nameController.text;
    _store!.store_telephone = telePhoneController.text;
    _store!.store_photo_cnt = _storeImage.length;
    _store!.store_address = addrController.text + detailAddrController.text;
    // _store!.store_photo = "photo";
    _store!.business_registration = "busi";
    _store!.store_description = introController.text;

    await Api().client.registerStore(_store!).then((response) async {
      var storeId = response.store_id;
      var store_logo_url = response.store_logo_url;
      final store_photo_urls = response.store_photo_urls;

      print(storeId);
      print(store_logo_url);
      print(response.store_photo_urls[0]);

      uploadLogoImage(store_logo_url);
      uploadStoreImages(store_photo_urls);

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
    store_photo_urls.asMap().forEach((idx, store_photo_url) async {
      try {
        final response = await http.put(
          Uri.parse(store_photo_url),
          body: await _storeImage[idx].readAsBytes(),
        );

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

/*
  void getImge() async {
    final listResult = await FirebaseStorage.instance
        .ref()
        .child("business_certification/")
        .listAll();

    final islandRef = FirebaseStorage.instance.ref().child("1678203722204.png");

    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.absolute}/business_certification/test.jpeg";
    final file = File(filePath);

    for (var list in listResult.items) {
      list.getDownloadURL().then((String result) async {
        print(result);
        // await _saveImage(result, list.name);
      });
    }
  }

*/
/*
  Future<void> _saveImage(url, name) async {
    String? message;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final listResult = await FirebaseStorage.instance
        .ref()
        .child("business_certification/")
        .child("test1.jpeg")
        .listAll();

    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();

      var filename = '${dir.path}/${name}';
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // final params = SaveFileDialogParams(sourceFilePath: file.path);
      // final finalPath = await FlutterFileDialog.saveFile(params: params);
      setState(() {
        storePhoto.add(file);
      });

      // if (finalPath != null) {
      //   message = 'Image saved to disk';
      // }
    } catch (e) {
      message = 'An error occurred while saving the image';
      print(e.toString());
    }

    if (message != null) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  */

  _addressAPI() async {
    Kpostal model = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KpostalView(
              kakaoKey: '8ba72a270b2ab65050c15f1aa2cce9a9',
              useLocalServer: false,
              callback: (Kpostal result) {
                setState(() {
                  print("주소callback");
                  print(result.postCode);
                  addrController.text =
                      result.address ?? "주소 없음" + result.buildingName ?? "";
                  _store!.store_lat = result.latitude as double;
                  _store!.store_lng = result.longitude as double;

                  // this.address = result.address;
                  // this.latitude = result.latitude.toString();
                  // this.longitude = result.longitude.toString();
                  // this.kakaoLatitude = result.kakaoLatitude.toString();
                  // this.kakaoLongitude = result.kakaoLongitude.toString();
                });
              }),
        )
        // CupertinoPageRoute(
        //   builder: (context) => KpostalView(
        //     kakaoKey: '8ba72a270b2ab65050c15f1aa2cce9a9',
        //     useLocalServer: false,
        //   ),

        // ),
        );

    // Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
    //     print(result.address);
    print("검색된 주소");
    print('${model.addressEng!} ${model.address!} ${model.buildingName!}');
    print("latitude: ${model.latitude} / longitude: ${model.longitude}");
    print("through KAKAO Geocoder");
    print(
        "latitude: ${model.kakaoLatitude} / longitude: ${model.kakaoLongitude}");
  }

/*
  Future<void> uploadImg(index, value) async {
    print("이미지 저장");
    final storageRef = FirebaseStorage.instance.ref();

    try {
      final imgName = value.path.toString().split('/').last;
      final mountainsRef = storageRef
          .child("business_certification/unapproved/${imgName}_${index}.jpeg");
      await mountainsRef.putFile(File(value.path));

      // StorageUploadTask storageUploadTask =
      // storageReference.putFile(_image);

      // // 파일 업로드 완료까지 대기
      // await storageUploadTask.onComplete;
    } on FirebaseException catch (e) {
      print("사진 업로드 실패" + e.code);
    }
    // 업로드한 사진의 URL 획득
    String downloadURL = await storageRef.getDownloadURL();
  }

*/

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
    List<Widget> itemWidgets = _storeImage.map((item) {
      return Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.fromLTRB(0, 2, 2, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Image.file(
            File(item.path),
            fit: BoxFit.cover,
          ),
        ),
      );
    }).toList();

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
                      builder: (context) =>
                          PhotoUploadePage(savedImage: _storeImage)),
                );

                setState(() {
                  _storeImage = result;
                });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image(
                    image: AssetImage('assets/camera.jpeg'),
                    width: 100,
                    height: 100,
                  )),
            )));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: itemWidgets),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String postCode = '-';
  String address = '-';
  String latitude = '-';
  String longitude = '-';
  String kakaoLatitude = '-';
  String kakaoLongitude = '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KpostalView(
                      useLocalServer: false,
                      kakaoKey: '8ba72a270b2ab65050c15f1aa2cce9a9',
                      callback: (Kpostal result) {
                        setState(() {
                          this.postCode = result.postCode;
                          this.address = result.address;
                          this.latitude = result.latitude.toString();
                          this.longitude = result.longitude.toString();
                          this.kakaoLatitude = result.kakaoLatitude.toString();
                          this.kakaoLongitude =
                              result.kakaoLongitude.toString();
                        });
                      },
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue)),
              child: Text(
                'Search Address',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              padding: EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Text('postCode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: ${this.postCode}'),
                  Text('address',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: ${this.address}'),
                  Text('LatLng', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'latitude: ${this.latitude} / longitude: ${this.longitude}'),
                  Text('through KAKAO Geocoder',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'latitude: ${this.kakaoLatitude} / longitude: ${this.kakaoLongitude}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
