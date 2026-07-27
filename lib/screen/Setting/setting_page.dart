import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owner/screen/Setting/faq_page.dart';
import 'package:owner/screen/Setting/notice_page.dart';
import 'package:owner/screen/Setting/user_info_page.dart';
import 'package:owner/screen/inquiry_page.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/screen/LoginPage.dart';
import 'package:owner/screen/Setting/terms_page.dart';
import 'package:owner/oss_licenses.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Future<String> _version;

  @override
  void initState() {
    super.initState();
    _version = getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "더보기"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getUserInfo(),
                    const SizedBox(height: 24),
                    getsettingListView(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              businessInformation(),
            ],
          ),
        ),
      ),
    );
  }

  List dataListItem() {
    var items = [
      "내 정보",
      "공지사항",
      "문의하기",
      "자주묻는 질문",
      "약관 보기",
      "라이선스",
      "버전",
    ];
    return items;
  }

  List<IconData> getIcons() {
    return [
      Icons.person_outline,
      Icons.notifications_outlined,
      Icons.contact_support_outlined,
      Icons.help_outline,
      Icons.description_outlined,
      Icons.description_outlined,
      Icons.info_outline,
    ];
  }

  List getSelectedPage() {
    var items = [
      const UserInfoPage(),
      const NoticePage(),
      const InquiryPage(),
      const FAQPage(),
      const TermsPage(),
      OssLicensesPage(),
    ];
    return items;
  }

  String _formatLoginId(String? loginId) {
    if (loginId == null || loginId.isEmpty) return "";
    return loginId.replaceAll("@gifnut.com", "");
  }

  Widget getUserInfo() {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(returnToPrevious: true),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "로그인 & 가입하기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "로그인 후 서비스 이용이 가능합니다.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserInfoPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLoginId(user.login_id),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget getsettingListView() {
    var allItems = dataListItem();
    var selectedPage = getSelectedPage();
    var icons = getIcons();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int index = 0; index < allItems.length; index++)
            if (index == 6)
              version()
            else
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => selectedPage[index]),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icons[index],
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          allItems[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget version() {
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFE7831))),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "버전",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Text(
                  "v 1.0.0",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "버전",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "v ${snapshot.data}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Widget businessInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "502 Company \n대표: 한수진 \n사업자등록번호: 479-03-03427",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "주소: 서울특별시 강남대로 112길 47, 2층-661A호\n이메일: admin@502company.com \n고객센터: 02-3664-3338",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

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
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MiscOssLicenseSingle(
                      name: ossLicenses[i].name,
                      version: ossLicenses[i].version,
                      description: ossLicenses[i].description,
                      licenseText: ossLicenses[i].license ?? '',
                      homepage: ossLicenses[i].homepage ?? '',
                    ),
                  ));
                },
              )
          ],
        ),
      ),
    );
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final String version;
  final String description;
  final String licenseText;
  final String homepage;

  const MiscOssLicenseSingle({
    super.key,
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
            if (description.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                child: Text(description),
              ),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: Text(_bodyText()),
            ),
            const Divider(),
            ListTile(
              title: const Text('Homepage'),
              subtitle: Text(homepage),
            ),
          ],
        ),
      ),
    );
  }
}
