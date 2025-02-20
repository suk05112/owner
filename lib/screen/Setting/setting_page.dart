import 'package:flutter/material.dart';
import 'package:owner/screen/Setting/faq_page.dart';
import 'package:owner/screen/Setting/notice_page.dart';
import 'package:owner/screen/Setting/user_info_page.dart';
import 'package:owner/screen/Settlement/settlement_page.dart';
import 'package:owner/screen/inquiry_page.dart';

import '../../common/Style/CommonSection.dart';
import '../Register/operating_hours_setting_Page.dart';
import '../Store/MenuManagementPage.dart';
import 'package:owner/oss_licenses.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("설정"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
                margin: const EdgeInsets.fromLTRB(21, 0, 21, 21),
                // height: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getsettingListView(),
                      const Spacer(),
                      businessInformation()
                    ]))));
  }

  List dataListItem() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      "내 정보",
      "공지사항",
      "문의하기",
      /*"정산계좌 관리",*/
      "자주묻는 질문",
      // "알림",
      "라이선스",
      "버전",
    ];
    return items;
  }

  List getSelectedPage() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      const UserInfoPage(),
      const NoticePage(),
      const InquiryPage(),
      const FAQPage(),
      // const OperatingHoursSettingPage(),
      // OperatingHoursSettingPage(),
      // MenuManagementPage(
      //   storeId: _storeId,
      // ),
      OssLicensesPage(),
      // const LicensePage()
    ];

    return items;
  }

//Converting the dataSources as a widget
  Widget getsettingListView() {
    var allItems = dataListItem();
    var selectedPage = getSelectedPage();
    // var listView = ListView.separated(
    var listView = ListView.builder(
      itemCount: allItems.length,
      itemExtent: 46.0,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 5) {
          return Version();
        } else {
          return GestureDetector(
              //You need to make my child interactive
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => selectedPage[index])),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${allItems[index]}"),
                    const Divider()
                  ]));
          // return ListTile(title: Text(allItems[index]));
        }
      },
    );
    return listView;
  }

  Widget Version() {
    return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("버전"), Spacer(), Text("v 1.0.0"), Divider()])
        ]);
  }

  Widget businessInformation() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("502 Company",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          Text("대표: 한수진", style: TextStyle(fontSize: 10)),
          Text("사업자 등록번호: 479-03-03427", style: TextStyle(fontSize: 10)),
          Text("주소: 서울특별시 강서구 공항대로 543", style: TextStyle(fontSize: 10)),
          Text("이메일: service@502company.com", style: TextStyle(fontSize: 10)),
          Text("고객센터: 02-3664-3338", style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class LicensePage extends StatelessWidget {
  const LicensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("라이선스"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(21, 0, 21, 21),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("this is license page")],
                  ))
            ]))));
  }
}

class OssLicensesPage extends StatelessWidget {
  static Future<List<String>> loadLicenses() async {
    final ossKeys = List<String>.from(ossLicenses);
    return ossKeys..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("라이선스"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (var i = 0; i < ossLicenses.length; i++)
                ListTile(
                  title: Text(ossLicenses[i].name),
                  // subtitle: ossLicenses[i].description != null ? Text(ossLicenses[i].description!) : null,
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 클릭하면 해당 오픈소스 라이선스 페이지로 이동
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MiscOssLicenseSingle(
                            name: ossLicenses[i].name ?? '',
                            version: ossLicenses[i].version ?? '',
                            description: ossLicenses[i].description ?? '',
                            licenseText: ossLicenses[i].license ?? '',
                            homepage: ossLicenses[i].homepage ?? '')));
                  },
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MiscOssLicenseSingle(name: ossLicenses[i].name, json: ossLicenses[i])))
                )
            ],
          ),
        ));
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final String version;
  final String description;
  final String licenseText;
  final String homepage;

  MiscOssLicenseSingle({
    required this.name,
    required this.version,
    required this.description,
    required this.licenseText,
    required this.homepage,
  });

  String _bodyText() {
    return licenseText.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("라이선스"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(name),
              subtitle: Text('version : $version'),
            ),
            if (description != null)
              Padding(
                  padding:
                      const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: Text(description)),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: Text(_bodyText()),
            ),
            const Divider(),
            ListTile(
              title: Text('Homepage'),
              subtitle: Text(homepage),
              // onTap: () async {
              //   if (await canLaunch(homepage)) {
              //     await launch(homepage);
              //   } else {
              //     throw 'Could not launch $homepage';
              //   }
              // }
            ),
          ],
        ),
      ),
    );
  }
}
