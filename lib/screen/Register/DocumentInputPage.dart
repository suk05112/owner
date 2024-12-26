import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/screen/Register/SingUpCompletePage.dart';
import 'package:owner/screen/Register/register_store_page.dart';
import 'package:provider/provider.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'dart:io';

import '../../common/Style/TextAsset.dart';
import '../../common/api/request/store/store.dart';
import '../../common/widget/CommonWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DocumentInputPage extends StatefulWidget {
  const DocumentInputPage({Key? key}) : super(key: key);
  // final Store? store;

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

  final _formKey = GlobalKey<FormState>();

  late Store _store;
  late File? imageFile;
  bool _isChecked = false;

  var userImage;

  final inputDecoration = const InputDecoration(
    hintStyle: TextAssset.placeholder,
    border: UnderlineInputBorder(
        // borderRadius: BorderRadius.circular(5.0),
        ),
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(0, 5, 21, 5),
  );

  void initState() {
    super.initState();
    User? user = Provider.of<UserProvider>(context, listen: false).user;

    _store = Store(owner_id: user?.owner_id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("매장 등록하기"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Container(
                    margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //대표자명
                          Text(
                            "대표자명",
                            style: TextAssset.header2,
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration:
                                inputDecoration.copyWith(hintText: "이름 입력"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),

                          //가게 이름
                          Text(
                            "가게이름",
                            style: TextAssset.header2,
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: storenNameController,
                            keyboardType: TextInputType.text,
                            decoration:
                                inputDecoration.copyWith(hintText: "매장 이름 입력"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 5),

                          // 가게 주소
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "주소",
                                  style: TextAssset.header2,
                                ),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                          flex: 2,
                                          child: TextFormField(
                                            style: TextAssset.placeholder2,
                                            enabled: false,
                                            controller: addrController,
                                            keyboardType: TextInputType.text,
                                            decoration: inputDecoration.copyWith(
                                                hintText:
                                                    "Enter your Store Address"),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              backgroundColor: Colors.white,
                                              minimumSize:
                                                  const Size.fromHeight(
                                                      50), // NEW
                                            ),
                                            onPressed: () async {
                                              _addressAPI();
                                            },
                                            child: const Text(
                                              '주소 검색',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ))
                                    ]),
                                const SizedBox(
                                  height: 5,
                                ),
                                //상세주소
                                TextFormField(
                                  controller: detailAddrController,
                                  keyboardType: TextInputType.text,
                                  decoration: inputDecoration.copyWith(
                                      hintText: "상세주소 입력"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter TelePhone';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 5),
                              ]),

                          InputInfoWidget(
                            title: "사업자 등록번호",
                            hintText: "사업자 등록번호 입력",
                            validator: validateName,
                          ),

                          const SizedBox(height: 5),

                          DocumentUploadWidget(
                            title: "사업자 등록증",
                            validator: validateBR,
                          ),
                          DocumentUploadWidget(
                            title: "통장 사본",
                            validator: validatebankBook,
                          ),

                          const ExpansionTile(
                              iconColor: Colors.black,
                              collapsedIconColor: Colors.black,
                              title: Text(
                                "개인정보 수집 및 이용 동의",
                                style: TextStyle(
                                  // fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              children: [
                                Text(
                                    "수집 목적: 입점 신청자 연락 및 상담\n수집 항목: 성명, 휴대폰 번호, 제출서류(사업자등록증, 영업신고증 등)에 포함된 개인정보\n보유 및 이용기간: 6개월\n개인정보 수집 및 이용 동의를 거부할 권리가 있으며, 거부할 경우 입점신청이 불가합니다.")
                              ]),
                          Row(
                            children: [
                              Checkbox(
                                  value: _isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      _isChecked = !_isChecked;
                                    });
                                  }),
                              Text("[필수] 개인정보 수집 및 이용 동의합니다")
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorAssset.mainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                // minimumSize: const Size.fromHeight(50), // NEW
                              ),
                              onPressed: () {
                                if (!_isChecked) {
                                  showToast();
                                  return;
                                }
                                _store.store_name = storenNameController.text;
                                _store.store_address =
                                    "${addrController.text} ${detailAddrController.text}";

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterStorePage(
                                              isRegister: true,
                                              store: _store,
                                            )));
                              },
                              child: const Text(
                                '다음',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ])))));
  }

  void showToast() {
    Fluttertoast.showToast(
        msg: "개인정보 수집 이용에 동의해주세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }

  // validate businessRegistration
  String? validateBR(File? value) {
    if (value == null) {
      return "빈 문자열";
    }
    _store.business_registration = value;
    return null;
  }

  // validate bankBook
  String? validatebankBook(File? value) {
    if (value == null) {
      return "빈 문자열";
    }
    return null;
  }

  _addressAPI() async {
    Kpostal model = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KpostalView(
              kakaoKey: '16dd251b86287783606ea600a98c7131',
              useLocalServer: false,
              callback: (Kpostal result) {
                setState(() {
                  print("주소callback");
                  print(result.postCode);
                  addrController.text =
                      result.address ?? "주소 없음" + result.buildingName ?? "";
                  _store!.store_lat = result.latitude as double;
                  _store!.store_lng = result.longitude as double;
                });
              }),
        ));
  }
}

//upload
class DocumentUploadWidget extends StatefulWidget {
  DocumentUploadWidget({required this.title, required this.validator});

  final String title;
  Function(File?) validator;

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  late File _image;
  final picker = ImagePicker();
  String? uploadedFilename;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextAssset.header2,
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffF2F2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onPressed: uploadedFilename == null
                      ? () async {
                          final pickedImage = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedImage != null) {
                            widget.validator(File(pickedImage.path));
                            setState(() {
                              uploadedFilename = pickedImage.name;
                            });
                          }
                        }
                      : null,
                  child: uploadedFilename == null
                      ? const Text(
                          '파일 업로드',
                          style: TextStyle(color: Colors.black),
                        )
                      : const Text('업로드 완료',
                          style: TextStyle(color: Colors.black)),
                ),
              ),
              Visibility(
                visible: uploadedFilename != null,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffD7DBE6),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Container(
                        width: 300,
                        height: 50,
                        child: Text(
                          uploadedFilename ?? "업로드 된 파일 이름",
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/X_button.png',
                          width: 10,
                          height: 10,
                        ),
                        // iconSize: 10,
                        onPressed: () {
                          setState(() {
                            uploadedFilename = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
            ])
      ],
    );
  }
}
