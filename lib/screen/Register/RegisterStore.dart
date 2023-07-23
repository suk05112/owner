import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/APIDioClient.dart';
import 'package:owner/common/api/request/store/register_store_post.dart';
import 'package:owner/common/api/response/store/store.dart';
import 'package:owner/common/model/cafeInfo.dart';
import 'package:owner/register.dart';
import 'package:owner/screen/Store/CafeDetailPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

// import '../../common/DatabaseService.dart';
import 'OperatingHoursSettingPage.dart';
import 'PhotoUploadPage.dart';
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
  final CafeInfo? store;

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  // DatabaseService service = DatabaseService();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController telePhoneController = TextEditingController();
  TextEditingController introController = TextEditingController();

  late bool _isRegister;
  late CafeInfo? _store;
  final _formKey = GlobalKey<FormState>();
  var storePhoto = [];

  File? _imageFile;

  @override
  void initState() {
    _isRegister = widget.isRegister;
    _store = widget.store;

    if (_isRegister == false) {
      getImge();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Add Employee"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("매장 이름"),
                  _isRegister
                      ? TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          decoration: inputDecoration.copyWith(
                              hintText: "Enter your Store Name"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Name';
                            }
                            return null;
                          },
                        )
                      : Text('not register ${_store?.store_name}'),
                  Text("주소"),
                  _isRegister
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Flexible(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: addressController,
                                    keyboardType: TextInputType.text,
                                    decoration: inputDecoration.copyWith(
                                        hintText: "Enter your Store Address"),
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
                                      backgroundColor:
                                          Color.fromARGB(255, 151, 125, 253),
                                      minimumSize:
                                          const Size.fromHeight(50), // NEW
                                    ),
                                    onPressed: () async {
                                      _addressAPI();
                                      // Kpostal model = await Navigator.push(
                                      //   context,
                                      //   CupertinoPageRoute(
                                      //     builder: (context) => KpostalView(
                                      //       kakaoKey:
                                      //           '8ba72a270b2ab65050c15f1aa2cce9a9',
                                      //       useLocalServer: false,
                                      //     ),
                                      //   ),
                                      // );
                                      // addressController.text = model.address;
                                    },
                                    child: Text('주소 검색'),
                                  ))
                            ])
                      : Text('not register ${_store?.store_name}'),
                  Text("상세주소"),
                  TextFormField(
                    controller: telePhoneController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your Store TelePhone"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter TelePhone';
                      }
                      return null;
                    },
                  ),
                  Text("전화번호"),
                  TextFormField(
                    controller: telePhoneController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your Store TelePhone"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter TelePhone';
                      }
                      return null;
                    },
                  ),
                  Text("가게소개"),
                  TextFormField(
                    controller: introController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your Store TelePhone"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter TelePhone';
                      }
                      return null;
                    },
                  ),
                  Text("운영시간"),
                  TextButton(
                    child: Text(
                      "Visit GeeksforGeeks",
                      style: TextStyle(fontSize: 25),
                    ),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OperatingHoursSettingPage()));
                    },
                  ),
                  Text("가게 대표 사진"),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      _navigateUploadPhoto(context);
                    },
                    child: Text('업로드'),
                  ),

                  ItemGridview(),

                  // SizedBox(
                  //   width: 100, // <-- Your width
                  //   height: 100,
                  //   child: ElevatedButton(
                  //     child: Text("업로드".toUpperCase(),
                  //         style: TextStyle(fontSize: 14)),
                  //     style: buttonStyle,
                  //     onPressed: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) =>
                  //                   const PhotoUploadePage()));
                  //     },
                  //   ),
                  // ),
                  Text("로고 사진"),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 151, 125, 253),
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(title: 'test')));
                      // _navigateUploadPhoto(context);
                    },
                    child: Text('업로드'),
                  ),

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
                      storePhoto
                          .asMap()
                          .forEach((index, value) => uploadImg(index, value));

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
        ));
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

    RegisterStorePost store = RegisterStorePost(
        owner_id: 1,
        store_logo: "new logo",
        store_name: nameController.text,
        store_telephone: telePhoneController.text,
        store_photo_cnt: 5,
        store_address: "Adr",
        store_lat: 1,
        store_lng: 1,
        business_registration: "busi",
        store_description: introController.text);

    await Api().client.registerStore(store).then((response) {
      var storeId = response.storeId;
      print("등록성공" + storeId.toString());
      ApiServiceImpl().uploadImage();

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
        await _saveImage(result, list.name);
      });
    }
  }

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
  }

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

  // SelectionScreen을 띄우고 navigator.pop으로부터 결과를 기다리는 메서드
  _navigateUploadPhoto(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PhotoUploadePage(savedImage: storePhoto)),
    );

    setState(() {
      storePhoto = result;
    });
    storePhoto = result;
  }

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));

  final buttonStyle = ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0)),
      backgroundColor:
          MaterialStateProperty.all<Color>(Color.fromARGB(255, 154, 152, 152)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)))));

  Widget ItemGridview() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: storePhoto.map((item) {
          return SizedBox(
            height: 100,
            width: 100,
            child: Image.file(
              File(item.path),
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
    // );
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
