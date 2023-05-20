import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owner/common/model/CafeInfo.dart';
import 'package:owner/register.dart';
import 'package:owner/screen/Store/CafeDetailPage.dart';
import 'package:owner/screen/cafelist/cafelist_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import '../common/DatabaseService.dart';
import '../common/model/Store.dart';
import 'Register/OperatingHoursSettingPage.dart';
import 'Register/PhotoUploadPage.dart';
import 'Register/SettingOpeningDatePage.dart';
import 'cafe_detail/cafe_detail_page.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage(
      {Key? key, required this.isRegister, required this.store});
  final bool isRegister;
  final CafeInfo? store;

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  DatabaseService service = DatabaseService();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController telePhoneController = TextEditingController();
  TextEditingController introController = TextEditingController();

  late bool _isRegister;
  late CafeInfo? _store;
  final _formKey = GlobalKey<FormState>();
  var storePhoto = [];

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
                      ? TextFormField(
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
                        )
                      : Text('not register ${_store?.store_name}'),
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
                      _navigateUploadPhoto(context);
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
                      Store store = Store(
                          logo: "new logo",
                          store_name: nameController.text,
                          store_telephone: telePhoneController.text,
                          owner_id: "0000001",
                          open_yn: false,
                          operatingHourId: "operatingHourId",
                          introduce: introController.text);
                      service.registerStore("ownerId", store);

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
  // return GridView.builder(
  //     shrinkWrap: true,
  //     physics: ScrollPhysics(),
  //     primary: true,
  //     padding: EdgeInsets.only(top: 15.0),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 0.2, //1.0
  //       crossAxisSpacing: 4.0, //1.0
  //       // mainAxisExtent: 100,
  //     ),
  //     itemCount: _storePhoto.length,
  //     itemBuilder: (context, index) {
  //       return Container(
  //         width: 50, // <-- Your width
  //         height: 50,
  //         padding: EdgeInsets.all(1),
  //         child: Image.file(
  //           _storePhoto[index],
  //           fit: BoxFit.cover,
  //         ),
  //       );
  //     });
  // }
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController traitsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

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
                          const Text('Name', style: textStyle),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: inputDecoration.copyWith(
                                hintText: "Enter your Name"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Name';
                              }
                              return null;
                            },
                          ),
                          !isLoading
                              ? Center(
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(200, 50)),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      255, 83, 80, 80))),
                                      onPressed: (() async {
                                        if (_formKey.currentState!.validate()) {
                                          DatabaseService service =
                                              DatabaseService();
                                          List<String> employeeTraits =
                                              traitsController.text.split(",");
                                          late Address address;
                                          if (addressController.text
                                              .contains(",")) {
                                            List<String> fullAddress =
                                                addressController.text
                                                    .split(",");
                                            address = Address(
                                                streetName: fullAddress[0],
                                                buildingName: fullAddress[1],
                                                cityName: fullAddress[2]);
                                          }
                                          Employee employee = Employee(
                                              name: nameController.text,
                                              age:
                                                  int.parse(ageController.text),
                                              salary: int.parse(
                                                  salaryController.text),
                                              address: address,
                                              employeeTraits: employeeTraits);
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await service.addEmployee(employee);
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }),
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(fontSize: 20),
                                      )),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.push(
                              //     context,
                              //     // MaterialPageRoute(builder: (context) => CafeList()));
                              //     MaterialPageRoute(builder: (context) => EmployeeScreen()));
                            },
                            child: Text("뒤로가기"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigator.pushNamed(context, '/add');
                              Navigator.push(
                                  context,
                                  // MaterialPageRoute(builder: (context) => CafeList()));
                                  MaterialPageRoute(
                                      builder: (context) => CafeList()));
                            },
                            child: Text("cafe info"),
                          ),
                        ])))));
  }

  static const textStyle = TextStyle(
    color: Colors.white,
    fontSize: 22.0,
    letterSpacing: 1,
    fontWeight: FontWeight.bold,
  );

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}

class Employee {
  final String? id;
  final String name;
  final int age;
  final int salary;
  final Address address;
  final List<String>? employeeTraits;
  Employee(
      {this.id,
      required this.name,
      required this.age,
      required this.salary,
      required this.address,
      this.employeeTraits});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'salary': salary,
      'address': address.toMap(),
      'employeeTraits': employeeTraits
    };
  }

  Employee.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()!["name"],
        age = doc.data()!["age"],
        salary = doc.data()!["salary"],
        address = Address.fromMap(doc.data()!["address"]),
        employeeTraits = doc.data()?["employeeTraits"] == null
            ? null
            : doc.data()?["employeeTraits"].cast<String>();
}

class Address {
  final String streetName;
  final String buildingName;
  final String cityName;

  Address(
      {required this.streetName,
      required this.buildingName,
      required this.cityName});

  Map<String, dynamic> toMap() {
    return {
      'streetName': streetName,
      'buildingName': buildingName,
      'cityName': cityName,
    };
  }

  Address.fromMap(Map<String, dynamic> addressMap)
      : streetName = addressMap["streetName"],
        buildingName = addressMap["buildingName"],
        cityName = addressMap["cityName"];
}
