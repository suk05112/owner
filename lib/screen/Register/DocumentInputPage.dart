import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/screen/Register/SingUpCompletePage.dart';
import 'dart:io';

import '../../common/CommonWidget.dart';

class DocumentInputPage extends StatefulWidget {
  const DocumentInputPage({Key? key}) : super(key: key);

  @override
  State<DocumentInputPage> createState() => _DocumentInputPageState();
}

class _DocumentInputPageState extends State<DocumentInputPage> {
  late File? imageFile;
  var userImage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("매장 정보 입력"),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InputInfoWidget(
          title: "사업자 등록번호",
          hintText: "Enter your 사업자 등록번호",
          validator: validateName,
        ),
        DocumentUploadWidget(
          title: "사업자 등록증",
          validator: validateName,
        ),
        DocumentUploadWidget(
          title: "영업 신고증",
          validator: validateName,
        ),
        InputInfoWidget(
          title: "계좌번호",
          hintText: "Enter your 계좌번호",
          validator: validateName,
        ),
        DocumentUploadWidget(
          title: "통장 사본 업로드",
          validator: validateName,
        ),
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            PickedFile? pickedFile =
                await picker.getImage(source: ImageSource.gallery);
            // imageFile = File(pickedFile!.path);
            // setState(() => imageFile = File(pickedFile!.path));
            var image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setState(() {
                userImage = File(image.path);
              });
              final firebaseStorageRef = FirebaseStorage.instanceFor(
                  bucket: "gs://cafe-owner.appspot.com");
              final storageRef = FirebaseStorage.instance.ref();
              storageRef
                  .child('bankbook') // collection 이름
                  .child('_picName.jpg') // 업로드한 파일의 최종이름, 본인이 원하는 이름.
                  .putFile(userImage);
              // Image.file(File(userImage))
            }
          },
          child: Text('업로드'),
        ),
        userImage != null ? Image.file(userImage as File) : Text("I"),
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          width: double.infinity,
          height: 100,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Flexible(
              flex: 1,
              child: SizedBox(
                width: double.infinity, // <-- Your width
                height: 50,
                // width: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 151, 125, 253),
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('이전'),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              flex: 1,
              child: Container(
                width: double.infinity, // <-- Your width
                height: 50,
                // width: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 151, 125, 253),
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpCompletePage()));
                  },
                  child: Text('확인'),
                ),
              ),
            ),
          ]),
        ),
      ]),
    ));
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }
}

//upload
class DocumentUploadWidget extends StatefulWidget {
  DocumentUploadWidget({required this.title, required this.validator});

  final String title;
  Function(String?) validator;

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  late File _image;
  final picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        Container(
          height: 1.0,
          width: 500.0,
          color: Color.fromARGB(255, 71, 71, 71),
        ),
        const SizedBox(height: 5.0),
        Container(
            padding: EdgeInsets.only(top: 1, bottom: 1, left: 6, right: 6),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.title),
                  ElevatedButton(
                    onPressed: () async {
                      // getImage();
                      // uploadImageToFirebaseStorage();
                      // var picker = ImagePicker();
                      // XFile? image =
                      //     await picker.pickImage(source: ImageSource.gallery);
                      // // 스토리지에 먼저 사진 업로드 하는 부분.
                      // final firebaseStorageRef = FirebaseStorage.instanceFor(
                      //     bucket: "gs://cafe-owner.appspot.com");
                      // final storageRef = FirebaseStorage.instance.ref();
                      // storageRef
                      //     .child('bankbook') // collection 이름
                      //     .child('_picName.jpg') // 업로드한 파일의 최종이름, 본인이 원하는 이름.
                      //     .putFile(File(image!.path));
                    },
                    child: Text('업로드'),
                  ),
                  Text("업로드 된 파일 이름"),
                  const SizedBox(
                    height: 5.0,
                  ),
                ]))
      ],
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 65,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: "gs://cafe-owner.appspot.com");
    final storageRef = FirebaseStorage.instance.ref();

    Reference reference =
        storageRef.child('images/${DateTime.now().toString()}.jpeg');
    UploadTask uploadTask = reference.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    print('Image URL: $imageUrl');
  }

  Future<String?> uploadImageToFirebaseStorage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final File imageFile = File(pickedFile!.path);

    String fileName = DateTime.now().toString();
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    try {
      await storageReference.putFile(imageFile);
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}
